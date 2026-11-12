#import "/.shared/typst/utp.typ": *
#unit("labs", "08-crypto-as-money")

#labsection(8, label: <sec:lab08-crypto>)[Testing whether a cryptocurrency is money]

#labproject[Apply the three-function test with evidence rather than opinion][
  #strong[Coverage.] Chapter~#ref(<ch:cryptocurrencies>). \

  #strong[Goal.] Measure the properties Chapter~@ch:cryptocurrencies discusses qualitatively, and reach a defensible verdict on each of money’s three functions.

  #include "visuals/08-flow.typ"
]

#strong[Complete worked example.] This runnable fixture uses synthetic inputs. First reproduce it, then adapt the data or ratings with documented evidence. All code below belongs to one file.

```terminal
python all_experiments/lab08_crypto_as_money.py
```

#strong[Setup and output folder.]

#lstinput("/FINTECH INNOVATION/all_experiments/lab08_crypto_as_money.py", first: 1, last: 10, lang: "python")

#strong[Generate comparable daily teaching series.]

#lstinput("/FINTECH INNOVATION/all_experiments/lab08_crypto_as_money.py", first: 11, last: 23, lang: "python")

#strong[Measure volatility on the same observation frequency.]

#include "visuals/08-trace.typ"

#strong[Use the chapter while coding.] Revisit #link(<ch:cryptocurrencies>)[the earlier chapter explanation]; match its operation to the variables and state changes below.

#strong[Follow the supplied implementation.] The frequency factor belongs to this daily fixture. Inspect the dates and missing values before reusing it for another series. Recovery is the gain from the trough back to the prior peak, not the negative of the drawdown percentage.

#include "visuals/08-worked-case.typ"

#lstinput("/FINTECH INNOVATION/all_experiments/lab08_crypto_as_money.py", first: 24, last: 30, lang: "python")

#strong[Measure path-dependent drawdown and recovery.]

#lstinput("/FINTECH INNOVATION/all_experiments/lab08_crypto_as_money.py", first: 31, last: 39, lang: "python")

#strong[Compare explicit payment assumptions.]

#lstinput("/FINTECH INNOVATION/all_experiments/lab08_crypto_as_money.py", first: 40, last: 45, lang: "python")

#include "visuals/08-result.typ"

#strong[Check the run.] The following output was captured from the supplied script; it describes the synthetic fixture only.

#lstinput("/FINTECH INNOVATION/labs/outputs/lab08.txt", lang: "terminal")

#include "visuals/08-crypto-as-money-chapter.typ"

#verification[
  #strong[Explain and extend your result.] Identify the largest synthetic drawdown and calculate the recovery needed. Compare each fee with a small purchase amount and state which assumption most affects payment practicality.

  - The script runs from a fresh process and creates the named CSV or report files.
  - Every rate uses a stated population and denominator; every model assumption is identified.
  - Synthetic outputs are labelled and are not presented as observations of a real institution.
  - Change one input, rerun, and explain the direction of the result.
]
