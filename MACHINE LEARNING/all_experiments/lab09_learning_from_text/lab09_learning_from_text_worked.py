"""Lab 09: Learning from text.

The code cells of lab09_learning_from_text_worked.ipynb, in notebook order, as one script. From the course folder:
    python all_experiments/lab09_learning_from_text/lab09_learning_from_text_worked.py
It writes the same figures and tables as the notebook, to results/lab09/.
"""
from pathlib import Path
import os
os.chdir(Path(__file__).resolve().parent)

# %% Question 1 - Setup
# 1. The course helper: finds the course folder and prepares the output folders.
import sys
sys.path.insert(0, "..")                     # all_experiments/, where course_setup.py lives
from course_setup import start_lab

# 2. The libraries this lab uses.
import json
import re                                                          # patterns in text
from collections import Counter                                    # counts how often each thing occurs
import joblib                                                      # save and load fitted models
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from scipy import sparse                                           # tables that store only non-zero cells
from sklearn.decomposition import TruncatedSVD                     # compress a sparse table
from sklearn.feature_extraction.text import CountVectorizer, TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import (average_precision_score, confusion_matrix, precision_recall_curve,
                             precision_score, recall_score)
from sklearn.model_selection import StratifiedKFold, cross_val_predict, cross_val_score, train_test_split
from sklearn.naive_bayes import MultinomialNB
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import normalize                        # scale every row to length 1

# 3. Where this lab reads and writes.
DATA, RESULTS, MODELS = start_lab("lab09")

# %% Question 2 - Read the messages and remove the repeats
sms = pd.read_csv(DATA / "supervised/sms_spam/sms_spam.csv")
print("shape:", sms.shape)
print(sms["label"].value_counts().to_string())
print("messages that repeat an earlier one:", int(sms["message"].duplicated().sum()))

# A repeated message could land on both sides of a split, so keep one copy of each.
unique = sms.drop_duplicates("message").reset_index(drop=True)
is_spam = (unique["label"] == "spam").astype(int)
print("different messages:", len(unique), " spam:", int(is_spam.sum()), f"({is_spam.mean():.1%})")

length = unique["message"].str.len()
print("median length in characters:", length.groupby(unique["label"]).median().to_dict())
for label in ["ham", "spam"]:
    print(f"{label:5s}", unique.loc[unique["label"] == label, "message"].iloc[0][:98])

# Seal the test messages now; Part B opens them once, in Question 10.
text_train, text_test, y_train, y_test = train_test_split(unique["message"], is_spam, test_size=0.20,
                                                          random_state=42, stratify=is_spam)
y_train, y_test = y_train.to_numpy(), y_test.to_numpy()
print(len(text_train), "training messages,", int(y_train.sum()), "of them spam;",
      len(text_test), "test messages,", int(y_test.sum()), "of them spam")

# %% Question 3 - Split a message into tokens
def tokens(text):
    """Lower-case the text and keep every run of two or more letters, digits or underscores."""
    return re.findall(r"\b\w\w+\b", text.lower())

example = sms["message"][8]
print(example)
print(tokens(example))

# scikit-learn's vectorizer splits text by the same rule: check it on every training message.
analyze = CountVectorizer().build_analyzer()
print("\nsame tokens as CountVectorizer on every training message:",
      all(tokens(m) == analyze(m) for m in text_train))

# Count every token of the training messages.
frequency = Counter(token for message in text_train for token in tokens(message))
print("tokens:", sum(frequency.values()), " different tokens:", len(frequency))
print("most common:", frequency.most_common(8))
once = sum(1 for n in frequency.values() if n == 1)
print(f"tokens that occur exactly once: {once} ({once / len(frequency):.0%})")

# %% Question 4 - Build the table of counts
counter = CountVectorizer()
counts = counter.fit_transform(text_train)            # learn the vocabulary, then count
words = counter.get_feature_names_out()
cells = counts.shape[0] * counts.shape[1]
print("type:", type(counts).__name__, " shape:", counts.shape)
print(f"cells: {cells:,}   not zero: {counts.nnz:,} ({counts.nnz / cells:.2%})")
stored = counts.data.nbytes + counts.indices.nbytes + counts.indptr.nbytes
print(f"memory: {stored / 1024:.0f} KB stored sparse, "
      f"{cells * 8 / 1e6:.0f} MB if every zero were written out")

