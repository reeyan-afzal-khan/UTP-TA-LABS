#import "/.shared/typst/utp.typ": *
#show: book.with(title: [FinTech Innovation], summary: [Explores FinTech through financial inclusion, digital banking, crowdfunding, blockchain, and cryptocurrency.], lab-total: 8)

#cover(title: [FinTech Innovation], summary: [Explores FinTech through financial inclusion, digital banking, crowdfunding, blockchain, and cryptocurrency.])
#outline(depth: 1)
#pagebreak()
#include "chapters/course-map.typ"

#include "/FINTECH INNOVATION/chapters/00-toolkit.typ"


#stage[FinTech Foundations and Access] 
#include "/FINTECH INNOVATION/chapters/01-introduction-to-fintech.typ"



#include "/FINTECH INNOVATION/chapters/02-financial-inclusion.typ"
 
#include "/FINTECH INNOVATION/labs/01-unbundling-teardown.typ"
 
#include "/FINTECH INNOVATION/labs/02-measuring-inclusion.typ"


#stage[Alternative Finance and Digital Banking] 
#include "/FINTECH INNOVATION/chapters/03-p2p-and-crowdfunding.typ"
 
#include "/FINTECH INNOVATION/labs/03-p2p-loan-book.typ"



#include "/FINTECH INNOVATION/chapters/04-mobile-and-internet-banking.typ"
 
#include "/FINTECH INNOVATION/labs/04-mobile-banking-audit.typ"



#include "/FINTECH INNOVATION/chapters/05-digital-only-banks.typ"
 
#include "/FINTECH INNOVATION/labs/05-neobank-unit-economics.typ"


#stage[Distributed Infrastructure and Platform Competition] 
#include "/FINTECH INNOVATION/chapters/06-blockchain.typ"
 
#include "/FINTECH INNOVATION/labs/06-build-a-blockchain.typ"



#include "/FINTECH INNOVATION/chapters/07-big-tech-in-fintech.typ"
 
#include "/FINTECH INNOVATION/labs/07-platform-competition.typ"



#include "/FINTECH INNOVATION/chapters/08-cryptocurrencies.typ"
 
#include "/FINTECH INNOVATION/labs/08-crypto-as-money.typ"



#include "/FINTECH INNOVATION/chapters/final-revision-map.typ"

