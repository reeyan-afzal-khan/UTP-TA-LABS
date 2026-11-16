#import "/.shared/typst/utp.typ": *
#import "/MACHINE LEARNING/course-tools.typ": *
#unit("labs", "04-clustering-pca")

#labsection(4, label: <sec:lab04-clustering-pca>)[Unsupervised learning I: clustering and PCA]

#labproject[Customer segments from two years of invoices, and a compressed view of 15,701 wood-defect images][
  #strong[Read first.] Chapters~#ref(<ch:unsupervised>)--#ref(<ch:dimred>). \

  #strong[Goal.] Turn raw invoice lines into one row per customer, find segments with K-means and DBSCAN and judge them by evidence and usefulness, then compress images with PCA and choose how much to keep by validation, testing once. \

  #strong[Scenario.] An online gift shop hands you two years of invoices and asks who its customers are, with no labels to learn from. A sawmill’s inspection camera photographs every defect on its boards and asks how much of each photo it really needs to keep. Neither question has an answer key, so the evidence has to come from the data and from what the answer is for. \

  #strong[Data.] In `all_datasets/`: `unsupervised/online_retail_ii/online_retail_ii.zip`, every invoice line of a UK online shop from December 2009 to December 2011, from the UCI repository (Chen, 2012); and `unsupervised/wood_surface_defects/wood_defects.npz`, 15,701 photos of seven kinds of defect on sawn boards, cut from a public industrial dataset (Kodytek, Bodzas and Bilik, 2022). \

  #strong[Notebook.] `all_experiments/lab04_clustering_pca/lab04_clustering_pca_worked.ipynb`, with a README beside it. \

  #strong[Hand in.] The executed notebook, `results/lab04/`, the saved PCA model and a short conclusion, as listed in the checklist at the end of this sheet.
]

#labroadmap([Your map of this lab],
  [A],
  [Build customer rows, segment them with $K$-means, find outliers with DBSCAN],
  [2--6],
  [B],
  [Compress wood-defect images with PCA, choose the budget, test once and save],
  [7--11],
  [Finish],
  [Save the evidence; then cluster the defect images],
  [12--14],
  [After],
  [Exercises, answers, troubleshooting tips and the two checklists],
  [---],
)

#labsetup[
  + Activate your course environment and confirm the two data files are in `all_datasets/`. Keep the ZIP file as it is: pandas reads the CSV inside it directly.
  + From the course folder, start Jupyter, open the notebook, and choose #strong[Restart Kernel and Run All Cells]. It takes about two minutes; the pixel models of Questions~8 and~9 take most of it.
  + Part~A is clustering and Part~B is PCA. Neither has an answer key, so each question asks for the evidence a result needs.

  ```terminal
  jupyter lab
  ```

  Prefer a plain script? From the course folder, `python all_experiments/lab04_clustering_pca/lab04_clustering_pca_worked.py` runs the same code and writes the same evidence.
]

#labroutine

#exercises[
  #strong[Warm-up on paper.] Do these before opening the notebook; the code will check you.

  + A customer bought on 1 November 2011 and on 2 December 2011, in two orders worth £120 and £80. The data ends on 9 December 2011, and recency is counted from the day after. What are this customer’s recency, frequency and monetary value?
  + Spend runs from £3 to £580,987, with a median of £868. Why would K-means on the raw numbers spend most of its effort on a few customers, and what does taking logs change?
]

#labquestion(1)[Setup][
  Run this first, and keep this kernel for the later questions. Every lab starts the same way. `start_lab()`, from `all_experiments/course_setup.py`, finds the course folder and returns the three folders the lab uses: `DATA` to read from, `RESULTS` and `MODELS` to write to. The imports in between are grouped by what they are for.
]

#labanswer[
  #labcode("lab04_clustering_pca", 1)

  #readcode[
    - The setup has the same three steps. The new tools are `KMeans` and `DBSCAN`, which find groups, and `PCA`, which compresses many columns into a few.
    - `silhouette_score` and `adjusted_rand_score` score a clustering: the first without labels, the second against known ones.
    - `GroupShuffleSplit` splits rows so that all the rows of one group stay on the same side.
  ]

  #refoutput[
    ```terminal
    course folder: MACHINE LEARNING
    reads all_datasets/, writes results/lab04/ and models/
    ```
  ]
]

#labpartopen([Part A], [Clustering customers from their invoices], [Questions 2--6 • Data: Online Retail II invoices], [Turn a million invoice lines into one row per customer, then find segments with $K$-means and outliers with DBSCAN.])

