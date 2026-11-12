#import "/.shared/typst/utp.typ": *
#unit("chapters", "final-revision-map")

#chapter-star[Final Revision Map]

Use this section after completing all eight chapters. It compresses the course into the comparisons and causal chains most likely to help in revision.

#heading(depth: 2, numbering: none)[The complete course in one chain]

#utpfig([The complete course in one chain. Customer friction and digital technology drive unbundling and new platforms, and each branch of the course follows from one link in that chain.], label: <fig:revision-chain>)[
  #canvas({
    let b = (draw: blue, fill: pale-blue, rounded: 2mm, text-width: 2.45, min-height: 1.15, align: center, font: font("script", weight: "bold", fill: navy))
    let g = (draw: green, fill: pale-teal, rounded: 2mm, text-width: 2.45, min-height: 1.15, align: center, font: font("script", weight: "bold", fill: navy))
    let o = (draw: orange, fill: pale-orange, rounded: 2mm, text-width: 2.45, min-height: 1.15, align: center, font: font("script", weight: "bold", fill: navy))
    let arr = (line-width: widths.thick, draw: teal, end: tip("Stealth", length: 1.8mm, line: widths.thick))
    node((-5.2, 1.2), [Traditional \
  intermediation], name: "a", ..b)
    node((-2.6, 1.2), [Customer \
  friction], name: "b", ..b)
    node((0, 1.2), [Digital \
  technology], name: "c", ..g)
    node((2.6, 1.2), [Unbundling + \
  new platforms], name: "d", ..g)
    node((5.2, 1.2), [Competition + \
  new risks], name: "e", ..o)
    node((-3.9, -1.2), [Financial \
  inclusion], name: "f", ..b)
    node((-1.3, -1.2), [P2P / mobile / \
  digital banks], name: "g", ..g)
    node((1.3, -1.2), [Blockchain + \
  crypto], name: "h", ..o)
    node((3.9, -1.2), [Big Tech + \
  ecosystems], name: "i", ..o)
    connect("a", "b", ..arr)
    connect("b", "c", ..arr)
    connect("c", "d", ..arr)
    connect("d", "e", ..arr)
    connect("b", "f", bend: -24deg, ..arr, name: "curve-1")
    connect("c", "g", bend: -14deg, ..arr, name: "curve-2")
    connect("c", "h", bend: 10deg, ..arr, name: "curve-3")
    connect("d", "i", bend: 24deg, ..arr, name: "curve-4")
  })
]

#heading(depth: 2, numbering: none)[Eight concepts you must distinguish]

#utptable[
  #tabularx(
    columns: (27%, 1fr),
    styles: (navy-bold,),
    header: ([Concept], [Distinction to remember]),
    [Disintermediation vs unbundling], [Disintermediation changes the intermediary; unbundling separates a one-stop provider into specialist services.],
    [Unbanked vs underbanked], [Unbanked means no formal account; underbanked means partial or insufficient use of mainstream services.],
    [Traditional lending vs P2P], [Bank lending uses the bank balance sheet and pooling; P2P matches investors and borrowers through a platform.],
    [Donation vs reward vs debt vs equity crowdfunding], [No return; non-financial reward; repayment with interest; ownership claim.],
    [UX vs CX], [UX is interface interaction; CX is the entire relationship including reliability, support, security, price, and access.],
    [Neobank vs challenger bank], [In the Week 5 lecture, no full banking license versus full banking license.],
    [Centralized database vs blockchain], [Single authoritative state versus replicated, cryptographically linked records governed by network validation/consensus.],
    [FinTech vs TechFin], [Finance-led technology innovation versus technology-platform-led expansion into financial services.],
  )
]

#heading(depth: 2, numbering: none)[Recurring FinTech value proposition]

Most cases in the course can be decomposed into five claims:

