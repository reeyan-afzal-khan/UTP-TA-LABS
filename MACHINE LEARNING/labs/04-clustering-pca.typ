#import "/.shared/typst/utp.typ": *
#unit("labs", "04-clustering-pca")

#lab("4")[Unsupervised learning I: clustering and PCA] <sec:lab04-clustering-pca>

#callout("labproject", title: [Customer segments from two years of invoices, and a compressed view of 15,701 wood-defect images])[#strong[Read first.] Chapters~#ref(label("ch:unsupervised"), supplement: none)--#ref(label("ch:dimred"), supplement: none). \
#strong[Goal.] Turn raw invoice lines into one row per customer, find segments with K-means and DBSCAN and judge them by evidence and usefulness, then compress images with PCA and choose how much to keep by validation, testing once. \
#strong[Scenario.] An online gift shop hands you two years of invoices and asks who its customers are, with no labels to learn from. A sawmill's inspection camera photographs every defect on its boards and asks how much of each photo it really needs to keep. Neither question has an answer key, so the evidence has to come from the data and from what the answer is for. \
#strong[Data.] In `all_datasets/`: `unsupervised/ online_retail_ii/ online_retail_ii.zip`, every invoice line of a UK online shop from December 2009 to December 2011, from the UCI repository (Chen, 2012); and `unsupervised/ wood_surface_defects/ wood_defects.npz`, 15,701 photos of seven kinds of defect on sawn boards, cut from a public industrial dataset (Kodytek, Bodzas and Bilik, 2022). \
#strong[Notebook.] `all_experiments/ lab04_clustering_pca/ lab04_clustering_pca_worked.ipynb`, with a README beside it. \
#strong[Hand in.] The executed notebook, `results/lab04/`, the saved PCA model and a short conclusion, as listed in the checklist at the end of this sheet.]

#heading(level: 2, numbering: none)[Your map of this lab]
#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    [Part], [What you do], [Questions],
    [A], [Build customer rows, segment them with $K$-means, find outliers with DBSCAN], [2--6],
    [B], [Compress wood-defect images with PCA, choose the budget, test once and save], [7--11],
    [Finish], [Save the evidence; then cluster the defect images], [12--14],
    [After], [Your-turn tasks, expected findings, troubleshooting and the two checklists], [---],
  )]
  , kind: table
  )

#callout("labmode", title: [Lab setup])[+ Activate your course environment and confirm the two data files are in `all_datasets/`. Keep the ZIP file as it is: pandas reads the CSV inside it directly.

+ From the course folder, start Jupyter, open the notebook, and choose #strong[Restart Kernel and Run All Cells]. It takes about two minutes; the pixel models of Questions~8 and~9 take most of it.

+ Part~A is clustering and Part~B is PCA. Neither has an answer key, so each question asks for the evidence a result needs.

#code-block("jupyter lab", lang: "text") Prefer a plain script? From the course folder, `python all_experiments/ lab04_clustering_pca/ lab04_clustering_pca_worked.py` runs the same code and writes the same evidence.]

#strong[How to work through this sheet.] Predict the result, run the matching notebook cell, compare with the reference output, and explain the result in your own words.

#callout("yourturn", title: [Your turn])[#strong[Warm-up on paper.] Do these before opening the notebook; the code will check you.

+ A customer bought on 1 November 2011 and on 2 December 2011, in two orders worth £120 and £80. The data ends on 9 December 2011, and recency is counted from the day after. What are this customer's recency, frequency and monetary value?

+ Spend runs from £3 to £580,987, with a median of £868. Why would K-means on the raw numbers spend most of its effort on a few customers, and what does taking logs change?]

#callout("labquestion", title: [Question 1 --- Setup])[Run this first, and keep this kernel for the later questions. Every lab starts the same way. `start_lab()`, from `all_experiments/ course_setup.py`, finds the course folder and returns the three folders the lab uses: `DATA` to read from, `RESULTS` and `MODELS` to write to. The imports in between are grouped by what they are for.] #callout("labanswer", title: [Worked answer])[#source-code("/MACHINE LEARNING/all_experiments/lab04_clustering_pca/lab04_clustering_pca_worked.py", first: 11, last: 30, lang: "python") *Reference output.*

#code-block("course folder: MACHINE LEARNING\nreads all_datasets/, writes results/lab04/ and models/", lang: "text")]

