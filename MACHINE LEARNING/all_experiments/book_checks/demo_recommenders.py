"""Recommender systems: the worked numbers of Chapter 24.

An online gift shop sold about 4,600 different products to about 5,900 customers in two years. Which
ten products should it show each customer next? The script builds a customer-product matrix from
Lab 4's sales, chooses the settings of five recommenders on one window of time, tests them once on the
next window, and then looks at what none of them can do on its own: serve a customer or a product the
shop has never seen.

Run from the course folder:      python all_experiments/book_checks/demo_recommenders.py
It reads all_datasets/unsupervised/online_retail_ii/ and takes about half a minute.
"""
import math
from pathlib import Path

import numpy as np
import pandas as pd
from scipy import sparse
from sklearn.decomposition import TruncatedSVD
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.preprocessing import normalize

DATA = Path(__file__).resolve().parents[2] / "all_datasets"
CHECK_BOOK_NUMBERS = True
FOUND = {}          # every value the asserts below check
TOP = 10            # every recommender fills ten places
VALID_CUT, TEST_CUT = pd.Timestamp("2011-06-01"), pd.Timestamp("2011-09-01")
NEIGHBOURS = (10, 20, 50, 100, 200, 400)          # the settings tried on the validation window
FACTORS = (10, 20, 50, 100, 200, 300)
pd.set_option("display.width", 160)

TINY = pd.DataFrame([[1, 1, 0, 0, 1], [1, 1, 0, 0, 0], [0, 1, 1, 1, 0], [0, 0, 1, 1, 1], [1, 0, 0, 0, 0]],
                    index=["Ann", "Ben", "Cara", "Dev", "Eve"],
                    columns=["teapot", "mug", "candle", "lantern", "card"])


# ---------------------------------------------------------------- the five recommenders
def best_sellers(bought, history):
    """Everyone gets the same ranking: by how many customers bought each product."""
    buyers = np.asarray(bought.sum(axis=0)).ravel()
    return np.tile(buyers, (history.shape[0], 1))


def product_similarity(bought):
    """Cosine similarity of every pair of product columns."""
    columns = normalize(bought.T.tocsr())          # each product's buyers, scaled to length 1
    similar = (columns @ columns.T).toarray()      # shared buyers / sqrt(buyers of one x buyers of other)
    np.fill_diagonal(similar, 0)                   # a product does not recommend itself
    return similar


def item_based(history, similar):
    """A product's score: its total similarity to everything the customer bought."""
    return np.asarray(history @ similar)


def user_based(bought, rows, neighbours):
    """A product's score: how many of the customer's closest customers bought it, weighted by closeness."""
    people = normalize(bought)                                 # each customer's row scaled to length 1
    close = (people[rows] @ people.T).toarray()                # cosine similarity to every customer
    close[np.arange(len(rows)), rows] = 0                      # a customer is not their own neighbour
    nearest = np.sort(close, axis=1)[:, [-neighbours]]
    close[close < nearest] = 0                                 # keep only the closest customers
    return np.asarray((bought.T @ close.T).T)


def factorization(bought, history, factors):
    """A product's score: the customer's tastes times the product's tastes, from a truncated SVD."""
    svd = TruncatedSVD(n_components=factors, random_state=0).fit(bought)
    tastes = svd.transform(history)                # customers x factors
    return tastes @ svd.components_                # (customers x factors) times (factors x products)


def word_similarity(descriptions):
    """Cosine similarity of product descriptions, each read as the set of words in it."""
    words = normalize(CountVectorizer(binary=True).fit_transform(descriptions))
    similar = (words @ words.T).toarray()
    np.fill_diagonal(similar, 0)
    return similar


