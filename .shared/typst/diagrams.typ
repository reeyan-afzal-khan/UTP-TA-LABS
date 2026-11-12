// The drawing vocabulary of style/diagrams.tex and diagrams/*.tex, on CeTZ.
// A diagram is ordinary CeTZ code in the chapter or lab that shows it:
//
//   #canvas({
//     node((0, 0), [12], name: "a", ..utpcell)
//     node((1.55, 0), [25], name: "b", ..utpcell)
//     connect("a", "b", ..utparrow)
//   })
//
// Coordinates are centimetres, as in TikZ. The option names are TikZ's keys
// in Typst form: draw, fill, line-width, dash, rounded, inner-sep,
// min-width, min-height, min-size, text-width, align, font, text, anchor.
#import "/.shared/packages/cetz/0.5.3/src/lib.typ" as cetz
#import "palette.typ": *
#import "theme.typ": *
#import "state.typ": *

#let draw = cetz.draw
#let decorations = cetz.decorations

// A TikZ picture: centimetre units, round caps and joins (theme.tex set
// line cap=round and line join=round for every picture). Lines and frames
// without a colour take the text colour, as TikZ does: ink on the page,
// black inside a box. `cell` is \utpdiagramsize (the course's unless given);
// `compact` is the smaller grid of utpcompactlabfigure.
// x, y and scale are TikZ's picture options of the same names: they move
// coordinates, never the size of a node. transform-shape scales the nodes too.
#let canvas(body, cell: auto, compact: false, x: 1cm, y: 1cm, scale: 1, transform-shape: false) = context {
  let size = if cell != auto { cell } else if compact { (0.90, 0.62) } else { cfg("diagram-size") }
  let color = text.fill
  let k = if transform-shape { 1 } else { scale }
  let drawing = cetz.canvas(length: 1cm, x: k * x, y: k * y, {
    cetz.draw.set-ctx(ctx => {
      ctx.insert("utp", (cell: size, compact: compact, color: color))
      ctx
    })
    cetz.draw.set-style(stroke: (cap: "round", join: "round", thickness: 0.4pt, paint: color))
    body
  })
  if transform-shape and scale != 1 { std.scale(scale * 100%, reflow: true, drawing) } else { drawing }
}
#let _utp(ctx) = ctx.at("utp", default: (cell: (1.0, 0.8), compact: false, color: ink))

// ------------------------------------------------------------ basic values
// TikZ line widths and dash patterns.
#let widths = (ultra-thin: 0.1pt, very-thin: 0.2pt, thin: 0.4pt, semithick: 0.6pt,
  thick: 0.8pt, very-thick: 1.2pt, ultra-thick: 1.6pt)
#let dash-pattern(dash, width) = {
  if dash == none or dash == "solid" { return none }
  if type(dash) == array { return dash }
  (
    "dashed": (3pt, 3pt), "densely dashed": (3pt, 2pt), "loosely dashed": (3pt, 6pt),
    "dotted": (width, 2pt), "densely dotted": (width, 1pt), "loosely dotted": (width, 4pt),
  ).at(dash)
}

// A node font: \scriptsize\bfseries\color{UTPNavy} is font("script", weight: "bold", fill: navy).
#let font(size, weight: "regular", fill: auto, style: "normal", family: none) = {
  let f = (size: if type(size) == str { sizes.at(size) } else { size }, weight: weight, style: style)
  if fill != auto { f.insert("fill", fill) }
  if family != none { f.insert("font", family) }
  f
}

// The baselineskip LaTeX uses with a font size (for multi-line node text).
#let skip-of(size) = {
  let best = "normal"
  for (k, v) in sizes { if calc.abs((v - size).pt()) < calc.abs((sizes.at(best) - size).pt()) { best = k } }
  skips.at(best)
}

// An arrow tip as a CeTZ mark. TikZ's Stealth: width 3/4 and inset 0.325 of the length.
// The colour is the line's unless given (resolved when the line is drawn).
#let tip(kind, length: auto, width: auto, line: 0.4pt, color: auto, fill: auto, open: false) = {
  if kind == none { return none }
  let L = if length != auto { length } else if kind == "Stealth" { 3pt + 4.5 * line } else if kind == "Latex" { 3pt + 4.5 * line } else { 2.2pt + 1.6 * line }
  let W = if width != auto { width } else if kind == "Stealth" { 0.75 * L } else if kind == "Latex" { 0.75 * L } else { 1.6 * L }
  let name = (Stealth: "stealth", Latex: "triangle", to: "barbed", Bar: "bar", Circle: "circle",
    Square: "rect", Triangle: "triangle", Kite: "diamond").at(kind, default: "stealth")
  (symbol: name, length: L, width: W, inset: if kind == "Stealth" { 0.325 * L } else { 0pt },
    fill: if open { none } else { fill }, open: open, color: color,
    stroke: (paint: color, thickness: calc.min(line.pt(), 0.6) * 1pt, dash: none))
}
#let _tip-for(t, draw) = {
  if t == none { return none }
  let t = t
  let c = if t.at("color", default: auto) == auto { draw } else { t.color }
  if t.at("fill", default: auto) == auto and not t.at("open", default: false) { t.fill = c }
  t.stroke.paint = c
  let _ = t.remove("color", default: none)
  let _ = t.remove("open", default: none)
  t
}

// ------------------------------------------------------------------ nodes
#let _num(ctx, x) = if type(x) == length { cetz.util.resolve-number(ctx, x) } else if x == none { 0 } else { x }

// The picture's unit vectors (x, y and scale of the canvas, and scopes):
// how long one coordinate step is in centimetres along each axis.
#let _scale(ctx) = {
  let t = ctx.transform
  (calc.sqrt(calc.pow(t.at(0).at(0), 2) + calc.pow(t.at(1).at(0), 2)),
   calc.sqrt(calc.pow(t.at(0).at(1), 2) + calc.pow(t.at(1).at(1), 2)))
}
// An absolute distance (centimetres on the page) as picture coordinates.
#let _abs-shift(ctx, dx, dy) = {
  let (sx, sy) = _scale(ctx)
  (_num(ctx, dx) / sx, _num(ctx, dy) / sy)
}
// A point on the page back in picture coordinates.
#let _local(ctx, q) = cetz.util.apply-transform(cetz.matrix.inverse(ctx.transform), q)

