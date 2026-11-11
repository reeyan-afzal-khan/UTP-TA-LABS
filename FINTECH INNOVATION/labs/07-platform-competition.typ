#import "/.shared/typst/utp.typ": *
#unit("labs", "07-platform-competition")

#lab("7")[Platform competition and the Big Tech threat] <sec:lab07-platform>

#callout("labproject", title: [Assess whether a Big Tech entrant can take a bank's customers])[#strong[Coverage.] Chapter~#ref(label("ch:bigtech"), supplement: none). \
#strong[Goal.] Apply the chapter's "four assets and one liability" framework to a real platform, and reach a defensible view on where the competitive boundary actually sits.


#include "/FINTECH INNOVATION/labs/visuals/07-flow.typ"


#callout("labmode", title: [How much is scaffolded?])[Choose one Big Tech platform with financial ambitions --- Grab, Apple, Alipay, Amazon, or Gojek --- and the incumbent bank you analysed in Lab~#link(label("sec:lab01-unbundling"))[1]. Analysing the same bank throughout the course means Labs 1, 5, and 7 accumulate into one coherent argument.]

#strong[Part A --- FinTech or TechFin?]

Chapter~#ref(label("ch:bigtech"), supplement: none) draws a distinction that determines everything downstream:

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([], [FinTech], [TechFin],),
    table.hline(),
    [Starts from], [A financial product], [An existing user base],
    [Wants], [To win in finance], [To strengthen the core platform],
    [Finance is], [The business], [A retention feature],
    [Can afford], [Losses funded by investors], [Losses funded by another division],
  )]
  , kind: table
  )

#callout("keyidea", title: [Key idea])[A TechFin competitor can price a financial product at zero margin indefinitely, because the product's job is to keep users inside an ecosystem that earns elsewhere.

An incumbent bank cannot match that, and neither can a FinTech. This is the single most important asymmetry in the chapter, and every recommendation you make must account for it.]

#strong[Part B --- Score the four assets and the liability.]

Score your chosen platform 1--5 on each asset, and separately assess the liability:

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Asset], [Evidence to look for],),
    table.hline(),
    [Customer access], [Monthly active users; daily open rate; is the app already a habit?],
    [Data], [Behavioural signals a bank cannot see --- location, purchases, messages, search],
    [Brand and trust], [Would users hand this company their salary? Survey data where available],
    [Capital and talent], [Cash reserves; ability to absorb losses; engineering headcount],
    [#strong[The liability]], [#strong[Regulatory exposure.] Banking licences, capital requirements, consumer-protection rules, antitrust attention, data-localisation law],
  )]
  , kind: table
  )

#callout("pitfall", title: [Common mistake])[The liability is not a tiebreaker to note at the end. It is frequently decisive.

Big Tech firms have repeatedly retreated from regulated banking while expanding in payments --- Google Plex was cancelled, Facebook's Libra/Diem collapsed. Payments need light licensing; deposits and credit need a banking licence, capital adequacy, and a regulator willing to grant one to a foreign technology firm. Trace where your platform stops, and identify which rule stopped it.]

#strong[Part C --- Map the ecosystem and find the wedge.]

Super apps do not enter finance through the front door. They start with a payment that removes friction from something the user already does --- a taxi fare, a food order --- and expand outward from the resulting transaction data.

Map your platform's services and mark the sequence in which financial products were added. Then answer: what was the wedge, and what did the wedge make possible next?

#strong[Complete worked example.] This runnable fixture uses synthetic inputs. First reproduce it, then adapt the data or ratings with documented evidence. All code below belongs to one file. #code-block("python all_experiments/lab07_platform_scorecard.py", lang: "text")

#strong[Setup and output folder.] #source-code("/FINTECH INNOVATION/all_experiments/lab07_platform_scorecard.py", first: 1, last: 10, lang: "python")

#strong[Make the scoring assumptions visible.] #source-code("/FINTECH INNOVATION/all_experiments/lab07_platform_scorecard.py", first: 11, last: 19, lang: "python")

#strong[Compare assets without turning them into unsupported market forecasts.] 
#include "/FINTECH INNOVATION/labs/visuals/07-trace.typ"


#strong[Use the chapter while coding.] Revisit #link(label("ch:bigtech"))[the earlier chapter explanation]; match its operation to the variables and state changes below.

#strong[Follow the supplied implementation.] This script does not compute a weighted overall winner. Read each asset comparison independently and fill the evidence template before substituting researched ratings. A numerical advantage does not establish licensing rights, adoption or market share. 
#include "/FINTECH INNOVATION/labs/visuals/07-worked-case.typ"


#source-code("/FINTECH INNOVATION/all_experiments/lab07_platform_scorecard.py", first: 20, last: 29, lang: "python")

#strong[Create a record of evidence and dependencies.] #source-code("/FINTECH INNOVATION/all_experiments/lab07_platform_scorecard.py", first: 30, last: 37, lang: "python") 
#include "/FINTECH INNOVATION/labs/visuals/07-result.typ"
 #strong[Check the run.] The following output was captured from the supplied script; it describes the synthetic fixture only. #source-code("/FINTECH INNOVATION/labs/outputs/lab07.txt", first: 1, last: none, lang: "text")

#strong[Part D --- What the incumbent still owns.]

Chapter~#ref(label("ch:bigtech"), supplement: none) is clear that banks retain real assets, and a credible analysis names them rather than concluding that banks are doomed:

- A banking licence and the deposit guarantee that comes with it.

- Balance-sheet capacity for lending at scale and long duration.

- Decades of credit-performance data through a full economic cycle --- which no platform has.

- Regulatory relationships and compliance infrastructure that took years to build.

- Trust for large, infrequent, consequential transactions. Users will pay for coffee with a phone; they buy a house through a bank.

#callout("tryit", title: [Try it yourself])[The chapter suggests banks and FinTechs may collaborate against a common Big Tech threat. Design one such partnership: which asset does each side contribute, and what does each give up?

Then stress-test it. Partnerships fail when one side can eventually build what the other supplies. Which side is that here, and how long do they need?]]

#strong[Chapter connection.] Revisit #link(label("ch:bigtech"))[the chapter explanation] and map its states to the steps below. 
#include "/FINTECH INNOVATION/labs/visuals/07-platform-competition-chapter.typ"


#callout("verification", title: [Verification checklist])[#strong[Explain and extend your result.] Choose one asset rating, state what evidence would justify changing it, and recompute that asset's difference under both plausible values. Identify whether its advantage label changes; do not report an overall ranking that the script does not calculate.

- Every asset score cites evidence --- a user figure, a filing, a survey --- not impression.

- The platform is explicitly classified as FinTech or TechFin, with the cross-subsidy consequence stated.

- Regulatory position is assessed against a named licence regime in a named jurisdiction.

- Contested and defensible segments are separated, and the defensible list is non-empty.]
