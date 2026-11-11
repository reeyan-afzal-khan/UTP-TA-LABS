#import "/.shared/typst/utp.typ": *
#unit("labs", "07-nlp-part-b")

#lab("7")[NLP Evaluation: Airline Tweet Sentiment Classification] <sec:lab07-nlp-b>

#callout("labproject", title: [Build and evaluate a three-class sentiment classifier])[#strong[Read first.] Chapter~#ref(label("ch:nlp-methods"), supplement: none). \
#strong[Goal.] Compare a majority baseline with validation-tuned Multinomial Naive Bayes under a leakage-safe protocol. \
#strong[Scenario.] An airline support team wants to classify customer tweets as negative, neutral or positive. \
#strong[Data.] `all_datasets/lab07-Tweets.csv` (14,640 tweets about six US airlines). \
#strong[Notebook.] `all_experiments/lab07_airline_sentiment_worked.ipynb`. \
#strong[Hand in.] The executed notebook, the `results/lab07/` folder and a short conclusion, as listed in the checklist at the end of this sheet.]

#callout("labmode", title: [Lab setup])[+ Activate your course environment and confirm that the data file is in `all_datasets/`.

+ Start Jupyter from `all_experiments/`, open the notebook, and choose #strong[Restart Kernel and Run All Cells]. Everything runs in a few seconds.

#code-block("cd all_experiments\njupyter lab", lang: "text") Prefer a plain script? From the course folder, `python all_experiments/lab07_airline_sentiment_worked.py` runs the same code and writes the same evidence.]


#include "/ARTIFICIAL INTELLIGENCE/labs/visuals/07-flow.typ"


#strong[How to work through this sheet.] Predict the result, run the matching notebook cell, compare with the reference output, and explain the result in your own words.

#callout("yourturn", title: [Your turn])[#strong[Warm-up on paper.] The figures of Chapter~#ref(label("ch:nlp-methods"), supplement: none) give two tweets scored by hand. Repeat the idea for the two-word message #emph[delayed thanks], using negative: share 0.635, delayed 0.00393, thanks 0.00259; positive: share 0.156, delayed 0.00062, thanks 0.0203. Which class wins?

#emph[Answer.] Negative: $0.635 times 0.00393 times 0.00259 approx 6.5 times 10^(- 6)$. Positive: $0.156 times 0.00062 times 0.0203 approx 2.0 times 10^(- 6)$. Negative wins, because "delayed" and the class share together outweigh "thanks".]

#strong[Setup.] Run the imports and path setup first, and keep this kernel state for the later questions. In the script version the first seven lines also set the working directory. #source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab07_airline_sentiment_worked.py", first: 1, last: 7, lang: "python") #source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab07_airline_sentiment_worked.py", first: 8, last: 24, lang: "python")

#callout("labquestion", title: [Question 1 --- Inspect and clean the data])[Keep tweet id, text, sentiment and airline. Report the class balance and the number of duplicate texts. Replace URLs and `@mentions` with placeholder tokens, then drop duplicates #emph[before] splitting, both exact copies and tweets that become identical after normalisation, so that no near-copy can land in two different subsets.] #callout("labanswer", title: [Worked answer])[
#include "/ARTIFICIAL INTELLIGENCE/labs/visuals/07-trace.typ"
 #source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab07_airline_sentiment_worked.py", first: 26, last: 40, lang: "python") *Reference output.*

#code-block("Raw tweets: 14640 | exact duplicate texts: 213\nDuplicates after normalisation: 355\nTweets kept: 14285\nshare:  negative 0.635   neutral 0.209   positive 0.156", lang: "text")

#strong[What it means.] 14,640 tweets shrink to 14,285 after duplicate handling. Negative tweets are 63 % of the data, so a classifier that always says #emph[negative] would score 63 % accuracy while being useless, and macro F1 is therefore the headline metric. Removing near-duplicates before the split matters: a retweet in the training set and its twin in the test set would inflate every score.]

#callout("labquestion", title: [Question 2 --- Create a fixed stratified split])[Split 70/15/15 with seed 42, stratified by sentiment, and save tweet ids with their split label to `split.csv`.] #callout("labanswer", title: [Worked answer])[#source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab07_airline_sentiment_worked.py", first: 42, last: 49, lang: "python") *Reference output.*

#code-block("split       negative  neutral  positive    All\ntest            1361      447       335   2143\ntrain           6348     2087      1564   9999\nvalidation      1360      447       336   2143", lang: "text")

#strong[What it means.] Stratification keeps the 63/21/16 class mix in all three subsets. The test subset is now frozen: nothing below looks at it until Question~6.]

