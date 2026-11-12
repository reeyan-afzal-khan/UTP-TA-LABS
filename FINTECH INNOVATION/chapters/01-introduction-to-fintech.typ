#import "/.shared/typst/utp.typ": *
#unit("chapters", "01-introduction-to-fintech")

= Introduction to FinTech <ch:intro-fintech>

#chapterguide[No specialist background is required; begin with the basic functions of a retail bank.][define FinTech, explain why it emerged, distinguish disintermediation from unbundling, identify its main drivers and advantages, and analyze the pressures faced by both incumbents and FinTech firms.]

FinTech is not simply “finance on a phone.” The course presents it as a broader re-design of financial services in which modern technology changes the #emph[business model], the #emph[customer interface], the #emph[speed of decisions], the #emph[data used], and sometimes the very need for a traditional financial intermediary.

#keyidea[
  A useful working definition from the lecture material is: #term[FinTech is technology-enabled innovation in financial services that can create new business models, applications, processes, or products and materially change how financial services are provided.]
]

== Start with what a traditional bank does

At the simplest level, the lecture frames retail banking around three core functions:

+ #term[Store value.] Customers place money in a regulated institution that provides a secure place for deposits.
+ #term[Move value.] Banks support payments through cash, cards, transfers, and related payment infrastructure.
+ #term[Lend value.] Banks collect funds from savers and lend them to households and businesses.

The traditional model therefore places the bank between two groups. Savers receive interest; borrowers obtain capital; the bank earns a spread and fees for performing intermediation, risk management, compliance, liquidity management, and payment services.

#utpfig([The traditional bank sits between savers and borrowers. It takes deposits, makes loans, and earns a spread and fees for intermediation, risk management, and payment services.], label: <fig:bank-intermediary>)[
  #canvas({
    let p = (draw: blue, fill: pale-blue, rounded: 2mm, min-width: 3.2, min-height: 1.25, align: center, font: font("small", weight: "bold", fill: navy))
    let bank = (draw: navy, fill: navy, text: white, rounded: 2mm, min-width: 3.5, min-height: 1.55, align: center, font: font("small", weight: "bold"))
    let arr = (line-width: widths.thick, draw: teal, end: tip("Stealth", length: 2.2mm, line: widths.thick))
    node((0, 0), [Savers \
  deposits], name: "s", ..p)
    node(right-of("s", 1.1), [Traditional bank \
  intermediary], name: "b", ..bank)
    node(right-of("b", 1.1), [Borrowers \
  loans], name: "r", ..p)
    connect("s", "b", ..arr)
    node(along("s", "b", t: 50%), [funds], font: font("script"), anchor: "south")
    connect("b", "r", ..arr)
    node(along("b", "r", t: 50%), [credit], font: font("script"), anchor: "south")
    connect("r", "b", bend: 24deg, ..arr, name: "curve-1")
    node((name: "curve-1", anchor: 50%), [interest + repayment], font: font("script"), anchor: "north")
    connect("b", "s", bend: 24deg, ..arr, name: "curve-2")
    node((name: "curve-2", anchor: 50%), [interest], font: font("script"), anchor: "north")
  })
]

This integrated model historically enjoyed strong barriers to entry. Large incumbents possessed established brands, branch and payment networks, compliance capability, capital, customer relationships, and institutional knowledge. The lecture’s central argument is that digital technology weakens some of these barriers and makes it possible to compete with only one slice of the old bank value chain.

== What FinTech changes

The lecture materials describe FinTech companies as firms that combine financial services with modern technology to change the way people pay, transfer money, borrow, lend, invest, insure, and manage wealth. The emphasis is repeatedly placed on five qualities:

#utptable[
  #tabularx(
    columns: (22%, 1fr),
    styles: (navy-bold,),
    header: ([Quality], [What it means in the course]),
    [User-friendly], [The product is built around the customer’s task rather than the bank’s internal process.],
    [Efficient], [Digital workflows reduce manual steps, paperwork, and avoidable operating cost.],
    [Transparent], [Pricing, status, and product information are made easier for customers to see and understand.],
    [Automated], [Software performs tasks that previously required repeated human processing.],
    [Accessible], [Internet and mobile distribution can reach users outside the physical branch network.],
  )
]

