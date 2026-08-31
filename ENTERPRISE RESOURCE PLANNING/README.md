# Enterprise Resource Planning — labs

Eight labs, matching Tutorials 1–8. The lab sections live in the notes
(`_NOTES/labs/`); this folder holds the supporting materials.

| Lab | Tutorial | Topic | Materials |
| --: | --- | --- | --- |
| 1 | 1 | Business processes in Odoo | — (Odoo only) |
| 2 | 2 | ERP development and app structure | — (Odoo only) |
| 3 | 3 | Production planning | — (Odoo only) |
| 4 | 4 | CRM and the sales pipeline | — (Odoo only) |
| 5 | 5 | Sales order to invoice | — (Odoo only) |
| 6 | 6 | Forecasting and S&OP | `Lab06/sop_planner.py` |
| 7 | 7 | Supply chain and MRP | — (Odoo only) |
| 8 | 8 | HR and process modelling | — (Odoo only) |

Most labs are performed entirely inside Odoo, so there is nothing to run here.
Lab 6 is the exception: it requires a planning calculation.

## Lab 6 — the missing spreadsheet

The notes for Lab 6 specify a supplied Excel spreadsheet. **That file was not
included with the course materials.** Rather than leave the lab uncompletable,
`Lab06/sop_planner.py` reproduces the same calculation with every formula
written out rather than hidden in cells.

```bash
cd Lab06
py sop_planner.py
py sop_planner.py --safety-stock 500
py sop_planner.py --unit pairs
```

Build the spreadsheet as the tutorial requires — that is still the deliverable.
Use the script to **check** it. If your sheet and the script disagree, one of
you has a formula wrong, and finding out which is the point.

Standard library only; no packages to install.

### Two documented discrepancies in the source material

The lab notes flag both of these rather than silently resolving them. The
script lets you run either interpretation and compare.

**Safety stock.** Tutorial 6 states 100. The supplied spreadsheet has 500 in
the opening December cell. Confirm which your tutor requires and state the
assumption in your submission.

**Units.** The tutorial states demand in *pairs* but the production rate as
40 *shoes* per hour. These are not the same unit:

- `--unit pairs` — capacity around 7,000/month against roughly 2,500 demand.
  Nothing ever binds, and the S&OP plan becomes trivial.
- `--unit shoes` (default) — capacity halves to about 3,500/month. November
  and December run at 99% utilisation and inventory must be built ahead.

That one reading makes the exercise meaningless is itself evidence for which
was intended. Say so in your submission rather than silently picking one.

## Odoo

Labs 1–5, 7, and 8 use Odoo 19 Community Edition. Follow your tutor's
deployment instructions — the notes assume a working instance and do not cover
installation.

Menu paths in the notes are written as `Sales → Reporting`, matching the Odoo
navigation.

## Notes

The LaTeX teaching notes are in [`_NOTES/`](_NOTES/) and build independently:

```bash
cd _NOTES && make
```
