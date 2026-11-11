#import "/.shared/typst/utp.typ": *
#unit("chapters", "00-toolkit")


#heading(level: 1)[Your Toolkit and Environment Setup]
 <ch:toolkit>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Create folders and run basic #strong[terminal commands].

*By the end, you can:* organize data and notebooks, configure an environment, install dependencies, check that everything works, and run labs reproducibly.]

Every lab in this course runs from the same folder, in the same Python environment. Twenty minutes spent here saves hours of chasing path errors later.


#heading(level: 2)[The course project layout]


Your project root is the course folder. In this repository it is called `MACHINE LEARNING/`; name your own copy without spaces, for example `UTP-MACHINE-LEARNING/`, because spaces in paths cause avoidable trouble in terminals. Inside it you will find:

#block[
#code-block("all_datasets/       one folder per dataset\n  README.md         the index\n  supervised/       Labs 1-3: the answer is known\n    bank_marketing/\n    hotel_bookings/ hotel_bookings.zip,\n                    README.md\n    lending_club/\n    sms_spam/\n    telco_customer_churn/\n    used_cars/\n  unsupervised/     Labs 4-5: find structure\n    creditcard_fraud_ulb/\n    online_retail_ii/\n    wood_surface_defects/\n  advanced/         Labs 5, 7, 8\n    banking77/\n    electricity_load/", lang: "text")

]
#block[
#code-block("all_experiments/           one folder per lab:\n  course_setup.py          the setup every lab shares\n  lab01_features/          notebook, .py twin, README\n  lab02_supervised_workflow/ (+ predict_churn.py)\n  lab03_supervised_models/\n  lab04_clustering_pca/\n  lab05_anomaly_limited_labels/\n  lab06_reinforcement/\n  lab07_deep_learning_cnn/\n  lab08_deep_learning_lstm/\n  book_checks/\n    demo_study_log.py       Chapters 2,4,9,10,16,17\n    demo_foundations.py     Chapters 3,5-9\n    demo_model_families.py  Chapters 10-14\n    demo_unsupervised.py    Chapters 15-19\n    demo_advanced.py        Chapters 20-21\n    check_your_turn.py      Your-turn answers\nmodels/   results/lab01/ ... lab08/   requirements.txt", lang: "text")

]
Every dataset folder holds its file and a README, its data card: source, licence, columns and quirks. Keep the ZIP files zipped: pandas reads the CSV inside each one. Every lab folder holds one worked notebook, a `.py` twin that runs the same code, and a README naming its data, outputs and run time; each starts with `course_setup.py`, which finds the course folder. `predict_churn.py` uses the model saved in Lab~2. Notebooks write models and cards to `models/` and evidence to `results/`; do not edit generated outputs by hand. The `book_checks/` scripts print every worked number in the chapters and check it with an assert.


#heading(level: 2)[The datasets]