# ---------------------------------------------------------------- data and the test
def read_sales():
    """Lab 4's sales, minus the lines that are not goods, and one description for each product."""
    lines = pd.read_csv(DATA / "unsupervised/online_retail_ii/online_retail_ii.zip",
                        dtype={"Invoice": str, "StockCode": str}, parse_dates=["InvoiceDate"])
    sales = lines.dropna(subset=["Customer ID"])
    real_sale = ~sales["Invoice"].str.startswith("C") & (sales["Quantity"] > 0) & (sales["Price"] > 0)
    sales = sales[real_sale].drop_duplicates()
    goods = sales["StockCode"].str.match(r"\d{5}")         # postage, carriage, discounts: other codes
    other = sales.loc[~goods, "StockCode"].value_counts()
    print(f"sales lines {len(sales):,}, of which {int(other.sum()):,} are not goods,"
          f" under {len(other)} codes:", other.index.tolist())
    sales = sales[goods].assign(customer=sales["Customer ID"].astype(int))
    names = sales.groupby("StockCode")["Description"].agg(lambda d: d.value_counts().index[0])
    print(f"customers {sales['customer'].nunique():,}, products {sales['StockCode'].nunique():,},"
          f" orders {sales['Invoice'].nunique():,}, {sales['InvoiceDate'].min():%Y-%m-%d}"
          f" to {sales['InvoiceDate'].max():%Y-%m-%d}")
    FOUND["sales"] = (len(sales) + int(other.sum()), int(other.sum()), len(other),
                      sales["customer"].nunique(), sales["StockCode"].nunique(),
                      sales["Invoice"].nunique())
    return sales, names


def purchase_matrix(sales, cut):
    """One row per customer and one column per product: 1 if the customer bought it before the cut."""
    before = sales[sales["InvoiceDate"] < cut]
    customers = np.sort(before["customer"].unique())
    products = np.sort(before["StockCode"].unique())
    pairs = before[["customer", "StockCode"]].drop_duplicates()
    rows = np.searchsorted(customers, pairs["customer"])
    cols = np.searchsorted(products, pairs["StockCode"])
    bought = sparse.csr_matrix((np.ones(len(pairs)), (rows, cols)), shape=(len(customers), len(products)))
    return bought, customers, products


def order_counts(sales, cut, customers, products):
    """The same matrix holding how many orders included the product, instead of a 1."""
    orders = sales[sales["InvoiceDate"] < cut].groupby(["customer", "StockCode"])["Invoice"].nunique()
    rows = np.searchsorted(customers, orders.index.get_level_values(0))
    cols = np.searchsorted(products, orders.index.get_level_values(1))
    return sparse.csr_matrix((orders.to_numpy(float), (rows, cols)), shape=(len(customers), len(products)))


def first_purchases(sales, start, end, bought, customers, products):
    """The answers: what each known customer bought for the first time between start and end."""
    window = sales[(sales["InvoiceDate"] >= start) & (sales["InvoiceDate"] < end)]
    pairs = window[["customer", "StockCode"]].drop_duplicates()
    pairs = pairs[pairs["customer"].isin(customers) & pairs["StockCode"].isin(products)]
    rows = np.searchsorted(customers, pairs["customer"])
    cols = np.searchsorted(products, pairs["StockCode"])
    again = np.asarray(bought[rows, cols]).ravel() > 0         # bought before the cut as well
    answers = pd.Series(cols[~again]).groupby(rows[~again]).apply(set)
    return answers.index.to_numpy(), list(answers), round(float(again.mean()), 3)


def top_ten(scores, history):
    """The ten best-scored products for each customer, leaving out what they bought already."""
    scores = np.array(scores, dtype=float)
    scores[history.nonzero()] = -np.inf
    return np.argsort(-scores, axis=1, kind="stable")[:, :TOP]


def measure(top, answers):
    """Hit rate, precision and recall at ten, and how many different products were shown at all."""
    hits = np.array([len(set(ten) & answer) for ten, answer in zip(top, answers)])
    sizes = np.array([len(answer) for answer in answers])
    return {"hit rate": round(float((hits > 0).mean()), 3),
            "precision": round(float(hits.mean() / TOP), 3),
            "recall": round(float((hits / sizes).mean()), 3),
            "products shown": len(np.unique(top))}


