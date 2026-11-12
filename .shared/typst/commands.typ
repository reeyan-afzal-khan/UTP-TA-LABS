// The small commands of style/commands.tex and the network transcript helpers.
#import "palette.typ": *
#import "theme.typ": *
#import "state.typ": cfg
#import "boxes.typ": tcb

#let term(body) = text(weight: "bold", fill: navy, body)          // \term
#let cmd(body) = raw(body)                                        // \cmd (plain text)
#let lib(body) = text(weight: "bold", fill: blue, raw(body))      // \lib
#let utpapp(body) = text(weight: "bold", fill: blue, body)        // \utpapp
#let pathmenu(body) = text(weight: "bold", fill: teal, body)      // \pathmenu
#let ptrnull = text(size: sizes.script, fill: muted)[NULL]        // \ptrnull

// Cross-references, with the word written out as the LaTeX macros did.
#let chapref(target) = [Chapter~#ref(target)]
#let secref(target) = [Section~#ref(target)]
#let figref(target) = [Figure~#ref(target)]
#let chapsref(a, b) = [Chapters~#ref(a)--#ref(b)]

// Coloured, bold maths: \cxg, \cxo, \cxr.
#let cxg(body) = text(fill: green, weight: "bold", body)
#let cxo(body) = text(fill: orange, weight: "bold", body)
#let cxr(body) = text(fill: red, weight: "bold", body)

// \coretag and \latertag: read-now and come-back-to markers.
#let tag-chip(label, fill, color) = block(above: 3pt + par-spacing, below: 3pt + par-spacing,
  box(fill: fill, inset: (x: 3pt, y: 3pt), text(size: sizes.small, weight: "bold", fill: color, label)))
#let coretag = tag-chip([CORE NOW], pale-blue, blue)
#let latertag = tag-chip([RETURN LATER], pale-gray, muted)

// \kagglesource{url}{name}
#let kagglesource(url, name) = block(above: 3pt + par-spacing, below: par-spacing,
  [*Kaggle source:* #link(url, name)])

// Device transcripts (network.tex): highlighted fields and the reading hint.
#let hi(body) = text(weight: "bold", fill: blue, body)
#let higreen(body) = text(weight: "bold", fill: green, body)
#let hired(body) = text(weight: "bold", fill: red, body)
#let dimline(body) = text(fill: mix(muted, 75%), body)
#let vrpread(body) = block(above: 3pt, below: 3.8pt,
  text(size: sizes.footnote, fill: muted)[*Read:* #body])

// A device transcript: each line a list of verbatim pieces and highlights.
#let vrp(..lines) = context block(width: 100%, breakable: true, above: 0pt, below: 0pt, {
  let mono = cfg("mono")
  set text(font: mono, size: sizes.script * mono-scale.at(mono, default: 0.88), fill: ink)
  set par(justify: false, leading: skips.script - line-box * sizes.script * mono-scale.at(mono, default: 0.88))
  show raw: set text(size: 1.25em)
  for (i, l) in lines.pos().enumerate() {
    if i > 0 { linebreak() }
    for piece in l { piece }
  }
})

// \texttt around formatted text.
#let mono(body) = context text(font: cfg("mono"), size: mono-scale.at(cfg("mono"), default: 0.88) * 1em, body)

// \raggedright for a stretch of text.
#let raggedright(body) = {
  set par(justify: false)
  body
}

// \resizebox{width}{!}{...}: scale content to a width.
#let resizebox(width, body) = layout(space => {
  let w = if type(width) == ratio { width * space.width } else { width }
  let natural = measure(body)
  if natural.width == 0pt { body } else {
    scale(w / natural.width * 100%, reflow: true, body)
  }
})

// enumitem options on one list: [leftmargin=..,itemsep=..,topsep=..].
#let listopts(leftmargin: auto, itemsep: auto, topsep: auto, parsep: 4.48pt,
  marker: auto, numbering: auto, body) = {
  let gap = if itemsep == auto { auto } else { skips.normal + itemsep + parsep - line-box * sizes.normal }
  set list(spacing: gap) if gap != auto
  set enum(spacing: gap) if gap != auto
  set list(indent: leftmargin - 5.45pt - 3.25pt, body-indent: 5.45pt) if leftmargin != auto
  set enum(indent: leftmargin - 5.45pt - 6.74pt, body-indent: 5.45pt) if leftmargin != auto
  set list(marker: marker) if marker != auto
  set enum(numbering: numbering) if numbering != auto
  show list: set block(above: par-spacing + topsep, below: par-spacing + topsep) if topsep != auto
  show enum: set block(above: par-spacing + topsep, below: par-spacing + topsep) if topsep != auto
  body
}

// \begin{description}[leftmargin=..,style=nextline]: the label on its own
// line when it is wider than the margin, otherwise beside the text.
#let describe-nextline(leftmargin, body) = {
  show terms.item: it => context {
    let label = text(weight: "bold", fill: navy, it.term)
    if measure(label).width + 5.45pt > leftmargin {
      block(above: 0pt, below: 0pt, label)
      block(above: leading-for("normal"), below: 0pt, pad(left: leftmargin, it.description))
    } else {
      grid(columns: (leftmargin, 1fr), label, it.description)
    }
  }
  show terms: set block(above: par-spacing + 0.3 * em-normal, below: par-spacing + 0.3 * em-normal)
  body
}

// \item[label] in an itemize list.
#let item-label(body) = text(weight: "bold", body)

// A page turned sideways (pdflscape).
#let landscape(body) = page(flipped: true, body)

// \captionof{figure}{...} outside a figure frame.
#let captionof(body) = align(center, text(size: sizes.small)[#text(weight: "bold", fill: navy)[Figure.] #body])

// Font Awesome 5 icons (the fontawesome5 package), from the bundled fonts.
#let fa-brand(code) = text(font: "Font Awesome 5 Brands", str.from-unicode(code))
#let fa-solid(code) = text(font: "Font Awesome 5 Free Solid", str.from-unicode(code))
#let icon-windows = fa-brand(0xf17a)
#let icon-apple = fa-brand(0xf179)
#let icon-linux = fa-brand(0xf17c)
#let fa-check = fa-solid(0xf00c)
#let fa-times = fa-solid(0xf00d)

// \shortstack: short lines stacked and centred.
#let shortstack(body) = box(align(center, {
  set par(leading: leading-for("normal"))
  body
}))

// \begin{vrpbox}{command}: a device transcript under the command that printed it.
#let vrpbox(title, body) = context tcb(body, title: title, back: white, frame: mix(navy, 65%),
  rule: 0.7pt, arc: 1.2mm, left: 1.6mm, right: 1.6mm, top: 1.4mm, bottom: 1.4mm,
  title-back: mix(navy, 88%), title-font: (weight: "regular", font: cfg("mono"),
    size: sizes.script * mono-scale.at(cfg("mono"), default: 0.88)),
  above: 0.8 * em-normal, below: 0.9 * em-normal)
