#import "/.shared/typst/utp.typ": *
#show: book.with(title: [Machine Learning], summary: [A step-by-step path through data preparation, shared mathematical foundations, supervised and unsupervised learning, and a little touch of Deep Learning.], lab-total: 8)

#cover(title: [Machine Learning], summary: [A step-by-step path through data preparation, shared mathematical foundations, supervised and unsupervised learning, and a little touch of Deep Learning.])
#outline(depth: 1)
#pagebreak()
#include "chapters/course-map.typ"

#include "/MACHINE LEARNING/chapters/00-toolkit.typ"


#stage[Orientation and Tools] 
#include "/MACHINE LEARNING/chapters/01-where-to-begin-ML.typ"


#stage[Foundations Shared by Machine Learning] 
#include "/MACHINE LEARNING/chapters/02-understanding-and-preparing-data.typ"
 
#include "/MACHINE LEARNING/chapters/03-how-machine-learning-works.typ"
 
#include "/MACHINE LEARNING/chapters/04-statistics-geometry-and-similarity.typ"
 
#include "/MACHINE LEARNING/labs/01-features.typ"


#stage[Supervised Learning] #stage(number: "3A", subtitle: [Define objectives, evaluation, and selection before comparing models.])[Supervised Workflow] 
#include "/MACHINE LEARNING/chapters/05-how-supervised-learning-works.typ"
 
#include "/MACHINE LEARNING/chapters/06-evaluating-supervised-models.typ"
 
#include "/MACHINE LEARNING/chapters/07-training-generalization-and-model-selection.typ"
 #stage(number: "3B", subtitle: [Compare model families under one fixed validation workflow.])[Supervised Model Families] 
#include "/MACHINE LEARNING/chapters/08-linear-models-for-regression.typ"
 
#include "/MACHINE LEARNING/chapters/09-linear-models-for-classification.typ"
 
#include "/MACHINE LEARNING/labs/02-supervised-workflow.typ"



#include "/MACHINE LEARNING/chapters/10-nearest-neighbors-and-naive-bayes.typ"
 
#include "/MACHINE LEARNING/chapters/11-decision-trees.typ"
 
#include "/MACHINE LEARNING/chapters/12-ensemble-methods.typ"
 
#include "/MACHINE LEARNING/chapters/13-support-vector-machines.typ"
 
#include "/MACHINE LEARNING/labs/03-supervised-models.typ"


#stage[Unsupervised Learning] #stage(number: "4A", subtitle: [Evaluate unlabeled structure through stability, usefulness, and domain evidence.])[Unsupervised Workflow] 
#include "/MACHINE LEARNING/chapters/14-how-unsupervised-learning-works.typ"
 #stage(number: "4B", subtitle: [Compare clustering, representations, and anomaly detection; validate their meaning.])[Unsupervised Model Families] 
#include "/MACHINE LEARNING/chapters/15-clustering.typ"
 
#include "/MACHINE LEARNING/chapters/16-dimensionality-reduction-and-representation.typ"
 
#include "/MACHINE LEARNING/labs/04-clustering-pca.typ"



#include "/MACHINE LEARNING/chapters/17-anomaly-detection.typ"
 
#include "/MACHINE LEARNING/labs/05-anomaly-limited-labels.typ"


#stage[Advanced Concepts] 
#include "/MACHINE LEARNING/chapters/18-semi-supervised-and-active-learning.typ"
 
#include "/MACHINE LEARNING/chapters/19-reinforcement-learning.typ"
 
#include "/MACHINE LEARNING/labs/06-reinforcement.typ"



#include "/MACHINE LEARNING/chapters/20-neural-networks.typ"
 
#include "/MACHINE LEARNING/labs/07-deep-learning-cnn.typ"
 
#include "/MACHINE LEARNING/labs/08-deep-learning-lstm.typ"



#include "/MACHINE LEARNING/chapters/capstone-project.typ"