#callout("labpart", title: [Part A --- Clustering customers from their invoices])[*Goal.* Turn a million invoice lines into one row per customer, then find segments with $K$-means and outliers with DBSCAN.

Questions 2--6 •~Data: Online Retail II invoices]

#callout("labquestion", title: [Question 2 --- Build one row per customer])[Clustering needs one row per customer, and the file holds one row per invoice line. Clean the lines with fixed rules, then summarize each customer by recency (days since the last purchase), frequency (number of orders) and monetary value (total spend): the RFM table marketers use. All three have long right tails, so they are logged before scaling.] #callout("labanswer", title: [Worked answer])[
#include "/MACHINE LEARNING/labs/visuals/04-trace.typ"
 #source-code("/MACHINE LEARNING/all_experiments/lab04_clustering_pca/lab04_clustering_pca_worked.py", first: 32, last: 59, lang: "python") *Reference output.*

#code-block("invoice lines: 1067371  from 2009-12-01 to 2011-12-09\nno customer ID: 0.228  cancellations: 0.018  exact duplicates: 34335\n779425 clean lines from 5878 customers\n      recency_days  orders     spend\n50\nmean         200.9     6.3    2955.9\nmax          738.0   398.0  580987.0", lang: "text")

#strong[What it means.] Over a million lines become 779,425 sales from 5,878 customers. Almost a quarter of the lines have no customer ID, so they cannot belong to anyone's history; cancellations, returns and repeated lines would distort the totals. Every rule is fixed, so it may run before any model. The mean spend is more than three times the median, the long tail the logs are there to tame.]

#callout("labquestion", title: [Question 3 --- Score $k$ from 2 to 8])[K-means needs $k$ in advance. Inertia always falls as $k$ grows, so look for a bend; the silhouette asks how much closer each customer is to its own cluster than to the next one, and peaks at a good $k$.] #callout("labanswer", title: [Worked answer])[
#include "/MACHINE LEARNING/labs/visuals/04-worked-case.typ"
 #source-code("/MACHINE LEARNING/all_experiments/lab04_clustering_pca/lab04_clustering_pca_worked.py", first: 61, last: 82, lang: "python") #callout("labvisual", title: [Reference plot from the supplied notebook])[#image("/MACHINE LEARNING/labs/visuals/04-notebook-reference.png", width: 90%)] *Reference output.*

#code-block("k=2  inertia=8600.4  silhouette=0.439\nk=3  inertia=6375.8  silhouette=0.347\nk=4  inertia=4963.7  silhouette=0.365\nk=5  inertia=4137.7  silhouette=0.339\n...\nk=8  inertia=2919.8  silhouette=0.307", lang: "text")

#strong[What it means.] The silhouette peaks at $k = 2$, a split into active and inactive customers that any shopkeeper already knows. Among the richer splits, $k = 4$ beats both 3 and 5. The numbers narrow the choice; what the segments are for decides it, and the next questions use four.]

#callout("labquestion", title: [Question 4 --- Compare K-means with DBSCAN])[K-means with four segments, against DBSCAN, which finds dense regions and leaves the rest as #emph[noise]. Here noise is not an error: it is the customers who look like no one else.] #callout("labanswer", title: [Worked answer])[#source-code("/MACHINE LEARNING/all_experiments/lab04_clustering_pca/lab04_clustering_pca_worked.py", first: 84, last: 97, lang: "python") *Reference output.*

#code-block("K-means (k=4) silhouette: 0.365\nDBSCAN clusters: 2  noise customers: 91  their share of revenue: 0.308\nnoise customers' median orders and spend: {'orders': 29.0, 'spend': 23419.0}", lang: "text")

#strong[What it means.] DBSCAN finds two dense groups and refuses to place 91 customers, 1.5% of them. Those 91 carry 30.8% of the shop's revenue, with a median of 29 orders and £23,419: the wholesale buyers. A method allowed to say "none of the above" found the customers who matter most.]

#callout("labquestion", title: [Question 5 --- Describe the segments])[Medians describe each K-means segment in its own units, with its share of the shop's revenue.] #callout("labanswer", title: [Worked answer])[#source-code("/MACHINE LEARNING/all_experiments/lab04_clustering_pca/lab04_clustering_pca_worked.py", first: 99, last: 109, lang: "python") *Reference output.*

