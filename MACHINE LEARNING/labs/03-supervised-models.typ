#import "/.shared/typst/utp.typ": *
#unit("labs", "03-supervised-models")

#lab("3")[Supervised learning II: model families] <sec:lab03-supervised-models>

#callout("labproject", title: [Neighbors, naive Bayes, trees, ensembles, and support vector machines on one workflow])[#strong[Read first.] Chapters~#ref(label("ch:knn-nb"), supplement: none)--#ref(label("ch:svm"), supplement: none). \
#strong[Goal.] Compare model families under Lab~2's fixed validation workflow on a hard, real credit problem: see the boundary each family draws, read a tree's rules and watch it overfit, check whether ensembles earn their cost, and tune an SVM's two dials. \
#strong[Scenario.] A lender wants to know which applicants will default, and the used-car dealer from Lab~2 wants better prices than a straight line. You decline to pick a model from reputation: hold the split and metric fixed, change one family at a time, and let the evidence decide, including when it says the simpler model is enough. \
#strong[Data.] In `all_datasets/ supervised/`: `lending_club/ lending_club_2014_2015.zip`, 100,000 finished personal loans that Lending Club, a US lender, issued in 2014 and 2015; `used_cars/ used_cars.zip` from Lab~2; and `sms_spam/ sms_spam.csv`, 5,572 text messages from the UCI repository, in the Try-it. \
#strong[Notebook.] `all_experiments/ lab03_supervised_models/ lab03_supervised_models_worked.ipynb`, with a README beside it. \
#strong[Hand in.] The executed notebook, `results/lab03/`, the saved SVM and a short conclusion, as listed in the checklist at the end of this sheet.]

#heading(level: 2, numbering: none)[Your map of this lab]
#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    [Part], [What you do], [Questions],
    [A], [Rank loan defaults with KNN and naive Bayes; draw their boundaries], [2--5],
    [B], [Read a small tree's rules, then watch a deep tree overfit], [6--8],
    [C], [Compare a forest with boosting on used-car prices], [9--10],
    [D], [Tune an SVM, map its two dials, save and verify it], [11--13],
    [Finish], [Save the evidence; then classify text messages as spam], [14--16],
    [After], [Your-turn tasks, expected findings, troubleshooting and the two checklists], [---],
  )]
  , kind: table
  )

#callout("labmode", title: [Lab setup])[+ Activate your course environment and confirm the three data files are in `all_datasets/ supervised/`.

+ Check the small worked numbers of the model chapters. The last line must read `Every number above matches the book.`

+ From the course folder, start Jupyter, open the notebook, and choose #strong[Restart Kernel and Run All Cells]. It takes about two minutes; the neighbor search in Question~3 and the SVMs in Questions~11 and~12 take most of it.

#code-block("python all_experiments/book_checks/demo_model_families.py\njupyter lab", lang: "text") Prefer a plain script? From the course folder, `python all_experiments/ lab03_supervised_models/ lab03_supervised_models_worked.py` runs the same code and writes the same evidence.]

#strong[How to work through this sheet.] Predict the result, run the matching notebook cell, compare with the reference output, and explain the result in your own words.

#callout("yourturn", title: [Your turn])[#strong[Warm-up on paper.] Do these before opening the notebook; the code will check you.

+ 959 of the 5,000 validation loans default. What accuracy does a model that always says "repaid" score, and why does that make accuracy a poor way to compare the models below?

+ Two applicants ask for \$10,000 and \$15,000, with FICO credit scores of 700 and 680. In the training loans the amounts have a standard deviation of \$8,487 and the scores of 30.3. Which difference decides the distance between them in raw units, and which after scaling?]

#callout("labquestion", title: [Question 1 --- Setup])[Run this first, and keep this kernel for the later questions. Every lab starts the same way. `start_lab()`, from `all_experiments/ course_setup.py`, finds the course folder and returns the three folders the lab uses: `DATA` to read from, `RESULTS` and `MODELS` to write to. The imports in between are grouped by what they are for.] #callout("labanswer", title: [Worked answer])[#source-code("/MACHINE LEARNING/all_experiments/lab03_supervised_models/lab03_supervised_models_worked.py", first: 11, last: 39, lang: "python") *Reference output.*

