// Data Science: the book. Settings first, then the chapters and labs in teaching order.
#import "/.shared/typst/utp.typ": *
#show: book.with(
  title: [Introduction to Data Science],
  outline: [Practical data science in R: from framing questions and preparing data to analysis, modelling, validation, and responsible communication.],
  lab-total: 10,
  contents: (part: 1.40em, chapter: 0.46em, lab: 0.54em),
  titles: (pitfall: [Analytical pitfall], labmode: [Lab guidance]),
)
#cover()
#contents()
#include "chapters/course-map.typ"
#show: mainmatter

#include "chapters/00-toolkit.typ"

#part[Foundations: Questions, Data, and Reproducibility]
#include "chapters/01-data-science-workflow.typ"
#include "labs/01-data-science-workflow.typ"

#include "chapters/02-data-quality.typ"
#include "labs/02-data-quality.typ"

#part[Working with Data and Finding Patterns]
#include "chapters/03-data-wrangling.typ"
#include "labs/03-data-wrangling.typ"

#include "chapters/04-exploratory-analysis.typ"
#include "labs/04-exploratory-analysis.typ"

#include "chapters/05-visualization.typ"
#include "labs/05-visualization.typ"

#part[Uncertainty and Predictive Modelling]
#include "chapters/06-inference.typ"
#include "labs/06-inference.typ"

#include "chapters/07-regression.typ"
#include "labs/07-regression.typ"

#include "chapters/08-classification.typ"
#include "labs/08-classification.typ"

#include "chapters/09-validation-preprocessing.typ"
#include "labs/09-validation-preprocessing.typ"

#part[Unsupervised Learning and Integration]
#include "chapters/10-unsupervised-learning.typ"
#include "labs/10-unsupervised-learning.typ"

#part[Capstone]
#include "chapters/capstone-project.typ"
