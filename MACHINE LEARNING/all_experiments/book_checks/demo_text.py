"""Learning from text: the worked numbers of Chapter 31.

Two collections of short messages go from raw text to a working classifier: 5,572 text messages
labeled spam or ham, and 13,083 questions typed to a bank's support chat, labeled with 77 intents.
Along the way the script counts tokens, weighs them, trims the vocabulary, picks a threshold for a
spam folder, searches by similarity, and builds word vectors from nothing but the company words keep.

Run from the course folder:      python all_experiments/book_checks/demo_text.py
It reads all_datasets/supervised/sms_spam/ and all_datasets/advanced/banking77/ and takes about a minute.
"""
from collections import Counter
from pathlib import Path

import numpy as np
import pandas as pd
from scipy import sparse
from sklearn.decomposition import TruncatedSVD
from sklearn.feature_extraction.text import ENGLISH_STOP_WORDS, CountVectorizer, TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import average_precision_score, confusion_matrix, precision_score, recall_score
from sklearn.model_selection import StratifiedKFold, cross_val_predict, train_test_split
from sklearn.naive_bayes import MultinomialNB
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import normalize

DATA = Path(__file__).resolve().parents[2] / "all_datasets"
CHECK_BOOK_NUMBERS = True
FOUND = {}          # every value the asserts below check
FOLDS = StratifiedKFold(5, shuffle=True, random_state=42)
pd.set_option("display.width", 160)

TINY = ["win a free prize now", "call me now", "free call free prize", "are you free now"]


def tiny():
    """Four made-up messages, small enough to count and weigh by hand."""
    counter = CountVectorizer()
    counts = counter.fit_transform(TINY)
    words = counter.get_feature_names_out()
    names = [f"message {i}" for i in range(1, len(TINY) + 1)]
    table = pd.DataFrame(counts.toarray(), index=names, columns=words)
    print("counts\n" + table.to_string())

    weigher = TfidfVectorizer()
    weights = weigher.fit_transform(TINY)
    in_messages = (table > 0).sum()                                    # document frequency of every word
    idf = np.log((1 + len(TINY)) / (1 + in_messages)) + 1              # the formula scikit-learn uses
    assert np.allclose(idf, weigher.idf_)
    print("\nmessages containing each word:", in_messages.to_dict())
    print("idf:", idf.round(3).to_dict())
    raw = table.loc["message 3"] * idf                                 # count times idf ...
    by_hand = raw / np.sqrt((raw ** 2).sum())                          # ... then scaled to length 1
    assert np.allclose(by_hand, weights[2].toarray()[0])
    print("message 3, count x idf:", raw[raw > 0].round(3).to_dict(), " length:", round(float(np.sqrt((raw ** 2).sum())), 3))
    print("message 3, tf-idf:", by_hand[by_hand > 0].round(3).to_dict())
    FOUND["tiny"] = (list(words), table.to_numpy().tolist(), idf.round(3).to_dict(), by_hand[by_hand > 0].round(3).to_dict())

    # Word order: two opposite sentences with exactly the same bag of words.
    real, scam = "the offer is real, not a scam", "the offer is a scam, not real"
    single = CountVectorizer().fit([real, scam])
    same_bag = (single.transform([real]) != single.transform([scam])).nnz == 0
    pairs = CountVectorizer(ngram_range=(2, 2))
    in_pairs = pd.DataFrame(pairs.fit_transform([real, scam]).toarray(), columns=pairs.get_feature_names_out())
    only_real = in_pairs.columns[(in_pairs.iloc[0] > 0) & (in_pairs.iloc[1] == 0)].tolist()
    only_scam = in_pairs.columns[(in_pairs.iloc[1] > 0) & (in_pairs.iloc[0] == 0)].tolist()
    print(f"\nsame bag of single words: {same_bag}; word pairs only in the first: {only_real}; only in the second: {only_scam}")
    FOUND["order"] = (same_bag, only_real, only_scam)