// Offset of a named anchor from the centre of a node of half-size (w, h).
#let _offset(anchor, w, h, shape) = {
  let d = (
    "center": (0, 0), "north": (0, 1), "south": (0, -1), "east": (1, 0), "west": (-1, 0),
    "north-east": (1, 1), "north-west": (-1, 1), "south-east": (1, -1), "south-west": (-1, -1),
  ).at(anchor, default: none)
  if d == none {
    // a numeric angle: a point on the border in that direction
    let a = float(anchor) * 1deg
    return if shape in ("circle", "ellipse") { (w * calc.cos(a), h * calc.sin(a)) }
      else {
        let (c, s) = (calc.cos(a), calc.sin(a))
        let t = calc.min(if c != 0 { w / calc.abs(c) } else { 1e9 }, if s != 0 { h / calc.abs(s) } else { 1e9 })
        (t * c, t * s)
      }
  }
  let (dx, dy) = d
  if shape in ("circle", "ellipse") and dx != 0 and dy != 0 { (dx * w * 0.7071, dy * h * 0.7071) }
  else if shape == "diamond" and dx != 0 and dy != 0 { (dx * w / 2, dy * h / 2) }
  else { (dx * w, dy * h) }
}

// A TikZ node: its text, a shape sized to the text or to the minimum size,
// placed so that `anchor` sits at `pos`. Named nodes are CeTZ groups with the
// compass anchors on the outer border; "name.shape.30deg" is a border point.
#let node(pos, body, name: none, anchor: auto, shape: "rectangle", draw: none, fill: none,
  line-width: 0.4pt, dash: none, rounded: 0pt, opacity: 100%, fill-opacity: auto,
  inner-sep: auto, inner-xsep: auto, inner-ysep: auto, outer-sep: auto,
  min-width: 0, min-height: 0, min-size: 0, text-width: none, align: auto,
  font: (:), text: auto, color: auto, rotate: 0deg, xshift: 0pt, yshift: 0pt, aspect: 1,
  star-points: 5, star-point-ratio: 1.5, cell: false, ..rest) = cetz.draw.get-ctx(ctx => {
  // the options this drawer adjusts (a closure cannot assign to them)
  let (font, min-size, text, draw) = (font, min-size, text, draw)
  // positions may come from right-of(), below-of() ... as (pos:, anchor:)
  let (pos, anchor) = if type(pos) == dictionary and "pos" in pos {
    (pos.pos, if anchor == auto { pos.anchor } else { anchor })
  } else { (pos, if anchor == auto { "center" } else { anchor }) }
  if type(pos) == function { pos = pos(ctx) }
  // TikZ color= sets the text colour and the colour of a bare draw
  if color != auto {
    if text == auto { text = color }
    if draw == auto { draw = color }
  }
  // \ttfamily in a node font: the book's mono face, scaled as in LaTeX
  if font.at("font", default: none) == "mono" {
    let mono = cfg("mono")
    font.insert("font", mono)
    font.insert("size", font.at("size", default: sizes.normal) * mono-scale.at(mono, default: 0.88))
  }
  let size = font.at("size", default: sizes.normal)
  // \utpdiagramsize: cell styles take the current cell size
  let (cw, ch) = if cell { _utp(ctx).cell } else { (none, none) }
  if _utp(ctx).compact and shape == "circle" and min-size == 8mm { min-size = 7mm }
  if draw == auto { draw = _utp(ctx).color }
  let mw = if cell and min-width == 0 { cw } else { min-width }
  let mh = if cell and min-height == 0 { ch } else { min-height }
  let style = font
  if text != auto { style.insert("fill", text) }
  // The text, set as in the book: its line metrics (CeTZ resets the text edges,
  // so they are set again here) and the baselineskip of the node's font.
  let gap = skip-of(size) - line-box * size
  let make(edges) = {
    set std.text(..style)
    set std.text(top-edge: edges.at(0), bottom-edge: edges.at(1))
    set par(justify: false, leading: gap, spacing: gap)
    if text-width != none {
      let w = if type(text-width) == length { text-width } else { text-width * 1cm }
      std.block(width: w, std.align(if align == auto { left } else { align }, body))
    } else if align != auto {
      std.align(align, body)
    } else { body }
  }
  let label = make((top-edge, bottom-edge))
  let (bw, bh) = cetz.util.measure(ctx, label)
  // TeX sizes a node by its glyphs: the height of the first line and the depth
  // of the last. A single line is measured; longer text keeps the full line box.
  let em = _num(ctx, size)
  let (asc, desc) = if bh == 0 { (0, 0) } else if bh < (line-box + 0.5) * em {
    (cetz.util.measure(ctx, make(("bounds", "baseline"))).at(1),
     cetz.util.measure(ctx, make(("baseline", "bounds"))).at(1))
  } else { (0.712 * em, 0.2 * em) }
  if bh > 0 { bh = bh - line-box * em + asc + desc }
  let sep = if inner-sep == auto { 0.3333 * size } else { inner-sep }
  let sx = _num(ctx, if inner-xsep == auto { sep } else { inner-xsep })
  let sy = _num(ctx, if inner-ysep == auto { sep } else { inner-ysep })
  let lw = _num(ctx, line-width)
  let outer = if outer-sep == auto { if draw == none { 0 } else { lw / 2 } } else { _num(ctx, outer-sep) }
  let (w, h) = (bw + 2 * sx, bh + 2 * sy)
  if shape == "circle" {
    let d = calc.max(calc.sqrt(w * w + h * h), _num(ctx, min-size), _num(ctx, mw), _num(ctx, mh))
    (w, h) = (d, d)
  } else if shape == "ellipse" {
    (w, h) = (calc.max(w * 1.4142, _num(ctx, mw), _num(ctx, min-size)), calc.max(h * 1.4142, _num(ctx, mh), _num(ctx, min-size)))
  } else if shape == "diamond" {
    let H = w / aspect + h
    (w, h) = (calc.max(aspect * H, _num(ctx, mw), _num(ctx, min-size)), calc.max(H, _num(ctx, mh), _num(ctx, min-size)))
  } else {
    (w, h) = (calc.max(w, _num(ctx, mw), _num(ctx, min-size)), calc.max(h, _num(ctx, mh), _num(ctx, min-size)))
  }
  // a star: the text box sits inside the inner points, the points reach `ratio` further out
  let (star-in, star-out) = if shape == "star" {
    let r = calc.sqrt(w * w + h * h) / 2
    let R = calc.max(r * star-point-ratio, _num(ctx, min-size) / 2)
    (R / star-point-ratio, R)
  } else { (0, 0) }
  if shape == "star" { (w, h) = (2 * star-out, 2 * star-out) }
  let (hw, hh) = (w / 2 + outer, h / 2 + outer)
  let (_, p) = cetz.coordinate.resolve(ctx, pos)
  // The node is drawn in an unscaled frame on its centre: TikZ scales and
  // rotates the positions of nodes with the picture, never their shapes.
  let at = cetz.util.apply-transform(ctx.transform, p)
  // TikZ's text anchors: text (start of the first baseline), base (the last
  // baseline), mid (half an ex above it)
  let base = -bh / 2 + desc
  let text-anchors = (text: (-bw / 2, bh / 2 - asc), base: (0, base), base-west: (-hw, base),
    base-east: (hw, base), mid: (0, base + 0.243 * em), mid-west: (-hw, base + 0.243 * em),
    mid-east: (hw, base + 0.243 * em))
  let (ox, oy) = if anchor in text-anchors { text-anchors.at(anchor) } else { _offset(anchor, hw, hh, shape) }
  if rotate != 0deg {
    (ox, oy) = (ox * calc.cos(rotate) - oy * calc.sin(rotate), ox * calc.sin(rotate) + oy * calc.cos(rotate))
  }
  let (cx, cy) = (at.at(0) - ox + _num(ctx, xshift), at.at(1) - oy + _num(ctx, yshift))
  let stroke = if draw == none { none } else {
    (paint: draw.transparentize(100% - opacity), thickness: line-width, dash: dash-pattern(dash, line-width))
  }
  let paint = if fill == none { none } else {
    fill.transparentize(100% - (if fill-opacity == auto { opacity } else { fill-opacity }))
  }
  let (x0, y0, x1, y1) = (-w / 2, -h / 2, w / 2, h / 2)
  let shape-element = if shape == "circle" {
    cetz.draw.circle((0, 0), radius: w / 2, stroke: stroke, fill: paint, name: "shape")
  } else if shape == "ellipse" {
    cetz.draw.circle((0, 0), radius: (w / 2, h / 2), stroke: stroke, fill: paint, name: "shape")
  } else if shape == "diamond" {
    cetz.draw.line((x0, 0), (0, y1), (x1, 0), (0, y0), close: true, stroke: stroke, fill: paint, name: "shape")
  } else if shape == "star" {
    let n = star-points
    cetz.draw.line(..range(2 * n).map(k => {
      let a = 90deg + k * 180deg / n
      let r = if calc.even(k) { star-out } else { star-in }
      (r * calc.cos(a), r * calc.sin(a))
    }), close: true, stroke: stroke, fill: paint, name: "shape")
  } else if shape == "cross-out" {
    cetz.draw.line((x0, y0), (x1, y1), stroke: stroke)
    cetz.draw.line((x0, y1), (x1, y0), stroke: stroke)
    cetz.draw.rect((x0, y0), (x1, y1), stroke: none, name: "shape")
  } else if shape == "rounded-rectangle" {
    cetz.draw.rect((x0, y0), (x1, y1), radius: h / 2, stroke: stroke, fill: paint, name: "shape")
  } else if shape == "cylinder" {
    let ry = calc.min(h * 0.15, w * 0.3)
    cetz.draw.merge-path(stroke: stroke, fill: paint, close: true, {
      cetz.draw.line((x0, y1 - ry), (x0, y0 + ry))
      cetz.draw.arc((x0, y0 + ry), start: 180deg, stop: 360deg, radius: (w / 2, ry))
      cetz.draw.line((x1, y0 + ry), (x1, y1 - ry))
      cetz.draw.arc((x1, y1 - ry), start: 0deg, stop: 180deg, radius: (w / 2, ry))
    })
    cetz.draw.arc((x0, y1 - ry), start: 180deg, stop: 360deg, radius: (w / 2, ry), stroke: stroke)
    cetz.draw.rect((x0, y0), (x1, y1), stroke: none, name: "shape")
  } else if shape == "cloud" {
    let n = 11
    let pts = range(n + 1).map(k => {
      let a = k * 360deg / n
      (w / 2 * calc.cos(a), h / 2 * calc.sin(a))
    })
    cetz.draw.merge-path(stroke: stroke, fill: paint, close: true, {
      for k in range(n) {
        cetz.draw.arc-through(pts.at(k), {
          let a = (k + 0.5) * 360deg / n
          (w / 2 * 1.18 * calc.cos(a), h / 2 * 1.18 * calc.sin(a))
        }, pts.at(k + 1))
      }
    })
    cetz.draw.circle((0, 0), radius: (w / 2, h / 2), stroke: none, name: "shape")
  } else {
    cetz.draw.rect((x0, y0), (x1, y1), radius: _num(ctx, rounded), stroke: stroke, fill: paint, name: "shape")
  }
  let anchors = ("north", "south", "east", "west", "north-east", "north-west", "south-east", "south-west")
  cetz.draw.group(name: name, {
    cetz.draw.set-transform(((1, 0, 0, cx), (0, 1, 0, cy), (0, 0, 1, at.at(2)), (0, 0, 0, 1)))
    if rotate != 0deg { cetz.draw.rotate(rotate) }
    shape-element
    // the text takes exactly its TeX box, so the picture's bounds end at the
    // node shapes as in TikZ; the line box above and below the glyphs overhangs
    cetz.draw.content((0, 0), box(width: bw * ctx.length, height: bh * ctx.length,
      place(top + std.left, dy: (asc - 0.712 * em) * ctx.length, label)), anchor: "center", angle: rotate)
    cetz.draw.anchor("center", (0, 0))
    for a in anchors {
      let (dx, dy) = _offset(a, hw, hh, if shape == "star" { "circle" } else { shape })
      cetz.draw.anchor(a, (dx, dy))
    }
    for (a, p) in text-anchors { cetz.draw.anchor(a, p) }
    if shape == "diamond" { cetz.draw.anchor("diamond", (0, 0)) }
    if shape == "star" { cetz.draw.anchor("round-border", (0, 0)) }
  })
})

