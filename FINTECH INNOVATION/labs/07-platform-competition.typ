#import "/.shared/typst/utp.typ": *
#unit("labs", "07-platform-competition")

#labsection(7, label: <sec:lab07-platform>)[Platform competition and the Big Tech threat]

#labproject[Assess whether a Big Tech entrant can take a bank’s customers][
  #strong[Coverage.] Chapter~#ref(<ch:bigtech>). \

  #strong[Goal.] Apply the chapter’s “four assets and one liability” framework to a real platform, and reach a defensible view on where the competitive boundary actually sits.

  #include "visuals/07-flow.typ"

  #note[
    Choose one Big Tech platform with financial ambitions --- Grab, Apple, Alipay, Amazon, or Gojek --- and the incumbent bank you analysed in Lab~#labref(<sec:lab01-unbundling>). Analysing the same bank throughout the course means Labs 1, 5, and 7 accumulate into one coherent argument.
  ]

  #v(6pt)
  #strong[Part A --- FinTech or TechFin?]

  Chapter~@ch:bigtech draws a distinction that determines everything downstream:

  #utptable[
    #tabularx(
      columns: (16%, 1fr, 1fr),
      styles: (navy-bold,),
      header: ([], [FinTech], [TechFin]),
      [Starts from], [A financial product], [An existing user base],
      [Wants], [To win in finance], [To strengthen the core platform],
      [Finance is], [The business], [A retention feature],
      [Can afford], [Losses funded by investors], [Losses funded by another division],
    )
  ]

  #note[
    A TechFin competitor can price a financial product at zero margin indefinitely, because the product’s job is to keep users inside an ecosystem that earns elsewhere.

    An incumbent bank cannot match that, and neither can a FinTech. This is the single most important asymmetry in the chapter, and every recommendation you make must account for it.
  ]

  #v(6pt)
  #strong[Part B --- Score the four assets and the liability.]

  Score your chosen platform 1--5 on each asset, and separately assess the liability:

  #utptable[
    #tabularx(
      columns: (20%, 1fr),
      styles: (navy-bold,),
      header: ([Asset], [Evidence to look for]),
      [Customer access], [Monthly active users; daily open rate; is the app already a habit?],
      [Data], [Behavioural signals a bank cannot see --- location, purchases, messages, search],
      [Brand and trust], [Would users hand this company their salary? Survey data where available],
      [Capital and talent], [Cash reserves; ability to absorb losses; engineering headcount],
      table.hline(stroke: 0.55pt + rule-color),
      table.cell(fill: mix(pale-orange, 70%))[#strong[The liability]], table.cell(fill: mix(pale-orange, 70%))[#strong[Regulatory exposure.] Banking licences, capital requirements, consumer-protection rules, antitrust attention, data-localisation law],
    )
  ]

  #warning[
    The liability is not a tiebreaker to note at the end. It is frequently decisive.

    Big Tech firms have repeatedly retreated from regulated banking while expanding in payments --- Google Plex was cancelled, Facebook’s Libra/Diem collapsed. Payments need light licensing; deposits and credit need a banking licence, capital adequacy, and a regulator willing to grant one to a foreign technology firm. Trace where your platform stops, and identify which rule stopped it.
  ]

  #v(6pt)
  #strong[Part C --- Map the ecosystem and find the wedge.]

  Super apps do not enter finance through the front door. They start with a payment that removes friction from something the user already does --- a taxi fare, a food order --- and expand outward from the resulting transaction data.

  Map your platform’s services and mark the sequence in which financial products were added. Then answer: what was the wedge, and what did the wedge make possible next?

  #strong[Complete worked example.] This runnable fixture uses synthetic inputs. First reproduce it, then adapt the data or ratings with documented evidence. All code below belongs to one file.

  ```terminal
  python all_experiments/lab07_platform_scorecard.py
  ```

  #strong[Setup and output folder.]

  #lstinput("/FINTECH INNOVATION/all_experiments/lab07_platform_scorecard.py", first: 1, last: 10, lang: "python")

  #strong[Make the scoring assumptions visible.]

  #lstinput("/FINTECH INNOVATION/all_experiments/lab07_platform_scorecard.py", first: 11, last: 19, lang: "python")

  #strong[Compare assets without turning them into unsupported market forecasts.]

  #include "visuals/07-trace.typ"

  #strong[Use the chapter while coding.] Revisit #link(<ch:bigtech>)[the earlier chapter explanation]; match its operation to the variables and state changes below.

  #strong[Follow the supplied implementation.] This script does not compute a weighted overall winner. Read each asset comparison independently and fill the evidence template before substituting researched ratings. A numerical advantage does not establish licensing rights, adoption or market share.

  #include "visuals/07-worked-case.typ"

  #lstinput("/FINTECH INNOVATION/all_experiments/lab07_platform_scorecard.py", first: 20, last: 29, lang: "python")

  #strong[Create a record of evidence and dependencies.]

  #lstinput("/FINTECH INNOVATION/all_experiments/lab07_platform_scorecard.py", first: 30, last: 37, lang: "python")

  #include "visuals/07-result.typ"

  #strong[Check the run.] The following output was captured from the supplied script; it describes the synthetic fixture only.

  #lstinput("/FINTECH INNOVATION/labs/outputs/lab07.txt", lang: "terminal")

  #v(6pt)
  #strong[Part D --- What the incumbent still owns.]

  Chapter~@ch:bigtech is clear that banks retain real assets, and a credible analysis names them rather than concluding that banks are doomed:

  - A banking licence and the deposit guarantee that comes with it.
  - Balance-sheet capacity for lending at scale and long duration.
  - Decades of credit-performance data through a full economic cycle --- which no platform has.
  - Regulatory relationships and compliance infrastructure that took years to build.
  - Trust for large, infrequent, consequential transactions. Users will pay for coffee with a phone; they buy a house through a bank.

  #exercises[
    The chapter suggests banks and FinTechs may collaborate against a common Big Tech threat. Design one such partnership: which asset does each side contribute, and what does each give up?

    Then stress-test it. Partnerships fail when one side can eventually build what the other supplies. Which side is that here, and how long do they need?
  ]
]

#strong[Chapter connection.] Revisit #link(<ch:bigtech>)[the chapter explanation] and map its states to the steps below.

#include "visuals/07-platform-competition-chapter.typ"

#checklist[
  #strong[Explain and extend your result.] Choose one asset rating, state what evidence would justify changing it, and recompute that asset’s difference under both plausible values. Identify whether its advantage label changes; do not report an overall ranking that the script does not calculate.

  - Every asset score cites evidence --- a user figure, a filing, a survey --- not impression.
  - The platform is explicitly classified as FinTech or TechFin, with the cross-subsidy consequence stated.
  - Regulatory position is assessed against a named licence regime in a named jurisdiction.
  - Contested and defensible segments are separated, and the defensible list is non-empty.
]