# One row of the table: the columns that are not zero, and the words they stand for.
row = counts[0]
print("\nfirst training message:", text_train.iloc[0])
print("its row:", {words[j]: int(n) for j, n in zip(row.indices, row.data)})

# The test messages are counted with the vocabulary learned from the training messages.
test_counts = counter.transform(text_test)
known = set(words)
unseen = [token for message in text_test for token in tokens(message) if token not in known]
with_unseen = np.mean([any(token not in known for token in tokens(message)) for message in text_test])
print("\ntest table:", test_counts.shape, " test tokens with no column:", len(unseen),
      "for example", unseen[:5])
print(f"test messages with at least one such token: {with_unseen:.1%}")

# %% Question 5 - Find the words that separate spam from ham
present = (counts > 0).astype(int)                    # 1 where the word occurs in the message at all
share = pd.DataFrame({
    "spam": np.asarray(present[y_train == 1].mean(axis=0)).ravel(),
    "ham": np.asarray(present[y_train == 0].mean(axis=0)).ravel(),
}, index=words)
share["difference"] = share["spam"] - share["ham"]
ordered = share.sort_values("difference")
print("share of messages that contain the word (%)")
print((100 * ordered.tail(8)[::-1]).round(1).to_string())
print((100 * ordered.head(8)).round(1).to_string())
common = (100 * share.loc[["you", "the", "and"], ["spam", "ham"]]).round(1)
print("\nnearly the same on both sides:", common.to_dict("index"))

fig, axes = plt.subplots(1, 2, figsize=(10, 3.6))
for ax, part, title in [(axes[0], ordered.tail(8), "Words that lean towards spam"),
                        (axes[1], ordered.head(8)[::-1], "Words that lean towards ham")]:
    places = np.arange(len(part))
    ax.barh(places, 100 * part["spam"], height=-0.4, align="edge", label="spam")
    ax.barh(places, 100 * part["ham"], height=0.4, align="edge", label="ham")
    ax.set_yticks(places, part.index)
    ax.set_xlabel("Messages that contain the word (%)")
    ax.set_title(title)
    ax.legend()
plt.tight_layout()
plt.savefig(RESULTS / "words_that_separate_spam_from_ham.png", dpi=160, bbox_inches="tight")
plt.show()

# %% Question 6 - Fit naive Bayes inside a pipeline
folds = StratifiedKFold(5, shuffle=True, random_state=42)

def cross_validated(vectorizer, model):
    """A spam probability for every training message, each from a pipeline that never saw it."""
    pipeline = Pipeline([("words", vectorizer), ("model", model)])
    return cross_val_predict(pipeline, text_train, y_train, cv=folds, method="predict_proba")[:, 1]

def score(name, prob_spam, threshold=0.5):
    """Precision, recall and the two kinds of mistake at one threshold, on the training messages."""
    flagged = prob_spam >= threshold
    return {"filter": name,
            "precision": precision_score(y_train, flagged),
            "recall": recall_score(y_train, flagged),
            "average precision": average_precision_score(y_train, prob_spam),
            "real flagged": int((flagged & (y_train == 0)).sum()),
            "spam missed": int((~flagged & (y_train == 1)).sum())}

def show(rows):
    """Print a list of scores as a table, one filter per line."""
    print(pd.DataFrame(rows).set_index("filter").round(3).to_string())

print(f"answering 'ham' every time is right for {1 - y_train.mean():.1%} of the training messages\n")
prob = {"naive Bayes on counts": cross_validated(CountVectorizer(), MultinomialNB())}
show([score("naive Bayes on counts", prob["naive Bayes on counts"])])

# %% Question 7 - Weigh the words with tf-idf, by hand first
tiny = ["win a free prize now", "call me now", "free call free prize", "are you free now"]
tiny_counter = CountVectorizer()
tiny_words = tiny_counter.fit(tiny).get_feature_names_out()
tiny_counts = pd.DataFrame(tiny_counter.transform(tiny).toarray(), columns=tiny_words)
print(tiny_counts.to_string())