// A named point (\coordinate).
#let coordinate(name, pos) = cetz.draw.group(name: name, {
  for a in ("center", "default", "north", "south", "east", "west", "north-east", "north-west",
    "south-east", "south-west") { cetz.draw.anchor(a, pos) }
})

// ---------------------------------------------------- node-relative places
// right=d of a, below=d of a, ...: the new node's facing side d away
// (d in centimetres on the page, whatever the picture's units; or measured,
// as distance-y(a, b) is).
#let _beside(target, side, dx, dy, anchor, sx: 1, sy: 1) = (
  pos: ctx => {
    let v(d) = if type(d) == function { d(ctx) } else { d }
    // of a node: from its facing side; of a point (an anchor, a calc point): from the point
    let at = if type(target) == str and not target.contains(".") { target + "." + side } else { target }
    (rel: _abs-shift(ctx, sx * v(dx), sy * v(dy)), to: at)
  }, anchor: anchor)

// How far b lies from a along x or y on the page, in centimetres
// (TikZ's let \p1 = ($(b)-(a)$) in ... \x1, \y1).
#let distance-x(a, b) = ctx => {
  let (_, p, q) = cetz.coordinate.resolve(ctx, a, b)
  let (p, q) = (cetz.util.apply-transform(ctx.transform, p), cetz.util.apply-transform(ctx.transform, q))
  q.at(0) - p.at(0)
}
#let distance-y(a, b) = ctx => {
  let (_, p, q) = cetz.coordinate.resolve(ctx, a, b)
  let (p, q) = (cetz.util.apply-transform(ctx.transform, p), cetz.util.apply-transform(ctx.transform, q))
  q.at(1) - p.at(1)
}
#let right-of(target, d) = _beside(target, "east", d, 0, "west")
#let left-of(target, d) = _beside(target, "west", d, 0, "east", sx: -1)
#let above-of(target, d) = _beside(target, "north", 0, d, "south")
#let below-of(target, d) = _beside(target, "south", 0, d, "north", sy: -1)
#let above-right-of(target, dy, dx) = _beside(target, "north-east", dx, dy, "south-west")
#let above-left-of(target, dy, dx) = _beside(target, "north-west", dx, dy, "south-east", sx: -1)
#let below-right-of(target, dy, dx) = _beside(target, "south-east", dx, dy, "north-west", sy: -1)
#let below-left-of(target, dy, dx) = _beside(target, "south-west", dx, dy, "north-east", sx: -1, sy: -1)

