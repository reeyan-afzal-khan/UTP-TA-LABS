// Course title: the book. Settings first, then the chapters and labs in teaching order.
#import "/.shared/typst/utp.typ": *
#show: book.with(
  title: [Course title],
  running-head: [Course title Notes],
  outline: [Describe the learning outcomes and practical work.],
  lab-total: 1,
)
#cover()
#contents()
#show: mainmatter

#part[Foundations]
// Create these files before enabling the includes. Each starts with
//   #import "/.shared/typst/utp.typ": *
//   #unit("chapters", "01-introduction")     (or "labs")
// #include "chapters/01-introduction.typ"
// #include "labs/01-introduction.typ"
