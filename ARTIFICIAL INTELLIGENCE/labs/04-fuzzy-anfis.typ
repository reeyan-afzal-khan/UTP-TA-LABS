#import "/.shared/typst/utp.typ": *
#unit("labs", "04-fuzzy-anfis")

#labsection(4, label: <sec:lab04-fuzzy>)[Fuzzy Logic and ANFIS with Air-Quality Data]

#labproject[Combine expert rules with data-driven prediction][
  #strong[Read first.] Chapter~#ref(<ch:fuzzy>). \

  #strong[Goal.] Build a Mamdani controller and a compact Sugeno ANFIS, then compare ANFIS with linear regression on held-out data. \

  #strong[Scenario.] An environmental monitor needs an interpretable ventilation policy and a nonlinear predictor for carbon-monoxide concentration. \

  #strong[Data.] `all_datasets/lab04-AirQuality.csv` (UCI Air Quality, hourly sensor readings). \

  #strong[Notebook.] `all_experiments/lab04_fuzzy_anfis_worked.ipynb`; inference and ANFIS training are implemented with NumPy, SciPy and scikit-learn. \

  #strong[Hand in.] The executed notebook, the `results/lab04/` folder and a short conclusion, as listed in the checklist at the end of this sheet.
]

#labmode[
  + Activate your course environment and confirm that the data file is in `all_datasets/`.
  + Start Jupyter from `all_experiments/`, open the notebook, and choose #strong[Restart Kernel and Run All Cells]. ANFIS training is the slowest step, and the notebook still finishes in a few seconds on a laptop.

  ```terminal
  cd all_experiments
  jupyter lab
  ```

  Prefer a plain script? From the course folder, `python all_experiments/lab04_fuzzy_anfis_worked.py` runs the same code and writes the same evidence.
]

#include "visuals/04-flow.typ"

#labroutine

#yourturn[
  #strong[Warm-up on paper.] Using the sets of Chapter~@ch:fuzzy, trace the reading $20^(compose)$C, 50 % through the controller: compute the memberships, then the three rule strengths. Can you say what the centroid will be without any arithmetic?

  #emph[Answer.] Mild is $(20-12)\/10=0.8$ and comfortable is 1; all others are 0. Low $=0$, medium $=min(0.8,1)=0.8$, high $=0$. Only the medium output triangle is clipped, and it is symmetric about 50, so the centroid is 50 %.
]

#strong[Setup.] Run the imports and path setup first, and keep this kernel state for the later questions. In the script version the first seven lines also set the working directory.

#lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/lab04_fuzzy_anfis_worked.py", first: 1, last: 7, lang: "python")

#lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/lab04_fuzzy_anfis_worked.py", first: 8, last: 24, lang: "python")

#labquestion(1)[Clean the data][
  The UCI Air Quality file is semicolon-separated with a decimal comma, marks missing values as $-200$, and ends with empty rows. Parse it, turn $-200$ into missing values, drop the empty tail, and report how many usable rows each variable has. Plot temperature against humidity to see the conditions the controller must cover.
]

#labanswer[
  #include "visuals/04-trace.typ"

  #lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/lab04_fuzzy_anfis_worked.py", first: 26, last: 36, lang: "python")

  #labvisual[Reference plot from the supplied notebook][
    #fitted-image("/ARTIFICIAL INTELLIGENCE/labs/visuals/04-notebook-reference.png", width: 88%, height: 5cm)
  ]

  #refoutput[
    ```terminal
    Rows: 9357
    usable rows:  T 8991   RH 8991   CO(GT) 7674   PT08.S1(CO) 8991   PT08.S2(NMHC) 8991
    ```
  ]

  #strong[What it means.] 9,357 hourly rows remain. Temperature and humidity are present in 8,991 of them, but the reference CO analyser `CO(GT)` is missing in almost 1,700 rows, so the regression later uses only rows where the target and both sensors are present. Temperature spans about 0--45 degrees and humidity 10--90 %, which fixes the ranges of the controller.
]

