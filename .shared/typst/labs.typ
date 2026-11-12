// Lab sheets: labs/layout.tex, labs/activities.tex and the lab boxes.
//
//   #labsection(1, label: <sec:lab01>)[Feature engineering]   the banner
//   #labquestion(3)[Read the data card][...]                  a question
//   #labanswer[... #expectedoutput ...]                       its worked answer
//   #labroadmap([Your map of this lab], ..rows)               the map of the parts
//   #labpartopen([Part A], [Title], [Questions 2--4], [Goal.]) a part banner
#import "palette.typ": *
#import "theme.typ": *
#import "state.typ": *
#import "boxes.typ": *
#import "tables.typ": tabularx, tabcolsep, rule-color, stripe-fill

// \labsection{n}{title}{label}: a new page, the navy banner, a contents entry.
#let labsection(number, title, label: none) = {
  pagebreak(weak: true)
  context {
    let full = [Lab #number of #cfg("lab-total") --- #title]
    toc-entry("lab", full)
    mark(full)
    bookmark(1, full)
    if label != none { [#metadata((kind: "lab", number: number))#label] }
  }
  block(width: 100%, fill: navy, radius: 2mm, above: 0pt, below: 13.87pt, breakable: false,
    inset: (x: 5mm + 1mm, top: 25.10pt - 0.712 * sizes.large, bottom: 20.08pt - 0.2 * sizes.Large), {
      set par(justify: false)
      block(above: 0pt, below: 0pt,
        text(size: sizes.large, weight: "bold", fill: mix(teal, 35%))[PRACTICAL MILESTONE])
      block(above: 32.61pt - 0.2 * sizes.large - 0.712 * sizes.Huge, below: 0pt,
        text(size: sizes.Huge, weight: "bold", fill: white)[Lab #number of #context cfg("lab-total")])
      block(above: 20.12pt - 0.2 * sizes.Huge - 0.712 * sizes.Large, below: 0pt, {
        set par(leading: leading-for("Large"))
        text(size: sizes.Large, weight: "bold", fill: white, title)
      })
    })
}

// \labflow{chapter connection}{goal}{explain}: the brief under a lab title.
#let labflow(connection, goal, explain) = {
  v(3pt)
  [*Chapter connection.* #connection]
  parbreak()
  [*Goal.* #goal]
  parbreak()
  [*Explain.* #explain]
  parbreak()
  v(6pt)
}

// \labsourcecard{file}{what it does}{what to inspect}: the heading over a listing.
#let labsourcecard(file, what, inspect) = {
  v(6pt)
  [*#file --- #what*]
  parbreak()
  [*Inspect.* #inspect]
  parbreak()
  v(3pt)
}

// A question as the student meets it, and its worked answer.
#let labquestion(number, title, body) = tcb(body, title: [Question #number --- #title],
  back: mix(pale-orange, 55%), frame: orange, left: 2.6mm, right: 2.6mm)
#let labanswer(body) = tcb(body, title: [Worked answer], back: white, frame: teal,
  left: 2.6mm, right: 2.6mm)

// \expectedoutput: the label over a printed output, kept with it.
#let expectedoutput = block(above: 3pt + par-spacing, below: par-spacing, sticky: true,
  text(weight: "bold", fill: navy)[Reference output.])

// \begin{refoutput}: "Reference output." and the output stay on one page.
#let refoutput(body) = block(breakable: false, width: 100%, above: par-spacing, below: par-spacing, {
  expectedoutput
  body
})

// Answers to a quick check, and the findings a lab expects.
#let checkanswers = callout([Quick-check answers], mix(pale-gray, 72%), mix(muted, 62%),
  rule: 0.65pt, left: 2.5mm, right: 2.5mm, top: 1.6mm, bottom: 1.6mm, title-back: muted)
#let expectedfindings = callout([Expected findings], mix(pale-gray, 72%), mix(muted, 62%),
  rule: 0.65pt, left: 2.5mm, right: 2.5mm, top: 1.6mm, bottom: 1.6mm, title-back: muted)
#let yourturn = callout([Your turn], white, teal, rule: 0.9pt)
#let labcheckpoint(body) = tcb(body, title: [Checkpoint: before you move on],
  back: mix(pale-teal, 65%), frame: green, left: 2.6mm, right: 2.6mm,
  breakable: false, above: 1.2 * em-normal)

