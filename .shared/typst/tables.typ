// Tables in the house shape of style/theme.tex: a full-width tabularx with
// booktabs rules, a tinted header row of centred bold navy cells, zebra
// striping from the second row (\rowcolors{2}{UTPPaleBlue!72}{white}), and
// \small text in vertically centred cells padded by \tabcolsep.
//
//   #tabularx(
//     columns: (22%, 1fr),               // m{0.22\linewidth} X
//     styles: (navy-bold,),              // >{\bfseries\color{UTPNavy}} on column 1
//     header: ([Operation], [What it does]),
//     [Insertion], [Add a new element.],
//   )
//
// A percentage is a share of the line width, as in m{0.22\linewidth}; 1fr is
// an X column; auto is an l, c or r column. The padding LaTeX puts around each
// column is added here, so the widths read exactly as they did in LaTeX.
#import "palette.typ": *
#import "theme.typ": *

#let tabcolsep = 6.48pt
#let rule-color = mix(blue, 45%)
#let header-fill = mix(pale-blue, 92%)
#let stripe-fill = mix(pale-blue, 72%)
#let cell-inset = (top: 4.93pt, bottom: 2.81pt)

// Column styles a table can name in `styles:`.
#let navy-bold = (weight: "bold", fill: navy)
#let mono-cell = (font: "Source Code Pro", size: 0.88em)
#let italic-cell = (style: "italic")

// booktabs: \heavyrulewidth and \lightrulewidth, with the space it leaves
// above and below each rule, measured from the LaTeX pages.
#let heavy-rule = 0.87pt
#let light-rule = 0.55pt

// A header cell that is not the usual centred bold navy one.
#let th(body) = std.align(center, text(weight: "bold", fill: navy, body))

// \multicolumn{n}{c}{...}: a body or header cell spanning n columns.
#let multicolumn(n, alignment, body, style: (:)) = table.cell(colspan: n,
  inset: (x: tabcolsep, ..cell-inset), align: alignment + horizon, text(..style, body))

#let spacer(n, height) = table.cell(colspan: n, inset: 0pt, box(height: height))

#let tabularx(
  columns: (),
  align: (),
  styles: (),
  valign: (),
  header: none,
  header-fill: header-fill,
  column-fill: (),
  rules: auto,
  rule-color: rule-color,
  size: "small",
  zebra: true,
  ..cells,
) = {
  // Only a share of the line width needs the width of the space it sits in.
  let shares = columns.any(w => type(w) in (ratio, relative))
  let build(width) = {
  let n = columns.len()
  let cells = cells.pos()
  let pad-left(i) = if i == 0 { 0pt } else { tabcolsep }
  let pad-right(i) = if i == n - 1 { 0pt } else { tabcolsep }
  // LaTeX widths are the text width; Typst's include the padding.
  let widths = columns.enumerate().map(((i, w)) => {
    if type(w) == ratio { w * width + pad-left(i) + pad-right(i) }
    else if type(w) == relative { w.ratio * width + w.length + pad-left(i) + pad-right(i) }
    else if type(w) == length { w + pad-left(i) + pad-right(i) }
    else { w }
  })
  let col-align(i) = align.at(i, default: left)
  let col-valign(i) = valign.at(i, default: horizon)
  let col-style(i) = {
    let s = styles.at(i, default: none)
    if s == none { (:) } else { s }
  }
  // booktabs rules: all three (auto, with a header), none, or some ("bottom",)
  let which = if rules == auto { if header != none { ("top", "mid", "bottom") } else { () } }
    else if rules == "booktabs" { ("top", "mid", "bottom") } else if rules == "none" { () } else { rules }
  // Two narrow edge columns carry the zebra tint past the rules, as
  // \rowcolors does; the rules and the header tint stop at the text edges.
  let edge = if zebra { tabcolsep } else { 0pt }
  let m = n + 2
  let rows = ()
  let rule(weight) = table.hline(stroke: weight + rule-color, start: 1, end: n + 1)
  if "top" in which {
    rows.push(rule(heavy-rule))
    rows.push(spacer(m, 3.88pt))
  }
  if header != none {
    // One header row, or several (a list of rows) above the \midrule.
    let header-rows = if header.len() > 0 and type(header.first()) == array { header } else { (header,) }
    for (k, hr) in header-rows.enumerate() {
      rows.push(table.cell(inset: 0pt)[])
      for h in hr {
        if type(h) == content and h.func() == table.cell {
          let f = h.fields()
          let body = f.remove("body")
          rows.push(table.cell(..f, fill: header-fill, body))
        } else {
          rows.push(table.cell(fill: header-fill, inset: (x: tabcolsep, ..cell-inset),
            align: center + horizon, text(weight: "bold", fill: navy, h)))
        }
      }
      rows.push(table.cell(inset: 0pt)[])
    }
    if "mid" in which {
      rows.push(spacer(m, 2.39pt))
      rows.push(rule(light-rule))
      rows.push(spacer(m, 3.72pt))
    }
  }
  // Group the body cells into rows of n columns.
  let span-of(c) = if type(c) == content and c.func() == table.cell { c.at("colspan", default: 1) } else { 1 }
  let body-rows = ()
  let row = ()
  let filled = 0
  for c in cells {
    // a rule between body rows: keep it in order, outside the cell count
    if type(c) == content and c.func() == table.hline {
      body-rows.push(c)
      continue
    }
    row.push(c)
    filled += span-of(c)
    if filled >= n {
      body-rows.push(row)
      row = ()
      filled = 0
    }
  }
  if row.len() > 0 { body-rows.push(row) }
  // \rowcolors{2}: counting the header as row 1, rows 3, 5, ... are tinted.
  let first = if header != none { 2 } else { 1 }
  let k = 0
  for r in body-rows {
    if type(r) == content {
      rows.push(table.hline(stroke: r.stroke, start: 1, end: n + 1))
      continue
    }
    let row-number = first + k
    k += 1
    let tint = if zebra and row-number >= 2 and calc.odd(row-number) { stripe-fill } else { none }
    rows.push(table.cell(inset: 0pt, fill: tint)[])
    let x = 0
    for c in r {
      if type(c) == content and c.func() == table.cell {
        let f = c.fields()
        let body = f.remove("body")
        if "fill" not in f { f.insert("fill", tint) }
        rows.push(table.cell(..f, body))
        x += f.at("colspan", default: 1)
      } else {
        let fill = column-fill.at(x, default: none)
        rows.push(table.cell(fill: if fill != none { fill } else { tint },
          inset: (left: pad-left(x), right: pad-right(x), ..cell-inset),
          align: col-align(x) + col-valign(x), text(..col-style(x), c)))
        x += 1
      }
    }
    rows.push(table.cell(inset: 0pt, fill: tint)[])
  }
  if "bottom" in which {
    rows.push(spacer(m, 2.56pt))
    rows.push(rule(heavy-rule))
  }
  // a LaTeX tabular is one box: it never breaks across pages
  block(breakable: false, pad(x: -edge, fsize(size, table(columns: (edge, ..widths, edge), stroke: none, inset: 0pt, ..rows))))
  }
  if shares { layout(space => build(space.width)) } else { build(none) }
}