// ------------------------------------------------------------------ paths
// The shape of a named node, for clipping a line at its border.
// (a \coordinate is a bare point: lines run to it, not to a border)
#let _named(ctx, p) = type(p) == str and not p.contains(".") and p in ctx.nodes
#let _is-node(ctx, p) = _named(ctx, p) and "shape" in (ctx.nodes.at(p).anchors)(())
#let _center(ctx, p) = {
  let (_, v) = cetz.coordinate.resolve(ctx, if _named(ctx, p) { p + ".center" } else { p })
  v
}
// The point of a node's border in direction a (an angle on the page). CeTZ
// finds it on rectangles and ellipses; a diamond is a polygon through its
// compass points, a star the circle through its points.
#let _border-at(ctx, name, a) = {
  let names = (ctx.nodes.at(name).anchors)(())
  if "diamond" in names or "round-border" in names {
    let T(p) = cetz.util.apply-transform(ctx.transform, p)
    let get(n) = { let (_, v) = cetz.coordinate.resolve(ctx, name + "." + n); T(v) }
    let c = get("center")
    let d = (calc.cos(a), calc.sin(a))
    let hit = if "round-border" in names {
      let n = get("north")
      let r = calc.sqrt(calc.pow(n.at(0) - c.at(0), 2) + calc.pow(n.at(1) - c.at(1), 2))
      (c.at(0) + r * d.at(0), c.at(1) + r * d.at(1), 0)
    } else {
      let vs = ("north", "east", "south", "west").map(get)
      let best = none
      for k in range(4) {
        let (p, q) = (vs.at(k), vs.at(calc.rem(k + 1, 4)))
        let e = (q.at(0) - p.at(0), q.at(1) - p.at(1))
        let den = d.at(0) * e.at(1) - d.at(1) * e.at(0)
        if calc.abs(den) > 1e-12 {
          let w = (p.at(0) - c.at(0), p.at(1) - c.at(1))
          let t = (w.at(0) * e.at(1) - w.at(1) * e.at(0)) / den
          let u = (w.at(0) * d.at(1) - w.at(1) * d.at(0)) / den
          if t > 0 and u >= -1e-9 and u <= 1 + 1e-9 and (best == none or t < best) { best = t }
        }
      }
      let t = if best == none { 0 } else { best }
      (c.at(0) + t * d.at(0), c.at(1) + t * d.at(1), 0)
    }
    return _local(ctx, hit)
  }
  let (_, v) = cetz.coordinate.resolve(ctx, name + ".shape." + str(calc.rem-euclid(a.deg(), 360)) + "deg")
  v
}
#let _border(ctx, name, toward) = {
  // the direction on the page: node shapes are drawn unscaled
  let c = cetz.util.apply-transform(ctx.transform, _center(ctx, name))
  let t = cetz.util.apply-transform(ctx.transform, toward)
  _border-at(ctx, name, calc.atan2(t.at(0) - c.at(0), t.at(1) - c.at(1)))
}

#let _stroke(draw, line-width, dash, opacity) = if draw == none { none } else {
  (paint: draw.transparentize(100% - opacity), thickness: line-width, dash: dash-pattern(dash, line-width),
    cap: "round", join: "round")
}

// A TikZ path between points or nodes: connect("a", "b"), connect("a", "-|", "b"),
// connect((0, 0), (1, 0), (1, 1)). Lines that start or end at a node stop at its
// border. bend: or out-angle:/in-angle: makes a TikZ `to` curve.
#let connect(..args, draw: auto, line-width: 0.4pt, dash: none, start: none, end: none,
  fill: none, opacity: 100%, rounded: 0pt, bend: none, out-angle: none, in-angle: none, looseness: 1,
  min-distance: 0, shorten-start: 0pt, shorten-end: 0pt, close: false, name: none) = cetz.draw.get-ctx(ctx => {
  let raw = args.pos()
  let draw = if draw == auto { _utp(ctx).color } else { draw }
  // resolve corners of -| and |-
  let pts = ()
  let kinds = ()
  let i = 0
  while i < raw.len() {
    let p = raw.at(i)
    if p == "-|" or p == "|-" {
      let a = _center(ctx, raw.at(i - 1))
      let b = _center(ctx, raw.at(i + 1))
      pts.push(if p == "-|" { (b.at(0), a.at(1), 0) } else { (a.at(0), b.at(1), 0) })
      kinds.push("corner")
    } else {
      pts.push(p)
      kinds.push(if _is-node(ctx, p) { "node" } else { "point" })
    }
    i += 1
  }
  let centers = pts.map(p => if type(p) == array and p.len() == 3 and type(p.at(2)) != str { p } else { _center(ctx, p) })
  let stroke = _stroke(draw, line-width, dash, opacity)
  let mark = (start: _tip-for(start, draw), end: _tip-for(end, draw))
  let paint = if fill == none { none } else { fill.transparentize(100% - opacity) }
  if bend != none or out-angle != none or in-angle != none {
    let a = centers.first()
    let b = centers.last()
    let ang = calc.atan2(b.at(0) - a.at(0), b.at(1) - a.at(1))
    let o = if out-angle != none { out-angle } else { ang + bend }
    let n = if in-angle != none { in-angle } else { ang + 180deg - bend }
    // TikZ: control points 0.3915 x looseness of the distance away, and at least min distance
    let d = calc.max(calc.sqrt(calc.pow(b.at(0) - a.at(0), 2) + calc.pow(b.at(1) - a.at(1), 2)) * 0.3915 * looseness,
      _num(ctx, min-distance))
    let pa = if kinds.first() == "node" { _border-at(ctx, pts.first(), o) } else { a }
    let pb = if kinds.last() == "node" { _border-at(ctx, pts.last(), n) } else { b }
    let c1 = (pa.at(0) + d * calc.cos(o), pa.at(1) + d * calc.sin(o))
    let c2 = (pb.at(0) + d * calc.cos(n), pb.at(1) + d * calc.sin(n))
    cetz.draw.bezier(pa, pb, c1, c2, stroke: stroke, mark: mark, fill: paint, name: name)
    // TikZ's picture size counts a curve's control points
    cetz.draw.line(pa, c1, c2, pb, stroke: none)
    return
  }
  let out-pts = centers
  if kinds.first() == "node" and centers.len() > 1 { out-pts.at(0) = _border(ctx, pts.first(), centers.at(1)) }
  if kinds.last() == "node" and centers.len() > 1 { out-pts.at(-1) = _border(ctx, pts.last(), centers.at(-2)) }
  // shorten >=, shorten <=
  let shorten(p, q, d) = {
    let len = calc.sqrt(calc.pow(q.at(0) - p.at(0), 2) + calc.pow(q.at(1) - p.at(1), 2))
    if len == 0 { p } else { (p.at(0) + (q.at(0) - p.at(0)) * d / len, p.at(1) + (q.at(1) - p.at(1)) * d / len, 0) }
  }
  if shorten-start != 0pt { out-pts.at(0) = shorten(out-pts.at(0), out-pts.at(1), _num(ctx, shorten-start)) }
  if shorten-end != 0pt { out-pts.at(-1) = shorten(out-pts.at(-1), out-pts.at(-2), _num(ctx, shorten-end)) }
  cetz.draw.line(..out-pts, stroke: stroke, mark: mark, fill: paint, close: close, name: name)
})