def read_messages():
    """The text messages with repeats removed, split once into training and test messages."""
    sms = pd.read_csv(DATA / "supervised/sms_spam/sms_spam.csv")
    unique = sms.drop_duplicates("message").reset_index(drop=True)  # a repeat must not sit on both sides
    is_spam = (unique["label"] == "spam").astype(int)
    split = train_test_split(unique["message"], is_spam, test_size=0.20, random_state=42, stratify=is_spam)
    return sms, unique, split


def cross_validated(vectorizer, model, text, y):
    """A spam probability for every training message, each from a pipeline that never saw that message."""
    pipeline = Pipeline([("words", vectorizer), ("model", model)])
    return cross_val_predict(pipeline, text, y, cv=FOLDS, method="predict_proba")[:, 1]


def strict_threshold(y, prob, allowed=0.001):
    """The lowest threshold that sends at most `allowed` of the real messages to the spam folder."""
    ham = np.sort(prob[y == 0])[::-1]                       # real messages, most spam-like first
    budget = int(allowed * len(ham))                        # how many of them may be flagged
    return float(ham[budget]) + 1e-6                        # just above the first that may not be


def scores(y, prob, threshold=0.5):
    flagged = prob >= threshold
    return {"precision": round(precision_score(y, flagged, zero_division=0), 3), "recall": round(recall_score(y, flagged), 3),
            "average_precision": round(average_precision_score(y, prob), 3),
            "real_flagged": int((flagged & (y == 0)).sum()), "spam_missed": int((~flagged & (y == 1)).sum())}


