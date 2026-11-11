# UTP Teaching Assistant Labs

Laboratory materials and original Typst teaching companions for courses taught at Universiti Teknologi
PETRONAS. Each course is written as a book: chapters explain the ideas, and each lab sheet comes straight after
the chapter it practises. Finished courses also ship the code every lab runs, the data it reads, and PDFs of the
whole book and of each lab session.

[YouTube playlist: installing the software for these labs](https://youtube.com/playlist?list=PLinUrn8TVRE8TakJwrFYdOsH1i1GBBdVN)

## Courses

To edit and preview the Typst books locally, open this repository root in VS Code and follow the [local Typst setup and VS Code guide](.typst-setup/README.md).

| Course | Status | Labs | Lab tools | Book | Covers |
| --- | --- | --- | --- | --- | --- |
| [Algorithms & Data Structures](<ALGORITHMS & DATA STRUCTURES/README.md>) | in development | 11 | C++ | [PDF](.all-pdfs/algorithms-data-structures/ADS-Book.pdf) | arrays through hashing, correctness arguments, complexity, edge-case testing, reproducible benchmarking |
| [Artificial Intelligence](<ARTIFICIAL INTELLIGENCE/README.md>) | **ready** | 8 | Python, Jupyter | [PDF](.all-pdfs/artificial-intelligence/AI-Book.pdf) | search, fuzzy logic and ANFIS, robotics, NLP, local search and genetic algorithms, game search, experimental evaluation |
| [Data Communication & Networking](<DATA COMMUNICATION & NETWORKING/README.md>) | in development | 9 | Wireshark, Huawei eNSP | [PDF](.all-pdfs/data-communication-networking/DCN-Book.pdf) | packet analysis, static and OSPF routing, FTP, DHCP, LACP, VLANs, WAN links |
| [Introduction to Data Science](<DATA SCIENCE/README.md>) | **ready** | 10 | R | [PDF](.all-pdfs/data-science/DS-Book.pdf) | data quality, wrangling, EDA, visualization, inference, regression, classification, validation, clustering and PCA |
| [Enterprise Resource Planning](<ENTERPRISE RESOURCE PLANNING/README.md>) | in development | 8 | Odoo 19 Community | [PDF](.all-pdfs/enterprise-resource-planning/ERP-Book.pdf) | business processes, sales and CRM, production and supply chain, accounting, HR, process modelling |
| [FinTech Innovation](<FINTECH INNOVATION/README.md>) | in development | 8 | Python | [PDF](.all-pdfs/fintech-innovation/FI-Book.pdf) | inclusion, P2P and crowdfunding, digital banking, blockchain, Big Tech, cryptocurrencies |
| [Machine Learning](<MACHINE LEARNING/README.md>) | **ready** | 8 | Python, Jupyter, PyTorch | [PDF](.all-pdfs/machine-learning/ML-Book.pdf) | supervised, unsupervised, limited-label and reinforcement learning, neural networks, CNNs and LSTMs |
| [Operating Systems](<OPERATING SYSTEMS/README.md>) | **ready** | 10 | C and Bash on Linux/WSL | [PDF](.all-pdfs/operating-systems/OS-Book.pdf) | processes, scheduling, concurrency, memory, file systems |

Each course name opens that course's guide: its lab table, what to read before each lab, how to run the code, and
its folder map. Book PDFs are generated on demand with steps 03–04 into `.all-pdfs/<course>/<CODE>-Book.pdf`; step 05 adds chapter/lab PDFs and manifests. **Ready** courses are complete; courses **in development** are usable
but still being reviewed, and their guide lists anything that remains.

## Working through a lab

1. **Open the course guide** and find the lab in its table.
2. **Read the chapters first.** The lab's own folder in [`.all-pdfs/`](.all-pdfs) holds the chapters it practises,
   then the lab sheet. The same pages are in the book.
3. **Run the code.** The course guide gives the setup once and the command for each lab. The code in the book and
   the code in the course folder are the same code.

## Published PDFs

Every course has the same layout in [`.all-pdfs/`](.all-pdfs), built by `.typst-setup/scripts/publish.py` and never edited by
hand:

```text
.all-pdfs/<course>/
  <CODE>-Book.pdf          the whole book
  Lab-01/                  one folder per lab
    Chapter-01.pdf           each chapter the lab practises
    Lab-Activity.pdf         the lab sheet
  Lab-02/ ...
  Capstone-Project.pdf     the capstone or final project, where the course has one
  Appendix-A.pdf, ...      appendices and references after the last lab
```

Each published course includes `manifest.json` with its actual page ranges and chapter coverage. The PDF links above become available after publication.

## How a course is organised

Every course folder uses the same names, and holds only that course's content:

```text
<COURSE>/
  README.md          the course guide
  main.typ           the book: configuration and the chapter list
  chapters/          one .typ per chapter, plus course-map.typ
  labs/              one .typ per lab sheet
  appendices/        reference material printed after the labs           (some courses)
  figures/           images the book includes                            (some courses)
  all_datasets/      the data the labs read; treat it as read-only       (some courses)
  all_experiments/   the code each lab runs: notebooks, scripts, sources (some courses)
  results/           evidence the lab code writes, one folder per lab    (some courses)
  models/            trained models the labs save                        (some courses)
  requirements.txt   Python packages for the lab code                    (Python courses)
  0.from_lecturer/   the lecturer's slides, tutorials and manuals        (some courses)
```

## Repository layout

```text
.typst-setup/      numbered Windows/shell setup and build steps
.shared/
  typst/          shared book components, cover and palette
  templates/      starter files for new courses
  assets/         bundled fonts, licenses and logos
  packages/       pinned diagram dependencies and licenses
  docs/           style, authoring and maintenance guides
.all-pdfs/        published books, lab PDFs and page manifests
.engine/          optional Typst-based lecture-video tooling
<COURSE>/         main.typ, chapters, labs, figures, code and data
```

See the [setup guide](.typst-setup/README.md) for live preview, numbered scripts, and portability. To add a course, start with [course template](.shared/templates/course/main.typ) and the [checklist](.shared/docs/adding-a-course.md).

## Video subtitles

See the [CrisperWhisper setup](.subtitle-setup/README.md) for an isolated CUDA environment, numbered scripts, and resumable SRT generation beside media in `.courses/`.

## Disclaimer

These materials support teaching and independent study. They are not official university publications and do not replace the current course outline, assessment brief, or institutional policies.