The course folder ships with all eleven datasets, so there is nothing to download. `all_datasets/` groups them by how the course learns from them: `supervised/` for tables whose answer is known (Labs~1 to~3), `unsupervised/` for data where the labs look for structure without the answer (Labs~4 and~5), and `advanced/` for few labels, deep networks and sequences. Every dataset is public and real, and each serves a lab where its quirks teach something. Click a #strong[dataset name] to read its documentation and licence; each dataset's README records how its file was made from the source.

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Dataset], [Where the labs use it],),
    table.hline(),
    [#link("https://huggingface.co/datasets/gemuchu/hotel_bookings")[Hotel Booking Demand]], [Lab~1: data card, features, leakage; Lab~2: date-order validation, overbooking threshold],
    [#link("https://huggingface.co/datasets/scikit-learn/churn-prediction")[Telco Customer Churn]], [Lab~1: repairing types, scaling and neighbors; Lab~2: tuning and a saved model],
    [#link("https://huggingface.co/datasets/MLLab-TS/bank_marketing")[Bank Marketing]], [Lab~1: prediction timing, feature selection, leakage],
    [#link("https://huggingface.co/datasets/KTHESAT/usa-used-car-market-cars-com")[Used Cars (Cars.com)]], [Lab~2: linear regression on messy listings; Lab~3: forests and boosting],
    [#link("https://huggingface.co/datasets/codesignal/lending-club-loan-accepted")[Lending Club Loans]], [Lab~3: KNN, naive Bayes, trees, SVMs],
    [#link("https://huggingface.co/datasets/codesignal/sms-spam-collection")[SMS Spam Collection]], [Lab~3 Try-it: text classification],
    [#link("https://huggingface.co/datasets/attik/Online-Retail-II-UCI")[Online Retail II]], [Lab~4: customer segments with $K$-means and DBSCAN],
    [#link("https://huggingface.co/datasets/iluvvatar/wood_surface_defects")[Wood Surface Defects]], [Lab~4: PCA; Lab~7: dense networks and CNNs],
    [#link("https://huggingface.co/datasets/David-Egea/Creditcard-fraud-detection")[Credit Card Fraud (ULB)]], [Lab~5: anomaly detection, imbalanced evaluation],
    [#link("https://huggingface.co/datasets/PolyAI/banking77")[Banking77]], [Lab~5: self-training and active learning],
    [#link("https://huggingface.co/datasets/sxj1024/electricity_load_2011_2014")[Electricity Load Diagrams 2011--2014]], [Lab~8: LSTM forecasting],
  )]
  , kind: table
  )


#heading(level: 3)[If a file is missing]


+ Copy it again from the course repository into #strong[its folder] in `all_datasets/`, keeping its #strong[exact name], including capitalization.

+ Keep #strong[ZIP files zipped]: the notebooks read them in place.

+ Run the notebook from inside the course folder: it finds `all_datasets/` by looking upward from where it runs.

#callout("pitfall", title: [Common mistake])[For #strong[`FileNotFoundError`], check the working directory and filename. Fix the path rather than moving files into the project root.]


#heading(level: 2)[Two ways to set up: plain Python or Anaconda]


An environment is a private shelf of Python packages for one project. Two projects can then use different versions of the same library without knocking each other over. Route~A uses Python's own `venv`; Route~B uses conda. Either works, so pick one and stick with it. If you do not already have a preference, take Route~A.

#callout("keyidea", title: [Key idea])[Use one environment per project; activate it before installing or running packages.]


#heading(level: 2)[Route A: install Python and configure PATH]


Download Python from the #link("https://www.python.org/downloads/")[#strong[official downloads page]].

/ Windows: #block[
Run the installer, enable #strong[`PATH`], and reopen the terminal. Use #strong[`py`].
]

/ macOS: #block[
Run the #strong[`.pkg` installer] and restart Terminal. Keep the #strong[system Python] unchanged.
]

/ Linux: #block[
Install #strong[Python 3] with your package manager. Do not replace the #strong[system Python].
]

#strong[Windows PATH fix.] If `py` is missing, open #strong[Edit environment variables for your account], then #strong[Path \> Edit]. Add the installer's command directory, for example:

#code-block("", lang: "text")

#strong[macOS PATH fix.] If the installer placed Python in `/usr/local/bin` but your terminal cannot find it, add that directory to your Z shell's #strong[PATH]:

#code-block("echo 'export PATH=\"/usr/local/bin:$PATH\"' >> ~/.zshrc\nsource ~/.zshrc", lang: "text")

For #strong[Debian or Ubuntu]:

#code-block("sudo apt update\nsudo apt install python3 python3-venv python3-pip", lang: "text")

#strong[Verify] the installation and executable location:

#code-block("# Windows\npy --version\npy -m pip --version\nwhere py\n\n# macOS or Linux\npython3 --version\npython3 -m pip --version\nwhich -a python3", lang: "text")


#heading(level: 2)[Route A: create an isolated virtual environment]


#strong[`venv`] keeps this project's packages separate from other projects. See the #link("https://docs.python.org/3/library/venv.html")[#strong[venv documentation]].

The root-level #strong[`requirements.txt`] lists dependencies, including PyTorch (`torch`) for Labs~7--8. A CPU is sufficient.

#code-block("numpy\npandas\nmatplotlib\nscikit-learn\njoblib\njupyter\ntorch", lang: "text")

#strong[Create] the environment in the #strong[project root]:

#code-block("# Windows\npy -m venv .venv\n\n# macOS or Linux\npython3 -m venv .venv", lang: "text")

#strong[Activate] it from the same folder:

#code-block("# Windows (PowerShell)\n.venv\\Scripts\\Activate.ps1\n\n# macOS/Linux\nsource .venv/bin/activate", lang: "text")

#strong[Install dependencies] after activation:

#code-block("# Windows\npy -m pip install --upgrade pip\npy -m pip install -r requirements.txt\n\n# macOS or Linux\npython3 -m pip install --upgrade pip\npython3 -m pip install -r requirements.txt", lang: "text")

#strong[Install once; activate every session.] Reuse #strong[`.venv`] without reinstalling unchanged requirements.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/MACHINE LEARNING/figures/diagrams/c3e80d148ffb5274.svg")], caption: [The environment routine. Creating `.venv` and installing the requirements happen once; every later session starts by activating the environment and goes straight back to the notebooks.]) <fig:venv-routine>

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/MACHINE LEARNING/figures/diagrams/abd9aac9d5348c96.svg")], caption: [Separate environments, separate packages. Each project's `.venv` holds its own copies of the libraries, and the system Python is left alone; activate the intended project environment before running `pip install`.]) <fig:venv-separate>


#heading(level: 2)[Route B: Anaconda or Miniconda]


#strong[Miniconda] supplies Python and `conda`; #strong[Anaconda] adds Navigator and preinstalled packages. Download #link("https://docs.anaconda.com/miniconda/")[#strong[Miniconda]] or #link("https://www.anaconda.com/download")[#strong[Anaconda]].

/ Windows: #block[
Use default installer options without adding conda to PATH. Open #strong[Anaconda Prompt] from Start.
]

/ macOS / Linux: #block[
Run the `.pkg` or `.sh` installer, then close and reopen the terminal. The prompt shows `(base)`, which means conda is active.
]

#strong[Create] one environment for the course, with a Python version the libraries support, then #strong[activate] it:

#code-block("conda create -n ml python=3.12\nconda activate ml", lang: "text")

#strong[Install dependencies] with the same `requirements.txt` used in Route A:

#code-block("pip install -r requirements.txt", lang: "text")

Create once, activate each session, and avoid installing into `(base)`. Check the active environment and Python:

#code-block("conda env list\npython -c \"import sys; print(sys.executable)\"", lang: "text")

#callout("pitfall", title: [Common mistake])[Avoid installing the same package with both conda and pip. Use pip with the course requirements. Recreate a broken environment with `conda env remove -n ml`, then repeat setup.]


#heading(level: 2)[Check that everything works]


Run these three commands from the course folder with your environment active. Each one tests something different, so a failure tells you where to look.

#code-block("python -c \"import numpy, pandas, matplotlib, sklearn, joblib, torch; print('Packages OK')\"\npython all_experiments/book_checks/demo_study_log.py\npython all_experiments/lab01_features/lab01_features_worked.py", lang: "text")

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Command], [You should see], [It proves],),
    table.hline(),
    [The import line], [`Packages OK`], [The environment is active and complete],
    [`demo_study_log.py`], [Last line: `Every number above matches the book.`], [NumPy reproduces the chapters' worked examples],
    [`lab01_features_worked.py`], [`raw + engineered validation ROC AUC = 0.855` among the lines], [The datasets are in place and scikit-learn works],
  )]
  , kind: table
  )


