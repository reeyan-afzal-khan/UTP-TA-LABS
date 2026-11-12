// Type sizes and vertical rhythm of the LaTeX books (11pt report class with
// Source Sans), measured from the reference PDFs. LaTeX points are 1/72.27 in,
// Typst points 1/72 in, so 10.95 LaTeX pt is the 10.91pt used here.
#import "palette.typ": *

// \tiny ... \Huge, and the baselineskip LaTeX sets with each.
#let sizes = (
  tiny: 5.98pt, script: 7.97pt, footnote: 8.97pt, small: 9.96pt, normal: 10.91pt,
  large: 11.96pt, Large: 14.35pt, LARGE: 17.22pt, huge: 20.66pt, Huge: 24.79pt,
)
#let skips = (
  tiny: 6.97pt, script: 9.46pt, footnote: 10.96pt, small: 11.95pt, normal: 13.55pt,
  large: 13.95pt, Large: 17.93pt, LARGE: 21.92pt, huge: 24.91pt, Huge: 29.89pt,
)

// A line's box runs from the top of the ascenders (h, l, d: 0.712em) to just
// below the baseline (0.2em, a typical TeX descender depth). With these edges
// Typst's leading reproduces LaTeX's fixed baselineskip, and the space between
// a line and a frame matches what TeX measures from the glyphs.
#let top-edge = 0.712em
#let bottom-edge = -0.2em
#let line-box = 0.912

// The leading that gives size `name` its LaTeX baselineskip.
#let leading-for(name) = skips.at(name) - line-box * sizes.at(name)

// Typeset `body` at a LaTeX size: \small, \scriptsize, ... with its baselineskip.
#let fsize(name, body) = {
  set text(size: sizes.at(name))
  set par(leading: leading-for(name))
  body
}

// \fontsize{size}{skip}\selectfont: any size with its baselineskip.
#let fsize-at(size, skip, body) = {
  set text(size: size)
  set par(leading: skip - line-box * size)
  body
}

// LaTeX's \parskip (0.55em) on top of the baselineskip.
#let parskip = 6pt
#let par-spacing = skips.normal + parskip - line-box * sizes.normal

// One em and one ex at the body size, for lengths LaTeX wrote in em.
#let em-normal = 10.91pt

// The source-code faces, scaled as the LaTeX packages scaled them.
#let mono-scale = (
  "Source Code Pro": 0.88,
  "Inconsolatazi4": 1.02,
)

// \keepspace{h}: start a new page unless at least h is left on this one.
#let keepspace(height) = {
  block(above: 0pt, below: 0pt, height: height, breakable: false, width: 100%)
  v(-height, weak: false)
}