#labquestion(2)[Build the fuzzy controller][
  Inputs: temperature and relative humidity. Output: ventilation demand, 0--100 %. Give each variable three triangular membership functions (the outer two are shoulders), write the expert rules, and implement Mamdani inference: `min` for AND, `max` to combine rules, centroid to defuzzify. Plot the memberships.
]

#labanswer[
  Follow the dictionaries `t` and `h`, then the three rule strengths, then `output`. The numerator sums `V_range` times `output`, and the denominator sums `output`. Their ratio at the warm-up reading is 50, not the firing strength 0.8.

  #include "visuals/04-worked-case.typ"

  #lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/lab04_fuzzy_anfis_worked.py", first: 38, last: 76, lang: "python")

  #strong[What it means.] The three sets of each variable overlap, so every reading belongs to at least one set and neighbouring rules blend rather than switch. Six rules map temperature and humidity to low, medium or high ventilation, and the centroid of the combined output set is the crisp percentage.
]

#strong[Connect it to the chapter.] This is the difference the controller exploits: a degree instead of a jump.

#include "visuals/04-fuzzy-anfis-chapter.typ"

#labquestion(3)[Validate the rule base][
  Evaluate five fixed operating points that have an expected qualitative answer, then compute the full control surface and check that it is smooth and rises in the right direction. Save both.
]

#labanswer[
  #lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/lab04_fuzzy_anfis_worked.py", first: 78, last: 92, lang: "python")

  #refoutput[
    ```terminal
       T_C  RH_pct expected  ventilation_pct
    0   10      30      low             18.9
    1   20      50   medium             50.0
    2   35      50     high             82.3
    3   25      80     high             83.8
    4   40      80     high             84.2
    ```
  ]

  #strong[What it means.] About 19 % for the cool, dry point, 50 % for the mild, comfortable point, and over 80 % for the hot or humid points: every fixed point lands in its expected band. The surface rises towards the hot-and-humid corner without steps, because overlapping memberships blend neighbouring rules.
]

#labquestion(4)[Prepare the ANFIS task][
  Predict the reference CO concentration `CO(GT)` from the two metal-oxide sensors `PT08.S1(CO)` and `PT08.S2(NMHC)`. Keep complete rows only, split 70/15/15 with seed 42, standardise the inputs with training statistics only, and save the split.
]

#labanswer[
  #lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/lab04_fuzzy_anfis_worked.py", first: 94, last: 106, lang: "python")

  #refoutput[
    ```terminal
    {'usable_rows': 7344, 'train': 5140, 'validation': 1102, 'test': 1102}
    ```
  ]

  #strong[What it means.] 7,344 complete rows give 5,140 training, 1,102 validation and 1,102 test rows. The scaler sees only the training rows, so nothing from validation or test leaks into the model.
]

#labquestion(5)[Fit two model classes][
  Train linear regression as the baseline. Implement a first-order Sugeno ANFIS with Gaussian memberships: the rule outputs are solved by least squares, the membership centres and widths by L-BFGS-B. Train candidates with two and three memberships per input and select the size by validation RMSE only. Save `metrics.csv`.
]

#labanswer[
  #lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/lab04_fuzzy_anfis_worked.py", first: 108, last: 171, lang: "python")

  #refoutput[
    ```terminal
                   model  validation_rmse  validation_mae
    0  Linear regression           0.5103          0.3722
    1          ANFIS-2MF           0.4548          0.3194
    2          ANFIS-3MF           0.4484          0.3151
    Selected by validation RMSE: ANFIS-3MF
    ```
  ]

  #strong[What it means.] Both ANFIS candidates beat the linear baseline on validation RMSE, and three memberships per input is marginally better than two, so it is selected. The choice is made without looking at the test columns. The class maps onto the five ANFIS layers: Gaussian memberships (layer 1), rule strengths and their normalisation (layers 2--3) in `_weights`, linear rule outputs (layer 4) in `_design`, and the weighted sum (layer 5) in `predict`. L-BFGS-B differs slightly between SciPy versions, so your third decimal may differ from this reference; the ordering of the models should not.
]

