// The title page of .shared/cover.tex. Every element sits where the LaTeX
// cover put it; positions are page coordinates in points from the top left.
// What changes between books comes from book(): title, subtitle, outline,
// outline heading, author and author role.
#import "palette.typ": *
#import "theme.typ": *
#import "state.typ": *
#import "/.shared/packages/cetz/0.5.3/src/lib.typ" as cetz

#let margin = 59.53pt
// Put `body` with its top-left corner (or top-centre) at page point (x, y).
#let at-page(x, y, body, center: false) = place(top + if center { std.center } else { left },
  dx: if center { 0pt } else { x - margin }, dy: y - margin, body)
// A line of text whose baseline is at page height y.
#let line-at(y, size, body, center: true, x: 0pt) = at-page(x, y - 0.712 * size, center: center,
  text(size: size, body))

// The TA workflow: four stages around a navy core, with arrows between them.
#let cover-workflow() = cetz.canvas(length: 1pt, {
  import cetz.draw: *
  // TikZ placed the stages 4.75cm and 2.55cm from the centre (cm = 28.3465pt).
  let cm = 28.3465
  let stage(x, y, name, body) = {
    rect((x - 53.15, y - 20.125), (x + 53.15, y + 20.125), radius: 1.5 * cm / 10, name: name,
      stroke: 0.65pt + mix(blue, 65%), fill: mix(pale-blue, 42%))
    content((x, y), text(size: sizes.small, weight: "bold", fill: navy, align(center, body)))
  }
  stage(0, 0, "prepare", [SESSION\ PLANNING])
  stage(4.75 * cm, -2.55 * cm, "explain", [INSTRUCTIONAL\ SUPPORT])
  stage(0, -5.10 * cm, "facilitate", [STUDENT\ ENGAGEMENT])
  stage(-4.75 * cm, -2.55 * cm, "assess", [LEARNING\ ASSESSMENT])
  circle((0, -2.55 * cm), radius: 31.83, stroke: 1pt + gold, fill: navy)
  content((0, -2.55 * cm), text(size: sizes.small, weight: "bold", fill: white, align(center)[TA\ WORKFLOW]))
  let arrow(a, b) = {
    // shorten <=7pt, >=7pt along the straight line
    let (ax, ay) = a
    let (bx, by) = b
    let d = calc.sqrt((bx - ax) * (bx - ax) + (by - ay) * (by - ay))
    let (ux, uy) = ((bx - ax) / d, (by - ay) / d)
    line((ax + 7 * ux, ay + 7 * uy), (bx - 7 * ux, by - 7 * uy), stroke: 0.6pt + muted,
      mark: (end: "stealth", length: 2.1mm, width: 1.6mm, fill: muted, stroke: 0.6pt + muted))
  }
  arrow((53.15, 0), (4.75 * cm, -2.55 * cm + 20.125))
  arrow((4.75 * cm, -2.55 * cm - 20.125), (53.15, -5.10 * cm))
  arrow((-53.15, -5.10 * cm), (-4.75 * cm, -2.55 * cm - 20.125))
  arrow((-4.75 * cm, -2.55 * cm + 20.125), (-53.15, 0))
})

#let cover() = context {
  let o = config.get()
  set par(justify: false)
  empty-page
  // The gold bands at the top and bottom edges of the page.
  at-page(0pt, 0pt, rect(width: 595.28pt, height: 3.40pt, fill: gold, stroke: none))
  at-page(0pt, 838.49pt, rect(width: 595.28pt, height: 3.40pt, fill: gold, stroke: none))
  at-page(0pt, 77.48pt, center: true, image("/.shared/assets/logos/logo-UTP.png", height: 2.85cm))
  line-at(211.32pt, 28.89pt, text(weight: "bold", fill: navy, o.title))
  line-at(242.06pt, sizes.Large, text(fill: muted, o.subtitle))
  at-page(0pt, 272.22pt, center: true, rect(width: 26%, height: 1.3pt, fill: gold, stroke: none))
  // The workflow's left edge is the LEARNING box, its top the SESSION box.
  at-page(109.8pt - 0.33pt, 301.24pt - 0.33pt, cover-workflow())
  // The course outline: a pale frame with a gold left edge.
  at-page(0pt, 517.63pt, center: true, block(width: 82%, height: 583.06pt - 517.63pt,
    fill: mix(blue, 18%), radius: 1.5mm, inset: 0.45pt, {
      block(width: 100%, height: 100%, fill: white, radius: 1.5mm - 0.45pt, {
        place(left + top, dx: 0.35pt, rect(width: 1.6pt, height: 100%, fill: gold, stroke: none))
        set align(center)
        v(538.08pt - 518.08pt - 0.712 * sizes.large)
        block(above: 0pt, below: 0pt, text(size: sizes.large, weight: "bold", fill: blue, o.outline-heading))
        block(above: 554.90pt - 538.08pt - 0.2 * sizes.large - 0.712 * sizes.normal, below: 0pt,
          width: 100% - 2 * (6mm + 1mm), text(fill: ink, o.outline))
      })
    }))
  // Prepared by, and the department logo.
  line-at(722.46pt, sizes.normal, center: false, x: 101.3pt,
    text(weight: "bold", fill: blue)[PREPARED BY])
  line-at(743.12pt, sizes.Large, center: false, x: 101.3pt,
    text(weight: "bold", fill: navy, o.author))
  line-at(756.80pt, sizes.small, center: false, x: 101.3pt, text(fill: muted, o.author-role))
  at-page(362.13pt, 703.86pt, image("/.shared/assets/logos/logo-DC.png", height: 2.10cm))
  counter(page).update(0)
  pagebreak()
}
