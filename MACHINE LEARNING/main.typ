// Machine Learning: the book. Settings first, then the chapters and labs in teaching order.
#import "/.shared/typst/utp.typ": *
#show: book.with(
  title: [Machine Learning],
  running-head: [Machine Learning Notes],
  outline: [A step-by-step path through the whole machine-learning process: tools and data, exploration and features, supervised and unsupervised learning, deep learning, text, and a model put to work.],
  lab-total: 10,
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
#include "chapters/02-python-data-toolkit.typ"

#part[Foundations Shared by Machine Learning]
#include "chapters/03-understanding-and-preparing-data.typ"
#include "chapters/04-how-machine-learning-works.typ"
#include "chapters/05-statistics-geometry-and-similarity.typ"
#include "chapters/06-exploratory-data-analysis.typ"
#include "labs/00-data-toolkit-eda.typ"

#include "chapters/07-distributions-and-hypothesis-tests.typ"
#include "chapters/08-feature-engineering.typ"
#include "labs/01-features.typ"

#part[Supervised Learning]
#substage("3A")[Supervised Workflow][Define objectives, evaluation, and selection before comparing models.]
#include "chapters/09-how-supervised-learning-works.typ"
#include "chapters/10-evaluating-supervised-models.typ"
#include "chapters/11-training-generalization-and-model-selection.typ"
#substage("3B")[Supervised Model Families][Compare model families under one fixed validation workflow.]
#include "chapters/12-linear-models-for-regression.typ"
#include "chapters/13-linear-models-for-classification.typ"
#include "labs/02-supervised-workflow.typ"

#include "chapters/14-nearest-neighbors-and-naive-bayes.typ"
#include "chapters/15-decision-trees.typ"
#include "chapters/16-ensemble-methods.typ"
#include "chapters/17-support-vector-machines.typ"
#include "chapters/18-feature-selection.typ"
#include "labs/03-supervised-models.typ"

#part[Unsupervised Learning]
#substage("4A")[Unsupervised Workflow][Evaluate unlabeled structure through stability, usefulness, and domain evidence.]
#include "chapters/19-how-unsupervised-learning-works.typ"
#substage("4B")[Unsupervised Model Families][Compare clustering, representations, and anomaly detection; validate their meaning.]
#include "chapters/20-clustering.typ"
#include "chapters/21-dimensionality-reduction-and-representation.typ"
#include "labs/04-clustering-pca.typ"

#include "chapters/22-anomaly-detection.typ"
#include "chapters/23-recommender-systems.typ"

#part[Limited Labels and Rewards]
#include "chapters/24-semi-supervised-and-active-learning.typ"
#include "labs/05-anomaly-limited-labels.typ"

#include "chapters/25-reinforcement-learning.typ"
#include "labs/06-reinforcement.typ"

#part[Deep Learning]
#include "chapters/26-neural-networks.typ"
#include "chapters/27-training-deep-networks.typ"
#include "chapters/28-convolutional-networks.typ"
#include "labs/07-deep-learning-cnn.typ"

#include "chapters/29-sequence-models-and-attention.typ"
#include "labs/08-deep-learning-lstm.typ"

#part[Language and Products]
#include "chapters/30-learning-from-text.typ"
#include "labs/09-learning-from-text.typ"

#include "chapters/31-the-end-to-end-project.typ"
#include "chapters/32-serving-and-monitoring.typ"
#include "labs/10-end-to-end-project.typ"

#include "chapters/capstone-project.typ"