The lecture uses definitions associated with the IMF/World Bank and the People’s Bank of China to reinforce that FinTech is not one product category. It can appear in deposits, lending and capital raising, insurance, investment management, payments, clearing, and settlement.

#intuition[
  A bank is an organization that happens to use technology. A FinTech proposition starts by asking whether technology can redesign a particular financial job from the customer’s point of view. That distinction explains why a small firm can challenge one profitable process without first reproducing an entire bank.
]

== Why did FinTech emerge?

The slides connect the modern FinTech wave to both a #term[trust shock] and a #term[technology shift].

=== The post-2008 trust problem

The global financial crisis is presented as a major catalyst. Confidence in established institutions weakened, particularly among younger consumers. A new provider that had no role in the crisis could position itself around lower cost, clearer pricing, better interfaces, and greater transparency.

The lecture also argues that customers became less willing to organize their lives around banking hours and bank procedures. In a digital economy, users increasingly expect services to be available when needed, with status information visible immediately.

=== Digital natives and changing expectations

Millennials and later digital-native users grew up learning, buying, communicating, and sharing online. As a result, they compare a bank not only with another bank but with the best digital experiences they use elsewhere. Amazon, Google, Apple, and other technology leaders become the benchmark for speed, personalization, and usability.

#workedexample[
  Suppose a customer can open an e-commerce account in minutes, receive real-time delivery updates, and get personalized recommendations. If a banking product takes days, demands repeated branch visits, and provides little status visibility, the customer experiences the bank’s process as friction even if the underlying financial product is sound. FinTech competition often targets exactly this gap.
]

The lecture cites a TransferWise survey in which respondents identified perceived security, lower cost, convenience, speed, and customer service as reasons for preferring technology providers. Treat those percentages as a lecture-era snapshot; the conceptual lesson is that #emph[non-price experience factors can be as strategically important as price].

== Disintermediation: cutting out part of the middle layer

#term[Disintermediation] means reducing or removing a traditional intermediary from a transaction. In finance, a digital marketplace can connect users directly while the platform performs matching, information, identity, or risk-assessment functions.

#utpfig([Disintermediation. In the traditional model the bank’s balance sheet stands between saver and borrower; a digital marketplace connects them directly while still performing matching, information, and risk-assessment functions.], label: <fig:disintermediation>)[
  #canvas({
    let person = (draw: blue, fill: pale-blue, rounded: 2mm, min-width: 2.7, min-height: 1.1, align: center, font: font("small", weight: "bold", fill: navy))
    let old = (draw: muted, fill: pale-gray, rounded: 2mm, min-width: 3, min-height: 1.1, align: center, font: font("small", weight: "bold", fill: navy))
    let new = (draw: teal, fill: pale-teal, rounded: 2mm, min-width: 3, min-height: 1.1, align: center, font: font("small", weight: "bold", fill: navy))
    let arr = (line-width: widths.thick, draw: teal, end: tip("Stealth", length: 2.1mm, line: widths.thick))
    node((-5, 1), [Saver / investor], name: "a", ..person)
    node((0, 1), [Bank balance sheet], name: "b", ..old)
    node((5, 1), [Borrower], name: "c", ..person)
    connect("a", "b", ..arr)
    connect("b", "c", ..arr)
    node((-5, -1.3), [Saver / investor], name: "d", ..person)
    node((0, -1.3), [Digital marketplace], name: "e", ..new)
    node((5, -1.3), [Borrower], name: "f", ..person)
    connect("d", "e", ..arr)
    connect("e", "f", ..arr)
    node((0, -2.2), [The platform may match, score and service the transaction \
  without funding it like a traditional bank.], font: font("script", fill: muted), align: center)
  })
]

The slides emphasize why this can be disruptive:

- removing layers may lower borrowing costs and raise returns to fund providers;
- the investor rather than the platform may carry more direct credit risk;
- the platform may not need to maintain the same liquidity structure as a deposit-taking bank;
- revenue can be volume-based rather than primarily based on taking balance-sheet risk.

