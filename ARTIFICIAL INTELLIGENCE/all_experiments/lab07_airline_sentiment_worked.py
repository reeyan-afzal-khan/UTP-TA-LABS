# Complete executable companion to lab07_airline_sentiment_worked.ipynb
# Code cells are kept in notebook order, including worked extensions.
from pathlib import Path
import os
from IPython.display import display
os.chdir(Path(__file__).resolve().parent)

import re
from pathlib import Path

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from IPython.display import display
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.metrics import ConfusionMatrixDisplay, accuracy_score, confusion_matrix, f1_score, precision_recall_fscore_support
from sklearn.model_selection import train_test_split
from sklearn.naive_bayes import MultinomialNB

ROOT = Path.cwd().parent
DATA = ROOT / "all_datasets"
RESULTS = ROOT / "results" / "lab07"
RESULTS.mkdir(parents=True, exist_ok=True)
CLASSES = ["negative", "neutral", "positive"]

tweets = pd.read_csv(DATA / "lab07-Tweets.csv", dtype={"tweet_id": str})[["tweet_id", "text", "airline_sentiment", "airline"]]


def clean(text):
    text = re.sub(r"https?://\S+|www\.\S+", " URL ", text)
    text = re.sub(r"@\w+", " USER ", text)
    return " ".join(text.lower().split())


print("Raw tweets:", len(tweets), "| exact duplicate texts:", int(tweets.text.duplicated().sum()))
tweets["model_text"] = tweets.text.map(clean)
print("Duplicates after normalisation:", int(tweets.model_text.duplicated().sum()))
tweets = tweets.drop_duplicates("model_text").reset_index(drop=True)
print("Tweets kept:", len(tweets))
display(tweets.airline_sentiment.value_counts(normalize=True).rename("share").round(3).to_frame())

train, rest = train_test_split(tweets.index, test_size=0.30, random_state=42, stratify=tweets.airline_sentiment)
val, test = train_test_split(rest, test_size=0.50, random_state=42, stratify=tweets.airline_sentiment[rest])

tweets["split"] = "train"
tweets.loc[val, "split"] = "validation"
tweets.loc[test, "split"] = "test"
tweets[["tweet_id", "airline_sentiment", "split"]].to_csv(RESULTS / "split.csv", index=False)
display(pd.crosstab(tweets.split, tweets.airline_sentiment, margins=True))

def vectorizer(ngram_range):
    return CountVectorizer(stop_words="english", min_df=2, max_features=20_000, ngram_range=ngram_range)


for ngram_range in [(1, 1), (1, 2)]:
    vocabulary = vectorizer(ngram_range).fit(tweets.model_text[train]).vocabulary_
    print(f"ngram_range={ngram_range}: {len(vocabulary):,} features")

majority = tweets.airline_sentiment[train].mode()[0]
y_val = tweets.airline_sentiment[val]
majority_f1 = f1_score(y_val, [majority] * len(val), average="macro")
print(f"Majority class: {majority} | validation accuracy {(y_val == majority).mean():.3f} | validation macro F1 {majority_f1:.3f}")

rows = [{"ngram_range": "majority baseline", "alpha": np.nan, "validation_macro_f1": majority_f1}]
for ngram_range in [(1, 1), (1, 2)]:
    features = vectorizer(ngram_range).fit(tweets.model_text[train])
    X_train, X_val = features.transform(tweets.model_text[train]), features.transform(tweets.model_text[val])
    for alpha in [0.3, 0.5, 1.0, 2.0]:
        model = MultinomialNB(alpha=alpha).fit(X_train, tweets.airline_sentiment[train])
        rows.append({"ngram_range": str(ngram_range), "alpha": alpha,
                     "validation_macro_f1": f1_score(y_val, model.predict(X_val), average="macro")})

validation = pd.DataFrame(rows).sort_values("validation_macro_f1", ascending=False)
validation.to_csv(RESULTS / "validation_results.csv", index=False)
display(validation.round(4))

best = validation.iloc[0]
best_ngram = (1, 2) if best.ngram_range == "(1, 2)" else (1, 1)
print("Selected:", best.ngram_range, "alpha =", best.alpha)

features = vectorizer(best_ngram).fit(tweets.model_text[train])
model = MultinomialNB(alpha=best.alpha).fit(features.transform(tweets.model_text[train]), tweets.airline_sentiment[train])

X_test = features.transform(tweets.model_text[test])
test_set = tweets.loc[test].assign(prediction=model.predict(X_test), confidence=model.predict_proba(X_test).max(axis=1))
test_set.to_csv(RESULTS / "test_predictions.csv", index=False)
y_test = test_set.airline_sentiment


def metric_row(name, prediction):
    precision, recall, f1, _ = precision_recall_fscore_support(y_test, prediction, average="macro", zero_division=0)
    return {"model": name, "accuracy": accuracy_score(y_test, prediction), "macro_precision": precision, "macro_recall": recall, "macro_f1": f1}


metrics = pd.DataFrame([metric_row("Majority baseline", [majority] * len(test)), metric_row("Multinomial NB", test_set.prediction)])
metrics.to_csv(RESULTS / "metrics.csv", index=False)
display(metrics.round(4))

matrix = confusion_matrix(y_test, test_set.prediction, labels=CLASSES)
pd.DataFrame(matrix, index=CLASSES, columns=CLASSES).to_csv(RESULTS / "confusion_matrix.csv")
ConfusionMatrixDisplay(matrix, display_labels=CLASSES).plot(colorbar=False)
plt.title("Naive Bayes test confusion matrix")
plt.tight_layout()
plt.savefig(RESULTS / "confusion_matrix.png", dpi=160)

precision, recall, f1, support = precision_recall_fscore_support(y_test, test_set.prediction, labels=CLASSES)
per_class = pd.DataFrame({"precision": precision, "recall": recall, "f1": f1, "support": support}, index=CLASSES)
per_class.to_csv(RESULTS / "per_class_metrics.csv")
display(per_class.round(3))

rows = []
for airline, group in test_set.groupby("airline"):
    rows.append({"airline": airline, "n_test": len(group), "accuracy": accuracy_score(group.airline_sentiment, group.prediction),
                 "macro_f1": f1_score(group.airline_sentiment, group.prediction, average="macro")})
per_airline = pd.DataFrame(rows).set_index("airline").sort_values("macro_f1")
per_airline.to_csv(RESULTS / "per_airline_f1.csv")
display(per_airline.round(3))


def category(text):
    text = text.lower()
    if "?" in text:
        return "question or request"
    if re.search(r"\b(no|not|never|can't|don't|didn't|won't)\b", text):
        return "negation"
    if len(text.split()) <= 7:
        return "very short text"
    return "mixed or ambiguous wording"


mistakes = test_set[test_set.prediction != test_set.airline_sentiment]
errors = pd.concat(mistakes[mistakes.airline_sentiment == c].nlargest(4, "confidence") for c in CLASSES)
errors = errors.assign(category=errors.text.map(category))
errors[["tweet_id", "airline", "airline_sentiment", "prediction", "confidence", "text", "category"]].to_csv(RESULTS / "error_analysis.csv", index=False)
display(errors[["airline_sentiment", "prediction", "confidence", "text", "category"]])
print("Saved:", sorted(p.name for p in RESULTS.iterdir()))