+ #term[Lower cost] through automation, digital distribution, cloud infrastructure, and reduced physical overhead.
+ #term[Faster service] through fewer manual approval layers and real-time data.
+ #term[Better customer experience] through intuitive interfaces, transparency, alerts, personalization, and continuous access.
+ #term[Better matching or risk assessment] through platforms and additional data sources.
+ #term[Greater access] for customers and businesses who are difficult to serve through legacy economics.

Whenever you make one of these claims in an answer, pair it with a limitation: security, privacy, credit loss, lack of guarantees, regulation, sustainability, integration, or market concentration.

#heading(depth: 2, numbering: none)[Recurring technology stack]

#utptable[
  #tabularx(
    columns: (22%, 1fr),
    styles: (navy-bold,),
    header: ([Technology], [Role in the course]),
    [Mobile], [Continuous financial access, notifications, biometrics, camera/OCR, contactless interaction],
    [Cloud], [Scalable modern infrastructure and faster deployment for digital banks and incumbents],
    [APIs], [Connect banks to third-party applications and enable platform/open-banking models],
    [Big data / analytics], [Personalization, credit assessment, fraud detection, and predictive intelligence],
    [AI / automation], [Faster decisions, conversational assistance, process efficiency, and robo-advice],
    [Blockchain], [Shared, cryptographically linked transaction history without one authoritative ledger copy],
    [Cryptography], [Key ownership, transaction authorization, hashing, signatures, and proof-of-work mechanisms],
  )
]

#heading(depth: 2, numbering: none)[Recurring business-model tension]

The most important business tension across P2P lending, neobanks, Big Tech, and crypto is:

#align(center)[
  #term[growth and access] $quad arrow.l.r.long quad$ #term[risk, trust, regulation, and sustainable economics]
]

A good exam answer should explain both sides. Technology can lower one cost while creating another. Removing a bank intermediary can improve price while moving risk to investors. Giving users private-key control increases freedom while reducing recoverability. A neobank can acquire users cheaply while still failing to monetize them sustainably.

#heading(depth: 2, numbering: none)[Fast comparison: who owns the customer relationship?]

#utptable[
  #tabularx(
    columns: (20%, 1fr, 1fr, 1fr),
    styles: (navy-bold,),
    header: ([Model], [Primary interface], [Strategic asset], [Main vulnerability]),
    [Traditional bank], [Branch + bank-owned digital channels], [Trust, license, balance sheet, customer history], [Legacy cost and slower change],
    [P2P platform], [Marketplace], [Matching, scoring, low-cost distribution], [Credit risk and weak guarantees],
    [Digital-only bank], [Mobile-first account], [CX, modern architecture, data, low servicing cost], [Profitability and trust at scale],
    [Big Tech / TechFin], [Existing super-platform], [User base, engagement, data, ecosystem], [Regulatory exposure and financial-brand risk],
    [Cryptocurrency network], [Wallet + protocol], [Decentralized transfer and user-controlled keys], [Volatility, custody, governance, scalability, regulation],
  )
]

#heading(depth: 2, numbering: none)[Exam-answer structure]

For an “analyze” or “evaluate” question, use this order:

#utpsteps[
  + #term[Define the model precisely.]
  + #term[Identify the traditional friction or market failure.]
  + #term[Explain the enabling technology and business-model change.]
  + #term[State the benefit to each stakeholder.]
  + #term[State the risk or limitation to each stakeholder.]
  + #term[Explain the incumbent or regulatory response.]
  + #term[Conclude with the condition under which the innovation creates sustainable value.]
]

#quickcheck[
  Without looking back, answer these eight prompts in one or two sentences each:

  + Why did the 2008 crisis help create an opening for FinTech?
  + How do digital financial services change the economics of financial inclusion?
  + Why can P2P lending serve a borrower rejected by a bank?
  + Why does a good mobile app still depend on legacy core integration?
  + Why can a digital-only bank have millions of users and still lose money?
  + How do hash references make blockchain history tamper-evident?
  + Why does Big Tech care about financial services even if direct banking profit is modest?
  + Why is Bitcoin’s private-key model both empowering and risky?
]