def spam():
    """From raw text messages to a spam folder with a chosen threshold."""
    f = FOUND
    sms, unique, (text_train, text_test, y_train, y_test) = read_messages()
    y_train, y_test = y_train.to_numpy(), y_test.to_numpy()
    f["rows"] = (len(sms), int(sms["message"].duplicated().sum()), len(unique), int((unique["label"] == "spam").sum()))
    f["split"] = (len(text_train), int(y_train.sum()), len(text_test), int(y_test.sum()))
    length = unique["message"].str.len().groupby(unique["label"]).median()
    f["length"] = length.to_dict()
    print(f"\n{f['rows'][0]:,} messages, {f['rows'][1]} of them repeats; {f['rows'][2]:,} different messages, "
          f"{f['rows'][3]} spam ({f['rows'][3] / f['rows'][2]:.1%})")
    print(f"median length in characters: {f['length']}")
    print(f"training messages: {f['split'][0]:,} ({f['split'][1]} spam); test messages: {f['split'][2]:,} ({f['split'][3]} spam)")

    # Tokens: what the default analyzer makes of one message.
    counter = CountVectorizer()
    counts = counter.fit_transform(text_train)
    words = counter.get_feature_names_out()
    analyze = counter.build_analyzer()
    example = sms["message"][8]
    f["tokens"] = analyze(example)
    print("\none message:", example)
    print("its tokens:", f["tokens"])

    # The document-term matrix.
    cells = counts.shape[0] * counts.shape[1]
    f["matrix"] = (counts.shape, int(counts.nnz), cells, round(100 * counts.nnz / cells, 2), round(counts.sum() / counts.shape[0], 1))
    print(f"\ncount matrix: {counts.shape[0]:,} messages x {counts.shape[1]:,} words = {cells:,} cells, "
          f"{counts.nnz:,} of them not zero ({f['matrix'][3]}%); {f['matrix'][4]} tokens per message")
    totals = pd.Series(np.asarray(counts.sum(axis=0)).ravel(), index=words).sort_values(ascending=False)
    f["top"] = totals.head(8).to_dict()
    f["once"] = int((totals == 1).sum())
    print("most frequent words:", f["top"])
    print(f"words that occur once in all the training messages: {f['once']:,} of {len(words):,} ({f['once'] / len(words):.0%})")
    bands = pd.cut(totals, [0, 1, 2, 5, 20, np.inf], labels=["once", "twice", "3 to 5", "6 to 20", "over 20"])
    f["tail"] = bands.value_counts().reindex(bands.cat.categories).to_dict()
    f["tail_tokens"] = round(100 * totals[totals > 20].sum() / totals.sum(), 1)
    print(f"words by how often they occur: {f['tail']}; the words seen over 20 times make up {f['tail_tokens']}% of all tokens")

    # Which words separate the classes? The share of spam and of ham messages that contain each.
    present = (counts > 0).astype(int)
    share = pd.DataFrame({"spam": np.asarray(present[y_train == 1].mean(axis=0)).ravel(),
                          "ham": np.asarray(present[y_train == 0].mean(axis=0)).ravel()}, index=words)
    chosen = ["call", "free", "txt", "claim", "you", "to", "my", "ok"]
    f["share"] = (100 * share.loc[chosen]).round(1)
    print("\nshare of messages that contain the word (%):\n" + f["share"].T.to_string())

    # Trimming the vocabulary: stop words, rare words, stems. Scored with naive Bayes on counts.
    from nltk.stem import PorterStemmer                 # pure Python: no corpus download is needed
    stemmer = PorterStemmer()
    f["stems"] = {w: stemmer.stem(w) for w in ["calls", "calling", "called", "winning", "wins", "winner", "won", "prizes",
                                                "freely", "university", "universe"]}
    print("\nstems:", f["stems"])

    def stemmed(text):
        return [stemmer.stem(word) for word in analyze(text)]

    trims = {
        "every word": CountVectorizer(),
        "without the stop list": CountVectorizer(stop_words="english"),
        "in at least two messages": CountVectorizer(min_df=2),
        "stemmed": CountVectorizer(analyzer=stemmed),
    }
    f["trim"] = {}
    for name, vectorizer in trims.items():
        size = len(vectorizer.fit(text_train).vocabulary_)
        ap = average_precision_score(y_train, cross_validated(vectorizer, MultinomialNB(), text_train, y_train))
        f["trim"][name] = (size, round(ap, 3))
        print(f"{name:26s} vocabulary {size:5,d}   naive Bayes, cross-validated average precision {ap:.3f}")
    f["stop_list"] = len(ENGLISH_STOP_WORDS)
    print("words on scikit-learn's English stop list:", f["stop_list"])

    # Word pairs and triples: what they cost in columns.
    f["ngrams"] = {n: len(CountVectorizer(ngram_range=(1, n)).fit(text_train).vocabulary_) for n in (1, 2, 3)}
    print("\ncolumns with single words, plus pairs, plus triples:", f["ngrams"])

    # Weights: the idf of common and of rare words.
    weigher = TfidfVectorizer().fit(text_train)
    in_messages = pd.Series(np.asarray(present.sum(axis=0)).ravel(), index=words)
    idf = pd.Series(weigher.idf_, index=weigher.get_feature_names_out())
    f["idf"] = {w: (int(in_messages[w]), round(float(idf[w]), 2)) for w in ["you", "call", "free", "claim", "prize", "lunch"]}
    print("word: (training messages containing it, idf):", f["idf"])

    # Words the test messages use that the training messages never did.
    known = set(words)
    test_tokens = [analyze(message) for message in text_test]
    n_tokens = sum(len(tokens) for tokens in test_tokens)
    unseen = sum(word not in known for tokens in test_tokens for word in tokens)
    with_unseen = np.mean([any(word not in known for word in tokens) for tokens in test_tokens])
    f["unseen"] = (round(100 * unseen / n_tokens, 1), round(100 * with_unseen, 1))
    print(f"\ntest tokens never seen in training: {f['unseen'][0]}%; test messages with at least one: {f['unseen'][1]}%")

    # Four filters, each cross-validated on the training messages with the vectorizer inside the pipeline.
    candidates = {
        "naive Bayes on counts": (CountVectorizer(), MultinomialNB()),
        "logistic on tf-idf, C = 1": (TfidfVectorizer(), LogisticRegression(max_iter=2000)),
        "logistic on tf-idf, C = 10": (TfidfVectorizer(), LogisticRegression(max_iter=2000, C=10)),
        "logistic on character pieces": (TfidfVectorizer(analyzer="char_wb", ngram_range=(2, 5), sublinear_tf=True),
                                         LogisticRegression(max_iter=2000, C=10)),
    }
    f["always_ham"] = round(1 - y_train.mean(), 3)
    print(f"\nanswering 'ham' every time is right for {f['always_ham']:.1%} of the training messages")
    f["cv"], cv_prob = {}, {}
    for name, (vectorizer, model) in candidates.items():
        cv_prob[name] = cross_validated(vectorizer, model, text_train, y_train)
        f["cv"][name] = scores(y_train, cv_prob[name])
        print(f"{name:30s} {f['cv'][name]}")
    piece_maker = candidates["logistic on character pieces"][0]
    f["pieces"] = len(piece_maker.fit(text_train).vocabulary_)
    f["pieces_of_txt"] = piece_maker.build_analyzer()("txt")
    print(f"character pieces of 2 to 5 characters: {f['pieces']:,} columns; the pieces of 'txt': {f['pieces_of_txt']}")

    # The leak: learning the vocabulary and the idf from all the messages before cross-validating.
    all_weights = TfidfVectorizer().fit_transform(text_train)
    leaked = cross_val_predict(LogisticRegression(max_iter=2000, C=10), all_weights, y_train, cv=FOLDS, method="predict_proba")[:, 1]
    f["leak"] = (round(average_precision_score(y_train, leaked), 4),
                 round(average_precision_score(y_train, cv_prob["logistic on tf-idf, C = 10"]), 4))
    print(f"vectorizer fitted outside the folds: average precision {f['leak'][0]}; inside the pipeline: {f['leak'][1]}")

    # What the word model learned: its largest weights in each direction.
    word_model = Pipeline([("words", TfidfVectorizer()), ("model", LogisticRegression(max_iter=2000, C=10))]).fit(text_train, y_train)
    weight = pd.Series(word_model.named_steps["model"].coef_[0], index=word_model.named_steps["words"].get_feature_names_out())
    f["spam_words"] = weight.sort_values(ascending=False).head(8).index.tolist()
    f["ham_words"] = weight.sort_values().head(6).index.tolist()
    print("\nwords that push hardest towards spam:", f["spam_words"])
    print("words that push hardest towards ham: ", f["ham_words"])
    # 'lt' and 'gt' are what the tokenizer leaves of "&lt;" and "&gt;", the web's codes for < and >.
    coded = text_train.str.contains("&lt;", regex=False).to_numpy()
    f["coded"] = (int(coded[y_train == 0].sum()), int(coded[y_train == 1].sum()))
    print(f"training messages that contain '&lt;': {f['coded'][0]} ham, {f['coded'][1]} spam")
    f["coded_example"] = text_train[text_train[coded].str.len().idxmin()]      # the shortest of them, as an example
    print("   for example:", f["coded_example"])

    # Choose the threshold on the cross-validated probabilities: at most 1 real message in 1,000 flagged.
    chosen_name = "logistic on character pieces"
    threshold = strict_threshold(y_train, cv_prob[chosen_name])
    f["threshold"] = round(threshold, 2)
    f["cv_strict"] = scores(y_train, cv_prob[chosen_name], threshold)
    print(f"\nthreshold for at most 1 real message in 1,000: {threshold:.2f}  cross-validated: {f['cv_strict']}")

    # The test messages, opened once.
    vectorizer, model = candidates[chosen_name]
    final = Pipeline([("words", vectorizer), ("model", model)]).fit(text_train, y_train)
    test_prob = final.predict_proba(text_test)[:, 1]
    f["test_half"] = scores(y_test, test_prob)
    f["test_strict"] = scores(y_test, test_prob, threshold)
    f["test_matrix"] = confusion_matrix(y_test, test_prob >= threshold).tolist()
    print(f"test at 0.50: {f['test_half']}")
    print(f"test at {threshold:.2f}: {f['test_strict']}  confusion matrix {f['test_matrix']}")
    missed = text_test[(test_prob < threshold) & (y_test == 1)]
    quiz = missed[missed.str.contains("Simpsons")]
    f["missed"] = (len(missed), quiz.iloc[0][:100] if len(quiz) else None)
    print(f"one of the {len(missed)} spam messages that got through: {f['missed'][1]} ...")
    print("is 'not' on the stop list?", "not" in ENGLISH_STOP_WORDS)
    f["not_is_stop_word"] = "not" in ENGLISH_STOP_WORDS


