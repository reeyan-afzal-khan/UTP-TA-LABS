#import "/.shared/typst/utp.typ": *
#unit("labs", "03-p2p-loan-book")

#lab("3")[P2P loan-book economics and diversification] <sec:lab03-p2p>

#callout("labproject", title: [Price credit risk, then prove diversification does what the chapter claims])[#strong[Coverage.] Chapter~#ref(label("ch:p2p-crowdfunding"), supplement: none). \
#strong[Goal.] Compute the return an investor actually receives on a P2P loan book, and demonstrate numerically why concentration is the risk that ruins retail lenders.


#include "/FINTECH INNOVATION/labs/visuals/03-flow.typ"
]

#strong[Complete worked example.] This runnable fixture uses synthetic inputs. First reproduce it, then adapt the data or ratings with documented evidence. All code below belongs to one file. #code-block("python all_experiments/lab03_p2p_loan_book.py", lang: "text")

#strong[Setup and output folder.] #source-code("/FINTECH INNOVATION/all_experiments/lab03_p2p_loan_book.py", first: 1, last: 10, lang: "python")

#strong[Create loans with transparent grade assumptions.] #source-code("/FINTECH INNOVATION/all_experiments/lab03_p2p_loan_book.py", first: 11, last: 24, lang: "python")

#strong[Use one consistent cash-flow model.] 
#include "/FINTECH INNOVATION/labs/visuals/03-trace.typ"


#strong[Use the chapter while coding.] Revisit #link(label("ch:p2p-crowdfunding"))[the earlier chapter explanation]; match its operation to the variables and state changes below.

#strong[Follow the supplied implementation.] Return and loss are different columns with different meanings. Follow np.where to see which return branch applies, then inspect one actual default row. The portfolio bootstrap samples these realised loan returns independently; it does not model correlated default shocks. 
#include "/FINTECH INNOVATION/labs/visuals/03-worked-case.typ"


#source-code("/FINTECH INNOVATION/all_experiments/lab03_p2p_loan_book.py", first: 25, last: 36, lang: "python")

#strong[Resample equal-weight portfolios.] #source-code("/FINTECH INNOVATION/all_experiments/lab03_p2p_loan_book.py", first: 37, last: 48, lang: "python") 
#include "/FINTECH INNOVATION/labs/visuals/03-result.typ"
 #strong[Check the run.] The following output was captured from the supplied script; it describes the synthetic fixture only. #source-code("/FINTECH INNOVATION/labs/outputs/lab03.txt", first: 1, last: none, lang: "text") 
#include "/FINTECH INNOVATION/labs/visuals/03-p2p-loan-book-chapter.typ"


#callout("verification", title: [Verification checklist])[#strong[Explain and extend your result.] Compare portfolio sizes using mean return and downside quantiles. Explain why a narrower simulated distribution is conditional on the independence assumption.

- The script runs from a fresh process and creates the named CSV or report files.

- Every rate uses a stated population and denominator; every model assumption is identified.

- Synthetic outputs are labelled and are not presented as observations of a real institution.

- Change one input, rerun, and explain the direction of the result.]