in_messages = (tiny_counts > 0).sum()                              # messages that contain each word
idf = np.log((1 + len(tiny)) / (1 + in_messages)) + 1
raw = tiny_counts.loc[2] * idf                                     # message 3: count times idf ...
by_hand = raw / np.sqrt((raw ** 2).sum())                          # ... scaled to length 1
print("\nidf:", idf.round(3).to_dict())
print("message 3 by hand:           ", by_hand[by_hand > 0].round(3).to_dict())

weights = TfidfVectorizer().fit_transform(tiny)
print("message 3 by TfidfVectorizer:", {tiny_words[j]: round(float(v), 3)
                                        for j, v in sorted(zip(weights[2].indices, weights[2].data))})

# The same weights on the real training messages.
real = TfidfVectorizer().fit(text_train)
real_idf = pd.Series(real.idf_, index=real.get_feature_names_out())
chosen_words = ["you", "call", "free", "claim", "prize", "lunch"]
containing = {w: int(present[:, counter.vocabulary_[w]].sum()) for w in chosen_words}
print("\nmessages containing the word:", containing)
print("idf on the training messages:", real_idf[chosen_words].round(2).to_dict())

# %% Question 8 - Compare four filters
pieces = TfidfVectorizer(analyzer="char_wb", ngram_range=(2, 5), sublinear_tf=True)
candidates = {
    "logistic on tf-idf, C = 1": (TfidfVectorizer(), LogisticRegression(max_iter=2000)),
    "logistic on tf-idf, C = 10": (TfidfVectorizer(), LogisticRegression(max_iter=2000, C=10)),
    "logistic on character pieces": (pieces, LogisticRegression(max_iter=2000, C=10)),
}
for name, (vectorizer, model) in candidates.items():
    prob[name] = cross_validated(vectorizer, model)
show([score(name, prob_spam) for name, prob_spam in prob.items()])
print("\ncolumns of the character filter:", len(pieces.fit(text_train).vocabulary_))
print("the pieces of 'txt':", pieces.build_analyzer()("txt"))

plt.figure(figsize=(5.8, 3.8))
for name, prob_spam in prob.items():
    precision, recall, _ = precision_recall_curve(y_train, prob_spam)
    plt.plot(recall, precision, label=name)
plt.xlim(0.6, 1)
plt.ylim(0.9, 1.003)
plt.xlabel("Recall: share of the spam caught")
plt.ylabel("Precision: share of the flagged that is spam")
plt.title("Four spam filters, cross-validated")
plt.legend(fontsize=8)
plt.tight_layout()
plt.savefig(RESULTS / "four_spam_filters.png", dpi=160, bbox_inches="tight")
plt.show()

# %% Question 9 - Read what the filter learned
word_filter = Pipeline([("words", TfidfVectorizer()), ("model", LogisticRegression(max_iter=2000, C=10))])
word_filter.fit(text_train, y_train)
weight = pd.Series(word_filter.named_steps["model"].coef_[0],
                   index=word_filter.named_steps["words"].get_feature_names_out()).sort_values()
print("pushing towards spam:", weight.tail(10).index[::-1].tolist())
print("pushing towards ham: ", weight.head(10).index.tolist())

# Two of the ham words are not words. Where do they come from?
coded = text_train.str.contains("&lt;", regex=False).to_numpy()
print("\ntraining messages that contain '&lt;':", int(coded.sum()),
      " of them spam:", int(y_train[coded].sum()))
for i in text_train[coded].str.len().nsmallest(3).index:
    print("   ", text_train[i])

# %% Question 10 - Choose the threshold, then open the test messages
def strict_threshold(y, prob_spam, allowed=0.001):
    """The lowest threshold that sends at most `allowed` of the real messages to the spam folder."""
    ham = np.sort(prob_spam[y == 0])[::-1]                  # real messages, most spam-like first
    budget = int(allowed * len(ham))                        # how many of them may be flagged
    return float(ham[budget]) + 1e-6                        # just above the first that may not be

chosen = "logistic on character pieces"
threshold = strict_threshold(y_train, prob[chosen])
print(f"threshold for at most 1 real message in 1,000: {threshold:.2f}")
show([score("cross-validated, at 0.50", prob[chosen]),
      score(f"cross-validated, at {threshold:.2f}", prob[chosen], threshold)])

