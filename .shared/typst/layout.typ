// Page layout, headings, running heads and the Learning Path contents page.
// Mirrors the LaTeX style files configuration.tex, theme.tex, contents.tex,
// headings.tex and frontmatter.tex. The lengths are measured from the PDFs
// those files produced.
#import "palette.typ": *
#import "theme.typ": *
#import "state.typ": *
#import "listings.typ": show-listing
#import "figures.typ": show-utpfig

#let part-counter = counter("utp-part")

// ------------------------------------------------------------ chapter heads
// \titleformat{\chapter}[display]: a blue badge with the word and the
// number, the title in \Huge, and a 1.2pt rule.
#let chapter-badge(number) = context align(right, block(width: 78.26pt, height: 43.71pt, fill: blue, {
  set par(justify: false)
  place(top + center, dy: 12.70pt - 0.712 * sizes.Large,
    text(size: sizes.Large, weight: "bold", fill: white, hyphenate: false, cfg("chapter-label")))
  place(top + center, dy: 40.43pt - 0.712 * sizes.Huge,
    text(size: sizes.Huge, weight: "bold", fill: white, number))
}))

#let chapter-title(body) = {
  block(above: 0pt, below: 0pt, {
    set par(justify: false, leading: leading-for("Huge"))
    set text(size: sizes.Huge, weight: "bold", fill: navy, hyphenate: false)
    body
  })
  block(above: 15.16pt - 0.2 * sizes.Huge, below: 0pt, width: 100%, height: 1.2pt, fill: blue)
}

// After the rule: the next line's baseline sits 24.73pt below it.
#let after-chapter = 24.73pt - 0.712 * sizes.normal