def nearest_messages(query, vectorizer, weights, texts, k=3):
    """The k stored messages most similar to the query.

    Tf-idf rows have length 1, so the dot product of two rows is their cosine similarity."""
    similarity = (weights @ vectorizer.transform([query]).T).toarray().ravel()
    best = np.argsort(similarity)[::-1][:k]
    return [(round(float(similarity[i]), 2), texts.iloc[i]) for i in best]


def word_vectors(documents, window=4, size=100, min_count=3):
    """One dense vector per word, from nothing but which words appear near which.

    Count how often each pair of words occurs within `window` positions of each other, turn the counts into
    positive pointwise mutual information (how much more often than chance), and compress with an SVD."""
    frequency = Counter(word for tokens in documents for word in tokens)
    vocabulary = sorted(word for word, n in frequency.items() if n >= min_count)
    position = {word: i for i, word in enumerate(vocabulary)}
    rows, cols = [], []
    for tokens in documents:
        ids = [position[word] for word in tokens if word in position]
        for here, word_id in enumerate(ids):
            for neighbor in ids[max(0, here - window):here] + ids[here + 1:here + 1 + window]:
                rows.append(word_id)
                cols.append(neighbor)
    shape = (len(vocabulary), len(vocabulary))
    together = sparse.coo_matrix((np.ones(len(rows)), (rows, cols)), shape=shape).tocsr().tocoo()
    alone = np.asarray(together.sum(axis=1)).ravel()
    pmi = np.log(together.data * together.sum() / (alone[together.row] * alone[together.col]))
    keep = pmi > 0                                                     # pairs seen more often than chance
    ppmi = sparse.coo_matrix((pmi[keep], (together.row[keep], together.col[keep])), shape=shape).tocsr()
    vectors = normalize(TruncatedSVD(n_components=size, random_state=42).fit_transform(ppmi))
    return vocabulary, position, vectors


