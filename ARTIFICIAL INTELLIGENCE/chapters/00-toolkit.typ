#import "/.shared/typst/utp.typ": *
#unit("chapters", "00-toolkit")


#heading(level: 1)[Your Toolkit and Environment Setup]
 <ch:toolkit>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Create folders and run basic #strong[terminal commands].

*By the end, you can:* organize data and notebooks, configure an environment, install dependencies, check that everything works, and run labs reproducibly.]

Every lab in this course runs from the same folder, in the same Python environment. Twenty minutes spent here saves hours of chasing path errors later.


#heading(level: 2)[The course project layout]


Your project root is the course folder. In this repository it is called `ARTIFICIAL INTELLIGENCE/`; name your own copy without spaces, for example `UTP-ARTIFICIAL-INTELLIGENCE/`. It holds these folders:

#strong[Datasets] #code-block("all_datasets/\n  lab01-03_airports.csv\n  lab01-03_routes.csv\n  lab04-AirQuality.csv\n  lab05-sensor_readings_24.csv\n  lab06-ocr-handwritten-prescription.zip\n  lab07-Tweets.csv\n  lab08-insurance.csv", lang: "text")

#strong[Experiments, helper code, and generated evidence] #code-block("all_experiments/\n  lab01_search_foundations_worked.ipynb        one notebook per lab, each with a .py twin\n  lab02_informed_search_worked.ipynb\n  lab03_search_engineering_worked.ipynb\n  lab04_fuzzy_anfis_worked.ipynb\n  lab05_robotics_sensor_control_worked.ipynb\n  lab06_handwriting_ocr_worked.ipynb\n  lab07_airline_sentiment_worked.ipynb\n  lab08_genetic_algorithm_regression_worked.ipynb\n  demo_robot_maze.py                           the maze of Chapters 2-4\n  demo_sliding_puzzle.py                       the 8-puzzle of Chapters 2-3\n  demo_local_search.py                         eight queens and beam search, Chapters 9-10\n  demo_game_search.py                          noughts and crosses, Chapter 11\n  utils/\n    core.py\n    openflights.py\n    plotting.py\n    __main__.py\n    test_search.py\n    search_queries.csv\nresults/\n  lab01/ ... lab08/\nrequirements.txt", lang: "text")

#callout("keyidea", title: [Key idea])[The notebooks import reusable search code from `utils/`. Each notebook writes its evidence to `results/`, which should not be edited by hand; `requirements.txt` lists the packages installed in `.venv/`. The `demo_` scripts need no dataset and print every number the chapters quote for the maze, puzzle and game examples.]


#heading(level: 2)[The datasets]


