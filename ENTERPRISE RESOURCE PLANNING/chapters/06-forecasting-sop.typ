#import "/.shared/typst/utp.typ": *
#unit("chapters", "06-forecasting-sop")


#heading(level: 1)[Sales Forecasting and Sales & Operations Planning]
 <ch:forecasting-sop>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* You should understand the production-planning hierarchy and the difference between forecast, production plan, inventory, and capacity.

*By the end, you can:* calculate a simple promotion-adjusted forecast, construct an S&OP table, interpret capacity utilisation and safety stock, and identify unit or data inconsistencies before using a planning model.]

#callout("sourcebasis", title: [Source basis])[This chapter follows Tutorial 6, the supplied Sales Forecast and S&OP spreadsheet, and the forecasting sections of Chapter 4. The tutorial uses Footloose Sport Shoes and asks students to automate the calculations with spreadsheet formulas. Every figure below is plotted from the tutorial's own input values.]


#heading(level: 2)[Forecast structure used in the tutorial]


The Footloose exercise supplies the previous year's monthly sales, identifies the promotional demand inside those figures, assumes 3% underlying growth, and adds a different promotion plan for the forecast year. The calculation is four rows: strip last year's promotion, grow the base, add this year's promotion.



The three series are easier to judge as lines than as a grid of numbers.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/5f6a66e4ff78f6b7.cetz.json")], caption: [The tutorial's three series. Note what happens at June, November, and December: the previous-year line jumps, the base line does not, and the forecast line jumps again only where a #emph[new] promotion is planned. June is the instructive case --- last year's spike disappears and is not replaced.]) <fig:footloose-forecast>

#callout("workedexample", title: [Worked example])[For June, previous-year sales were 5,500 pairs of which 200 were promotional. The base is 5,300. Applying 3% growth gives $5 \, 300 times 1.03 = 5 \, 459$. No new promotion is planned for June, so the forecast stays at 5,459 pairs --- below last year's actual sales, which is the correct answer.]

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/b442a0effb11d6e7.cetz.json")], caption: [The two promotion months broken into their three components. The forecast is higher than last year in both months, but for different reasons: December's new promotion is smaller than last year's, so almost all its growth comes from the base. The axis starts at 5,400 so the increments are visible.]) <fig:promo-decomposition>

If the organisation plans in whole pairs it must also choose and document a rounding rule. Do not round some months and not others.


#heading(level: 2)[S&OP is a balancing problem]


Once forecast demand exists, planners decide how much to produce. The inventory balance is $I_t = I_(t - 1) + P_t - F_t$. A plan that copies the forecast into the production row keeps inventory flat, which is rarely what a seasonal business wants.


#heading(level: 2)[Capacity, and the unit that decides everything]


Tutorial 6 states a maximum of 40 shoes per hour, 8 hours per normal day, and a utilisation ceiling of 99%. Before calculating anything, the units must agree.

#callout("pitfall", title: [Common mistake])[The tutorial describes demand in #emph[pairs] but states production as #emph[40 shoes per hour]. Those are different units. Read literally, capacity is 20 pairs/hour; read as the classroom shorthand, it is 40 pairs/hour. Confirm the intended unit with the tutor before finalising the table.]

This is not a pedantic point. The two readings give opposite answers about whether the year's plan is possible at all.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/89d175275c367f0e.cetz.json")], caption: [Monthly utilisation if production simply matches the forecast, under both readings of the production rate. At 40 pairs/hour the year fits comfortably under the ceiling; at 20 pairs/hour every single month is infeasible, some by nearly double. No amount of planning skill recovers from choosing the wrong unit.]) <fig:unit-ambiguity>

With the rate confirmed as $r$ pairs/hour, monthly capacity and utilisation are

$ C_t = r times 8 times D_t \, #h(2em) U_t = P_t / C_t times 100 % lt.eq 99 % \, $

where $D_t$ is the working days in the month.


#heading(level: 2)[Safety stock and seasonal peaks]


