#import "/.shared/typst/utp.typ": *
#unit("chapters", "00-toolkit")


#heading(level: 1)[Tools for the FinTech Practicals]
 <ch:toolkit>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Set up Python and the supporting tools used throughout the practicals.

*By the end, you can:* Install the required libraries, prepare the lab files, and run the examples on your computer.]


#heading(level: 2)[Two ways to set up: plain Python or Anaconda]


#callout("keyidea", title: [Key idea])[Choose one installation route and keep the FinTech lab packages in its course environment.]


#heading(level: 2)[Route A: install and verify Python]


Download a supported Python release from the #link("https://www.python.org/downloads/")[#strong[official downloads page]].

/ Windows: #block[
Install Python and keep the Python launcher selected. Use #strong[`py`] to run it; a manual PATH change is usually unnecessary.
]

/ macOS: #block[
Use the official installer or your approved package manager. Run Python with #strong[`python3`] and leave the system Python unchanged.
]

/ Linux: #block[
Install Python~3 with your distribution's package manager. Include `python3-venv` and `python3-pip` if using Route~A; do not replace the system Python.
]

#strong[Windows command check.] If `py` is not recognised, reopen the terminal and check that the Python launcher was installed. Use the official installer to repair the installation rather than adding a guessed folder to PATH:

#code-block("py --version\npy -0p", lang: "text")

#strong[macOS command check.] After installing, reopen Terminal. If `python3` is still unavailable, consult the installer instructions instead of adding a hard-coded directory to your shell configuration:

#code-block("python3 --version\ncommand -v python3", lang: "text")

For #strong[Debian or Ubuntu]:

#code-block("sudo apt update\nsudo apt install python3 python3-venv python3-pip", lang: "text")

#strong[Verify] the installation and executable location:

#code-block("# Windows\npy --version\npy -m pip --version\nwhere py\n\n# macOS or Linux\npython3 --version\npython3 -m pip --version\nwhich -a python3", lang: "text")


#heading(level: 2)[Route A: create an isolated lab environment]


#strong[`venv`] keeps course packages separate from other Python projects. See the #link("https://docs.python.org/3/library/venv.html")[#strong[venv documentation]].

The FinTech labs need only these third-party Python packages; Lab~6 and the other standard-library exercises require no additional packages:

#code-block("pandas\nnumpy", lang: "text")

Create the environment in the folder where you will keep the course scripts and data files:

#code-block("# Windows\npy -m venv .venv\n\n# macOS or Linux\npython3 -m venv .venv", lang: "text")

#strong[Activate] it from that folder:

#code-block("# Windows (PowerShell)\n.\\.venv\\Scripts\\Activate.ps1\n\n# macOS or Linux\nsource .venv/bin/activate", lang: "text")

#strong[Install dependencies] after activation:

#code-block("python -m pip install --upgrade pip\npython -m pip install pandas numpy", lang: "text")

#strong[Install once; activate every session.] Reuse #strong[`.venv`] without reinstalling packages that have not changed. No course-specific `requirements.txt` is included in the current repository.

The supporting scripts and CSV files are supplied separately by the instructor or course bundle. Keep each script beside its input data and run it from that folder. For example:

#code-block("python unbundling_scorecard.py value_chain.csv", lang: "text")

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/FINTECH INNOVATION/figures/diagrams/e00d9d099ecde45d.svg")], caption: [Create the course environment and install pandas and NumPy once. For each practical session, activate it before running a lab script or working through the code in the lab sheet.]) <fig:venv-routine>

#callout("keyidea", title: [Key idea])[#strong[Activate first, then install.] Run the course scripts with the same Python environment that contains `pandas` and `NumPy`.]

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/FINTECH INNOVATION/figures/diagrams/9dd228e108ae9094.svg")], caption: [Keep the FinTech lab packages isolated from the operating system and from other projects. This environment needs only `pandas` and `NumPy`; built-in modules such as `hashlib` are already included with Python.]) <fig:venv-separate>


#heading(level: 2)[Route B: Anaconda or Miniconda]


Anaconda or Miniconda is an alternative way to install Python and manage the course packages; it is not required by the labs. Download #link("https://docs.anaconda.com/miniconda/")[#strong[Miniconda]] or #link("https://www.anaconda.com/download")[#strong[Anaconda]].

/ Windows: #block[
Use the installer defaults and open Anaconda Prompt from Start when installation is complete.
]

/ macOS / Linux: #block[
Follow the installer instructions, reopen the terminal, and confirm that `conda` is available.
]

#strong[Create] one environment for the course, then #strong[activate] it:

#code-block("conda create -n fintech python=3.12\nconda activate fintech", lang: "text")

#strong[Install the course packages] into the active environment:

#code-block("conda install pandas numpy", lang: "text")

Create the environment once and activate it for each session. Check the active environment and confirm the libraries are available:

#code-block("conda env list\npython -c \"import sys; print(sys.executable)\"\npython -c \"import pandas, numpy; print('Packages ready')\"", lang: "text")

#callout("pitfall", title: [Common mistake])[Install packages into the `fintech` environment, not `(base)`. For this route, use `conda install` rather than mixing package managers. If the environment is unusable, remove `fintech` with `conda env remove -n fintech` and recreate it.]

#callout("troubleshoot", title: [Troubleshooting])[#strong[Conda not found on Windows:] open Anaconda Prompt and check the installation there. #strong[A lab cannot import pandas or NumPy:] activate `fintech`, check that the active Python belongs to that environment, then install the packages there.]
