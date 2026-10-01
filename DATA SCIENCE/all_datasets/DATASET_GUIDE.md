# Bundled Data Science Datasets

These files are local course inputs. Core labs read them directly from `all_datasets/`; no Kaggle API or network access is required during a lab.

| File | Rows x columns | Main course use |
|---|---:|---|
| `iris_dataset.csv` | 153 x 6 | data quality, category consistency, missing values, invalid measurement audit |
| `titanic_dataset.csv` | 891 x 12 | missingness and categorical data |
| `student_performance_dataset.csv` | 649 x 33 | inference, confounding, observational interpretation |
| `bike_sharing_dataset_day.csv` | 731 x 16 | workflow, time-aware analysis, demand patterns |
| `bike_sharing_dataset_hour.csv` | 17,379 x 17 | wrangling, aggregation, cyclic time features |
| `medical_cost_personal_dataset.csv` | 1,338 x 7 | EDA, skew, group comparisons |
| `red_wine_quality_dataset.csv` | 1,599 x 12 | visualisation, ordinal outcomes, correlation structure, duplicate semantics |
| `ames_housing_dataset.csv` | 2,930 x 82 | regression, diagnostics, structural missingness, categorical predictors |
| `heart_failure_dataset.csv` | 918 x 12 | binary classification, calibration, subgroup diagnostics |
| `breast_cancer_dataset.csv` | 569 x 33 | classification geometry and feature redundancy |
| `credit_card_fraud_dataset.csv` | 10,000 x 10 | class imbalance, validation, threshold choice |
| `mall_customers_dataset.csv` | 200 x 5 | clustering and segmentation |
| `wine_recognition_dataset.csv` | 178 x 15 | PCA and multivariate structure |
| `optical_recognition_handwritten_digits.zip` | 3,823 train + 1,797 test rows | multiclass classification, 64-dimensional image features, writer-independent validation |

## Working rule
Treat these files as read-only source evidence. Perform cleaning and feature engineering in code, and write any derived outputs outside `all_datasets/`.
