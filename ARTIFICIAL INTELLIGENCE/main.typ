// Artificial Intelligence: the book. Settings first, then the chapters and labs in teaching order.
#import "/.shared/typst/utp.typ": *
#show: book.with(
  title: [Artificial Intelligence],
  running-head: [Artificial Intelligence Notes],
  outline: [Eight laboratory-guided modules covering search, fuzzy systems, robotics, #parbreak() natural language processing, and optimization, closing with game search.],
  lab-total: 8,
  contents: (part: 1.15em, chapter: 0.40em, lab: 0.50em),
  routine-compare: [Check your output against the reference output. Runtimes will differ; counts, costs and routes should not.],
)
#cover()
#contents()
#include "chapters/course-map.typ"
#show: mainmatter

#include "chapters/00-toolkit.typ"

#part[Search and Problem Solving]
#include "chapters/01-uninformed-search.typ"
#include "labs/01-search-foundations.typ"

#include "chapters/02-informed-search.typ"
#include "labs/02-informed-search.typ"
#include "chapters/03-search-implementation-patterns.typ"
#include "labs/03-search-consolidation.typ"

#part[Approximate Reasoning and Intelligent Control]
#include "chapters/04-fuzzy-logic-and-anfis.typ"
#include "labs/04-fuzzy-anfis.typ"
#include "chapters/05-robotics-scenarios.typ"
#include "labs/05-robotics.typ"

#part[Language Intelligence]
#include "chapters/06-nlp-foundations.typ"
#include "labs/06-nlp-part-a.typ"
#include "chapters/08-nlp-methods.typ"
#include "labs/07-nlp-part-b.typ"

#part[Local Search and Evolutionary Optimization]
#include "chapters/09-local-search.typ"
#include "chapters/10-genetic-algorithms.typ"
#include "labs/08-genetic-algorithms.typ"

#part[Adversarial Search]
#include "chapters/11-adversarial-search.typ"
