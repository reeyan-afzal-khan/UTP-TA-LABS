#import "/.shared/typst/utp.typ": *


#heading(level: 1, numbering: none)[Course Map]


This course is easiest to understand as one connected story: technology changes how financial services are delivered, which expands access, creates new intermediaries, reshapes banks, and finally enables new infrastructure and platform competitors. Three stages tell that story; the final revision map compresses it.

#callout("utpfigure", title: [])[#diagram-image("/FINTECH INNOVATION/figures/diagrams/4ff3129e0075b985.svg")]

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Stage], [Focus], [Key question],),
    table.hline(),
    [1], [FinTech foundations and financial inclusion], [Why did FinTech emerge, and whom does finance still fail to serve?],
    [2], [Alternative finance and digital banking], [How are lending and banking redesigned around digital channels?],
    [3], [Distributed infrastructure and platforms], [Who controls the ledger, the customer interface, and money itself?],
  )]
  , kind: table
  )

#callout("keyidea", title: [Key idea])[The recurring pattern across the course is #emph[friction $arrow.r$ technology-enabled redesign $arrow.r$ new value proposition $arrow.r$ new risks and regulation]. Use that pattern to connect apparently different topics such as P2P lending, neobanks, blockchain, Big Tech, and cryptocurrency.]

#callout("libnote", title: [Reference note])[#strong[About dated facts.] The lecture decks contain market statistics, company valuations, product examples, and regulatory statements from several different years. In these notes such figures are labeled as lecture snapshots. They are useful for understanding the argument being taught, but they should not be interpreted as current market data unless separately verified.]


#heading(level: 2, numbering: none)[The story the course tells]


#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Step], [Where], [Topics],),
    table.hline(),
    [1. Why FinTech emerged], [Week 1, Chapter 1], [Traditional intermediation, disintermediation, unbundling, customer friction, technology drivers, and incumbent challenges.],
    [2. Who finance still fails to serve], [Week 2, Chapter 2], [Unbanked and underbanked customers, financial inclusion, digital financial services, alternative data, and access constraints.],
    [3. How intermediation is redesigned], [Weeks 3--5, Chapters 3--5], [P2P lending and crowdfunding, mobile banking, platform banking, neobanks, challenger banks, customer experience, profitability, and regulation.],
    [4. How the financial infrastructure changes], [Weeks 6--7, Chapter 6], [Distributed ledgers, cryptography, blocks, Merkle trees, nodes, miners, immutability, and smart contracts.],
    [5. Who controls the customer interface], [Week 8, Chapter 7], [Big Tech, TechFin, GAFA/BAT, super apps, data advantages, incumbent bank assets, and platform competition.],
    [6. What happens when money becomes digital], [Week 9, Chapter 8], [Cryptocurrencies, Bitcoin wallets and mining, forks, currency functions, benefits, risks, scalability, and cryptoization.],
  )]
  , kind: table
  )
