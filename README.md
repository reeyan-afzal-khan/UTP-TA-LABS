# UTP Teaching Assistant Labs and Course Notes

This repository collects laboratory materials, tutorial resources, implementations, and original LaTeX teaching companions from courses taught at Universiti Teknologi PETRONAS.
[YouTube playlist for software installation for these labs](https://youtube.com/playlist?list=PLinUrn8TVRE8TakJwrFYdOsH1i1GBBdVN)

## Course notes

| Course | Note coverage |
| --- | --- |
| [Algorithms and Data Structures](<ALGORITHMS & DATA STRUCTURES/_NOTES/main.tex>) | Arrays through hashing, algorithm comparison, correctness arguments, complexity models, edge-case testing, and reproducible benchmarking |
| [Artificial Intelligence](<ARTIFICIAL INTELLIGENCE/_NOTES/main.tex>) | Search, fuzzy logic, ANFIS, robotics, NLP, genetic algorithms, experimental evaluation, error analysis, and responsible AI practice |
| [Data Communication and Networking](<DATA COMMUNICATION & NETWORKING/_NOTES/main.tex>) | Packet analysis, routing, services, switching, WAN links, layered troubleshooting, hardening, change control, and incident records |
| [Data Science](<DATA SCIENCE/_NOTES/main.tex>) | R foundations, data structures, data frames, visualization, correlation, normalization, data contracts, reproducible EDA, and evidence-based communication |
| [Enterprise Resource Planning](<ENTERPRISE RESOURCE PLANNING/_NOTES/main.tex>) | Integrated processes, Odoo practice, governance, segregation of duties, master-data controls, audit trails, and process analytics |
| [FinTech Innovation](<FINTECH INNOVATION/_NOTES/main.tex>) | Inclusion, alternative finance, digital banking, blockchain, Big Tech, cryptocurrencies, product economics, risk governance, and operational resilience |
| [Machine Learning](<MACHINE LEARNING/_NOTES/main.tex>) | Supervised, unsupervised, limited-label, and reinforcement learning, plus leakage prevention, reproducibility, subgroup evaluation, model cards, and monitoring |
| [Operating Systems](<OPERATING SYSTEMS/_NOTES/main.tex>) | Processes, scheduling, concurrency, memory, storage, security boundaries, least privilege, defensive programming, and observability |

Each course remains a self-contained LaTeX project. Its `main.tex` file owns the document design and includes the course's chapters, laboratories, and appendices from their existing folders.

## Building the notes

Each book compiles with any TeX distribution (tested on MiKTeX). Run three
passes so the table of contents and cross-references settle:

```bash
cd "OPERATING SYSTEMS/_NOTES" && pdflatex -interaction=nonstopmode main.tex
```

## Running the labs

| Course | Language | How to run |
| --- | --- | --- |
| Algorithms and Data Structures | C++17 | `g++ -std=c++17 -Wall -Wextra Task01.cpp -o task01 && ./task01` |
| Operating Systems | C (POSIX), Bash | `gcc -Wall -Wextra -pthread Task01.c -o task01` — needs Linux or WSL. Lab 9 also needs freeglut: add `-lglut -lGLU -lGL -lm` |
| Data Science | R | `Rscript Task01.R` — the input-driven scripts also work under RStudio |
| Machine Learning | Python (Jupyter) | open the notebook, or `jupyter nbconvert --execute Task01.ipynb` |
| Artificial Intelligence | Python (Labs 1–3), MATLAB (Labs 4–8) | `py search_uninformed.py`; MATLAB parts need the Fuzzy Logic and Text Analytics toolboxes |
| FinTech Innovation | Python | `py inclusion_analysis.py`; regenerate the synthetic data with `tools/generate_datasets.py` |
| Enterprise Resource Planning | Python + Odoo 19 | Build each lab in the Odoo browser interface, then prove it: `py check_setup.py --password ...`. Master data imports from the supplied CSVs. See [the ERP README](<ENTERPRISE RESOURCE PLANNING/README.md>) |
| Data Communication and Networking | Huawei VRP (eNSP) | paste the `.txt` configs one block at a time; `Lab04/wildcard_calc.py` is a helper |

Python labs need `pandas`, `numpy`, `matplotlib`, and `scikit-learn`; the R
labs need `dplyr` for Lab 7 only.

## Disclaimer

These materials support teaching and independent study. They are not official university publications and do not replace the current course outline, assessment brief, or institutional policies.