The tutorial expects higher demand in June and December and wants a safety buffer. The sensible response is to produce above forecast while capacity is slack early in the year and draw the buffer down through the peak.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/41b879513f6a2266.cetz.json")], caption: [A plan that deliberately departs from the forecast. Production runs above demand from January to August, when capacity is under-used, and the accumulated stock absorbs the November and December peak without pushing utilisation to the ceiling. Working days assumed per month.]) <fig:sop-plan>

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/a603b07a9c788d65.cetz.json")], caption: [The inventory consequence of the same plan, from an opening balance of 100 pairs. Stock climbs while production exceeds demand, peaks in October, and is consumed through the two promotion months --- which is the whole purpose of planning production separately from forecasting it.]) <fig:inventory-profile>


#heading(level: 2)[A disciplined spreadsheet design]


A planning spreadsheet must separate #strong[inputs] from #strong[calculated rows]. The growth rate is entered once and referenced absolutely; promotion assumptions live in their own row; capacity is calculated from rate, hours, and working days rather than typed as a number.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/b80fb32a6570a138.cetz.json")], caption: [Inputs on the left are the only cells anyone types into. Everything on the right is a formula. A tutor or manager should be able to change one input cell and watch the whole plan recalculate.]) <fig:spreadsheet-anatomy>


#heading(level: 2)[Product-mix planning]


The tutorial's S&OP table also splits total production among product types. If the mix is 50%, 30%, and 20%, then $P_(1 \, t) = 0.50 P_t$, $P_(2 \, t) = 0.30 P_t$, and $P_(3 \, t) = 0.20 P_t$. The percentages must sum to 100%.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/a6813909825505f4.cetz.json")], caption: [The aggregate plan allocated by mix, using September's figure. The split is an aggregate rule: real products may consume different amounts of the bottleneck resource, which a percentage allocation cannot express.]) <fig:product-mix>


#heading(level: 2)[Source inconsistencies to notice before modelling]


A few values in the course materials should be surfaced rather than silently reconciled:

- Tutorial 6 asks for the 2023 forecast from 2022 sales, while the supplied spreadsheet headings still say "for year 2022." The row values match the tutorial's input structure.

- Tutorial 6 states safety stock of 100, but the spreadsheet pre-fills 500 in the December inventory cell of the S&OP table.

- Demand is stated in pairs while the production rate is stated in shoes (#ref(label("fig:unit-ambiguity"), supplement: [Figure])).

#callout("keyidea", title: [Key idea])[Planning models are only as reliable as their units and assumptions. Before writing formulas, verify time period, unit of measure, starting inventory, promotion assumptions, capacity rate, and whether the numbers describe items, pairs, cases, or product groups.]


#heading(level: 2)[How Odoo contributes to forecasting and planning]


The supplied build guide does not implement an S&OP workflow, but it creates the operational history that planning depends on.

#callout("applicationbox", title: [Application walkthrough])[Use Odoo's reporting views to connect the spreadsheet exercise to ERP data:

- #strong[Sales Reporting]: confirmed demand and revenue history.

- #strong[Inventory Reporting]: on-hand stock and movement history.

- #strong[Manufacturing Operations Manufacturing Orders], in its Graph or Pivot view: orders and output.

The planning spreadsheet is an analytical layer over the integrated transaction history, not a separate world.]

#callout("tryit", title: [Try it yourself])[Build one month of S&OP twice: first at 40 #emph[pairs]/hour, then at the literal 40 #emph[shoes]/hour. Compare capacity and utilisation against #ref(label("fig:unit-ambiguity"), supplement: [Figure]). This is why unit discipline comes before any planning discussion.]

#callout("quickcheck", title: [Check your understanding])[+ Why should last year's promotion be removed before applying the 3% growth factor?

+ What does a positive ending inventory mean in the S&OP balance equation?

+ Why might production be deliberately higher than forecast in March if December demand is expected to peak?]