#code-block("customers  recency_days  orders   spend  revenue_share\nkmeans_cluster\n0                    2056         400.0     1.0   291.0          0.040\n1                    1474         162.0     5.0  1587.0          0.179\n2                    1117          15.0    13.0  5232.0          0.721\n3                    1231          23.0     3.0   721.0          0.059", lang: "text")

#strong[What it means.] Four segments a marketing team can act on: 2,056 lost one-time buyers who last ordered over a year ago; 1,474 lapsing regulars, worth a reminder; 1,231 recent occasional buyers, worth a second sale; and 1,117 best customers, who order every few weeks and bring in 72.1% of all revenue. The cluster numbers are arbitrary; the names come from reading the medians.]

#callout("labquestion", title: [Question 6 --- Plot both clusterings])[Orders against spend, on log scales, colored by each method's labels.] #callout("labanswer", title: [Worked answer])[#source-code("/MACHINE LEARNING/all_experiments/lab04_clustering_pca/lab04_clustering_pca_worked.py", first: 111, last: 124, lang: "python")

#strong[What it means.] K-means cuts the cloud into four slices, because it always splits the space. DBSCAN draws a different line: its two dense clusters are simply the customers who ordered once and those who came back. Its noise points are the outliers, mostly at the top right, where a few customers have many orders and very large bills, plus a scattering of single unusually large orders.]

#callout("labcheckpoint", title: [Checkpoint: before you move on])[- 779,425 clean lines from 5,878 customers.

- The silhouette peaks at $k = 2$ (0.439); $k = 4$ scores 0.365.

- DBSCAN leaves 91 customers as noise, and they bring 30.8% of the revenue.]

#callout("labpart", title: [Part B --- PCA on wood-defect images])[*Goal.* Compress 3,072 pixels with PCA, choose how much to keep on validation, and open the test images once.

Questions 7--11 •~Data: wood surface defects]

#callout("labquestion", title: [Question 7 --- Load the images])[The source holds 20,276 photos of sawn boards, collected for automated quality control, with a box around each defect. The course file holds 15,701 of those defects, cut out and shrunk to 32 by 32 colour pixels, in seven types. Most boards carry several defects, so whole boards go to one side of each split, development or test: a defect never meets its neighbour from the same board on the other side. The test images stay closed until Question~9.] #callout("labanswer", title: [Worked answer])[#source-code("/MACHINE LEARNING/all_experiments/lab04_clustering_pca/lab04_clustering_pca_worked.py", first: 126, last: 150, lang: "python") *Reference output.*

#code-block("images: (15701, 32, 32, 3)  boards: 10358\nper defect type: {'live knot': 3000, 'dead knot': 3000, 'resin': 3000, 'knot with crack': 2276,\n 'crack': 2169, 'marrow': 1181, 'quartzity': 1075}\n12567 development and 3134 test images; boards in both: 0", lang: "text")

#strong[What it means.] Each image becomes a row of $32 times 32 times 3 = 3 \, 072$ numbers. Neighboring pixels, and the three colours of one pixel, are strongly correlated: that redundancy is what PCA can remove. The types are not balanced, so the per-type recall in Question~9 matters as much as the accuracy.]

#strong[Connect it to the chapter.] K-means and PCA both had no answer key, and from here on PCA is judged against one. 
#include "/MACHINE LEARNING/labs/visuals/04-clustering-pca-chapter.typ"


#callout("labquestion", title: [Question 8 --- Choose a PCA budget on validation])[How much variance to keep is a hyperparameter, so it is chosen on validation rows: a quarter of the development boards, split off the same way. Logistic regression on all 3,072 pixels is the reference; with that many inputs it needs up to 3,000 steps to converge.] #callout("labanswer", title: [Worked answer])[#source-code("/MACHINE LEARNING/all_experiments/lab04_clustering_pca/lab04_clustering_pca_worked.py", first: 152, last: 170, lang: "python") *Reference output.*

#code-block("all 3,072 pixels: validation accuracy = 0.6168\n90\n95\n99", lang: "text")

#strong[What it means.] Ninety per cent of the variance fits in just 21 directions, but those directions describe the light and colour of the wood more than the shape of a defect, and they score 0.570. The score climbs with the budget, and 99%, 248 components, comes within a point of all 3,072 pixels. The budget is 99%: a twelvefold compression for almost no loss.]

