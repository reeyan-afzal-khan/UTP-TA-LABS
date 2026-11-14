#import "/.shared/typst/utp.typ": *
#import "/MACHINE LEARNING/course-tools.typ": *
#unit("labs", "05-anomaly-limited-labels")

#labsection(5, label: <sec:lab05-anomaly-limited-labels>)[Unsupervised learning II: anomaly detection and limited labels]

#labproject[Ranking card fraud without labels, and getting the most from a small labeling budget][
  #strong[Read first.] Chapters~@ch:anomaly and~#ref(<ch:semi-supervised>). \

  #strong[Goal.] Rank card transactions for review with an anomaly detector that never sees a fraud label, judge the ranking with metrics that respect a 0.17% base rate, then stretch a small labeling budget with self-training and active learning, checking each against a labels-only baseline. \

  #strong[Scenario.] A bank’s fraud team can review a few hundred alerts a day and wants the right ones at the top of the list. A bank’s support team wants customer messages routed to the right one of 77 desks automatically, and can pay for only a thousand or so of them to be labeled by hand. In both cases labels are the scarce resource, and the question is how far you can get without them. \

  #strong[Data.] In `all_datasets/`: `unsupervised/creditcard_fraud_ulb/creditcard_fraud_ulb.zip`, 284,807 transactions by European cardholders over two days in September 2013, released by the Machine Learning Group of the Université Libre de Bruxelles (Dal Pozzolo and others, 2015); and `advanced/banking77/banking77.csv`, 13,083 messages to a bank’s support chat, each labeled with one of 77 intents (Casanueva and others, PolyAI, 2020). \

  #strong[Notebook.] `all_experiments/lab05_anomaly_limited_labels/lab05_anomaly_limited_labels_worked.ipynb`, with a README beside it. \

  #strong[Hand in.] The executed notebook, `results/lab05/` and a short conclusion, as listed in the checklist at the end of this sheet.
]

#labroadmap([Your map of this lab],
  [A],
  [Rank card fraud with an Isolation Forest and judge the ranking],
  [2--4],
  [B],
  [Self-train from 1,000 labels; compare two ways of buying labels],
  [5--9],
  [Finish],
  [Save the evidence; then size a review budget and read the messages the learner finds hardest],
  [10--12],
  [After],
  [Your-turn tasks, expected findings, troubleshooting and the two checklists],
  [---],
)

#labmode[
  + Activate your course environment and confirm the two data files are in `all_datasets/`. Keep the card-payment file zipped: pandas reads the CSV inside it.
  + From the course folder, start Jupyter, open the notebook, and choose #strong[Restart Kernel and Run All Cells]. It takes under a minute.
  + Part~A uses no labels to train; Part~B uses as few as it can. Both keep a labeled test set, because a claim needs evidence.

  ```terminal
  jupyter lab
  ```

  Prefer a plain script? From the course folder, `python all_experiments/lab05_anomaly_limited_labels/lab05_anomaly_limited_labels_worked.py` runs the same code and writes the same evidence.
]

#labroutine

#yourturn[
  #strong[Warm-up on paper.] Do these before opening the notebook; the code will check you.

  + 148 of 85,443 test transactions are fraud. What accuracy does “never fraud” score, and what average precision does a random ranking score?
  + A team reviews its top 100 alerts and finds 39 frauds. How many times better than a random sample of 100 is that?
]

#labquestion(1)[Setup][
  Run this first, and keep this kernel for the later questions. Every lab starts the same way. `start_lab()`, from `all_experiments/course_setup.py`, finds the course folder and returns the three folders the lab uses: `DATA` to read from, `RESULTS` and `MODELS` to write to. The imports in between are grouped by what they are for.
]

#labanswer[
  #labcode("lab05_anomaly_limited_labels", 1)

  #readcode[
    - The setup has the same three steps as before.
    - `IsolationForest` is a detector that needs no labels, `TfidfVectorizer` turns messages into weighted word columns, and `SelfTrainingClassifier` wraps a classifier so that it can learn from its own confident guesses.
  ]

  #refoutput[
    ```terminal
    course folder: MACHINE LEARNING
    reads all_datasets/, writes results/lab05/ and models/
    ```
  ]
]