#labquestion(2)[Build one row per customer][
  Clustering needs one row per customer, and the file holds one row per invoice line. Clean the lines with fixed rules, then summarize each customer by recency (days since the last purchase), frequency (number of orders) and monetary value (total spend): the RFM table marketers use. All three have long right tails, so they are logged before scaling.
]

#labanswer[
  #include "visuals/04-trace.typ"

  #labcode("lab04_clustering_pca", 2)

  #readcode[
    - `dtype={"Invoice": str, "StockCode": str}` reads the two code columns as text, and `parse_dates=["InvoiceDate"]` turns the date column into real dates while reading.
    - `lines["Invoice"].str.startswith("C")` marks the cancelled invoices, whose numbers begin with a C. The mean of the mask is their share.
    - `dropna(subset=["Customer ID"])` drops the lines that name no customer. `real_sale` joins three conditions with `&`; the `~` in front of the first one flips it to "not a cancellation".
    - `assign(revenue=...)` adds a column: the quantity times the unit price.
    - `day_after` is midnight after the last sale: `normalize()` sets the time to 00:00, and `pd.Timedelta(days=1)` adds a day.
    - `groupby("Customer ID").agg(...)` builds one row per customer. Each argument has the form `new_column=(source_column, how)`: the days since the customer's last order, the number of different invoices (`nunique`), and the total revenue.
    - `np.log1p` pulls in the long tails, and `StandardScaler().fit_transform` puts the three columns on one scale. There is no split, because nothing is being predicted.
  ]

  #refoutput[
    ```terminal
    invoice lines: 1067371  from 2009-12-01 to 2011-12-09
    no customer ID: 0.228  cancellations: 0.018  exact duplicates: 34335
    779425 clean lines from 5878 customers
          recency_days  orders     spend
    50%           95.0     3.0     867.7
    mean         200.9     6.3    2955.9
    max          738.0   398.0  580987.0
    ```
  ]

  #strong[What it means.] Over a million lines become 779,425 sales from 5,878 customers. Almost a quarter of the lines have no customer ID, so they cannot belong to anyone’s history; cancellations, returns and repeated lines would distort the totals. Every rule is fixed, so it may run before any model. The mean spend is more than three times the median, the long tail the logs are there to tame.
]

#labquestion(3)[Score $k$ from 2 to 8][
  K-means needs $k$ in advance. Inertia always falls as $k$ grows, so look for a bend; the silhouette asks how much closer each customer is to its own cluster than to the next one, and peaks at a good $k$.
]

#labanswer[
  #include "visuals/04-worked-case.typ"

  #labcode("lab04_clustering_pca", 3)

  #readcode[
    - The loop fits K-means once for each `k` from 2 to 8. `n_init=20` starts each fit from 20 random sets of centers and keeps the best result.
    - `fit_predict(X)` fits the model and returns each customer's cluster number.
    - `kmeans.inertia_` is the total squared distance from every customer to their own center. It always falls as `k` grows, so the bend is what matters, not the lowest value.
    - `silhouette_score(X, labels)` compares, for each customer, the distance to their own cluster with the distance to the nearest other cluster. Unlike inertia, it has a best value.
  ]

  #labvisual[Reference plot from the supplied notebook][
    #fitted-image("/MACHINE LEARNING/labs/visuals/04-notebook-reference.png", width: 88%, height: 5cm)
  ]

  #refoutput[
    ```terminal
    k=2  inertia=8600.4  silhouette=0.439
    k=3  inertia=6375.8  silhouette=0.347
    k=4  inertia=4963.7  silhouette=0.365
    k=5  inertia=4137.7  silhouette=0.339
    ...
    k=8  inertia=2919.8  silhouette=0.307
    ```
  ]

  #strong[What it means.] The silhouette peaks at $k=2$, a split into active and inactive customers that any shopkeeper already knows. Among the richer splits, $k=4$ beats both 3 and 5. The numbers narrow the choice; what the segments are for decides it, and the next questions use four.
]

#labquestion(4)[Compare K-means with DBSCAN][
  K-means with four segments, against DBSCAN, which finds dense regions and leaves the rest as #emph[noise]. Here noise is not an error: it is the customers who look like no one else.
]

