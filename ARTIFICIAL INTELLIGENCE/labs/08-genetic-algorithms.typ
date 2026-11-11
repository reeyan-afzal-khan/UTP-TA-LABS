#import "/.shared/typst/utp.typ": *
#unit("labs", "08-genetic-algorithms")

#lab("8")[Genetic Algorithms: Regression and Reproducibility] <sec:lab08-ga>

#callout("labproject", title: [Fit a medical-cost regression model with a Genetic Algorithm])[#strong[Read first.] Chapters~#ref(label("ch:localsearch"), supplement: none) and~#ref(label("ch:ga"), supplement: none). \
#strong[Goal.] Verify a NumPy GA, evaluate it across ten seeds, and compare it with exact least squares. \
#strong[Scenario.] Test whether a real-valued GA can recover useful linear-regression coefficients, and compare its stochastic behaviour with an exact baseline. \
#strong[Data.] `all_datasets/lab08-insurance.csv` (1,338 policies). \
#strong[Notebook.] `all_experiments/lab08_genetic_algorithm_regression_worked.ipynb`. \
#strong[Hand in.] The executed notebook, the `results/lab08/` folder and a short conclusion, as listed in the checklist at the end of this sheet.]

#callout("labmode", title: [Lab setup])[+ Activate your course environment and confirm that the data file is in `all_datasets/`.

+ Start Jupyter from `all_experiments/`, open the notebook, and choose #strong[Restart Kernel and Run All Cells]. Everything runs in a few seconds.

#code-block("cd all_experiments\njupyter lab", lang: "text") Prefer a plain script? From the course folder, `python all_experiments/lab08_genetic_algorithm_regression_worked.py` runs the same code and writes the same evidence.]


#include "/ARTIFICIAL INTELLIGENCE/labs/visuals/08-flow.typ"


#strong[How to work through this sheet.] Predict the result, run the matching notebook cell, compare with the reference output, and explain the result in your own words.

#callout("yourturn", title: [Your turn])[#strong[Warm-up on paper.] Run one generation of a GA by hand, minimising $f \( x \) = \( x - 3 \)^2$, with the population $x = { - 4 \, med 1 \, med 5 \, med 8 }$. Compute each fitness and keep one elite. Hold a tournament of two between $x = 1$ and $x = 8$, and another between $x = - 4$ and $x = 5$. Blend the two winners with $alpha = 0.5$. Is the child better than both parents here?

#emph[Answer.] Fitness: $49$, $4$, $4$, $25$. The elite is $x = 1$ or $x = 5$ (they tie). The tournaments are won by $x = 1$ and $x = 5$. The blended child is $0.5 times 1 + 0.5 times 5 = 3$, with fitness 0, the exact answer. Blending two points either side of the optimum is why crossover is so strong here, and why real problems are rarely this kind.]

#strong[Setup.] Run the imports and path setup first, and keep this kernel state for the later questions. In the script version the first seven lines also set the working directory. #source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab08_genetic_algorithm_regression_worked.py", first: 1, last: 7, lang: "python") #source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab08_genetic_algorithm_regression_worked.py", first: 8, last: 23, lang: "python")

#callout("labquestion", title: [Question 1 --- Verify the evolutionary loop])[Before touching real data, minimise $f \( x \) = \( x - 3 \)^2$ with a small real-valued GA (tournament selection, blend crossover, Gaussian mutation, two elites) and confirm that the best solution approaches $x = 3$.] #callout("labanswer", title: [Worked answer])[
#include "/ARTIFICIAL INTELLIGENCE/labs/visuals/08-trace.typ"
 #source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab08_genetic_algorithm_regression_worked.py", first: 25, last: 45, lang: "python") *Reference output.*

#code-block("Best x = 2.999989   f(x) = 0.00000000", lang: "text")

#strong[What it means.] The best individual lands about $10^(- 5)$ from $x = 3$ after 80 generations. The loop (evaluate, keep elites, select by tournament, blend, mutate, replace) is the same loop the regression GA uses below, so a bug would show up here first.]

#callout("labquestion", title: [Question 2 --- Prepare the regression task])[Predict charges from age, BMI, number of children and smoker status (0/1). Split 80/20 with seed 42, standardise the predictors with training statistics only, and save the split.] #callout("labanswer", title: [Worked answer])[#source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab08_genetic_algorithm_regression_worked.py", first: 47, last: 57, lang: "python") *Reference output.*