# Fit the chosen filter on all the training messages, and open the test messages once.
vectorizer, model = candidates[chosen]
spam_filter = Pipeline([("words", vectorizer), ("model", model)]).fit(text_train, y_train)
test_prob = spam_filter.predict_proba(text_test)[:, 1]
flagged = test_prob >= threshold
matrix = confusion_matrix(y_test, flagged)
outcome = pd.DataFrame(matrix, index=["real", "spam"], columns=["to the inbox", "to the spam folder"])
print("\n" + outcome.to_string())
print(f"test precision {precision_score(y_test, flagged):.3f}   recall {recall_score(y_test, flagged):.3f}"
      f"   average precision {average_precision_score(y_test, test_prob):.3f}")
print("real messages sent to the spam folder:")
for message in text_test[flagged & (y_test == 0)]:
    print("   ", message[:100])

# %% Question 11 - Classify bank questions into 77 intents
bank = pd.read_csv(DATA / "advanced/banking77/banking77.csv")
train = bank[bank["split"] == "train"].reset_index(drop=True)
test = bank[bank["split"] == "test"].reset_index(drop=True)
intents = bank.drop_duplicates("label").sort_values("label")["intent"].tolist()   # position = label
q_train, q_test = train["text"], test["text"]
i_train, i_test = train["label"].to_numpy(), test["label"].to_numpy()
sizes = train["intent"].value_counts()
print(len(q_train), "training questions,", len(q_test), "test questions,", len(intents), "intents")
print(f"training questions per intent: from {sizes.min()} ({sizes.idxmin()})"
      f" to {sizes.max()} ({sizes.idxmax()})")
for _, question in train.sample(4, random_state=1).iterrows():
    print(f"    {question['intent']:26s} {question['text'][:76]}")

intent_model = Pipeline([("words", TfidfVectorizer()), ("model", LogisticRegression(max_iter=3000, C=10))])
intent_model.fit(q_train, i_train)
intent_prob = intent_model.predict_proba(q_test)
predicted = intent_prob.argmax(axis=1)
intent_accuracy = (predicted == i_test).mean()
top_three = np.argsort(intent_prob, axis=1)[:, -3:]
in_top_three = np.mean([truth in row for truth, row in zip(i_test, top_three)])
columns = len(intent_model.named_steps["words"].vocabulary_)
print(f"\ncolumns: {columns}   guessing: {1 / len(intents):.3f}")
print(f"test accuracy: {intent_accuracy:.3f}   right intent in the top three: {in_top_three:.3f}")

# %% Question 12 - Find where the classifier fails
matrix77 = confusion_matrix(i_test, predicted)
recall = pd.Series(matrix77.diagonal() / matrix77.sum(axis=1), index=intents).sort_values()
print("lowest recall:")
print(recall.head(5).round(3).to_string())
print("intents with every test question right:", int((recall == 1).sum()),
      "  intents below 0.80:", int((recall < 0.80).sum()))

mistakes = matrix77 - np.diag(matrix77.diagonal())
pairs = [(intents[i], intents[j], int(mistakes[i, j])) for i, j in zip(*np.where(mistakes >= 4))]
confused = pd.DataFrame(pairs, columns=["asked_about", "model_answered", "times"])
confused = confused.sort_values(["times", "asked_about"], ascending=[False, True])
print("\npairs confused four times or more:")
print(confused.to_string(index=False))

plt.figure(figsize=(10, 3.2))
plt.bar(range(len(recall)), recall.to_numpy())
plt.axhline(intent_accuracy, linestyle="--", color="grey", label="overall accuracy")
plt.xlabel("The 77 intents, from the lowest recall to the highest")
plt.ylabel("Recall on 40 test questions")
plt.title("Recall of each intent")
plt.legend()
plt.tight_layout()
plt.savefig(RESULTS / "recall_of_each_intent.png", dpi=160, bbox_inches="tight")
plt.show()