#labanswer[
  #labcode("lab04_clustering_pca", 4)

  #readcode[
    - `DBSCAN(eps=0.5, min_samples=10)` grows clusters from dense regions: places where at least 10 customers lie within a distance of 0.5 of one another. A customer who belongs to no dense region gets the label -1, which means noise.
    - `d_labels == -1` is a mask for the noise customers.
    - `customers.loc[is_noise, "spend"].sum() / customers["spend"].sum()` is the share of all revenue that comes from the noise customers.
    - `len(set(d_labels[~is_noise]))` counts the different cluster numbers once the noise is left out.
  ]

  #refoutput[
    ```terminal
    K-means (k=4) silhouette: 0.365
    DBSCAN clusters: 2  noise customers: 91  their share of revenue: 0.308
    noise customers' median orders and spend: {'orders': 29.0, 'spend': 23419.0}
    ```
  ]

  #strong[What it means.] DBSCAN finds two dense groups and refuses to place 91 customers, 1.5% of them. Those 91 carry 30.8% of the shop’s revenue, with a median of 29 orders and £23,419: the wholesale buyers. A method allowed to say “none of the above” found the customers who matter most.
]

#labquestion(5)[Describe the segments][
  Medians describe each K-means segment in its own units, with its share of the shop’s revenue.
]

#labanswer[
  #labcode("lab04_clustering_pca", 5)

  #readcode[
    - `customers.assign(kmeans_cluster=k_labels, dbscan_cluster=d_labels)` attaches both sets of labels to the customer table.
    - `groupby("kmeans_cluster").agg(...)` describes each segment: its size (`"size"`), three medians, and its total spend.
    - `profile.pop("revenue")` removes that column and hands it back, so it can be divided by the shop's total revenue and stored as a share.
    - `round({...})` rounds each column to its own number of decimals.
  ]

  #refoutput[
    ```terminal
                    customers  recency_days  orders   spend  revenue_share
    kmeans_cluster
    0                    2056         400.0     1.0   291.0          0.040
    1                    1474         162.0     5.0  1587.0          0.179
    2                    1117          15.0    13.0  5232.0          0.721
    3                    1231          23.0     3.0   721.0          0.059
    ```
  ]

  #strong[What it means.] Four segments a marketing team can act on: 2,056 lost one-time buyers who last ordered over a year ago; 1,474 lapsing regulars, worth a reminder; 1,231 recent occasional buyers, worth a second sale; and 1,117 best customers, who order every few weeks and bring in 72.1% of all revenue. The cluster numbers are arbitrary; the names come from reading the medians.
]

#labquestion(6)[Plot both clusterings][
  Orders against spend, on log scales, colored by each method’s labels.
]

#labanswer[
  #labcode("lab04_clustering_pca", 6)

  #readcode[
    - The list `clusterings` pairs each chart with a set of labels and a title, and the loop draws both in the same way.
    - `ax.scatter(..., c=labels, cmap="tab10")` colours each customer by cluster number.
    - `set_xscale("log")` and `set_yscale("log")` spread out the crowded low end of both axes.
    - `scatter.legend_elements()` returns one legend entry per colour, and the `*` unpacks them into `ax.legend`.
  ]

  #strong[What it means.] K-means cuts the cloud into four slices, because it always splits the space. DBSCAN draws a different line: its two dense clusters are simply the customers who ordered once and those who came back. Its noise points are the outliers, mostly at the top right, where a few customers have many orders and very large bills, plus a scattering of single unusually large orders.
]

#labcheckpoint[
  #listopts(leftmargin: 1.2em, itemsep: 1.9925pt, topsep: 0.9963pt)[
    - 779,425 clean lines from 5,878 customers.
    - The silhouette peaks at $k=2$ (0.439); $k=4$ scores 0.365.
    - DBSCAN leaves 91 customers as noise, and they bring 30.8% of the revenue.
  ]
]

#labpartopen([Part B], [PCA on wood-defect images], [Questions 7--11 • Data: wood surface defects], [Compress 3,072 pixels with PCA, choose how much to keep on validation, and open the test images once.])

#labquestion(7)[Load the images][
  The source holds 20,276 photos of sawn boards, collected for automated quality control, with a box around each defect. The course file holds 15,701 of those defects, cut out and shrunk to 32 by 32 colour pixels, in seven types. Most boards carry several defects, so whole boards go to one side of each split, development or test: a defect never meets its neighbour from the same board on the other side. The test images stay closed until Question~9.
]

