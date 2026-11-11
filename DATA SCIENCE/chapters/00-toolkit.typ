#import "/.shared/typst/utp.typ": *
#unit("chapters", "00-toolkit")


#heading(level: 1)[Your Toolkit and Environment Setup]
 <ch:toolkit>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Basic familiarity with files and folders is enough; no previous R installation is assumed.

*By the end, you can:* install R and RStudio, optionally manage R through Anaconda/conda, configure Git and GitHub with SSH, create a reproducible course project, verify the software stack, and understand the datasets used throughout the course.]


#heading(level: 2)[What you are installing---and why]


The course uses #strong[R] as the statistical computing engine and #strong[RStudio] as the main integrated development environment (IDE). These are related but separate pieces of software. R performs the computation; RStudio provides an editor, console, data viewer, plotting pane, help system, project management, and an integrated terminal.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/DATA SCIENCE/figures/diagrams/6880d31edbc01d76.svg")], caption: [R computes, RStudio provides the working environment, and the operating system supports both. Git records changes to course code; pushing shares committed changes with the GitHub repository.]) <fig:r-stack>

#callout("keyidea", title: [Key idea])[Install #strong[R first], then install #strong[RStudio]. RStudio does not replace R; it discovers and launches an installed R version.]


#heading(level: 2)[Course project layout]
 Use `UTP-DATA-SCIENCE/` as the project root, with these folders:

#block[
#code-block("all_datasets/\n  ames_housing_dataset.csv\n  bike_sharing_dataset_day.csv\n  bike_sharing_dataset_hour.csv\n  breast_cancer_dataset.csv\n  credit_card_fraud_dataset.csv\n  heart_failure_dataset.csv\n  mall_customers_dataset.csv\n  medical_cost_personal_dataset.csv\n  optical_recognition_handwritten_digits.zip\n  red_wine_quality_dataset.csv\n  student_performance_dataset.csv\n  titanic_dataset.csv", lang: "text")

]
#block[
#code-block("all_experiments/\n  lab01_workflow.R\n  lab02_data_quality.R\n  lab03_wrangling.R\n  lab04_eda.R\n  lab05_visualization.R\n  lab06_inference.R\n  lab07_regression.R\n  lab08_classification.R\n  lab09_validation.R\n  lab10_unsupervised.R", lang: "text")

]

#heading(level: 2)[Route A---recommended: install R natively]


For most students, the simplest and most reliable setup is a native installation of R from the #link("https://cran.r-project.org/")[#strong[Comprehensive R Archive Network (CRAN)]] followed by RStudio Desktop from #link("https://posit.co/download/rstudio-desktop/")[#strong[Posit]].


#heading(level: 3)[Windows]


+ Open the #link("https://cran.r-project.org/")[CRAN home page], select #strong[Download R for Windows], then choose #strong[base].

+ Download the current stable Windows installer and run it. The default 64-bit installation is suitable for this course.

+ Keep the default components unless your institution provides different instructions.

+ After installation, open the Windows Start menu and confirm that an #strong[R] entry exists.

From a terminal, installation can be verified with:

#code-block("R --version", lang: "text")

If the terminal cannot find `R` but R opens normally from the Start menu, the installation itself may still be correct. RStudio can discover standard Windows installations without requiring students to edit the system PATH manually.


#heading(level: 3)[macOS]


+ Open the #link("https://cran.r-project.org/")[CRAN home page] and select #strong[Download R for macOS].

+ Choose the installer that matches the machine architecture. Recent Apple Silicon Macs use the ARM64 build; older Intel Macs use the Intel build.

+ Open the downloaded `.pkg` and follow the installer prompts.

+ Close and reopen Terminal after installation, then verify R.

#code-block("R --version\nwhich R", lang: "text")


#heading(level: 3)[Linux]


Linux installation differs by distribution. Use the distribution-specific instructions under #strong[Download R for Linux] on CRAN. On Debian/Ubuntu systems, a basic repository installation is commonly performed with:

#code-block("sudo apt update\nsudo apt install r-base", lang: "text")

Institutional machines may use a managed repository or module system instead. The objective is the same: the command below should start a current R session.

#code-block("R", lang: "text")

