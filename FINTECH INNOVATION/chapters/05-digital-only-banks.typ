#import "/.shared/typst/utp.typ": *
#unit("chapters", "05-digital-only-banks")

= Digital-Only Banks <ch:digital-banks>

#chapterguide[Chapter~@ch:mobile-banking explained the mobile channel and platform banking. This chapter asks what happens when the entire banking proposition is designed to be digital from the beginning.][distinguish the lecture’s neobank and challenger-bank categories, explain their value proposition and prerequisites, analyze growth-versus-profitability trade-offs, identify key risks and regulatory criteria, and compare incumbent response strategies.]

A digital-only bank is not simply a traditional bank with a good app. The Week 5 lecture treats the most important difference as architectural and organizational: the business is built around digital delivery, modern technology, low physical overhead, rapid product iteration, and a customer experience designed without decades of legacy systems and processes.

== Neobanks and challenger banks in the lecture

The course uses a licensing-based distinction:

/ Neobank: A digital banking provider #emph[without] a full banking license.
/ Challenger bank: A digital-only institution #emph[with] a full banking license.

Terminology varies across markets and publications, but this is the classification used in the supplied lecture and therefore the one to use when answering course questions.

Many digital entrants do not initially try to replace a high-street bank for every need. They target specific customer problems that are not served well and can begin with a limited product, such as a current account, prepaid card, or fixed-term savings product.

#utptable[
  #tabularx(
    columns: (23%, 1fr, 1fr),
    styles: (navy-bold,),
    header: ([Dimension], [Digital-only proposition], [Traditional incumbent]),
    [Physical presence], [Little or no branch network], [Established branch and office footprint],
    [Technology], [Modern, modular, cloud-oriented architecture], [Often mixed with older core and product systems],
    [Onboarding], [Paperless, mobile-first e-KYC where permitted], [May involve more channel and process complexity],
    [Product change], [Shorter release cycles and partnerships], [More governance layers and legacy integration],
    [Customer interface], [Mobile-first and data-driven], [Omnichannel, including branches, web, and mobile],
    [Economics], [Lower servicing cost but often low early revenue], [Higher fixed cost but mature revenue base],
  )
]

== Why customers are attracted to digital-only banking

The lecture connects digital-only growth to frustration with legacy providers and stronger demand for simple, transparent, useful digital services. Younger and digitally literate users are an obvious target, but the course also notes that the proposition can appeal to any customer who values ease of use.

Digital-only firms commonly emphasize:

- fast, paperless account opening;
- lower and more transparent fees;
- faster digital service;
- real-time balances and notifications;
- budgeting and savings tools;
- personalization;
- open ecosystems and partner products.

The lecture lists Revolut, Monzo, Starling, Tandem, N26/Number26, Nubank, and Anytime among example digital challengers. These are used to illustrate the category; their current products, licenses, and economics may have evolved since the cited lecture snapshots.

== The structural strengths of digital-only banks

The Week 5 deck identifies three general strengths: modern platforms and apps, scalable models, and strong online communities. These are best understood as a chain.

#utpfig([The structural strengths of digital-only banks as a chain. Modern modular technology lowers servicing cost and speeds product iteration, which together build scale and customer engagement.], label: <fig:neobank-strengths>)[
  #canvas({
    let b = (draw: blue, fill: pale-blue, rounded: 2mm, text-width: 2.65, min-height: 1.25, align: center, font: font("script", weight: "bold", fill: navy))
    let g = (draw: green, fill: pale-teal, rounded: 2mm, text-width: 2.65, min-height: 1.25, align: center, font: font("script", weight: "bold", fill: navy))
    let arr = (line-width: widths.thick, draw: teal, end: tip("Stealth", length: 2mm, line: widths.thick))
    node((-4.5, 0), [Modern modular \
  technology], name: "a", ..b)
    node((-1.5, 0), [Lower servicing \
  cost], name: "b", ..b)
    node((1.5, 0), [Fast product and \
  CX iteration], name: "c", ..b)
    node((4.5, 0), [Scale + customer \
  engagement], name: "d", ..g)
    connect("a", "b", ..arr)
    connect("b", "c", ..arr)
    connect("c", "d", ..arr)
  })
]

Modern infrastructure matters because a bank is not a single application. It is a collection of onboarding, payment, savings, lending, risk, data, compliance, reporting, and support capabilities. Modular architecture makes it easier to change one component or connect a partner without rebuilding everything else.

