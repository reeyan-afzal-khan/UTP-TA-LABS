#import "/.shared/typst/utp.typ": *
#let title = [Course title]
#let summary = [Describe the learning outcomes and practical work.]
#show: book.with(title: title, summary: summary, lab-total: 1)

#cover(title: title, summary: summary)
#outline(depth: 1)
#pagebreak()

#stage[Foundations]
// Create these files before enabling the includes.
// #include "chapters/01-introduction.typ"
// #include "labs/01-introduction.typ"
