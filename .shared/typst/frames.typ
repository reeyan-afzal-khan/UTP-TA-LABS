// Frames: the one framing primitive behind figure frames, table frames and
// device transcripts (style/boxes.tex's tcolorbox). Teaching asides do not
// use it: they are the Note, Tip and Warning callouts of callouts.typ.
#import "palette.typ": *
#import "theme.typ": *
#import "state.typ": config, cfg

#let boxsep = 1mm

// Spacing around a frame, from the LaTeX pages: a frame after a paragraph
// starts 10.84pt below its baseline; the next baseline sits 16.26pt below it.
#let box-above = 10.84pt - 0.2 * sizes.normal
#let box-below = 16.26pt - 0.712 * sizes.normal

// Two frames back to back sit closer than a frame and a paragraph: LaTeX leaves
// 6.8pt between them, and 12pt when one of them is a numbered figure. Each frame
// looks up, from the previous layout pass, whether the last frame ended right
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
// (none shows the frame colour), `title-color` the fonttitle colour, and
// left/right/top/bottom the tcolorbox paddings. `kind` says how it stacks under
// another frame ("box", "figure"; none for frames with spacing of their own).
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

// A frame with explicit tcolorbox options, for one-off layouts such as the
// operating-system cards of the Git setup chapter: \begin{tcolorbox}[...].
#let tcolorbox = tcb
