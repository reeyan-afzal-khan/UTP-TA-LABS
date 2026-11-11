// Codly owns all block-code rendering; inline raw stays unframed.
#import "/.shared/packages/codly/2.0.0/codly.typ" as codly
#import "palette.typ": *

#let listing(it, font: "Source Code Pro", numbered: false) = {
  set text(font: font, size: if font.starts-with("Inconsolata") { 8.13pt } else { 7.01pt })
  set par(leading: 2.2pt, spacing: 0pt, justify: false)
  show: codly.line-set_(fill: rgb("F7F8F9"), stroke: .4pt + blue.lighten(72%), inset: (x: 0pt, y: 0pt))
  block(above: 7.65pt, below: 8.74pt, breakable: true)[
    #codly.new(it, number-enabled: numbered, lang-position: none, file-position: none,
      padding: 5pt, radius: 0pt, leading: 1pt, row-gutter: 0pt, breakable: true)
  ]
}
