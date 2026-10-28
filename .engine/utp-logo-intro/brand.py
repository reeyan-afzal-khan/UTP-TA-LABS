"""The UTP logo as clean vector art, for a white background, and its animation.

The logo (logo-UTP.png, next to this file) is a 391 x 761 raster drawn for
paper. It is rebuilt once as vector layers, each made as cleanly as the
source allows:

    oval     an exact ellipse, fitted to the emblem (not traced: no wobble)
    lines    the gold lines, traced at 8x from soft colour coverage (sub-pixel
             edges, true line widths) and made exactly symmetric by averaging
             the emblem with its mirror image
    word     UNIVERSITI / TEKNOLOGI / PETRONAS set in a real serif (Georgia,
             the closest installed match), each letter fitted to the box of
             the original letter, so the spacing is the logo's own, in the
             logo's own blue (WORD_COLOR)
    rules    the two gold rules, as exact rectangles

The centre lines of the gold lines are also extracted (thinning, then joined
through crossings into long strokes), so the animation can draw the emblem
like a pen, rising from the stem, before the exact shapes take over.

Everything is cached in the cache's brand folder; delete it to rebuild.
"""

from __future__ import annotations

import glob
import json
from pathlib import Path

import numpy as np
from PIL import Image

from render_kit import HERE, cache_dir, within

SOURCE = HERE / "logo-UTP.png"
UTP_BLUE = "#0B4F94"
UTP_GOLD = "#E5A21E"
WORD_COLOR = "#034A8C"          # the wordmark: the blue of the printed letters (white on black, in the lectures)
WORD_FONT = "georgia.ttf"       # the wordmark face (falls back to tracing the letters)
S = 8                           # vector units per source pixel
VERSION = "13"


# ------------------------------------------------------------------ helpers

def _bands(alpha: np.ndarray) -> list[tuple[int, int]]:
    rows = alpha.max(axis=1) > 0.16
    bands, start = [], None
    for y, filled in enumerate(rows):
        if filled and start is None:
            start = y
        if not filled and start is not None:
            bands.append((start, y - 1))
            start = None
    if start is not None:
        bands.append((start, len(rows) - 1))
    return bands


def _up(arr: np.ndarray, scale: int) -> np.ndarray:
    """A float image enlarged with Lanczos: soft edges stay soft, so a 0.5 threshold is sub-pixel exact."""
    im = Image.fromarray(arr.astype(np.float32), mode="F")
    return np.asarray(im.resize((im.width * scale, im.height * scale), Image.LANCZOS))


def _mirror(arr: np.ndarray, cx: float) -> np.ndarray:
    """The image reflected about the vertical line x = cx (array pixel units, centres at i + 0.5)."""
    from scipy.ndimage import shift
    w = arr.shape[1]
    flipped = arr[:, ::-1]                       # reflection about x = w / 2
    return shift(flipped, (0, 2 * cx - w), order=3, mode="constant")


def _potrace_paths(mask: np.ndarray, turd: int, ox: float = 0.0, oy: float = 0.0, scale: float = 1.0) -> str:
    import potrace
    bm = potrace.Bitmap(~mask)                   # potrace traces dark pixels: the shape is the ink
    plist = bm.trace(turdsize=turd, alphamax=1.1, opticurve=True, opttolerance=0.25)

    def pt(q) -> str:
        return f"{q.x * scale + ox:.2f},{q.y * scale + oy:.2f}"
    parts = []
    for curve in plist:
        d = [f"M{pt(curve.start_point)}"]
        for seg in curve.segments:
            if seg.is_corner:
                d.append(f"L{pt(seg.c)}L{pt(seg.end_point)}")
            else:
                d.append(f"C{pt(seg.c1)} {pt(seg.c2)} {pt(seg.end_point)}")
        d.append("Z")
        parts.append("".join(d))
    return " ".join(parts)


