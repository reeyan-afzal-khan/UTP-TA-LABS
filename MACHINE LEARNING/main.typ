// Machine Learning: the book. Settings first, then the chapters and labs in teaching order.
#import "/.shared/typst/utp.typ": *
#show: book.with(
  title: [Machine Learning],
  running-head: [Machine Learning Notes],
  outline: [A step-by-step path through data preparation, shared mathematical foundations, supervised and unsupervised learning, and a little touch of Deep Learning.],
  lab-total: 8,
  contents: (part: 0.30em, chapter: 0.04em, lab: 0.04em),
  keep-headings: (7 * 13.55pt, 6 * 13.55pt),
  routine-intro: [Question $n$ is the code cell the notebook labels Question $n$; after #strong[Restart Kernel and Run All Cells] its prompt reads #mono[\[$n$\]]. For each question, do four things in order:],
  routine-compare: [Check your output against the reference output. Printed figures come from one CPU run with the package versions on the sheet’s first output. Other versions can move the last digit; a neural network can move the third decimal.],
  titles: (labmode: [Lab setup], deliverable: [Submission checklist]),
)
#cover()
#contents()
#include "chapters/course-map.typ"
#show: mainmatter

#include "chapters/00-toolkit.typ"

#part[Orientation and Tools]
#include "chapters/01-where-to-begin-ML.typ"

#part[Foundations Shared by Machine Learning]
#include "chapters/02-understanding-and-preparing-data.typ"
#include "chapters/03-how-machine-learning-works.typ"
#include "chapters/04-statistics-geometry-and-similarity.typ"
#include "labs/01-features.typ"

#part[Supervised Learning]
#substage("3A")[Supervised Workflow][Define objectives, evaluation, and selection before comparing models.]
#include "chapters/05-how-supervised-learning-works.typ"
#include "chapters/06-evaluating-supervised-models.typ"
#include "chapters/07-training-generalization-and-model-selection.typ"
#substage("3B")[Supervised Model Families][Compare model families under one fixed validation workflow.]
#include "chapters/08-linear-models-for-regression.typ"
#include "chapters/09-linear-models-for-classification.typ"
#include "labs/02-supervised-workflow.typ"

#include "chapters/10-nearest-neighbors-and-naive-bayes.typ"
#include "chapters/11-decision-trees.typ"
#include "chapters/12-ensemble-methods.typ"
#include "chapters/13-support-vector-machines.typ"
#include "labs/03-supervised-models.typ"

#part[Unsupervised Learning]
#substage("4A")[Unsupervised Workflow][Evaluate unlabeled structure through stability, usefulness, and domain evidence.]
#include "chapters/14-how-unsupervised-learning-works.typ"
#substage("4B")[Unsupervised Model Families][Compare clustering, representations, and anomaly detection; validate their meaning.]
#include "chapters/15-clustering.typ"
#include "chapters/16-dimensionality-reduction-and-representation.typ"
#include "labs/04-clustering-pca.typ"

#include "chapters/17-anomaly-detection.typ"
#include "labs/05-anomaly-limited-labels.typ"

#part[Advanced Concepts]
#include "chapters/18-semi-supervised-and-active-learning.typ"
#include "chapters/19-reinforcement-learning.typ"
#include "labs/06-reinforcement.typ"

#include "chapters/20-neural-networks.typ"
#include "labs/07-deep-learning-cnn.typ"
#include "labs/08-deep-learning-lstm.typ"

#include "chapters/capstone-project.typ"