== How neobanks construct a value proposition

=== Lower operating cost

With no branch network and less legacy IT to maintain, digital-only startups can operate at lower servicing cost. The lecture gives a range of roughly 40--70% lower servicing costs than mainstream banks as a historical estimate.

Lower cost creates strategic options:

- lower fees;
- higher savings rates;
- free or cheaper foreign transactions;
- investment in better digital support or features;
- ability to serve lower-balance customers.

=== Easy setup

Mobile e-KYC can make account creation paperless and straightforward. This removes one of the most visible pieces of onboarding friction discussed since Chapter~#ref(<ch:intro-fintech>).

=== Faster product launches through partnerships

Digital-only firms often work with third parties rather than building every product internally. Partnerships can form marketplaces or ecosystems that allow the bank to add new products faster and at lower development cost.

=== Modern technology and agile governance

The Week 5 slides contrast digital challengers with incumbents that spend a large share of IT budgets maintaining traditional systems. New entrants can use cloud-native infrastructure, open architecture, modular design, analytics, and shorter decision cycles.

=== Lower risk aversion toward experimentation

The lecture argues that smaller digital firms can be more willing to experiment, learn from failure, and gather customer feedback before a launch. The advantage is organizational speed rather than a claim that prudential financial risk should be ignored.

=== Better customer experience

Digital challengers focus on fast, seamless, personalized interactions. The deck cites satisfaction comparisons in several countries as lecture-era evidence that neobanks can outperform established institutions on perceived experience.

#keyidea[
  A neobank’s value proposition is a system: low operating cost funds competitive pricing; modular technology enables fast change; data enables personalization; and mobile delivery makes the experience continuous. Removing one piece weakens the whole proposition.
]

== UX is only one part of CX

Week 5 explicitly warns against confusing a polished interface with a complete customer experience. A bank must also answer:

- How quickly can customers access and move money?
- Are services stable and predictable?
- How much friction is introduced by risk and compliance controls?
- Is live support available when needed?
- Are customer data and money secure?

These operational questions often matter more than visual design when something goes wrong.

#utpfig([Customer experience is more than the interface. It also covers how quickly money moves, how stable the service is, the friction of risk and compliance controls, access to live support, and the security of data and money.], label: <fig:cx-beyond-ux>)[
  #canvas({
    let outer = (draw: navy, line-width: 0.9963pt, rounded: 3mm)
    let item = (draw: mix(blue, 55%), fill: white, rounded: 1.5mm, text-width: 3.2, min-height: 1.05, align: center, font: font("script", fill: navy), inner-sep: 2.9888pt)
    let ux = (..item, fill: pale-orange, draw: orange, line-width: 0.8966pt)
    let hd = (font: font("small", weight: "bold", fill: navy),)
    let nb = (font: font("script", fill: muted), align: center)
    rectangle((-2.2, -2.55), (12.2, 1.35), ..outer)
    node((-2.05, 1.2), [Customer experience (CX)], ..hd, anchor: "north-west")
    node((0, 0.1), [the interface itself #strong[(UX)]], ..ux)
    node((3.7, 0.1), [how quickly money can be accessed and moved], ..item)
    node((7.4, 0.1), [stability and predictability of service], ..item)
    node((11.1, 0.1), [friction created by risk and compliance controls], ..item)
    node((2.3, -1.55), [availability of live human support], ..item)
    node((6, -1.55), [security of customer data and money], ..item)
    node((9.9, -1.55), [when something goes wrong, these five decide whether the customer stays], ..nb, text-width: 4.6)
    node((5, -3.2), [A polished interface is one box of six. Week~5’s warning is that a bank can win on UX and still lose the customer on any of the other five --- which is why CX, not UX, is the thing being competed over.], ..nb, text-width: 13)
  })
]

== Digital-only banking and financial inclusion

The lecture links branchless economics to financial inclusion. If servicing costs are lower, the bank may be able to accept customers with weak credit history or low balances who are unattractive to branch-heavy institutions.

This is the same mechanism studied in Chapter~#ref(<ch:financial-inclusion>): technology does not create inclusion by itself, but it can change the unit economics that previously made a segment uneconomic to serve.

== Speed and diversity of services

The Week 5 deck uses app comparisons to illustrate two competitive dimensions:

+ #term[speed], such as shorter login and onboarding times;
+ #term[functional diversity], such as real-time balances, smart notifications, budgeting, savings, and personal-finance features.

