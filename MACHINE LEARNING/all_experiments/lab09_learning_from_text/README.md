# Lab 09 — Learning from text

Two collections of short messages go from raw text to working models. You split text messages into tokens and build the table of counts yourself, turn it into a spam filter whose threshold protects real messages, classify bank questions into 77 intents and find the pairs the classifier confuses, search stored questions by similarity, and learn word vectors that repair a search which counting gets wrong.

**Lab sheet:** [`Lab-09/Lab-Activity.pdf`](../../../.all-pdfs/machine-learning/Lab-09/Lab-Activity.pdf), which practises the chapter *Learning from Text*.

## Parts

The sheet and the notebook are divided the same way; each part ends with a checkpoint.

| Part | What you do | Questions |
| --- | --- | --- |
| A | Read the text messages, split them into tokens, and build the table of counts | 2–5 |
| B | Build a spam filter, weigh words with tf-idf, read its weights, and choose its threshold | 6–10 |
| C | Classify bank questions into 77 intents, find where it fails, and search by similarity | 11–14 |
| D | Learn word vectors from the company words keep, and use them to search and to classify | 15–18 |
| Finish | Save the model and the evidence; then test repeats and character pieces yourself | 19–22 |
| After | Your-turn tasks, expected findings, troubleshooting and the checklist (on the lab sheet) | — |

## Files

| File | What it is |
| --- | --- |
| `lab09_learning_from_text_worked.ipynb` | The worked notebook: every question on the sheet, with *Read the code* notes, its output, and what the output shows |
| `lab09_learning_from_text_worked.py` | The same code cells as one script; each cell starts with a `# %% Question n` line |

## Data

| File | Contents | Source |
| --- | --- | --- |
| `all_datasets/supervised/sms_spam/sms_spam.csv` | 5,572 text messages labeled spam or ham; the data card is the `README.md` beside it | Almeida and Hidalgo, *SMS Spam Collection* (2011), [UCI](https://archive.ics.uci.edu/dataset/228/sms+spam+collection); CC BY 4.0 |
| `all_datasets/advanced/banking77/banking77.csv` | 13,083 questions to a bank's support chat, each with one of 77 intents and an official train and test split | Casanueva and others, PolyAI (2020), [Hugging Face](https://huggingface.co/datasets/PolyAI/banking77); CC BY 4.0 |

## Run

From the course folder:

```bash
jupyter lab                                              # open lab09_learning_from_text_worked.ipynb, then Restart Kernel and Run All Cells
python all_experiments/lab09_learning_from_text/lab09_learning_from_text_worked.py      # or the script
```

A run takes about a minute on a laptop CPU. It needs only the packages of the earlier labs: NumPy, pandas, Matplotlib, SciPy and scikit-learn.

## What a run writes

- `results/lab09/`: four figures and eight tables (the share of spam and ham messages containing each word, the test confusion matrix of the spam filter, recall by intent, the confused intent pairs, the preprocessing comparison, the word neighbors, the label-efficiency table, and the metrics).
- `models/bank_intent_tfidf_logistic.joblib`: the intent classifier, vectorizer and model in one pipeline, with `models/bank_intent_card.json` beside it.

Every run regenerates these files, so do not edit them by hand. `python all_experiments/book_checks/check_your_turn.py lab09` checks the numbers printed under *Expected findings* on the sheet.
