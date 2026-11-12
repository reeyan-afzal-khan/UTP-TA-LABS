// The learning boxes of style/boxes.tex, one function per tcolorbox, with the
// shared defaults applied (\utpheavycallouts, \utpbreakableframes and the
// navy \utplabprojectcolour). Each takes the same arguments as its LaTeX
// environment: \begin{labproject}{Title} ... is #labproject[Title][...].
#import "palette.typ": *
#import "theme.typ": *
#import "state.typ": config, cfg

#let boxsep = 1mm

// Spacing around a box, from the LaTeX pages: a box after a paragraph starts
// 10.84pt below its baseline; the next baseline sits 16.26pt below the box.
#let box-above = 10.84pt - 0.2 * sizes.normal
#let box-below = 16.26pt - 0.712 * sizes.normal

// Two boxes back to back sit closer than a box and a paragraph: LaTeX leaves
// 6.8pt between them, and 12pt when one of them is a numbered figure. Each box
// looks up, from the previous layout pass, whether the last box ended right
// above it (nothing but the spacing between them), and if so takes that gap.
#let stacked-gap = (box: 6.8pt, figure: 12pt)
#let _stacked(kind) = context {
  let starts = query(selector(<utp-box-start>).after(here()))
  let ends = query(selector(<utp-box-end>).before(here()))
  if starts.len() == 0 or ends.len() == 0 { return }
  let prev = ends.last()
  if prev.value == none { return }
  let (s, e) = (starts.first().location().position(), prev.location().position())
  if s.page == e.page and s.y - e.y < 25pt {
    v(if "figure" in (kind, prev.value) { stacked-gap.figure } else { stacked-gap.box }, weak: true)
  }
}

// One tcolorbox. `frame` is colframe, `back` colback, `title-back` colbacktitle
// (none shows the frame colour, as the quiet boxes do), `title-color` the
// fonttitle colour, and left/right/top/bottom the tcolorbox paddings. `kind`
// says how it stacks under another box ("box", "figure"; none for boxes with
// spacing of their own).
#let tcb(
  body,
  title: none,
  back: white,
  frame: blue,
  rule: 0.8pt,
  arc: 2mm,
  left: 2.5mm,
  right: 2.5mm,
  top: 1.8mm,
  bottom: 1.8mm,
  title-back: none,
  title-color: white,
  title-font: (:),
  breakable: true,
  above: box-above,
  below: box-below,
  width: 100%,
  height: auto,
  valign: top,
  centered: false,
  text-color: black,
  kind: auto,
) = {
  let kind = if kind != auto { kind } else if above == box-above and below == box-below { "box" } else { none }
  if kind != none { _stacked(kind) }
  block(width: width, height: height, breakable: breakable, above: above, below: below,
  fill: frame, radius: arc, inset: rule, {
    [#metadata(none)<utp-box-start>]
    if title != none {
      block(width: 100%, fill: title-back, sticky: true, above: 0pt, below: rule,
        radius: (top-left: arc - rule, top-right: arc - rule),
        inset: (left: left + boxsep, right: right + boxsep, y: boxsep), layout(size => {
          set par(justify: false)
          set align(std.left)
          set text(weight: "bold", fill: title-color, ..title-font)
          // TeX sizes a one-line title bar by the title's own glyphs
          if measure(block(width: size.width, title)).height < 1.5em.to-absolute() {
            text(top-edge: "bounds", bottom-edge: "bounds", title)
          } else { title }
        }))
    }
    block(width: 100%, height: if height == auto { auto } else { 1fr }, fill: back,
      breakable: breakable, above: 0pt, below: 0pt,
      radius: if title == none { arc - rule } else { (bottom-left: arc - rule, bottom-right: arc - rule) },
      inset: (left: left + boxsep, right: right + boxsep, top: top + boxsep, bottom: bottom + boxsep), {
        // A tcolorbox sets its content like a minipage: no \parskip.
        set par(spacing: leading-for("normal"))
        set text(fill: text-color)
        set align(valign)
        if centered { set align(center); body } else { body }
      })
  })
  [#metadata(kind)<utp-box-end>]
}

// Titles a course may rename in main.typ: titles: (labmode: [Lab setup]).
#let default-titles = (
  keyidea: [Key idea],
  worked: [Worked example],
  pitfall: [Common mistake],
  tryit: [Try it yourself],
  quickcheck: [Check your understanding],
  recap: [Chapter recap],
  deliverable: [Lab deliverable],
  labmode: [How much is scaffolded?],
  intuition: [Plain idea],
  firstread: [Core path],
  glance: [Chapter at a glance],
  debug: [Debugging task],
  optional: [Beyond the core],
  verification: [Verification checklist],
  troubleshoot: [Troubleshooting],
  sourcebasis: [Source basis],
  application: [Application walkthrough],
)
#let box-title(key) = cfg("titles").at(key, default: default-titles.at(key))

// A callout: a tinted box under a solid title bar, for something to act on.
#let callout(key-or-title, back, frame, rule: 0.8pt, left: 2.6mm, right: 2.6mm,
  top: 1.8mm, bottom: 1.8mm, title-back: none, ..rest) = body => context tcb(body,
  title: if type(key-or-title) == str { box-title(key-or-title) } else { key-or-title },
  back: back, frame: frame, rule: rule, left: left, right: right, top: top, bottom: bottom,
  title-back: title-back, ..rest)

