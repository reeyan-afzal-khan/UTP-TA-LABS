#import "/.shared/typst/utp.typ": *
#unit("labs", "01-unbundling-teardown")

#labsection(1, label: <sec:lab01-unbundling>)[Unbundling teardown of an incumbent bank]

#labproject[Map a bank’s value chain and find where it is being taken apart][
  #strong[Coverage.] Chapter~#ref(<ch:intro-fintech>). \

  #strong[Goal.] Turn the week’s mental model --- friction, then technology-enabled redesign, then new value proposition, then new risk --- into a defensible written assessment of one real institution.

  #include "visuals/01-flow.typ"

  #note[
    This is an analysis lab, not a coding lab. The script exists to keep your scoring arithmetic honest and reproducible; the marks are in the argument you build around its output.

    Choose one incumbent retail bank you can research in English. Maybank, CIMB, DBS, HSBC, and Lloyds all publish enough in their annual reports to work with. Use the same bank for the rest of the course where possible, so later labs compound.
  ]

  #v(6pt)
  #strong[Part A --- Decompose the value chain.]

  A universal bank is not one business. It is roughly seven, bundled together and sold behind one brand:

  #utptable[
    #tabularx(
      columns: (22%, 1fr, 1fr),
      styles: (navy-bold,),
      header: ([Value-chain segment], [What the bank actually provides], [Typical challenger]),
      [Payments], [Moving money between parties], [Wise, Stripe, GrabPay],
      [Deposits], [Safekeeping and interest], [Neobanks, money-market apps],
      [Lending], [Credit assessment and balance sheet], [P2P platforms, BNPL],
      [Wealth], [Advice and portfolio construction], [Robo-advisers],
      [Foreign exchange], [Currency conversion], [Wise, Revolut],
      [SME services], [Accounts, credit, cash management], [Tide, Aspire],
      [Trust and compliance], [Regulatory licence, KYC, deposit guarantee], [Rarely attacked directly],
    )
  ]

  For your chosen bank, record segment revenue estimates in your assessment with the report, year and page. Mark undisclosed values as unknown. The generated `value_chain.csv` contains the four scoring criteria; replace the example ratings in the script’s `rows` list with evidence-based ratings and retain a copy of your original run.

  #v(6pt)
  #strong[Part B --- Score disruption likelihood.]

  Chapter~@ch:intro-fintech argues that disruption concentrates where four conditions hold together: high customer friction, weak regulatory moat, low capital intensity, and a data or network advantage available to the entrant.

  Score each segment 1--5 on all four, where #strong[5 always means more favourable to the challenger]. Moat and capital are therefore inverted relative to the bank’s strength --- a strong regulatory moat scores 1, not 5. Getting that direction wrong inverts your entire analysis, so state the convention in your write-up.

  #strong[Complete worked example.] This runnable fixture uses synthetic inputs. First reproduce it, then adapt the data or ratings with documented evidence. All code below belongs to one file.

  ```terminal
  python all_experiments/lab01_unbundling_scorecard.py
  ```

  #strong[Setup and output folder.]

  #lstinput("/FINTECH INNOVATION/all_experiments/lab01_unbundling_scorecard.py", first: 1, last: 10, lang: "python")

  #strong[Build an explicit scoring fixture.]

  #lstinput("/FINTECH INNOVATION/all_experiments/lab01_unbundling_scorecard.py", first: 11, last: 24, lang: "python")

  #strong[Load, validate, then rank.]

  #include "visuals/01-trace.typ"

  #strong[Use the chapter while coding.] Revisit #link(<ch:intro-fintech>)[the earlier chapter explanation]; match its operation to the variables and state changes below.

  #strong[Follow the supplied implementation.] Read the criterion order before changing weights. weak\_moat and low\_capital are already oriented so a larger value favours the challenger. The program regenerates its input fixture, so edit rows for a changed fixture rather than expecting a generated CSV edit to persist.

  #include "visuals/01-worked-case.typ"

  #lstinput("/FINTECH INNOVATION/all_experiments/lab01_unbundling_scorecard.py", first: 25, last: 39, lang: "python")

  #strong[Save evidence separately from the numeric score.]

  #lstinput("/FINTECH INNOVATION/all_experiments/lab01_unbundling_scorecard.py", first: 40, last: 47, lang: "python")

  #include "visuals/01-result.typ"

  #strong[Check the run.] The following output was captured from the supplied script; it describes the synthetic fixture only.

  #lstinput("/FINTECH INNOVATION/labs/outputs/lab01.txt", lang: "terminal")

  The worked script gives each factor weight 0.25. This is an explicit classroom assumption, not an empirical estimate. Change one weight, rebalance the others so they sum to one, and explain how the ranking changes.

  #exercises[
    Payments lands at exactly 3.00 here and is not flagged, yet payments is the most visibly disrupted segment in the real market. Something is wrong with the model.

    Work out what. Is the moat score too generous, is capital intensity mis-scored for a payments challenger who never touches a balance sheet, or is the weighting itself at fault? Adjust one input, justify it, and note how much the ranking moves --- a model that is stable under reasonable disagreement is worth more than one that is not.
  ]

  #warning[
    A high score is a hypothesis, not a finding. The scorecard tells you where to look; it cannot tell you whether anyone has actually succeeded there.

    Every segment you rank above 3.0 needs a named challenger and evidence they have taken real volume. If you cannot name one, your score is wrong or the moat is stronger than you assessed --- either way, revise it and say why.
  ]

  #v(6pt)
  #strong[Part C --- Distinguish disintermediation from unbundling.]

  These two words are used interchangeably in casual writing and mean different things here. Classify each challenger you identified:

  - #strong[Unbundling] --- the challenger takes one segment and does it better. The bank keeps the rest. A remittance app does not want your mortgage.
  - #strong[Disintermediation] --- the challenger removes the bank from the transaction entirely. A P2P platform connects lender to borrower with no balance sheet in between.

  The distinction matters because the defences differ. Unbundling is answered by improving the attacked segment or partnering. Disintermediation is answered by changing what you are for.

  #exercises[
    Find one case where a challenger unbundled a segment and then #emph[rebundled] --- added adjacent products until it resembled a bank again. Revolut and Grab are both defensible choices.

    Then answer the question that case raises: if challengers converge on the incumbent model, was the original bundle inefficient, or is bundling simply what customers want once trust is established?
  ]
]

#strong[Chapter connection.] Revisit #link(<ch:intro-fintech>)[the chapter explanation] and map its states to the steps below.

#include "visuals/01-unbundling-teardown-chapter.typ"

#checklist[
  #strong[Explain and extend your result.] Change one rating or one weight while keeping weights summing to one. Report any ranking reversal and identify which research evidence would resolve the sensitive assumption.

  - Every revenue figure is sourced to a named report, page, and year.
  - Segments where the bank does not disclose a breakdown are marked as estimates, not stated as fact.
  - Every segment scored above 3.0 names a real challenger with evidence of volume.
  - Each challenger is classified as unbundling or disintermediation, with a reason.
]
