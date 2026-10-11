# Published PDFs

The compiled books, split for teaching. Every course folder has the same layout: the whole book, then one
folder per lab holding everything a student reads for that session — the chapters the lab practises, then the
lab sheet itself.

```text
<course>/
  <CODE>-Book.pdf          the whole book, every chapter and lab in teaching order
  Lab-01/                  one folder for every lab
    Chapter-01.pdf           each chapter this lab practises
    Chapter-02.pdf
    Lab-Activity.pdf         the lab sheet, the same pages as in the book
  Lab-02/ ...
  Capstone-Project.pdf     the capstone or final-project chapter, where the course has one
  Appendix-A.pdf, ...      appendices and references that follow the last lab
```

How the folders are filled:

- **A lab's chapters** are the ones between the previous lab and this one. A lab that follows straight after
  another, such as Machine Learning's Labs 7 and 8, practises the same chapter, so each folder holds its own
  copy. A lab sheet that draws on other chapters names them with `\labcovers` (Enterprise Resource Planning's
  practicals, which follow the tutorial order).
- **An unnumbered chapter before Chapter 1** is `Chapter-00.pdf`, or `Chapter-00A.pdf`, `Chapter-00B.pdf` when
  there are several (Operating Systems' two orientation chapters).
- **Part and stage divider pages** appear only in the book.

| Course | Book | What the folder holds |
| --- | --- | --- |
| [Algorithms & Data Structures](<../ALGORITHMS & DATA STRUCTURES/README.md>) | [ADS-Book.pdf](algorithms-data-structures/ADS-Book.pdf) · 98 pages | [11 lab folders and the final project](algorithms-data-structures) |
| [Artificial Intelligence](<../ARTIFICIAL INTELLIGENCE/README.md>) | [AI-Book.pdf](artificial-intelligence/AI-Book.pdf) · 93 pages | [8 lab folders](artificial-intelligence) |
| [Data Communication & Networking](<../DATA COMMUNICATION & NETWORKING/README.md>) | [DCN-Book.pdf](data-communication-networking/DCN-Book.pdf) · 91 pages | [9 lab folders, the group project and the command reference](data-communication-networking) |
| [Introduction to Data Science](<../DATA SCIENCE/README.md>) | [DS-Book.pdf](data-science/DS-Book.pdf) · 106 pages | [10 lab folders and the capstone](data-science) |
| [Enterprise Resource Planning](<../ENTERPRISE RESOURCE PLANNING/README.md>) | [ERP-Book.pdf](enterprise-resource-planning/ERP-Book.pdf) · 87 pages | [8 lab folders, the capstone and two appendices](enterprise-resource-planning) |
| [FinTech Innovation](<../FINTECH INNOVATION/README.md>) | [FI-Book.pdf](fintech-innovation/FI-Book.pdf) · 105 pages | [8 lab folders and the final revision map](fintech-innovation) |
| [Machine Learning](<../MACHINE LEARNING/README.md>) | [ML-Book.pdf](machine-learning/ML-Book.pdf) · 160 pages | [8 lab folders and the capstone](machine-learning) |
| [Operating Systems](<../OPERATING SYSTEMS/README.md>) | [OS-Book.pdf](operating-systems/OS-Book.pdf) · 86 pages | [10 lab folders and the capstone](operating-systems) |

Every file here is generated. Do not edit or re-split them by hand; rebuild instead, from the repository root:

```bash
python .shared/build.py DS        # rebuild one course's folder
python .shared/build.py           # rebuild them all
```

The script compiles the book in a temporary folder and replaces that course's folder here as a whole, so no
stale file survives a change to the book. This README is not touched. See [`.shared/README.md`](../.shared/README.md).