Historical statistics in the deck include claims that non-traditional current-account providers had more app features and that digital challengers were faster in some UK app measurements. These are snapshots, but the strategic point remains: customers experience the bank through the speed and usefulness of everyday interactions.

== What customers actually want

The lecture makes an important distinction between #term[basic services] and #term[desired experience].

Basic services include:

- transaction management;
- lending;
- savings;
- financial guidance.

What differentiates a provider may be less tangible: simplicity, visibility, relevant advice, clear fees, and help with keeping complex money matters manageable.

A Southeast Asian survey quoted in the lecture cites lack of personalized advice, high fees, and unattractive image as reasons customers might move away from traditional banks. The percentages are historical, but the pattern reinforces the importance of personalization, price, and brand perception.

== Genuine differentiation

Digital-only banks share several traits, but being digital does not automatically make each bank distinctive. The lecture identifies multiple differentiation mechanisms.

=== Branchless delivery and e-KYC

Everyday services are delivered digitally, including identity verification where regulation permits. The customer should not need a physical visit simply because the bank’s process was designed around branches.

=== Personalization

Data can be used for motivational nudges, savings suggestions, spending insights, or proactive help. The lecture uses Tandem’s idea of fitness-app-like motivation and Revolut’s customizable cards as examples of different forms of personalization.

=== Open ecosystems

Instead of manufacturing every product, a digital bank can encourage third-party providers to connect to its platform. This allows access to “best in class” services and can generate additional revenue.

=== Transparency

Fees, interest rates, and balances can be communicated clearly. The lecture even describes the possibility of telling customers when a competitor offers a better deal, positioning transparency itself as part of the brand.

=== Predictive intelligence

By analyzing income and spending, a digital bank can warn a customer before an overdraft, estimate free cash before payday, or offer a relevant short-term facility. This is a move from recording financial history toward anticipating the next decision.

== Prerequisites for a successful digital-only banking market

The Week 5 slides identify ecosystem conditions that make digital banking more viable.

#utptable[
  #tabularx(
    columns: (26%, 1fr),
    styles: (navy-bold,),
    header: ([Prerequisite], [Why it matters]),
    [Unmet customer need], [A challenger needs a real problem that incumbents do not solve consistently.],
    [Smartphone and internet penetration], [Creates a sufficiently large addressable digital market.],
    [Digital payment infrastructure], [Gives users a base layer for broader digital financial engagement.],
    [Cloud availability and acceptance], [Supports scalable infrastructure while meeting data-sovereignty rules.],
    [Technology adoption and talent], [Skilled teams are needed to build, operate, secure, and improve the bank.],
    [National digital identity], [Can simplify verification and KYC, increasing onboarding efficiency and transparency.],
    [Supportive regulation], [Determines licensing, product scope, capital, data, consumer protection, and innovation freedom.],
  )
]

== Strategic priority 1: attract customers and build trust

New digital banks begin with low awareness. A better app is not enough if users do not trust the institution with salary, savings, or major payments. The product must be functionally rich enough to become useful while the brand demonstrates reliability.

Online communities can help. A satisfied digital user can recommend the product publicly, creating a network effect in customer acquisition and product feedback.

== Strategic priority 2: differentiate from other digital players

As more neobanks enter a market, their products can begin to look similar. If every challenger offers a card, instant notifications, budgeting, and free onboarding, those features become the category baseline rather than differentiation.

#intuition[
  Early in a market, “digital” is a differentiator. Later, “digital” becomes the minimum expectation. Sustainable differentiation must then come from a target segment, business model, data advantage, service quality, ecosystem, brand, or specialized capability.
]

== Strategic priority 3: expand profitably

This is one of the most important Week 5 themes. Digital-only banks may have low cost bases and rapid user growth while still losing money.

Why?

- young users may hold small balances and generate limited revenue;
- many users keep the neobank as a secondary account;
- low fees attract customers but reduce income;
- customer-acquisition costs rise as the market becomes crowded;
- free foreign exchange and transfers can be expensive to subsidize;
- compliance, support, fraud, and technology still have significant costs.

The lecture uses Revolut, Monzo, Starling, N26, Varo, and others to illustrate the industry’s shift from “growth at all costs” toward profitability.