#labpartopen([Part A], [Ranking fraud without labels], [Questions 2--4 • Data: ULB card transactions], [Rank card transactions with a detector that never sees a fraud label, and judge the ranking at a 0.17% base rate.])

#labquestion(2)[Fit an Isolation Forest without labels][
  To protect the cardholders, the bank released its columns as 28 anonymous principal components, `V1` to `V28`, plus the time and the amount. An Isolation Forest is fitted on the training rows #emph[without] the fraud column: it learns what ordinary looks like, and scores how easily each transaction can be isolated.
]

#labanswer[
  #include "visuals/05-trace.typ"

  #labcode("lab05_anomaly_limited_labels", 2)

  #readcode[
    - `cards["Time"].max() / 3600` turns seconds into hours.
    - `[f"V{i}" for i in range(1, 29)]` builds the 28 column names from `V1` to `V28`. `.copy()` makes the selection an independent table, so adding `log_amount` to it is safe.
    - `train_test_split(..., stratify=y)` uses the labels for one purpose: to give both sides the same fraud rate.
    - `forest.fit(X_train)` receives no labels. An Isolation Forest builds 300 random trees and measures how few splits it takes to cut each transaction off from the rest: unusual ones are cut off quickly.
    - `decision_function` is high for ordinary rows, so the minus sign turns it into an anomaly score: higher means more unusual.
  ]

  #refoutput[
    ```terminal
    transactions: 284807  over 48 hours; 492 frauds
    ```
  ]

  #strong[What it means.] The labels are still used for one thing: `stratify` keeps the fraud rate equal in both halves, so the evaluation is fair. The forest itself never sees them.
]

#labquestion(3)[Score the ranking][
  Accuracy is useless at a 0.17% base rate, so the ranking is judged three ways: ROC AUC, average precision, which guessing scores at the prevalence, and how many frauds a team would find in its first 100 reviews.
]

#labanswer[
  #include "visuals/05-worked-case.typ"

  #labcode("lab05_anomaly_limited_labels", 3)

  #readcode[
    - `y_test.mean()` is the fraud rate, which is also the average precision that a random ranking would earn.
    - `roc_auc_score` and `average_precision_score` need only a score that ranks. The detector never has to answer yes or no.
    - `ranked` puts the labels, the scores and the amounts in one table. `cards.loc[X_test.index, "Amount"]` fetches the amounts of the test transactions by their row labels.
    - `sort_values("anomaly_score", ascending=False)` puts the most unusual first, so `ranked.head(review_budget)` is the list a reviewer would work through.
  ]

  #refoutput[
    ```terminal
    test transactions: 85443  frauds: 148  prevalence: 0.00173
    ROC AUC: 0.95
    average precision: 0.219  ( 126 x prevalence)
    frauds in the top 100 alerts: 39
     fraud_label  anomaly_score  amount
               0          0.251 4861.64
               0          0.250 1676.60
               1          0.247    2.28
               1          0.242    1.00
               0          0.242 5964.95
               1          0.240    1.00
    ...
    ```
  ]

  #strong[What it means.] ROC AUC 0.950 sounds excellent, and average precision, 0.219, tells the truer story: most alerts are still genuine. Yet a team reviewing the first 100 would find 39 frauds, where a random 100 would hold fewer than one. Look at the amounts in the top ten: frauds for exactly \$1.00. That is card testing, where a thief checks a stolen card with a tiny purchase, and it is unusual enough for the forest to notice without being told. The genuine alerts are unusual too, mostly large purchases: anomalous is not the same as fraudulent.
]

#labquestion(4)[Plot the scores and precision at $k$][
  The score distributions for genuine and fraud transactions, and the fraud rate among the top $k$ alerts as $k$ grows.
]

