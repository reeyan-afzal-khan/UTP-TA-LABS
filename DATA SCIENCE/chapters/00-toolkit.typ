#import "/.shared/typst/utp.typ": *
#unit("chapters", "00-toolkit")

= Your Toolkit and Environment Setup <ch:toolkit>

#chapterguide[Basic familiarity with files and folders is enough; no previous R installation is assumed.][install R and RStudio, optionally manage R through Anaconda/conda, configure Git and GitHub with SSH, create a reproducible course project, verify the software stack, and understand the datasets used throughout the course.]

== What you are installing---and why

The course uses #strong[R] as the statistical computing engine and #strong[RStudio] as the main integrated development environment (IDE). These are related but separate pieces of software. R performs the computation; RStudio provides an editor, console, data viewer, plotting pane, help system, project management, and an integrated terminal.

#utpfig([R computes, RStudio provides the working environment, and the operating system supports both. Git records changes to course code; pushing shares committed changes with the GitHub repository.], label: <fig:r-stack>)[
  #canvas({
    let layer-style = (draw: mix(blue, 70%), fill: pale-blue, rounded: 1.5mm, line-width: 0.6974pt, text-width: 0.9 * 16.06, min-height: 1.4, inner-xsep: 3.5mm, inner-ysep: 3mm, align: left, font: font("normal", fill: navy))
    let flow = (line-width: 0.797pt, draw: teal, end: tip("Stealth", length: 2mm, width: 1.5mm, line: 0.797pt))
    node((0, 0), [#strong[Course project --- files and evidence] \ #v(2.9888pt)
   `all_datasets/`, and `all_experiments/`], name: "project", ..layer-style)
    node(below-of("project", 0.35), [#strong[RStudio Desktop --- working environment] \ #v(2.9888pt)
   Edit scripts; use the console, plots, help, and project tools], name: "studio", ..layer-style, draw: mix(teal, 80%), fill: pale-teal)
    node(below-of("studio", 0.35), [#strong[R --- computation engine] \ #v(2.9888pt)
   Work with data, fit statistical models, and create graphics], name: "r", ..layer-style)
    node(below-of("r", 0.35), [#strong[Operating system --- platform] \ #v(2.9888pt)
   Windows, macOS, or Linux], name: "os", ..layer-style, draw: mix(muted, 70%), fill: pale-gray)
    node(below-of("os", 0.35), [#strong[Git and GitHub --- version and share code] \ #v(2.9888pt)
   Commit reviewed changes, then push to the remote repository.], name: "git", ..layer-style, draw: mix(orange, 80%), fill: pale-orange)
    connect("project.south", "studio.north", ..flow)
    connect("studio.south", "r.north", ..flow)
    connect("r.south", "os.north", ..flow)
    connect("os.south", "git.north", ..flow, dash: "dashed")
  })
]

#keyidea[
  Install #strong[R first], then install #strong[RStudio]. RStudio does not replace R; it discovers and launches an installed R version.
]

== Course project layout

Use `UTP-DATA-SCIENCE/` as the project root, with these folders:

#box(width: 49%)[
  ```terminal
  all_datasets/
    ames_housing_dataset.csv
    bike_sharing_dataset_day.csv
    bike_sharing_dataset_hour.csv
    breast_cancer_dataset.csv
    credit_card_fraud_dataset.csv
    heart_failure_dataset.csv
    mall_customers_dataset.csv
    medical_cost_personal_dataset.csv
    optical_recognition_handwritten_digits.zip
    red_wine_quality_dataset.csv
    student_performance_dataset.csv
    titanic_dataset.csv
  ```
]#h(1fr)#box(width: 49%)[
  ```terminal
  all_experiments/
    lab01_workflow.R
    lab02_data_quality.R
    lab03_wrangling.R
    lab04_eda.R
    lab05_visualization.R
    lab06_inference.R
    lab07_regression.R
    lab08_classification.R
    lab09_validation.R
    lab10_unsupervised.R
  ```
]

== Route A---recommended: install R natively

For most students, the simplest and most reliable setup is a native installation of R from the #link("https://cran.r-project.org/")[#strong[Comprehensive R Archive Network (CRAN)]] followed by RStudio Desktop from #link("https://posit.co/download/rstudio-desktop/")[#strong[Posit]].

=== Windows

#utpsteps[
  + Open the #link("https://cran.r-project.org/")[CRAN home page], select #strong[Download R for Windows], then choose #strong[base].
  + Download the current stable Windows installer and run it. The default 64-bit installation is suitable for this course.
  + Keep the default components unless your institution provides different instructions.
  + After installation, open the Windows Start menu and confirm that an #strong[R] entry exists.
]

From a terminal, installation can be verified with:

```terminal
R --version
```

If the terminal cannot find `R` but R opens normally from the Start menu, the installation itself may still be correct. RStudio can discover standard Windows installations without requiring students to edit the system PATH manually.

=== macOS

#utpsteps[
  + Open the #link("https://cran.r-project.org/")[CRAN home page] and select #strong[Download R for macOS].
  + Choose the installer that matches the machine architecture. Recent Apple Silicon Macs use the ARM64 build; older Intel Macs use the Intel build.
  + Open the downloaded `.pkg` and follow the installer prompts.
  + Close and reopen Terminal after installation, then verify R.
]

```terminal
R --version
which R
```

=== Linux

Linux installation differs by distribution. Use the distribution-specific instructions under #strong[Download R for Linux] on CRAN. On Debian/Ubuntu systems, a basic repository installation is commonly performed with:

