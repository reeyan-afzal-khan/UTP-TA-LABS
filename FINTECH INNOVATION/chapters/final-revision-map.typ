#import "/.shared/typst/utp.typ": *
#unit("chapters", "final-revision-map")


#heading(level: 1, numbering: none)[Final Revision Map]


Use this section after completing all eight chapters. It compresses the course into the comparisons and causal chains most likely to help in revision.


#heading(level: 2, numbering: none)[The complete course in one chain]


#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/FINTECH INNOVATION/figures/diagrams/b12dc9b29a0fe354.cetz.json")], caption: [The complete course in one chain. Customer friction and digital technology drive unbundling and new platforms, and each branch of the course follows from one link in that chain.]) <fig:revision-chain>


#heading(level: 2, numbering: none)[Eight concepts you must distinguish]


#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Concept], [Distinction to remember],),
    table.hline(),
    [Disintermediation vs unbundling], [Disintermediation changes the intermediary; unbundling separates a one-stop provider into specialist services.],
    [Unbanked vs underbanked], [Unbanked means no formal account; underbanked means partial or insufficient use of mainstream services.],
    [Traditional lending vs P2P], [Bank lending uses the bank balance sheet and pooling; P2P matches investors and borrowers through a platform.],
    [Donation vs reward vs debt vs equity crowdfunding], [No return; non-financial reward; repayment with interest; ownership claim.],
    [UX vs CX], [UX is interface interaction; CX is the entire relationship including reliability, support, security, price, and access.],
    [Neobank vs challenger bank], [In the Week 5 lecture, no full banking license versus full banking license.],
    [Centralized database vs blockchain], [Single authoritative state versus replicated, cryptographically linked records governed by network validation/consensus.],
    [FinTech vs TechFin], [Finance-led technology innovation versus technology-platform-led expansion into financial services.],
  )]
  , kind: table
  )


#heading(level: 2, numbering: none)[Recurring FinTech value proposition]


Most cases in the course can be decomposed into five claims:

+ #strong[Lower cost] through automation, digital distribution, cloud infrastructure, and reduced physical overhead.

+ #strong[Faster service] through fewer manual approval layers and real-time data.

+ #strong[Better customer experience] through intuitive interfaces, transparency, alerts, personalization, and continuous access.

+ #strong[Better matching or risk assessment] through platforms and additional data sources.

+ #strong[Greater access] for customers and businesses who are difficult to serve through legacy economics.

Whenever you make one of these claims in an answer, pair it with a limitation: security, privacy, credit loss, lack of guarantees, regulation, sustainability, integration, or market concentration.


#heading(level: 2, numbering: none)[Recurring technology stack]


#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Technology], [Role in the course],),
    table.hline(),
    [Mobile], [Continuous financial access, notifications, biometrics, camera/OCR, contactless interaction],
    [Cloud], [Scalable modern infrastructure and faster deployment for digital banks and incumbents],
    [APIs], [Connect banks to third-party applications and enable platform/open-banking models],
    [Big data / analytics], [Personalization, credit assessment, fraud detection, and predictive intelligence],
    [AI / automation], [Faster decisions, conversational assistance, process efficiency, and robo-advice],
    [Blockchain], [Shared, cryptographically linked transaction history without one authoritative ledger copy],
    [Cryptography], [Key ownership, transaction authorization, hashing, signatures, and proof-of-work mechanisms],
  )]
  , kind: table
  )


#heading(level: 2, numbering: none)[Recurring business-model tension]


The most important business tension across P2P lending, neobanks, Big Tech, and crypto is:

#block[
#strong[growth and access] $quad arrow.l.r quad$ #strong[risk, trust, regulation, and sustainable economics]

]
A good exam answer should explain both sides. Technology can lower one cost while creating another. Removing a bank intermediary can improve price while moving risk to investors. Giving users private-key control increases freedom while reducing recoverability. A neobank can acquire users cheaply while still failing to monetize them sustainably.


#heading(level: 2, numbering: none)[Fast comparison: who owns the customer relationship?]


#figure(
  align(center)[#table(
    columns: 4,
    align: (left,left,left,left,),
    table.header([Model], [Primary interface], [Strategic asset], [Main vulnerability],),
    table.hline(),
    [Traditional bank], [Branch + bank-owned digital channels], [Trust, license, balance sheet, customer history], [Legacy cost and slower change],
    [P2P platform], [Marketplace], [Matching, scoring, low-cost distribution], [Credit risk and weak guarantees],
    [Digital-only bank], [Mobile-first account], [CX, modern architecture, data, low servicing cost], [Profitability and trust at scale],
    [Big Tech / TechFin], [Existing super-platform], [User base, engagement, data, ecosystem], [Regulatory exposure and financial-brand risk],
    [Cryptocurrency network], [Wallet + protocol], [Decentralized transfer and user-controlled keys], [Volatility, custody, governance, scalability, regulation],
  )]
  , kind: table
  )


#heading(level: 2, numbering: none)[Exam-answer structure]


For an "analyze" or "evaluate" question, use this order:

+ #strong[Define the model precisely.]

+ #strong[Identify the traditional friction or market failure.]

+ #strong[Explain the enabling technology and business-model change.]

+ #strong[State the benefit to each stakeholder.]

+ #strong[State the risk or limitation to each stakeholder.]

+ #strong[Explain the incumbent or regulatory response.]

+ #strong[Conclude with the condition under which the innovation creates sustainable value.]

#callout("quickcheck", title: [Check your understanding])[Without looking back, answer these eight prompts in one or two sentences each:

+ Why did the 2008 crisis help create an opening for FinTech?

+ How do digital financial services change the economics of financial inclusion?

+ Why can P2P lending serve a borrower rejected by a bank?

+ Why does a good mobile app still depend on legacy core integration?

+ Why can a digital-only bank have millions of users and still lose money?

+ How do hash references make blockchain history tamper-evident?

+ Why does Big Tech care about financial services even if direct banking profit is modest?

+ Why is Bitcoin's private-key model both empowering and risky?]