# ---------------------------------------------------------------- the worked numbers
def tiny():
    """Five customers and five products, small enough to recommend by hand."""
    bought = sparse.csr_matrix(TINY.to_numpy(float))
    print("who bought what\n" + TINY.to_string())
    shared = (bought.T @ bought).toarray()                     # customers who bought both of a pair
    similar = pd.DataFrame(product_similarity(bought), index=TINY.columns, columns=TINY.columns)
    print("\nshared buyers\n" + pd.DataFrame(shared, index=TINY.columns, columns=TINY.columns).to_string())
    print("\nproduct similarity\n" + similar.round(3).to_string())
    eve = bought[[4]]
    by_item = pd.Series(item_based(eve, similar.to_numpy())[0], index=TINY.columns).round(3)
    people = normalize(bought)
    close = pd.Series((people[4] @ people.T).toarray()[0], index=TINY.index).round(3)
    by_user = pd.Series(user_based(bought, np.array([4]), 2)[0], index=TINY.columns).round(3)
    print("\nEve, item-based scores:", by_item.to_dict())
    print("Eve's similarity to each customer:", close.to_dict())
    print("Eve, user-based scores with two neighbours:", by_user.to_dict())
    svd = TruncatedSVD(n_components=2, random_state=0).fit(bought)
    tastes = pd.DataFrame(svd.transform(bought), index=TINY.index, columns=["taste 1", "taste 2"])
    kinds = pd.DataFrame(svd.components_, index=["taste 1", "taste 2"], columns=TINY.columns)
    rebuilt = tastes.to_numpy() @ kinds.to_numpy()
    print("\ncustomers' tastes\n" + tastes.round(2).to_string())
    print("products' tastes\n" + kinds.round(2).to_string())
    print("rebuilt\n" + pd.DataFrame(rebuilt, index=TINY.index, columns=TINY.columns).round(2).to_string())
    FOUND["tiny"] = (shared.astype(int).tolist(), similar.round(3).to_numpy().tolist(), by_item.to_dict(),
                     close.to_dict(), by_user.to_dict(), tastes.abs().round(2).to_numpy().tolist(),
                     kinds.abs().round(2).to_numpy().tolist(), rebuilt.round(2).tolist())


def choose_settings(sales, names):
    """Choose the neighbours and the factors on a window that the test never sees."""
    bought, customers, products = purchase_matrix(sales, VALID_CUT)
    rows, answers, again = first_purchases(sales, VALID_CUT, TEST_CUT, bought, customers, products)
    history = bought[rows]
    print(f"\nvalidation: matrix {bought.shape}, {len(rows):,} customers, {sum(map(len, answers)):,}"
          f" first purchases; {again:.1%} of their buying in the window repeated an earlier purchase")

    def hit_rate(scores):
        return measure(top_ten(scores, history), answers)["hit rate"]

    def hit_and_shown(scores):
        found = measure(top_ten(scores, history), answers)
        return found["hit rate"], found["products shown"]

    words = word_similarity(names.reindex(products))
    found = {"best sellers": hit_rate(best_sellers(bought, history)),
             "item-based": hit_rate(item_based(history, product_similarity(bought))),
             "product descriptions": hit_rate(item_based(history, words))}
    by_neighbours = {k: hit_and_shown(user_based(bought, rows, k)) for k in NEIGHBOURS}
    by_factors = {d: hit_and_shown(factorization(bought, history, d)) for d in FACTORS}
    print("validation hit rate at ten:", found)
    print("  user-based, (hit rate, products shown) by number of neighbours:", by_neighbours)
    print("  factorization, (hit rate, products shown) by number of factors:", by_factors)

    counts = order_counts(sales, VALID_CUT, customers, products)
    cells = {"1 if bought": bought, "number of orders": counts, "log(1 + orders)": counts.log1p()}
    weights = {name: (hit_rate(item_based(m[rows], product_similarity(m))),
                      hit_rate(factorization(m, m[rows], 100))) for name, m in cells.items()}
    print("  item-based and factorization hit rate, by what a cell holds:", weights)
    neighbours = max(NEIGHBOURS, key=lambda k: by_neighbours[k][0])
    factors = max(FACTORS, key=lambda d: by_factors[d][0])
    FOUND["valid"] = (bought.shape, len(rows), sum(map(len, answers)), again, found, by_neighbours,
                      by_factors, weights)
    return neighbours, factors