#labanswer[
  #labcode("lab05_anomaly_limited_labels", 4)

  #readcode[
    - `hits[:k].mean()` is the precision at `k`: the share of frauds among the `k` most unusual transactions. The list comprehension computes it for every `k` from 10 to 2,000.
    - `anomaly_score[~is_fraud]` and `anomaly_score[is_fraud]` separate the two groups for the histograms. `density=True` scales each histogram to an area of 1, so a few frauds can be compared with tens of thousands of genuine payments.
    - `axhline(prevalence, ...)` draws the fraud rate, the level that a random list would reach.
  ]

  #labvisual[Reference plot from the supplied notebook][
    #fitted-image("/MACHINE LEARNING/labs/visuals/05-notebook-reference.png", width: 88%, height: 5cm)
  ]

  #strong[What it means.] Frauds sit to the right, with overlap. The precision curve falls from about one half at the top of the list towards the base rate: every extra review finds fewer frauds. A fraud team therefore plans by review budget, not by ROC AUC.
]

#labcheckpoint[
  #listopts(leftmargin: 1.2em, itemsep: 1.9925pt, topsep: 0.9963pt)[
    - ROC AUC 0.950, but average precision only 0.219.
    - The top 100 alerts hold 39 of the 148 test frauds.
  ]
]

#labpartopen([Part B], [Learning from few labels], [Questions 5--9 • Data: Banking77 customer-support messages], [Stretch 1,000 labels with self-training, then compare two ways of buying more labels.])

#labquestion(5)[Split the messages three ways][
  Banking77 holds 13,083 messages that customers typed to a bank’s support chat, each labeled by hand with one of 77 intents, such as `card_arrival` or `exchange_rate`. Labels cost money, so this part pretends most are unknown: a pool of 8,003 messages to learn from, 2,000 for validation, and the official 3,080 test messages, opened once. Turning text into numbers needs only the words, so the TF-IDF vocabulary of single words and word pairs is learned from the pool without any labels.
]

#labanswer[
  #labcode("lab05_anomaly_limited_labels", 5)

  #readcode[
    - `messages.drop_duplicates("label").sort_values("label")["intent"].tolist()` keeps one row per label, in label order, and reads off the intent names. The result is a list in which position 0 is the name of label 0.
    - The file carries its own `split` column. `train_part.sample(2000, random_state=42)` sets validation messages aside, and `train_part.drop(val.index)` leaves the pool.
    - `TfidfVectorizer(ngram_range=(1, 2), min_df=2, sublinear_tf=True)` builds columns for single words and for pairs of words, ignores those found in fewer than two messages, and dampens repeated words with a logarithm.
    - `.fit(pool["text"])` learns the vocabulary from the pool. `transform` then turns each set of messages into a sparse matrix with one column per word or pair.
    - `make_model()` returns a fresh classifier each time, so every method in Part~B uses the same one.
  ]

  #refoutput[
    ```terminal
    pool: 8003  validation: 2000  test: 3080  intents: 77
                                                            text       intent
    What can I do if my card still hasn't arrived after 2 weeks? card_arrival
      I have been waiting over a week. Is the card still coming? card_arrival
          How do I know if I will get my card, or if it is lost? card_arrival
    vocabulary: 8834 words and word pairs
    ```
  ]

  #strong[What it means.] Three customers ask the same thing in three different ways, which is what makes intents hard: the model must learn that “hasn’t arrived”, “still coming” and “will I get my card” mean one thing. Each message becomes a row of 8,834 weights, almost all zero. The pool keeps its labels hidden; the code reveals them only when a policy pays for them.
]

#labquestion(6)[Self-train from 1,000 labels][
  Keep the labels of 1,000 pool messages, an eighth of the pool and about 13 per intent, and hide the rest. The baseline uses only those 1,000. Self-training then adopts its own confident predictions, with probability at least 0.8, as pseudo-labels, refits, and repeats.
]

