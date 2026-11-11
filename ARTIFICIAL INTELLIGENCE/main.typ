#import "/.shared/typst/utp.typ": *
#show: book.with(title: [Artificial Intelligence], summary: [Eight laboratory-guided modules covering search, fuzzy systems, robotics,

natural language processing, and optimization, closing with game search.], lab-total: 8)

#cover(title: [Artificial Intelligence], summary: [Eight laboratory-guided modules covering search, fuzzy systems, robotics,
natural language processing, and optimization, closing with game search.])
#outline(depth: 1)
#pagebreak()
#include "chapters/course-map.typ"

#include "/ARTIFICIAL INTELLIGENCE/chapters/00-toolkit.typ"


#stage[Search and Problem Solving] 
#include "/ARTIFICIAL INTELLIGENCE/chapters/01-uninformed-search.typ"
 
#include "/ARTIFICIAL INTELLIGENCE/labs/01-search-foundations.typ"



#include "/ARTIFICIAL INTELLIGENCE/chapters/02-informed-search.typ"
 
#include "/ARTIFICIAL INTELLIGENCE/labs/02-informed-search.typ"
 
#include "/ARTIFICIAL INTELLIGENCE/chapters/03-search-implementation-patterns.typ"
 
#include "/ARTIFICIAL INTELLIGENCE/labs/03-search-consolidation.typ"


#stage[Approximate Reasoning and Intelligent Control] 
#include "/ARTIFICIAL INTELLIGENCE/chapters/04-fuzzy-logic-and-anfis.typ"
 
#include "/ARTIFICIAL INTELLIGENCE/labs/04-fuzzy-anfis.typ"
 
#include "/ARTIFICIAL INTELLIGENCE/chapters/05-robotics-scenarios.typ"
 
#include "/ARTIFICIAL INTELLIGENCE/labs/05-robotics.typ"


#stage[Language Intelligence] 
#include "/ARTIFICIAL INTELLIGENCE/chapters/06-nlp-foundations.typ"
 
#include "/ARTIFICIAL INTELLIGENCE/labs/06-nlp-part-a.typ"
 
#include "/ARTIFICIAL INTELLIGENCE/chapters/08-nlp-methods.typ"
 
#include "/ARTIFICIAL INTELLIGENCE/labs/07-nlp-part-b.typ"


#stage[Local Search and Evolutionary Optimization] 
#include "/ARTIFICIAL INTELLIGENCE/chapters/09-local-search.typ"
 
#include "/ARTIFICIAL INTELLIGENCE/chapters/10-genetic-algorithms.typ"
 
#include "/ARTIFICIAL INTELLIGENCE/labs/08-genetic-algorithms.typ"


#stage[Adversarial Search] 
#include "/ARTIFICIAL INTELLIGENCE/chapters/11-adversarial-search.typ"