def _flow(lines_mask: np.ndarray, cx: float, cy: float, rx: float, ry: float, width: float,
          levels: int = 100) -> dict:
    """The gold filling the engraved lines from the base.

    Every point of the gold gets its distance along the lines from where they meet the bottom of the
    oval (Dijkstra over the gold pixels). The reveal at a distance is the region within it, traced as
    one path per level (SVG units); the intro shows the exact artwork cut by these paths, so the lines
    are never thicker or thinner than the logo, and the symmetric artwork flows symmetrically. Also
    returned: the flow fronts at every level (where the glowing tips sit)."""
    from scipy.ndimage import distance_transform_edt, label
    from scipy.sparse import coo_matrix
    from scipy.sparse.csgraph import dijkstra
    f = 4                                                      # the flow grid: 2 px per source pixel
    grid = np.asarray(Image.fromarray((lines_mask * 255).astype(np.uint8)).resize(
        (lines_mask.shape[1] // f, lines_mask.shape[0] // f), Image.LANCZOS)) > 127
    h, w = grid.shape
    ys, xs = np.nonzero(grid)
    index = -np.ones(grid.shape, dtype=np.int64)
    index[ys, xs] = np.arange(len(ys))
    rows, cols, cost = [], [], []
    for dy, dx, c in ((0, 1, 1.0), (1, 0, 1.0), (1, 1, 2 ** 0.5), (1, -1, 2 ** 0.5)):
        a = index[0:h - dy, max(0, -dx):w - max(0, dx)]       # each pixel ...
        b = index[dy:h, max(0, dx):w - max(0, -dx)]           # ... and its neighbour at (dy, dx)
        ok = (a >= 0) & (b >= 0)
        rows.append(a[ok])
        cols.append(b[ok])
        cost.append(np.full(int(ok.sum()), c))
    graph = coo_matrix((np.concatenate(cost), (np.concatenate(rows), np.concatenate(cols))),
                       shape=(len(ys), len(ys))).tocsr()
    # the sources: gold touching the oval in its lower half (the feet of the lines)
    sx, sy = (xs + 0.5) * f / S, (ys + 0.5) * f / S
    rim = (((sx - cx) / rx) ** 2 + ((sy - cy) / ry) ** 2 >= 0.94) & (sy > cy)
    dist = dijkstra(graph, directed=False, indices=np.nonzero(rim)[0], min_only=True)
    finite = np.isfinite(dist)
    dist[~finite] = dist[finite].max()
    field = np.full(grid.shape, np.inf)
    field[ys, xs] = dist
    # off the gold, a point takes the distance of the nearest gold: the edges of a level then run
    # between the lines, where nothing is drawn, and cross a line only at its flow front
    _, (iy, ix) = distance_transform_edt(~grid, return_indices=True)
    field = field[iy, ix]
    top = float(dist.max())
    band = 0.8 * width / f
    # each level is the gold reached so far, traced at 4 px per source pixel (sub-pixel on screen), so
    # the intro just shows it: no boolean geometry at render time (it left stray triangles)
    g = 2
    fine_gold = np.asarray(Image.fromarray((lines_mask * 255).astype(np.uint8)).resize(
        (lines_mask.shape[1] // g, lines_mask.shape[0] // g), Image.LANCZOS)) > 127
    fine = np.asarray(Image.fromarray(field.astype(np.float32), mode="F").resize(
        (fine_gold.shape[1], fine_gold.shape[0]), Image.BILINEAR))
    out = {"levels": [], "fronts": []}
    for j in range(1, levels + 1):
        d = top * j / levels
        out["levels"].append(_potrace_paths(fine_gold & (fine <= d), turd=6, scale=g))
        front = grid & (field > d - band) & (field <= d)
        lab, n = label(front, structure=np.ones((3, 3)))
        pts = []
        for k in range(1, n + 1):
            py, px = np.nonzero(lab == k)
            if len(px) >= 3:
                pts.append([round(float(px.mean() + 0.5) * f, 1), round(float(py.mean() + 0.5) * f, 1)])
        out["fronts"].append(pts)
    return out


def _ellipse_path(cx: float, cy: float, rx: float, ry: float) -> str:
    """An ellipse as four cubic arcs, starting at the top and running clockwise (the drawing order)."""
    k = 0.5522847498
    return (f"M{cx:.2f},{cy - ry:.2f} "
            f"C{cx + k * rx:.2f},{cy - ry:.2f} {cx + rx:.2f},{cy - k * ry:.2f} {cx + rx:.2f},{cy:.2f} "
            f"C{cx + rx:.2f},{cy + k * ry:.2f} {cx + k * rx:.2f},{cy + ry:.2f} {cx:.2f},{cy + ry:.2f} "
            f"C{cx - k * rx:.2f},{cy + ry:.2f} {cx - rx:.2f},{cy + k * ry:.2f} {cx - rx:.2f},{cy:.2f} "
            f"C{cx - rx:.2f},{cy - k * ry:.2f} {cx - k * rx:.2f},{cy - ry:.2f} {cx:.2f},{cy - ry:.2f} Z")


def _font_path(name: str) -> str | None:
    for folder in (r"C:\Windows\Fonts", str(Path.home() / r"AppData\Local\Microsoft\Windows\Fonts")):
        for f in glob.glob(str(Path(folder) / "*")):
            if Path(f).name.lower() == name.lower():
                return f
    return None


def _glyph_path(font, ch: str, box: tuple[float, float, float, float]) -> str | None:
    """A letter's outline, fitted to box (x0, y0, x1, y1) in SVG units (y down)."""
    from fontTools.pens.boundsPen import BoundsPen
    from fontTools.pens.svgPathPen import SVGPathPen
    from fontTools.pens.transformPen import TransformPen
    gs = font.getGlyphSet()
    name = font.getBestCmap().get(ord(ch))
    if name is None:
        return None
    bp = BoundsPen(gs)
    gs[name].draw(bp)
    if bp.bounds is None:
        return None
    gx0, gy0, gx1, gy1 = bp.bounds
    x0, y0, x1, y1 = box
    sx, sy = (x1 - x0) / (gx1 - gx0), (y1 - y0) / (gy1 - gy0)
    pen = SVGPathPen(gs, ntos=lambda v: f"{v:.2f}")
    gs[name].draw(TransformPen(pen, (sx, 0, 0, -sy, x0 - gx0 * sx, y1 + gy0 * sy)))
    return pen.getCommands()


# --------------------------------------------------------- centre lines

def _thin(img: np.ndarray) -> np.ndarray:
    """Zhang-Suen thinning: the one-pixel centre line of a shape."""
    img = img.astype(np.uint8).copy()
    while True:
        changed = False
        for step in (0, 1):
            P = np.pad(img, 1)
            p2, p3, p4 = P[:-2, 1:-1], P[:-2, 2:], P[1:-1, 2:]
            p5, p6, p7 = P[2:, 2:], P[2:, 1:-1], P[2:, :-2]
            p8, p9 = P[1:-1, :-2], P[:-2, :-2]
            seq = [p2, p3, p4, p5, p6, p7, p8, p9, p2]
            B = p2 + p3 + p4 + p5 + p6 + p7 + p8 + p9
            A = sum(((seq[i] == 0) & (seq[i + 1] == 1)).astype(np.uint8) for i in range(8))
            if step == 0:
                c = ((p2 * p4 * p6) == 0) & ((p4 * p6 * p8) == 0)
            else:
                c = ((p2 * p4 * p8) == 0) & ((p2 * p6 * p8) == 0)
            m = (img == 1) & (B >= 2) & (B <= 6) & (A == 1) & c
            if m.any():
                img[m] = 0
                changed = True
        if not changed:
            return img.astype(bool)


DIRS = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)]


def _strokes(mask: np.ndarray, spur: float) -> list[np.ndarray]:
    """The centre lines of a line drawing as long polylines (x, y), joined straight through crossings."""
    sk = _thin(mask)
    pts = set(zip(*np.nonzero(sk)))

    def nbrs(p):
        return [(p[0] + dy, p[1] + dx) for dy, dx in DIRS if (p[0] + dy, p[1] + dx) in pts]

    node = {p for p in pts if len(nbrs(p)) != 2}
    # junction pixels that touch form one junction
    cluster: dict = {}
    for p in node:
        if p in cluster:
            continue
        cid, todo = len(set(cluster.values())), [p]
        while todo:
            q = todo.pop()
            if q in cluster:
                continue
            cluster[q] = cid
            todo += [r for r in nbrs(q) if r in node and r not in cluster]
    edges, seen = [], set()
    for p in node:
        for q in nbrs(p):
            if q in node or q in seen:
                continue
            path, prev, cur = [p, q], p, q
            while cur not in node:
                seen.add(cur)
                nxt = [r for r in nbrs(cur) if r != prev and r not in seen and r not in path[-4:]]
                if not nxt:
                    nxt = [r for r in nbrs(cur) if r in node and r != prev]
                    if not nxt:
                        break
                prev, cur = cur, nxt[0]
                path.append(cur)
            edges.append({"a": cluster[p], "b": cluster.get(cur), "pts": path})
    for p in pts - node - seen:                                  # closed loops with no junction
        if p in seen:
            continue
        path, prev, cur = [p], None, p
        while True:
            seen.add(cur)
            nxt = [r for r in nbrs(cur) if r != prev and r not in seen]
            if not nxt:
                break
            prev, cur = cur, nxt[0]
            path.append(cur)
        if len(path) > 8:
            edges.append({"a": None, "b": None, "pts": path + [path[0]]})
    # short spurs at line ends are thinning artefacts
    ends = {c for c in set(cluster.values()) if sum(1 for e in edges for k in ("a", "b") if e[k] == c) == 1}
    edges = [e for e in edges if not ((e["a"] in ends or e["b"] in ends) and len(e["pts"]) < spur)]
    # at each junction, continue every line through the most nearly straight partner
    ends_at: dict = {}
    for i, e in enumerate(edges):
        for k, side in (("a", 0), ("b", -1)):
            if e[k] is not None:
                ends_at.setdefault(e[k], []).append((i, side))

    def direction(i, side):
        p = np.array(edges[i]["pts"], dtype=float)
        p = p if side == 0 else p[::-1]
        far = p[min(len(p) - 1, 10)]
        d = far - p[0]
        return d / max(np.linalg.norm(d), 1e-9)

    link: dict = {}
    for c, incident in ends_at.items():
        cand = []
        for x in range(len(incident)):
            for y in range(x + 1, len(incident)):
                (i, si), (j, sj) = incident[x], incident[y]
                if i == j:
                    continue
                cand.append((float(np.dot(direction(i, si), direction(j, sj))), incident[x], incident[y]))
        used = set()
        for score, u, v in sorted(cand):
            if score > -0.6 or u in used or v in used:              # pair only lines that run on (> ~127 deg)
                continue
            used.update((u, v))
            link[u], link[v] = v, u
    out, done = [], set()
    for i in range(len(edges)):
        if i in done:
            continue
        # walk back to one end of this chain, then forward
        cur, side, guard = i, 0, 0
        while (cur, side) in link and guard < 200:
            j, sj = link[(cur, side)]
            if j == i:
                break
            cur, side = j, (-1 if sj == 0 else 0)
            guard += 1
        chain, cur, enter = [], cur, side
        guard = 0
        while cur not in done and guard < 200:
            done.add(cur)
            p = edges[cur]["pts"]
            chain += p if enter == 0 else p[::-1]
            leave = -1 if enter == 0 else 0
            if (cur, leave) not in link:
                break
            cur, s2 = link[(cur, leave)]
            enter = s2
            guard += 1
        out.append(np.array([(x, y) for y, x in chain], dtype=float))
    return out


def _smooth(poly: np.ndarray, win: int = 7, step: int = 3) -> np.ndarray:
    """A moving average over every column (x, y and any extra, such as the line's half width)."""
    if len(poly) < win + 2:
        return poly
    k = np.ones(win) / win
    sm = np.stack([np.convolve(np.pad(poly[:, j], win // 2, mode="edge"), k, mode="valid")
                   for j in range(poly.shape[1])], axis=1)
    sm[0, :2], sm[-1, :2] = poly[0, :2], poly[-1, :2]
    keep = list(range(0, len(sm), step))
    if keep[-1] != len(sm) - 1:
        keep.append(len(sm) - 1)
    return sm[keep]


# ------------------------------------------------------------- building

def trace_logo() -> dict[str, str]:
    """{"full", "emblem", "strokes", "meta"}: the logo, the emblem alone, the emblem's centre lines (all SVG,
    in the same units), and their line width."""
    out = cache_dir("brand")
    names = {k: out / f"utp-{k}-v{VERSION}.{'json' if k == 'meta' else 'svg'}" for k in ("full", "emblem", "strokes", "meta")}
    if all(p.exists() and p.stat().st_mtime >= SOURCE.stat().st_mtime for p in names.values()):
        return {k: str(p) for k, p in names.items()}
    rgba = np.asarray(Image.open(SOURCE).convert("RGBA")).astype(np.float64)
    rgb, a = rgba[..., :3], rgba[..., 3] / 255.0
    h, w = a.shape
    bands = _bands(a)
    e0, e1 = bands[0]
    # the two colours of the emblem, and how gold each pixel is (0 blue .. 1 gold), sub-pixel soft
    r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
    solid = a > 0.97
    gold_px = solid & (r > 170) & (b < 90) & (r > b + 90)
    blue_px = solid & (b > 100) & (r < 60)
    G, B = np.median(rgb[gold_px], axis=0), np.median(rgb[blue_px], axis=0)
    gold = np.clip(((rgb - B) @ (G - B)) / float((G - B) @ (G - B)), 0, 1) * a
    # the oval: an exact ellipse from the alpha moments of the emblem (a filled ellipse has var = r^2 / 4)
    ys, xs = np.mgrid[0:h, 0:w]
    m = a.copy()
    m[e1 + 1:] = 0
    tot = m.sum()
    cx, cy = (m * (xs + 0.5)).sum() / tot, (m * (ys + 0.5)).sum() / tot
    rx = 2 * np.sqrt((m * (xs + 0.5 - cx) ** 2).sum() / tot)
    ry = 2 * np.sqrt((m * (ys + 0.5 - cy) ** 2).sum() / tot)
    # The emblem is symmetric by design but the raster is not quite: find the axis of the gold design
    # (best match with its own mirror image), centre the oval on it, and build the right half as the
    # mirror of the left (averaging both halves blurs where they disagree).
    g_src = gold[: e1 + 1]
    best = (cx, -1.0)
    for c in np.arange(cx - 8, cx + 8, 0.25):
        mm = _mirror(g_src, c)
        score = float((g_src * mm).sum() / np.sqrt((g_src ** 2).sum() * (mm ** 2).sum()))
        if score > best[1]:
            best = (c, score)
    cx = float(best[0])
    # the gold lines: enlarged, the left half mirrored, cut at the oval, traced at the 50% edge
    g_up = _up(g_src, S)
    cols = np.arange(g_up.shape[1])[None, :] + 0.5
    g_up = np.where(cols < cx * S, g_up, _mirror(g_up, cx * S))
    yy, xx = np.mgrid[0:g_up.shape[0], 0:g_up.shape[1]]
    inside = (((xx + 0.5) / S - cx) / rx) ** 2 + (((yy + 0.5) / S - cy) / ry) ** 2 <= 1.0
    lines_mask = (g_up > 0.5) & inside
    d_lines = _potrace_paths(lines_mask, turd=S * S * 3)
    # the wordmark: one fitted letter per original letter (or the letters traced, without the font)
    word_paths = []
    texts = ["UNIVERSITI", "TEKNOLOGI", "PETRONAS"]
    font_file = _font_path(WORD_FONT)
    font = None
    if font_file:
        from fontTools.ttLib import TTFont
        font = TTFont(font_file)
    rules = []
    text_bands = []
    for y0, y1 in bands[1:]:
        band_gold = gold[y0:y1 + 1]
        if (band_gold > 0.5).mean() > 0.4:                     # a gold rule, not a line of letters
            up = _up(band_gold, S) > 0.5
            ry_, rx_ = np.nonzero(up)
            rules.append((y0 * S + ry_.min(), y0 * S + ry_.max() + 1, rx_.min(), rx_.max() + 1))
        else:
            text_bands.append((y0, y1))
    for (y0, y1), text in zip(text_bands, texts):
        cov = a[y0:y1 + 1] * (1 - gold[y0:y1 + 1])
        col = cov.max(axis=0) > 0.25
        segs, s0 = [], None
        for i, f in enumerate(col):
            if f and s0 is None:
                s0 = i
            if not f and s0 is not None:
                segs.append((s0, i - 1))
                s0 = None
        if s0 is not None:
            segs.append((s0, len(col) - 1))
        if font is None or len(segs) != len(text):
            word_paths.append(_potrace_paths(_up(cov, S) > 0.5, turd=S * S * 2, oy=y0 * S))
            continue
        for (c0, c1), ch in zip(segs, text):
            lo, hi = max(0, c0 - 1), min(cov.shape[1], c1 + 2)
            up = _up(cov[:, lo:hi], S) > 0.5                   # the letter's exact ink box
            ly, lx = np.nonzero(up)
            box = (lo * S + lx.min(), y0 * S + ly.min(), lo * S + lx.max() + 1, y0 * S + ly.max() + 1)
            d = _glyph_path(font, ch, box)
            if d:
                word_paths.append(d)
    # the centre lines of the gold lines, for drawing them like a pen
    from scipy.ndimage import distance_transform_edt
    k = 4                                                      # thinning at half the vector scale
    small = Image.fromarray((lines_mask * 255).astype(np.uint8)).resize(
        (lines_mask.shape[1] // (S // k), lines_mask.shape[0] // (S // k)), Image.LANCZOS)
    small = np.asarray(small) > 127
    dist = distance_transform_edt(small)
    half = float(np.median(dist[_thin(small)]))
    width = 2 * half * (S // k)
    polys = []
    for p in _strokes(small, spur=3 * width / (S // k)):
        # each centre-line point with the line's half width there (capped where lines cross and swell)
        hw = np.minimum(dist[p[:, 1].astype(int), p[:, 0].astype(int)], 1.8 * half)
        polys.append(_smooth(np.column_stack([p, hw])) * (S // k))
    polys = [p for p in polys
             if len(p) >= 3 and np.linalg.norm(np.diff(p[:, :2], axis=0), axis=1).sum() > 2 * width]
    for i, p in enumerate(polys):                              # every line is drawn from its lower end
        if p[0][1] < p[-1][1]:
            polys[i] = p[::-1]
    polys.sort(key=lambda p: -p[0][1])

    W, H = w * S, h * S
    frame = f'<rect x="0" y="0" width="{W}" height="{H}" fill="#000000" fill-opacity="0"/>'
    oval = f'<path d="{_ellipse_path(cx * S, cy * S, rx * S, ry * S)}" fill="{UTP_BLUE}"/>'
    lines = f'<path d="{d_lines}" fill="{UTP_GOLD}" fill-rule="evenodd"/>'
    rule_svg = "".join(f'<rect x="{x0}" y="{y0}" width="{x1 - x0}" height="{y1 - y0}" fill="{UTP_GOLD}"/>'
                       for y0, y1, x0, x1 in rules)
    word = "".join(f'<path d="{d}" fill="{WORD_COLOR}" fill-rule="nonzero"/>' for d in word_paths)
    head = f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}">'
    names["full"].write_text(head + frame + oval + lines + rule_svg + word + "</svg>", encoding="utf-8")
    EH = (e1 + 1) * S
    names["emblem"].write_text(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {EH}" width="{W}" '
                               f'height="{EH}">' + oval + lines + "</svg>", encoding="utf-8")
    strokes = "".join('<path d="M' + " L".join(f"{x:.1f},{y:.1f}" for x, y, _ in p) +
                      f'" fill="none" stroke="{UTP_GOLD}" stroke-width="{width:.1f}"/>' for p in polys)
    names["strokes"].write_text(head + frame + strokes + "</svg>", encoding="utf-8")
    # everything the animation needs, in the SVG's units (y down): the oval, and each gold line as a
    # centre line with its half width at every point (the intro draws the lines as growing ribbons)
    # the twin pinnacles: the highest gold on each side of the axis (the tops of the PETRONAS Towers)
    pinnacles = []
    gy, gx = np.nonzero(lines_mask)
    for side in (gx < cx * S, gx >= cx * S):
        top = gy[side].min()
        pinnacles.append([float(gx[side][gy[side] <= top + 2].mean()), float(top)])
    names["meta"].write_text(json.dumps({
        "line_width": width, "width": W, "height": H,
        "ellipse": [cx * S, cy * S, rx * S, ry * S],
        "pinnacles": pinnacles,
        "flow": _flow(lines_mask, cx, cy, rx, ry, width),
        "lines": [{"pts": [[round(x, 1), round(y, 1)] for x, y, _ in p], "hw": [round(w_, 1) for _, _, w_ in p]}
                  for p in polys],
    }), encoding="utf-8")
    return {k: str(p) for k, p in names.items()}


def logos() -> dict[str, str]:
    try:
        return trace_logo()
    except Exception as exc:                                   # no potrace/fontTools: no logo rather than fail
        print(f"  ! UTP logo could not be built: {exc}")
        return {}


def split_layers(mob) -> dict:
    """The logo's parts, by colour: {"oval": [...], "lines": [...], "word": [...], "rules": [...]}."""
    from manim import VGroup
    parts = {"oval": VGroup(), "lines": VGroup(), "word": VGroup(), "rules": VGroup()}
    for sub in mob.family_members_with_points():
        if sub.get_fill_opacity() < 0.01:
            continue                                           # the transparent frame
        hexc = sub.get_fill_color().to_hex().upper()
        if hexc == UTP_BLUE.upper():
            parts["oval"].add(sub)
        elif hexc == WORD_COLOR.upper():
            parts["word"].add(sub)
        elif hexc == UTP_GOLD.upper():
            (parts["rules"] if len(sub.points) <= 20 else parts["lines"]).add(sub)
    return parts


def intro(logo, parts: dict | None = None, strokes=None) -> list[tuple[list, float]]:
    """The logo drawing itself: [(animations, seconds), ...], played one after another.

    The oval's outline is drawn from the top and the blue fills in; the gold lines are drawn like
    a pen, rising from the stem, and become the exact shapes; a glint runs round the oval; the
    wordmark rises letter by letter while the rules grow from the centre."""
    from manim import UP, Create, FadeIn, FadeOut, GrowFromCenter, ShowPassingFlash, smooth
    parts = parts or split_layers(logo)
    steps = []
    first = []
    oval = parts["oval"]
    outline = None
    if len(oval):
        outline = oval.copy().set_fill(opacity=0).set_stroke(color="#7FB2EA", width=3.5, opacity=1)
        first += [within(FadeIn(oval, scale=0.985), 0.32, 0.72), within(Create(outline, rate_func=smooth), 0.0, 0.6)]
    if strokes is not None and len(strokes):
        # one rising wave: each line is drawn while the wave passes from its foot to its highest point,
        # so both halves of the emblem grow together, whatever pieces the lines were traced in
        lo = min(s.points[0][1] for s in strokes)
        hi = max(s.points[:, 1].max() for s in strokes)
        span = max(hi - lo, 1e-6)
        for s in strokes:
            a = (s.points[0][1] - lo) / span
            b = max(a + 0.12, (s.points[:, 1].max() - lo) / span)
            first.append(within(Create(s), 0.36 + 0.6 * a, min(1.0, 0.36 + 0.6 * b)))
    elif len(parts["lines"]):
        from manim import DrawBorderThenFill
        first.append(within(DrawBorderThenFill(parts["lines"], stroke_width=1.2, stroke_color=UTP_GOLD), 0.4, 1.0))
    if first:
        steps.append((first, 2.0))
    second = []
    if strokes is not None and len(strokes) and len(parts["lines"]):
        second += [FadeIn(parts["lines"]), FadeOut(strokes)]
    if outline is not None:
        glint = oval.copy().set_fill(opacity=0).set_stroke(color="#FFE7A8", width=5, opacity=1)
        second += [FadeOut(outline), ShowPassingFlash(glint, time_width=0.35)]
    if second:
        steps.append((second, 0.7))
    third = []
    letters = list(parts["word"])
    for i, letter in enumerate(letters):
        a = 0.5 * i / max(1, len(letters) - 1)
        third.append(within(FadeIn(letter, shift=UP * 0.06 * logo.height / 4.6), a, a + 0.5))
    for r in parts["rules"]:
        third.append(within(GrowFromCenter(r), 0.15, 0.75))
    if third:
        steps.append((third, 1.3))
    if not steps:
        steps = [([FadeIn(logo)], 0.8)]
    return steps
