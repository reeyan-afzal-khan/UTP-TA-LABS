#import "/.shared/typst/utp.typ": *
#unit("chapters", "06-forecasting-sop")

= Sales Forecasting and Sales & Operations Planning <ch:forecasting-sop>

#chapterguide[You should understand the production-planning hierarchy and the difference between forecast, production plan, inventory, and capacity.][calculate a simple promotion-adjusted forecast, construct an S&OP table, interpret capacity utilisation and safety stock, and identify unit or data inconsistencies before using a planning model.]

#sourcebasis[
  This chapter follows Tutorial 6, the supplied Sales Forecast and S&OP
  spreadsheet, and the forecasting sections of Chapter 4. The tutorial uses
  Footloose Sport Shoes and asks students to automate the calculations with
  spreadsheet formulas. Every figure below is plotted from the tutorial’s own
  input values.
]

== Forecast structure used in the tutorial

The Footloose exercise supplies the previous year’s monthly sales, identifies
the promotional demand inside those figures, assumes 3% underlying growth, and
adds a different promotion plan for the forecast year. The calculation is four
rows: strip last year’s promotion, grow the base, add this year’s promotion.

#utptable[
  #resizebox(100%)[#tabularx(
    columns: (auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto),
    align: (left, right, right, right, right, right, right, right, right, right, right, right, right),
    header: ([], [Jan], [Feb], [Mar], [Apr], [May], [Jun], [Jul], [Aug], [Sep], [Oct], [Nov], [Dec]),
    [Previous year], [4000], [4000], [4500], [5000], [5000], [5500], [5500], [5750], [6000], [6000], [6200], [6300],
    [Previous promo], [0], [0], [0], [0], [0], [200], [0], [0], [0], [0], [400], [400],
    [Base], [4000], [4000], [4500], [5000], [5000], [5300], [5500], [5750], [6000], [6000], [5800], [5900],
    [3% growth], [120], [120], [135], [150], [150], [159], [165], [172.5], [180], [180], [174], [177],
    [Base projection], [4120], [4120], [4635], [5150], [5150], [5459], [5665], [5922.5], [6180], [6180], [5974], [6077],
    [New promo], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [500], [400],
    [Forecast], [4120], [4120], [4635], [5150], [5150], [5459], [5665], [5922.5], [6180], [6180], [6474], [6477],
  )]
]

The three series are easier to judge as lines than as a grid of numbers.

#utpfig([The tutorial’s three series. Note what happens at June, November, and December: the previous-year line jumps, the base line does not, and the forecast line jumps again only where a #emph[new] promotion is planned. June is the instructive case --- last year’s spike disappears and is not replaced.], label: <fig:footloose-forecast>)[
  #canvas({
    axis(width: 14.6cm, height: 6.4cm, ymin: 3600, ymax: 7000, ylabel: [pairs], symbolic-x: ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"), xtick: "data", x-tick-label-style: font("script", fill: muted), legend-style: (at: (0.5, 1.19), anchor: "north", columns: 3), ymajorgrids: true, grid-style: (draw: mix(muted, 22%)), plot-style: (mark-size: 1.4944pt,),
      addplot(draw: muted, mark: "*", mark-fill: muted, coords: (("Jan", 4000), ("Feb", 4000), ("Mar", 4500), ("Apr", 5000), ("May", 5000), ("Jun", 5500), ("Jul", 5500), ("Aug", 5750), ("Sep", 6000), ("Oct", 6000), ("Nov", 6200), ("Dec", 6300)), legend: [previous year (as sold)]),
      addplot(draw: blue, dash: "dashed", mark: "square*", mark-fill: pale-blue, coords: (("Jan", 4000), ("Feb", 4000), ("Mar", 4500), ("Apr", 5000), ("May", 5000), ("Jun", 5300), ("Jul", 5500), ("Aug", 5750), ("Sep", 6000), ("Oct", 6000), ("Nov", 5800), ("Dec", 5900)), legend: [base (promotion removed)]),
      addplot(draw: green, mark: "triangle*", mark-fill: pale-teal, coords: (("Jan", 4120), ("Feb", 4120), ("Mar", 4635), ("Apr", 5150), ("May", 5150), ("Jun", 5459), ("Jul", 5665), ("Aug", 5922.5), ("Sep", 6180), ("Oct", 6180), ("Nov", 6474), ("Dec", 6477)), legend: [forecast]),
      {
        connect((2, 6500), (5, 5480), ..proclink)
        node((1, 6600), [June: last year’s spike removed, not replaced], ..procchipwarn, anchor: "west", font: font("tiny"))
        connect((6, 6130), (10, 6430), ..proclink)
        node((3, 6130), [new promotion added here], ..procchip, anchor: "west", font: font("tiny"))
      },
    )
  })
]