#labanswer[
  #labcode("lab04_clustering_pca", 7)

  #readcode[
    - `np.load` opens the `.npz` file, which holds several named arrays: the images `x`, the labels `y`, the board each image was cut from, and the class names.
    - `np.bincount(labels)` counts the images of each type, and `dict(zip(class_names, ...))` pairs the counts with the names.
    - `images.reshape(len(images), -1)` flattens each image into one row. The `-1` tells NumPy to work out the row length itself: 32 x 32 x 3 = 3,072. Dividing by 255 puts every value between 0 and 1.
    - `GroupShuffleSplit(...).split(X_all, labels, boards)` yields the row positions of the two sides, with every board wholly on one side. `next(...)` takes the single split that was asked for.
    - `set(b_dev) & set(boards[test_rows])` is the set of boards that appear on both sides. It must be empty.
    - `np.flatnonzero(labels == k)[0]` is the position of the first image of type `k`.
  ]

  #refoutput[
    ```terminal
    images: (15701, 32, 32, 3)  boards: 10358
    per defect type: {'live knot': 3000, 'dead knot': 3000, 'resin': 3000, 'knot with crack': 2276,
     'crack': 2169, 'marrow': 1181, 'quartzity': 1075}
    12567 development and 3134 test images; boards in both: 0
    ```
  ]

  #strong[What it means.] Each image becomes a row of $32 times 32 times 3=3","072$ numbers. Neighboring pixels, and the three colours of one pixel, are strongly correlated: that redundancy is what PCA can remove. The types are not balanced, so the per-type recall in Question~9 matters as much as the accuracy.
]

#strong[Connect it to the chapter.] K-means and PCA both had no answer key, and from here on PCA is judged against one.

#include "visuals/04-clustering-pca-chapter.typ"

#labquestion(8)[Choose a PCA budget on validation][
  How much variance to keep is a hyperparameter, so it is chosen on validation rows: a quarter of the development boards, split off the same way. Logistic regression on all 3,072 pixels is the reference; with that many inputs it needs up to 3,000 steps to converge.
]

#labanswer[
  #labcode("lab04_clustering_pca", 8)

  #readcode[
    - The development images are split once more, again by board, into a part to fit on and a part to validate on.
    - In `PCA(n_components=0.90, svd_solver="full")`, a fraction in place of a whole number asks PCA to keep as many components as it takes to hold that share of the variance.
    - Inside the pipeline, PCA is fitted on the fitting images only, and the logistic regression is trained on the compressed rows.
    - `candidate.named_steps["pca"].n_components_` reports how many components were kept.
    - `f"{retained_variance:.0%}"` prints 0.9 as 90%.
  ]

  #refoutput[
    ```terminal
    all 3,072 pixels: validation accuracy = 0.6168
    90% variance:  21 components, validation accuracy = 0.5701
    95% variance:  50 components, validation accuracy = 0.5919
    99% variance: 248 components, validation accuracy = 0.6072
    ```
  ]

  #strong[What it means.] Ninety per cent of the variance fits in just 21 directions, but those directions describe the light and colour of the wood more than the shape of a defect, and they score 0.570. The score climbs with the budget, and 99%, 248 components, comes within a point of all 3,072 pixels. The budget is 99%: a twelvefold compression for almost no loss.
]

#labquestion(9)[Open the test images once][
  The chosen budget, 99% of the variance, is refit on all the development images and scored once on the test boards, beside logistic regression on all 3,072 pixels.
]

#labanswer[
  #labcode("lab04_clustering_pca", 9)

  #readcode[
    - The chosen pipeline and the plain model are refitted on all the development images: once the choice is made, the validation rows can be used for training.
    - `pca.explained_variance_ratio_.sum()` is the share of the variance that the kept components hold.
    - `recall_score(..., average=None)` returns one recall per defect type instead of a single average.
  ]

  #refoutput[
    ```terminal
    FINAL TEST (3,134 images from boards never seen in development)
    all 3,072 pixels accuracy: 0.6375
    PCA components kept: 253  variance retained: 0.99
    PCA -> logistic accuracy: 0.6331
    recall per defect type: {'live knot': 0.56, 'dead knot': 0.69, 'resin': 0.73, 'knot with crack': 0.43,
     'crack': 0.72, 'marrow': 0.74, 'quartzity': 0.58}
    ```
  ]

  #strong[What it means.] On boards never seen before, 253 components score 0.633 against 0.638 for every pixel: half a point for a model twelve times smaller in its inputs. Knots with cracks are the hardest type (recall 0.43), because they look like the knots they are; cracks, resin and marrow are found most often. A linear model on pixels stops near 64%; Lab~7 asks whether a network that learns its own features can do better.
]