def compare(sales, names, neighbours, factors):
    """Fit everything on the sales before September 2011 and test once on September to December."""
    bought, customers, products = purchase_matrix(sales, TEST_CUT)
    end = sales["InvoiceDate"].max() + pd.Timedelta(days=1)
    rows, answers, again = first_purchases(sales, TEST_CUT, end, bought, customers, products)
    history = bought[rows]
    sizes = np.asarray(bought.sum(axis=1)).ravel()           # products each customer bought before
    print(f"\ntest: matrix {bought.shape} with {bought.nnz:,} ones"
          f" ({bought.nnz / np.prod(bought.shape):.2%} filled); median customer bought"
          f" {np.median(sizes):.0f} products")
    stored = bought.data.nbytes + bought.indices.nbytes + bought.indptr.nbytes
    full = np.prod(bought.shape) * bought.dtype.itemsize
    print(f"  kept sparse it takes {stored / 1e6:.1f} MB; written out in full, {full / 1e6:.0f} MB")
    FOUND["memory"] = (round(stored / 1e6, 1), round(full / 1e6))
    print(f"  {len(rows):,} customers bought {sum(map(len, answers)):,} products for the first time"
          f" (median {np.median([len(a) for a in answers]):.0f} each);"
          f" {again:.1%} of their buying repeated")
    similar = product_similarity(bought)
    scores = {"best sellers": best_sellers(bought, history),
              "item-based": item_based(history, similar),
              "user-based": user_based(bought, rows, neighbours),
              "factorization": factorization(bought, history, factors),
              "product descriptions": item_based(history, word_similarity(names.reindex(products)))}
    tops = {name: top_ten(s, history) for name, s in scores.items()}
    table = pd.DataFrame({name: measure(top, answers) for name, top in tops.items()}).T
    best = np.argsort(-np.asarray(bought.sum(axis=0)).ravel(), kind="stable")[:100]
    table["from top 100"] = [round(float(np.isin(top, best).mean()), 3) for top in tops.values()]
    print(table.to_string())
    left = bought.shape[1] - sizes[rows]                     # products each customer could still be shown
    chance = np.mean([1 - math.comb(int(n) - len(a), TOP) / math.comb(int(n), TOP)
                      for n, a in zip(left, answers)])
    print(f"  ten products drawn at random would give a hit rate of {chance:.3f}")
    FOUND["test"] = (bought.shape, bought.nnz, float(np.median(sizes)), len(rows), sum(map(len, answers)),
                     float(np.median([len(a) for a in answers])), again, table.to_dict("index"),
                     round(float(chance), 3))

    # One customer's three lists, side by side.
    one = int(np.flatnonzero(customers[rows] == 12680)[0])
    lists = {name: [(names[products[j]].strip(), j in answers[one]) for j in tops[name][one]]
             for name in ("best sellers", "item-based", "factorization")}
    had = sorted(names[products[j]].strip() for j in history[one].indices)
    print(f"  customer 12680 bought {len(had)} products before the cut and {len(answers[one])} new ones"
          " after it. Before:", "; ".join(had))
    for name, ten in lists.items():
        print(f"    {name}: " + "; ".join(p + (" (bought)" if hit else "") for p, hit in ten))
    FOUND["one"] = (had, len(answers[one]), lists)

    # Who gains: customers with a short history against customers with a long one.
    groups = np.asarray(pd.qcut(sizes[rows], 3, labels=["short", "middle", "long"]))
    edges = [int(sizes[rows][groups == g].max()) for g in ("short", "middle")]
    by_group = {}
    for g in ("short", "middle", "long"):
        inside = groups == g
        group_answers = [a for a, keep in zip(answers, inside) if keep]
        by_group[g] = {name: measure(top[inside], group_answers)["hit rate"] for name, top in tops.items()}
    print("  hit rate by length of history, thirds ending at", edges, "products:", by_group)
    FOUND["groups"] = (edges, by_group)
    return bought, customers, products, similar