#workedexample[
  For June, previous-year sales were 5,500 pairs of which 200 were promotional. The
  base is 5,300. Applying 3% growth gives $5(,)300 times 1.03 = 5(,)459$. No new
  promotion is planned for June, so the forecast stays at 5,459 pairs --- below
  last year’s actual sales, which is the correct answer.
]

#utpfig([The two promotion months broken into their three components. The forecast is higher than last year in both months, but for different reasons: December’s new promotion is smaller than last year’s, so almost all its growth comes from the base. The axis starts at 5,400 so the increments are visible.], label: <fig:promo-decomposition>)[
  #canvas({
    axis(width: 12.6cm, height: 5.6cm, ybar-stacked: true, bar-width: 25.9029pt, ymin: 5400, ymax: 6700, ylabel: [pairs], symbolic-x: ("Nov base", "Nov forecast", "Dec base", "Dec forecast"), xtick: "data", x-tick-label-style: font("script", fill: muted), enlarge-x-limits: 0.22, legend-style: (at: (0.5, 1.19), anchor: "north", columns: 3), ymajorgrids: true, grid-style: (draw: mix(muted, 22%)),
      addplot(draw: blue, fill: pale-blue, coords: (("Nov base", 5800), ("Nov forecast", 5800), ("Dec base", 5900), ("Dec forecast", 5900)), legend: [base demand]),
      addplot(draw: green, fill: pale-teal, coords: (("Nov base", 0), ("Nov forecast", 174), ("Dec base", 0), ("Dec forecast", 177)), legend: [3% growth]),
      addplot(draw: orange, fill: pale-orange, coords: (("Nov base", 0), ("Nov forecast", 500), ("Dec base", 0), ("Dec forecast", 400)), legend: [planned promotion]),
    )
  })
]

If the organisation plans in whole pairs it must also choose and document a
rounding rule. Do not round some months and not others.

== S&OP is a balancing problem

Once forecast demand exists, planners decide how much to produce. The inventory
balance is $I_t = I_(t-1) + P_t - F_t$. A plan that copies the forecast into the
production row keeps inventory flat, which is rarely what a seasonal business
wants.

== Capacity, and the unit that decides everything

Tutorial 6 states a maximum of 40 shoes per hour, 8 hours per normal day, and a
utilisation ceiling of 99%. Before calculating anything, the units must agree.

#pitfall[
  The tutorial describes demand in #emph[pairs] but states production as #emph[40 shoes per hour]. Those are different units. Read literally, capacity is 20
  pairs/hour; read as the classroom shorthand, it is 40 pairs/hour. Confirm the
  intended unit with the tutor before finalising the table.
]

This is not a pedantic point. The two readings give opposite answers about
whether the year’s plan is possible at all.

#utpfig([Monthly utilisation if production simply matches the forecast, under both readings of the production rate. At 40 pairs/hour the year fits comfortably under the ceiling; at 20 pairs/hour every single month is infeasible, some by nearly double. No amount of planning skill recovers from choosing the wrong unit.], label: <fig:unit-ambiguity>)[
  #canvas({
    axis(width: 14.6cm, height: 6cm, ymin: 0, ymax: 210, ylabel: [utilisation (%)], symbolic-x: ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"), xtick: "data", x-tick-label-style: font("script", fill: muted), legend-style: (at: (0.5, 1.2), anchor: "north", columns: 3), ymajorgrids: true, grid-style: (draw: mix(muted, 22%)), plot-style: (mark-size: 1.4944pt,),
      addplot(draw: red, mark: "*", mark-fill: pale-red, coords: (("Jan", 117), ("Feb", 129), ("Mar", 126), ("Apr", 161), ("May", 153), ("Jun", 155), ("Jul", 169), ("Aug", 168), ("Sep", 176), ("Oct", 184), ("Nov", 184), ("Dec", 193)), legend: [literal: 20 pairs/hour]),
      addplot(draw: green, mark: "square*", mark-fill: pale-teal, coords: (("Jan", 58.5), ("Feb", 64.4), ("Mar", 63), ("Apr", 80.5), ("May", 76.6), ("Jun", 77.5), ("Jul", 84.3), ("Aug", 84.1), ("Sep", 87.8), ("Oct", 92), ("Nov", 92), ("Dec", 96.4)), legend: [shorthand: 40 pairs/hour]),
      addplot(draw: orange, dash: "dashed", mark: none, domain: (0, 11), samples: 2, coords: (("Jan", 99), ("Dec", 99)), legend: [99% ceiling]),
      {
        node((6, 142), [every month infeasible], ..procchipbad, anchor: "north", font: font("tiny"))
      },
    )
  })
]

With the rate confirmed as $r$ pairs/hour, monthly capacity and utilisation are