#callout("labquestion", title: [Question 9 --- Open the test images once])[The chosen budget, 99% of the variance, is refit on all the development images and scored once on the test boards, beside logistic regression on all 3,072 pixels.] #callout("labanswer", title: [Worked answer])[#source-code("/MACHINE LEARNING/all_experiments/lab04_clustering_pca/lab04_clustering_pca_worked.py", first: 172, last: 186, lang: "python") *Reference output.*

#code-block("FINAL TEST (3,134 images from boards never seen in development)\nall 3,072 pixels accuracy: 0.6375\nPCA components kept: 253  variance retained: 0.99\nPCA -> logistic accuracy: 0.6331\nrecall per defect type: {'live knot': 0.56, 'dead knot': 0.69, 'resin': 0.73, 'knot with crack': 0.43,\n 'crack': 0.72, 'marrow': 0.74, 'quartzity': 0.58}", lang: "text")

#strong[What it means.] On boards never seen before, 253 components score 0.633 against 0.638 for every pixel: half a point for a model twelve times smaller in its inputs. Knots with cracks are the hardest type (recall 0.43), because they look like the knots they are; cracks, resin and marrow are found most often. A linear model on pixels stops near 64%; Lab~7 asks whether a network that learns its own features can do better.]

#callout("labquestion", title: [Question 10 --- See what 99% looks like])[Rebuild eight test images from 90% and from 99% of the variance to see what each keeps, and draw how the variance accumulates over the 3,072 directions.] #callout("labanswer", title: [Worked answer])[#source-code("/MACHINE LEARNING/all_experiments/lab04_clustering_pca/lab04_clustering_pca_worked.py", first: 188, last: 220, lang: "python") *Reference output.*

#code-block("components for 50\nthe first three components hold 0.624 of the variance", lang: "text")

#strong[What it means.] Two directions hold half of the variance and three hold 62%: mostly how light or dark, and how yellow, the wood is. Rebuilt from 21 components, a knot is a soft brown blur; from 253, its rings and cracks come back. Variance is not the same as usefulness: the directions that matter for telling defects apart are the faint ones, deep in the curve.]

#callout("labquestion", title: [Question 11 --- Save and reload the model])[Save the pipeline, reload it, and check that it still names the first test images.] #callout("labanswer", title: [Worked answer])[#source-code("/MACHINE LEARNING/all_experiments/lab04_clustering_pca/lab04_clustering_pca_worked.py", first: 222, last: 229, lang: "python") *Reference output.*

#code-block("file size (MB): 6.26\npredicted: ['knot with crack', 'knot with crack', 'dead knot', 'dead knot', 'knot with crack']\nactual:    ['knot with crack', 'knot with crack', 'knot with crack', 'dead knot', 'knot with crack']", lang: "text")

#strong[What it means.] Four of the five first test images are named correctly, and the miss is the confusion Question~9 predicted: a knot with a crack called a dead knot. The file holds the 253 components, each 3,072 numbers long, and the classifier: the price of compression is storing the directions.]

#callout("labcheckpoint", title: [Checkpoint: before you move on])[- Keeping 99% of the variance takes 248 components and scores 0.6072 on validation, against 0.6168 for all pixels.

- On the test boards: 0.6375 for all pixels and 0.6331 with 253 components.]

#callout("labpart", title: [Finish --- Save the evidence, then try it yourself])[*Goal.* Write the results folder, then extend the lab yourself before reading one worked solution.

Questions 12--14]

#callout("labquestion", title: [Question 12 --- Save the evidence])[Write the numbers above to the results folder. These files are regenerated on every run, so do not edit them by hand.] #callout("labanswer", title: [Worked answer])[#source-code("/MACHINE LEARNING/all_experiments/lab04_clustering_pca/lab04_clustering_pca_worked.py", first: 231, last: 243, lang: "python")]

#heading(level: 2, numbering: none)[Try it yourself]
#callout("labquestion", title: [Question 13 --- Try it yourself])[Cluster images without their labels. Reduce the Question~8 fitting images to 50 PCA components, run K-means with 7 clusters, one per defect type, and only then compare the clusters with the true types, with the adjusted Rand index and a table of what each cluster contains. Attempt it in this empty cell before reading the solution.]

#callout("labquestion", title: [Question 14 --- One solution])[The labels are used only after the clustering, to judge it. The average image of each cluster shows what K-means grouped by.] #callout("labanswer", title: [Worked answer])[#source-code("/MACHINE LEARNING/all_experiments/lab04_clustering_pca/lab04_clustering_pca_worked.py", first: 247, last: 269, lang: "python") *Reference output.*

