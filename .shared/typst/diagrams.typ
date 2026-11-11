// Project-owned CeTZ drawing primitives. Coordinates are millimetres.
#import "/.shared/packages/cetz/0.5.3/src/lib.typ" as cetz
#import "palette.typ": *

#let flow-diagram(items) = layout(size => {
  let n = items.len()
  if n == 0 { return }
  let gap = 5.0
  let w = calc.min(31.0, (size.width / 1mm - (n - 1) * gap) / n)
  let labels = items.map(body => block(width: (w - 4) * 1mm, align(center, text(size: 9pt, fill: navy, body))))
  let h = calc.max(12.0, ..labels.map(body => measure(body).height / 1mm + 4))
  align(center, cetz.canvas(length: 1mm, {
    import cetz.draw: *
    for (i, body) in labels.enumerate() {
      let x = i * (w + gap)
      rect((x, -h / 2), (x + w, h / 2), radius: 2, stroke: .7pt + blue, fill: pale-blue)
      content((x + w / 2, 0), body)
      if i < n - 1 { line((x + w + .8, 0), (x + w + gap - .8, 0), stroke: .9pt + teal, mark: (end: ">", length: 1.8mm, width: 1.4mm)) }
    }
  }))
})

#let cover-workflow() = cetz.canvas(length: 1mm, {
  import cetz.draw: *
  let nodes = (
    ((0, 0), [SESSION\ PLANNING]),
    ((47.5, -25.5), [INSTRUCTIONAL\ SUPPORT]),
    ((0, -51), [STUDENT\ ENGAGEMENT]),
    ((-47.5, -25.5), [LEARNING\ ASSESSMENT]),
  )
  for ((x, y), body) in nodes {
    rect((x - 18.75, y - 7.1), (x + 18.75, y + 7.1), radius: 1.5,
      stroke: .65pt + blue.lighten(35%), fill: pale-blue.lighten(58%))
    content((x, y), text(size: 9.96pt, weight: "bold", fill: navy, align(center, body)))
  }
  circle((0, -25.5), radius: 11.3, stroke: 1pt + gold, fill: navy)
  content((0, -25.5), text(size: 9.96pt, weight: "bold", fill: white, align(center, [TA\ WORKFLOW])))
  for (a, b) in (
    ((20.8, -1.3), (45.5, -17.1)),
    ((45.5, -33.9), (20.8, -49.7)),
    ((-20.8, -49.7), (-45.5, -33.9)),
    ((-45.5, -17.1), (-20.8, -1.3)),
  ) { line(a, b, stroke: .6pt + muted, mark: (end: ">", length: 2.1mm, width: 1.4mm)) }
})