$ C_t = r times 8 times D_t, wide U_t = frac(P_t, C_t) times 100 % <= 99 % , $

where $D_t$ is the working days in the month.

== Safety stock and seasonal peaks

The tutorial expects higher demand in June and December and wants a safety
buffer. The sensible response is to produce above forecast while capacity is
slack early in the year and draw the buffer down through the peak.

#utpfig([A plan that deliberately departs from the forecast. Production runs above demand from January to August, when capacity is under-used, and the accumulated stock absorbs the November and December peak without pushing utilisation to the ceiling. Working days assumed per month.], label: <fig:sop-plan>)[
  #canvas({
    axis(width: 14.6cm, height: 6.2cm, ybar: 1.4944pt, bar-width: 6.9738pt, ymin: 0, ymax: 8400, ylabel: [pairs], symbolic-x: ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"), xtick: "data", x-tick-label-style: font("script", fill: muted), enlarge-x-limits: 0.055, legend-style: (at: (0.5, 1.2), anchor: "north", columns: 3), ymajorgrids: true, grid-style: (draw: mix(muted, 22%)),
      addplot(draw: mix(muted, 60%), fill: pale-gray, coords: (("Jan", 7040), ("Feb", 6400), ("Mar", 7360), ("Apr", 6400), ("May", 6720), ("Jun", 7040), ("Jul", 6720), ("Aug", 7040), ("Sep", 7040), ("Oct", 6720), ("Nov", 7040), ("Dec", 6720)), legend: [capacity at 40 pairs/hour]),
      addplot(draw: green, fill: pale-teal, coords: (("Jan", 4600), ("Feb", 4600), ("Mar", 5000), ("Apr", 5400), ("May", 5400), ("Jun", 5700), ("Jul", 5900), ("Aug", 6050), ("Sep", 6200), ("Oct", 6200), ("Nov", 6200), ("Dec", 6200)), legend: [production plan]),
      addplot(draw: blue, fill: pale-blue, coords: (("Jan", 4120), ("Feb", 4120), ("Mar", 4635), ("Apr", 5150), ("May", 5150), ("Jun", 5459), ("Jul", 5665), ("Aug", 5922.5), ("Sep", 6180), ("Oct", 6180), ("Nov", 6474), ("Dec", 6477)), legend: [forecast demand]),
    )
  })
]

#utpfig([The inventory consequence of the same plan, from an opening balance of 100 pairs. Stock climbs while production exceeds demand, peaks in October, and is consumed through the two promotion months --- which is the whole purpose of planning production separately from forecasting it.], label: <fig:inventory-profile>)[
  #canvas({
    axis(width: 14.6cm, height: 5.4cm, ymin: 0, ymax: 3000, ylabel: [ending inventory (pairs)], symbolic-x: ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"), xtick: "data", x-tick-label-style: font("script", fill: muted), ymajorgrids: true, grid-style: (draw: mix(muted, 22%)),
      addplot(draw: blue, fill: pale-blue, mark: "*", mark-fill: blue, mark-size: 1.4944pt, coords: (("Jan", 580), ("Feb", 1060), ("Mar", 1425), ("Apr", 1675), ("May", 1925), ("Jun", 2166), ("Jul", 2401), ("Aug", 2528), ("Sep", 2548), ("Oct", 2568), ("Nov", 2294), ("Dec", 2017))),
      {
        node((1, 1200), [building the buffer], ..procchip, anchor: "south-west", font: font("tiny"))
        node((11, 2350), [drawn down], ..procchipwarn, anchor: "south-east", font: font("tiny"))
      },
    )
  })
]

== A disciplined spreadsheet design

A planning spreadsheet must separate #term[inputs] from #term[calculated rows].
The growth rate is entered once and referenced absolutely; promotion assumptions
live in their own row; capacity is calculated from rate, hours, and working days
rather than typed as a number.