#utpfig([Unit economics. When the cost to serve one active customer exceeds the revenue that customer brings, a million customers have the same shape of loss; only lowering the cost to serve or raising revenue per customer changes it.], label: <fig:unit-economics>)[
  #canvas({
    let rev = (draw: teal, fill: pale-teal, line-width: 0.797pt)
    let cst = (draw: red, fill: pale-red, line-width: 0.797pt)
    let bl = (font: font("tiny", fill: muted), align: center)
    let hd = (font: font("small", weight: "bold", fill: navy),)
    let gap = (font: font("tiny", weight: "bold", fill: red), align: center)
    let lev = (draw: green, fill: white, rounded: 1.5mm, text-width: 3.5, min-height: 0.9, align: center, font: font("script", fill: navy))
    let go = (line-width: widths.thick, draw: muted, end: tip("Stealth", length: 2mm, line: widths.thick))
    node((1.35, 2.55), [One active customer], ..hd)
    rectangle((0.55, 0), (1.15, 0.95), ..rev, fill: auto)
    rectangle((1.55, 0), (2.15, 1.75), ..cst, fill: auto)
    connect((0.35, 0), (2.45, 0), draw: mix(muted, 60%))
    node((0.85, -0.3), [revenue], ..bl)
    node((1.85, -0.3), [cost to serve], ..bl)
    connect((2.35, 0.95), (2.35, 1.75), draw: red, start: tip("Stealth", length: 1.6mm, line: 0.4pt), end: tip("Stealth", length: 1.6mm, line: 0.4pt))
    node((2.45, 1.35), [loss], ..gap, anchor: "west")
    node((6.55, 2.55), [One million active customers], ..hd)
    rectangle((5.75, 0), (6.35, 0.95), ..rev, fill: auto)
    rectangle((6.75, 0), (7.35, 1.75), ..cst, fill: auto)
    connect((5.55, 0), (7.65, 0), draw: mix(muted, 60%))
    node((6.05, -0.3), [revenue], ..bl)
    node((7.05, -0.3), [cost to serve], ..bl)
    connect((7.55, 0.95), (7.55, 1.75), draw: red, start: tip("Stealth", length: 1.6mm, line: 0.4pt), end: tip("Stealth", length: 1.6mm, line: 0.4pt))
    node((7.65, 1.35), [loss $times thin 10^6$], ..gap, anchor: "west")
    connect((3.55, 0.9), (5.05, 0.9), ..go)
    node(along((3.55, 0.9), (5.05, 0.9), t: 50%), [growth], ..bl, anchor: "south")
    node((4.3, 0.28), [the shape does not change], ..bl, text-width: 1.9)
    node((1.75, -1.6), [lower the cost to serve], ..lev)
    node((5.75, -1.6), [raise revenue per customer], ..lev)
    node((9.75, -1.6), [shift into lending, paid tiers, and other margin], ..lev)
    node((-0.15, -1.6), [levers], font: font("script", weight: "bold", fill: green), anchor: "east")
    node((5.3, -2.85), [Adding customers repeats the left-hand picture; it does not redraw it. Only the three levers change the relative height of the two bars, which is why Week~5 treats user growth as evidence of demand rather than evidence of a viable bank.], font: font("script", fill: ink), align: center, text-width: 12.6)
  })
]

=== Paths toward better economics

The slides describe several responses:

+ #term[Lower overhead further] when expenses exceed sustainable revenue.
+ #term[Shift toward more profitable products], especially lending, mortgages, or software services.
+ #term[Create paid tiers] with valuable features and better unit economics.
+ #term[Focus geographically] rather than expanding everywhere at once.
+ #term[Build fee-based and interest-based revenue] while preserving lower operating cost.

#workedexample[
  A digital bank acquires one million customers with a free account, free international transfers, and high savings rates. User growth looks impressive, but each active customer costs money to serve and produces little revenue. Profitability requires either lowering acquisition/servicing cost, increasing revenue per customer, or moving users into products with sustainable margins. Growth alone is therefore not proof of a viable bank.
]

== Strategic partnerships

A neobank can partner with an institution that already has regulatory approval, gaining faster access to market infrastructure and customers. Partnerships can also let each side specialize:

- the FinTech contributes agility, digital infrastructure, customer-centric design, and experimentation;
- the incumbent contributes trust, brand recognition, regulatory capability, and distribution scale.

The lecture uses Revolut’s product positioning and KakaoBank/TMRW experience design as examples of different customer-engagement strategies.

== Social networks as a distribution and brand channel