#labquestion(6)[Evaluate once on the test data][
  Report test RMSE and MAE for the baseline and the selected ANFIS, save the predicted-versus-actual figure, and say whether the extra complexity is justified.
]

#labanswer[
  #lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/lab04_fuzzy_anfis_worked.py", first: 173, last: 184, lang: "python")

  #refoutput[
    ```terminal
    Test RMSE improvement over linear regression: 12.9%
    Saved: ['fuzzy_control_surface.png', 'fuzzy_fixed_points.csv', 'fuzzy_memberships.png', 'metrics.csv', 'predicted_vs_actual.png', 'split.csv', 'temperature_humidity.png']
    ```
  ]

  #strong[What it means.] Test RMSE falls from about 0.537 to about 0.467. In `predicted_vs_actual.png` the straight line predicts negative CO at very low concentrations and under-predicts at high ones, while ANFIS stays near the diagonal at both ends. Whether 13 % is worth the extra complexity is your judgement, so state it and give a reason.
]

#yourturn[
  Add new cells at the end of the notebook for these three tasks.

  + #strong[Trace one more reading.] Work out $28^(compose)$C, 45 % by hand, then run `ventilation(28, 45)`. Which rules fire, and why is the answer above 50 %?
  + #strong[Debugging task.] Copy `ventilation` and delete `h["humid"]` from the `high` rule, so that it reads `high = t["hot"]`. Run it at $(25, 80)$ and explain the output. Then count how many points of the control-surface grid fire no rule at all. What does this say about checking a rule base?
  + #strong[One more size.] Fit `SugenoANFIS(n_mfs=4)` on the same training rows and compare its validation RMSE with the three-set model. How many rules does it have? Would you switch? Do not look at its test score to decide.
]

#expectedfindings[
  + Medium fires at $0.40$ and high at $0.11$, and the answer is $55.5 thin %$. Adding weight on the high side moves the balance point above 50.
  + At $(25,80)$ nothing fires: the reading is mild and humid, and “humid” was the only rule covering it. The output set is empty, so the centroid is $0\/0$ and the function returns `nan` with a warning. 99 of the 1,886 grid points have the same problem, whereas the full rule base has none. Coverage must be tested, not assumed.
  + 16 rules and a validation RMSE of about 0.445, against about 0.448 for 9 rules. The gain is small for nearly twice the rules, so staying with three sets is easy to defend. There is no single right answer here; the reasoning is the point.
]

#troubleshoot[
  / All columns are strings or `NaN`: The file uses `;` between fields and `,` for decimals. Keep `sep=";"` and `decimal=","` exactly as in Question~1.
  / `nan` from `ventilation`: No rule fired for that reading. See the debugging task above.
  / Slightly different ANFIS numbers: Expected across SciPy versions. Report your own numbers; the ordering should hold.
  / `LinAlgError: Singular matrix`: You removed the ridge term in `_solve_outputs`. Restore it.
]

#verification[
  - $-200$ values are treated as missing, and 9,357 hourly rows remain after cleaning.
  - The five fixed operating points land in their expected bands, and the control surface rises smoothly towards the hot-and-humid corner.
  - The split has 5,140, 1,102 and 1,102 rows, and the scaler is fitted on the training rows only.
  - The ANFIS candidate is chosen by validation RMSE before the test set is used.
  - The selected ANFIS lowers test RMSE relative to linear regression (about 0.467 against 0.537).
]

#labdeliverable[
  - Restart the kernel and run all cells without errors.
  - Submit the executed notebook, including your #emph[Your turn] cells, and the generated `results/lab04/` folder.
  - Add a short conclusion: justify the selected ANFIS size, explain why test data cannot guide model selection, and state one limitation of the random split.
]
