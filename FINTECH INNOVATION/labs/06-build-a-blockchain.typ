#import "/.shared/typst/utp.typ": *
#unit("labs", "06-build-a-blockchain")

#lab("6")[Build a blockchain from first principles] <sec:lab06-blockchain>

#callout("labproject", title: [Implement hashing, Merkle roots, chaining, and proof of work --- then break it])[#strong[Coverage.] Chapter~#ref(label("ch:blockchain"), supplement: none). \
#strong[Goal.] Build the structure Chapter~#ref(label("ch:blockchain"), supplement: none) describes, using a complete standard-library Python program, then detect tampering and explain why a real consensus network requires more than hash links.


#include "/FINTECH INNOVATION/labs/visuals/06-flow.typ"
]

#strong[Complete worked example.] This runnable fixture uses synthetic inputs. First reproduce it, then adapt the data or ratings with documented evidence. All code below belongs to one file. #code-block("python all_experiments/lab06_build_a_blockchain.py", lang: "text")

#strong[Setup and output folder.] #source-code("/FINTECH INNOVATION/all_experiments/lab06_build_a_blockchain.py", first: 1, last: 10, lang: "python")

#strong[Hash unambiguous serialised data.] #source-code("/FINTECH INNOVATION/all_experiments/lab06_build_a_blockchain.py", first: 11, last: 28, lang: "python")

#strong[Define the block and bounded proof of work.] 
#include "/FINTECH INNOVATION/labs/visuals/06-trace.typ"
 #source-code("/FINTECH INNOVATION/all_experiments/lab06_build_a_blockchain.py", first: 29, last: 47, lang: "python")

#strong[Build the complete chain, including genesis.] #source-code("/FINTECH INNOVATION/all_experiments/lab06_build_a_blockchain.py", first: 48, last: 55, lang: "python")

#strong[Verify every block, then deliberately tamper.]

#strong[Use the chapter while coding.] Revisit #link(label("ch:blockchain"))[the earlier chapter explanation]; match its operation to the variables and state changes below.

#strong[Follow the supplied implementation.] The changed transaction alters block 2's Merkle root and hash. Block 3 still stores the old hash. Proof-of-work validity is checked independently; do not rely on a specific extra proof-of-work failure when explaining the guaranteed linkage failure. 
#include "/FINTECH INNOVATION/labs/visuals/06-worked-case.typ"


#source-code("/FINTECH INNOVATION/all_experiments/lab06_build_a_blockchain.py", first: 56, last: 78, lang: "python") 
#include "/FINTECH INNOVATION/labs/visuals/06-result.typ"
 #strong[Check the run.] The following output was captured from the supplied script; it describes the synthetic fixture only. #source-code("/FINTECH INNOVATION/labs/outputs/lab06.txt", first: 1, last: none, lang: "text") 
#include "/FINTECH INNOVATION/labs/visuals/06-build-a-blockchain-chapter.typ"


#callout("verification", title: [Verification checklist])[#strong[Explain and extend your result.] Tamper with one transaction and report the first failed validation check. Explain the downstream work required to rebuild the local chain and why that alone does not model a real consensus attack.

- The script runs from a fresh process and creates the named CSV or report files.

- Every rate uses a stated population and denominator; every model assumption is identified.

- Synthetic outputs are labelled and are not presented as observations of a real institution.

- Change one input, rerun, and explain the direction of the result.]