#labanswer[
  #labcode("lab05_anomaly_limited_labels", 6)

  #readcode[
    - `np.random.default_rng(42)` is a seeded random generator, and `rng.choice(len(y_pool), 1000, replace=False)` draws 1,000 different row positions.
    - `np.full(len(y_pool), -1)` starts with every label hidden: -1 is the code for "unlabeled". The next line reveals the 1,000 labels that were drawn.
    - `SelfTrainingClassifier(make_model(), threshold=0.80)` fits the model on the labeled rows, predicts the rest, adopts as a label every prediction it is at least 80% sure of, and repeats for up to ten rounds.
    - `semi.labeled_iter_ > 0` marks the rows that the model labeled itself (the original labels have round 0), and `semi.transduction_` holds the labels it ended with. Comparing them with the hidden truth shows how many adopted labels were right.
    - The last model uses every label of the pool: the ceiling against which the other two are measured.
  ]

  #refoutput[
    ```terminal
    labels only (1,000 messages): validation accuracy 0.638
    self-training adopted 486 pseudo-labels, 98.8% of them right
    self-training: validation accuracy 0.632
    all 8,003 labels (the ceiling): 0.882
    ```
  ]

  #strong[What it means.] Self-training did not help: its 486 pseudo-labels were almost all right, yet the score fell slightly. With 77 intents and 13 labels each, the model is confident only about messages it already gets right, so the pseudo-labels teach it nothing new, and they tilt it towards the intents it already knows. The ceiling, 0.882 with every label, shows how much was left on the table. Without the labels-only baseline, “self-training scored 0.632” would have sounded like a result; Your-turn task~3 lowers the threshold to see what more pseudo-labels do.
]

#strong[Connect it to the chapter.] A score is only useful with a threshold you chose, and a limited label budget is the same kind of decision.

#include "visuals/05-anomaly-limited-labels-chapter.typ"

#labquestion(7)[Simulate active learning][
  Both policies start from the same 154 labeled messages, two per intent, and buy 100 more per round for ten rounds. Uncertainty sampling buys the messages whose two most likely intents are closest; random querying buys any 100.
]

#labanswer[
  #labcode("lab05_anomaly_limited_labels", 7)

  #readcode[
    - `np.where(y_pool == c)[0]` lists the rows of intent `c`, and `rng.choice(..., 2, replace=False)` draws two of them. `np.concatenate` joins the draws of all 77 intents into the 154 starting rows.
    - `active_set` and `random_set` are plain lists of row positions that grow by 100 in every round.
    - `np.setdiff1d(np.arange(len(y_pool)), active_set)` is every row that is not yet labeled.
    - `np.sort(active.predict_proba(...), axis=1)` sorts each message's 77 probabilities, so the last two columns hold its two most likely intents. Their difference is the margin, and a small margin means the model cannot decide.
    - `np.argsort(margin)[:query_batch]` gives the positions of the 100 smallest margins, and those messages join the labeled set.
    - `break` leaves the loop after the last scoring round, before buying labels that would never be used.
  ]

  #refoutput[
    ```terminal
    round  1: labels= 154  uncertainty=0.319  random=0.319
    round  2: labels= 254  uncertainty=0.360  random=0.368
    round  3: labels= 354  uncertainty=0.464  random=0.438
    ...
    round  8: labels= 854  uncertainty=0.674  random=0.631
    round  9: labels= 954  uncertainty=0.700  random=0.648
    round 10: labels=1054  uncertainty=0.712  random=0.679
    ```
  ]

  #strong[What it means.] The two policies are level for two rounds: a model that knows two examples per intent cannot yet tell which messages are informative. From round~3 uncertainty sampling leads, and the lead grows to about three points. Every message it buys sits between two intents the model confuses, so each label sharpens a boundary that matters.
]

#labquestion(8)[Plot label efficiency][
  Validation accuracy against labels bought, for both policies.
]

#labanswer[
  #labcode("lab05_anomaly_limited_labels", 8)

  #readcode[
    - Two calls to `plt.plot` draw both curves on the same axes, with the number of labels on the horizontal axis, so the two policies are compared at equal cost.
  ]
]

#labquestion(9)[Open the test set once for each policy][
  Refit each policy’s final labeled set and score both on the official test messages, once.
]