# %% Question 13 - Validate the preprocessing
settings = {
    "single words": TfidfVectorizer(),
    "single words, stop words removed": TfidfVectorizer(stop_words="english"),
    "words and pairs": TfidfVectorizer(ngram_range=(1, 2), min_df=2),
}
three_folds = StratifiedKFold(3, shuffle=True, random_state=42)
preprocessing = {}
for name, candidate in settings.items():
    pipeline = Pipeline([("words", candidate), ("model", LogisticRegression(max_iter=3000, C=10))])
    cv_accuracy = cross_val_score(pipeline, q_train, i_train, cv=three_folds).mean()
    columns = len(candidate.fit(q_train).vocabulary_)
    preprocessing[name] = {"columns": columns, "cv_accuracy": cv_accuracy}
    print(f"{name:34s} {columns:6d} columns   cross-validated accuracy {cv_accuracy:.3f}")

stop_list = TfidfVectorizer(stop_words="english").get_stop_words()
asked = ["how", "why", "not", "my", "when", "still", "card", "pin"]
print("\non the stop list:", [word for word in asked if word in stop_list])

# %% Question 14 - Search the stored questions by similarity
vectorizer = intent_model.named_steps["words"]
w_train = vectorizer.transform(q_train)               # one tf-idf row per stored question, of length 1

def nearest_by_words(query, k=3):
    """Print the k stored questions most similar to the query, by the cosine of their tf-idf rows."""
    similarity = (w_train @ vectorizer.transform([query]).T).toarray().ravel()
    for i in np.argsort(similarity)[::-1][:k]:
        print(f"    {similarity[i]:.2f}  {train['intent'][i]:36s} {q_train[i]}")

queries = ["how do I change my pin", "my new card still has not arrived",
           "the cash machine swallowed my card"]
for query in queries:
    print("query:", query)
    nearest_by_words(query)

# %% Question 15 - Count the company each word keeps
analyze = vectorizer.build_analyzer()
documents = [analyze(text) for text in q_train]
frequency = Counter(word for tokens_ in documents for word in tokens_)
vocabulary = sorted(word for word, n in frequency.items() if n >= 3)
position = {word: i for i, word in enumerate(vocabulary)}

window = 4
rows, cols = [], []
for tokens_ in documents:
    ids = [position[word] for word in tokens_ if word in position]
    for here, word_id in enumerate(ids):
        for neighbor in ids[max(0, here - window):here] + ids[here + 1:here + 1 + window]:
            rows.append(word_id)
            cols.append(neighbor)
shape = (len(vocabulary), len(vocabulary))
together = sparse.coo_matrix((np.ones(len(rows)), (rows, cols)), shape=shape).tocsr()
print("words with a row:", len(vocabulary), "  pairs counted:", len(rows),
      "  cells not zero:", together.nnz)

# The company of one word, by raw count and by how many times more often than chance.
alone = np.asarray(together.sum(axis=1)).ravel()                 # how much company each word has in total
near = together[position["declined"]].toarray().ravel()
expected = alone[position["declined"]] * alone / alone.sum()
company = pd.DataFrame({"count": near, "lift": near / expected}, index=vocabulary)
most_often = company["count"].sort_values(ascending=False).head(8).astype(int)
print("\nmost often near 'declined':", most_often.to_dict())
often = company[company["count"] >= 5]                           # seen near it at least five times
above_chance = often["lift"].sort_values(ascending=False).head(8).round(1)
print("furthest above chance:     ", above_chance.to_dict())

# %% Question 16 - Compress the company into word vectors
pairs = together.tocoo()
pmi = np.log(pairs.data * pairs.sum() / (alone[pairs.row] * alone[pairs.col]))
keep = pmi > 0                                                    # pairs seen more often than chance
ppmi = sparse.coo_matrix((pmi[keep], (pairs.row[keep], pairs.col[keep])), shape=shape).tocsr()
vectors = normalize(TruncatedSVD(n_components=100, random_state=42).fit_transform(ppmi))
print("cells above chance:", ppmi.nnz, "  word vectors:", vectors.shape)

def neighbors(word, k=5):
    """The k words whose vectors point most nearly the same way as the given word's."""
    similarity = vectors @ vectors[position[word]]
    return [vocabulary[i] for i in np.argsort(similarity)[::-1][1:k + 1]]

asked = ["pin", "stolen", "fee", "declined", "cash", "atm", "arrived"]
word_neighbors = {word: neighbors(word) for word in asked}
for word, near_words in word_neighbors.items():
    print(f"{word:9s}", near_words)