#code-block("course folder: MACHINE LEARNING\nreads all_datasets/, writes results/lab03/ and models/", lang: "text")]

#callout("labpart", title: [Part A --- Neighbors and naive Bayes])[*Goal.* Rank loan defaults with two simple model families, and see why accuracy hides the difference.

Questions 2--5 •~Data: Lending Club loans, 2014 and 2015]

#callout("labquestion", title: [Question 2 --- Read the loans and split them])[Each row is one finished loan, and `loan_status` says whether it was paid in full or charged off, written off as a default. The cell builds thirteen numbers the lender knew when it approved the loan: the amount, the term, the interest rate, the borrower's income, debt-to-income ratio (DTI) and FICO credit score, and seven more from the application and the credit file. The data card's eight columns written after the loan was issued, like Lab~1's `reservation_status`, never enter a model. A random 20,000 loans keep nearest neighbors and SVMs fast on a laptop, and `stratify` keeps the default rate the same in both halves.] #callout("labanswer", title: [Worked answer])[
#include "/MACHINE LEARNING/labs/visuals/03-trace.typ"
 #source-code("/MACHINE LEARNING/all_experiments/lab03_supervised_models/lab03_supervised_models_worked.py", first: 41, last: 75, lang: "python") *Reference output.*

#code-block("shape: (100000, 40)\nloan_status\nFully Paid     80630\nCharged Off    19370\nmissing values: {'dti': 1, 'revol_util': 39, 'emp_years': 5542}\n15000 training and 5000 validation loans; 959 validation defaults", lang: "text")

#strong[What it means.] 19.4% of the loans were charged off. The text columns needed work before they could become numbers: the term arrives as " 36 months", employment length as "10+ years" or "\< 1 year", and the credit history as two month names to subtract. A few gaps remain, mostly the employment length of 5,542 borrowers; the median of the training loans fills them inside every pipeline. The other 80,000 loans wait, untouched, for Part~D's test.]

#callout("labquestion", title: [Question 3 --- Choose $k$ by cross-validation])[$k$ is chosen by five-fold cross-validation on the training rows only, scored by ROC AUC because accuracy says little when 81% of loans are repaid. The imputer and the scaler sit inside the pipeline, so each fold fills and scales with its own training rows.] #callout("labanswer", title: [Worked answer])[
#include "/MACHINE LEARNING/labs/visuals/03-worked-case.typ"
 #source-code("/MACHINE LEARNING/all_experiments/lab03_supervised_models/lab03_supervised_models_worked.py", first: 77, last: 99, lang: "python") #callout("labvisual", title: [Reference plot from the supplied notebook])[#image("/MACHINE LEARNING/labs/visuals/03-notebook-reference.png", width: 90%)] *Reference output.*

#code-block("k=   1  cross-validated ROC AUC = 0.552\nk=   5  cross-validated ROC AUC = 0.632\nk=  25  cross-validated ROC AUC = 0.692\nk= 101  cross-validated ROC AUC = 0.710\nk= 201  cross-validated ROC AUC = 0.716\nk= 401  cross-validated ROC AUC = 0.717\nk= 801  cross-validated ROC AUC = 0.719\nk=1601  cross-validated ROC AUC = 0.718\nk=3201  cross-validated ROC AUC = 0.717\nselected k: 801", lang: "text")

#strong[What it means.] One borrower's nearest neighbor says almost nothing about them (0.552, barely above a coin toss), but the default rate among hundreds of similar borrowers does. The curve rises steeply, then levels off past $k = 201$: on noisy data a neighborhood must be large before its vote is informative. $k = 801$ is about 7% of the 12,000 loans in each fold's training part.]

#callout("labquestion", title: [Question 4 --- Compare KNN with naive Bayes])[The chosen KNN against Gaussian naive Bayes, with Lab~2's logistic regression as a reference, on the validation loans. Accuracy is printed only to show why it is the wrong metric here; average precision is the honest one for the rarer class.] #callout("labanswer", title: [Worked answer])[#source-code("/MACHINE LEARNING/all_experiments/lab03_supervised_models/lab03_supervised_models_worked.py", first: 101, last: 114, lang: "python") *Reference output.*

