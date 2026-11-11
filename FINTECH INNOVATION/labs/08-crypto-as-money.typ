#import "/.shared/typst/utp.typ": *
#unit("labs", "08-crypto-as-money")

#lab("8")[Testing whether a cryptocurrency is money] <sec:lab08-crypto>

#callout("labproject", title: [Apply the three-function test with evidence rather than opinion])[#strong[Coverage.] Chapter~#ref(label("ch:cryptocurrencies"), supplement: none). \
#strong[Goal.] Measure the properties Chapter~#ref(label("ch:cryptocurrencies"), supplement: none) discusses qualitatively, and reach a defensible verdict on each of money's three functions.


#include "/FINTECH INNOVATION/labs/visuals/08-flow.typ"
]

#strong[Complete worked example.] This runnable fixture uses synthetic inputs. First reproduce it, then adapt the data or ratings with documented evidence. All code below belongs to one file. #code-block("python all_experiments/lab08_crypto_as_money.py", lang: "text")

#strong[Setup and output folder.] #source-code("/FINTECH INNOVATION/all_experiments/lab08_crypto_as_money.py", first: 1, last: 10, lang: "python")

#strong[Generate comparable daily teaching series.] #source-code("/FINTECH INNOVATION/all_experiments/lab08_crypto_as_money.py", first: 11, last: 23, lang: "python")

#strong[Measure volatility on the same observation frequency.] 
#include "/FINTECH INNOVATION/labs/visuals/08-trace.typ"


#strong[Use the chapter while coding.] Revisit #link(label("ch:cryptocurrencies"))[the earlier chapter explanation]; match its operation to the variables and state changes below.

#strong[Follow the supplied implementation.] The frequency factor belongs to this daily fixture. Inspect the dates and missing values before reusing it for another series. Recovery is the gain from the trough back to the prior peak, not the negative of the drawdown percentage. 
#include "/FINTECH INNOVATION/labs/visuals/08-worked-case.typ"


#source-code("/FINTECH INNOVATION/all_experiments/lab08_crypto_as_money.py", first: 24, last: 30, lang: "python")

#strong[Measure path-dependent drawdown and recovery.] #source-code("/FINTECH INNOVATION/all_experiments/lab08_crypto_as_money.py", first: 31, last: 39, lang: "python")

#strong[Compare explicit payment assumptions.] #source-code("/FINTECH INNOVATION/all_experiments/lab08_crypto_as_money.py", first: 40, last: 45, lang: "python") 
#include "/FINTECH INNOVATION/labs/visuals/08-result.typ"
 #strong[Check the run.] The following output was captured from the supplied script; it describes the synthetic fixture only. #source-code("/FINTECH INNOVATION/labs/outputs/lab08.txt", first: 1, last: none, lang: "text") 
#include "/FINTECH INNOVATION/labs/visuals/08-crypto-as-money-chapter.typ"


#callout("verification", title: [Verification checklist])[#strong[Explain and extend your result.] Identify the largest synthetic drawdown and calculate the recovery needed. Compare each fee with a small purchase amount and state which assumption most affects payment practicality.

- The script runs from a fresh process and creates the named CSV or report files.

- Every rate uses a stated population and denominator; every model assumption is identified.

- Synthetic outputs are labelled and are not presented as observations of a real institution.

- Change one input, rerun, and explain the direction of the result.]