#heading(level: 2)[Start a notebook, and read its device line]


Every lab has a worked notebook. Start Jupyter from the course folder with `jupyter lab`; each notebook finds `all_datasets/` by looking upward from its own folder. Open a notebook and choose #strong[Restart Kernel and Run All Cells]. Most labs take under a minute; Labs~7 and~8 train neural networks, about four minutes each on a laptop CPU. Their Setup cell prints the Python in use and the device it picked: an NVIDIA GPU (`cuda`), an Apple GPU (`mps`), or the CPU. To reproduce the printed numbers exactly on a machine with a GPU, hide it before starting Jupyter:

#code-block("# PowerShell\n$env:CUDA_VISIBLE_DEVICES = \"-1\"\n# macOS or Linux\nexport CUDA_VISIBLE_DEVICES=-1", lang: "text")

#callout("troubleshoot", title: [Troubleshooting])[/ `Activate.ps1` cannot be loaded: #block[
Windows blocks scripts by default. Run `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` once in PowerShell, then activate again.
]

/ Conda not found on Windows: #block[
Use Anaconda Prompt, or initialize PowerShell there with `conda init powershell`.
]

/ A notebook cannot import a package: #block[
Jupyter is running from a different environment. Activate the course environment, restart Jupyter, and run `import sys; print(sys.executable)` in a cell to confirm which Python it uses.
]

/ `Invalid device id` in the Setup cell of Lab~7 or~8: #block[
You set `CUDA_VISIBLE_DEVICES` to an empty string. Use `-1`, as shown above.
]

/ `OMP: Error #15`: #block[
Two OpenMP runtimes are loaded. The Setup cells of Labs~7 and~8 set `KMP_DUPLICATE_LIB_OK`; elsewhere, set it before importing PyTorch.
]]