def one_pair(bought, products, names, similar):
    """The similarity worked out on one real pair, and the nearest products by buyers and by words."""
    a, b = np.searchsorted(products, ["85123A", "21733"])
    col = bought.tocsc()
    n_a, n_b = int(col[:, a].sum()), int(col[:, b].sum())
    both = int(col[:, a].multiply(col[:, b]).sum())
    print(f"\n{names['85123A']}: {n_a} buyers; {names['21733']}: {n_b}; both: {both};"
          f" cosine {both / math.sqrt(n_a * n_b):.3f}")
    words = word_similarity(names.reindex(products))
    near = [(names[products[j]].strip(), round(float(similar[a, j]), 3))
            for j in np.argsort(-similar[a], kind="stable")[:5]]
    alike = [(names[products[j]].strip(), round(float(words[a, j]), 3))
             for j in np.argsort(-words[a], kind="stable")[:5]]
    print("  most similar by buyers:", near)
    print("  most similar by description:", alike)
    FOUND["pair"] = (n_a, n_b, both, round(both / math.sqrt(n_a * n_b), 3), near, alike)


def taste_ends(bought, products, names, factors):
    """What the tastes mean: the products at the two ends of a few of them."""
    svd = TruncatedSVD(n_components=factors, random_state=0).fit(bought)
    size = bought.multiply(bought).sum()                     # the sum of squares of the whole matrix
    kept, first = (svd.singular_values_ ** 2).sum() / size, svd.singular_values_[0] ** 2 / size
    print(f"\n{factors} tastes rebuild {kept:.1%} of the matrix (sum of squares);"
          f" the first alone {first:.1%}")
    ends = {}
    for f in (1, 2, 3, 4, 7):
        order = np.argsort(svd.components_[f - 1], kind="stable")
        ends[f] = ([names[p].strip() for p in products[order[-3:][::-1]]],
                   [names[p].strip() for p in products[order[:3]]])
        print(f"  taste {f}: {ends[f][0]}  against  {ends[f][1]}")
    FOUND["tastes"] = (round(float(kept), 3), round(float(first), 3), ends)


def newcomers(sales, bought, customers, products, similar, factors):
    """Customers with no history: their first order is all there is; what they buy later is the test."""
    window = sales[sales["InvoiceDate"] >= TEST_CUT]
    new = window[~window["customer"].isin(customers)]
    first = new.sort_values(["InvoiceDate", "Invoice"]).groupby("customer")["Invoice"].first()
    in_first = new["Invoice"].isin(first)
    baskets = new[in_first & new["StockCode"].isin(products)]
    later = new[~in_first & new["StockCode"].isin(products)]
    people = np.intersect1d(baskets["customer"].unique(), later["customer"].unique())
    baskets = baskets[baskets["customer"].isin(people)].drop_duplicates(["customer", "StockCode"])
    history = sparse.csr_matrix((np.ones(len(baskets)), (np.searchsorted(people, baskets["customer"]),
                                                         np.searchsorted(products, baskets["StockCode"]))),
                                shape=(len(people), len(products)))
    later = later[later["customer"].isin(people)]
    answers = [set(np.searchsorted(products, g["StockCode"])) - set(history[i].indices)
               for i, (_, g) in enumerate(later.groupby("customer"))]
    keep = np.flatnonzero([len(a) > 0 for a in answers])     # bought something beyond the first order
    history, answers = history[keep], [answers[i] for i in keep]
    found = {"best sellers": measure(top_ten(best_sellers(bought, history), history), answers),
             "item-based": measure(top_ten(item_based(history, similar), history), answers),
             "factorization": measure(top_ten(factorization(bought, history, factors), history), answers)}
    median_first = float(np.median(np.diff(history.indptr)))
    print(f"\n{new['customer'].nunique():,} customers bought for the first time after the cut;"
          f" {history.shape[0]} of them came back after a first order of {median_first:.0f} products"
          " (median)")
    for name, result in found.items():
        print(f"    {name:14s} {result}")
    FOUND["newcomers"] = (new["customer"].nunique(), history.shape[0], median_first, found)


