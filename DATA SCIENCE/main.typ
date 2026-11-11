#import "/.shared/typst/utp.typ": *
#show: book.with(title: [Introduction to Data Science], summary: [Practical data science in R: from framing questions and preparing data to analysis, modelling, validation, and responsible communication.], lab-total: 10)

#cover(title: [Introduction to Data Science], summary: [Practical data science in R: from framing questions and preparing data to analysis, modelling, validation, and responsible communication.])
#outline(depth: 1)
#pagebreak()
#include "chapters/course-map.typ"

#include "/DATA SCIENCE/chapters/00-toolkit.typ"


#stage[Foundations: Questions, Data, and Reproducibility] 
#include "/DATA SCIENCE/chapters/01-data-science-workflow.typ"
 
#include "/DATA SCIENCE/labs/01-data-science-workflow.typ"



#include "/DATA SCIENCE/chapters/02-data-quality.typ"
 
#include "/DATA SCIENCE/labs/02-data-quality.typ"


#stage[Working with Data and Finding Patterns] 
#include "/DATA SCIENCE/chapters/03-data-wrangling.typ"
 
#include "/DATA SCIENCE/labs/03-data-wrangling.typ"



#include "/DATA SCIENCE/chapters/04-exploratory-analysis.typ"
 
#include "/DATA SCIENCE/labs/04-exploratory-analysis.typ"



#include "/DATA SCIENCE/chapters/05-visualization.typ"
 
#include "/DATA SCIENCE/labs/05-visualization.typ"


#stage[Uncertainty and Predictive Modelling] 
#include "/DATA SCIENCE/chapters/06-inference.typ"
 
#include "/DATA SCIENCE/labs/06-inference.typ"



#include "/DATA SCIENCE/chapters/07-regression.typ"
 
#include "/DATA SCIENCE/labs/07-regression.typ"



#include "/DATA SCIENCE/chapters/08-classification.typ"
 
#include "/DATA SCIENCE/labs/08-classification.typ"



#include "/DATA SCIENCE/chapters/09-validation-preprocessing.typ"
 
#include "/DATA SCIENCE/labs/09-validation-preprocessing.typ"


#stage[Unsupervised Learning and Integration] 
#include "/DATA SCIENCE/chapters/10-unsupervised-learning.typ"
 
#include "/DATA SCIENCE/labs/10-unsupervised-learning.typ"


#stage[Capstone] 
#include "/DATA SCIENCE/chapters/capstone-project.typ"

