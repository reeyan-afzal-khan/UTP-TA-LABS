# Enterprise Resource Planning

**Status: in development.** The book, all eight practicals, and their PDFs are in place; the course is still
being reviewed before it is marked ready.

ERP concepts and business processes, practised end to end in Odoo 19 Community Edition on one running case, West
End Bicycles. Ten chapters in four stages cover business processes, ERP development, sales and CRM, production
planning, forecasting and S&OP, supply chain and MRP, accounting, HR, and process modelling. Eight integrated Odoo
practicals, a capstone and two appendices follow.

**[Book (PDF, 87 pages)](../.all_pdfs/enterprise-resource-planning/ERP-Book.pdf)** ·
[Lab bundles](../.all_pdfs/enterprise-resource-planning) ·
[Odoo quick reference (Appendix A)](../.all_pdfs/enterprise-resource-planning/Appendix-A.pdf) ·
[LaTeX source](main.tex) ·
[Lecturer materials](0.from_lecturer) ·
[All courses](../README.md)

## Stages

| Stage | Chapters | Starts on page |
| --- | --- | --- |
| 1 ERP Foundations and Business Processes | 1–2 | 1 |
| 2 Customer, Sales, and Revenue | 3–4 | 13 |
| 3 Planning, Production, and Supply Chain | 5–7 | 25 |
| 4 Finance, People, and Process Improvement | 8–10 | 44 |
| 5 Integrated Odoo Practicals | Labs 1–8 | 59 |
| Capstone, Appendix A (Odoo quick reference), Appendix B (source map) | | 77 |

## Labs

Unlike the other courses, the practicals follow the tutorial schedule rather than the chapter order, so they are
collected together in Stage 5. Lab *N* is Tutorial *N*. Each practical names the chapters it draws on with
`\labcovers` after its banner, so its folder under
[`.all_pdfs/enterprise-resource-planning/`](../.all_pdfs/enterprise-resource-planning) holds exactly the chapters
in the "Read first" column, then the practical. Page numbers are the ones printed in the book.

| Lab | Practical | Tutorial | Read first | Pages |
| --- | --- | --- | --- | --- |
| 1 | [Business Process and Odoo Environment Setup](../.all_pdfs/enterprise-resource-planning/Lab-01/Lab-Activity.pdf) | T1 | Ch. 1–2 | 60–62 |
| 2 | [ERP Benefits, Challenges, and Modular Integration](../.all_pdfs/enterprise-resource-planning/Lab-02/Lab-Activity.pdf) | T2 | Ch. 2 | 63–64 |
| 3 | [Production Planning and Manufacturing in Odoo](../.all_pdfs/enterprise-resource-planning/Lab-03/Lab-Activity.pdf) | T3 | Ch. 5 | 65–66 |
| 4 | [Customer Relationship Management in Odoo](../.all_pdfs/enterprise-resource-planning/Lab-04/Lab-Activity.pdf) | T4 | Ch. 4 | 67–68 |
| 5 | [Sales Order Process: Order-to-Cash in Odoo](../.all_pdfs/enterprise-resource-planning/Lab-05/Lab-Activity.pdf) | T5 | Ch. 3, 8 | 69–70 |
| 6 | [Sales Forecasting and S&OP with ERP Data](../.all_pdfs/enterprise-resource-planning/Lab-06/Lab-Activity.pdf) | T6 | Ch. 6 | 71–72 |
| 7 | [Supply Chain Management: Procure, Receive, and Measure](../.all_pdfs/enterprise-resource-planning/Lab-07/Lab-Activity.pdf) | T7 | Ch. 7 | 73–74 |
| 8 | [Human Resources and Recruitment Process Modelling](../.all_pdfs/enterprise-resource-planning/Lab-08/Lab-Activity.pdf) | T8 | Ch. 9–10 | 75–76 |
| | [Capstone: West End Bicycles End-to-End ERP Story](../.all_pdfs/enterprise-resource-planning/Capstone-Project.pdf) | | all | 77–80 |

## Running the labs

Every practical runs in **Odoo 19 Community Edition**. Lab 1 sets up the database (for example
`west_end_bicycles`, with Malaysia as the country) and installs the course apps; if your class uses a provisioned
deployment, use the database you were assigned. Appendix A is a quick reference to the Odoo menus the labs use.

## Still to do

- Decide whether the practicals should move next to their chapters in the book, as in the other courses, or stay
  together in tutorial order. The lab folders under `.all_pdfs/` are already organised by lab either way.

## Folder map

```text
ENTERPRISE RESOURCE PLANNING/
  main.tex            the book: configuration and chapter list
  chapters/           10 chapters, the course map (with a list of figures) and the capstone
  labs/               8 Odoo practicals, input together in Stage 5
  appendices/         the Odoo quick reference and the course source map
  0.from_lecturer/    the lecturer's notes, tutorials, TA answer guides and teaching manuals
```

The business-process diagrams are drawn with the shared
[process diagram library](../.shared/diagrams/process.tex).

## Building the book

From the repository root:

```bash
python .shared/build.py ERP            # rebuild the book and its lab PDFs in .all_pdfs/enterprise-resource-planning/
python .shared/build.py ERP --check    # build only, to check a change; writes nothing
```

The build runs in a temporary folder, so nothing is written to this course folder. See [`.shared/`](../.shared)
for the shared styles every book uses.
