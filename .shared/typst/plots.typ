// The charts of pgfplots, drawn with CeTZ inside a canvas:
//
//   #canvas({
//     axis(width: 11.2cm, height: 6.4cm, xmin: 1, xmax: 100, ymin: 0, ymax: 1000,
//       xlabel: [input size $n$], ylabel: [operations], axis-lines: "left",
//       addplot(x => x * x, domain: (1, 100), samples: 100, draw: red, legend: [$O(n^2)$]),
//       node((60, 900), [a note]),        // drawing in axis coordinates
//     )
//   })
//
// The option names are pgfplots' keys in Typst form. As in pgfplots, width and
// height are those of the whole chart: the axis box is 45pt smaller each way.
// Ticks are chosen, numbered and placed as pgfplots does.
#import "/.shared/packages/cetz/0.5.3/src/lib.typ" as cetz
#import "palette.typ": *
#import "theme.typ": *
#import "diagrams.typ": node, connect, font, widths, tip, dash-pattern, _num

// ------------------------------------------------------------ pgfplots' look
#let _pt = 72 / 72.27                        // one TeX point in Typst points
#let descriptions = 45pt * _pt               // width/height left for labels
#let tick-length = 0.1cm
#let max-tick-space = 35pt * _pt             // the widest gap between auto ticks
#let tick-font = "New Computer Modern"       // tick labels are set in maths

// A number as \pgfmathprintnumber prints it: 1,000 and 0.25 and −3.
#let pgf-num(v, precision: 2) = {
  let neg = v < 0
  let a = calc.abs(v)
  let r = calc.round(a, digits: precision)
  let whole = calc.floor(r)
  let frac = r - whole
  let ws = str(int(whole))
  let parts = ()
  while ws.len() > 3 {
    parts.insert(0, ws.slice(ws.len() - 3))
    ws = ws.slice(0, ws.len() - 3)
  }
  parts.insert(0, ws)
  let s = parts.join(",")
  if frac > 1e-9 {
    let f = str(calc.round(frac, digits: precision))
    s += "." + f.split(".").at(1, default: "0")
  }
  if neg and r != 0 { "\u{2212}" + s } else { s }
}

// The tick step pgfplots picks: about one tick per 35pt, rounded to 1, 2 or 5
// times a power of ten.
#let auto-step(lo, hi, length) = {
  let n = calc.max(1, calc.floor(length / max-tick-space))
  let raw = (hi - lo) / n
  let e = calc.floor(calc.log(raw))
  let m = raw / calc.pow(10.0, e)
  let nice = if m < 1.5 { 1 } else if m < 3.5 { 2 } else if m < 7.5 { 5 } else { 10 }
  nice * calc.pow(10.0, e)
}
// Log axes: whole decades, the same number of ticks, counted down from the top.
#let log-ticks(lo, hi, length) = {
  let n = calc.max(1, calc.floor(length / max-tick-space))
  let dist = calc.max(1, calc.floor((hi - lo) / n))
  let out = ()
  let k = calc.floor(hi + 1e-9)
  while k >= lo - 1e-9 {
    out.insert(0, calc.pow(10.0, k))
    k -= dist
  }
  out
}
#let auto-ticks(lo, hi, length) = {
  let step = auto-step(lo, hi, length)
  let k = calc.ceil(lo / step - 1e-9)
  let out = ()
  while k * step <= hi + 1e-9 * step {
    let v = calc.round(k * step, digits: 10)
    out.push(v)
    k += 1
  }
  out
}

// ---------------------------------------------------------------- the data
// \addplot: an expression (a function of x), coordinates, or table columns.
// The style keys are the TikZ ones: draw, fill, line-width, dash, mark, ...
#let addplot(
  ..expr,
  coords: none, table: none, x: none, y: none, meta: none,
  domain: auto, samples: auto,
  draw: auto, fill: none, line-width: 1.15pt * _pt, dash: none, opacity: 100%, fill-opacity: auto,
  mark: none, mark-size: 2pt, mark-fill: auto, mark-draw: auto,
  only-marks: false, smooth: false,
  legend: none, forget: false,
  restrict-y: none, skip-between: none,
  nodes-near-coords: auto, node-style: (:),
) = (
  utp-plot: true,
  expr: expr.pos().at(0, default: none),
  coords: coords, table: table, x: x, y: y, meta: meta,
  domain: domain, samples: samples,
  draw: draw, fill: fill, line-width: line-width, dash: dash, opacity: opacity, fill-opacity: fill-opacity,
  mark: mark, mark-size: mark-size, mark-fill: mark-fill, mark-draw: mark-draw,
  only-marks: only-marks, smooth: smooth,
  legend: legend, forget: forget, restrict-y: restrict-y, skip-between: skip-between,
  nodes-near-coords: nodes-near-coords, node-style: node-style,
)

