// The three callouts: the only framed asides in the books.
//
//   #note[...]      amber   something important to keep in mind
//   #tip[...]       green   practical advice: a shortcut, a better way, a fix
//   #warning[...]   red     a common mistake, or a step that breaks or loses work
//
// Each is a tinted panel with a coloured bar down its left side and its label
// in a small tab on the top edge. Colours are `callout-colors` in palette.typ;
// sizes and spacing are `callout-style` below. A course can rename a label in
// its main.typ, for example  titles: (note: [Remember]).
#import "palette.typ": *
#import "theme.typ": *
#import "state.typ": cfg

#let callout-labels = (note: [Note], tip: [Tip], warning: [Warning])

#let callout-style = (
  bar: 3pt,                                    // the bar down the left side
  radius: 1.6mm,                               // the panel's corners
  inset: (left: 4.4mm, right: 4mm, bottom: 2.6mm),
  tab-gap: 2.1mm,                              // from the tab to the first line
  tab-left: 3.4mm,                             // from the panel's left edge to the tab
  above: 11pt,                                 // to the text above (plus half the tab)
  below: 11pt,                                 // to the text below
  spacing: 7pt,                                // between paragraphs inside
)

// The label tab: white bold text on the accent colour.
#let callout-tab(kind) = context box(fill: callout-colors.at(kind).accent, radius: 1mm,
  inset: (x: 2mm, y: 1.2mm),
  text(size: sizes.small, weight: "bold", fill: white, top-edge: "cap-height", bottom-edge: "baseline",
    cfg("titles").at(kind, default: callout-labels.at(kind))))

#let callout(kind, body) = context {
  let colors = callout-colors.at(kind)
  let s = callout-style
  let tab = callout-tab(kind)
  let half = measure(tab).height / 2
  let pad-top = half + s.tab-gap
  block(width: 100%, breakable: true, above: s.above + half, below: s.below,
    fill: colors.fill, stroke: (left: s.bar + colors.accent), radius: s.radius,
    inset: (left: s.inset.left, right: s.inset.right, top: pad-top, bottom: s.inset.bottom), {
      place(top + left, dx: s.tab-left - s.inset.left, dy: -pad-top - half, tab)
      set par(spacing: s.spacing)
      show list: set block(above: s.spacing, below: s.spacing)
      show enum: set block(above: s.spacing, below: s.spacing)
      show terms: set block(above: s.spacing, below: s.spacing)
      body
    })
}

#let note(body) = callout("note", body)
#let tip(body) = callout("tip", body)
#let warning(body) = callout("warning", body)