// A quiet box: a light frame with coloured title text, for an aside.
#let quiet(key-or-title, frame, title-color, back: white, rule: 0.5pt, top: 1.5mm, bottom: 1.5mm, ..rest) = body => context tcb(body,
  title: if type(key-or-title) == str { box-title(key-or-title) } else { key-or-title },
  back: back, frame: frame, rule: rule, left: 2.5mm, right: 2.5mm, top: top, bottom: bottom,
  title-color: title-color, ..rest)

// Explaining an idea
#let keyidea = callout("keyidea", pale-teal, teal, rule: 0.85pt, left: 2.5mm, right: 2.5mm)
#let workedexample = callout("worked", pale-blue, blue, left: 2.5mm, right: 2.5mm)
#let pitfall = callout("pitfall", pale-red, red, left: 2.5mm, right: 2.5mm, title-color: navy)
// Asking the reader to do something
#let tryit = callout("tryit", white, teal, rule: 0.9pt, left: 2.5mm, right: 2.5mm)
#let quickcheck = callout("quickcheck", white, orange, rule: 0.9pt, left: 2.5mm, right: 2.5mm)
#let chapterrecap = callout("recap", pale-teal, green, rule: 0.9pt, left: 2.5mm, right: 2.5mm)
// Lab structure
#let labdeliverable = callout("deliverable", white, green, rule: 0.9pt, top: 1.9mm, bottom: 1.9mm)
#let labmode = callout("labmode", mix(pale-blue, 52%), blue, rule: 0.75pt, top: 1.7mm, bottom: 1.7mm)
// Softer asides
#let intuition = callout("intuition", pale-orange, orange, left: 2.5mm, right: 2.5mm)
#let firstread = callout("firstread", white, blue, rule: 0.9pt, left: 2.5mm, right: 2.5mm)
#let debugtask = callout("debug", mix(pale-red, 58%), red, rule: 0.85pt, top: 1.9mm, bottom: 1.9mm)
#let analogy = quiet([Analogy], mix(orange, 38%), mix(orange, 85%, other: black))
#let coursechoice = callout([Course choice], white, navy, left: 2.8mm, right: 2.8mm, top: 2mm, bottom: 2mm)
#let decisionmemo = callout([Decision memo], mix(pale-orange, 55%), orange, rule: 0.85pt, top: 1.9mm, bottom: 1.9mm)
#let libnote = quiet([Reference note], mix(muted, 48%), navy)
#let miniproject = callout([Mini-project], mix(pale-teal, 52%), green, rule: 0.9pt, top: 1.9mm, bottom: 1.9mm)
#let sourcebasis = quiet("sourcebasis", mix(muted, 55%), muted)
#let optionaltopic = quiet("optional", mix(muted, 58%), muted)
#let secondpass = callout([Second pass], mix(pale-gray, 82%), muted, rule: 0.75pt, top: 1.9mm, bottom: 1.9mm)
#let verification = callout("verification", mix(pale-teal, 65%), green)
#let troubleshoot = callout("troubleshoot", mix(pale-orange, 70%), orange)
// Boxes that take a title
#let modelcard(title, body) = tcb(body, title: title, back: white, frame: blue, rule: 0.9pt)
#let labproject(title, body) = tcb(body, title: title, back: white, frame: navy, rule: 0.9pt,
  left: 2.7mm, right: 2.7mm, top: 2mm, bottom: 2mm)
#let sourcealignment(title, body) = tcb(body, title: title, frame: mix(muted, 55%), rule: 0.5pt,
  top: 1.5mm, bottom: 1.5mm, title-color: muted)
// Further shared teaching boxes
#let clarification = quiet([Clarification], mix(blue, 42%), blue)
#let projectrequirement = callout([Project requirement], pale-blue, blue)
#let recommendedworkflow = callout([Recommended workflow], pale-teal, teal)
#let conceptmap = quiet([Concept map], mix(blue, 55%), navy, back: mix(pale-blue, 45%), rule: 0.7pt,
  top: 1.8mm, bottom: 1.8mm)
#let referencebox = quiet([Reference note], mix(muted, 58%), muted)
#let applicationbox(body) = context {
  let style = cfg("titles").at("application-style", default: none)
  if style == "teal" {
    tcb(body, title: box-title("application"), back: pale-teal, frame: teal, rule: 0.75pt,
      left: 2.6mm, right: 2.6mm)
  } else {
    tcb(body, title: box-title("application"), back: white, frame: blue, rule: 0.9pt,
      left: 2.6mm, right: 2.6mm, top: 1.9mm, bottom: 1.9mm)
  }
}

// The box that opens a chapter.
#let chapterguide(before, after) = context tcb(title: box-title("glance"), frame: navy, top: 2mm, bottom: 2mm, [
  *Before you start:* #before

  *By the end, you can:* #after
])

// A box with explicit tcolorbox options, for \begin{tcolorbox}[...].
#let tcolorbox = tcb