#labquestion(10)[See what 99% looks like][
  Rebuild eight test images from 90% and from 99% of the variance to see what each keeps, and draw how the variance accumulates over the 3,072 directions.
]

#labanswer[
  #labcode("lab04_clustering_pca", 10)

  #readcode[
    - `few.transform(X_test[:8])` compresses eight images to a few numbers each, and `few.inverse_transform(...)` expands them back to 3,072 numbers: the image as the components remember it.
    - `batch[j].reshape(32, 32, 3)` turns a row back into a picture, and `np.clip(..., 0, 1)` trims the values that the rebuilding pushed slightly outside the valid range.
    - `PCA(svd_solver="full").fit(X_dev)` keeps every component, and `np.cumsum(explained_variance_ratio_)` is the running total of the variance.
    - `np.searchsorted(cumulative, share) + 1` is the number of components needed to reach a share: the position of the first running total that is at least that large, plus one because positions start at 0.
  ]

  #refoutput[
    ```terminal
    components for 50%, 80%, 90%, 95% and 99% of the variance: [2, 8, 21, 51, 253]
    the first three components hold 0.624 of the variance
    ```
  ]

  #strong[What it means.] Two directions hold half of the variance and three hold 62%: mostly how light or dark, and how yellow, the wood is. Rebuilt from 21 components, a knot is a soft brown blur; from 253, its rings and cracks come back. Variance is not the same as usefulness: the directions that matter for telling defects apart are the faint ones, deep in the curve.
]

#labquestion(11)[Save and reload the model][
  Save the pipeline, reload it, and check that it still names the first test images.
]

#labanswer[
  #labcode("lab04_clustering_pca", 11)

  #readcode[
    - `joblib.dump(final_model, model_path)` saves the PCA and the classifier in one file, so new images are compressed exactly as the training images were.
    - `loaded.predict(X_test[:5])` returns class numbers, and the list comprehension turns them into names.
    - Dividing the file size by `1e6` gives megabytes.
  ]

  #refoutput[
    ```terminal
    file size (MB): 6.26
    predicted: ['knot with crack', 'knot with crack', 'dead knot', 'dead knot', 'knot with crack']
    actual:    ['knot with crack', 'knot with crack', 'knot with crack', 'dead knot', 'knot with crack']
    ```
  ]

  #strong[What it means.] Four of the five first test images are named correctly, and the miss is the confusion Question~9 predicted: a knot with a crack called a dead knot. The file holds the 253 components, each 3,072 numbers long, and the classifier: the price of compression is storing the directions.
]

#labcheckpoint[
  #listopts(leftmargin: 1.2em, itemsep: 1.9925pt, topsep: 0.9963pt)[
    - Keeping 99% of the variance takes 248 components and scores 0.6072 on validation, against 0.6168 for all pixels.
    - On the test boards: 0.6375 for all pixels and 0.6331 with 253 components.
  ]
]

#labpartopen([Finish], [Save the evidence, then try it yourself], [Questions 12--14], [Write the results folder, then extend the lab yourself before reading one worked solution.])

#labquestion(12)[Save the evidence][
  Write the numbers above to the results folder. These files are regenerated on every run, so do not edit them by hand.
]

#labanswer[
  #labcode("lab04_clustering_pca", 12)

  #readcode[
    - Each table is built with `pd.DataFrame` from the lists and arrays collected along the way, and written with `to_csv`.
    - `np.arange(1, len(cumulative) + 1)` numbers the components from 1.
    - `index=False` leaves out the row numbers. The segment table keeps its index, because the index is the cluster number.
  ]
]

#labquestion(13)[Try it yourself][
  Cluster images without their labels. Reduce the Question~8 fitting images to 50 PCA components, run K-means with 7 clusters, one per defect type, and only then compare the clusters with the true types, with the adjusted Rand index and a table of what each cluster contains. Attempt it in this empty cell before reading the solution.
]

#labquestion(14)[One solution][
  The labels are used only after the clustering, to judge it. The average image of each cluster shows what K-means grouped by.
]

