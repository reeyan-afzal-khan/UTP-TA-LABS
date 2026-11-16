#import "/.shared/typst/utp.typ": *
#unit("labs", "05-robotics")

#labsection(5, label: <sec:lab05-robotics>)[Robotics: Sensor-to-Action Control]

#labproject[Build and evaluate an interpretable wall-following controller][
  #strong[Read first.] Chapter~#ref(<ch:robotics>). \

  #strong[Goal.] Derive a four-sensor threshold policy, compare it with an all-sensor reference model, and test its sensitivity to sensor noise. \

  #strong[Scenario.] A SCITOS G5 robot must convert 24 ultrasonic readings into one of four movement commands while following a wall. \

  #strong[Data.] `all_datasets/lab05-sensor_readings_24.csv` (5,456 readings, no header: 24 distances in metres, then the action). \

  #strong[Notebook.] `all_experiments/lab05_robotics_sensor_control_worked.ipynb`. \

  #strong[Hand in.] The executed notebook, the `results/lab05/` folder and a short conclusion, as listed in the checklist at the end of this sheet.
]

#labsetup[
  + Activate your course environment and confirm that the data file is in `all_datasets/`.
  + Start Jupyter from `all_experiments/`, open the notebook, and choose #strong[Restart Kernel and Run All Cells]. Everything runs in a few seconds.

  ```terminal
  cd all_experiments
  jupyter lab
  ```

  Prefer a plain script? From the course folder, `python all_experiments/lab05_robotics_sensor_control_worked.py` runs the same code and writes the same evidence.
]

#include "visuals/05-flow.typ"

#labroutine

#exercises[
  #strong[Warm-up on paper.] Using the first levels of the learned tree in #figref(<fig:tree-rules>), decide what the controller does for these readings: (a) US14 $=0.81$; (b) US14 $=1.94$, US18 $=5.00$, US17 $=1.44$. Say in plain words what is happening around the robot in each case.

  #emph[Answer.] (a) Sharp-Right-Turn: the wall is close on the rear left, so steer away. (b) US14 and US18 are both large and US17 is above 0.90, so the tree goes down the branch that mostly says Slight-Left-Turn: the wall has fallen away, so edge back towards it.
]

#strong[Setup.] Run the imports and path setup first, and keep this kernel state for the later questions. In the script version the first seven lines also set the working directory.

#lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/lab05_robotics_sensor_control_worked.py", first: 1, last: 7, lang: "python")

#lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/lab05_robotics_sensor_control_worked.py", first: 8, last: 23, lang: "python")

#labquestion(1)[Inspect the data and fix the split][
  The CSV has no header: 24 ultrasonic distances (metres) followed by the action label. Name the columns, report the class balance and sensor summary statistics, and create a fixed stratified 70/30 train/test split with seed 42. Save the split.
]

#labanswer[
  #include "visuals/05-trace.typ"

  #lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/lab05_robotics_sensor_control_worked.py", first: 25, last: 38, lang: "python")

  #refoutput[
    ```terminal
    Shape: (5456, 25)
    Move-Forward 2205 (0.404)   Sharp-Right-Turn 2097 (0.384)
    Slight-Right-Turn 826 (0.151)   Slight-Left-Turn 328 (0.060)
    {'train': 3819, 'test': 1637}
    ```
  ]

  #strong[What it means.] The classes are imbalanced, so accuracy alone would flatter a model that ignores the small classes, and macro F1 is reported throughout. Sensor readings are distances in metres between 0.4~m and 5~m. Stratification keeps the class shares equal in the 3,819 training and 1,637 test rows. The notebook numbers the sensors from US00, the front sensor, clockwise to US23.
]

#labquestion(2)[Select four sensors using training data only][
  Rank the 24 sensors by mutual information with the action, computed on the training rows only, and keep the top four for the interpretable controller. Save the full ranking.
]

#labanswer[
  Read `selected` rather than hard-coding the names from a saved run:

  #include "visuals/05-worked-case.typ"

  #lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/lab05_robotics_sensor_control_worked.py", first: 40, last: 45, lang: "python")

  #refoutput[
    ```terminal
    Selected sensors: ['US14', 'US17', 'US18', 'US13']
    ```
  ]

  #strong[What it means.] The four most informative sensors come from the same rear-left arc of the ring, which is what a wall follower needs: the distance to the wall it is tracking, seen from slightly different angles. Selecting on training rows only keeps the test set untouched.
]

#strong[Connect it to the chapter.] The next questions fill in the “think” box of this loop. Remember that the dashed arrow is not tested here.

#include "visuals/05-robotics-chapter.typ"

#labquestion(3)[Fit an interpretable rule controller][
  A shallow decision tree is a fixed set of threshold rules. Carve an internal validation set out of the training rows, choose the tree depth by validation macro F1, refit on all training rows, and export the final tree as explicit if--then rules.
]

#labanswer[
  #lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/lab05_robotics_sensor_control_worked.py", first: 47, last: 65, lang: "python")

  #refoutput[
    ```terminal
    depth 2: 0.463   depth 3: 0.826   depth 4: 0.872   depth 5: 0.887   depth 6: 0.883
    Selected depth: 5 | leaves: 14
    |--- US14 <= 0.90
    |   |--- class: Sharp-Right-Turn
    |--- US14 >  0.90
    |   |--- US18 <= 1.00
    ...
    ```
  ]

  #strong[What it means.] Validation macro F1 climbs steeply from depth 2 to 4 and flattens at depth 5, which is selected. The exported tree reads as a policy. Its very first split, #emph[if the wall-side sensor US14 reads less than 0.9~m, turn sharply right], is the wall-following reflex, and the deeper splits refine the slight turns. Every decision is a threshold a robotics engineer can inspect.
]