// ------------------------------------------------------------------- book
#let book(..options, body) = {
  let o = defaults
  for (key, value) in options.named() {
    if key in ("contents", "titles") { o.insert(key, o.at(key) + value) } else { o.insert(key, value) }
  }
  if o.running-head == none { o.running-head = [Course Notes] }
  let mono-size = mono-scale.at(o.mono, default: 0.88)

  set document(title: o.title, author: "Reeyan Afzal Khan")
  set text(font: "Source Sans 3", size: sizes.normal, fill: ink, lang: "en", region: "us",
    top-edge: top-edge, bottom-edge: bottom-edge, costs: (hyphenation: 200%))
  set par(justify: true, leading: leading-for("normal"), spacing: par-spacing,
    justification-limits: (tracking: (min: -0.012em, max: 0.012em)))
  set page(paper: "a4", margin: 21mm, numbering: "i",
    header-ascent: 25.16pt, footer-descent: 29.89pt - 0.712 * sizes.small,
    header: context {
      let pg = here().page()
      if query(<utp-plain>).any(m => m.location().page() == pg) { return }
      if query(<utp-empty>).any(m => m.location().page() == pg) { return }
      let marks = query(<utp-mark>).filter(m => m.location().page() <= pg)
      set text(size: sizes.small, fill: muted)
      set par(justify: false)
      block(above: 0pt, below: 0pt, grid(columns: (auto, 1fr), align: (left, right),
        o.running-head, if marks.len() > 0 { marks.last().value }))
      block(above: 13.3pt - 0.2 * sizes.small, below: 0pt, line(length: 100%, stroke: 0.5pt + pale-blue))
    },
    footer: context {
      let pg = here().page()
      if query(<utp-empty>).any(m => m.location().page() == pg) { return }
      align(center, text(size: sizes.small, fill: muted, counter(page).display()))
    })

  // Headings. Level 1 is a Stage (\part), 2 a chapter, 3 a section and 4 a
  // subsection; content files write `=` for a chapter. Stages are not
  // numbered headings, so chapter numbers run on through the book.
  set heading(offset: 1, supplement: none, numbering: (..n) => {
    let n = n.pos().slice(1)
    n.map(str).join(".")
  })
  show heading.where(level: 1): none
  show heading.where(level: 2): it => {
    if it.numbering == none { return none }
    pagebreak(weak: true)
    plain-page
    let number = counter(heading).display(it.numbering)
    toc-entry("chapter", it.body, number: number)
    mark(it.body)
    counter(figure.where(kind: "utpfig")).update(0)
    counter(math.equation).update(0)
    block(above: 0pt, below: after-chapter, {
      chapter-badge(number)
      block(above: 35.01pt - 1.68pt - 0.712 * sizes.Huge, below: 0pt, chapter-title(it.body))
    })
  }
  let keep(level) = if o.keep-headings != none { keepspace(o.keep-headings.at(level - 3)) }
  show heading.where(level: 3): it => keep(3) + block(above: 24.62pt, below: 12.73pt, sticky: true, {
    set text(size: sizes.Large, weight: "bold", fill: navy, hyphenate: false)
    set par(justify: false, leading: leading-for("Large"))
    if it.numbering != none {
      counter(heading).display(it.numbering)
      h(0.55 * em-normal)
    }
    it.body
  })
  show heading.where(level: 4): it => keep(4) + block(above: 19.61pt, below: 11.57pt, sticky: true, {
    set text(size: sizes.large, weight: "bold", fill: blue, hyphenate: false)
    set par(justify: false, leading: leading-for("large"))
    if it.numbering != none {
      counter(heading).display(it.numbering)
      h(0.5 * em-normal)
    }
    it.body
  })
  show heading.where(level: 5): it => block(above: 17pt, below: 9.6pt, sticky: true,
    text(weight: "bold", it.body))

  // A reference to a figure shows the chapter the figure is in (the numbering
  // alone would take the chapter of the page that cites it).
  show ref: it => {
    let el = it.element
    if el == none or el.func() != figure or el.kind != "utpfig" { return it }
    let loc = el.location()
    let chapter = counter(heading).at(loc).at(1, default: 0)
    let n = counter(figure.where(kind: "utpfig")).at(loc).first()
    link(loc, if chapter > 0 [#chapter.#n] else [#n])
  }

  // Lists, as enumitem set them.
  set list(indent: 7.1pt, body-indent: 5.45pt, marker: ([•], [–], [∗], [·]),
    spacing: skips.normal + 6.88pt - line-box * sizes.normal)
  show list: set block(above: 12.33pt, below: 12.33pt)
  set enum(indent: 6.9pt, body-indent: 5.45pt, number-align: end + top,
    spacing: skips.normal + 7.53pt - line-box * sizes.normal)
  show enum: set block(above: 12.33pt, below: 12.33pt)
  // description lists: each item its own paragraph, the label in bold navy,
  // \itemsep plus \parsep between items
  // (topsep 0.3em above and below the list)
  let item-gap = skips.normal + 7.21pt - line-box * sizes.normal
  set terms(separator: [ ], hanging-indent: 0pt, spacing: item-gap)
  show terms: it => block(above: 12.88pt, below: 12.88pt, {
    for item in it.children {
      block(above: item-gap, below: item-gap, {
        text(weight: "bold", fill: navy, item.term)
        [ ]
        item.description
      })
    }
  })

  // Display maths and inline code.
  show math.equation.where(block: true): set block(above: 8pt, below: 8pt)
  // Typst sets raw text at 0.8em; LaTeX scaled the mono face to 0.88 (or 1.02).
  show raw: set text(font: o.mono, size: mono-size / 0.8 * 1em)
  show raw.where(block: true): it => show-listing(it, mono: o.mono, scale: mono-size)
  set raw(theme: "listings.tmTheme", tab-size: 4)

  // Numbered figures with their caption inside the frame.
  show figure.where(kind: "utpfig"): show-utpfig

  config.update(o)
  body
}

// ------------------------------------------------------------ stage pages
// \part: a Stage page with the title near the top and a teal rule.
#let part(title) = {
  pagebreak(weak: true)
  part-counter.step()
  context toc-entry("part", title, number: [Stage #part-counter.get().first()])
  plain-page
  bookmark(1, title)
  context {
    let n = part-counter.get().first()
    set align(center)
    set par(justify: false)
    v(34.89pt - 0.712 * sizes.Large)
    block(above: 0pt, below: 0pt, text(size: sizes.Large, weight: "bold", fill: teal)[Stage #n])
    block(above: 40.80pt - 0.2 * sizes.Large - 0.712 * sizes.Huge, below: 0pt,
      text(size: sizes.Huge, weight: "bold", fill: navy, hyphenate: false, title))
    block(above: 48.02pt - 0.2 * sizes.Huge, below: 0pt, width: 45%, height: 1.5pt, fill: teal)
  }
  pagebreak()
}

// \substage{3A}{title}{summary}: an unnumbered page, listed with the chapters.
#let substage(number, title, summary) = {
  pagebreak(weak: true)
  empty-page
  toc-entry("chapter", [Stage #number --- #title])
  bookmark(2, [Stage #number --- #title])
  set align(center)
  set par(justify: false)
  v(0.2 * 722.83pt + 9.31pt - 0.712 * sizes.Large)
  block(above: 0pt, below: 0pt, text(size: sizes.Large, weight: "bold", fill: teal)[Stage #number])
  block(above: 0.45 * em-normal + skips.Huge - 0.2 * sizes.Large - 0.712 * sizes.Huge, below: 0pt,
    text(size: sizes.Huge, weight: "bold", fill: navy, hyphenate: false, title))
  block(above: 0.65 * em-normal + 4.96pt, below: 0pt, width: 46%, height: 1.5pt, fill: teal)
  block(above: 1.1 * em-normal + 3pt, width: 76%, {
    set text(size: sizes.large, fill: muted)
    set par(leading: leading-for("large"))
    summary
  })
  pagebreak()
}

// \chapter*: a chapter without a number (course map, appendix openings).
#let chapter-star(title, toc: true) = {
  pagebreak(weak: true)
  plain-page
  if toc { toc-entry("chapter", title) }
  mark(title)
  bookmark(2, title)
  block(above: 0pt, below: after-chapter, {
    v(27.21pt - 0.712 * sizes.Huge)
    chapter-title(title)
  })
}

// ---------------------------------------------------------- contents page
// tocloft's dotted leader, then the page number flush right in its own box.
#let leader(shown, color: ink, box-width: 21.4pt) = {
  h(4pt)
  box(width: 1fr, text(fill: color, weight: "regular", repeat(gap: 0.5em, justify: false)[.]))
  box(width: box-width, align(right, shown))
}

#let contents() = context {
  let c = cfg("contents")
  let o = config.get()
  let base = c.size
  pagebreak(weak: true)
  plain-page
  mark([Learning Path])
  block(above: 0pt, below: 44.16pt, {
    v(79.34pt - 0.712 * sizes.Huge)
    text(size: sizes.Huge, weight: "bold", fill: ink)[Learning Path]
  })
  set text(size: sizes.at(base))
  set par(justify: false, leading: leading-for(base))
  let gap = skips.at(base) - line-box * sizes.at(base)
  let lab-color = mix(orange, 90%, other: black)
  let lab-leader = mix(orange, 65%, other: muted)
  for e in query(<utp-toc>) {
    let v = e.value
    let loc = e.location()
    let n = counter(page).at(loc).first()
    let pattern = loc.page-numbering()
    let shown = if pattern == none { str(n) } else { numbering(pattern, n) }
    if v.kind == "part" {
      block(above: gap - 0.3pt + c.part, below: 0pt, link(loc, {
        set text(size: sizes.at(c.part-size), weight: "bold", fill: navy)
        box(width: 50pt, v.number)
        v.title
        h(1fr)
        shown
      }))
    } else if v.kind == "chapter" {
      block(above: gap + c.chapter, below: 0pt, link(loc, {
        h(o.chapter-toc-indent)
        if v.number != none {
          box(width: o.chapter-toc-numwidth, [#o.chapter-toc-word~#v.number])
        }
        v.title
        leader(shown)
      }))
    } else if v.kind == "lab" {
      block(above: gap + c.lab, below: 0pt, link(loc, {
        set text(weight: "bold", fill: lab-color)
        h(3 * em-normal)
        v.title
        leader(shown, color: lab-leader, box-width: 29.6pt)
      }))
    }
  }
}

// After the front matter: chapter one opens on an arabic page 1.
#let mainmatter(body) = {
  pagebreak(weak: true)
  set page(numbering: "1")
  counter(page).update(1)
  body
}