#code-block("always 'repaid' would be 0.808 accurate\nKNN        accuracy=0.808 roc_auc=0.723 average_precision=0.379\nGaussianNB accuracy=0.773 roc_auc=0.716 average_precision=0.350\nlogistic   accuracy=0.811 roc_auc=0.731 average_precision=0.387", lang: "text")

#strong[What it means.] KNN's accuracy equals the baseline's: at 0.5 it never predicts a default, because no loan has a majority of defaulters among its 801 neighbors. Naive Bayes is #emph[less] accurate than always saying "repaid", yet it ranks loans nearly as well as KNN. Only the ranking metrics separate the models, and even they separate them by little: average precision is nearly twice the guessing rate of 0.192 for all three, and the simple logistic regression edges ahead.]

#callout("labquestion", title: [Question 5 --- Draw the boundaries on two columns])[Two columns only, the interest rate and the debt-to-income ratio, so the boundary can be drawn. Shading is each model's predicted default probability, and crosses are real defaults. Logistic regression draws straight bands, naive Bayes curved ones, and KNN follows the data.] #callout("labanswer", title: [Worked answer])[#source-code("/MACHINE LEARNING/all_experiments/lab03_supervised_models/lab03_supervised_models_worked.py", first: 116, last: 142, lang: "python") *Reference output.*

#code-block("Logistic regression    on interest rate and DTI only: ROC AUC 0.714\nKNN (k=801)            on interest rate and DTI only: ROC AUC 0.714\nGaussian naive Bayes   on interest rate and DTI only: ROC AUC 0.712", lang: "text")

#strong[What it means.] Three shapes, one score. Defaults are scattered through every region of the plane, and the risk rises smoothly with the interest rate, so any reasonable boundary does as well as any other. On two columns the families score within 0.02 of the thirteen-column models of Question~4: the interest rate carries most of the signal, a point Your-turn task~4 measures. On noisy credit data the data, not the algorithm, sets the ceiling.]

#callout("labcheckpoint", title: [Checkpoint: before you move on])[- 959 validation defaults, so always saying "repaid" is already 0.808 accurate.

- KNN reaches ROC AUC 0.723 and average precision 0.379; naive Bayes 0.716 and 0.350.]

#callout("labpart", title: [Part B --- One tree: readable rules and overfitting])[*Goal.* Fit a tree small enough to read, see what it learned about lending, then watch a deeper tree overfit.

Questions 6--8 •~Data: Lending Club loans]

#callout("labquestion", title: [Question 6 --- Fit a readable tree])[A tree needs no scaling, but scikit-learn's trees need every gap filled, so the training median fills them first. A depth-3 tree has at most eight leaves: few enough to read. Watch how many loans it flags at the usual 0.5 cutoff.] #callout("labanswer", title: [Worked answer])[#source-code("/MACHINE LEARNING/all_experiments/lab03_supervised_models/lab03_supervised_models_worked.py", first: 144, last: 155, lang: "python") *Reference output.*

#code-block("validation ROC AUC: 0.715  average precision: 0.338\nloans flagged at 0.5: 0\ndefault rate in each leaf: [0.055, 0.097, 0.149, 0.209, 0.244, 0.292, 0.344, 0.475]", lang: "text")

#strong[What it means.] The tree flags no loan at all at 0.5, because no leaf holds more defaults than repayments. Judged by its decisions it is useless; judged by its ranking, from a 5.5% default rate in the safest leaf to 47.5% in the riskiest, it is nearly as good as the models of Part~A. A lender would act on those rates, with a cutoff of its own.]

#callout("labquestion", title: [Question 7 --- Read the tree's rules])[A depth-3 tree is a set of if-then rules small enough to print. `show_weights` adds, for each leaf, how many training loans were repaid and how many defaulted, so each rule comes with its own default rate. Ask which columns the tree chose, and who chose those columns' values.] #callout("labanswer", title: [Worked answer])[#source-code("/MACHINE LEARNING/all_experiments/lab03_supervised_models/lab03_supervised_models_worked.py", first: 157, last: 168, lang: "python") *Reference output.*

