// Algorithms & Data Structures: the book. Settings first, then the chapters and labs in teaching order.
#import "/.shared/typst/utp.typ": *
#show: book.with(
  title: [Algorithms & Data Structures],
  outline: [C++ examples, guided laboratories, and comparative projects connect \
 data-structure choices with correctness and performance.],
  lab-total: 11,
  contents: (part: 0.98em, chapter: 0.32em, lab: 0.38em),
  listing: "cpp",
  diagram-size: (1.05, 0.85),
)
#cover()
#contents()
#include "chapters/course-map.typ"
#show: mainmatter

#include "chapters/00-toolkit.typ"

#part[Foundations]
#include "chapters/01-introduction.typ"
#include "labs/01-foundations.typ"

#include "chapters/02-arrays.typ"
#include "labs/02-arrays.typ"

#part[Linear Dynamic Structures]
#include "chapters/03-linked-lists.typ"
#include "labs/03-linked-lists.typ"
#include "chapters/04-circular-linked-list.typ"
#include "labs/04-circular-list.typ"
#include "chapters/05-stacks.typ"
#include "labs/05-stacks.typ"
#include "chapters/06-queues.typ"
#include "labs/06-queues.typ"

#part[Trees and Hierarchies]
#include "chapters/07-trees-i.typ"
#include "labs/07-trees-i.typ"
#include "chapters/08-trees-ii.typ"
#include "labs/08-trees-ii.typ"

#part[Graphs and Traversal]
#include "chapters/09-graphs.typ"
#include "labs/09-graphs.typ"

#part[Core Algorithms and Fast Access]
#include "chapters/10-searching-sorting.typ"
#include "labs/10-searching-sorting.typ"
#include "chapters/11-hashing.typ"
#include "labs/11-hashing.typ"

#part[Course Project and Synthesis]
#include "chapters/12-final-project.typ"
