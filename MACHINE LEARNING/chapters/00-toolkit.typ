#import "/.shared/typst/utp.typ": *
#unit("chapters", "00-toolkit")

= Your Toolkit and Environment Setup <ch:toolkit>

#chapterguide[Create folders and run basic #strong[terminal commands].][organize data and notebooks, configure an environment, install dependencies, check that everything works, and run labs reproducibly.]

Every lab in this course runs from the same folder, in the same Python environment. Twenty minutes spent here saves hours of chasing path errors later.

== The course project layout

Your project root is the course folder. In this repository it is called `MACHINE LEARNING/`; name your own copy without spaces, for example `UTP-MACHINE-LEARNING/`, because spaces in paths cause avoidable trouble in terminals. Inside it you will find:

#box(width: 47%)[
  ```terminal
  all_datasets/       one folder per dataset
    README.md         the index
    supervised/       the answer is known
      bank_marketing/
      heart_disease/
      hotel_bookings/ hotel_bookings.zip,
                      README.md
      lending_club/
      sms_spam/
      telco_customer_churn/
      used_cars/
    unsupervised/     find structure
      creditcard_fraud_ulb/
      online_retail_ii/
      wood_surface_defects/
    advanced/         few labels, sequences
      banking77/
      electricity_load/
  ```
]#h(1fr)#box(width: 51%)[
  ```terminal
  all_experiments/           one folder per lab:
    course_setup.py          the setup every lab shares
    lab00_data_toolkit_eda/  notebook, .py twin, README
    lab01_features/
    lab02_supervised_workflow/ (+ predict_churn.py)
    lab03_supervised_models/
    lab04_clustering_pca/
    lab05_anomaly_limited_labels/
    lab06_reinforcement/
    lab07_deep_learning_cnn/
    lab08_deep_learning_lstm/
    lab09_learning_from_text/
    lab10_end_to_end_project/ (+ booking_project/)
    book_checks/             demo_*.py, one for each
                             group of chapters, and
                             check_your_turn.py
  models/   results/lab00/ ... lab10/
  requirements.txt
  ```
]

#fsize("footnote")[Every dataset folder holds its file and a README, its data card: source, licence, columns and quirks. Keep the ZIP files zipped: pandas reads the CSV inside each one. Every lab folder holds one worked notebook, a `.py` twin that runs the same code, and a README naming its data, outputs and run time; each starts with `course_setup.py`, which finds the course folder. `predict_churn.py` uses the model saved in Lab~2, and `booking_project/` is Lab~10’s project as a small package with tests, a web service and a page. Notebooks write models and cards to `models/` and evidence to `results/`; do not edit generated outputs by hand. The `book_checks/` scripts print every worked number in the chapters and check it with an assert.

]

== The datasets

The course folder ships with all twelve datasets, so there is nothing to download. `all_datasets/` groups them by how the course learns from them: `supervised/` for tables whose answer is known, `unsupervised/` for data where the labs look for structure without the answer, and `advanced/` for few labels, text and sequences. Several datasets return in later chapters and labs, so each one’s quirks become familiar. Every dataset is public and real, and each serves a lab where its quirks teach something. Click a #strong[dataset name] to read its documentation and licence; each dataset’s README records how its file was made from the source.