#pitfall[
  Disintermediation does #emph[not] mean “no intermediary of any kind.” A P2P or crowdfunding platform is itself an intermediary in matching, information, contracting, servicing, and often risk assessment. The difference is that it does not necessarily perform all of the functions of a conventional bank.
]

== Unbundling: attacking one part of the value chain

#term[Unbundling] is the course’s other central disruption concept. A traditional bank offers many products under one institution. A FinTech firm can focus intensely on a narrow service and attempt to become the “best of breed” in that niche.

#utpfig([Unbundling. A traditional bank offers payments, lending, wealth, insurance, and settlement under one roof; a single-purpose FinTech attacks one slice of that value chain and tries to be the best in that niche.], label: <fig:unbundling>)[
  #canvas({
    let service = (draw: blue, fill: pale-blue, rounded: 1.5mm, min-width: 2.25, min-height: 0.85, align: center, font: font("script", weight: "bold", fill: navy))
    let attack = (draw: orange, fill: pale-orange, rounded: 1.5mm, min-width: 2.25, min-height: 0.85, align: center, font: font("script", weight: "bold", fill: navy))
    let arr = (line-width: widths.thick, draw: orange, end: tip("Stealth", length: 2mm, line: widths.thick))
    node((-5, 0), [Payments], name: "p", ..service)
    node((-2.5, 0), [Lending], name: "l", ..service)
    node((0, 0), [Wealth], name: "w", ..service)
    node((2.5, 0), [Insurance], name: "i", ..service)
    node((5, 0), [Settlement], name: "s", ..service)
    node((-2.5, -1.6), [Single-purpose \
  FinTech], name: "x", ..attack)
    connect("x", "l", ..arr)
    node((0, -2.55), [A focused entrant does not need to rebuild the whole bank; \
  it needs to make one high-friction, valuable activity significantly better.], font: font("script", fill: muted), align: center)
  })
]

The supplied lecture lists examples across the financial system:

- #term[Payments and settlement:] electronic payments, digital currencies, and distributed ledgers can change the payment process and cost structure.
- #term[Funding:] direct lending and crowdfunding connect savers and borrowers through digital channels using structured and unstructured data.
- #term[Asset management:] robo-advisory and AI-based tools can automate portfolio advice and monitoring.
- #term[Investment banking:] algorithmic trading and B2B platforms can create more direct links between buyers and sellers.
- #term[Insurance:] connected devices, data, and new usage patterns can change underwriting, distribution, and claims.

#keyidea[
  Disintermediation changes #emph[who sits in the middle]. Unbundling changes #emph[how many services must be bought from the same provider]. The two often occur together, but they answer different questions.
]

== Where disruption is most likely

The lecture gives a compact strategic rule: incumbents are most vulnerable where #term[customer friction] meets a #term[large profit pool]. A digital entrant can therefore begin vertically, fix one painful process, gain the customer relationship, and later expand horizontally.

Typical sources of friction discussed in the slides include:

- long decision times in lending;
- opaque prices and fees;
- repeated paperwork and manual approval;
- products designed around internal silos rather than customer journeys;
- weak mobile experiences;
- limited access for thin-file, unbanked, or underbanked customers.

Digital players can combine platform models, data-intensive decision-making, and relatively asset-light operations. This is why the lecture repeatedly compares FinTech businesses with marketplaces: the strategic asset is often the software, data, network, and customer relationship rather than a large physical footprint.

== The main drivers of FinTech

The Week 1 deck groups the drivers into customer, technology, economic, and access forces. The following table consolidates them.

#utptable[
  #tabularx(
    columns: (23%, 1fr),
    styles: (navy-bold,),
    header: ([Driver], [Course explanation]),
    [Customer expectations], [Users expect 24/7 access, intuitive design, personalization, transparency, and fast service.],
    [Mobile culture], [Smartphones reduce dependence on branches and make financial services continuously reachable.],
    [AI, cloud, and big data], [Scalable computing and analytics lower the cost of building data-driven services and automate decisions.],
    [New digital value systems], [Digital currencies and new credit/payment mechanisms create alternatives to older infrastructure.],
    [Trust and transparency], [Post-crisis skepticism creates room for providers that communicate more clearly and appear customer-centric.],
    [Financial stress and liquidity needs], [Consumers value tools that help them manage payments, liquidity, savings, and investments under economic pressure.],
    [Unbanked and underbanked demand], [Large populations remain poorly served by conventional models and represent both a social need and a market opportunity.],
    [Lower barriers to entry], [Internet and mobile distribution allow new firms to reach users without first building a branch network.],
  )
]