// A point a fraction of the way along a straight connection, measured
// between the borders as TikZ does (midway is 50%).
#let along(from, to, t: 50%) = ctx => {
  let a = if _is-node(ctx, from) { _border(ctx, from, _center(ctx, to)) } else { _center(ctx, from) }
  let b = if _is-node(ctx, to) { _border(ctx, to, _center(ctx, from)) } else { _center(ctx, to) }
  let f = t / 100%
  (a.at(0) + (b.at(0) - a.at(0)) * f, a.at(1) + (b.at(1) - a.at(1)) * f)
}

// The box around several nodes (fit=(a)(b)), measured on the page.
#let fit(names, name: none, inner-sep: 3.64pt, ..style) = cetz.draw.get-ctx(ctx => {
  let xs = ()
  let ys = ()
  for n in names {
    for a in ("north-east", "south-west") {
      let (_, v) = cetz.coordinate.resolve(ctx, n + "." + a)
      let q = cetz.util.apply-transform(ctx.transform, v)
      xs.push(q.at(0))
      ys.push(q.at(1))
    }
  }
  let s = _num(ctx, inner-sep)
  let (x0, x1, y0, y1) = (calc.min(..xs) - s, calc.max(..xs) + s, calc.min(..ys) - s, calc.max(..ys) + s)
  node(_local(ctx, ((x0 + x1) / 2, (y0 + y1) / 2, 0)), [], name: name, min-width: x1 - x0,
    min-height: y1 - y0, inner-sep: 0pt, ..style)
})

// A curly brace from a to b, raised above the line (decoration brace).
#let brace(a, b, amplitude: 4pt, raise: 2pt, draw: muted, line-width: 0.6pt, mirror: false) = cetz.draw.get-ctx(ctx => {
  let p = _center(ctx, a)
  let q = _center(ctx, b)
  let ang = calc.atan2(q.at(0) - p.at(0), q.at(1) - p.at(1))
  let r = _num(ctx, raise) * if mirror { -1 } else { 1 }
  let off = (-calc.sin(ang) * r, calc.cos(ang) * r)
  cetz.decorations.brace((p.at(0) + off.at(0), p.at(1) + off.at(1)), (q.at(0) + off.at(0), q.at(1) + off.at(1)),
    amplitude: _num(ctx, amplitude), flip: mirror, pointiness: 100%, outer-pointiness: 100%,
    stroke: (paint: draw, thickness: line-width), fill: none)
})

// ------------------------------------------------------ the shared styles
// style/diagrams.tex: cells take the current \utpdiagramsize (see canvas).

#let utpcell = (draw: blue, fill: pale-blue, cell: true, font: font("small", weight: "bold", fill: navy), inner-sep: 1pt)
#let utphot = (draw: orange, fill: pale-orange, line-width: 1pt, cell: true, font: font("small", weight: "bold", fill: navy), inner-sep: 1pt)
#let utpdone = (draw: green, fill: pale-teal, cell: true, font: font("small", weight: "bold", fill: navy), inner-sep: 1pt)
#let utpdim = (draw: mix(muted, 45%), fill: pale-gray, cell: true, font: font("small", fill: muted), inner-sep: 1pt)
#let utpwall = (draw: navy, fill: mix(navy, 82%), cell: true, inner-sep: 1pt)
#let utpnode = (shape: "circle", draw: blue, fill: pale-blue, min-size: 8mm, font: font("small", weight: "bold", fill: navy), inner-sep: 0.5pt)
#let utpnodehot = (shape: "circle", draw: orange, fill: pale-orange, line-width: 1pt, min-size: 8mm, font: font("small", weight: "bold", fill: navy), inner-sep: 0.5pt)
#let utpnodedone = (shape: "circle", draw: green, fill: pale-teal, min-size: 8mm, font: font("small", weight: "bold", fill: navy), inner-sep: 0.5pt)
#let utpnodedim = (shape: "circle", draw: mix(muted, 45%), fill: pale-gray, min-size: 8mm, font: font("small", fill: muted), inner-sep: 0.5pt)
#let utparrow = (draw: teal, line-width: widths.thick, end: tip("Stealth", length: 2.2mm, line: widths.thick, color: teal))
#let utpptr = (draw: blue, line-width: widths.semithick, end: tip("Stealth", length: 2mm, line: widths.semithick, color: blue))
#let utpdash = (draw: red, line-width: widths.semithick, dash: "dashed", end: tip("Stealth", length: 2mm, line: widths.semithick, color: red))
#let utpedge = (draw: teal, line-width: widths.thick)
#let utplabel = (font: font("script", fill: muted), inner-sep: 1pt)
#let utptag = (font: font("script", weight: "bold", fill: orange), inner-sep: 1pt)
#let utpbrace = (draw: muted, line-width: widths.semithick, amplitude: 4pt, raise: 2pt)
#let utpstep = (draw: navy, fill: white, rounded: 1.5mm, min-height: 0.75, font: font("script", fill: navy), align: center, inner-sep: 2pt)
#let utpstage = utpstep
#let utppanel = (draw: mix(blue, 30%), fill: white, rounded: 1.5mm, inner-sep: 2.5mm)
#let utpbox = (draw: blue, fill: pale-blue, rounded: 2mm, align: center, font: font("small", fill: navy), inner-sep: 2.2mm)

// ---------------------------------------------------- other path shapes
#let _paint(fill, opacity) = if fill == none { none } else { fill.transparentize(100% - opacity) }

