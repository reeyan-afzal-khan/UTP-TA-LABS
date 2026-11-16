#import "/.shared/typst/utp.typ": *
#unit("chapters", "capstone-project")

#chapter-star[Capstone Project: From Raw Data to Defensible Evidence]

Build one reproducible project from raw data to validated conclusions and a reusable model. The labs handed you the question, the data and the code. Here you choose all three, and you defend every decision with evidence.

#note[
  Use a public dataset that no lab uses, with a licence that allows it; the Hugging Face dataset hub, the UCI Machine Learning Repository and OpenML are good places to look. Keep raw files in `all_datasets/`, and your notebook in its own folder, `all_experiments/capstone/`, with a README like the labs’ that names the data’s source and licence.
]

#heading(depth: 2, numbering: none)[Before you start]

Write one page answering three questions, and show it to your tutor before modeling.

#utpsteps[
  + #strong[Which corner of the map?] Does your log hold the answers? Do you want a number, a category, groups, or fewer columns (#figref(<fig:ml-map>))?
  + #strong[What decision does this serve?] Name who would use the output, and what each kind of wrong answer costs them.
  + #strong[When is the prediction made?] List the columns that exist at that moment. Everything else is leakage (#secref(<sec:data-leakage>)).
]

#heading(depth: 2, numbering: none)[Required capstone sequence]

+ #strong[Problem.] Specify rows, objective, use moment, population, metric, and error costs.
+ #strong[Data.] Record provenance, schema, units, missingness, duplicates, invalid values, identifiers, and cleaning rules.
+ #strong[Splits.] Match future use with random, stratified, grouped, or chronological splits; reserve a supervised test set.
+ #strong[Baseline.] Evaluate a no-skill or domain rule.
+ #strong[Preprocessing.] Fit learned transformations within training folds.
+ #strong[Models.] Compare at least three families, including one interpretable model.
+ #strong[Development.] Tune, select features, and resample only within validated development pipelines.
+ #strong[Diagnostics.] Plot relevant errors, residuals, thresholds, learning curves, features, clusters, or scores.
+ #strong[Subgroups.] Locate failures beyond aggregate metrics.
+ #strong[Final evidence.] Test once on untouched supervised data, or present complementary unsupervised evidence.
+ #strong[Limits.] Distinguish prediction from causation and state unsupported claims.
+ #strong[Reproducibility.] Record paths, packages, seeds, notebook order, and configuration.
+ #strong[Artifact.] Save the pipeline and model card under `models/`; demonstrate reloading and prediction.

#heading(depth: 2, numbering: none)[Choose one extension]

Add one, and keep it only if the evidence says it helps.

- #strong[Limited labels.] Hide most labels; try self-training or active learning (#chapref(<ch:semi-supervised>)).
- #strong[A neural network.] Beside your best model, with early stopping and several seeds (#chapref(<ch:deep-training>)).
- #strong[Text or sequences.] A tf-idf text column (#chapref(<ch:text>)), or a forecast (#chapref(<ch:sequence>)).
- #strong[Ranking.] If the data records who chose what, test a recommender on later choices (#chapref(<ch:recommenders>)).
- #strong[A model put to work.] A data contract, tests, a service and a drift check (#chapsref(<ch:project>, <ch:serving>)).

#heading(depth: 2, numbering: none)[What to hand in]

- A notebook that runs from top to bottom after #strong[Restart Kernel and Run All Cells].
- The saved pipeline and model card under `models/`, with a cell that reloads them and predicts one new row.
- A results table: baseline, each model family, and the locked model’s one test score.
- A two-page report in your own words: the problem and its costs, the split and why it imitates real use, what you compared, what you chose and why, where the model fails, and what it must not be used for.

#heading(depth: 2, numbering: none)[How it is judged]

#utptable[
  #tabularx(
    columns: (24%, 1fr),
    styles: (navy-bold,),
    header: ([Criterion], [What good looks like]),
    [Honest evaluation], [The split imitates real use, preprocessing sits inside a pipeline, and the test set is opened once.],
    [Baseline], [Every model is compared with a rule that costs nothing, on the same rows.],
    [Comparison], [Three families under one protocol, with fold spread or another estimate of uncertainty.],
    [Diagnosis], [At least one look at actual errors or subgroups, and what it changed.],
    [Reasoning], [Each choice is justified by evidence, including choosing a simpler model when a gain is within noise.],
    [Reproducibility], [Someone else can rerun it and get your numbers, and your report states what may vary.],
  )
]

#warning[
  Three mistakes cost the most. Fitting a scaler or selector on all the rows before cross-validating. Reporting the best of many test scores. Claiming a cause from a coefficient or an importance score. The course gave you a tool to avoid each one.
]