#callout("labquestion", title: [Question 3 --- Fit text features on training data only])[Build a bag of words with `CountVectorizer` (English stop words removed, terms in fewer than two training tweets dropped, at most 20,000 features). Fit it on the training texts only and report the vocabulary size for unigrams and for unigrams plus bigrams.] #callout("labanswer", title: [Worked answer])[The vocabulary is itself something learned from training data. Trace how it moves through the protocol: 
#include "/ARTIFICIAL INTELLIGENCE/labs/visuals/07-worked-case.typ"


#source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab07_airline_sentiment_worked.py", first: 51, last: 57, lang: "python") *Reference output.*

#code-block("ngram_range=(1, 1): 4,671 features\nngram_range=(1, 2): 11,850 features", lang: "text")

#strong[What it means.] The vocabulary is learned from training tweets alone, so a word that appears only in validation or test tweets is unknown to the model, exactly the situation a deployed classifier faces. Adding bigrams more than doubles the vocabulary and lets the model see phrases such as #emph[hold hours] and #emph[great flight] that a unigram model splits apart.]

#strong[Connect it to the chapter.] This is what `clean` and the vectoriser do to one tweet. Notice what has gone by the last step. 
#include "/ARTIFICIAL INTELLIGENCE/labs/visuals/07-nlp-part-b-chapter.typ"


#callout("labquestion", title: [Question 4 --- Establish a majority-class baseline])[Predict the most frequent training class for every validation tweet and record its accuracy and macro F1. Any real model must beat this.] #callout("labanswer", title: [Worked answer])[#source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab07_airline_sentiment_worked.py", first: 59, last: 62, lang: "python") *Reference output.*

#code-block("Majority class: negative | validation accuracy 0.635 | validation macro F1 0.259", lang: "text")

#strong[What it means.] The majority baseline reaches 63 % accuracy but only 0.26 macro F1, because its recall on #emph[neutral] and #emph[positive] is zero. This is the number that shows why accuracy alone misleads on imbalanced classes.]

#callout("labquestion", title: [Question 5 --- Tune Naive Bayes on validation data])[Grid-search the n-gram range ${ \( 1 \, 1 \) \, \( 1 \, 2 \) }$ and the smoothing parameter $alpha in { 0.3 \, 0.5 \, 1 \, 2 }$, scoring by validation macro F1. Save `validation_results.csv` and select the best setting without looking at the test data.] #callout("labanswer", title: [Worked answer])[#source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab07_airline_sentiment_worked.py", first: 64, last: 79, lang: "python") *Reference output.*

#code-block("ngram_range  alpha  validation_macro_f1\n(1, 2)         0.3               0.6973\n(1, 2)         0.5               0.6903\n(1, 2)         1.0               0.6868\n(1, 1)         0.3               0.6760\n...\nSelected: (1, 2) alpha = 0.3", lang: "text")

#strong[What it means.] Unigrams plus bigrams with light smoothing give the best validation macro F1, about 0.70. The differences between settings are small, which is itself useful: Naive Bayes is not very sensitive to $alpha$ here, and the choice of n-grams matters more than the smoothing.]

#callout("labquestion", title: [Question 6 --- Evaluate once on the test data])[Refit the vectoriser and the selected model on the training tweets, predict the test tweets once, and report accuracy, macro precision, macro recall and macro F1 for the baseline and the model. Save `metrics.csv`, `test_predictions.csv` and the confusion matrix.] #callout("labanswer", title: [Worked answer])[#source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab07_airline_sentiment_worked.py", first: 81, last: 104, lang: "python") #callout("labvisual", title: [Reference plot from the supplied notebook])[#image("/ARTIFICIAL INTELLIGENCE/labs/visuals/07-notebook-reference.png", width: 90%)] *Reference output.*

#code-block("model  accuracy  macro_precision  macro_recall  macro_f1\n0  Majority baseline    0.6351           0.2117        0.3333    0.2589\n1     Multinomial NB    0.7699           0.7036        0.6933    0.6978", lang: "text")

#strong[What it means.] On the untouched test set Naive Bayes reaches about 77 % accuracy and 0.70 macro F1, against 63 % and 0.26 for the baseline. The confusion matrix shows the typical pattern: negative tweets are recognised well, while #emph[neutral] tweets are pulled towards #emph[negative], because complaint vocabulary dominates the corpus.]