# %% Question 17 - Search again, by meaning
def message_vectors(texts):
    """Each text as the average of its words' vectors, scaled to length 1."""
    out = np.zeros((len(texts), vectors.shape[1]))
    for row, text in enumerate(texts):
        ids = [position[word] for word in analyze(text) if word in position]
        if ids:
            out[row] = vectors[ids].mean(axis=0)
    return normalize(out)

d_train, d_test = message_vectors(q_train), message_vectors(q_test)
print("one vector per question:", d_train.shape)

def nearest_by_vectors(query, k=3):
    """Print the k stored questions whose averaged word vectors are closest to the query's."""
    similarity = d_train @ message_vectors([query])[0]
    for i in np.argsort(similarity)[::-1][:k]:
        print(f"    {similarity[i]:.2f}  {train['intent'][i]:36s} {q_train[i]}")

for query in queries:
    print("query:", query)
    nearest_by_vectors(query)

# %% Question 18 - Classify with the vectors, with many labels and with few
def accuracy_of(features_train, features_test, chosen=slice(None)):
    """Fit the logistic regression on the chosen training rows and score it on every test question."""
    model = LogisticRegression(max_iter=3000, C=10).fit(features_train[chosen], i_train[chosen])
    return (model.predict(features_test) == i_test).mean()

w_test = vectorizer.transform(q_test)
words_all, vectors_all = accuracy_of(w_train, w_test), accuracy_of(d_train, d_test)
print(f"all the labels: tf-idf, 2,320 columns               test accuracy {words_all:.3f}")
print(f"all the labels: averaged word vectors, 100 columns  test accuracy {vectors_all:.3f}")

label_efficiency = []
for per_intent in (2, 5, 10):
    by_words, by_vectors = [], []
    for seed in range(10):
        rng = np.random.default_rng(seed)
        few = np.concatenate([rng.choice(np.where(i_train == c)[0], per_intent, replace=False)
                              for c in range(len(intents))])
        by_words.append(accuracy_of(w_train, w_test, few))
        by_vectors.append(accuracy_of(d_train, d_test, few))
    ahead = int(np.sum(np.array(by_vectors) > np.array(by_words)))
    label_efficiency.append({"labels_per_intent": per_intent, "tfidf": np.mean(by_words),
                             "word_vectors": np.mean(by_vectors), "vectors_ahead_in_10": ahead})
    print(f"{per_intent:2d} labels per intent: tf-idf {np.mean(by_words):.3f}"
          f"   word vectors {np.mean(by_vectors):.3f}   vectors ahead in {ahead} of 10 draws")

curve = pd.DataFrame(label_efficiency)
plt.figure(figsize=(5.6, 3.6))
plt.plot(range(4), list(curve["tfidf"]) + [words_all], marker="o", label="tf-idf")
plt.plot(range(4), list(curve["word_vectors"]) + [vectors_all], marker="o", label="averaged word vectors")
plt.xticks(range(4), ["2", "5", "10", "all (about 130)"])
plt.xlabel("Labeled questions for each intent")
plt.ylabel("Test accuracy")
plt.title("Which representation needs fewer labels?")
plt.legend()
plt.tight_layout()
plt.savefig(RESULTS / "which_representation_needs_fewer_labels.png", dpi=160, bbox_inches="tight")
plt.show()

# %% Question 19 - Save the intent model and use it
model_path = MODELS / "bank_intent_tfidf_logistic.joblib"
joblib.dump(intent_model, model_path)
card = {
    "task": "send a customer's question to one of 77 banking intents",
    "input": "a list of raw strings; the pipeline lower-cases and tokenizes them itself",
    "output": "predict: the label number; predict_proba: 77 probabilities; intents[label] is the name",
    "intents": intents,
    "model": "TfidfVectorizer() on single words, then LogisticRegression(C=10)",
    "training_questions": len(q_train),
    "test_accuracy": round(float(intent_accuracy), 3),
    "test_top_three_accuracy": round(float(in_top_three), 3),
    "weakest_intent": {"name": recall.index[0], "recall": round(float(recall.iloc[0]), 3)},
    "known_limits": "matches words letter for letter; words it never saw are ignored without a warning",
}
(MODELS / "bank_intent_card.json").write_text(json.dumps(card, indent=2))

