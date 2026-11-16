// Teaching elements without a frame. Each prints a short bold label and then
// its content as ordinary text, so that only the three callouts of
// callouts.typ (Note, Tip, Warning) are framed.
//
//   #chapterguide[what to know first][what you can do by the end]   opens a chapter
//   #example[...]                  a worked example; "Example." runs into its first line
//   #exercises[...]                tasks for the reader to do
//   #questions[...]                review questions
//   #answers[...]                  answers to the questions or exercises just above
//   #summary[...]                  what to carry forward from the chapter
//   #checklist[...]                points to check finished work against
//   #checklist(title: [...])[...]  the same under a title of its own
//   #submission[...]               what to hand in
//   #element-head([Title])         the same bold label alone, for a course's own
//                                  titled elements (such as ML's recipe cards)
//
// A course renames a label in its main.typ, for example
//   titles: (questions: [Self-check], answers: [Self-check answers])
#import "palette.typ": *
#import "theme.typ": *
#import "state.typ": cfg

#let element-labels = (
  before: [Before you start:],
  after: [By the end, you can:],
  example: [Example.],
  exercises: [Exercises],
  questions: [Review questions],
  answers: [Answers],
  summary: [Summary],
  checklist: [Checklist],
  submission: [Submission],
  // lab sheets (labs.typ)
  setup: [Setup],
  solution: [Solution],
  checkpoint: [Checkpoint],
)
#let element-label(key) = cfg("titles").at(key, default: element-labels.at(key))

// The label over an element, kept on the page with the element's first line.
#let element-head(title, size: "large", color: navy, above: 1.45em, below: 0.6em) = block(
  above: above, below: below, sticky: true, {
    set par(justify: false, leading: leading-for(size))
    text(size: sizes.at(size), weight: "bold", fill: color, title)
  })

// A labelled element: its head, then its body as ordinary text.
#let element(key, body, title: auto) = {
  element-head(if title == auto { context element-label(key) } else { title })
  body
}

#let exercises(body) = element("exercises", body)
#let questions(body) = element("questions", body)
#let answers(body) = element("answers", body)
#let summary(body) = element("summary", body)
#let checklist(body, title: auto) = element("checklist", body, title: title)
#let submission(body) = element("submission", body)

// A worked example: the label runs into the example's first line.
#let example(body) = [#context text(weight: "bold", fill: navy, element-label("example")) #body]

// The opening of a chapter: what to know first, and what the reader can do by
// the end. A hairline separates it from the chapter's first section.
#let chapterguide(before, after) = block(width: 100%, above: 0pt, below: 1.5em, {
  [#context text(weight: "bold", fill: navy, element-label("before")) #before]
  parbreak()
  [#context text(weight: "bold", fill: navy, element-label("after")) #after]
  block(above: 1.1em, below: 0pt, line(length: 100%, stroke: 0.6pt + mix(blue, 30%)))
})
