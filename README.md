# UTP Teaching Assistant Labs and Course Notes

This repository collects laboratory materials, tutorial resources, implementations, and original LaTeX teaching companions from courses taught at Universiti Teknologi PETRONAS.

## Course notes

| Course | Note coverage | LaTeX entry point |
| --- | --- | --- |
| Algorithms and Data Structures | Arrays through hashing, algorithm comparison, correctness arguments, complexity models, edge-case testing, and reproducible benchmarking | [Open notes](<ALGORITHMS & DATA STRUCTURES/%23NOTES/main.tex>) |
| Artificial Intelligence | Search, fuzzy logic, ANFIS, robotics, NLP, genetic algorithms, experimental evaluation, error analysis, and responsible AI practice | [Open notes](<ARTIFICIAL INTELLIGENCE/%23NOTES/main.tex>) |
| Data Communication and Networking | Packet analysis, routing, services, switching, WAN links, layered troubleshooting, hardening, change control, and incident records | [Open notes](<DATA COMMUNICATION & NETWORKING/%23NOTES/main.tex>) |
| Data Science | R foundations, data structures, data frames, visualization, correlation, normalization, data contracts, reproducible EDA, and evidence-based communication | [Open notes](<DATA SCIENCE/%23NOTES/main.tex>) |
| Enterprise Resource Planning | Integrated processes, Odoo practice, governance, segregation of duties, master-data controls, audit trails, and process analytics | [Open notes](<ENTERPRISE RESOURCE PLANNING/%23NOTES/main.tex>) |
| FinTech Innovation | Inclusion, alternative finance, digital banking, blockchain, Big Tech, cryptocurrencies, product economics, risk governance, and operational resilience | [Open notes](<FINTECH INNOVATION/%23NOTES/main.tex>) |
| Machine Learning | Supervised, unsupervised, limited-label, and reinforcement learning, plus leakage prevention, reproducibility, subgroup evaluation, model cards, and monitoring | [Open notes](<MACHINE LEARNING/%23NOTES/main.tex>) |
| Operating Systems | Processes, scheduling, concurrency, memory, storage, security boundaries, least privilege, defensive programming, and observability | [Open notes](<OPERATING SYSTEMS/%23NOTES/main.tex>) |

Each course remains a self-contained LaTeX project. Its `main.tex` file owns the
document design and includes the course's chapters, laboratories, and appendices
from their existing folders.

## Featured notebooks

| Course | Notebook | Purpose |
| --- | --- | --- |
| Artificial Intelligence | [Search strategy comparison](<ARTIFICIAL INTELLIGENCE/Lab01/Search_Strategy_Comparison.ipynb>) | Reproducible BFS, uniform-cost, and A* comparison with path, cost, expansion, frontier, and heuristic checks |
| Artificial Intelligence | [Robotics simulation scenarios](<ARTIFICIAL INTELLIGENCE/Lab05/Lab_5_code.ipynb>) | Clean, output-free collection of eight motion, planning, control, mapping, and reinforcement-learning demonstrations |
| Data Science | [Reproducible EDA in R](<DATA SCIENCE/Lab Final Project/Reproducible_EDA.ipynb>) | Base-R final-project template for contracts, validation, cleaning logs, summaries, plots, association, and conclusions |
| Machine Learning | [Audit-ready classification](<MACHINE LEARNING/Lab10/Task02.ipynb>) | NumPy/pandas workflow for deterministic partitions, training-only preprocessing, threshold selection, subgroup checks, calibration, and a model card |

The Machine Learning course also retains its full sequence of task notebooks
across Labs 1--10. Notebook outputs are omitted where practical so that source,
not machine-specific execution state, remains canonical.

## Building the notes

From a course's `#NOTES` directory, run either of the following:

```text
latexmk -pdf -interaction=nonstopmode -halt-on-error main.tex
tectonic -X compile main.tex
```

LaTeX build products are intentionally excluded from version control. The
repository keeps the editable sources as the canonical course notes.

Run the repository-wide structural check after editing any note set:

```text
pwsh -File scripts/check-latex-notes.ps1
pwsh -File scripts/check-notebooks.ps1
```

## Disclaimer

These materials support teaching and independent study. They are not official
university publications and do not replace the current course outline,
assessment brief, or institutional policies.