loaded = joblib.load(model_path)
same = np.array_equal(loaded.predict(q_test), predicted)
size_kb = round(model_path.stat().st_size / 1024)
print("file size (KB):", size_kb, "  reloaded model predicts the same:", same)

new_questions = ["I never got the card you sent me", "why was I charged twice for my coffee",
                 "the cash machine swallowed my card"]
for question, row in zip(new_questions, loaded.predict_proba(new_questions)):
    best = np.argsort(row)[::-1][:3]
    print(question)
    print("    " + ",  ".join(f"{intents[j]} {row[j]:.2f}" for j in best))

# %% Question 20 - Save the evidence
(100 * ordered[["spam", "ham"]]).round(1).rename_axis("word").to_csv(RESULTS / "word_share_by_class.csv")
pd.DataFrame(matrix, index=["real", "spam"], columns=["to_inbox", "to_spam_folder"]).to_csv(
    RESULTS / "spam_test_confusion_matrix.csv")
recall.round(3).rename("recall").rename_axis("intent").to_csv(RESULTS / "recall_by_intent.csv")
confused.to_csv(RESULTS / "confused_intent_pairs.csv", index=False)
settings_table = pd.DataFrame(preprocessing).T.round(3).rename_axis("vectorizer")
settings_table.to_csv(RESULTS / "preprocessing_comparison.csv")
pd.DataFrame(word_neighbors).T.rename_axis("word").to_csv(RESULTS / "word_neighbors.csv")
curve.round(3).to_csv(RESULTS / "label_efficiency.csv", index=False)
metrics = [
    {"part": "B", "dataset": "sms_spam", "model": chosen, "threshold": round(threshold, 2),
     "test_precision": precision_score(y_test, flagged), "test_recall": recall_score(y_test, flagged),
     "test_average_precision": average_precision_score(y_test, test_prob)},
    {"part": "C", "dataset": "banking77", "model": "tf-idf + logistic",
     "test_accuracy": intent_accuracy, "test_top_three_accuracy": in_top_three},
    {"part": "D", "dataset": "banking77", "model": "averaged word vectors + logistic",
     "test_accuracy": vectors_all},
]
pd.DataFrame(metrics).round(3).to_csv(RESULTS / "metrics.csv", index=False)
print("Saved:", sorted(p.name for p in RESULTS.iterdir()))

# %% Question 21 - Try it yourself
# Your work here

# %% Question 22 - One solution
def character_pieces():
    return TfidfVectorizer(analyzer="char_wb", ngram_range=(2, 5), sublinear_tf=True)

# Part 1: the same split, with the repeated messages left in.
all_spam = (sms["label"] == "spam").astype(int)
text_a, text_b, y_a, y_b = train_test_split(sms["message"], all_spam, test_size=0.20, random_state=42,
                                            stratify=all_spam)
leaky = Pipeline([("words", character_pieces()), ("model", LogisticRegression(max_iter=2000, C=10))])
leaky.fit(text_a, y_a)
caught = pd.Series(leaky.predict_proba(text_b)[:, 1] >= 0.5, index=text_b.index)
seen = text_b.isin(set(text_a))
spam_b = y_b == 1
n_seen, n_new = int((seen & spam_b).sum()), int((~seen & spam_b).sum())
print(f"test messages that also occur in training: {seen.mean():.1%}")
print(f"recall on the {n_seen} test spam seen in training: {caught[seen & spam_b].mean():.3f}")
print(f"recall on the {n_new} test spam not seen:        {caught[~seen & spam_b].mean():.3f}")
print(f"recall on all the test spam:                {caught[spam_b].mean():.3f}")
print(f"Question 10's filter at 0.5, repeats removed: {recall_score(y_test, test_prob >= 0.5):.3f}")

# Part 2: character pieces on the 77 intents.
by_pieces = Pipeline([("words", character_pieces()), ("model", LogisticRegression(max_iter=3000, C=10))])
by_pieces.fit(q_train, i_train)
pieces_accuracy = (by_pieces.predict(q_test) == i_test).mean()
print(f"\ncharacter pieces on the intents: {len(by_pieces.named_steps['words'].vocabulary_)} columns")
print(f"test accuracy {pieces_accuracy:.3f}, against {intent_accuracy:.3f} for single words")