// \labpart{title} and \labsubhead{title}: a blue band inside a lab sheet.
#let labpart(title) = {
  keepspace(11 * skips.normal)
  block(above: 6pt + par-spacing, below: 3pt + par-spacing, sticky: true,
    text(size: sizes.large, weight: "bold", fill: blue, title))
}
#let labsubhead(title) = {
  keepspace(9 * skips.normal)
  block(above: 6pt + par-spacing, below: 3pt + par-spacing, sticky: true,
    text(size: sizes.large, weight: "bold", fill: blue, title))
}

// \labroadmap{title}{rows}: the map of a lab's parts, before the first question.
#let labroadmap(title, ..rows) = tcb(title: title, frame: navy, rule: 0.7pt,
  top: 1.4mm, bottom: 1.4mm, breakable: false, {
    set text(size: sizes.small)
    set par(leading: leading-for("small"), justify: false)
    let cells = rows.pos()
    let n-rows = calc.ceil(cells.len() / 3)
    table(
      columns: (1.35cm + tabcolsep, 1fr, 1.55cm + tabcolsep),
      stroke: none,
      inset: (x, y) => (
        left: if x == 0 { 0pt } else { tabcolsep },
        right: if x == 2 { 0pt } else { tabcolsep },
        top: 3.4pt, bottom: 1.8pt),
      align: (x, y) => (if x == 2 { right } else { left }) + top,
      fill: (x, y) => if y >= 2 and calc.even(y) { stripe-fill } else { none },
      table.header(
        text(weight: "bold", fill: muted)[Part],
        text(weight: "bold", fill: muted)[What you do],
        text(weight: "bold", fill: muted)[Questions],
      ),
      table.hline(stroke: 0.4pt + rule-color),
      ..cells.enumerate().map(((i, c)) => if calc.rem(i, 3) == 0 { text(weight: "bold", fill: navy, c) } else { c }),
    )
  })

// \labpartopen{Part A}{title}{meta}{goal}: a part banner, on a new page
// unless most of this one is still free.
#let labpartopen(part, title, meta, goal) = {
  v(12pt)
  keepspace(0.6 * 722.83pt)
  tcb(title: [#part#h(0.55em)#text(fill: mix(teal, 45%))[|]#h(0.55em)#title],
    title-font: (size: sizes.large), back: pale-blue, frame: navy,
    left: 3mm, right: 3mm, top: 2mm, bottom: 2mm, breakable: false,
    above: 0pt, below: 1 * em-normal, {
      [#text(weight: "bold", fill: navy)[Goal.] #goal]
      parbreak()
      v(3pt)
      text(size: sizes.small, fill: muted, meta)
    })
}

// \begin{labchecklists}: the two checklists stay together on one page.
#let labchecklists(body) = block(breakable: false, width: 100%, body)

// \begin{utpsteps}: a numbered list labelled Step 1:, Step 2:, ...
#let utpsteps(body) = context {
  let marker(n) = text(fill: blue, weight: "bold")[Step~#n:]
  let width = measure(marker(8)).width
  set enum(numbering: marker, number-align: end + top, indent: 4.5 * em-normal - 5.45pt - width,
    body-indent: 5.45pt, spacing: skips.normal + 0.38 * em-normal + 4.48pt - line-box * sizes.normal)
  body
}

// \labroutine: the four steps every notebook question follows.
#let labroutine = context {
  v(3pt)
  [*How to work through this sheet.* #cfg("routine-intro")]
  utpsteps[
    + *Predict.* Read the task and write down what you expect before running anything.
    + *Run.* Run the matching cell in the notebook. The listing printed under the question is that same code, so you can read it here and run it there.
    + *Compare.* #cfg("routine-compare")
    + *Explain.* Add a Markdown cell saying what the result means, in your own words. Where your first prediction was wrong, say why.
  ]
  v(3pt)
}

// Lab~\ref{sec:lab03}: the number of the lab whose banner carries the label.
#let labref(target) = context {
  let found = query(target)
  if found.len() == 0 { return [??] }
  link(target, str(found.first().value.number))
}
