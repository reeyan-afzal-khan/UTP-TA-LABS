// Drawing vocabulary for the Git book: commits, branch labels, HEAD and the
// four places work lives. Chapters import it beside utp.typ:
//   #import "git-figures.typ": *
// Time runs left to right; a line joins each commit to its parent.
#import "/.shared/typst/utp.typ": *

// Commits: a small circle holding a letter. `new` marks what a command just
// made, `merge` a commit with two parents, `dim` a commit nothing points to.
#let gcommit = (shape: "circle", draw: blue, fill: pale-blue, min-size: 7mm,
  font: font("script", weight: "bold", fill: navy), inner-sep: 0.5pt)
#let gnew = (..gcommit, draw: orange, fill: pale-orange, line-width: 1pt)
#let gmerge = (..gcommit, draw: green, fill: pale-teal, line-width: 1pt)
#let gdim = (..gcommit, draw: mix(muted, 45%), fill: pale-gray, font: font("script", fill: muted), dash: "dashed")
#let gbad = (..gcommit, draw: red, fill: pale-red, line-width: 1pt)
#let ggood = (..gcommit, draw: green, fill: pale-teal)

// The line from a commit to its parent.
#let gparent = (draw: mix(muted, 70%), line-width: widths.thick)
#let gparentdim = (draw: mix(muted, 45%), line-width: widths.semithick, dash: "dashed")

// Labels: a branch, HEAD, and a remote-tracking note such as origin/main.
#let gbranch = (draw: teal, fill: pale-teal, rounded: 1mm, inner-sep: 2pt,
  font: font("script", weight: "bold", fill: navy))
#let ghead = (draw: orange, fill: pale-orange, rounded: 1mm, inner-sep: 2pt,
  font: font("script", weight: "bold", fill: navy))
#let gremote = (draw: mix(muted, 60%), fill: white, rounded: 1mm, inner-sep: 2pt, dash: "dashed",
  font: font("script", fill: muted))
#let gptr = (draw: teal, line-width: widths.semithick,
  end: arrow-tip("Stealth", length: 1.6mm, line: widths.semithick, color: teal))
#let gptrhead = (draw: orange, line-width: widths.semithick,
  end: arrow-tip("Stealth", length: 1.6mm, line: widths.semithick, color: orange))
#let gptrremote = (draw: mix(muted, 60%), line-width: widths.semithick, dash: "dashed",
  end: arrow-tip("Stealth", length: 1.6mm, line: widths.semithick, color: mix(muted, 60%)))

// A label `d` cm above (or below) a node, with an arrow pointing at it.
#let glabel(target, body, name, style: gbranch, d: 0.42, below: false) = {
  let ptr = if style == ghead { gptrhead } else if style == gremote { gptrremote } else { gptr }
  node(if below { below-of(target, d) } else { above-of(target, d) }, body, name: name, ..style)
  connect(name, target, ..ptr)
}

// A small caption inside a drawing.
#let gnote = (font: font("script", fill: muted), inner-sep: 1pt)
#let gtitle = (font: font("small", weight: "bold", fill: navy), inner-sep: 1pt)

// The four places: three on your computer and one on GitHub.
#let gplace = (draw: blue, fill: pale-blue, rounded: 1.5mm, min-width: 2.85, min-height: 1.25,
  align: center, inner-sep: 2pt, font: font("small", fill: navy))
#let gremoteplace = (..gplace, draw: purple, fill: pale-purple)
#let gforward = (draw: teal, line-width: widths.thick,
  end: arrow-tip("Stealth", length: 2.2mm, line: widths.thick, color: teal))
#let gback = (draw: orange, line-width: widths.thick,
  end: arrow-tip("Stealth", length: 2.2mm, line: widths.thick, color: orange))
#let gcmd(body) = text(font: "Source Code Pro", size: 0.88 * sizes.script, weight: "bold", body)
#let gcmdlabel = (font: font("script", fill: ink), fill: white, inner-sep: 1.5pt)