#code-block("adjusted Rand index against the true defect types: 0.129\n         images most common type  purity\ncluster\n2          1570        dead knot    0.56\n1          1630        live knot    0.46\n3          1048            resin    0.39\n...\n0           380            resin    0.27", lang: "text")

#strong[What it means.] The clusters barely match the types: an adjusted Rand index of 0.129, where 1 would be the types exactly and 0 a random split. The purest cluster is only 56% dead knots. The average images show why: K-means grouped the defects by brightness, colour and the direction of the grain, which is what varies most in pixels, not by what a grader calls a defect. Without labels, "similar" means similar pixels.]

#callout("labpart", title: [After the lab --- Your turn, troubleshooting and hand-in])[*Goal.* Extend the lab with the Your-turn tasks, compare with the expected findings, and check your work against the two checklists before you hand it in.

Your-turn tasks •~Expected findings •~Troubleshooting •~Checklists]

#callout("yourturn", title: [Your turn])[Add new cells at the end of the notebook for these tasks, and record your numbers before reading the expected findings.

+ #strong[One start or many?] Rerun K-means on the customers at $k = 4$ with `n_init=1`, for seeds 0 to 7, and record each inertia. Then do the same for the Question~14 images at $k = 7$. What does the difference say about `n_init`?

+ #strong[Take the logs away.] Refit K-means at $k = 4$ on the scaled but unlogged RFM columns, and compare the labels with Question~4's using `adjusted_rand_score`. How large are the four clusters?

+ #strong[Four or five?] Print the segment profile for $k = 5$. Which of the four segments splits, and could a marketing team use that split?

+ #strong[How few components?] Score logistic regression on the Question~8 validation rows with 2, 10 and 50 components. What share of the variance do two components keep, and what are they good for?]

#callout("expectedfindings", title: [Expected findings])[#strong[Warm-up.] Recency 8 days (from 2 December to 10 December), frequency 2, monetary value £200. On raw numbers a gap of £100,000 between two big spenders outweighs every other difference, so the few largest customers decide the clusters; logs measure spend in ratios, so £300 against £3,000 counts as much as £3,000 against £30,000.

+ The customers are stable: all eight single starts end between 4,963.7 and 4,964.0. The images are not: eight starts end between 248,598 and 251,895, and only three of them land within a few units of the best. Four well-separated customer groups leave little room for a bad start, while seven overlapping defect groups in 50 dimensions leave plenty. Several starts cost little and protect against the second case.

+ The adjusted Rand index against Question~4 is only 0.172, and the clusters hold 3,840, 1,999, 35 and 4 customers: two of the four "segments" are just the biggest spenders. Without the logs, the units decide the clustering.

+ At $k = 5$ the best customers split into 480 "champions" (median 7 days since the last order, 23 orders, £9,324) and 1,267 loyal regulars (35 days, 8 orders, £2,910). A team with a small budget for personal service may well want that split, an argument the silhouette alone cannot make.

+ Validation accuracy is 0.420 with 2 components, 0.538 with 10 and 0.591 with 50, against 0.607 with 248. Two components keep 53.0% of the variance, mostly the light and colour of the wood: good for drawing all the images on one page, not for telling a crack from a knot.]

#callout("troubleshoot", title: [Troubleshooting])[/ `FileNotFoundError` for the ZIP: #block[
Keep `unsupervised/ online_retail_ii/ online_retail_ii.zip` zipped in `all_datasets/`; pandas reads the CSV inside it.
]

/ A `KMeans` memory-leak warning on Windows: #block[
scikit-learn suggests setting `OMP_NUM_THREADS`; the results are unaffected.
]

/ Question~2 is slow: #block[
Reading a million lines takes a few seconds.
]

/ Questions~8 and~9 take a minute each: #block[
Logistic regression on 3,072 pixels needs many steps; `max_iter=3000` lets it converge. With the default it stops early and warns.
]]

#callout("verification", title: [Verification checklist])[- The cleaning rules are fixed and listed, and the RFM columns are logged and scaled before clustering.

- The choice of $k$ is justified by the silhouette and by what the segments are for.

- You can say who DBSCAN's noise customers are, and why they matter.

- Every split keeps whole boards on one side, the PCA budget is chosen on validation rows, and the test boards are scored once.

- `models/wood_pca_logistic.joblib` reloads and names the first test images.]