#code-block("|--- int_rate <= 14.0\n|   |--- int_rate <= 10.3\n|   |   |--- int_rate <= 7.9\n|   |   |   |--- weights: [2260.0, 131.0] class: 0\n|   |   |--- int_rate >  7.9\n|   |   |   |--- weights: [2158.0, 231.0] class: 0\n|   |--- int_rate >  10.3\n|   |   |--- term_months <= 48.0\n|   |   |   |--- weights: [3309.0, 581.0] class: 0\n|   |   |--- term_months >  48.0\n|   |   |   |--- weights: [663.0, 214.0] class: 0\n|--- int_rate >  14.0\n|   |--- term_months <= 48.0\n...\n|   |--- term_months >  48.0\n|   |   |--- mort_acc <= 1.5\n|   |   |   |--- weights: [709.0, 641.0] class: 0\n|   |   |--- mort_acc >  1.5\n|   |   |   |--- weights: [789.0, 414.0] class: 0", lang: "text")

#strong[What it means.] The rules read like a credit policy, and they use almost nothing but the interest rate and the term. The riskiest branch is a rate above 14.0% on a 60-month loan, for a borrower with at most one mortgage account: 641 of its 1,350 training loans defaulted. The interest rate is the price the lender set from its own risk grade, so on that column the tree has largely learned the lender's assessment back. That is not a flaw of the tree; it is what the data holds, and it is worth knowing before claiming a model "discovered" anything.]

#callout("labquestion", title: [Question 8 --- Grow the tree and watch it overfit])[The same tree with ten depth limits, scored by average precision on the training and validation rows. Deeper trees can always fit the training rows better; the question is when validation stops agreeing.] #callout("labanswer", title: [Worked answer])[#source-code("/MACHINE LEARNING/all_experiments/lab03_supervised_models/lab03_supervised_models_worked.py", first: 170, last: 192, lang: "python") *Reference output.*

#code-block("max_depth=   1  leaves=   2  training AP=0.266  validation AP=0.265\nmax_depth=   2  leaves=   4  training AP=0.317  validation AP=0.310\nmax_depth=   3  leaves=   8  training AP=0.344  validation AP=0.338\nmax_depth=   4  leaves=  16  training AP=0.363  validation AP=0.350\nmax_depth=   5  leaves=  31  training AP=0.388  validation AP=0.349\n...\nmax_depth=  15  leaves=1289  training AP=0.873  validation AP=0.244\nmax_depth=None  leaves=2408  training AP=1.000  validation AP=0.226", lang: "text")

#strong[What it means.] Validation peaks at depth~4 (0.350) and then falls, while training climbs to a perfect 1.000 for the unrestricted tree with 2,408 leaves. That tree has memorized the training loans, one leaf per handful of borrowers, and on new loans it scores 0.226, little above the 0.192 that guessing scores. On noisy data a tree overfits early: the useful depth is shallow, and the gap between the two curves is the overfitting you can see.]

#strong[Connect it to the chapter.] The next question moves from one tree to many. A vote among many tree-like opinions is the same idea as this picture of neighbors voting. 
#include "/MACHINE LEARNING/labs/visuals/03-supervised-models-chapter.typ"


#callout("labcheckpoint", title: [Checkpoint: before you move on])[- The depth-3 tree flags no loan at 0.5, yet ranks them with ROC AUC 0.715; its leaves run from 5.5% to 47.5% default.

- Validation average precision peaks at depth~4 (0.350), while training keeps climbing to 1.000.]

#callout("labpart", title: [Part C --- Many trees: forest against boosting])[*Goal.* Compare two tree ensembles on Lab~2's used-car prices, and see which features they rely on.

Questions 9--10 •~Data: used-car listings from Cars.com]

#callout("labquestion", title: [Question 9 --- Compare forest and boosting on car prices])[Back to Lab~2's car listings, with the same cleaning rules, the log of the price as the label, and the car's `model` included this time. Trees split on numbers, so each category becomes a code; a tree can still isolate a make or a model with a few splits. The boosting model is scikit-learn's histogram-based gradient boosting, the fast version built for tables with many rows. Three folds give three scores per family, so the gap between the families can be compared with the spread within each one.] #callout("labanswer", title: [Worked answer])[#source-code("/MACHINE LEARNING/all_experiments/lab03_supervised_models/lab03_supervised_models_worked.py", first: 194, last: 244, lang: "python") *Reference output.*

