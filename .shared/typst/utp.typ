// Shared UTP book design. All dimensions and colours are maintained here.
#import "diagrams.typ": flow-diagram
#import "code.typ": listing
#import "vector-diagrams.typ": vector-diagram
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

#let book(title: [], summary: [], lab-total: 10, mono-font: "Source Code Pro", body) = {
  set document(title: title, author: "Reeyan Afzal Khan")
  set text(font: "Source Sans 3", size: 10.91pt, fill: ink, lang: "en")
  set page(paper: "a4", margin: 21mm, numbering: "1",
    header: context {
      let chapters = query(heading.where(level: 1)).filter(h => h.location().page() <= here().page())
      if chapters.len() == 0 or chapters.last().location().page() != here().page() {
        set text(size: 9.96pt, fill: muted)
        grid(columns: (1fr, 1fr), align: (left, right), title, if chapters.len() > 0 { chapters.last().body })
        line(length: 100%, stroke: .5pt + pale-blue)
      }
    }, footer: context align(center, text(size: 9.96pt, fill: muted, counter(page).display())))
  set par(justify: true, leading: 3.2pt, spacing: 6.02pt)
  set heading(numbering: "1.1", outlined: true)
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    if it.numbering != none {
      counter(figure.where(kind: image)).update(0)
      align(right, block(width: 25.5mm + 6pt, fill: blue, inset: 3pt)[
        #align(center, text(size: 14.35pt, hyphenate: false, fill: white, weight: "bold")[CHAPTER\ #text(size: 24.79pt, counter(heading).display("1"))])
      ])
    }
    block(above: 0.65em, below: 0.5em, text(size: 24.79pt, weight: "bold", fill: navy, it.body))
    line(length: 100%, stroke: 1.2pt + blue)
    v(0.5em)
  }
  show heading.where(level: 2): it => block(above: 13.14pt, below: 3.83pt, sticky: true, text(size: 14.35pt, fill: navy, weight: "bold", it))
  show heading.where(level: 3): it => block(above: 10.4pt, below: 2.19pt, sticky: true, text(size: 11.96pt, fill: blue, weight: "bold", it))
  show raw: set text(font: mono-font, size: 9.64pt)
  show raw.where(block: true): it => listing(it, font: mono-font)
  set table(inset: 6pt, stroke: 0.4pt + blue.lighten(70%), fill: (x, y) => if calc.odd(y) { pale-blue } else { white })
  show table: set text(size: 9pt)
  set figure(gap: 5pt, numbering: n => context [#counter(heading).get().first().#n])
  show figure.caption: set text(size: 9.96pt)
  show math.equation.where(block: true): set block(above: 9pt, below: 9pt)
  set list(indent: 1.45em, body-indent: 0.4em, spacing: 0.22em)
  set enum(indent: 1.75em, body-indent: 0.4em, spacing: 0.28em)
  show terms: it => block(above: 3pt, below: 3pt, grid(columns: (100pt, 1fr), row-gutter: 3pt,
    ..it.children.map(item => (text(weight: "bold", fill: navy, item.term), item.description)).flatten()))
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
  let tint = if kind in ("keyidea", "chapterrecap") { rgb("EEF8F6") }
    else if kind in ("workedexample", "labmode") { pale-blue }
    else if kind in ("intuition", "analogy") { rgb("FFF5EA") }
    else if kind in ("pitfall", "debugtask") { rgb("FFF0EF") } else { white }
  block(width: 100%, breakable: true, fill: tint, stroke: 0.8pt + accent, radius: 2mm, inset: 0pt, above: 8pt, below: 8pt)[
    #if title != [] { block(width: 100%, fill: accent, inset: (x: 2.5mm, y: 3pt), radius: (top-left: 2mm, top-right: 2mm), text(fill: white, weight: "bold", title)) }
    #block(inset: (x: 2.5mm, y: 1.8mm), body)
  ]
}

#let diagram-image(path) = if lecture-export { image(path) } else { layout(size => {
  let drawing = image(path, width: size.width)
  align(center, if measure(drawing).height > 105mm { image(path, height: 105mm) } else { drawing })
}) }
#let diagram-drawing(path) = if lecture-export { image(path.replace(".cetz.json", ".svg")) } else { vector-diagram(path) }
#let flow(..items) = {
  let items = items.pos()
  if lecture-export { return metadata((utp: "flow", items: items)) }
  flow-diagram(items)
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