Digital banks can use online communities and social media to communicate product changes, build trust, and create a recognizable identity. The deck compares the more professional channel emphasis of many banks with neobanks’ tendency to discuss technology and cryptocurrency more visibly.

The strategic principle is not “use every social network.” It is to match the channel and content to the intended customer relationship.

== Risks and challenges

=== Consumer protection

Rapid innovation can expose customers to products they do not fully understand. This concern is especially important when the target population includes people who were previously unbanked and may have lower financial literacy.

=== Cybersecurity

A technology-heavy proposition can face severe disruption from successful attacks. A branchless bank cannot separate trust in the institution from trust in its technology.

=== Data protection

Personalization uses many customer data points, raising questions about appropriate collection, storage, security, and use.

=== Race-to-the-bottom pricing

If many digital banks compete primarily by reducing fees, the market can erode value faster than it creates sustainable revenue.

=== Business sustainability

The lecture notes that profitability may take years and that app downloads or valuation growth do not guarantee a financially sustainable institution.

#pitfall[
  A low-cost model is not the same as a profitable model. Profitability depends on the relationship between revenue per customer, cost to acquire the customer, cost to serve the customer, credit losses, fraud losses, compliance cost, funding cost, and the scale of the customer base.
]

== SMEs and digital banking

The lecture identifies SMEs as significant FinTech users across banking/payments, financial management, financing, and insurance. Digital platforms can simplify access to services and use data to offer working capital when needed.

A broader platform can bundle business applications so that the SME turns functions on or off as required. This raises expectations for what a business-banking relationship should provide.

== Regional case snapshots: Malaysia and Singapore

The lecture includes a Malaysia digital-banking licensing snapshot in which Bank Negara Malaysia planned up to five digital banking licenses and specified capital requirements. The specific capital figures and application context are historical lecture facts.

The comparison with Singapore and Hong Kong emphasizes a practical point: digital banks may still need access to ATM or cheque infrastructure because not every customer or economic activity becomes fully digital immediately. Malaysia is also presented as preferring local equity control in the cited framework.

== Global challenger-bank growth snapshot

The Week 5 deck reports that 43 challenger banks entered the global market in 2022, increasing the total from 248 in 2021 to 291 by Q4 2022. Use these figures as evidence of the lecture’s “rapid category expansion” argument, not as a current count.

== How incumbent banks respond

The lecture outlines three broad strategies.

=== Strategy 1: acquisitions and investment

An incumbent can acquire or invest in digital assets to obtain technology and reach. The slides use BBVA’s investments and acquisitions, along with BPCE/Fidor and BBVA/Simple, to show both the attraction and the difficulty of this strategy.

A major risk is #term[cultural clash]: integrating a nimble digital organization into a large incumbent can destroy the very operating model that made the acquisition valuable.

=== Strategy 2: build a parallel digital brand

Two variants are described.

/ Legacy-backed brand: Put a new digital brand on top of the parent bank’s existing infrastructure. This is faster but can inherit the same old constraints.
/ Clean-slate parallel bank: Build a separate technology stack and organization as a sandbox for modern architecture, new partners, new business models, and different recruiting practices.

The lecture argues that the clean-slate approach gives the parent institution a controlled environment in which to learn how a truly digital organization operates.

=== Strategy 3: partnership

The incumbent provides licenses, core systems, KYC, trust, or distribution while a technology partner supplies digital product capabilities. The VPBank/Timo example is used to illustrate this collaborative model.

#utpfig([Three ways an incumbent can respond to digital-only banks: acquire or invest to buy capabilities, build a parallel brand to learn, or partner to combine strengths.], label: <fig:incumbent-strategies>)[
  #canvas({
    let b = (draw: blue, fill: pale-blue, rounded: 2mm, text-width: 3.15, min-height: 1.2, align: center, font: font("script", weight: "bold", fill: navy))
    let arr = (line-width: widths.thick, draw: teal, end: tip("Stealth", length: 2mm, line: widths.thick))
    node((-4.2, 0), [Acquire / invest \
  buy capabilities], name: "a", ..b)
    node((0, 0), [Parallel brand \
  build + learn], name: "b", ..b)
    node((4.2, 0), [Partner \
  combine strengths], name: "c", ..b)
    node((0, -1.35), [Incumbents do not have one response. Each option trades speed, control, \
  cultural integration, technology freedom, and regulatory leverage differently.], font: font("script", fill: muted), align: center)
  })
]