def neighbors(word, vocabulary, position, vectors, k=5):
    similarity = vectors @ vectors[position[word]]
    return [vocabulary[i] for i in np.argsort(similarity)[::-1][1:k + 1]]


def message_vectors(texts, analyze, position, vectors):
    """A message as the average of its words' vectors, scaled to length 1."""
    out = np.zeros((len(texts), vectors.shape[1]))
    for row, text in enumerate(texts):
        ids = [position[word] for word in analyze(text) if word in position]
        if ids:
            out[row] = vectors[ids].mean(axis=0)
    return normalize(out)


def intents():
    """Seventy-seven kinds of question to a bank: sparse weights, similarity search, and dense vectors."""
    f = FOUND
    bank = pd.read_csv(DATA / "advanced/banking77/banking77.csv")
    train, test = bank[bank["split"] == "train"].reset_index(drop=True), bank[bank["split"] == "test"].reset_index(drop=True)
    names = bank.drop_duplicates("label").sort_values("label")["intent"].tolist()
    y_train, y_test = train["label"].to_numpy(), test["label"].to_numpy()

    vectorizer = TfidfVectorizer()
    w_train, w_test = vectorizer.fit_transform(train["text"]), vectorizer.transform(test["text"])
    model = LogisticRegression(max_iter=3000, C=10).fit(w_train, y_train)
    prob = model.predict_proba(w_test)
    predicted = prob.argmax(axis=1)
    top3 = np.mean([truth in row for truth, row in zip(y_test, np.argsort(prob, axis=1)[:, -3:])])
    bayes = MultinomialNB().fit(CountVectorizer().fit_transform(train["text"]), y_train)
    bayes_accuracy = (bayes.predict(CountVectorizer().fit(train["text"]).transform(test["text"])) == y_test).mean()
    f["bank"] = (len(train), len(test), len(names), w_train.shape[1], round((predicted == y_test).mean(), 3), round(top3, 3),
                 round(bayes_accuracy, 3))
    print(f"\n{len(train):,} training and {len(test):,} test questions, {len(names)} intents, {w_train.shape[1]:,} words")
    print(f"logistic regression on tf-idf: test accuracy {f['bank'][4]}, right intent among its top three {f['bank'][5]}; "
          f"naive Bayes on counts {f['bank'][6]}; guessing {1 / len(names):.3f}")

    matrix = confusion_matrix(y_test, predicted)
    recall = pd.Series(matrix.diagonal() / matrix.sum(axis=1), index=names).sort_values()
    f["weakest"] = recall.head(3).round(2).to_dict()
    f["perfect"] = int((recall == 1).sum())
    print("lowest recall:", f["weakest"], f" intents with every test question right: {f['perfect']}")
    mistakes = matrix - np.diag(matrix.diagonal())
    f["confused"] = sorted([(names[i], names[j], int(mistakes[i, j])) for i, j in zip(*np.where(mistakes >= 5))])
    print("pairs confused five times or more (truth, prediction, count):", f["confused"])

    # Similarity search: the stored questions closest to a new one.
    f["search"] = {}
    for query in ["my new card still has not arrived", "how do I change my pin"]:
        hits = nearest_messages(query, vectorizer, w_train, train["text"])
        f["search"][query] = [(s, train["intent"][train["text"] == text].iloc[0], text) for s, text in hits]
        print("query:", query)
        for s, intent, text in f["search"][query]:
            print(f"    {s:.2f}  {intent:36s} {text}")

    # Dense vectors, first for messages: compress the tf-idf matrix with an SVD.
    f["lsa"] = {}
    for size in (100, 300):
        svd = TruncatedSVD(n_components=size, random_state=42).fit(w_train)
        z_train, z_test = normalize(svd.transform(w_train)), normalize(svd.transform(w_test))
        accuracy = (LogisticRegression(max_iter=3000, C=10).fit(z_train, y_train).predict(z_test) == y_test).mean()
        f["lsa"][size] = round(accuracy, 3)
        print(f"tf-idf compressed to {size} numbers per question: test accuracy {accuracy:.3f}")

    # Dense vectors for words, learned from the training questions without their labels.
    analyze = vectorizer.build_analyzer()
    vocabulary, position, vectors = word_vectors([analyze(text) for text in train["text"]])
    f["vector_words"] = len(vocabulary)
    f["neighbors"] = {word: neighbors(word, vocabulary, position, vectors)
                      for word in ["pin", "stolen", "fee", "declined", "cash", "atm"]}
    print(f"\nword vectors for {len(vocabulary):,} words; nearest neighbors:")
    for word, near in f["neighbors"].items():
        print(f"    {word:9s} {near}")
    d_train = message_vectors(train["text"], analyze, position, vectors)
    d_test = message_vectors(test["text"], analyze, position, vectors)
    averaged = (LogisticRegression(max_iter=3000, C=10).fit(d_train, y_train).predict(d_test) == y_test).mean()
    f["averaged"] = round(averaged, 3)

    # Search again, this time comparing averaged word vectors.
    f["dense_search"] = {}
    for query in ["my new card still has not arrived", "the cash machine swallowed my card"]:
        similarity = d_train @ message_vectors([query], analyze, position, vectors)[0]
        best = np.argsort(similarity)[::-1][:3]
        f["dense_search"][query] = [(round(float(similarity[i]), 2), train["intent"][i], train["text"][i]) for i in best]
        print("query, by word vectors:", query)
        for s, intent, text in f["dense_search"][query]:
            print(f"    {s:.2f}  {intent:36s} {text}")
    f["sparse_machine"] = nearest_messages("the cash machine swallowed my card", vectorizer, w_train, train["text"], k=1)[0]
    print("the same query by tf-idf, best match:", f["sparse_machine"])
    print(f"each question as the average of its word vectors: test accuracy {averaged:.3f}")

    # Few labels: does a vector learned from unlabeled text help when labels are scarce? Ten draws each.
    f["few"] = {}
    for per_intent in (2, 5, 10):
        sparse_scores, dense_scores = [], []
        for seed in range(10):
            rng = np.random.default_rng(seed)
            few = np.concatenate([rng.choice(np.where(y_train == c)[0], per_intent, replace=False) for c in range(len(names))])
            sparse_scores.append((LogisticRegression(max_iter=3000, C=10).fit(w_train[few], y_train[few]).predict(w_test) == y_test).mean())
            dense_scores.append((LogisticRegression(max_iter=3000, C=10).fit(d_train[few], y_train[few]).predict(d_test) == y_test).mean())
        wins = int(np.sum(np.array(dense_scores) > np.array(sparse_scores)))
        f["few"][per_intent] = (round(float(np.mean(sparse_scores)), 3), round(float(np.mean(dense_scores)), 3), wins)
        print(f"{per_intent:2d} labels per intent: tf-idf {f['few'][per_intent][0]}, averaged word vectors {f['few'][per_intent][1]} "
              f"(ahead in {wins} of 10 draws)")