The course also highlights #term[data] as a distinctive advantage. Digital firms can gather, process, and interpret formal and social information to learn about customers and businesses. The strategic value is not simply collecting more data; it is turning data into faster and more relevant decisions.

== Why customers may prefer FinTech propositions

Across the introductory deck, the value proposition repeatedly reduces to four ideas:

+ #term[Better customer experience.] Design the process around the customer’s task.
+ #term[Lower cost or better pricing.] A lighter operating model can reduce fees or improve rates.
+ #term[Faster decisions.] Automation and data reduce waiting and manual approval layers.
+ #term[Access to underserved segments.] Alternative distribution and data can serve users rejected or ignored by traditional models.

#analogy[
  Think of a traditional bank as a department store that tries to sell every financial product. An unbundled FinTech is a specialist shop that chooses one category and tries to make the selection, price, and checkout experience dramatically better. The specialist does not need to be better at everything to take meaningful business away from the department store.
]

== Opportunities created by FinTech

The lecture describes several system-level opportunities:

- reduce transaction costs and operational friction;
- increase efficiency and competitive pressure;
- narrow information asymmetry through better data and analytics;
- broaden access to financial services, especially for underserved users;
- improve international payments and remittances;
- support regulatory compliance and supervisory processes with technology;
- enable more inclusive economic growth.

These opportunities create the bridge to Chapter~@ch:financial-inclusion, where the course asks who is excluded by the traditional system and how digital finance can change the economics of serving them.

== Threats to incumbent financial institutions

The Week 1 slides identify the main competitive threats as erosion of brand equity, market share, margins, information-security confidence, and customer retention. They also group incumbent challenges into a memorable set of “six Cs.” The source slides explicitly name culture, customers, competition, computers, compliance, and costs.

#utptable[
  #tabularx(
    columns: (18%, 1fr),
    styles: (navy-bold,),
    header: ([The C], [Pressure on the incumbent]),
    [Culture], [Become customer-centric, lean, automated, and agile while balancing institutional constraints.],
    [Customers], [Deal with empowered, demanding, sometimes confused, and occasionally malicious users.],
    [Competition], [Compete with aggressive, global, digitally native entrants rather than only peer banks.],
    [Computers], [Adopt new technology while maintaining always-connected, multi-device services.],
    [Compliance], [Handle fraud, cybersecurity, regulation, governance, risk, and compliance requirements.],
    [Costs], [Improve returns and efficiency while reducing expensive infrastructure and process overhead.],
  )
]

== Challenges faced by FinTech firms themselves

FinTechs are challengers, but the lecture is clear that they face serious constraints too.

=== Regulatory uncertainty and compliance

Financial services are highly regulated and requirements vary between jurisdictions. The slides stress that regulators may support innovation while still expecting firms to take compliance seriously. A young company must understand licensing, consumer protection, anti-financial-crime obligations, and which authority governs which activity.

=== Talent

FinTech firms compete for people who can combine software engineering, data, financial knowledge, security, design, and regulatory understanding. A strong idea does not become a scalable product without the right technical and domain talent.

=== Scaling the customer base

A B2C FinTech may need a very large user base before unit economics become sustainable. The Week 1 lecture uses Revolut and robo-advisory customer-acquisition costs as examples of the tension between rapid growth and profitability.

=== Raising capital

Financial services products can be expensive to build and launch, particularly when licensing, compliance, and security requirements are substantial. A company can therefore have a compelling customer proposition but still fail if it cannot finance the path to scale.

=== Cybersecurity

A digitally native financial provider is an attractive target. The slides emphasize that attackers are increasingly organized and capable, so security is not an optional technical feature; it is part of the firm’s financial and reputational viability.

