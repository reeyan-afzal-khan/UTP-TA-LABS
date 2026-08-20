# UTP Machine Learning

A structured set of machine-learning notes, datasets, and **10 consolidated practical labs**. The theory remains chapter-based, while related chapters share one larger lab milestone so the practical sequence finishes in ten labs.

## Repository layout

- `MACHINE_LEARNING_NOTES/` — LaTeX source for the course notes.
- `all_experiments/` — **10 canonical Jupyter lab notebooks**.
- `all_datasets/` — one folder per dataset.
- `MACHINE_LEARNING_NOTES/code-listings/` — generated Python mirrors used by LaTeX `listings`.
- `requirements.txt` — Python dependencies used by the practical work.

## Ten-lab practical sequence

| Lab | Chapters | Practical focus | Notebook |
| --- | --- | --- | --- |
| 01 | 02–03 | Environment, project paths, data audit, leakage boundaries | `lab01-foundations_environment_data.ipynb` |
| 02 | 04–05 | End-to-end learning loop, preprocessing, scaling, geometry | `lab02-learning_loop_geometry.ipynb` |
| 03 | 06–08 | Supervised baselines, evaluation, thresholds, model selection | `lab03-supervised_workflow_evaluation_selection.ipynb` |
| 04 | 09 | Linear/ridge regression and chronological validation | `lab04-regression_validation.ipynb` |
| 05 | 10–11 | Logistic regression, KNN, naive Bayes | `lab05-classification_models.ipynb` |
| 06 | 12–13 | Decision trees, random forests, boosting, ensembles | `lab06-trees_ensembles.ipynb` |
| 07 | 14 | Support vector machines | `lab07-support_vector_machines.ipynb` |
| 08 | 15–17 | Unsupervised workflow, clustering, PCA | `lab08-unsupervised_clustering_pca.ipynb` |
| 09 | 18–19 | Anomaly detection, self-training, active learning | `lab09-anomaly_limited_labels.ipynb` |
| 10 | 20 | Q-learning and capstone handoff | `lab10-reinforcement_integration.ipynb` |

Optional transfer activities (Heart Failure, Bike Sharing, and Wine Quality) are embedded inside Labs 3, 4, and 6. They are extensions, **not additional labs**. The capstone is an integration project after Lab 10, not Lab 11.

## Working with the notebooks

Create and activate a virtual environment, then install the requirements:

```bash
python -m venv .venv
source .venv/bin/activate       # macOS/Linux
# .venv\Scripts\Activate.ps1   # Windows PowerShell
python -m pip install -r requirements.txt
```

The notebooks resolve dataset paths when Jupyter is launched either from the repository root or from `all_experiments/`.