def new_products(sales, names, bought, customers, products):
    """Products with no buyers yet: only their descriptions can place them."""
    window = sales[sales["InvoiceDate"] >= TEST_CUT]
    fresh = np.sort(np.setdiff1d(window["StockCode"].unique(), products))
    known = window[window["customer"].isin(customers) & window["StockCode"].isin(fresh)]
    pairs = known[["customer", "StockCode"]].drop_duplicates()
    answers = pd.Series(np.searchsorted(fresh, pairs["StockCode"])).groupby(
        np.searchsorted(customers, pairs["customer"])).apply(set)
    vectorizer = CountVectorizer(binary=True).fit(names.reindex(np.concatenate([products, fresh])))
    old = normalize(vectorizer.transform(names.reindex(products)))
    new = normalize(vectorizer.transform(names.reindex(fresh)))
    scores = np.asarray(bought[answers.index.to_numpy()] @ (old @ new.T).toarray())
    result = measure(np.argsort(-scores, axis=1, kind="stable")[:, :TOP], list(answers))
    chance = np.mean([1 - math.comb(len(fresh) - len(a), TOP) / math.comb(len(fresh), TOP)
                      for a in answers])
    print(f"\n{len(fresh)} products were sold for the first time after the cut; {len(answers):,} known"
          f" customers bought {len(pairs):,} of them (customer and product pairs)")
    print(f"  ranked by description: {result}; ten at random: hit rate {chance:.3f}")
    FOUND["fresh"] = (len(fresh), len(answers), len(pairs), result, round(float(chance), 3))