#labanswer[
  #labcode("lab05_anomaly_limited_labels", 9)

  #readcode[
    - Each policy gets one final model, trained on all the labels it bought, and one score on the official test messages.
    - The second `print` pads its text with spaces so that the two numbers line up.
  ]

  #refoutput[
    ```terminal
    final test accuracy with 1054 labels, uncertainty sampling: 0.725
    final test accuracy with 1054 labels, random querying:     0.682
    ```
  ]

  #strong[What it means.] The validation lead holds on the test messages: about 4 points from the same 1,054 labels. To reach 0.712 on validation, random querying would need more labels than the ten rounds bought, so on a real budget the choice of #emph[which] messages to label is worth money. One seed and one dataset, though: report it as a promising result, not a law.
]

#labcheckpoint[
  #listopts(leftmargin: 1.2em, itemsep: 1.9925pt, topsep: 0.9963pt)[
    - Labels only: 0.638. Self-training: 0.632. Every label: 0.882.
    - With 1,054 labels, uncertainty sampling scores 0.725 on the test messages and random querying 0.682.
  ]
]

#labpartopen([Finish], [Save the evidence, then try it yourself], [Questions 10--12], [Write the results folder, then extend the lab yourself before reading one worked solution.])

#labquestion(10)[Save the evidence][
  Write the numbers above to the results folder. These files are regenerated on every run, so do not edit them by hand.
]

#labanswer[
  #labcode("lab05_anomaly_limited_labels", 10)

  #readcode[
    - Each dictionary in the list is one row of the metrics table. A key that a row lacks becomes a blank in that row.
    - `ranked.head(review_budget).to_csv(...)` saves the review list itself, which is what Part~A hands over.
  ]
]

#labsubhead[Try it yourself]

#labquestion(11)[Try it yourself][
  A fraud team can review a fixed number of alerts a day. Print the fraud rate and the frauds found in the top 50, 100, 300 and 1,000 alerts. Then look inside the active learner: print the four pool messages its final model is least sure about, with its top two intents and the true one. Attempt it in this empty cell before reading the solution.
]

#labquestion(12)[One solution][
  The review budgets reuse Question~4’s ranking; the messages reuse Question~7’s final active model.
]

#labanswer[
  #labcode("lab05_anomaly_limited_labels", 12)

  #readcode[
    - The loop reuses `hits` from Question~4: `hits[:budget].mean()` is the fraud rate among the first `budget` alerts, and the sum is the number of frauds found.
    - `np.argsort(probs, axis=1)[:, -2:]` gives, for each message, the columns of its two highest probabilities, and `active_final.classes_[...]` turns the column positions into labels.
    - `np.argsort(margin)[:4]` picks the four messages the final model is least sure of.
    - `intents[...]` turns a label number into its name, and `text[:75]` prints the first 75 characters of a message.
  ]

  #refoutput[
    ```terminal
    top   50 reviewed: fraud rate = 50.0%  (25 frauds found)
    top  100 reviewed: fraud rate = 39.0%  (39 frauds found)
    top  300 reviewed: fraud rate = 21.0%  (63 frauds found)
    top 1000 reviewed: fraud rate = 9.9%  (99 frauds found)
    Hello, I have noticed a problem on my recent withdrawal at the banks atm ma
        cash_withdrawal_charge or pending_cash_withdrawal?  truly cash_withdrawal_charge
    I had a problem with my card payment, can you help?
        declined_card_payment or reverted_card_payment??  truly declined_card_payment
    I was wondering why my payment hasn't gone through yet, its been a while.
        transfer_not_received_by_recipient or pending_card_payment?  truly pending_card_payment
    My identity can't be verified.
        why_verify_identity or unable_to_verify_identity?  truly unable_to_verify_identity
    ```
  ]

  #strong[What it means.] A thousand reviews find 99 of the 148 frauds, two in three, at a hit rate that has fallen to one in ten. The messages the active learner would buy next are genuinely ambiguous: a payment that “hasn’t gone through yet” could be a pending card payment or a transfer the recipient has not received, and “I had a problem with my card payment” fits two intents equally well. Those are the cases where a human label teaches the model the most. One intent’s name, `reverted_card_payment?`, ends in a question mark in the source, hence the double mark.
]