// (a) rectangle (b)
#let rectangle(a, b, draw: auto, fill: none, line-width: 0.4pt, dash: none, rounded: 0pt,
  opacity: 100%, fill-opacity: auto, ..rest) = cetz.draw.get-ctx(ctx => {
  let draw = if draw == auto { _utp(ctx).color } else { draw }
  let fill = if fill == auto { _utp(ctx).color } else { fill }
  cetz.draw.rect(a, b, radius: _num(ctx, rounded), stroke: _stroke(draw, line-width, dash, opacity),
    fill: _paint(fill, if fill-opacity == auto { opacity } else { fill-opacity }))
})

// A radius in picture units: a number follows the picture's units, a length
// (circle (2pt)) is that size on the page. (rx, ry) is an ellipse.
#let _radius(ctx, r) = {
  let (rx, ry) = if type(r) == array { r } else { (r, r) }
  let (sx, sy) = _scale(ctx)
  (if type(rx) == length { _num(ctx, rx) / sx } else { rx }, if type(ry) == length { _num(ctx, ry) / sy } else { ry })
}

// (c) circle (r), and (c) ellipse (a and b)
#let circle-at(c, r, draw: auto, fill: none, line-width: 0.4pt, dash: none, opacity: 100%,
  fill-opacity: auto, ..rest) = cetz.draw.get-ctx(ctx => {
  let draw = if draw == auto { _utp(ctx).color } else { draw }
  let fill = if fill == auto { _utp(ctx).color } else { fill }
  cetz.draw.circle(c, radius: _radius(ctx, r), stroke: _stroke(draw, line-width, dash, opacity),
    fill: _paint(fill, if fill-opacity == auto { opacity } else { fill-opacity }))
})

// (p) arc (start:end:radius): an arc that begins at p.
#let arc-at(p, start, stop, radius, draw: auto, line-width: 0.4pt, dash: none, opacity: 100%,
  fill: none, start-tip: none, end: none, ..rest) = cetz.draw.get-ctx(ctx => {
  let draw = if draw == auto { _utp(ctx).color } else { draw }
  let (_, q) = cetz.coordinate.resolve(ctx, p)
  let (rx, ry) = _radius(ctx, radius)
  let center = (q.at(0) - rx * calc.cos(start * 1deg), q.at(1) - ry * calc.sin(start * 1deg))
  cetz.draw.arc(center, start: start * 1deg, stop: stop * 1deg, radius: (rx, ry), anchor: "origin",
    stroke: _stroke(draw, line-width, dash, opacity), fill: _paint(fill, opacity),
    mark: (start: _tip-for(start-tip, draw), end: _tip-for(end, draw)))
})

// decorate, decoration=snake: a wavy line through the points.
#let snake(..pts, amplitude: 2.5pt, segment-length: 10pt, draw: auto, line-width: 0.4pt, dash: none,
  opacity: 100%, end: none) = cetz.draw.get-ctx(ctx => {
  let draw = if draw == auto { _utp(ctx).color } else { draw }
  cetz.decorations.wave(cetz.draw.line(..pts.pos()), amplitude: 2 * _num(ctx, amplitude),
    segment-length: _num(ctx, segment-length), stroke: _stroke(draw, line-width, dash, opacity),
    mark: (end: _tip-for(end, draw)))
})

// (a) grid (b)
#let grid-at(a, b, step: 1, draw: auto, line-width: 0.4pt, dash: none, opacity: 100%, ..rest) = cetz.draw.get-ctx(ctx => {
  let draw = if draw == auto { _utp(ctx).color } else { draw }
  cetz.draw.grid(a, b, step: step, stroke: _stroke(draw, line-width, dash, opacity))
})

// (a) .. controls (c1) and (c2) .. (b)
#let curve(a, b, c1, c2, draw: auto, line-width: 0.4pt, dash: none, opacity: 100%,
  start: none, end: none, fill: none, ..rest) = cetz.draw.get-ctx(ctx => {
  let draw = if draw == auto { _utp(ctx).color } else { draw }
  cetz.draw.bezier(a, b, c1, c2, stroke: _stroke(draw, line-width, dash, opacity),
    mark: (start: _tip-for(start, draw), end: _tip-for(end, draw)), fill: _paint(fill, opacity))
  // TikZ's picture size counts a curve's control points
  cetz.draw.line(a, c1, c2, b, stroke: none)
})

// plot[smooth] coordinates {...}
#let smooth-path(..pts, draw: auto, line-width: 0.4pt, dash: none, opacity: 100%,
  start: none, end: none) = cetz.draw.get-ctx(ctx => {
  let draw = if draw == auto { _utp(ctx).color } else { draw }
  cetz.draw.catmull(..pts.pos(), tension: 0.55, stroke: _stroke(draw, line-width, dash, opacity),
    mark: (start: _tip-for(start, draw), end: _tip-for(end, draw)))
})

// Positions measured between centres (TikZ "on grid").
#let right-of-center(target, d) = _beside(target, "center", d, 0, "center")
#let left-of-center(target, d) = _beside(target, "center", d, 0, "center", sx: -1)
#let above-of-center(target, d) = _beside(target, "center", 0, d, "center")
#let below-of-center(target, d) = _beside(target, "center", 0, d, "center", sy: -1)

