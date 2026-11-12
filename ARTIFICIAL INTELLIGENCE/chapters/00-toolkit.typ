#import "/.shared/typst/utp.typ": *
#unit("chapters", "00-toolkit")

= Your Toolkit and Environment Setup <ch:toolkit>

#chapterguide[Create folders and run basic #strong[terminal commands].][organize data and notebooks, configure an environment, install dependencies, check that everything works, and run labs reproducibly.]

Every lab in this course runs from the same folder, in the same Python environment. Twenty minutes spent here saves hours of chasing path errors later.

== The course project layout

Your project root is the course folder. In this repository it is called `ARTIFICIAL INTELLIGENCE/`; name your own copy without spaces, for example `UTP-ARTIFICIAL-INTELLIGENCE/`. It holds these folders:

#strong[Datasets]

```terminal
all_datasets/
  lab01-03_airports.csv
  lab01-03_routes.csv
  lab04-AirQuality.csv
  lab05-sensor_readings_24.csv
  lab06-ocr-handwritten-prescription.zip
  lab07-Tweets.csv
  lab08-insurance.csv
```

#strong[Experiments, helper code, and generated evidence]

```terminal
all_experiments/
  lab01_search_foundations_worked.ipynb        one notebook per lab, each with a .py twin
  lab02_informed_search_worked.ipynb
  lab03_search_engineering_worked.ipynb
  lab04_fuzzy_anfis_worked.ipynb
  lab05_robotics_sensor_control_worked.ipynb
  lab06_handwriting_ocr_worked.ipynb
  lab07_airline_sentiment_worked.ipynb
  lab08_genetic_algorithm_regression_worked.ipynb
  demo_robot_maze.py                           the maze of Chapters 2-4
  demo_sliding_puzzle.py                       the 8-puzzle of Chapters 2-3
  demo_local_search.py                         eight queens and beam search, Chapters 9-10
  demo_game_search.py                          noughts and crosses, Chapter 11
  utils/
    core.py
    openflights.py
    plotting.py
    __main__.py
    test_search.py
    search_queries.csv
results/
  lab01/ ... lab08/
requirements.txt
```

#keyidea[
  The notebooks import reusable search code from `utils/`. Each notebook writes its evidence to `results/`, which should not be edited by hand; `requirements.txt` lists the packages installed in `.venv/`. The `demo_` scripts need no dataset and print every number the chapters quote for the maze, puzzle and game examples.
]

== The datasets

Check `all_datasets/` first. If your copy of the course already holds the seven files listed above, skip to the next section. Otherwise click a #strong[dataset name] below to download it, extract the archive, and save the file under the name in the third column. The notebooks look for exactly those names.

#utptable[
  #fsize("footnote")[

  #tabularx(
    columns: (36%, 7%, 1fr),
    align: (left, center, left),
    header: ([Kaggle dataset], [Lab], [Save in `all_datasets/` as]),
    [#strong[OpenFlights:] #link("https://www.kaggle.com/datasets/open-flights/flight-route-database")[#strong[Routes]] & #link("https://www.kaggle.com/datasets/open-flights/airports-train-stations-and-ferry-terminals/data")[#strong[Airports]]], [1--3], [`lab01-03_routes.csv`, `lab01-03_airports.csv`],
    [#link("https://www.kaggle.com/datasets/fedesoriano/air-quality-data-set")[#strong[Air Quality]]], [4], [`lab04-AirQuality.csv`],
    [#link("https://www.kaggle.com/datasets/uciml/wall-following-robot")[#strong[Wall-Following Robot]] (24 sensors)], [5], [`lab05-sensor_readings_24.csv`],
    [#link("https://www.kaggle.com/datasets/mrdude20/doctor-handwriting-recognition-dataset")[#strong[Doctor Handwriting]]], [6], [`lab06-ocr-handwritten-prescription.zip`, kept zipped],
    [#link("https://www.kaggle.com/datasets/chandana890/twitter-airline-sentiment-dataset")[#strong[Twitter Airline Sentiment]]], [7], [`lab07-Tweets.csv`],
    [#link("https://www.kaggle.com/datasets/mirichoi0218/insurance")[#strong[Medical Cost]]], [8], [`lab08-insurance.csv`],
  )

  ]
]

#pitfall[
  For #strong[`FileNotFoundError`], check the working directory and the filename, including capitals. Fix the path or the name rather than moving files into the project root.
]

== Two ways to set up: plain Python or Anaconda

#analogy[
  A #term[virtual environment] is a separate toolbox for one project. Install a new wrench in this project’s box and every other project’s box stays exactly as it was, so a package you upgrade for one course cannot quietly break another.
]

#keyidea[
  Use one environment per project, and activate it before installing or running packages. Follow Route~A or Route~B below, not both.
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

The root-level #strong[`requirements.txt`] lists the dependencies. A CPU is sufficient for every lab, and no lab needs a GPU.

```terminal
numpy
pandas
matplotlib
scipy
scikit-learn
pillow
pytesseract
pytest
jupyter
```

#strong[Create] the environment in the #strong[project root]:

```terminal
# Windows
py -m venv .venv

# macOS or Linux
python3 -m venv .venv
```

#strong[Activate] it from the same folder. Your prompt then starts with `(.venv)`:

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
    let pygo = (line-width: widths.thick, draw: teal, end: tip("Stealth", length: 2.2mm, line: widths.thick))
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

#keyidea[
  #strong[Activate first, then install.] Keep course packages inside the #strong[project environment], not in a shared global installation.
]