// The points of a plot as (x, y, meta), with x already a symbolic index.
#let _points(p, opts) = {
  let sym = opts.symbolic-x
  let pts = if p.expr != none {
    let (a, b) = if p.domain != auto { p.domain } else if opts.domain != auto { opts.domain } else { (-5, 5) }
    let n = if p.samples != auto { p.samples } else if opts.samples != auto { opts.samples } else { 25 }
    range(n).map(k => { let x = a + k * (b - a) / (n - 1); (x, (p.expr)(x), none) })
  } else if p.table != none {
    p.table.map(r => (r.at(p.x), r.at(p.y), if p.meta != none { r.at(p.meta) } else { none }))
  } else {
    p.coords.map(c => (c.at(0), c.at(1), c.at(2, default: none)))
  }
  if sym != none {
    pts = pts.map(((x, y, m)) => (if type(x) == str { sym.position(s => s == x) } else { x }, y, m))
  }
  if p.skip-between != none {
    let (a, b) = p.skip-between
    pts = pts.enumerate().filter(((i, _)) => i < a or i >= b).map(((_, q)) => q)
  }
  pts
}

// --------------------------------------------------------------- clipping
// A polyline cut to the box [0, w] x [0, h]: a list of pieces.
#let _clip(pts, w, h) = {
  let eps = 1e-9
  let inside(p) = p.at(0) >= -eps and p.at(0) <= w + eps and p.at(1) >= -eps and p.at(1) <= h + eps
  // Liang-Barsky on one segment: the visible part, or none
  let seg(p, q) = {
    let (x0, y0) = p
    let (x1, y1) = q
    let (dx, dy) = (x1 - x0, y1 - y0)
    let (t0, t1) = (0.0, 1.0)
    for (pp, qq) in ((-dx, x0), (dx, w - x0), (-dy, y0), (dy, h - y0)) {
      if calc.abs(pp) < eps {
        if qq < 0 { return none }
      } else {
        let r = qq / pp
        if pp < 0 { if r > t1 { return none } else if r > t0 { t0 = r } }
        else { if r < t0 { return none } else if r < t1 { t1 = r } }
      }
    }
    ((x0 + t0 * dx, y0 + t0 * dy), (x0 + t1 * dx, y0 + t1 * dy))
  }
  let pieces = ()
  let cur = ()
  for i in range(1, pts.len()) {
    let s = seg(pts.at(i - 1), pts.at(i))
    if s == none { if cur.len() > 1 { pieces.push(cur) }; cur = (); continue }
    let (a, b) = s
    if cur.len() == 0 { cur.push(a) }
    else if calc.abs(cur.last().at(0) - a.at(0)) > 1e-6 or calc.abs(cur.last().at(1) - a.at(1)) > 1e-6 {
      if cur.len() > 1 { pieces.push(cur) }
      cur = (a,)
    }
    cur.push(b)
    if not inside(pts.at(i)) { pieces.push(cur); cur = () }
  }
  if cur.len() > 1 { pieces.push(cur) }
  pieces
}