// ----------------------------------------------- diagrams/network.tex
// Devices, links and the state of a path.
#let router = (shape: "circle", draw: blue, fill: pale-blue, min-size: 10mm, font: font("small", weight: "bold", fill: navy))
#let switch = (draw: teal, fill: pale-teal, rounded: 1mm, min-width: 15mm, min-height: 8mm, font: font("small", weight: "bold", fill: navy))
#let host = (draw: orange, fill: pale-orange, min-width: 15mm, min-height: 8mm, font: font("small", weight: "bold", fill: navy))
#let netlink = (draw: muted, line-width: widths.thick)
#let netlabel = (font: font("script", fill: muted), inner-sep: 1pt)
#let activepath = (draw: green, line-width: widths.very-thick)
#let backuppath = (draw: orange, line-width: widths.very-thick, dash: "dashed")
#let deadpath = (draw: red, line-width: widths.very-thick, dash: (2pt, 2pt))
#let flowarrow = (draw: blue, line-width: widths.thick, end: tip("Stealth", length: 2.2mm, line: widths.thick))
#let vlanA = (draw: blue, fill: pale-blue, rounded: 1mm, min-width: 13mm, min-height: 7mm, font: font("script", weight: "bold", fill: navy))
#let vlanB = (draw: orange, fill: pale-orange, rounded: 1mm, min-width: 13mm, min-height: 7mm, font: font("script", weight: "bold", fill: navy))
#let netframe = (draw: muted, fill: white, min-height: 6mm, font: font("script", fill: ink))
// Servers, clouds, port stubs, and a tinted broadcast domain.
#let server = (draw: purple, fill: pale-purple, rounded: 0.8mm, min-width: 15mm, min-height: 9mm, font: font("small", weight: "bold", fill: navy))
#let cloudnode = (shape: "cloud", draw: muted, fill: pale-gray, min-width: 22mm, min-height: 12mm, font: font("script", fill: ink))
#let portstub = (shape: "circle", draw: muted, fill: white, inner-sep: 0.7pt, font: font("tiny", fill: muted))
#let bcastzone = (draw: mix(blue, 45%), fill: mix(pale-blue, 60%), rounded: 2mm, dash: (3pt, 2pt))
#let bcastalt = (draw: mix(orange, 55%), fill: mix(pale-orange, 70%), rounded: 2mm, dash: (3pt, 2pt))
#let bcasttag = (font: font("script", weight: "bold", fill: navy), inner-sep: 1.5pt)
#let costlabel = (font: font("script", weight: "bold", fill: teal), inner-sep: 1pt, fill: white, rounded: 0.5mm)
#let figcap = (font: font("script", fill: muted), align: center)
// Protocol field layouts: \protorow and \prototicks.
#let hdrbase = (draw: mix(navy, 55%), min-height: 8mm, align: center, font: font("script", fill: navy), inner-sep: 1pt, anchor: "west")
#let hdrb = (..hdrbase, fill: pale-blue)
#let hdro = (..hdrbase, fill: pale-orange)
#let hdrg = (..hdrbase, fill: pale-teal)
#let hdrm = (..hdrbase, fill: pale-gray)
#let hdrr = (..hdrbase, fill: pale-red)
#let hdrpay = (..hdrbase, fill: white, draw: mix(muted, 55%), font: font("script", style: "italic", fill: muted))
#let hdrtick = (font: font("tiny", fill: muted), inner-sep: 1pt)
#let protorow(y, unit, cells) = {
  let x = 0
  for (w, label, style) in cells {
    node((x, y), label, ..style, min-width: w * unit)
    x += w * unit
  }
}
#let prototicks(y, unit, cells) = {
  let x = 0
  for (w, label) in cells {
    node((x + w * unit / 2, y), label, ..hdrtick)
    x += w * unit
  }
}
// Sequence diagrams.
#let seqhead = (draw: navy, fill: white, rounded: 1mm, min-width: 17mm, min-height: 7mm, font: font("script", weight: "bold", fill: navy))
#let seqline = (draw: mix(muted, 60%), dash: (2pt, 2pt))
#let seqarrow = (draw: blue, line-width: widths.semithick, end: tip("Stealth", length: 2mm, line: widths.semithick))
#let seqarrowb = (draw: teal, line-width: widths.semithick, end: tip("Stealth", length: 2mm, line: widths.semithick))
#let seqdrop = (draw: red, line-width: widths.semithick, dash: (2.5pt, 1.5pt), end: tip("Stealth", length: 2mm, line: widths.semithick))
#let seqrisk = (draw: red, line-width: widths.semithick, end: tip("Stealth", length: 2mm, line: widths.semithick))
#let seqlabel = (font: font("script", fill: ink), fill: white, inner-sep: 1.5pt)
#let seqnotebox = (font: font("script", fill: muted), align: left, inner-sep: 1pt)
#let seqspan = (draw: teal, fill: pale-teal, min-width: 2.6mm, inner-sep: 0pt)
#let seqactor(id, x, label, ..style) = node((x, 0), label, name: id, ..seqhead, ..style)
#let seqlife(id, y) = connect(id + ".south", (rel: (0, y), to: id + ".south"), ..seqline)
#let seqmsg(a, b, y, label, kind) = {
  let style = (arrow: seqarrow, arrowb: seqarrowb, drop: seqdrop, risk: seqrisk).at(kind)
  let p = (rel: (0, y), to: a + ".south")
  let q = (rel: (0, y), to: b + ".south")
  connect(p, q, ..style)
  node(along(p, q), label, ..seqlabel)
}
#let seqnote(x, y, width, body) = node((x, y), body, ..seqnotebox, text-width: width, anchor: "west")
// State machines.
#let netstate = (draw: blue, fill: pale-blue, rounded: 1.6mm, min-width: 17mm, min-height: 7.5mm, font: font("script", weight: "bold", fill: navy))
#let stategood = (..netstate, draw: green, fill: pale-teal, line-width: 1pt)
#let statebad = (..netstate, draw: red, fill: pale-red)
#let statewait = (..netstate, draw: orange, fill: pale-orange)
#let stedge = (draw: muted, line-width: widths.semithick, end: tip("Stealth", length: 2mm, line: widths.semithick))
#let stlabel = (font: font("tiny", fill: muted), align: center, inner-sep: 1.5pt)
// Protocol stacks.
#let netlayer = (draw: mix(navy, 45%), min-width: 34mm, min-height: 8mm, font: font("small", fill: navy), inner-sep: 2pt)
#let layerapp = (..netlayer, fill: pale-purple)
#let layertra = (..netlayer, fill: pale-teal)
#let layernet = (..netlayer, fill: pale-blue)
#let layerlnk = (..netlayer, fill: pale-orange)
#let layerphy = (..netlayer, fill: pale-gray)
#let pdu = (font: font("script", weight: "bold", fill: teal), inner-sep: 1pt)
#let layernum = (font: font("script", fill: muted), inner-sep: 1pt)

// ----------------------------------------------- diagrams/process.tex
#let _procbox(draw, fill, font-fill: navy, weight: "bold") = (draw: draw, fill: fill, rounded: 2mm,
  min-width: 2.35cm, min-height: 0.82cm, align: center, font: font("script", weight: weight, fill: font-fill), inner-sep: 1.6mm)