#utpfig([Separate environments, separate packages. Each project’s `.venv` holds its own copies of the libraries, and the system Python is left alone; activate the intended project environment before running `pip install`.], label: <fig:venv-separate>)[
  #canvas({
    let envbox = (draw: blue, fill: pale-blue, rounded: 1.9925pt, align: center, inner-sep: 3.9851pt, min-width: 4.3)
    let sysbox = (draw: muted, fill: pale-gray, rounded: 1.9925pt, align: center, inner-sep: 3.9851pt, min-width: 4.3)
    let pkg = (font: font("script", family: "mono"), align: center)
    let lbl = (font: font("script", fill: muted), align: center)
    let hit = (line-width: widths.thick, draw: teal, end: tip("Stealth", length: 2.2mm, line: widths.thick))
    node((0, 2.45), [system Python], name: "sys", font: font("small"), ..sysbox)
    node((2.35, 2.45), [leave this alone], font: font("small"), ..pkg, text: muted, anchor: "west")
    node((-2.8, 0), [`this course/.venv`], name: "a", font: font("small"), ..envbox)
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
conda create -n ai python=3.12
conda activate ai
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

#pitfall[
  Avoid installing the same package with both conda and pip. Use pip with the course requirements. Recreate a broken environment with `conda env remove -n ai`, then repeat setup.
]

== Check that everything works

Run these three commands from the course folder with your environment active. Each one tests something different, so a failure tells you where to look.

```terminal
python -c "import numpy, pandas, scipy, sklearn, matplotlib, PIL, pytest; print('Packages OK')"
python all_experiments/demo_robot_maze.py
python -m pytest all_experiments/utils -q
```

#utptable[
  #tabularx(
    columns: (24%, 36%, 1fr),
    styles: (navy-bold,),
    header: ([Command], [You should see], [It proves]),
    [The import line], [`Packages OK`], [The environment is active and complete],
    [`demo_robot_maze.py`], [Last line: `Every number above matches the book.`], [Your copy of the search code behaves as the book describes],
    [`pytest`], [`8 passed`], [The eight search tests pass on your machine],
  )
]

Lab~6 also needs the Tesseract OCR engine, which is not a Python package. Its lab sheet gives the install command for each system. Everything else needs only `requirements.txt`.

#troubleshoot[
  / `Activate.ps1` cannot be loaded: Windows blocks scripts by default. Run `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` once in PowerShell, then activate again.
  / Conda not found on Windows: Use Anaconda Prompt, or initialize PowerShell there with `conda init powershell`.
  / A notebook cannot import a package: Jupyter is running from a different environment. Activate the course environment, restart Jupyter, and run `import sys; print(sys.executable)` in a cell to confirm which Python it uses.
  / `No module named utils`: Start Jupyter from `all_experiments/`, or run the `.py` files from the course folder as shown on each lab sheet.
]