#code-block("{'rows': 1338, 'train': 1070, 'test': 268, 'predictors': ['age', 'bmi', 'children', 'smoker']}", lang: "text")

#strong[What it means.] 1,070 training and 268 test rows. Standardising the inputs puts all four coefficients on a comparable scale, which matters for a GA because one mutation step size is used for every coefficient gene.]

#strong[Connect it to the chapter.] Every generation below goes once around this loop. 
#include "/ARTIFICIAL INTELLIGENCE/labs/visuals/08-genetic-algorithms-chapter.typ"


#callout("labquestion", title: [Question 3 --- Define the chromosome, fitness and operators])[A chromosome has five real-valued genes: the intercept and four coefficients. Fitness is the training mean squared error. Write `run_ga` with tournament selection, blend crossover, Gaussian mutation and elitism, returning train RMSE, test RMSE, runtime and the best-so-far history. Run it once to check that it works.] #callout("labanswer", title: [Worked answer])[Keep the mapping from genes to the intercept and coefficients fixed, and inspect the prediction expression inside `run_ga` before changing mutation: 
#include "/ARTIFICIAL INTELLIGENCE/labs/visuals/08-worked-case.typ"


#source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab08_genetic_algorithm_regression_worked.py", first: 59, last: 95, lang: "python") *Reference output.*

#code-block("seed 1: train RMSE 6113.1 | test RMSE 5829.4 | 0.04 s\nBest chromosome [intercept, age, bmi, children, smoker]: [13346.1  3616.3  1978.4   519.2  9559.3]", lang: "text")

#strong[What it means.] One run of 160 generations with a population of 100 takes a fraction of a second and already produces a coefficient vector with a large positive smoker effect, as expected. Each gene is a coefficient, so the GA searches the same space as least squares, only without gradients. A low training error is not by itself evidence of generalisation, so read the test RMSE across seeds next.]

#callout("labquestion", title: [Question 4 --- Run ten independent seeds])[Repeat the GA for seeds 1--10, save train RMSE, test RMSE and runtime per seed to `ga_10_runs.csv`, and summarise the spread across seeds.] #callout("labanswer", title: [Worked answer])[#source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab08_genetic_algorithm_regression_worked.py", first: 97, last: 105, lang: "python") *Reference output.*

#code-block("Median test RMSE 5829.38 | SD across seeds 0.0019", lang: "text")

#strong[What it means.] All ten seeds converge to practically the same solution: the standard deviation of test RMSE across seeds is a few thousandths on a scale of thousands. This is the reproducibility evidence a single lucky run cannot provide.]

#callout("labquestion", title: [Question 5 --- Compare with least squares])[Fit ordinary least squares on the identical split and preprocessing, compare its test RMSE and coefficients with the GA, and plot the best-so-far training RMSE of five seeds against the OLS training RMSE.] #callout("labanswer", title: [Worked answer])[#source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab08_genetic_algorithm_regression_worked.py", first: 107, last: 121, lang: "python") #callout("labvisual", title: [Reference plot from the supplied notebook])[#image("/ARTIFICIAL INTELLIGENCE/labs/visuals/08-notebook-reference.png", width: 90%)] *Reference output.*

#code-block("OLS test RMSE: 5829.38\nOLS coefficients:    [3616.3 1978.4  519.2 9559.3]\nMedian GA coefficients: [3616.3 1978.4  519.2 9559.3]", lang: "text")

#strong[What it means.] The GA's median test RMSE equals the OLS test RMSE to within rounding, and its coefficients match the OLS coefficients. Every seed drops onto the OLS line within a few dozen generations. The GA has #emph[found] the optimum; it has not #emph[beaten] it. For an unconstrained least-squares problem the closed-form solution is exact and far cheaper.]

#callout("labquestion", title: [Question 6 --- Run one sensitivity study])[Reduce the population from 100 to 40, repeat the ten seeds, and compare median test RMSE, its spread and runtime for both settings and OLS. Save `ga_sensitivity_pop40.csv` and `summary.csv`.] #callout("labanswer", title: [Worked answer])[#source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab08_genetic_algorithm_regression_worked.py", first: 123, last: 133, lang: "python") *Reference output.*

