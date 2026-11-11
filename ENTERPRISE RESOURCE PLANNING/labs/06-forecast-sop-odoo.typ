#import "/.shared/typst/utp.typ": *
#unit("labs", "06-forecast-sop-odoo")

#lab("6")[Sales Forecasting and S&OP with ERP Data] <sec:lab06>

#callout("labproject", title: [Use the supplied planning spreadsheet and connect its inputs back to Odoo transactions])[#strong[Coverage.] Tutorial 6 + Chapter 6. \
#strong[Core systems.] Supplied Excel spreadsheet + Odoo Sales/Inventory/Manufacturing reporting. \
#strong[Goal.] Build formula-driven forecast and S&OP logic, then explain where an integrated ERP would supply the historical data used by the model.


#include "/ENTERPRISE RESOURCE PLANNING/labs/visuals/06-flow.typ"


#callout("labmode", title: [How the practical connects to the concept])[The tutorial explicitly requires the supplied spreadsheet. Odoo remains part of the lab by providing the operational context: Sales generates history, Inventory provides starting stock, and Manufacturing provides actual production. The spreadsheet performs the aggregate planning calculation.

#strong[The spreadsheet was not included with the course materials.] Rather than leave the lab uncompletable, `all_experiments/sop_planner.py` reproduces the same calculation with every formula written out:


#include "/ENTERPRISE RESOURCE PLANNING/labs/visuals/06-trace.typ"
 #strong[Use the chapter while coding.] Revisit #link(label("ch:forecasting-sop"))[the earlier chapter explanation]; match its operation to the variables and state changes below.

#strong[Follow the supplied implementation.] Follow base, forecast, capacity, opening, inventory and utilisation in that order. January closing stock becomes February opening stock. With --unit shoes, capacity halves to 3,520 pairs and January utilisation rises to 130.68%, so feasible becomes false even though the stock calculation remains 580. Check both conditions in the boolean expression rather than using positive closing stock as the sole feasibility test. 
#include "/ENTERPRISE RESOURCE PLANNING/labs/visuals/06-worked-case.typ"


#code-block("python all_experiments/sop_planner.py\npython all_experiments/sop_planner.py --safety-stock 500 --unit pairs", lang: "text")

Build the spreadsheet as the tutorial requires --- that is the deliverable. Use the script to #emph[check] it. If your sheet and the script disagree, one of you has a formula wrong, and finding out which is worth more than either answer.]

#strong[Part A --- Complete the simple sales forecast.]

Use the provided previous-year values. For each month:

+ Previous Year Base = Previous Year Sales $-$ Previous Promotion;

+ Growth = Previous Year Base $times 3 %$;

+ Base Projection = Previous Year Base + Growth;

+ Forecast = Base Projection + Current Promotion.

Current promotion assumptions: +500 pairs in November and +400 pairs in December.

Use formulas. Do not type the calculated rows manually.

#strong[Part B --- Resolve units before capacity calculation.]

The tutorial states demand in pairs but capacity as 40 shoes/hour. Record which interpretation your tutor intends. Your formulas must use one consistent unit throughout.

#strong[Part C --- Build the S&OP plan.]

Calculate capacity from production rate, 8 hours/day, and monthly working days. Keep utilisation at or below 99% as required in Tutorial 6. Use the inventory balance: $ I_t = I_(t - 1) + P_t - F_t . $ Plan around the expected festive-demand pressure in June and December rather than merely copying forecast into production.

#strong[Part D --- Check the source discrepancy.]

Tutorial 6 states safety stock = 100, while the supplied spreadsheet contains 500 in the initial December inventory cell. Do not hide the conflict. Confirm which value should be used for assessment and state it in your sheet or submission notes.

#strong[Complete formula checker.] The inputs below reproduce the worked chapter plan. Both unit interpretations are supported; the program reports infeasible months rather than silently changing the plan. #source-code("/ENTERPRISE RESOURCE PLANNING/all_experiments/sop_planner.py", first: 1, last: 27, lang: "python") #source-code("/ENTERPRISE RESOURCE PLANNING/all_experiments/sop_planner.py", first: 28, last: 42, lang: "python") #strong[Reference run: pairs per hour.] #source-code("/ENTERPRISE RESOURCE PLANNING/labs/walkthroughs/sop-pairs.txt", first: 1, last: none, lang: "text") #strong[Part E --- Inspect related Odoo reports.]

After completing earlier labs, open:

- #strong[Sales Reporting];

- #strong[Inventory Reporting];

- #strong[Manufacturing Operations Manufacturing Orders], switching to its Graph or Pivot view. Manufacturing has no Reporting menu in the default setup.

For each report, identify which S&OP input or validation measure it could provide in a larger implementation: sales history, starting inventory, production output, or actual-versus-plan comparison.

#callout("keyidea", title: [Key idea])[Forecasting is not "outside ERP." Even when the planning calculation is performed in a spreadsheet, the reliability of the model depends on integrated historical sales, inventory, and production data.]]

#strong[Chapter connection.] Revisit #link(label("ch:forecasting-sop"))[the chapter explanation] and map its states to the steps below. 
#include "/ENTERPRISE RESOURCE PLANNING/labs/visuals/06-forecast-sop-odoo-chapter.typ"



#include "/ENTERPRISE RESOURCE PLANNING/labs/walkthroughs/06-records.typ"


#callout("verification", title: [Verification checklist])[#strong[Explain and extend your result.] Run the two documented capacity-unit interpretations. Show the first month where feasibility differs and report both stock and utilisation, rather than only a final annual total.

- Every calculated row of the forecast uses formulas, not typed values.

- One unit is used consistently in the demand and capacity calculations, and the interpretation is recorded.

- Utilisation stays at or below 99 % in every month, and the inventory balance $I_t = I_(t - 1) + P_t - F_t$ holds.

- The safety-stock discrepancy (100 against 500) is stated, with the value used for assessment.

- Each Odoo report is matched to the S&OP input or measure it could provide.]
