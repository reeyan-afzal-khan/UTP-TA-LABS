#import "/.shared/typst/utp.typ": *
#show: book.with(title: [Algorithms & Data Structures], summary: [C++ examples, guided laboratories, and comparative projects connect \
data-structure choices with correctness and performance.], lab-total: 11)

#cover(title: [Algorithms & Data Structures], summary: [C++ examples, guided laboratories, and comparative projects connect \
data-structure choices with correctness and performance.])
#outline(depth: 1)
#pagebreak()
#include "chapters/course-map.typ"

#include "/ALGORITHMS & DATA STRUCTURES/chapters/00-toolkit.typ"


#stage[Foundations] 
#include "/ALGORITHMS & DATA STRUCTURES/chapters/01-introduction.typ"
 
#include "/ALGORITHMS & DATA STRUCTURES/labs/01-foundations.typ"

#include "/ALGORITHMS & DATA STRUCTURES/chapters/02-arrays.typ"
 
#include "/ALGORITHMS & DATA STRUCTURES/labs/02-arrays.typ"


#stage[Linear Dynamic Structures] 
#include "/ALGORITHMS & DATA STRUCTURES/chapters/03-linked-lists.typ"
 
#include "/ALGORITHMS & DATA STRUCTURES/labs/03-linked-lists.typ"
 
#include "/ALGORITHMS & DATA STRUCTURES/chapters/04-circular-linked-list.typ"
 
#include "/ALGORITHMS & DATA STRUCTURES/labs/04-circular-list.typ"
 
#include "/ALGORITHMS & DATA STRUCTURES/chapters/05-stacks.typ"
 
#include "/ALGORITHMS & DATA STRUCTURES/labs/05-stacks.typ"
 
#include "/ALGORITHMS & DATA STRUCTURES/chapters/06-queues.typ"
 
#include "/ALGORITHMS & DATA STRUCTURES/labs/06-queues.typ"


#stage[Trees and Hierarchies] 
#include "/ALGORITHMS & DATA STRUCTURES/chapters/07-trees-i.typ"
 
#include "/ALGORITHMS & DATA STRUCTURES/labs/07-trees-i.typ"
 
#include "/ALGORITHMS & DATA STRUCTURES/chapters/08-trees-ii.typ"
 
#include "/ALGORITHMS & DATA STRUCTURES/labs/08-trees-ii.typ"


#stage[Graphs and Traversal] 
#include "/ALGORITHMS & DATA STRUCTURES/chapters/09-graphs.typ"
 
#include "/ALGORITHMS & DATA STRUCTURES/labs/09-graphs.typ"


#stage[Core Algorithms and Fast Access] 
#include "/ALGORITHMS & DATA STRUCTURES/chapters/10-searching-sorting.typ"
 
#include "/ALGORITHMS & DATA STRUCTURES/labs/10-searching-sorting.typ"
 
#include "/ALGORITHMS & DATA STRUCTURES/chapters/11-hashing.typ"
 
#include "/ALGORITHMS & DATA STRUCTURES/labs/11-hashing.typ"


#stage[Course Project and Synthesis] 
#include "/ALGORITHMS & DATA STRUCTURES/chapters/12-final-project.typ"

