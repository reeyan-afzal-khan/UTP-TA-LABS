#import "/.shared/typst/utp.typ": *
#unit("chapters", "00-toolkit")

= Tools for the FinTech Practicals <ch:toolkit>

#chapterguide[Set up Python and the supporting tools used throughout the practicals.][Install the required libraries, prepare the lab files, and run the examples on your computer.]

== Two ways to set up: plain Python or Anaconda

#keyidea[
  Choose one installation route and keep the FinTech lab packages in its course environment.
]

== Route A: install and verify Python

Download a supported Python release from the
#link("https://www.python.org/downloads/")[#strong[official downloads page]].

#describe-nextline(1.15in)[
  / Windows: Install Python and keep the Python launcher selected. Use
    #strong[`py`] to run it; a manual PATH change is usually unnecessary.
  / macOS: Use the official installer or your approved package manager.
    Run Python with #strong[`python3`] and leave the system Python unchanged.
  / Linux: Install Python~3 with your distribution’s package manager.
    Include `python3-venv` and `python3-pip` if using Route~A;
    do not replace the system Python.
]

#strong[Windows command check.] If `py` is not recognised, reopen the
terminal and check that the Python launcher was installed. Use the official
installer to repair the installation rather than adding a guessed folder to PATH:

```terminal
py --version
py -0p
```

#strong[macOS command check.] After installing, reopen Terminal. If
`python3` is still unavailable, consult the installer instructions
instead of adding a hard-coded directory to your shell configuration:

```terminal
python3 --version
command -v python3
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

== Route A: create an isolated lab environment

#strong[`venv`] keeps course packages separate from other Python
projects. See the #link("https://docs.python.org/3/library/venv.html")[#strong[venv documentation]].

The FinTech labs need only these third-party Python packages; Lab~6 and the
other standard-library exercises require no additional packages:

```terminal
pandas
numpy
```

Create the environment in the folder where you will keep the course scripts
and data files:

```terminal
# Windows
py -m venv .venv

# macOS or Linux
python3 -m venv .venv
```

#strong[Activate] it from that folder:

```terminal
# Windows (PowerShell)
.\.venv\Scripts\Activate.ps1

# macOS or Linux
source .venv/bin/activate
```

#strong[Install dependencies] after activation:

```terminal
python -m pip install --upgrade pip
python -m pip install pandas numpy
```

#strong[Install once; activate every session.] Reuse #strong[`.venv`]
without reinstalling packages that have not changed. No course-specific
`requirements.txt` is included in the current repository.

The supporting scripts and CSV files are supplied separately by the
instructor or course bundle. Keep each script beside its input data and run it
from that folder. For example:

```terminal
python unbundling_scorecard.py value_chain.csv
```

#utpfig([Create the course environment and install pandas and NumPy once. For each practical session, activate it before running a lab script or working through the code in the lab sheet.], label: <fig:venv-routine>)[
  #canvas({
    let pystep = (draw: blue, fill: white, rounded: 1.9925pt, align: center, inner-sep: 3.9851pt, min-width: 3.3, min-height: 1.05, font: font("script", fill: navy, family: "mono"))
    let pyonce = (..pystep, fill: pale-blue)
    let pyevery = (..pystep, fill: pale-teal, draw: teal)
    let pycap = (font: font("script", weight: "bold", fill: muted),)
    let pynote = (font: font("script", fill: muted), align: center)
    let pygo = (line-width: widths.thick, draw: teal, end: tip("Stealth", length: 2.2mm, line: widths.thick))
    node((0, 0), [create .venv], name: "venv", font: font("small"), ..pyonce)
    node((4.05, 0), [activate], name: "act", font: font("small"), ..pyevery)
    node((8.1, 0), [install pandas \
  and NumPy], name: "inst", font: font("small"), ..pyonce)
    node((12.15, 0), [run lab scripts \
  and exercises], name: "work", font: font("small"), ..pyevery)
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
  #strong[Activate first, then install.] Run the course scripts with the same
  Python environment that contains `pandas` and `NumPy`.
]

#utpfig([Keep the FinTech lab packages isolated from the operating system and from other projects. This environment needs only `pandas` and `NumPy`; built-in modules such as `hashlib` are already included with Python.], label: <fig:venv-separate>)[
  #canvas({
    let envbox = (draw: blue, fill: pale-blue, rounded: 1.9925pt, align: center, inner-sep: 3.9851pt, min-width: 4.3)
    let sysbox = (draw: muted, fill: pale-gray, rounded: 1.9925pt, align: center, inner-sep: 3.9851pt, min-width: 4.3)
    let pkg = (font: font("script", family: "mono"), align: center)
    let lbl = (font: font("script", fill: muted), align: center)
    let hit = (line-width: widths.thick, draw: teal, end: tip("Stealth", length: 2.2mm, line: widths.thick))
    node((0, 2.45), [system Python], name: "sys", font: font("small"), ..sysbox)
    node((2.35, 2.45), [leave this alone], font: font("small"), ..pkg, text: muted, anchor: "west")
    node((-2.8, 0), [`FinTech labs/.venv`], name: "a", font: font("small"), ..envbox)
    node((-2.8, -0.52), [pandas \
  NumPy], font: font("small"), ..pkg, anchor: "north")
    node((2.8, 0), [`another project/.venv`], name: "b", font: font("small"), ..envbox)
    node((2.8, -0.52), [its own versions \
  of the same names], font: font("small"), ..pkg, anchor: "north")
    connect("sys", "a", ..hit)
    connect("sys", "b", ..hit)
  })
]

== Route B: Anaconda or Miniconda

Anaconda or Miniconda is an alternative way to install Python and manage the
course packages; it is not required by the labs. Download
#link("https://docs.anaconda.com/miniconda/")[#strong[Miniconda]] or
#link("https://www.anaconda.com/download")[#strong[Anaconda]].

#describe-nextline(1.15in)[
  / Windows: Use the installer defaults and open Anaconda Prompt from
    Start when installation is complete.
  / macOS / Linux: Follow the installer instructions, reopen the
    terminal, and confirm that `conda` is available.
]

#strong[Create] one environment for the course, then #strong[activate] it:

```terminal
conda create -n fintech python=3.12
conda activate fintech
```

#strong[Install the course packages] into the active environment:

```terminal
conda install pandas numpy
```

Create the environment once and activate it for each session. Check the
active environment and confirm the libraries are available:

```terminal
conda env list
python -c "import sys; print(sys.executable)"
python -c "import pandas, numpy; print('Packages ready')"
```

#pitfall[
  Install packages into the `fintech` environment, not `(base)`.
  For this route, use `conda install` rather than mixing package
  managers. If the environment is unusable, remove `fintech` with
  `conda env remove -n fintech` and recreate it.
]

#troubleshoot[
  #strong[Conda not found on Windows:] open Anaconda Prompt and check the
  installation there. #strong[A lab cannot import pandas or NumPy:] activate
  `fintech`, check that the active Python belongs to that environment, then install the packages there.
]