#labanswer[
  #labcode("lab04_clustering_pca", 14)

  #readcode[
    - `PCA(n_components=50, random_state=42).fit_transform(X_fit)` compresses each image to 50 numbers, and `KMeans(n_clusters=7, ...)` groups those rows. The labels are not used.
    - `adjusted_rand_score(y_fit, image_clusters)` compares the clusters with the true types: 1 for a perfect match, about 0 for a random one.
    - `pd.crosstab(...)` counts the true types inside each cluster. `pd.Categorical.from_codes(y_fit, class_names)` turns the label numbers into names for the column headings.
    - `table.idxmax(axis=1)` is each cluster's most common type, and `table.max(axis=1) / table.sum(axis=1)` is its purity.
    - `X_fit[image_clusters == c].mean(axis=0)` averages the images of one cluster pixel by pixel.
  ]

  #refoutput[
    ```terminal
    adjusted Rand index against the true defect types: 0.129
             images most common type  purity
    cluster
    2          1570        dead knot    0.56
    1          1630        live knot    0.46
    3          1048            resin    0.39
    ...
    0           380            resin    0.27
    ```
  ]

  #strong[What it means.] The clusters barely match the types: an adjusted Rand index of 0.129, where 1 would be the types exactly and 0 a random split. The purest cluster is only 56% dead knots. The average images show why: K-means grouped the defects by brightness, colour and the direction of the grain, which is what varies most in pixels, not by what a grader calls a defect. Without labels, “similar” means similar pixels.
]

#labpartopen([After the lab], [Exercises, troubleshooting and hand-in], [Exercises • Answers • Troubleshooting • Checklists], [Extend the lab with the exercises, compare with the answers, and check your work against the two checklists before you hand it in.])

#exercises[
  Add new cells at the end of the notebook for these tasks, and record your numbers before reading the answers.

  + #strong[One start or many?] Rerun K-means on the customers at $k=4$ with `n_init=1`, for seeds 0 to 7, and record each inertia. Then do the same for the Question~14 images at $k=7$. What does the difference say about `n_init`?
  + #strong[Take the logs away.] Refit K-means at $k=4$ on the scaled but unlogged RFM columns, and compare the labels with Question~4’s using `adjusted_rand_score`. How large are the four clusters?
  + #strong[Four or five?] Print the segment profile for $k=5$. Which of the four segments splits, and could a marketing team use that split?
  + #strong[How few components?] Score logistic regression on the Question~8 validation rows with 2, 10 and 50 components. What share of the variance do two components keep, and what are they good for?
]

#answers[
  #strong[Warm-up.] Recency 8 days (from 2 December to 10 December), frequency 2, monetary value £200. On raw numbers a gap of £100,000 between two big spenders outweighs every other difference, so the few largest customers decide the clusters; logs measure spend in ratios, so £300 against £3,000 counts as much as £3,000 against £30,000.

  + The customers are stable: all eight single starts end between 4,963.7 and 4,964.0. The images are not: eight starts end between 248,598 and 251,895, and only three of them land within a few units of the best. Four well-separated customer groups leave little room for a bad start, while seven overlapping defect groups in 50 dimensions leave plenty. Several starts cost little and protect against the second case.
  + The adjusted Rand index against Question~4 is only 0.172, and the clusters hold 3,840, 1,999, 35 and 4 customers: two of the four “segments” are just the biggest spenders. Without the logs, the units decide the clustering.
  + At $k=5$ the best customers split into 480 “champions” (median 7 days since the last order, 23 orders, £9,324) and 1,267 loyal regulars (35 days, 8 orders, £2,910). A team with a small budget for personal service may well want that split, an argument the silhouette alone cannot make.
  + Validation accuracy is 0.420 with 2 components, 0.538 with 10 and 0.591 with 50, against 0.607 with 248. Two components keep 53.0% of the variance, mostly the light and colour of the wood: good for drawing all the images on one page, not for telling a crack from a knot.
]

#tip[
  / `FileNotFoundError` for the ZIP: Keep `unsupervised/online_retail_ii/online_retail_ii.zip` zipped in `all_datasets/`; pandas reads the CSV inside it.
  / A `KMeans` memory-leak warning on Windows: scikit-learn suggests setting `OMP_NUM_THREADS`; the results are unaffected.
  / Question~2 is slow: Reading a million lines takes a few seconds.
  / Questions~8 and~9 take a minute each: Logistic regression on 3,072 pixels needs many steps; `max_iter=3000` lets it converge. With the default it stops early and warns.
]

#labchecklists[
  #checklist[
    - The cleaning rules are fixed and listed, and the RFM columns are logged and scaled before clustering.
    - The choice of $k$ is justified by the silhouette and by what the segments are for.
    - You can say who DBSCAN’s noise customers are, and why they matter.
    - Every split keeps whole boards on one side, the PCA budget is chosen on validation rows, and the test boards are scored once.
    - `models/wood_pca_logistic.joblib` reloads and names the first test images.
  ]
]