def main():
    tiny()
    spam()
    intents()
    if not CHECK_BOOK_NUMBERS:
        return
    f = FOUND
    words, table, idf, message3 = f["tiny"]
    assert words == ["are", "call", "free", "me", "now", "prize", "win", "you"]
    assert table == [[0, 0, 1, 0, 1, 1, 1, 0], [0, 1, 0, 1, 1, 0, 0, 0], [0, 1, 2, 0, 0, 1, 0, 0], [1, 0, 1, 0, 1, 0, 0, 1]]
    assert (idf["win"], idf["call"], idf["free"]) == (1.916, 1.511, 1.223)
    assert message3 == {"call": 0.465, "free": 0.753, "prize": 0.465}
    assert f["order"] == (True, ["is real", "not scam", "real not"], ["is scam", "not real", "scam not"])
    assert f["rows"] == (5572, 403, 5169, 653) and f["split"] == (4135, 522, 1034, 131)
    assert f["length"] == {"ham": 53.0, "spam": 148.0}
    assert f["tokens"][:4] == ["winner", "as", "valued", "network"] and f["tokens"][10:13] == ["receivea", "900", "prize"]
    assert len(f["tokens"]) == 25
    assert f["matrix"] == ((4135, 7680), 54735, 31756800, 0.17, 14.3)
    assert f["top"] == {"you": 1723, "to": 1650, "the": 1029, "and": 773, "in": 665, "is": 651, "me": 607, "it": 575}
    assert f["once"] == 4253
    assert f["tail"] == {"once": 4253, "twice": 1163, "3 to 5": 1011, "6 to 20": 815, "over 20": 438}
    assert f["tail_tokens"] == 68.5
    assert f["pieces_of_txt"] == [" t", "tx", "xt", "t ", " tx", "txt", "xt ", " txt", "txt ", " txt "]
    assert f["coded_example"] == "Wait  &lt;#&gt;  min.."
    assert f["share"].loc["call"].tolist() == [42.9, 3.7] and f["share"].loc["free"].tolist() == [22.4, 1.1]
    assert f["share"].loc["txt"].tolist() == [18.6, 0.3] and f["share"].loc["claim"].tolist() == [13.2, 0.0]
    assert f["share"].loc["you"].tolist() == [33.7, 28.8] and f["share"].loc["to"].tolist() == [62.6, 25.5]
    assert f["share"].loc["my"].tolist() == [1.9, 12.5] and f["share"].loc["ok"].tolist() == [0.8, 5.6]
    assert f["stems"] == {"calls": "call", "calling": "call", "called": "call", "winning": "win", "wins": "win",
                          "winner": "winner", "won": "won", "prizes": "prize", "freely": "freeli",
                          "university": "univers", "universe": "univers"}
    assert f["trim"] == {"every word": (7680, 0.955), "without the stop list": (7414, 0.965),
                         "in at least two messages": (3322, 0.961), "stemmed": (6513, 0.952)}
    assert f["stop_list"] == 318 and f["ngrams"] == {1: 7680, 2: 42642, 3: 87043}
    assert f["idf"] == {"you": (1218, 2.22), "call": (358, 3.44), "free": (158, 4.26), "claim": (69, 5.08),
                        "prize": (57, 5.27), "lunch": (29, 5.93)}
    assert f["unseen"] == (7.7, 50.6) and f["always_ham"] == 0.874
    cv = {name: (s["precision"], s["recall"], s["average_precision"], s["real_flagged"], s["spam_missed"])
          for name, s in f["cv"].items()}
    assert cv == {"naive Bayes on counts": (0.969, 0.902, 0.955, 15, 51),
                  "logistic on tf-idf, C = 1": (0.992, 0.738, 0.966, 3, 137),
                  "logistic on tf-idf, C = 10": (0.98, 0.862, 0.973, 9, 72),
                  "logistic on character pieces": (0.996, 0.895, 0.985, 2, 55)}
    assert f["pieces"] == 69650 and f["leak"] == (0.9696, 0.9732)
    assert f["spam_words"] == ["txt", "text", "reply", "call", "uk", "chat", "stop", "www"]
    assert f["ham_words"] == ["my", "me", "gt", "can", "lt", "that"] and f["coded"] == (179, 0)
    assert f["threshold"] == 0.37
    assert (f["cv_strict"]["precision"], f["cv_strict"]["recall"], f["cv_strict"]["real_flagged"]) == (0.994, 0.921, 3)
    assert (f["test_half"]["precision"], f["test_half"]["recall"], f["test_half"]["average_precision"]) == (0.992, 0.908, 0.991)
    assert (f["test_strict"]["precision"], f["test_strict"]["recall"]) == (0.976, 0.931)
    assert f["test_matrix"] == [[900, 3], [9, 122]]
    assert f["missed"][0] == 9 and f["missed"][1].startswith("In The Simpsons Movie") and f["not_is_stop_word"]
    assert f["bank"] == (10003, 3080, 77, 2320, 0.9, 0.97, 0.796)
    assert f["weakest"] == {"virtual_card_not_working": 0.68, "fiat_currency_support": 0.75, "pending_transfer": 0.75}
    assert f["perfect"] == 9
    assert f["confused"] == [("balance_not_updated_after_bank_transfer", "transfer_not_received_by_recipient", 5),
                             ("verify_my_identity", "why_verify_identity", 5),
                             ("virtual_card_not_working", "get_disposable_virtual_card", 5)]
    card = f["search"]["my new card still has not arrived"]
    assert [(s, intent) for s, intent, _ in card] == [(0.73, "transfer_not_received_by_recipient"), (0.66, "card_arrival"),
                                                      (0.62, "transfer_not_received_by_recipient")]
    assert [intent for _, intent, _ in f["search"]["how do I change my pin"]] == ["change_pin"] * 3
    assert f["lsa"] == {100: 0.814, 300: 0.871}
    # Word vectors come from a randomized SVD, so the checks on them allow for small differences between machines.
    assert f["vector_words"] == 1210
    near = f["neighbors"]
    assert "rejected" in near["declined"] and "lost" in near["stolen"] and "atm" in near["cash"] and "cash" in near["atm"]
    assert {"charged", "charge"} <= set(near["fee"]) and {"locked", "blocked"} <= set(near["pin"])
    assert 0.83 <= f["averaged"] <= 0.85
    by_vectors = f["dense_search"]
    assert [intent for _, intent, _ in by_vectors["my new card still has not arrived"]] == ["card_arrival"] * 3
    assert by_vectors["my new card still has not arrived"][0][2] == "Why has my new card still not come?"
    assert [intent for _, intent, _ in by_vectors["the cash machine swallowed my card"]] == ["card_swallowed"] * 3
    assert by_vectors["the cash machine swallowed my card"][0][2] == "The ATM machine ate my card."
    assert f["sparse_machine"] == (0.61, "How do I get a new card as your machine swallowed mine!")
    few = f["few"]
    assert few[2][1] > few[2][0] + 0.015 and few[2][2] >= 9          # with 2 labels per intent the dense vectors lead
    assert few[10][0] > few[10][1] + 0.015 and few[10][2] <= 1       # with 10 the sparse weights lead
    assert (few[2][0], few[5][0], few[10][0]) == (0.413, 0.595, 0.706)
    print("\nEvery number above matches the book.")


if __name__ == "__main__":
    main()