== Regulation and suitability of digital banks

The lecture presents two regulatory motivations:

+ create competition that pressures incumbents to improve;
+ improve service delivery to underbanked segments.

It then lists criteria regulators may use when assessing applicants.

#utptable[
  #tabularx(
    columns: (25%, 1fr),
    styles: (navy-bold,),
    header: ([Criterion], [Regulatory question]),
    [Path to profitability], [Is there a credible route to a financially sustainable bank rather than growth funded indefinitely by investors?],
    [Key differentiation], [Does the proposition solve a meaningful need, especially for underserved users?],
    [Adherence to regulation], [Can innovation operate within banking, prudential, financial-crime, and other applicable rules?],
    [Consumer protection], [Are cybersecurity, data protection, product conduct, and customer safeguards robust?],
    [Ability to serve underserved users], [Will the new license expand useful access rather than simply duplicate services for already well-served customers?],
  )
]

== Rebundling through open banking

FinTech began by unbundling bank services into specialist providers. The lecture then introduces the reverse possibility: #term[rebundling]. Open banking allows a digital bank to bring multiple third-party services back into one interface.

Potential beneficiaries are:

- digital-only banks, because a broader service set makes the account more compelling;
- FinTech partners, because bank platforms give them distribution;
- users, because one interface can aggregate useful specialist services.

This is a key course-level cycle:

#align(center)[
  #term[integrated bank] $arrow.r$ #term[unbundled specialists] $arrow.r$ #term[platform rebundling]
]

== Consolidation and market maturity

As investor priorities move from expansion toward profitability, the lecture anticipates consolidation. FinTech or technology firms may acquire digital banks partly for their banking licenses, and weaker challengers may merge or exit.

A mature digital-banking market therefore does not necessarily contain hundreds of permanently independent neobanks. Competition can produce consolidation around the firms that combine useful differentiation with sustainable economics.

== Disruptive innovation versus feature accumulation

The final Week 5 slides caution against two weak strategies.

=== Incremental imitation

A product that merely makes the old process slightly easier may not create enough customer value to reshape the market. The lecture uses buy-now-pay-later providers as an example of a product that reframed point-of-sale financing rather than simply copying a credit card interface.

=== Superfluous features

Feature count is not the objective. A bank can waste resources building sophisticated visualizations or integrations that the target customer rarely uses while neglecting core functions such as reliable and fast money movement.

#keyidea[
  Digital differentiation should be measured by the customer’s job-to-be-done, not by the number of screens, integrations, or AI features in the app.
]

== Why live support still matters

The lecture ends with a strong warning: digital finance does not mean 100% self-service. Customers need reliable human support for difficult or high-stakes problems. A robust model can combine email, phone, SMS, in-app chat, self-service resources, and human assistance.

The desired experience is summarized by the lecture’s phrase: support should be “never needed, always there.”

== A digital-bank business-model test

#utpsteps[
  + #term[Target segment.] Who is the bank built to serve, and what unmet need exists?
  + #term[License model.] Is it a licensed challenger bank or a neobank relying on a partner in the lecture’s terminology?
  + #term[Cost advantage.] Which branches, manual steps, and legacy systems are avoided?
  + #term[Differentiation.] What remains unique once every competitor has a good app?
  + #term[Revenue model.] Fees, subscriptions, lending margins, partner commissions, software, or another source?
  + #term[Unit economics.] Does revenue per customer eventually exceed acquisition, servicing, fraud, compliance, and funding costs?
  + #term[Risk and regulation.] How are security, data protection, consumer protection, and prudential requirements addressed?
  + #term[Support model.] What happens when the automated journey fails?
]

#tryit[
  Design a digital-only bank for Malaysian university students or micro-businesses. Define the target need, onboarding model, three core features, one partner integration, one revenue source, and the most serious risk. Then explain why the proposition is more than “a traditional bank with a new app.”
]

#quickcheck[
  + How does the Week 5 lecture distinguish a neobank from a challenger bank?
  + Why can digital-only banks operate at lower servicing cost?
  + Name four ways a digital bank can differentiate beyond interface design.
  + What market prerequisites support successful digital-only banking?
  + Why can rapid customer growth coexist with persistent losses?
  + Compare acquisition, parallel-brand, and partnership strategies for incumbents.
  + What five criteria does the lecture suggest regulators may examine?
  + What does “rebundling” mean in an open-banking context?
]