#code-block("method  median_test_rmse  sd_test_rmse  median_runtime_s\n0  GA pop=100         5829.3787        0.0019            0.0391\n1   GA pop=40         5829.3819        0.0255            0.0176\n2         OLS         5829.3785        0.0000               NaN\nSaved: ['convergence.png', 'ga_10_runs.csv', 'ga_sensitivity_pop40.csv', 'split.csv', 'summary.csv']", lang: "text")

#strong[What it means.] Forty chromosomes halve the runtime with the same median, and increase the seed-to-seed spread by more than ten times. On this easy problem both are fine. On a problem where a poor run is expensive, the spread is what you would be buying with those extra chromosomes.]

#callout("yourturn", title: [Your turn])[Add new cells at the end of the notebook. For every task, hold the split fixed, repeat over seeds 1--10, and report the median and standard deviation of test RMSE beside the OLS result. A helper saves typing: #code-block("def study(**settings):\n    scores = [run_ga(seed, **settings)[\"test_rmse\"] for seed in range(1, 11)]\n    return round(np.median(scores), 2), round(np.std(scores, ddof=1), 4)\nprint(study(mutation_rate=0.0), study(mutation_rate=0.05), study(mutation_rate=0.5))", lang: "python")

+ #strong[Mutation.] Try `mutation_rate` 0, 0.05, 0.15 and 0.5, then `mutation_scale` 0.01, 0.05, 0.25 and 1. What happens with no mutation at all, and why?

+ #strong[Budget.] Try `generations` 10, 20, 40 and 80. Where does extra budget stop paying?

+ #strong[Selection pressure.] Copy `run_ga` and change the tournament size from 3 to 1, which means no selection at all. One result will look odd: the median test RMSE can fall #emph[below] the OLS value. Does that mean the GA has beaten least squares?

+ #strong[Write down one change] to the problem that would make a GA more appropriate than OLS, and what you would have to change in the fitness function or operators.]

#callout("expectedfindings", title: [Expected findings])[+ With no mutation the median stays at about 6,534 with a spread of about 252: blending can only contract the population, so it collapses before reaching the optimum. Rates 0.05, 0.15 and 0.5 all reach about 5,829, with the tightest spread at 0.15. A scale of 0.01 is too timid (about 6,198); 0.05 and above reach the optimum.

+ Median test RMSE is about 6,317, 5,952, 5,830 and 5,829.38. Almost nothing is gained after 80 generations, and the lab's 160 is a safe margin.

+ With tournament size 1 the median is about 5,828.9 with a spread of about 11.5. It has not beaten anything. OLS minimises #emph[training] error, and it does so exactly. A run that has not converged can land closer to the test rows by chance, and the large spread is the giveaway. Its training RMSE is worse.

+ Integer coefficients, a penalty on the number of non-zero coefficients, or a black-box cost all fit. Least squares no longer applies, so the fitness function changes, and integer genes would need new crossover and mutation.]

#callout("troubleshoot", title: [Troubleshooting])[/ The GA never approaches OLS: #block[
Check the fitness sign (lower is better here) and that `X_train` is the standardised matrix.
]

/ Results differ on every run: #block[
Pass the seed through to `np.random.default_rng(seed)`. Do not use the global NumPy generator.
]

/ A shape error in `training_mse`: #block[
Keep `individuals[:, [0]]` with the inner brackets, so that the intercept column broadcasts across the rows.
]]

#callout("verification", title: [Verification checklist])[- The test GA finds $x approx 3$ for $f \( x \) = \( x - 3 \)^2$ before it is used on real data.

- The predictors are standardised with training statistics only (1,070 training and 268 test rows).

- Ten seeds are run, and `ga_10_runs.csv` records train RMSE, test RMSE and runtime for each.

- The GA's median test RMSE equals the least-squares test RMSE, and you can explain why it cannot beat it on training error.

- The population-40 sensitivity run is saved and its larger spread across seeds is explained.]

#callout("labdeliverable", title: [Submission checklist])[- Restart the kernel and run all cells without errors.

- Submit the executed notebook, including your #emph[Your turn] cells, and the generated `results/lab08/` folder.

- Add a short conclusion: report the median and spread, explain why matching OLS is not beating it, and name one problem change that would make a GA more appropriate.]