def main():
    tiny()
    sales, names = read_sales()
    neighbours, factors = choose_settings(sales, names)
    print(f"chosen on validation: {neighbours} neighbours, {factors} factors")
    bought, customers, products, similar = compare(sales, names, neighbours, factors)
    one_pair(bought, products, names, similar)
    taste_ends(bought, products, names, factors)
    newcomers(sales, bought, customers, products, similar, factors)
    new_products(sales, names, bought, customers, products)
    if not CHECK_BOOK_NUMBERS:
        return
    f = FOUND
    shared, similar, by_item, close, by_user, tastes, kinds, rebuilt = f["tiny"]
    assert shared == [[3, 2, 0, 0, 1], [2, 3, 1, 1, 1], [0, 1, 2, 2, 1], [0, 1, 2, 2, 1], [1, 1, 1, 1, 2]]
    assert similar[0] == [0, 0.667, 0, 0, 0.408] and similar[1][2:] == [0.408, 0.408, 0.408]
    assert similar[2][3:] == [1.0, 0.5] and similar[4] == [0.408, 0.408, 0.5, 0.5, 0]
    assert by_item == {"teapot": 0, "mug": 0.667, "candle": 0, "lantern": 0, "card": 0.408}
    assert close == {"Ann": 0.577, "Ben": 0.707, "Cara": 0, "Dev": 0, "Eve": 1.0}
    assert by_user == {"teapot": 1.284, "mug": 1.284, "candle": 0, "lantern": 0, "card": 0.577}
    assert tastes == [[1.43, 0.81], [1.03, 0.89], [1.36, 0.77], [1.18, 1.11], [0.44, 0.64]]
    assert kinds == [[0.44, 0.58, 0.39, 0.39, 0.40], [0.64, 0.25, 0.51, 0.51, 0.08]]
    assert rebuilt[4] == [0.60, 0.42, -0.15, -0.15, 0.13] and rebuilt[0][:2] == [1.15, 1.04]

    assert f["sales"] == (779425, 2848, 12, 5852, 4619, 36594)
    shape, n_rows, n_answers, again, found, by_neighbours, by_factors, weights = f["valid"]
    assert (shape, n_rows, n_answers, again) == ((4908, 4224), 1503, 26535, 0.486)
    assert found == {"best sellers": 0.300, "item-based": 0.381, "product descriptions": 0.220}
    assert by_neighbours == {10: (0.368, 1344), 20: (0.395, 1009), 50: (0.409, 727), 100: (0.413, 582),
                             200: (0.409, 451), 400: (0.401, 348)}
    assert by_factors == {10: (0.358, 389), 20: (0.379, 536), 50: (0.412, 757), 100: (0.428, 957),
                          200: (0.395, 1229), 300: (0.387, 1436)}
    assert weights == {"1 if bought": (0.381, 0.428), "number of orders": (0.340, 0.370),
                       "log(1 + orders)": (0.383, 0.418)}

    shape, ones, median_size, n_rows, n_answers, median_answers, again, table, chance = f["test"]
    assert (shape, ones, median_size, n_rows, n_answers) == ((5224, 4403), 387122, 41, 2238, 58644)
    assert (median_answers, again, chance) == (17, 0.391, 0.058)
    columns = ("hit rate", "precision", "recall", "products shown", "from top 100")
    assert {name: tuple(row[c] for c in columns) for name, row in table.items()} == {
        "best sellers": (0.300, 0.042, 0.020, 77, 0.999),
        "item-based": (0.366, 0.062, 0.036, 801, 0.811),
        "user-based": (0.400, 0.070, 0.038, 683, 0.720),
        "factorization": (0.448, 0.074, 0.043, 1062, 0.348),
        "product descriptions": (0.294, 0.045, 0.028, 1934, 0.103)}
    edges, by_group = f["groups"]
    order = ("best sellers", "item-based", "user-based", "factorization", "product descriptions")
    assert edges == [46, 116] and {g: tuple(by_group[g][n] for n in order) for g in by_group} == {
        "short": (0.291, 0.368, 0.393, 0.399, 0.252), "middle": (0.285, 0.358, 0.396, 0.447, 0.318),
        "long": (0.323, 0.372, 0.413, 0.500, 0.315)}

    assert f["memory"] == (4.7, 184)
    had, n_new, lists = f["one"]
    assert (len(had), n_new) == (19, 13)
    assert had == ["ALARM CLOCK BAKELIKE PINK", "ALARM CLOCK BAKELIKE RED", "BUNDLE OF 3 SCHOOL EXERCISE BOOKS",
                   "CARAVAN SQUARE TISSUE BOX", "CARD DOLLY GIRL", "CHILDREN'S APRON DOLLY GIRL",
                   "CHILDRENS APRON SPACEBOY DESIGN", "CHILDRENS CUTLERY DOLLY GIRL", "CHILDRENS CUTLERY SPACEBOY",
                   "DOLLY GIRL LUNCH BOX", "PACK OF 12 PINK POLKADOT TISSUES", "PACK OF 12 WOODLAND TISSUES",
                   "PANTRY SCRUBBING BRUSH", "PANTRY WASHING UP BRUSH", "PLASTERS IN TIN STRONGMAN",
                   "ROBOT BIRTHDAY CARD", "ROUND SNACK BOXES SET OF4 WOODLAND", "SPACEBOY BIRTHDAY CARD",
                   "SPACEBOY LUNCH BOX"]
    assert lists == {
        "best sellers": [(p, p == "BAKING SET 9 PIECE RETROSPOT") for p in (
            "WHITE HANGING HEART T-LIGHT HOLDER", "REGENCY CAKESTAND 3 TIER", "PACK OF 72 RETROSPOT CAKE CASES",
            "BAKING SET 9 PIECE RETROSPOT", "ASSORTED COLOUR BIRD ORNAMENT", "JUMBO BAG RED RETROSPOT",
            "PARTY BUNTING", "RETROSPOT TEA SET CERAMIC 11 PC", "LUNCH BAG RED RETROSPOT",
            "NATURAL SLATE HEART CHALKBOARD")],
        "item-based": [(p, p in ("CIRCUS PARADE LUNCH BOX", "PLASTERS IN TIN CIRCUS PARADE")) for p in (
            "PLASTERS IN TIN SPACEBOY", "CIRCUS PARADE LUNCH BOX", "LUNCH BAG SPACEBOY DESIGN",
            "PLASTERS IN TIN WOODLAND ANIMALS", "ROUND SNACK BOXES SET OF 4 FRUITS",
            "PLASTERS IN TIN CIRCUS PARADE", "LUNCH BAG DOLLY GIRL DESIGN", "LUNCH BAG WOODLAND",
            "PACK OF 60 SPACEBOY CAKE CASES", "LUNCH BAG RED RETROSPOT")],
        "factorization": [(p, p in ("ALARM CLOCK BAKELIKE GREEN", "CIRCUS PARADE LUNCH BOX",
                                    "ALARM CLOCK BAKELIKE IVORY", "PLASTERS IN TIN CIRCUS PARADE")) for p in (
            "PLASTERS IN TIN SPACEBOY", "ALARM CLOCK BAKELIKE GREEN", "CIRCUS PARADE LUNCH BOX",
            "ALARM CLOCK BAKELIKE ORANGE", "PLASTERS IN TIN WOODLAND ANIMALS", "PINK FAIRY CAKE CHILDRENS APRON",
            "PACK OF 12 SPACEBOY TISSUES", "ALARM CLOCK BAKELIKE IVORY", "ROUND SNACK BOXES SET OF 4 FRUITS",
            "PLASTERS IN TIN CIRCUS PARADE")]}

    n_a, n_b, both, cosine, near, alike = f["pair"]
    assert (n_a, n_b, both, cosine) == (1383, 675, 571, 0.591)
    assert near == [("RED HANGING HEART T-LIGHT HOLDER", 0.591), ("HEART OF WICKER LARGE", 0.453),
                    ("HEART OF WICKER SMALL", 0.444), ("CANDLEHOLDER PINK HANGING HEART", 0.436),
                    ("CREAM HEART CARD HOLDER", 0.412)]
    assert alike == [("RED HANGING HEART T-LIGHT HOLDER", 0.8), ("HANGING HEART ZINC T-LIGHT HOLDER", 0.8),
                     ("HANGING HEART JAR T-LIGHT HOLDER", 0.8), ("HEART T-LIGHT HOLDER", 0.775),
                     ("HEART T-LIGHT HOLDER", 0.775)]
    kept, first, ends = f["tastes"]
    assert (kept, first) == (0.390, 0.116)
    assert ends[1][0] == ["WHITE HANGING HEART T-LIGHT HOLDER", "PACK OF 72 RETROSPOT CAKE CASES",
                          "REGENCY CAKESTAND 3 TIER"]
    expected = {
        2: (["WHITE HANGING HEART T-LIGHT HOLDER", "HEART OF WICKER SMALL", "HEART OF WICKER LARGE"],
            ["LUNCH BAG SPACEBOY DESIGN", "PLASTERS IN TIN SPACEBOY", "ROUND SNACK BOXES SET OF4 WOODLAND"]),
        3: (["JUMBO BAG RED RETROSPOT", "LUNCH BAG RED RETROSPOT", "JUMBO BAG PINK POLKADOT"],
            ["VINTAGE SNAP CARDS", "VINTAGE HEADS AND TAILS CARD GAME", "WOODEN SCHOOL COLOURING SET"]),
        4: (["REGENCY CAKESTAND 3 TIER", "RED RETROSPOT CAKE STAND", "ROSES REGENCY TEACUP AND SAUCER"],
            ["REX CASH+CARRY JUMBO SHOPPER", "12 PENCILS SMALL TUBE SKULL", "FELTCRAFT BUTTERFLY HEARTS"]),
        7: (["PLEASE ONE PERSON METAL SIGN", "HAND OVER THE CHOCOLATE   SIGN", "GIN + TONIC DIET METAL SIGN"],
            ["RED SPOTTY CUP", "BLUE  SPOTTY CUP", "PINK  SPOTTY CUP"])}
    for taste, pair in expected.items():                   # an SVD may flip the sign of a whole taste
        assert {tuple(end) for end in ends[taste]} == {tuple(end) for end in pair}

    n_newcomers, n_back, median_first, found = f["newcomers"]
    assert (n_newcomers, n_back, median_first) == (628, 232, 23)
    assert {name: tuple(r.values()) for name, r in found.items()} == {
        "best sellers": (0.371, 0.065, 0.022, 16), "item-based": (0.513, 0.107, 0.067, 397),
        "factorization": (0.534, 0.114, 0.074, 581)}
    n_fresh, n_people, n_pairs, result, chance = f["fresh"]
    assert (n_fresh, n_people, n_pairs, chance) == (216, 1638, 10580, 0.235)
    assert tuple(result.values()) == (0.385, 0.070, 0.129, 186)
    print("\nEvery number above matches the book.")


if __name__ == "__main__":
    main()