Exit the interactive R console with `q()` and answer `n` if asked whether to save the workspace.


#heading(level: 2)[Install RStudio Desktop]


RStudio Desktop is available from #link("https://posit.co/download/rstudio-desktop/")[#strong[Posit's RStudio Desktop download page]]. Posit's current documentation states that RStudio requires an existing R installation, which is why R is installed first.

/ Windows: #block[
Download the stable `.exe`, run the installer, and launch RStudio from the Start menu.
]

/ macOS: #block[
Download the stable `.dmg`, open it, and drag RStudio to #strong[Applications].
]

/ Linux: #block[
Download the package matching the supported distribution, such as `.deb` for Ubuntu/Debian or `.rpm` for Fedora/RHEL-family systems, then install it with the system package manager.
]

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/DATA SCIENCE/figures/diagrams/0ee24921a3d4c714.svg")], caption: [The exact pane arrangement can be changed, but the distinction between source code and the console should remain clear. Saved scripts are the reproducible record; console commands are temporary unless copied into a script.]) <fig:rstudio-layout>


#heading(level: 3)[Verify that RStudio is using R]


Open RStudio and run these commands in the Console:

#code-block("R.version.string\nR.home()\ngetwd()", lang: "r")

The first two lines identify the R installation. The working directory should eventually be the supplied `DATA SCIENCE/` folder once the course project is opened.


#heading(level: 2)[Installing R packages]


The core lab scripts are deliberately written so that they can run with base R on a standard installation. Additional packages are valuable for larger projects, publication graphics, reshaping, and reporting.

Packages from CRAN are installed once and loaded in each new R session when needed:

#code-block("install.packages(c(\"ggplot2\", \"dplyr\", \"tidyr\", \"readr\", \"broom\"))\n\nlibrary(ggplot2)\nlibrary(dplyr)", lang: "r")

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/DATA SCIENCE/figures/diagrams/2d22286b58f37caa.svg")], caption: [Package installation writes software to an R library on the computer. `library()` attaches an installed package to the current R session.]) <fig:r-packages>


#heading(level: 2)[Route B---optional: Anaconda or Miniconda with R]


Some students already work in environments managed by `conda`. This is a valid optional route, especially when a broader workflow combines multiple languages or command-line tools. However, #strong[native R + RStudio is the recommended course setup] because it has the fewest moving parts.

Download #link("https://www.anaconda.com/download")[#strong[Anaconda Distribution]] or follow the #link("https://docs.conda.io/projects/conda/en/stable/user-guide/install/")[#strong[conda installation guide]] for Miniconda.

#callout("referencebox", title: [Reference note])[#strong[Current R channel note.] Anaconda announced that it no longer maintains its own R channel. For current R packages inside conda environments, Anaconda directs users toward #strong[conda-forge] or a native CRAN installation. For this reason, the commands below request R explicitly from conda-forge rather than relying on Anaconda's legacy R packages.]

Create a course-specific environment rather than installing project software into `base`:

#code-block("conda create -n ds-r conda-forge::r-base conda-forge::r-tidyverse\nconda activate ds-r\nR --version\nR", lang: "text")

Inside the R session, verify the environment's R installation:

#code-block("R.version.string\nR.home()\nq()", lang: "r")

Use the same environment on later sessions:

#code-block("conda activate ds-r\nR", lang: "text")

#callout("pitfall", title: [Analytical pitfall])[Do not mix several installation strategies casually. A machine can contain a native CRAN R, a conda R, and multiple package libraries at the same time. When troubleshooting, first determine which executable is active with `where R` on Windows or `which -a R` on macOS/Linux, then check `R.home()` inside R.]


#heading(level: 3)[RStudio with a conda-managed R]


RStudio normally discovers standard system installations of R. A conda-managed R lives inside an environment-specific directory, so discovery can be less automatic and varies by operating system. Students who require both RStudio and conda should confirm which R instance RStudio launches by checking `R.home()` and compare it with the R executable shown by the activated conda environment.

For this course, if RStudio is using the native CRAN R while the terminal uses conda R, choose one route for course work and stay consistent. Reproducibility improves when all labs use the same interpreter and package library.