#labpartopen([After the lab], [Your turn, troubleshooting and hand-in], [Your-turn tasks • Expected findings • Troubleshooting • Checklists], [Extend the lab with the Your-turn tasks, compare with the expected findings, and check your work against the two checklists before you hand it in.])

#yourturn[
  Add new cells at the end of the notebook for these tasks, and record your numbers before reading the expected findings.

  + #strong[What would labels buy?] Fit a plain logistic regression on the fraud training rows, this time using the labels. Compare its ROC AUC, average precision and frauds in the top 100 with the Isolation Forest’s.
  + #strong[Split by time.] Refit both models on the first 70% of the two days and score them on the rest. What happens to the Isolation Forest’s top 100, and why might unusual behavior in the later hours not be fraud?
  + #strong[Trust it more.] Repeat Question~6’s self-training with confidence thresholds of 0.5 and 0.3 instead of 0.8. How many pseudo-labels does it adopt, how many are right, and what happens to validation accuracy against the labels-only 0.638?
  + #strong[Choose a budget.] Suppose reviewing an alert costs \$5 and catching a fraud saves \$200. Compute the net saving at budgets of 50, 100, 300, 1,000, 2,000 and 5,000 reviews. Which budget would you choose?
]

#expectedfindings[
  #strong[Warm-up.] “Never fraud” is $1-148\/85","443=99.83 %$ accurate and catches nothing. A random ranking’s average precision equals the prevalence, 0.0017. A random 100 would hold $100 times 0.00173 approx 0.17$ frauds, so 39 is about 225 times better.

  + Logistic regression with labels: ROC AUC 0.956, average precision 0.711, 86 frauds in the top 100. The Isolation Forest without labels: 0.950, 0.219 and 39. ROC AUC barely moves, but labels more than double the frauds at the top of the list. When labels exist, use them; the anomaly detector is for when they do not, or for kinds of fraud no label describes yet.
  + Split at hour 36.9, the Isolation Forest’s ROC AUC is still 0.944, but its average precision falls to 0.044 and its top 100 holds just one fraud. Ordinary behavior in the later hours differs from what the forest learned in the earlier ones, so unusual-but-honest transactions crowd the top of the list. The supervised model, which learned what fraud looks like, keeps an average precision of 0.706 and 72 frauds in its top 100. An anomaly detector finds what is unusual, and what is unusual changes over time.
  + At 0.5 it adopts 3,604 pseudo-labels, 76.8% of them right, and validation accuracy falls to 0.596; at 0.3 it adopts 5,813, only 69.6% right, and scores 0.606. Both are worse than the 1,000 labels alone. A lower threshold buys more pseudo-labels, but every wrong one is learned as if it were true, and the next round builds on it: confirmation bias, measured. Always compute the baseline before reporting a semi-supervised method.
  + The frauds found are 25, 39, 63, 99, 116 and 123, so the net savings are \$4,750, \$7,300, \$11,100, \$14,800, \$13,200 and $- \$ 400$. A budget of about 1,000 reviews is best at these costs: beyond it, each extra review finds too little fraud to pay for itself. Change the costs, and the answer moves.
]

#troubleshoot[
  / `FileNotFoundError` for a data file: Keep the card-payment ZIP zipped in `all_datasets/unsupervised/`, and the Banking77 CSV in `all_datasets/advanced/`; match the names in Chapter~#ref(<ch:toolkit>).
  / Self-training is slow or warns about convergence: Each round refits a logistic regression with 77 classes on up to 8,003 messages. A run of under a minute is normal; the warning does not change the result.
  / Your active-learning curve differs: The policies depend on the random starting set; keep the seeds in Questions~6 and~7 to reproduce the sheet.
]

#labchecklists[
  #verification[
    - The Isolation Forest is fitted without the fraud column, and the ranking is judged by average precision and frauds found, not by accuracy.
    - You can explain why the top alerts include genuine transactions.
    - Every semi-supervised and active result is compared with a labels-only baseline on the same validation rows.
    - The official test messages are scored once, at the end.
  ]
]