#utptable[
  #fsize("footnote")[

  #tabularx(
    columns: (40%, 1fr),
    header: ([Dataset], [Where the labs and chapters use it]),
    [#link("https://www.kaggle.com/datasets/fedesoriano/heart-failure-prediction")[Heart Disease]], [Lab~0: a first look at a table and a first model; Chapters 7 and 8: exploration and tests],
    [#link("https://huggingface.co/datasets/gemuchu/hotel_bookings")[Hotel Booking Demand]], [Lab~1: data card, features, leakage; Lab~2: date-order validation, overbooking threshold; Lab~10 and Chapters 32--33: the end-to-end project],
    [#link("https://huggingface.co/datasets/scikit-learn/churn-prediction")[Telco Customer Churn]], [Lab~1: repairing types, scaling and neighbors; Lab~2: tuning and a saved model; Chapter 28: training deep networks],
    [#link("https://huggingface.co/datasets/MLLab-TS/bank_marketing")[Bank Marketing]], [Lab~1: prediction timing, feature selection, leakage],
    [#link("https://huggingface.co/datasets/KTHESAT/usa-used-car-market-cars-com")[Used Cars (Cars.com)]], [Lab~2: linear regression on messy listings; Lab~3: forests and boosting],
    [#link("https://huggingface.co/datasets/codesignal/lending-club-loan-accepted")[Lending Club Loans]], [Lab~3: KNN, naive Bayes, trees, SVMs; Chapter 19: feature selection],
    [#link("https://huggingface.co/datasets/codesignal/sms-spam-collection")[SMS Spam Collection]], [Lab~3 Try-it: text classification; Lab~9 and Chapter 31: a spam filter],
    [#link("https://huggingface.co/datasets/attik/Online-Retail-II-UCI")[Online Retail II]], [Lab~4: customer segments with $K$-means and DBSCAN; Chapter 24: recommender systems],
    [#link("https://huggingface.co/datasets/iluvvatar/wood_surface_defects")[Wood Surface Defects]], [Lab~4: PCA; Lab~7 and Chapter 29: dense networks and CNNs],
    [#link("https://huggingface.co/datasets/David-Egea/Creditcard-fraud-detection")[Credit Card Fraud (ULB)]], [Lab~5: anomaly detection, imbalanced evaluation],
    [#link("https://huggingface.co/datasets/PolyAI/banking77")[Banking77]], [Lab~5: self-training and active learning; Lab~9 and Chapter 31: intents, search and word vectors],
    [#link("https://huggingface.co/datasets/sxj1024/electricity_load_2011_2014")[Electricity Load Diagrams 2011--2014]], [Lab~8 and Chapter 30: recurrent networks and attention for forecasting],
  )

  ]
]

=== If a file is missing

#utpsteps[
  + Copy it again from the course repository into #strong[its folder] in `all_datasets/`, keeping its #strong[exact name], including capitalization.
  + Keep #strong[ZIP files zipped]: the notebooks read them in place.
  + Run the notebook from inside the course folder: it finds `all_datasets/` by looking upward from where it runs.
]

#warning[
  For #strong[`FileNotFoundError`], check the working directory and filename. Fix the path rather than moving files into the project root.
]

== Two ways to set up: plain Python or Anaconda

An environment is a private shelf of Python packages for one project. Two projects can then use different versions of the same library without knocking each other over. Route~A uses Python’s own `venv`; Route~B uses conda. Either works, so pick one and stick with it. If you do not already have a preference, take Route~A.

#note[
  Use one environment per project; activate it before installing or running packages.
]

== Route A: install Python and configure PATH

Download Python from the #link("https://www.python.org/downloads/")[#strong[official downloads page]].

#describe-nextline(1.15in)[
  / Windows: Run the installer, enable #strong[`PATH`], and reopen the terminal. Use #strong[`py`].
  / macOS: Run the #strong[`.pkg` installer] and restart Terminal. Keep the #strong[system Python] unchanged.
  / Linux: Install #strong[Python 3] with your package manager. Do not replace the #strong[system Python].
]

#strong[Windows PATH fix.] If `py` is missing, open #strong[Edit environment variables for your account], then #strong[Path \> Edit]. Add the installer’s command directory, for example:

```terminal
%LocalAppData%\Python\bin
```

#strong[macOS PATH fix.] If the installer placed Python in `/usr/local/bin` but your terminal cannot find it, add that directory to your Z shell’s #strong[PATH]:

```terminal
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

For #strong[Debian or Ubuntu]:

```terminal
sudo apt update
sudo apt install python3 python3-venv python3-pip
```

#strong[Verify] the installation and executable location:

```terminal
# Windows
py --version
py -m pip --version
where py

# macOS or Linux
python3 --version
python3 -m pip --version
which -a python3
```

== Route A: create an isolated virtual environment

#strong[`venv`] keeps this project’s packages separate from other projects. See the #link("https://docs.python.org/3/library/venv.html")[#strong[venv documentation]].

The root-level #strong[`requirements.txt`] lists dependencies: PyTorch (`torch`) for the networks of Labs~7--8, `flask` and `streamlit` for the web service and page of Lab~10, and `nltk` for one word-stemming experiment in Chapter 31. A CPU is sufficient.

```terminal
numpy
pandas
matplotlib
scikit-learn
joblib
jupyter
torch
nltk
flask
streamlit
```

#strong[Create] the environment in the #strong[project root]:

```terminal
# Windows
py -m venv .venv

# macOS or Linux
python3 -m venv .venv
```

#strong[Activate] it from the same folder:

```terminal
# Windows (PowerShell)
.venv\Scripts\Activate.ps1

# macOS/Linux
source .venv/bin/activate
```

#strong[Install dependencies] after activation:

```terminal
# Windows
py -m pip install --upgrade pip
py -m pip install -r requirements.txt

# macOS or Linux
python3 -m pip install --upgrade pip
python3 -m pip install -r requirements.txt
```

#strong[Install once; activate every session.] Reuse #strong[`.venv`] without reinstalling unchanged requirements.

#utpfig([The environment routine. Creating `.venv` and installing the requirements happen once; every later session starts by activating the environment and goes straight back to the notebooks.], label: <fig:venv-routine>)[
  #canvas({
    let pystep = (draw: blue, fill: white, rounded: 1.9925pt, align: center, inner-sep: 3.9851pt, min-width: 3.3, min-height: 1.05, font: font("script", fill: navy, family: "mono"))
    let pyonce = (..pystep, fill: pale-blue)
    let pyevery = (..pystep, fill: pale-teal, draw: teal)
    let pycap = (font: font("script", weight: "bold", fill: muted),)
    let pynote = (font: font("script", fill: muted), align: center)
    let pygo = (line-width: widths.thick, draw: teal, end: arrow-tip("Stealth", length: 2.2mm, line: widths.thick))
    node((0, 0), [py -m venv .venv], name: "venv", font: font("small"), ..pyonce)
    node((4.05, 0), [activate], name: "act", font: font("small"), ..pyevery)
    node((8.1, 0), [pip install -r \
  requirements.txt], name: "inst", font: font("small"), ..pyonce)
    node((12.15, 0), [run notebooks in \
  all\_experiments/], name: "work", font: font("small"), ..pyevery)
    connect("venv", "act", ..pygo)
    connect("act", "inst", ..pygo)
    connect("inst", "work", ..pygo)
    node((0, 0.92), [once per project], font: font("small"), ..pycap)
    node((4.05, 0.92), [every session], font: font("small"), ..pycap)
    node((8.1, 0.92), [once], font: font("small"), ..pycap)
    node((12.15, 0.92), [every session], font: font("small"), ..pycap)
    connect("work.south", (rel: (0, -0.85), to: "work.south"), "-|", "act.south", ..pygo, draw: orange)
    node((8.1, -1.15), [next session: #strong[reactivate], do not reinstall], font: font("small"), ..pynote, text: orange)
  })
]

#utpfig([Separate environments, separate packages. Each project’s `.venv` holds its own copies of the libraries, and the system Python is left alone; activate the intended project environment before running `pip install`.], label: <fig:venv-separate>)[
  #canvas({
    let envbox = (draw: blue, fill: pale-blue, rounded: 1.9925pt, align: center, inner-sep: 3.9851pt, min-width: 4.3)
    let sysbox = (draw: muted, fill: pale-gray, rounded: 1.9925pt, align: center, inner-sep: 3.9851pt, min-width: 4.3)
    let pkg = (font: font("script", family: "mono"), align: center)
    let lbl = (font: font("script", fill: muted), align: center)
    let hit = (line-width: widths.thick, draw: teal, end: arrow-tip("Stealth", length: 2.2mm, line: widths.thick))
    node((0, 1.75), [system Python], name: "sys", font: font("small"), ..sysbox)
    node((2.35, 1.75), [leave this alone], font: font("small"), ..pkg, text: muted, anchor: "west")
    node((-2.8, 0), [`THIS DIRECTORY/.venv`], name: "a", font: font("small"), ..envbox)
    node((-2.8, -0.52), [numpy \
  pandas \
  scikit-learn \
  jupyter], font: font("small"), ..pkg, anchor: "north")
    node((2.8, 0), [`some other project/.venv`], name: "b", font: font("small"), ..envbox)
    node((2.8, -0.52), [its own versions \
  of the same names], font: font("small"), ..pkg, anchor: "north")
    connect("sys", "a", ..hit)
    connect("sys", "b", ..hit)
  })
]

== Route B: Anaconda or Miniconda

#strong[Miniconda] supplies Python and `conda`; #strong[Anaconda] adds Navigator and preinstalled packages. Download #link("https://docs.anaconda.com/miniconda/")[#strong[Miniconda]] or #link("https://www.anaconda.com/download")[#strong[Anaconda]].

#describe-nextline(1.15in)[
  / Windows: Use default installer options without adding conda to PATH. Open #strong[Anaconda Prompt] from Start.
  / macOS / Linux: Run the `.pkg` or `.sh` installer, then close and reopen the terminal. The prompt shows `(base)`, which means conda is active.
]

#strong[Create] one environment for the course, with a Python version the libraries support, then #strong[activate] it:

```terminal
conda create -n ml python=3.12
conda activate ml
```

#strong[Install dependencies] with the same `requirements.txt` used in Route A:

```terminal
pip install -r requirements.txt
```

Create once, activate each session, and avoid installing into `(base)`. Check the active environment and Python:

```terminal
conda env list
python -c "import sys; print(sys.executable)"
```

#warning[
  Avoid installing the same package with both conda and pip. Use pip with the course requirements. Recreate a broken environment with `conda env remove -n ml`, then repeat setup.
]

== Check that everything works

Run these three commands from the course folder with your environment active. Each one tests something different, so a failure tells you where to look.

```terminal
python -c "import numpy, pandas, matplotlib, sklearn, joblib, torch; print('Packages OK')"
python all_experiments/book_checks/demo_study_log.py
python all_experiments/lab01_features/lab01_features_worked.py
```

#utptable[
  #tabularx(
    columns: (31%, 33%, 1fr),
    styles: (navy-bold,),
    header: ([Command], [You should see], [It proves]),
    [The import line], [`Packages OK`], [The environment is active and complete],
    [`demo_study_log.py`], [Last line: `Every number above matches the book.`], [NumPy reproduces the chapters’ worked examples],
    [`lab01_features_worked.py`], [`raw + engineered validation ROC AUC = 0.855` among the lines], [The datasets are in place and scikit-learn works],
  )
]

=== The scripts that check the book

`demo_study_log.py` is one of sixteen scripts in `book_checks/`. Every number in a chapter’s text, tables and figures is printed by one of them and checked by an assert, so you can rerun any of them and watch the same numbers appear. Each ends with the line `Every number above matches the book.`

#utptable[
  #fsize("footnote")[

  #tabularx(
    columns: (24%, 1.25fr, 24%, 0.85fr),
    header: ([Script], [Checks], [Script], [Checks]),
    [`demo_study_log.py`], [Chapters 2, 5, 13, 14, 21, 22], [`demo_advanced.py`], [Chapters 26, 27, 29, 30],
    [`demo_data_toolkit.py`], [Chapter 3], [`demo_deep_training.py`], [Chapter 28],
    [`demo_foundations.py`], [Chapters 4, 6, 10--13], [`demo_cnn.py`], [Chapter 29],
    [`demo_exploration.py`], [Chapters 7--9], [`demo_sequence.py`], [Chapter 30],
    [`demo_model_families.py`], [Chapters 14--18, Lab~3], [`demo_text.py`], [Chapter 31],
    [`demo_selection.py`], [Chapter 19], [`demo_project.py`], [Chapter 32],
    [`demo_unsupervised.py`], [Chapters 20--23, 25, Lab~5], [`demo_serving.py`], [Chapter 33],
    [`demo_recommenders.py`], [Chapter 24], [`check_your_turn.py`], [Your-turn tasks],
  )

  ]
]

== Start a notebook, and read its device line

Every lab has a worked notebook. Start Jupyter from the course folder with `jupyter lab`; each notebook finds `all_datasets/` by looking upward from its own folder. Open a notebook and choose #strong[Restart Kernel and Run All Cells]. Most labs take under a minute, Labs~3 and~10 about two; Labs~7 and~8 train neural networks, about four minutes each on a laptop CPU. Their Setup cell prints the Python in use and the device it picked: an NVIDIA GPU (`cuda`), an Apple GPU (`mps`), or the CPU. To reproduce the printed numbers exactly on a machine with a GPU, hide it before starting Jupyter:

```terminal
# PowerShell
$env:CUDA_VISIBLE_DEVICES = "-1"
# macOS or Linux
export CUDA_VISIBLE_DEVICES=-1
```

#tip[
  / `Activate.ps1` cannot be loaded: Windows blocks scripts by default. Run `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` once in PowerShell, then activate again.
  / Conda not found on Windows: Use Anaconda Prompt, or initialize PowerShell there with `conda init powershell`.
  / A notebook cannot import a package: Jupyter is running from a different environment. Activate the course environment, restart Jupyter, and run `import sys; print(sys.executable)` in a cell to confirm which Python it uses.
  / `Invalid device id` in the Setup cell of Lab~7 or~8: You set `CUDA_VISIBLE_DEVICES` to an empty string. Use `-1`, as shown above.
  / `OMP: Error #15`: Two OpenMP runtimes are loaded. The Setup cells of Labs~7 and~8 set `KMP_DUPLICATE_LIB_OK`; elsewhere, set it before importing PyTorch.
]
