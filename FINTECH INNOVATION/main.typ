// Fintech Innovation: the book. Settings first, then the chapters and labs in teaching order.
#import "/.shared/typst/utp.typ": *
#show: book.with(
  title: [FinTech Innovation],
  running-head: [FinTech Innovation Notes],
  outline: [Explores FinTech through financial inclusion, digital banking, crowdfunding, blockchain, and cryptocurrency.],
  lab-total: 8,
  contents: (part: 1.50em, chapter: 1.10em, lab: 0.40em),
)
#cover()
#contents()
#include "chapters/course-map.typ"
#show: mainmatter

#include "chapters/00-toolkit.typ"

#part[FinTech Foundations and Access]
#include "chapters/01-introduction-to-fintech.typ"

#include "chapters/02-financial-inclusion.typ"
#include "labs/01-unbundling-teardown.typ"
#include "labs/02-measuring-inclusion.typ"

#part[Alternative Finance and Digital Banking]
#include "chapters/03-p2p-and-crowdfunding.typ"
#include "labs/03-p2p-loan-book.typ"

#include "chapters/04-mobile-and-internet-banking.typ"
#include "labs/04-mobile-banking-audit.typ"

#include "chapters/05-digital-only-banks.typ"
#include "labs/05-neobank-unit-economics.typ"

#part[Distributed Infrastructure and Platform Competition]
#include "chapters/06-blockchain.typ"
#include "labs/06-build-a-blockchain.typ"

#include "chapters/07-big-tech-in-fintech.typ"
#include "labs/07-platform-competition.typ"

#include "chapters/08-cryptocurrencies.typ"
#include "labs/08-crypto-as-money.typ"

#include "chapters/final-revision-map.typ"