#utpfig([Inputs on the left are the only cells anyone types into. Everything on the right is a formula. A tutor or manager should be able to change one input cell and watch the whole plan recalculate.], label: <fig:spreadsheet-anatomy>)[
  #canvas({
    rectangle((0, -0.35), (5.4, 4.35), draw: mix(orange, 45%), fill: mix(pale-orange, 55%), rounded: 2.5mm)
    node((2.7, 4.05), [#strong[Inputs --- typed once]], ..proccap, text: orange)
    for (i, t) in ((0, [Previous-year sales by month]), (1, [Previous promotion by month]), (2, [Growth rate $g = 3 %$ #emph[(one cell)]]), (3, [New promotion by month]), (4, [Rate, hours/day, working days]), (5, [Opening inventory, safety stock])) {
      let y = 3.45 - i * 0.62
      node((2.7, y), [#t], ..procwarn, min-width: 4.8, text-width: 4.4, min-height: 0.5)
    }
    rectangle((7.2, -0.35), (14.6, 4.35), draw: mix(green, 45%), fill: mix(pale-teal, 55%), rounded: 2.5mm)
    node((10.9, 4.05), [#strong[Calculated --- formulas only]], ..proccap, text: green)
    for (i, t) in ((0, [Base $=$ previous sales $-$ previous promo]), (1, [Base projection $=$ base $times (1+g)$]), (2, [Forecast $=$ base projection $+$ new promo]), (3, [Capacity $=$ rate $times$ hours $times$ days]), (4, [Utilisation $=$ production $div$ capacity]), (5, [Ending inventory $= I_(t-1) + P_t - F_t$])) {
      let y = 3.45 - i * 0.62
      node((10.9, y), [#t], ..procgood, min-width: 6.8, text-width: 6.4, min-height: 0.5)
    }
    for i in range(0, 6) {
      let y = 3.45 - i * 0.62
      connect((5.5, y), (7.1, y), ..procflow)
    }
    node((7.3, -0.55), [If a number appears in the right-hand box as a typed constant, the model has a hidden assumption nobody can audit.], ..procnote, anchor: "north", text-width: 13.6)
  })
]

== Product-mix planning

The tutorial’s S&OP table also splits total production among product types. If
the mix is 50%, 30%, and 20%, then $P_(1,t)=0.50 P_t$, $P_(2,t)=0.30 P_t$, and
$P_(3,t)=0.20 P_t$. The percentages must sum to 100%.

#utpfig([The aggregate plan allocated by mix, using September’s figure. The split is an aggregate rule: real products may consume different amounts of the bottleneck resource, which a percentage allocation cannot express.], label: <fig:product-mix>)[
  #canvas({
    node((2.6, 1.4), [September plan \
  #fsize("tiny")[#text(weight: "regular")[$P_t = 6(,)200$ pairs]]], name: "tot", ..procstep, min-width: 4.4, min-height: 0.9)
    for (i, nm, pc, q) in ((0, "Running shoe", "50%", (3, 100)), (1, "Trail shoe", "30%", (1, 860)), (2, "Court shoe", "20%", (1, 240))) {
      let y = 2.4 - i * 1.15
      node((7.4, y), [#nm], name: "p" + str(i), ..procgood, anchor: "west", min-width: 3.4, min-height: 0.8)
      node((11, y), [#pc], ..procchip, anchor: "west")
      node((12.4, y), [#q pairs], ..procchip, anchor: "west", draw: blue, fill: pale-blue)
      connect((5, 1.4), (6.4, y), (7.35, y), ..procflow)
    }
    node((2.6, 0.5), [the percentages must sum to 100%, or the plan silently under- or over-commits capacity], ..procnote, anchor: "north", text-width: 6)
  })
]

== Source inconsistencies to notice before modelling

A few values in the course materials should be surfaced rather than silently
reconciled:

- Tutorial 6 asks for the 2023 forecast from 2022 sales, while the supplied spreadsheet headings still say “for year 2022.” The row values match the tutorial’s input structure.
- Tutorial 6 states safety stock of 100, but the spreadsheet pre-fills 500 in the December inventory cell of the S&OP table.
- Demand is stated in pairs while the production rate is stated in shoes (#figref(<fig:unit-ambiguity>)).

#keyidea[
  Planning models are only as reliable as their units and assumptions. Before
  writing formulas, verify time period, unit of measure, starting inventory,
  promotion assumptions, capacity rate, and whether the numbers describe items,
  pairs, cases, or product groups.
]

== How Odoo contributes to forecasting and planning

The supplied build guide does not implement an S&OP workflow, but it creates the
operational history that planning depends on.

#applicationbox[
  Use Odoo’s reporting views to connect the spreadsheet exercise to ERP data:

  - #pathmenu[Sales →Reporting]: confirmed demand and revenue history.
  - #pathmenu[Inventory →Reporting]: on-hand stock and movement history.
  - #pathmenu[Manufacturing →Operations →Manufacturing Orders], in its Graph or Pivot view: orders and output.

  The planning spreadsheet is an analytical layer over the integrated transaction
  history, not a separate world.
]

#tryit[
  Build one month of S&OP twice: first at 40 #emph[pairs]/hour, then at the literal
  40 #emph[shoes]/hour. Compare capacity and utilisation against
  #figref(<fig:unit-ambiguity>). This is why unit discipline comes before any
  planning discussion.
]

#quickcheck[
  + Why should last year’s promotion be removed before applying the 3% growth factor?
  + What does a positive ending inventory mean in the S&OP balance equation?
  + Why might production be deliberately higher than forecast in March if December demand is expected to peak?
]