Check `all_datasets/` first. If your copy of the course already holds the seven files listed above, skip to the next section. Otherwise click a #strong[dataset name] below to download it, extract the archive, and save the file under the name in the third column. The notebooks look for exactly those names.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Kaggle dataset], [Lab], [Save in `all_datasets/` as],),
    table.hline(),
    [#strong[OpenFlights:] #link("https://www.kaggle.com/datasets/open-flights/flight-route-database")[#strong[Routes]] & #link("https://www.kaggle.com/datasets/open-flights/airports-train-stations-and-ferry-terminals/data")[#strong[Airports]]], [1--3], [`lab01-03_routes.csv`, `lab01-03_airports.csv`],
    [#link("https://www.kaggle.com/datasets/fedesoriano/air-quality-data-set")[#strong[Air Quality]]], [4], [`lab04-AirQuality.csv`],
    [#link("https://www.kaggle.com/datasets/uciml/wall-following-robot")[#strong[Wall-Following Robot]] (24 sensors)], [5], [`lab05-sensor_readings_24.csv`],
    [#link("https://www.kaggle.com/datasets/mrdude20/doctor-handwriting-recognition-dataset")[#strong[Doctor Handwriting]]], [6], [`lab06-ocr-handwritten-prescription.zip`, kept zipped],
    [#link("https://www.kaggle.com/datasets/chandana890/twitter-airline-sentiment-dataset")[#strong[Twitter Airline Sentiment]]], [7], [`lab07-Tweets.csv`],
    [#link("https://www.kaggle.com/datasets/mirichoi0218/insurance")[#strong[Medical Cost]]], [8], [`lab08-insurance.csv`],
  )]
  , kind: table
  )

#callout("pitfall", title: [Common mistake])[For #strong[`FileNotFoundError`], check the working directory and the filename, including capitals. Fix the path or the name rather than moving files into the project root.]


#heading(level: 2)[Two ways to set up: plain Python or Anaconda]


#callout("analogy", title: [Analogy])[A #strong[virtual environment] is a separate toolbox for one project. Install a new wrench in this project's box and every other project's box stays exactly as it was, so a package you upgrade for one course cannot quietly break another.]

#callout("keyidea", title: [Key idea])[Use one environment per project, and activate it before installing or running packages. Follow Route~A or Route~B below, not both.]


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

The root-level #strong[`requirements.txt`] lists the dependencies. A CPU is sufficient for every lab, and no lab needs a GPU.

#code-block("numpy\npandas\nmatplotlib\nscipy\nscikit-learn\npillow\npytesseract\npytest\njupyter", lang: "text")

#strong[Create] the environment in the #strong[project root]:

#code-block("# Windows\npy -m venv .venv\n\n# macOS or Linux\npython3 -m venv .venv", lang: "text")

#strong[Activate] it from the same folder. Your prompt then starts with `(.venv)`:

#code-block("# Windows (PowerShell)\n.venv\\Scripts\\Activate.ps1\n\n# macOS/Linux\nsource .venv/bin/activate", lang: "text")

#strong[Install dependencies] after activation:

#code-block("# Windows\npy -m pip install --upgrade pip\npy -m pip install -r requirements.txt\n\n# macOS or Linux\npython3 -m pip install --upgrade pip\npython3 -m pip install -r requirements.txt", lang: "text")

#strong[Install once; activate every session.] Reuse #strong[`.venv`] without reinstalling unchanged requirements.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ARTIFICIAL INTELLIGENCE/figures/diagrams/c3e80d148ffb5274.svg")], caption: [The environment routine. Creating `.venv` and installing the requirements happen once; every later session starts by activating the environment and goes straight back to the notebooks.]) <fig:venv-routine>

#callout("keyidea", title: [Key idea])[#strong[Activate first, then install.] Keep course packages inside the #strong[project environment], not in a shared global installation.]

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ARTIFICIAL INTELLIGENCE/figures/diagrams/5e5d816615b49c8a.svg")], caption: [Separate environments, separate packages. Each project's `.venv` holds its own copies of the libraries, and the system Python is left alone; activate the intended project environment before running `pip install`.]) <fig:venv-separate>


#heading(level: 2)[Route B: Anaconda or Miniconda]


#strong[Miniconda] supplies Python and `conda`; #strong[Anaconda] adds Navigator and preinstalled packages. Download #link("https://docs.anaconda.com/miniconda/")[#strong[Miniconda]] or #link("https://www.anaconda.com/download")[#strong[Anaconda]].

/ Windows: #block[
Use default installer options without adding conda to PATH. Open #strong[Anaconda Prompt] from Start.
]

/ macOS / Linux: #block[
Run the `.pkg` or `.sh` installer, then close and reopen the terminal. The prompt shows `(base)`, which means conda is active.
]

#strong[Create] one environment for the course, with a Python version the libraries support, then #strong[activate] it:

#code-block("conda create -n ai python=3.12\nconda activate ai", lang: "text")

#strong[Install dependencies] with the same `requirements.txt` used in Route A:

#code-block("pip install -r requirements.txt", lang: "text")

Create once, activate each session, and avoid installing into `(base)`. Check the active environment and Python:

#code-block("conda env list\npython -c \"import sys; print(sys.executable)\"", lang: "text")

#callout("pitfall", title: [Common mistake])[Avoid installing the same package with both conda and pip. Use pip with the course requirements. Recreate a broken environment with `conda env remove -n ai`, then repeat setup.]


#heading(level: 2)[Check that everything works]


Run these three commands from the course folder with your environment active. Each one tests something different, so a failure tells you where to look.

#code-block("python -c \"import numpy, pandas, scipy, sklearn, matplotlib, PIL, pytest; print('Packages OK')\"\npython all_experiments/demo_robot_maze.py\npython -m pytest all_experiments/utils -q", lang: "text")

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Command], [You should see], [It proves],),
    table.hline(),
    [The import line], [`Packages OK`], [The environment is active and complete],
    [`demo_robot_maze.py`], [Last line: `Every number above matches the book.`], [Your copy of the search code behaves as the book describes],
    [`pytest`], [`8 passed`], [The eight search tests pass on your machine],
  )]
  , kind: table
  )

Lab~6 also needs the Tesseract OCR engine, which is not a Python package. Its lab sheet gives the install command for each system. Everything else needs only `requirements.txt`.

#callout("troubleshoot", title: [Troubleshooting])[/ `Activate.ps1` cannot be loaded: #block[
Windows blocks scripts by default. Run `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` once in PowerShell, then activate again.
]

/ Conda not found on Windows: #block[
Use Anaconda Prompt, or initialize PowerShell there with `conda init powershell`.
]

/ A notebook cannot import a package: #block[
Jupyter is running from a different environment. Activate the course environment, restart Jupyter, and run `import sys; print(sys.executable)` in a cell to confirm which Python it uses.
]

/ `No module named utils`: #block[
Start Jupyter from `all_experiments/`, or run the `.py` files from the course folder as shown on each lab sheet.
]]
