// Shared UTP book design. All dimensions and colours are maintained here.
#import "/.shared/packages/fletcher/0.5.8/src/exports.typ" as fletcher: diagram, node, edge
#import "palette.typ": *
#import "cover.typ": cover
#let lab-count = state("lab-total", 10)
#let stage-count = counter("stage")
#let horizontalrule = line(length: 100%, stroke: 0.5pt + blue)
#let lecture-export = sys.inputs.at("lecture", default: "false") == "true"
#let unit(kind, slug) = if not lecture-export {
  pagebreak(weak: true)
  context [#metadata((kind: kind, slug: slug, page: here().page())) <unit>]
}

#let book(title: [], summary: [], lab-total: 10, body) = {
  set document(title: title, author: "Reeyan Afzal Khan")
  set text(font: "Source Sans 3", size: 11pt, fill: ink, lang: "en")
  set page(paper: "a4", margin: 21mm, numbering: "1",
    header: context {
      set text(size: 9pt, fill: muted)
      title
      line(length: 100%, stroke: pale-blue)
    }, footer: context align(center, text(size: 9pt, fill: muted, counter(page).display())))
  set par(justify: true, leading: 0.55em, spacing: 0.55em)
  set heading(numbering: "1.1", outlined: true)
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    if it.numbering != none {
      align(right, block(width: 25.5mm, fill: blue, inset: 5pt)[
        #align(center, text(size: 13pt, hyphenate: false, fill: white, weight: "bold")[CHAPTER\ #text(size: 28pt, counter(heading).display("1"))])
      ])
    }
    block(above: 0.65em, below: 0.5em, text(size: 28pt, weight: "bold", fill: navy, it.body))
    line(length: 100%, stroke: 1.2pt + blue)
    v(0.5em)
  }
  show heading.where(level: 2): set text(size: 17pt, fill: navy)
  show heading.where(level: 3): set text(size: 14pt, fill: blue)
  show raw: set text(font: "Source Code Pro", size: 8.5pt)
  show raw.where(block: true): it => block(width: 100%, fill: rgb("F4F6F7"), inset: 7pt, radius: 2mm, breakable: true, it)
  set table(inset: 6pt, stroke: 0.4pt + blue.lighten(70%), fill: (x, y) => if calc.odd(y) { pale-blue } else { white })
  show table: set text(size: 9pt)
  set figure(gap: 5pt)
  show figure.caption: set text(size: 9pt)
  set list(indent: 1.45em, body-indent: 0.4em, spacing: 0.22em)
  set enum(indent: 1.75em, body-indent: 0.4em, spacing: 0.28em)
  lab-count.update(lab-total)
  body
}

#let callout(kind, title: [], body) = {
  if lecture-export { return metadata((utp: "callout", kind: kind, title: title, body: body)) }
  let accent = if kind in ("pitfall", "debugtask") { red }
    else if kind in ("quickcheck", "intuition", "analogy", "decisionmemo", "troubleshoot") { orange }
    else if kind in ("verification", "chapterrecap", "labdeliverable", "labcheckpoint", "miniproject") { green }
    else if kind in ("keyidea", "tryit", "yourturn", "labanswer", "recommendedworkflow") { teal }
    else if kind in ("labproject", "chapterguide", "labpart", "coursechoice") { navy }
    else { blue }
  block(width: 100%, breakable: true, stroke: 0.8pt + accent, radius: 2mm, inset: 0pt, above: 8pt, below: 8pt)[
    #if title != [] { block(width: 100%, fill: accent, inset: (x: 7pt, y: 5pt), radius: (top-left: 2mm, top-right: 2mm), text(fill: white, weight: "bold", title)) }
    #block(inset: 7pt, body)
  ]
}

#let diagram-image(path) = if lecture-export { image(path) } else { layout(size => {
  let drawing = image(path, width: size.width)
  align(center, if measure(drawing).height > 105mm { image(path, height: 105mm) } else { drawing })
}) }
#let flow(..items) = {
  let items = items.pos()
  if lecture-export { return metadata((utp: "flow", items: items)) }
  set text(size: 9pt, fill: navy)
  align(center, diagram(spacing: 4mm, node-stroke: 0.7pt + blue, node-fill: pale-blue,
    ..items.enumerate().map(((i, body)) => node((i, 0), block(width: 27mm, body), corner-radius: 2mm, inset: 6pt)),
    ..range(items.len() - 1).map(i => edge((i, 0), (i + 1, 0), "-|>", stroke: 0.9pt + teal)),
  ))
}
#let code-block(value, lang: "text") = raw(value, lang: lang, block: true)
#let source-code(path, first: 1, last: none, lang: "text") = {
  let lines = read(path).split("\n")
  code-block(lines.slice(first - 1, if last == none { lines.len() } else { calc.min(last, lines.len()) }).join("\n"), lang: lang)
}
#let lab(number, body) = {
  if lecture-export { return metadata((utp: "lab", number: number, title: body)) }
  pagebreak(weak: true)
  show heading: it => block(width: 100%, fill: navy, inset: 5mm, radius: 2mm)[
    #text(fill: teal.lighten(65%), weight: "bold")[PRACTICAL MILESTONE]
    #v(2mm)
    #text(size: 28pt, fill: white, weight: "bold")[Lab #number of #context lab-count.get()]
    #v(2mm)
    #text(size: 18pt, fill: white, weight: "bold", body)
  ]
  heading(level: 1, numbering: none, outlined: true, bookmarked: true)[Lab #number — #body]
}
#let stage(number: auto, subtitle: [], body) = {
  pagebreak(weak: true)
  context [#metadata((kind: "divider", slug: "stage", page: here().page())) <unit>]
  stage-count.step()
  v(45mm)
  align(center)[
    #text(size: 18pt, fill: teal, weight: "bold")[Stage #if number == auto { context stage-count.display() } else { number }]
    #v(5mm)
    #text(size: 30pt, fill: navy, weight: "bold", body)
    #v(6mm)
    #line(length: 45%, stroke: 1.5pt + teal)
    #v(8mm)
    #subtitle
  ]
  pagebreak()
}