#code-block("random_forest      CV log-RMSE = 0.2083 +/- 0.0014   folds [0.2086 0.21   0.2065]\ngradient_boosting  CV log-RMSE = 0.1941 +/- 0.0008   folds [0.1945 0.1947 0.193 ]", lang: "text")

#strong[What it means.] Boosting wins on every fold, and the gap, 0.014, is ten times either family's spread across folds, so it is real. Each forest tree is grown independently on a bootstrap sample and the trees are averaged, which steadies the prediction; boosting grows each tree to correct the errors of the ones before it, which lowers the error itself.]

#callout("labquestion", title: [Question 10 --- See what the boosted trees used])[One boosted model on a 75/25 split, scored in dollars, then permutation importance: shuffle one column on the validation rows and measure how much worse the predictions get.] #callout("labanswer", title: [Worked answer])[#source-code("/MACHINE LEARNING/all_experiments/lab03_supervised_models/lab03_supervised_models_worked.py", first: 246, last: 276, lang: "python") *Reference output.*

#code-block("validation MAE in dollars: 4453  R2 in dollars: 0.843\nage              0.357\nmileage_miles    0.323\nmake             0.219\nmodel            0.147\ndrive            0.084\nbody_type        0.052\nfuel_type        0.010\ncpo              0.001", lang: "text")

#strong[What it means.] The boosted trees miss a typical listing by \$4,453 and explain 84.3% of the variation in price, against Lab~2's straight line at \$9,009 and 57.5%, and its log-price line at \$7,695. Age and mileage matter most, then the make and the model: the trees found how a car loses value, and which car it is, without a single hand-made feature. Permutation importance measures what the model uses, not what causes a price, and two related columns, such as make and model, share their credit.]

#callout("labcheckpoint", title: [Checkpoint: before you move on])[- Cross-validated log-RMSE: 0.2083 for the forest, 0.1941 for boosting.

- Boosting misses a typical listing by \$4,453, with $R^2$ 0.843 in dollars; age and mileage matter most.]

#callout("labpart", title: [Part D --- Support vector machines])[*Goal.* Tune an SVM's two dials by cross-validation, test it once on loans no part has seen, then save the model and check that it reloads.

Questions 11--13 •~Data: Lending Club loans]

#callout("labquestion", title: [Question 11 --- Tune an SVM])[Back to the loans. Parts~A and~B compared models on the validation loans, so the test set is 20,000 of the 80,000 loans outside the sample, which no part has touched. The grid crosses a linear kernel with two values of `C`, and an RBF kernel with three of `C` and three of `gamma`, scored by three-fold ROC AUC on the training loans. Balanced class weights stop the SVM from calling every loan repaid.] #callout("labanswer", title: [Worked answer])[#source-code("/MACHINE LEARNING/all_experiments/lab03_supervised_models/lab03_supervised_models_worked.py", first: 278, last: 306, lang: "python") *Reference output.*

#code-block("best parameters: {'model__C': 0.1, 'model__gamma': 0.01, 'model__kernel': 'rbf'}\ncross-validated ROC AUC: 0.718\ntest ROC AUC: 0.716  test average precision: 0.375\nat the default boundary: precision 0.34  recall 0.543", lang: "text")

#strong[What it means.] The winner is the smoothest, most regularized setting in the grid, and the test score on 20,000 fresh loans agrees with the cross-validated one. With balanced weights the boundary flags enough loans to catch 54.3% of the defaults, at a precision of 0.34: one flagged loan in three really defaults.]

#callout("labquestion", title: [Question 12 --- Map the two dials])[The RBF part of the grid as a heatmap, then two small SVMs on the interest rate and the debt-to-income ratio alone, drawn so the difference between the kernels is visible.] #callout("labanswer", title: [Worked answer])[#source-code("/MACHINE LEARNING/all_experiments/lab03_supervised_models/lab03_supervised_models_worked.py", first: 308, last: 346, lang: "python") *Reference output.*

#code-block("gamma            0.01    0.1  scale\nparam_model__C\n0.1             0.718  0.713  0.714\n1.0             0.715  0.702  0.707\n10.0            0.714  0.647  0.665", lang: "text")