// ------------------------------------------------------------------ marks
// One plot mark of radius r at p (canvas units), in TikZ's shapes.
#let _mark(p, kind, r, fill, stroke) = {
  let (x, y) = p
  if kind == "*" { cetz.draw.circle(p, radius: r, fill: fill, stroke: stroke) }
  else if kind == "o" { cetz.draw.circle(p, radius: r, fill: none, stroke: stroke) }
  else if kind in ("square*", "square") {
    cetz.draw.rect((x - r, y - r), (x + r, y + r), fill: if kind == "square*" { fill } else { none }, stroke: stroke)
  } else if kind in ("triangle*", "triangle") {
    cetz.draw.line((x, y + r), (x - 0.866 * r, y - 0.5 * r), (x + 0.866 * r, y - 0.5 * r), close: true,
      fill: if kind == "triangle*" { fill } else { none }, stroke: stroke)
  } else if kind in ("diamond*", "diamond") {
    cetz.draw.line((x, y + r), (x - 0.75 * r, y), (x, y - r), (x + 0.75 * r, y), close: true,
      fill: if kind == "diamond*" { fill } else { none }, stroke: stroke)
  } else if kind == "x" {
    cetz.draw.line((x - r, y - r), (x + r, y + r), stroke: stroke)
    cetz.draw.line((x - r, y + r), (x + r, y - r), stroke: stroke)
  } else if kind == "+" {
    cetz.draw.line((x - r, y), (x + r, y), stroke: stroke)
    cetz.draw.line((x, y - r), (x, y + r), stroke: stroke)
  } else if kind == "|" { cetz.draw.line((x, y - r), (x, y + r), stroke: stroke) }
  else if kind == "-" { cetz.draw.line((x - r, y), (x + r, y), stroke: stroke) }
}

// The same marks as Typst content, for the legend.
#let _mark-image(kind, r, fill, stroke) = {
  let d = 2 * r
  let shape = if kind in ("*", "o") { circle(radius: r, fill: if kind == "*" { fill } else { none }, stroke: stroke) }
    else if kind in ("square*", "square") { rect(width: d, height: d, fill: if kind == "square*" { fill } else { none }, stroke: stroke) }
    else if kind in ("triangle*", "triangle") {
      polygon((r, 0pt), (r - 0.866 * r, 1.5 * r), (r + 0.866 * r, 1.5 * r),
        fill: if kind == "triangle*" { fill } else { none }, stroke: stroke)
    } else if kind == "x" { place(line(start: (0pt, 0pt), end: (d, d), stroke: stroke)); line(start: (0pt, d), end: (d, 0pt), stroke: stroke) }
    else { box(width: d, height: d) }
  shape
}

// A log tick label, 10 to a power. Set as text with a script-size power (as TeX's
// maths sets it), so the label's height and depth are its glyphs'.
#let pow10(v) = [10#super(typographic: false, size: 0.75em, baseline: -0.42em)[#int(calc.round(calc.log(v)))]]

// --------------------------------------------------------------- the axis
// pgfplots' defaults, with the book's own (theme.tex: \pgfplotsset{every axis/.append style=...}).
#let _axis-defaults = (
  width: 240pt, height: 207pt, scale-only-axis: false,
  xmin: auto, xmax: auto, ymin: auto, ymax: auto,
  xtick: auto, ytick: auto, xticklabels: auto, yticklabels: auto, ticks: true,
  xlabel: none, ylabel: none, title: none,
  axis-lines: "box", axis-line-style: (draw: mix(muted, 85%), line-width: 0.55pt * _pt),
  grid: none, xmajorgrids: false, ymajorgrids: false, grid-style: (:),
  tick-label-style: font("script", fill: muted), x-tick-label-style: (:), y-tick-label-style: (:),
  label-style: font("small", fill: navy), xlabel-style: (:), ylabel-style: (:),
  title-style: font("small", weight: "bold", fill: navy),
  legend-style: (size: sizes.script, draw: mix(blue, 22%), fill: white, radius: 1pt * _pt),
  legend-columns: 1, legend-cell-align: "center",
  ybar: none, ybar-stacked: false, bar-width: 10pt,
  symbolic-x: none, enlarge-x-limits: auto, enlargelimits: auto,
  nodes-near-coords: false, node-near-coord-style: (:),
  domain: auto, samples: auto, clip: true,
  xmode: "linear", ymode: "linear", axis-equal-image: false, scaled-y-ticks: true, axis-arrows: true,
  plot-style: (:),
  at: (0, 0), anchor: "south-west", name: none,
)

// The colour a plot draws in: its draw, or the text colour.
#let _ink(ctx, c) = if c == auto { ctx.at("utp", default: (color: ink)).color } else { c }