#callout("labquestion", title: [Question 7 --- Inspect subgroup performance and review errors])[Report per-class precision, recall and F1, then macro F1 per airline (`per_airline_f1.csv`). Finally take the four most confident mistakes for each true class, twelve deterministic errors, tag each with a simple category, and save `error_analysis.csv`.] #callout("labanswer", title: [Worked answer])[#source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab07_airline_sentiment_worked.py", first: 106, last: 136, lang: "python") *Reference output.*

#code-block("precision  recall     f1  support\nnegative      0.843   0.871  0.857     1361\nneutral       0.598   0.535  0.564      447\npositive      0.671   0.675  0.673      335\nmacro F1 by airline: Delta 0.659, American 0.662, United 0.675,\n                     US Airways 0.714, Southwest 0.726, Virgin America 0.782 (63 tweets)\nSaved: ['confusion_matrix.csv', 'confusion_matrix.png', 'error_analysis.csv', 'metrics.csv', 'per_airline_f1.csv', 'per_class_metrics.csv', 'split.csv', 'test_predictions.csv', 'validation_results.csv']", lang: "text")

#strong[What it means.] Neutral is the hardest class, because it has few distinctive words and sits between the other two. The airline table is a diagnostic rather than a ranking: Virgin America's score rests on 63 tweets. Read the twelve sampled errors yourself. All twelve carry confidence above 0.999, which is why these scores cannot be treated as probabilities of being right.]

#callout("yourturn", title: [Your turn])[Add new cells at the end of the notebook. Choose settings on #emph[validation] data only, using the loop from Question~5 as a pattern, and keep the test set out of it.

+ #strong[Question a default.] Refit with `stop_words=None`, keeping $alpha = 0.3$ and bigrams. What happens to validation macro F1, and why might it? Check whether `not`, `no` and `never` are in `sklearn.feature_extraction.text.ENGLISH_STOP_WORDS`.

+ #strong[Try other settings.] Compare `min_df=5`, $alpha = 0.1$, and `TfidfVectorizer` in place of `CountVectorizer`. Which help?

+ #strong[Look inside the model.] For each class, list the twelve terms with the highest log-probability relative to the other two classes, using the code below. Which class has words that look useful for future tweets, and which does not?

#code-block("names = np.array(features.get_feature_names_out())\nlog_prob = model.feature_log_prob_\nfor i, label in enumerate(model.classes_):\n    others = [j for j in range(3) if j != i]\n    odds = log_prob[i] - log_prob[others].mean(axis=0)\n    print(label, list(names[np.argsort(-odds)[:12]]))", lang: "python")]

#callout("expectedfindings", title: [Expected findings])[+ Validation macro F1 rises from 0.697 to 0.720, and the vocabulary reaches the 20,000 cap. All three words are on the stop list, along with `again`, so removing stop words was erasing negation and frequency words that carry sentiment. A default deserved testing.

+ All three are slightly worse or clearly worse: `min_df=5` gives 0.696, $alpha = 0.1$ gives 0.693, and TF-IDF with Multinomial Naive Bayes gives 0.633, because the model expects counts.

+ Negative: `worst`, `ridiculous`, `hung`, `hold hours`, `unacceptable`, `terrible`, `rude`. Positive: `good work`, `guys rock`, `best airline`, `great flight`, `excellent`, `fantastic`. Those look reusable. Neutral: `journal`, `wall street`, `nantucket`, `license`, which are one-off news topics. That helps explain why neutral is the hardest class.]

#callout("troubleshoot", title: [Troubleshooting])[/ Test metrics change between runs: #block[
Something is not seeded, or the test set is influencing a choice. Check `random_state=42` in both splits.
]

/ Scores suspiciously high: #block[
Duplicates may have crept across the split. Confirm that `Tweets kept: 14285` appears before the split.
]

/ `ValueError` about empty vocabulary: #block[
You probably passed the wrong column. The vectoriser reads `model_text`.
]]

#callout("verification", title: [Verification checklist])[- Duplicates are removed before the split, leaving 14,285 tweets.

- The 70/15/15 split is stratified, fixed with seed~42, and saved to `split.csv`.

- The vectoriser is fitted on training tweets only, and the settings are chosen by validation macro F1.

- The test set is used once: Naive Bayes reaches about 0.70 macro F1 against 0.26 for the majority baseline.

- Per-class and per-airline results and the twelve reviewed errors are saved.]

#callout("labdeliverable", title: [Submission checklist])[- Restart the kernel and run all cells without errors.

- Submit the executed notebook, including your #emph[Your turn] cells, and the generated `results/lab07/` folder.

- Add a short conclusion: explain why macro F1 is the headline metric, name the weakest class, and propose one stronger text representation without changing the evaluation protocol.]