#strong[What it means.] A small `gamma` makes each training loan's influence wide and the boundary smooth; a large `C` lets the boundary bend to fit every training loan. Together, `gamma` 0.1 and `C` 10 overfit and score worst, 0.647. On two columns, the linear and the RBF kernels score 0.70 and 0.69: a curved boundary has nothing to follow here.]

#callout("labquestion", title: [Question 13 --- Save and verify the model])[Save the winning pipeline and check that the file reproduces the test predictions exactly before calling it done.] #callout("labanswer", title: [Worked answer])[#source-code("/MACHINE LEARNING/all_experiments/lab03_supervised_models/lab03_supervised_models_worked.py", first: 348, last: 354, lang: "python") *Reference output.*

#code-block("file size (KB): 1393.0\nreloaded model reproduces the test predictions: True", lang: "text")

#strong[What it means.] The file is large for a model of thirteen inputs, because an SVM keeps its support vectors, the training loans that define its boundary, and on noisy data that is most of them; Your-turn task~3 counts them.]

#callout("labcheckpoint", title: [Checkpoint: before you move on])[- Best: RBF kernel, `C` = 0.1, `gamma` = 0.01; cross-validated ROC AUC 0.718, test 0.716.

- The reloaded model reproduces the test predictions.]

#callout("labpart", title: [Finish --- Save the evidence, then try it yourself])[*Goal.* Write the results folder, then extend the lab yourself before reading one worked solution.

Questions 14--16]

#callout("labquestion", title: [Question 14 --- Save the evidence])[Write the numbers above to the results folder. These files are regenerated on every run, so do not edit them by hand.] #callout("labanswer", title: [Worked answer])[#source-code("/MACHINE LEARNING/all_experiments/lab03_supervised_models/lab03_supervised_models_worked.py", first: 356, last: 376, lang: "python") *Reference output.*

#code-block("Saved: ['car_price_fold_scores.csv', 'choosing_k_on_training_data_only.png',\n 'deeper_trees_memorize_validation_peaks_and_falls.png', 'fold_by_fold_is_the_gap_bigger_than_the_spread.png',\n 'knn_selection.csv', 'loan_tree_rules.txt', 'metrics.csv', 'svm_grid_search.csv', 'the_fitted_loan_tree.png',\n 'three_boundaries_on_rate_and_dti.png', 'two_dials_and_two_kernels.png', 'what_the_boosted_trees_used.png']", lang: "text")]

#heading(level: 2, numbering: none)[Try it yourself]
#callout("labquestion", title: [Question 15 --- Try it yourself])[Naive Bayes is famous for text. Load `supervised/ sms_spam/ sms_spam.csv`, turn each message into word counts with `CountVectorizer`, and compare `MultinomialNB` with a nearest-neighbor classifier on tf-idf vectors. Report ROC AUC, precision and recall, and list the words that most raise the spam odds. Attempt it in this empty cell before reading the solution.]

#callout("labquestion", title: [Question 16 --- One solution])[The same split-fit-score workflow, with a vectorizer in front of each model. The vectorizer learns its vocabulary from the training messages only, because it sits inside the pipeline.] #callout("labanswer", title: [Worked answer])[#source-code("/MACHINE LEARNING/all_experiments/lab03_supervised_models/lab03_supervised_models_worked.py", first: 380, last: 410, lang: "python") *Reference output.*

#code-block("messages: 5572  spam share: 0.134  repeated messages: 403\nnaive Bayes on word counts   ROC AUC=0.982  precision=0.988  recall=0.909\nKNN (k=5) on tf-idf, cosine  ROC AUC=0.973  precision=0.987  recall=0.824\nwords that most raise the spam odds: ['claim', 'prize', '150p', 'tone', 'cs', '500', 'guaranteed',\n '18', '1000', 'landline']", lang: "text")

#strong[What it means.] 403 messages are exact repeats, which a careful project would drop before splitting. Naive Bayes wins on text, and it trains in an instant: its #emph[naive] assumption that words are independent is false, but it is a good enough approximation when there are thousands of weak clues. The words that most raise the spam odds are the vocabulary of a premium-rate scam. Unlike the loans, text gives every family a clear signal to find.]

#callout("labpart", title: [After the lab --- Your turn, troubleshooting and hand-in])[*Goal.* Extend the lab with the Your-turn tasks, compare with the expected findings, and check your work against the two checklists before you hand it in.