#labquestion(4)[Fit a reference model][
  Train a random forest on all 24 sensors using the same training partition. It is not interpretable; its purpose is to show what accuracy the four-sensor rule controller gives up.
]

#labanswer[
  #lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/lab05_robotics_sensor_control_worked.py", first: 67, last: 70, lang: "python")

  #refoutput[
    ```terminal
    Random forest trained on 24 sensors with 200 trees
    ```
  ]

  #strong[What it means.] The forest uses every sensor and 200 trees, so it can exploit interactions the shallow tree cannot. It is the reference ceiling, not a candidate controller.
]

#labquestion(5)[Evaluate on the held-out data][
  Report accuracy, macro precision, macro recall and macro F1 for both models on the test rows, draw both confusion matrices, list per-class recall for the rule controller, and identify its hardest action.
]

#labanswer[
  #lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/lab05_robotics_sensor_control_worked.py", first: 72, last: 97, lang: "python")

  #labvisual[Reference plot from the supplied notebook][
    #fitted-image("/ARTIFICIAL INTELLIGENCE/labs/visuals/05-notebook-reference.png", width: 88%, height: 5cm)
  ]

  #refoutput[
    ```terminal
                         model  accuracy  macro_precision  macro_recall  macro_f1
    0  Interpretable rule tree     0.923            0.879         0.921     0.895
    1  Random-forest reference     0.995            0.993         0.992     0.992
    Hardest action for the rule controller (lowest recall): Slight-Right-Turn
    ```
  ]

  #strong[What it means.] The four-sensor tree reaches about 92 % accuracy and 0.90 macro F1; the all-sensor forest reaches over 99 % on both. The rule controller’s weakest action is Slight-Right-Turn, and 22 of its 27 misses are called Move-Forward: the line between carrying on and nudging right sits on thresholds that a few centimetres can cross. That is the accuracy cost of a controller a person can read.
]

#labquestion(6)[Test robustness to sensor noise][
  Add zero-mean Gaussian noise to the test readings at 2, 5 and 10 % of the training-set standard deviation of each selected sensor, and plot the rule controller’s macro F1 against the noise level.
]

#labanswer[
  #lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/lab05_robotics_sensor_control_worked.py", first: 99, last: 116, lang: "python")

  #refoutput[
    ```terminal
    noise   0%: 0.895     2%: 0.858     5%: 0.787     10%: 0.706
    Saved: ['confusion_matrices.png', 'feature_scores.csv', 'metrics.csv', 'noise_robustness.csv', 'noise_robustness.png', 'rule_controller.txt', 'rule_per_class.csv', 'split.csv']
    ```
  ]

  #strong[What it means.] Macro F1 falls steadily as noise pushes readings across thresholds. Even 5 % of one standard deviation costs about eleven points, because a hard threshold has no margin: a reading on the wrong side by one millimetre gets the other action.
]

#exercises[
  Add new cells at the end of the notebook for these three tasks.

  + #strong[Trace one test row.] Row 265 reads US14 $=1.173$, US17 $=0.718$, US18 $=0.686$ and US13 $=5.0$. Follow it through `rule_controller.txt` by hand, then confirm with `rule_model.predict(X.loc[[265], selected])`. Now change US14 to $0.85$ in a copy of the row and predict the new action.
  + #strong[How many sensors?] Rerun the validation comparison at depth 5 with the top 1, 2, 4, 8 and 24 sensors from `feature_table`. Use validation rows only. Where do extra sensors stop paying for themselves?
  + #strong[Respond to a 5 % noise budget.] Try two responses and compare their macro F1 on test readings with 5 % noise: retrain the four-sensor tree on noisy training readings, and fit a tree of depth 8 on the top eight sensors. State the cost of each.
]

#answers[
  + US14 $>0.90$; US18 $<= 1.00$ and $>0.50$; US13 $>0.90$; US17 $>0.49$: #strong[Move-Forward], which is also the true action. With US14 at $0.85$ the very first rule fires: #strong[Sharp-Right-Turn].
  + Validation macro F1 is 0.544, 0.803, 0.887, 0.943 and 0.967. The jump from one to four sensors is large, and after that each gain costs more sensors for less.
  + Retraining the four-sensor tree on noisy readings barely helps (about 0.79 on noisy readings) and costs clean performance (about 0.83 on clean readings). Eight sensors at depth 8 give about 0.82 on noisy readings and 0.94 on clean readings, at the price of 23 leaves instead of 14 and twice the sensors to maintain. Your numbers will vary a little with the random seed for the noise.
]

#tip[
  / Sensor names look wrong: The file has no header, so `header=None` and `names=...` must both be present, as in Question~1.
  / A feature-name warning at `predict`: You passed a NumPy array to a model fitted on a DataFrame. Wrap it in `pd.DataFrame(values, columns=selected)`.
  / Test scores much higher than the reference: You probably selected sensors or depth using test rows. Check that every `fit` before Question~5 uses training rows only.
]

#checklist[
  - The 5,456 readings are split 70/30 with stratification, and the split is saved.
  - The four sensors are selected by mutual information on the training rows only.
  - The tree depth is chosen by validation macro F1, and the final tree is exported as readable if--then rules.
  - On the test rows the rule controller reaches about 92 % accuracy and 0.90 macro F1, and its hardest action is identified.
  - Macro F1 is reported at every noise level, and you can explain why it falls.
]

#submission[
  - Restart the kernel and run all cells without errors.
  - Submit the executed notebook, including the cells you added for the exercises, and the generated `results/lab05/` folder.
  - Add a short conclusion: identify the hardest action, and recommend one response to a 5 % sensor-noise budget, including its trade-off.
]