```terminal
sudo apt update
sudo apt install r-base
```

Institutional machines may use a managed repository or module system instead. The objective is the same: the command below should start a current R session.

```terminal
R
```

Exit the interactive R console with `q()` and answer `n` if asked whether to save the workspace.

== Install RStudio Desktop

RStudio Desktop is available from #link("https://posit.co/download/rstudio-desktop/")[#strong[Posit’s RStudio Desktop download page]]. Posit’s current documentation states that RStudio requires an existing R installation, which is why R is installed first.

#describe-nextline(1.25in)[
  / Windows: Download the stable `.exe`, run the installer, and launch RStudio from the Start menu.
  / macOS: Download the stable `.dmg`, open it, and drag RStudio to #strong[Applications].
  / Linux: Download the package matching the supported distribution, such as `.deb` for Ubuntu/Debian or `.rpm` for Fedora/RHEL-family systems, then install it with the system package manager.
]

#utpfig([The exact pane arrangement can be changed, but the distinction between source code and the console should remain clear. Saved scripts are the reproducible record; console commands are temporary unless copied into a script.], label: <fig:rstudio-layout>)[
  #canvas(x: 16.06cm, {
    let pane = (draw: mix(blue, 70%), fill: pale-blue, rounded: 1.5mm, line-width: 0.6974pt, text-width: 0.39 * 16.06, min-height: 1.85, inner-xsep: 3mm, inner-ysep: 2mm, align: left, font: font("footnote", fill: navy))
    node((0, 0), [#strong[Source editor] \ #v(4.9813pt)
   Write and save `.R` scripts. \
   Run selected lines or the whole file.], name: "source", ..pane)
    node((0.49, 0), [#strong[Environment / History] \ #v(4.9813pt)
   Inspect objects in memory. \
   Review earlier console commands.], name: "env", ..pane, draw: mix(muted, 70%), fill: pale-gray)
    node((0, -2.15), [#strong[Console] \ #v(4.9813pt)
   Execute R commands. \
   Read printed output and errors.], name: "console", ..pane, draw: mix(teal, 80%), fill: pale-teal)
    node((0.49, -2.15), [#strong[Files / Plots / Packages / Help] \ #v(4.9813pt)
   Browse files and manage packages. \
   View figures and documentation.], name: "tools", ..pane)
  })
]

=== Verify that RStudio is using R

Open RStudio and run these commands in the Console:

```r
R.version.string
R.home()
getwd()
```

The first two lines identify the R installation. The working directory should eventually be the supplied `DATA SCIENCE/` folder once the course project is opened.

== Installing R packages

The core lab scripts are deliberately written so that they can run with base R on a standard installation. Additional packages are valuable for larger projects, publication graphics, reshaping, and reporting.

Packages from CRAN are installed once and loaded in each new R session when needed:

```r
install.packages(c("ggplot2", "dplyr", "tidyr", "readr", "broom"))

library(ggplot2)
library(dplyr)
```

#utpfig([Package installation writes software to an R library on the computer. `library()` attaches an installed package to the current R session.], label: <fig:r-packages>)[
  #canvas({
    node((0, 0), [CRAN package repository], name: "cran", ..fcbox, text-width: 3.8)
    node(right-of("cran", 1.1), [Computer’s R library \
  `install.packages()` once], name: "lib", ..fcbox, text-width: 4.2)
    node(right-of("lib", 1.1), [Current R session \
  `library()` when needed], name: "session", ..fcbox, text-width: 4.2, fill: pale-teal, draw: teal)
    connect("cran", "lib", ..fcedge)
    connect("lib", "session", ..fcedge)
  })
]

== Route B---optional: Anaconda or Miniconda with R

Some students already work in environments managed by `conda`. This is a valid optional route, especially when a broader workflow combines multiple languages or command-line tools. However, #strong[native R + RStudio is the recommended course setup] because it has the fewest moving parts.

Download #link("https://www.anaconda.com/download")[#strong[Anaconda Distribution]] or follow the #link("https://docs.conda.io/projects/conda/en/stable/user-guide/install/")[#strong[conda installation guide]] for Miniconda.

#referencebox[
  #strong[Current R channel note.] Anaconda announced that it no longer maintains its own R channel. For current R packages inside conda environments, Anaconda directs users toward #strong[conda-forge] or a native CRAN installation. For this reason, the commands below request R explicitly from conda-forge rather than relying on Anaconda’s legacy R packages.
]

Create a course-specific environment rather than installing project software into `base`:

```terminal
conda create -n ds-r conda-forge::r-base conda-forge::r-tidyverse
conda activate ds-r
R --version
R
```

Inside the R session, verify the environment’s R installation:

```r
R.version.string
R.home()
q()
```

Use the same environment on later sessions:

```terminal
conda activate ds-r
R
```

#pitfall[
  Do not mix several installation strategies casually. A machine can contain a native CRAN R, a conda R, and multiple package libraries at the same time. When troubleshooting, first determine which executable is active with `where R` on Windows or `which -a R` on macOS/Linux, then check `R.home()` inside R.
]

=== RStudio with a conda-managed R

RStudio normally discovers standard system installations of R. A conda-managed R lives inside an environment-specific directory, so discovery can be less automatic and varies by operating system. Students who require both RStudio and conda should confirm which R instance RStudio launches by checking `R.home()` and compare it with the R executable shown by the activated conda environment.

For this course, if RStudio is using the native CRAN R while the terminal uses conda R, choose one route for course work and stay consistent. Reproducibility improves when all labs use the same interpreter and package library.