Your-turn tasks •~Expected findings •~Troubleshooting •~Checklists]

#callout("yourturn", title: [Your turn])[Add new cells at the end of the notebook for these tasks, and record your numbers before reading the expected findings.

+ #strong[Take the scaler away.] Refit the Question~3 pipeline at $k = 801$ without `StandardScaler`, keeping the imputer. What happens to cross-validated and validation ROC AUC? Print the training columns' standard deviations: which column now decides the neighbors?

+ #strong[How many trees are enough?] On the Question~10 split, fit the car-price forest of Question~9 with 1, 10, 50, 150 and 400 trees, and score the log-RMSE. Where does it stop improving? Compare with always guessing the training mean.

+ #strong[Count support vectors.] Refit the winning SVM from Question~11 on the training loans and read `n_support_`. How many training loans does the boundary depend on, and how many of them are defaults?

+ #strong[Whose model is it?] Refit Question~4's logistic regression without `int_rate`, then without `int_rate` and `term_months`, then on `int_rate` alone. How much of the model's skill is the lender's own pricing?]

#callout("expectedfindings", title: [Expected findings])[#strong[Warm-up.] Always saying "repaid" scores $4 \, 041 \/ 5 \, 000 = 80.8 %$, and the models below differ far more in how they rank risky loans than in accuracy. In raw units the amounts differ by 5,000 and the scores by 20, so the loan amount decides the distance alone; after scaling the gaps are $5 \, 000 \/ 8 \, 487 = 0.59$ and $20 \/ 30.3 = 0.66$, and the credit score counts slightly more.

+ Cross-validated ROC AUC falls from 0.719 to 0.571, and validation ROC AUC from 0.723 to 0.586. The loan amount has a standard deviation of \$8,487, against 30.3 for the FICO score, 23.7 for revolving utilization and 4.3 for the interest rate, so in raw units the neighbors are simply loans of a similar size, and the size of a loan says little about its risk.

+ Log-RMSE is 0.2836 with 1 tree, 0.2135 with 10, 0.2067 with 50, 0.2055 with 150 and 0.2053 with 400. It stops improving much after about 50 trees: more trees steady the average, but they cannot go below the error the trees share. Always guessing the mean scores 0.6553.

+ 11,478 of the 15,000 training loans, about three quarters, and 2,205 of them are among the 2,878 training defaults. On noisy data most loans sit near the boundary or on its wrong side, so the SVM keeps them all: that is why the file is 1.4~MB, and why SVMs grow slow as the rows grow.

+ The score falls from 0.731 to 0.708 without the interest rate, and to 0.669 without the rate and the term; the rate alone scores 0.707. One column, set by the lender from its own grade, carries almost all of the skill. A model trained on it mostly reproduces the lender's assessment, which is useful, but it is no independent second opinion.]

#callout("troubleshoot", title: [Troubleshooting])[/ The SVM cells take a minute: #block[
Question~11 fits eleven settings three times each on 10,000 loans, and an SVM's training time grows faster than its rows. That is expected on a laptop CPU.
]

/ Accuracy looks fine for every model: #block[
It is: always saying "repaid" is 80.8% accurate. Judge the models by ROC AUC and average precision, as the sheet does.
]

/ `ValueError: Input X contains NaN`: #block[
A tree, a plot or a model was given loans with gaps. Keep the imputer in every pipeline, and use the filled copies `Xt_train` and `Xt_valid` for the trees.
]

/ A loky or joblib message when the kernel stops: #block[
`n_jobs=-1` sometimes prints a harmless resource-tracker message on Windows when a pool closes. If the cell's results printed, the run is fine.
]]

#callout("verification", title: [Verification checklist])[- Every comparison in a part uses the same split and the same metric, and the eight columns written after the loan stay out of every model.

- $k$ and the SVM settings are chosen by cross-validation on training rows, and the test loans, which no part had seen, are scored once.

- You can read the depth-3 tree's riskiest rule, and say why the tree flags no loan at 0.5.

- You can say why boosting's win over the forest is real, using the fold spread.

- `models/loan_default_svm.joblib` reloads and reproduces the test predictions.]
