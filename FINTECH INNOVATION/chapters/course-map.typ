#import "/.shared/typst/utp.typ": *

#chapter-star[Course Map]

This course is easiest to understand as one connected story: technology changes how financial services are delivered, which expands access, creates new intermediaries, reshapes banks, and finally enables new infrastructure and platform competitors. Three stages tell that story; the final revision map compresses it.

#utpfigure[
  #canvas({
    node((0, 0), [#coursemapcard([STAGE 01], [Foundations], [Why FinTech emerged, and who it can reach])], name: "a", ..card)
    node(right-of("a", 0.66), [#coursemapcard([STAGE 02], [Alternative finance], [P2P lending, mobile and digital banks])], name: "b", ..card)
    node(right-of("b", 0.66), [#coursemapcard([STAGE 03], [Infrastructure], [Blockchain, Big Tech, and crypto])], name: "c", ..finalcard)
    connect("a", "b", ..arr)
    connect("b", "c", ..arr)
  })
]

#utptable[
  #tabularx(
    columns: (8%, 31%, 1fr),
    align: (center, left, left),
    styles: (navy-bold,),
    header: ([Stage], [Focus], [Key question]),
    [1], [FinTech foundations and financial inclusion], [Why did FinTech emerge, and whom does finance still fail to serve?],
    [2], [Alternative finance and digital banking], [How are lending and banking redesigned around digital channels?],
    [3], [Distributed infrastructure and platforms], [Who controls the ledger, the customer interface, and money itself?],
  )
]

#keyidea[
  The recurring pattern across the course is #emph[friction $arrow.r$ technology-enabled redesign $arrow.r$ new value proposition $arrow.r$ new risks and regulation]. Use that pattern to connect apparently different topics such as P2P lending, neobanks, blockchain, Big Tech, and cryptocurrency.
]

#libnote[
  #strong[About dated facts.] The lecture decks contain market statistics, company valuations, product examples, and regulatory statements from several different years. In these notes such figures are labeled as lecture snapshots. They are useful for understanding the argument being taught, but they should not be interpreted as current market data unless separately verified.
]

#pagebreak()

#heading(depth: 2, numbering: none)[The story the course tells]

#utptable[
  #tabularx(
    columns: (27%, 15%, 1fr),
    align: (left, center, left),
    styles: (navy-bold,),
    header: ([Step], [Where], [Topics]),
    [1\. Why FinTech emerged], [Week 1, Chapter 1], [Traditional intermediation, disintermediation, unbundling, customer friction, technology drivers, and incumbent challenges.],
    [2\. Who finance still fails to serve], [Week 2, Chapter 2], [Unbanked and underbanked customers, financial inclusion, digital financial services, alternative data, and access constraints.],
    [3\. How intermediation is redesigned], [Weeks 3--5, Chapters 3--5], [P2P lending and crowdfunding, mobile banking, platform banking, neobanks, challenger banks, customer experience, profitability, and regulation.],
    [4\. How the financial infrastructure changes], [Weeks 6--7, Chapter 6], [Distributed ledgers, cryptography, blocks, Merkle trees, nodes, miners, immutability, and smart contracts.],
    [5\. Who controls the customer interface], [Week 8, Chapter 7], [Big Tech, TechFin, GAFA/BAT, super apps, data advantages, incumbent bank assets, and platform competition.],
    [6\. What happens when money becomes digital], [Week 9, Chapter 8], [Cryptocurrencies, Bitcoin wallets and mining, forks, currency functions, benefits, risks, scalability, and cryptoization.],
  )
]