#pitfall[
  Do not assume that “digital” automatically means “cheap, safe, and scalable.” A FinTech can avoid branches and legacy systems yet still face high customer-acquisition costs, compliance costs, fraud losses, cyber risk, and the need for substantial investment capital.
]

== The global and Southeast Asian context

The course uses dated investment and company examples to show that FinTech is a global phenomenon with a particularly strong Asian presence. One lecture snapshot notes that the United States and China dominated many of the largest 2018 FinTech VC deals, while a later H1 2022 snapshot reports substantial investment across Asia-Pacific, the Americas, and EMEA.

Singapore is presented as an ASEAN FinTech hub because of its regulatory environment, policy support, ease of doing business, technology ecosystem, and concentration of FinTech firms. The slides then use Southeast Asian technology companies to illustrate how FinTech can become embedded inside larger digital ecosystems.

#utptable[
  #tabularx(
    columns: (19%, 1fr),
    styles: (navy-bold,),
    header: ([Lecture example], [Why it matters to the course argument]),
    [Grab], [Shows the convergence of transport, delivery, digital financial services, and digital banking ambitions.],
    [GoTo], [Demonstrates a super-app ecosystem combining on-demand services, commerce, and financial products.],
    [Sea], [Illustrates the movement from e-commerce and digital services into licensed digital banking.],
    [OVO], [Shows an e-wallet expanding into P2P lending, investment, and insurance through partnerships and acquisitions.],
    [Bitkub], [Connects the FinTech ecosystem to the cryptocurrency exchange sector.],
  )
]

The valuations, ownership percentages, user counts, and listing details in these examples are best read as historical lecture snapshots. Their educational purpose is to show #emph[ecosystem expansion]: a technology firm can use an existing user base and digital engagement to add financial services.

== A single mental model for Week 1

#utpfig([A single mental model for the course. A customer or institutional friction invites a technology, the technology enables a new business model, and the new model brings competition, access, and new risks.], label: <fig:fintech-mental-model>)[
  #canvas({
    let box-style = (draw: blue, fill: pale-blue, rounded: 2mm, text-width: 3, min-height: 1.35, align: center, font: font("script", weight: "bold", fill: navy))
    let box2 = (draw: teal, fill: pale-teal, rounded: 2mm, text-width: 3, min-height: 1.35, align: center, font: font("script", weight: "bold", fill: navy))
    let box3 = (draw: orange, fill: pale-orange, rounded: 2mm, text-width: 3, min-height: 1.35, align: center, font: font("script", weight: "bold", fill: navy))
    let arr = (line-width: widths.thick, draw: teal, end: tip("Stealth", length: 2mm, line: widths.thick))
    node((-4.8, 0), [FRICTION \
  cost, delay, poor CX, exclusion], name: "f", ..box-style)
    node((-1.6, 0), [TECHNOLOGY \
  mobile, data, AI, cloud], name: "t", ..box2)
    node((1.6, 0), [NEW MODEL \
  unbundle, platform, automate], name: "m", ..box2)
    node((4.8, 0), [OUTCOME \
  competition, access, new risks], name: "o", ..box3)
    connect("f", "t", ..arr)
    connect("t", "m", ..arr)
    connect("m", "o", ..arr)
  })
]

When you encounter a new FinTech case, ask four questions:

+ What customer or institutional friction is being targeted?
+ What technology makes a different process possible?
+ Which part of the financial value chain is being unbundled or re-intermediated?
+ What new risk, regulation, or sustainability problem appears as a result?

#tryit[
  Choose one financial app you use or know. Identify: (1) the traditional bank function it replaces or improves, (2) whether it is disintermediating or unbundling, (3) the main source of customer friction it solves, and (4) the new risk created by moving the task online.
]

#quickcheck[
  + What are the three basic functions of a retail bank used as the starting point in this course?
  + How is disintermediation different from unbundling?
  + Why can customer experience be a strategic source of disruption rather than merely a design issue?
  + Name four major drivers of FinTech innovation from the lecture.
  + Why can a successful FinTech still struggle to become profitable?
  + What is the “friction + profit pool” rule for predicting where disruption is likely?
]
