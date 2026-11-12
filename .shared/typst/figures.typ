// Figure frames of style/figures.tex and labs/visuals.tex.
//
//   #utpfig([The caption.], label: <fig:x>)[drawing]   a frame with a numbered caption
//   #utpfigure(title: [Title])[drawing]               a frame, optionally titled
//   #utptable[table]                                  the same frame for a table
//   #sourceimage([Title], "file.png")                 a lecturer's screenshot or slide
//   #labvisual([Title])[drawing]                      the narrower lab frame
#import "palette.typ": *
#import "theme.typ": *
#import "boxes.typ": tcb, box-above, box-below

// Figure 3.1: the chapter number, then the figure's number in the chapter.
// As LaTeX's report class: chapter.figure, and the figure alone in chapter 0.
#let figure-numbering(n) = context {
  let h = counter(heading).get()
  let chapter = h.at(1, default: 0)
  if chapter > 0 [#chapter.#n] else [#n]
}

// \begin{utpfig}[short]{caption}{label}: the drawing and its caption in one
// frame; the page never breaks between them.
#let utpfig(caption, body, label: none, short: none) = {
  let f = figure(body, kind: "utpfig", supplement: none, numbering: figure-numbering,
    caption: caption, outlined: true)
  if label == none { f } else { [#f#label] }
}

// book() shows every utpfig through this.
#let show-utpfig(it) = tcb(kind: "figure", frame: mix(blue, 32%), rule: 0.5pt, top: 2.6mm, bottom: 7.83pt,
  breakable: false, above: 14.45pt - 0.2 * sizes.normal, below: 21.48pt - 0.712 * sizes.normal,
  text-color: ink, centered: true, {
    it.body
    block(above: 17.34pt - 0.712 * sizes.small, below: 0pt, {
      set text(size: sizes.small)
      set par(leading: leading-for("small"), justify: false)
      text(weight: "bold", fill: navy)[Figure #it.counter.display(it.numbering).]
      [ ]
      it.caption.body
    })
  })

// \begin{utpfigure}[title]: a centred frame with an optional title bar.
#let utpfigure(body, title: none) = tcb(body, title: title, title-back: blue,
  frame: mix(blue, 35%), rule: 0.5pt, top: 2.2mm, bottom: 2.2mm, centered: true)

// \begin{utptable}: the frame around a table.
#let utptable(body) = tcb(body, frame: mix(blue, 28%), rule: 0.45pt,
  left: 2.2mm, right: 2.2mm, top: 1.8mm, bottom: 1.8mm)

// \includegraphics[width=..,height=..,keepaspectratio]: as large as fits both.
#let fitted-image(path, width: 100%, height: none) = layout(space => {
  let w = if type(width) == ratio { width * space.width } else { width }
  let natural = measure(image(path))
  let factor = w / natural.width
  if height != none { factor = calc.min(factor, height / natural.height) }
  image(path, width: natural.width * factor)
})

// \sourceimage and \compactsourceimage: a screenshot in a titled frame.
#let sourceimage(title, path, width: 90%) = utpfigure(title: [Source visual --- #title],
  fitted-image(path, width: width, height: 0.56 * 722.83pt))
#let compactsourceimage(title, path, width: 78%) = utpfigure(title: [Source visual --- #title],
  fitted-image(path, width: width, height: 0.42 * 722.83pt))

// \fignote: a short muted line under a drawing.
#let fignote(body) = block(above: 9pt, below: 0pt, text(size: sizes.script, fill: muted, body))

// \begin{labvisual}{title}: a lab frame, 94% wide, kept on one page.
#let labvisual(title, body) = block(above: 6.44pt - 0.2 * sizes.normal, below: 9pt, width: 100%,
  align(center, tcb(body, title: title, title-back: blue, frame: mix(blue, 35%), rule: 0.5pt,
    top: 2.2mm, bottom: 2.2mm, centered: true, breakable: false, width: 94%,
    above: 0pt, below: 0pt)))

// \begin{labgraphic}: a drawing scaled down to the line width and 6cm high.
#let labgraphic(body) = layout(space => {
  let natural = measure(body)
  if natural.width == 0pt or natural.height == 0pt { return body }
  let factor = calc.min(1.0, space.width / natural.width, 6cm / natural.height)
  if factor >= 1.0 { body } else {
    scale(factor * 100%, reflow: true, body)
  }
})