// The axis itself: everything a pgfplots axis environment draws.
#let _draw-axis(o, plots, extras) = cetz.draw.get-ctx(ctx => {
  let L = ctx.length
  // the axis box in canvas units
  let w = ((if o.scale-only-axis { o.width } else { o.width - descriptions }) / L)
  let h = ((if o.scale-only-axis { o.height } else { o.height - descriptions }) / L)
  let log-x = o.xmode == "log"
  let log-y = o.ymode == "log"
  let tx(v) = if log-x { calc.log(v) } else { v }
  let ty(v) = if log-y { calc.log(v) } else { v }
  // the data, and the limits pgfplots would take from it
  let data = plots.map(p => (p, _points(p, o)))
  let xs = data.map(((_, pts)) => pts.map(q => q.at(0))).flatten()
  let ys = data.map(((_, pts)) => pts.map(q => q.at(1))).flatten().filter(v => v != none)
  let xmin = if o.xmin != auto { o.xmin } else if xs.len() > 0 { calc.min(..xs) } else { 0 }
  let xmax = if o.xmax != auto { o.xmax } else if xs.len() > 0 { calc.max(..xs) } else { 1 }
  let ymin = if o.ymin != auto { o.ymin } else if ys.len() > 0 { calc.min(..ys) } else { 0 }
  let ymax = if o.ymax != auto { o.ymax } else if ys.len() > 0 { calc.max(..ys) } else { 1 }
  if o.ybar != none and o.ymin == auto { ymin = calc.min(ymin, 0) }
  // enlarge x limits: a share of the range on each side
  let ex = if o.enlarge-x-limits != auto { o.enlarge-x-limits } else if o.enlargelimits != auto { o.enlargelimits }
    else if o.symbolic-x != none or o.ybar != none { 0.1 } else { 0 }
  if type(ex) == bool { ex = if ex { 0.1 } else { 0 } }
  if o.xmin == auto or o.symbolic-x != none { xmin -= ex * (xmax - xmin) }
  if o.xmax == auto or o.symbolic-x != none { xmax += ex * (xmax - xmin) / (1 + ex) }
  if xmax == xmin { xmax = xmin + 1 }
  let (xlo, xhi) = (tx(xmin), tx(xmax))
  let (ylo, yhi) = (ty(ymin), ty(ymax))
  if yhi == ylo { yhi = ylo + 1 }
  if o.axis-equal-image {
    // one unit is as long on both axes; the box shrinks to fit
    let u = calc.min(w / (xhi - xlo), h / (yhi - ylo))
    (w, h) = (u * (xhi - xlo), u * (yhi - ylo))
  }
  let X(x) = (tx(x) - xlo) / (xhi - xlo) * w
  let Y(y) = (ty(y) - ylo) / (yhi - ylo) * h
  // where the box sits: `at` names the anchor point of the box
  let (ax, ay) = {
    let (_, p) = cetz.coordinate.resolve(ctx, o.at("at"))
    let (fx, fy) = (
      "south-west": (0, 0), "south": (0.5, 0), "south-east": (1, 0), "west": (0, 0.5), "center": (0.5, 0.5),
      "east": (1, 0.5), "north-west": (0, 1), "north": (0.5, 1), "north-east": (1, 1),
    ).at(o.anchor, default: (0, 0))
    (p.at(0) - fx * w, p.at(1) - fy * h)
  }
  let P(x, y) = (ax + X(x), ay + Y(y))
  let line-color = o.axis-line-style.at("draw", default: mix(muted, 85%))
  let axis-stroke = (paint: line-color, thickness: o.axis-line-style.at("line-width", default: 0.55pt * _pt), cap: "butt")
  // ticks
  let xticks = if not o.ticks { () } else if o.xtick == "data" {
    data.map(((_, pts)) => pts.map(q => q.at(0))).flatten().dedup().sorted()
  } else if o.xtick != auto { o.xtick } else if o.symbolic-x != none { range(o.symbolic-x.len()) }
    else if log-x { log-ticks(xlo, xhi, w * L) }
    else { auto-ticks(xmin, xmax, w * L) }
  let yticks = if not o.ticks { () } else if o.ytick != auto { o.ytick }
    else if log-y { log-ticks(ylo, yhi, h * L) }
    else { auto-ticks(ymin, ymax, h * L) }
  xticks = xticks.filter(v => tx(v) >= xlo - 1e-9 and tx(v) <= xhi + 1e-9)
  yticks = yticks.filter(v => ty(v) >= ylo - 1e-9 and ty(v) <= yhi + 1e-9)
  // grid
  let grid-stroke = (paint: o.grid-style.at("draw", default: luma(80%)), thickness: 0.4pt * _pt)
  if o.grid == "major" or o.xmajorgrids {
    for v in xticks { cetz.draw.line(P(v, ymin), P(v, ymax), stroke: grid-stroke) }
  }
  if o.grid == "major" or o.ymajorgrids {
    for v in yticks { cetz.draw.line(P(xmin, v), P(xmax, v), stroke: grid-stroke) }
  }
  // axis lines and tick marks
  let t = tick-length / L
  let is-left = o.axis-lines == "left"
  if o.axis-lines == "box" {
    cetz.draw.rect(P(xmin, ymin), P(xmax, ymax), stroke: axis-stroke)
    for v in xticks {
      cetz.draw.line(P(v, ymin), (rel: (0, t)), stroke: axis-stroke)
      cetz.draw.line(P(v, ymax), (rel: (0, -t)), stroke: axis-stroke)
    }
    for v in yticks {
      cetz.draw.line(P(xmin, v), (rel: (t, 0)), stroke: axis-stroke)
      cetz.draw.line(P(xmax, v), (rel: (-t, 0)), stroke: axis-stroke)
    }
  } else {
    // inner axis lines end in a stealth tip; ticks sit across them
    let tipped = if o.axis-arrows { (symbol: "stealth", length: 3.55pt, width: 3.55pt, inset: 1.33pt,
      fill: line-color, stroke: (paint: line-color, thickness: 0.4pt * _pt)) } else { none }
    let (x0, y0) = if is-left { (xmin, ymin) } else { (calc.max(xmin, calc.min(0, xmax)), calc.max(ymin, calc.min(0, ymax))) }
    cetz.draw.line(P(xmin, y0), P(xmax, y0), stroke: axis-stroke, mark: (end: tipped))
    cetz.draw.line(P(x0, ymin), P(x0, ymax), stroke: axis-stroke, mark: (end: tipped))
    for v in xticks { cetz.draw.line((rel: (0, -t / 2), to: P(v, y0)), (rel: (0, t)), stroke: axis-stroke) }
    for v in yticks { cetz.draw.line((rel: (-t / 2, 0), to: P(x0, v)), (rel: (t, 0)), stroke: axis-stroke) }
  }
  // the plots
  let n-bars = plots.filter(p => not p.forget).len()
  let bar-k = 0
  let stack = (:)
  for (p, pts) in data {
    let color = _ink(ctx, p.draw)
    let stroke = if p.draw == none { none } else {
      (paint: color.transparentize(100% - p.opacity), thickness: p.line-width,
        dash: dash-pattern(p.dash, p.line-width), cap: "round", join: "round")
    }
    let mk = if p.mark != none { p.mark } else if p.only-marks { "*" } else { none }
    let ms = _num(ctx, if "mark-size" in o.plot-style and p.mark-size == 2pt { o.plot-style.mark-size } else { p.mark-size })
    let r-fill = if p.fill != none { p.fill } else { none }
    if o.ybar != none or o.ybar-stacked {
      // bars: grouped side by side, or stacked
      let bw = _num(ctx, o.bar-width)
      let gap = _num(ctx, if type(o.ybar) != length { 2pt } else { o.ybar })
      let off = if o.ybar-stacked { 0 } else { (bar-k - (n-bars - 1) / 2) * (bw + gap) }
      for (x, y, m) in pts {
        let base = if o.ybar-stacked { stack.at(str(x), default: 0) } else { calc.max(ymin, 0) }
        let top = if o.ybar-stacked { base + y } else { y }
        let (px, py0) = P(x, base)
        let (_, py1) = P(x, top)
        // the axis clips bars that start or end outside it
        (py0, py1) = (calc.max(ay, calc.min(ay + h, py0)), calc.max(ay, calc.min(ay + h, py1)))
        if calc.abs(py1 - py0) > 1e-9 or not o.ybar-stacked {
          cetz.draw.rect((px + off - bw / 2, py0), (px + off + bw / 2, py1),
            fill: if r-fill == none { none } else { r-fill.transparentize(100% - p.opacity) }, stroke: stroke)
        }
        if o.ybar-stacked { stack.insert(str(x), top) }
        if o.nodes-near-coords {
          node((px + off, py1), [#text(font: tick-font)[#pgf-num(y)]], anchor: "south",
            ..o.node-near-coord-style)
        }
      }
      if not p.forget { bar-k += 1 }
      continue
    }
    // canvas points, restricted to y-domain if asked
    let cpts = pts.filter(((x, y, m)) => y != none and (p.restrict-y == none or (y >= p.restrict-y.at(0) and y <= p.restrict-y.at(1))))
      .map(((x, y, m)) => (X(x), Y(y), m))
    if p.fill != none and not p.only-marks and mk == none and p.expr == none {
      // a filled area under the points (fill= on a coordinates plot)
      let poly = cpts.map(q => (ax + q.at(0), ay + q.at(1)))
      cetz.draw.line(..poly, close: true, fill: p.fill.transparentize(100% - (if p.fill-opacity == auto { p.opacity } else { p.fill-opacity })), stroke: stroke)
    } else if not p.only-marks and stroke != none and cpts.len() > 1 {
      if p.smooth {
        cetz.draw.catmull(..cpts.map(q => (ax + q.at(0), ay + q.at(1))), tension: 0.5, stroke: stroke)
      } else {
        let pieces = if o.clip { _clip(cpts.map(q => (q.at(0), q.at(1))), w, h) } else { (cpts.map(q => (q.at(0), q.at(1))),) }
        for piece in pieces { cetz.draw.line(..piece.map(q => (ax + q.at(0), ay + q.at(1))), stroke: stroke) }
      }
    }
    if mk != none {
      let mfill = if p.mark-fill != auto { p.mark-fill } else { color }
      let mstroke = (paint: if p.mark-draw != auto { p.mark-draw } else { color }, thickness: calc.min(p.line-width.pt(), 0.4) * 1pt)
      for (cx, cy, m) in cpts {
        if not o.clip or (cx >= -1e-6 and cx <= w + 1e-6 and cy >= -1e-6 and cy <= h + 1e-6) {
          _mark((ax + cx, ay + cy), mk, ms, mfill, mstroke)
        }
      }
    }
    // labels on the points (nodes near coords with point meta)
    let near = if p.nodes-near-coords != auto { p.nodes-near-coords } else { o.nodes-near-coords }
    if near != false {
      for (cx, cy, m) in cpts {
        if m != none { node((ax + cx, ay + cy), [#m], anchor: "south", ..o.node-near-coord-style, ..p.node-style) }
      }
    }
  }
  // drawing in axis coordinates: \node at (axis cs:4,19), \draw (axis cs:...)
  if extras.len() > 0 {
    cetz.draw.scope({
      cetz.draw.translate((ax - xlo * w / (xhi - xlo), ay - ylo * h / (yhi - ylo)))
      cetz.draw.scale(x: w / (xhi - xlo), y: h / (yhi - ylo))
      for e in extras { e }
    })
  }
  // tick labels, axis labels and the title
  let tls = (size: sizes.normal, fill: ink) + o.tick-label-style
  let tick-text(style, body) = text(font: tick-font, size: style.size, fill: style.at("fill", default: ink), body)
  let x-style = tls + o.x-tick-label-style
  let y-style = tls + o.y-tick-label-style
  let xlab(v, i) = if o.xticklabels != auto { o.xticklabels.at(i, default: []) }
    else if o.symbolic-x != none { text(font: "Source Sans 3")[#o.symbolic-x.at(int(v), default: "")] }
    else if log-x { pow10(v) }
    else { pgf-num(v) }
  let ylab(v, i) = if o.yticklabels != auto { o.yticklabels.at(i, default: []) }
    else if log-y { pow10(v) }
    else { pgf-num(v) }
  // Distances measured from the LaTeX pages: tick labels stand off 1.15pt from
  // a box and 3.31pt from inner axis lines; the x label's baseline sits
  // 2.08 tick-label sizes plus 0.553 label sizes below the axis; the y label's
  // font box ends 7.54pt left of the widest tick label.
  let off = (if o.axis-lines == "box" { 1.15pt } else { 3.31pt }) / L
  let has-xlabels = xticks.len() > 0 and o.xticklabels != ()
  let has-ylabels = yticks.len() > 0 and o.yticklabels != ()
  for (i, v) in xticks.enumerate() {
    let body = xlab(v, i)
    if body != [] and body != "" {
      node((ax + X(v), ay - off), tick-text(x-style, body), anchor: "north", inner-sep: 0.333 * x-style.size,
        font: (size: x-style.size))
    }
  }
  for (i, v) in yticks.enumerate() {
    let body = ylab(v, i)
    if body != [] and body != "" {
      node((ax - off, ay + Y(v)), tick-text(y-style, body), anchor: "east", inner-sep: 0.333 * y-style.size,
        font: (size: y-style.size))
    }
  }
  let tick-w = if has-ylabels {
    (calc.max(0, ..yticks.enumerate().map(((i, v)) => measure(tick-text(y-style, ylab(v, i))).width / L))
      + 0.333 * y-style.size / L)
  } else { 0 }
  let ls = (size: sizes.normal, fill: ink) + o.label-style
  let middle = o.axis-lines in ("middle", "center")
  if o.xlabel != none and middle {
    let st = ls + o.xlabel-style
    node((ax + w, ay + Y(calc.max(ymin, calc.min(0, ymax)))), text(size: st.size, fill: st.at("fill", default: ink), o.xlabel),
      anchor: "south-east", font: (size: st.size))
  } else if o.xlabel != none {
    let st = ls + o.xlabel-style
    let drop = off + ((if has-xlabels { 2.0796 * x-style.size } else { 0pt }) + 0.553 * st.size) / L
    node((ax + w / 2, ay - drop), text(size: st.size, fill: st.at("fill", default: ink), o.xlabel),
      anchor: "base", font: (size: st.size))
  }
  if o.ylabel != none and middle {
    let st = ls + o.ylabel-style
    node((ax + X(calc.max(xmin, calc.min(0, xmax))), ay + h), text(size: st.size, fill: st.at("fill", default: ink), o.ylabel),
      anchor: "north-west", font: (size: st.size))
  } else if o.ylabel != none {
    let st = ls + o.ylabel-style
    let x = ax - off - tick-w - (7.54pt + 0.2 * st.size) / L
    node((x, ay + h / 2), text(size: st.size, fill: st.at("fill", default: ink), o.ylabel),
      anchor: "base", rotate: 90deg, font: (size: st.size))
  }
  if o.title != none {
    // every axis title: above the box, yshift=6pt (and any yshift of the title style)
    let st = (size: sizes.normal, fill: ink) + o.title-style
    let lift = (6pt * _pt + st.at("yshift", default: 0pt)) / L
    node((ax + w / 2, ay + h + lift), text(size: st.size, fill: st.at("fill", default: ink), weight: st.at("weight", default: "regular"), o.title),
      anchor: "south", font: (size: st.size))
  }
  // the legend
  let entries = data.filter(((p, _)) => p.legend != none and not p.forget)
  if entries.len() > 0 {
    let ls = (at: (0.97, 0.97), anchor: "north-east", size: sizes.normal, draw: ink, fill: white) + o.legend-style
    let image(p) = {
      let color = _ink(ctx, p.draw)
      let stroke = if p.draw == none { none } else { (paint: color, thickness: p.line-width, dash: dash-pattern(p.dash, p.line-width)) }
      let mk = if p.mark != none { p.mark } else if p.only-marks { "*" } else { none }
      let ms = _num(ctx, p.mark-size) * L
      let mfill = if p.mark-fill != auto { p.mark-fill } else { color }
      // the legend image: a 0.6cm line with the mark in its middle (a bar for bar plots)
      box(width: 0.6cm, height: 0.6em, {
        if o.ybar != none or o.ybar-stacked {
          place(center + horizon, rect(width: 0.2cm, height: 0.8em, fill: p.fill, stroke: stroke))
        } else {
          if not p.only-marks and stroke != none { place(horizon, line(length: 0.6cm, stroke: stroke)) }
          if mk != none { place(center + horizon, _mark-image(mk, ms, mfill, (paint: color, thickness: 0.4pt))) }
        }
      })
    }
    // pgfplots' legend: a matrix of nodes with 2pt inner sep and a 0.15em text
    // depth, no gaps between cells, and 3pt by 2pt of room inside its frame
    let pad = 2pt * _pt
    let entry-text(body) = box(inset: pad, text(size: ls.size, top-edge: "bounds", bottom-edge: -0.15em, body))
    let cells = entries.map(((p, _)) => (box(inset: pad, image(p)), entry-text(p.legend))).flatten()
    let table = grid(columns: ls.at("columns", default: o.legend-columns) * 2,
      align: (center + horizon, if o.legend-cell-align == "left" { left + horizon } else { center + horizon }), ..cells)
    let frame = block(inset: (x: 3pt * _pt, y: 2pt * _pt), fill: ls.fill,
      stroke: if ls.draw == none { none } else { 0.4pt * _pt + ls.draw }, radius: ls.at("radius", default: 0pt),
      text(size: ls.size, table))
    let (fx, fy) = ls.at("at")
    node((ax + fx * w, ay + fy * h), frame, anchor: ls.anchor, inner-sep: 0pt, font: (size: ls.size))
  }
  if o.name != none {
    cetz.draw.group(name: o.name, {
      cetz.draw.anchor("center", (ax + w / 2, ay + h / 2))
      cetz.draw.anchor("south-west", (ax, ay))
      cetz.draw.anchor("north-west", (ax, ay + h))
      cetz.draw.anchor("south-east", (ax + w, ay))
      cetz.draw.anchor("north-east", (ax + w, ay + h))
      cetz.draw.anchor("south", (ax + w / 2, ay))
      cetz.draw.anchor("north", (ax + w / 2, ay + h))
      cetz.draw.anchor("west", (ax, ay + h / 2))
      cetz.draw.anchor("east", (ax + w, ay + h / 2))
      cetz.draw.anchor("right-of-south-east", (ax + w, ay))
      cetz.draw.anchor("right-of-north-east", (ax + w, ay + h))
      cetz.draw.anchor("below-south-west", (ax, ay))
      cetz.draw.anchor("below-south-east", (ax + w, ay))
      cetz.draw.anchor("above-north-west", (ax, ay + h))
      cetz.draw.anchor("left-of-south-west", (ax, ay))
      cetz.draw.anchor("left-of-north-west", (ax, ay + h))
    })
  }
})

// \begin{axis}[options] ... \end{axis}: plots from addplot() and any CeTZ
// drawing (in axis coordinates), in the order given.
#let axis(..args) = {
  let o = _axis-defaults + args.named()
  // these styles add to the book's (a font style replaces it, as in pgfplots)
  for k in ("legend-style", "grid-style", "axis-line-style") {
    if k in args.named() { o.insert(k, _axis-defaults.at(k) + args.named().at(k)) }
  }
  let items = args.pos()
  let plots = items.filter(i => type(i) == dictionary and i.at("utp-plot", default: false))
  let extras = items.filter(i => not (type(i) == dictionary and i.at("utp-plot", default: false)))
  _draw-axis(o, plots, extras)
}

// \nextgroupplot[options]: one cell of a groupplot.
#let nextgroupplot(..args) = (utp-group-cell: true, named: args.named(), items: args.pos())

// \begin{groupplot}[group style={group size=c by r, horizontal sep=..}]: axes
// in a grid; the shared options apply to every cell.
#let groupplot(..args, group-size: (1, 1), horizontal-sep: 1cm, vertical-sep: 1cm) = cetz.draw.get-ctx(ctx => {
  let shared = args.named()
  let cells = args.pos().filter(c => type(c) == dictionary and c.at("utp-group-cell", default: false))
  let (cols, rows) = group-size
  let o0 = _axis-defaults + shared
  let w = ((if o0.scale-only-axis { o0.width } else { o0.width - descriptions }) / ctx.length)
  let h = ((if o0.scale-only-axis { o0.height } else { o0.height - descriptions }) / ctx.length)
  let hs = _num(ctx, horizontal-sep)
  let vs = _num(ctx, vertical-sep)
  for (k, c) in cells.enumerate() {
    let (i, j) = (calc.rem(k, cols), calc.quo(k, cols))
    let at = (i * (w + hs), -j * (h + vs))
    axis(..shared, ..c.named, at: at, anchor: "south-west", ..c.items)
  }
})
