# Heart disease

918 patients examined for heart disease at five hospitals, with 11 clinical measurements each. `HeartDisease` says whether the patient was diagnosed with heart disease.

**Used in:** Lab 0 (the first look at a table, exploratory data analysis, and a first baseline model), and the worked examples of the chapters on exploratory data analysis and on hypothesis tests.

**Source and licence:** fedesoriano, *Heart Failure Prediction Dataset* (September 2021), [Kaggle](https://www.kaggle.com/datasets/fedesoriano/heart-failure-prediction); Open Database License (ODbL) 1.0. It joins five heart-disease tables from the UCI repository (Cleveland, Hungary, Switzerland, Long Beach VA and Statlog) on their 11 shared columns and removes the repeated patients.

**Changed from the source:** None: the source file, renamed.

## Files

| File | Size | Read it with |
| --- | --- | --- |
| `heart_disease.csv` | 36 KB | `pd.read_csv(DATA / "supervised/heart_disease/heart_disease.csv")` |

`DATA` is the course's `all_datasets/` folder; every lab's Setup cell defines it.

## What to watch for

- 55.3% of the patients have heart disease (508 of 918), so always guessing "disease" is 55.3% accurate.
- No cell is blank, and yet values are missing. `Cholesterol` is 0 for 172 patients and `RestingBP` is 0 for one: nobody alive has a cholesterol or a blood pressure of zero, so a zero here means "not measured".
- Those gaps are not random: 88.4% of the patients with no cholesterol reading have heart disease, against 47.7% of the rest. The zeros mark the hospitals that did not record cholesterol, whose patients were sicker.
- `Oldpeak` is negative for 13 patients and exactly 0 for 368.
- 725 patients are men and 193 are women, so a pattern "for all patients" is mostly a pattern for men.
- The five hospitals are not identified, and patients were referred for testing, not sampled from the public: the disease rate here says nothing about the rate in a town.

## Columns of `heart_disease.csv`

918 rows and 12 columns.

| Column | Meaning | Type | Missing | Example |
| --- | --- | --- | --- | --- |
| `Age` | age in years | integer | 0 | 40 |
| `Sex` | `M` or `F` | text | 0 | M |
| `ChestPainType` | `TA` typical angina, `ATA` atypical angina, `NAP` non-anginal pain, `ASY` no chest pain | text | 0 | ATA |
| `RestingBP` | resting blood pressure in mm Hg; 0 means not measured | integer | 0 | 140 |
| `Cholesterol` | serum cholesterol in mg/dl; 0 means not measured | integer | 0 | 289 |
| `FastingBS` | 1 if fasting blood sugar is above 120 mg/dl | integer | 0 | 0 |
| `RestingECG` | resting electrocardiogram: `Normal`, `ST` (ST-T wave abnormality) or `LVH` (thickened left ventricle) | text | 0 | Normal |
| `MaxHR` | highest heart rate reached in the exercise test, beats per minute | integer | 0 | 172 |
| `ExerciseAngina` | chest pain brought on by exercise: `Y` or `N` | text | 0 | N |
| `Oldpeak` | how far the ST segment of the ECG drops during exercise, in mm | decimal | 0 | 0.0 |
| `ST_Slope` | slope of the ST segment at peak exercise: `Up`, `Flat` or `Down` | text | 0 | Up |
| `HeartDisease` | 1 if diagnosed with heart disease: the label | integer | 0 | 0 |