#let procstep = _procbox(blue, pale-blue)
#let procdoc = (draw: blue, fill: white, rounded: 1.2mm, min-width: 2.2cm, min-height: 0.8cm, align: center, font: font("script", fill: navy), inner-sep: 1.4mm)
#let procgood = _procbox(green, pale-teal)
#let procbad = _procbox(red, pale-red)
#let procwarn = _procbox(orange, pale-orange)
#let procquiet = _procbox(mix(muted, 45%), pale-gray, font-fill: muted, weight: "regular")
#let procterm = (shape: "rounded-rectangle", draw: navy, fill: mix(navy, 8%), min-width: 2.1cm, min-height: 0.68cm, align: center, font: font("script", weight: "bold", fill: navy), inner-sep: 1.2mm)
#let procdec = (shape: "diamond", aspect: 2.1, draw: orange, fill: pale-orange, align: center, font: font("script", fill: navy), inner-sep: 0.6mm)
#let procdb = (shape: "cylinder", draw: blue, fill: pale-blue, min-height: 1.25cm, min-width: 2.5cm, align: center, font: font("script", weight: "bold", fill: navy))
#let procstore = (draw: blue, fill: pale-blue, rounded: 2mm, align: center, min-height: 1.0cm, font: font("script", weight: "bold", fill: navy), inner-sep: 2mm)
#let proclane = (draw: mix(muted, 45%), fill: white, inner-sep: 0pt)
#let proclanehead = (font: font("script", weight: "bold", fill: navy), align: center)
#let proczone = (draw: mix(blue, 30%), fill: mix(pale-blue, 45%), rounded: 2.5mm, inner-sep: 3mm)
#let proczonewarn = (draw: mix(orange, 45%), fill: mix(pale-orange, 55%), rounded: 2.5mm, inner-sep: 3mm)
#let procflow = (draw: teal, line-width: widths.thick, end: tip("Stealth", length: 2.2mm, line: widths.thick))
#let procback = (draw: orange, line-width: widths.thick, end: tip("Stealth", length: 2.2mm, line: widths.thick))
#let procslow = (draw: red, line-width: widths.thick, dash: "dashed", end: tip("Stealth", length: 2.2mm, line: widths.thick))
#let proclink = (draw: mix(muted, 60%), line-width: widths.semithick, dash: "dotted")
#let proccap = (font: font("script", fill: muted), align: center, inner-sep: 1pt)
#let procnote = (font: font("tiny", fill: muted), align: center, inner-sep: 1pt)
#let prochead = (font: font("small", weight: "bold", fill: navy), align: center)
#let _chip(draw, fill) = (draw: draw, fill: fill, rounded: 1mm, font: font("tiny", weight: "bold", fill: navy), inner-xsep: 1.6mm, inner-ysep: 0.8mm)
#let procchip = _chip(teal, pale-teal)
#let procchipwarn = _chip(orange, pale-orange)
#let procchipbad = _chip(red, pale-red)

// ----------------------------------------------- diagrams/data-objects.tex
#let cell = (draw: blue, fill: pale-blue, min-width: 8mm, min-height: 7mm, font: font("script", fill: navy), inner-sep: 1pt)
#let cellalt = (..cell, fill: pale-orange, draw: orange)
#let cellghost = (..cell, fill: pale-gray, draw: mix(muted, 50%), font: font("script", style: "italic", fill: muted))
#let cellout = (..cell, fill: pale-teal, draw: teal)
#let cellbad = (..cell, fill: pale-red, draw: red)
#let slot = (draw: teal, fill: pale-teal, min-width: 17mm, min-height: 9mm, align: center, font: font("script", fill: navy), inner-sep: 1.5pt)
#let dscol = (draw: mix(navy, 45%), fill: white, min-width: 17mm, min-height: 7mm, font: font("script", fill: ink), inner-sep: 1pt)
#let dshead = (..dscol, fill: pale-blue, font: font("script", weight: "bold", fill: navy))
#let tag = (font: font("script", fill: muted), inner-sep: 1.5pt)
#let tagb = (font: font("script", weight: "bold", fill: navy), inner-sep: 1.5pt)
#let rarrow = (draw: teal, line-width: widths.semithick, end: tip("Stealth", length: 2mm, line: widths.semithick))
#let rarrowmuted = (draw: muted, line-width: widths.semithick, end: tip("Stealth", length: 2mm, line: widths.semithick))
#let fcbox = (draw: blue, fill: pale-blue, rounded: 1mm, min-width: 22mm, min-height: 7mm, font: font("script", fill: navy), align: center)
#let fcdiamond = (shape: "diamond", aspect: 2.2, draw: orange, fill: pale-orange, inner-sep: 1pt, font: font("script", fill: navy), align: center)
#let fcstart = (shape: "rounded-rectangle", draw: muted, fill: pale-gray, font: font("script", fill: ink), inner-sep: 2pt)
#let fcedge = (draw: muted, line-width: widths.semithick, end: tip("Stealth", length: 2mm, line: widths.semithick))
#let fclabel = (font: font("tiny", fill: muted), inner-sep: 1.5pt)

// ----------------------------------------------- style/course-map.tex
#let card = (draw: blue, fill: pale-blue, rounded: 2mm, min-width: 3.99cm, min-height: 1.88cm, align: left,
  inner-xsep: 3.2mm, inner-ysep: 1.6mm, font: font("small", fill: navy))
#let finalcard = (..card, draw: teal, fill: pale-teal)
#let arr = (draw: teal, line-width: 0.9pt, shorten-start: 0.8pt, shorten-end: 0.8pt,
  end: tip("Stealth", length: 2.25mm, width: 1.55mm, line: 0.9pt))
// \utpcoursemapcard{stage}{title}{summary}: the text of one course-map card.
#let coursemapcard(stage, title, summary) = box(width: 3.35cm, height: 1.52cm, {
  set par(justify: false, leading: 2.4pt)
  set align(left + top)
  text(size: sizes.script, weight: "bold", fill: teal, stage)
  linebreak()
  v(0.02em, weak: true)
  text(weight: "bold", title)
  linebreak()
  v(0.08em, weak: true)
  text(size: sizes.script, fill: mix(muted, 80%, other: navy), summary)
})

// -------------------------------------------------------- lab flow visuals
#import "figures.typ": labvisual, labgraphic

// \courselabflow{a}{b}{c}{d}: four numbered steps joined by arrows.
#let courselabflow(a, b, c, d) = labvisual([From setup to verified result], labgraphic(canvas({
  for (i, body) in (a, b, c, d).enumerate() {
    let pos = if i == 0 { (0, 0) } else { right-of("s" + str(i - 1), 0.35) }
    // (the picture's font=\small is overridden by utpstep's \scriptsize, as in TikZ)
    node(pos, [*#(i + 1)* \ #body], name: "s" + str(i), ..utpstep, text-width: 2.5, min-height: 1.15)
  }
  for i in range(3) { connect("s" + str(i), "s" + str(i + 1), ..utparrow) }
})))

// \courselabtrace{title}{head}{body}{head}{body}{head}{body}: three stages.
#let courselabtrace(title, h1, b1, h2, b2, h3, b3) = labvisual(title, labgraphic(canvas({
  let fills = (pale-blue, pale-blue, pale-teal)
  for (i, (h, b)) in ((h1, b1), (h2, b2), (h3, b3)).enumerate() {
    let pos = if i == 0 { (0, 0) } else { right-of("t" + str(i - 1), 0.4) }
    node(pos, [*#h* \ #v(3pt) #b], name: "t" + str(i), ..utpstep, fill: fills.at(i),
      text-width: 3.4, min-height: 1.8, align: left)
  }
  for i in range(2) { connect("t" + str(i), "t" + str(i + 1), ..utparrow) }
})))

// \begin{utpcompactlabfigure}[title]: a lab frame for a drawing on a smaller grid.
#let utpcompactlabfigure(title, body) = labvisual(title, body)
