#import "/.shared/typst/utp.typ": *
#unit("chapters", "03-p2p-and-crowdfunding")


#heading(level: 1)[P2P Lending and Crowdfunding]
 <ch:p2p-crowdfunding>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Chapter~#ref(label("ch:financial-inclusion"), supplement: none) explained why conventional lending can leave small, risky, or thin-file borrowers underserved.

*By the end, you can:* compare traditional and alternative lending, distinguish the major crowdfunding models, explain platform credit scoring and risk mitigation, and analyze the competitive advantages and limitations of P2P finance.]

Week 3 turns the ideas of disintermediation and inclusion into a concrete financial model. Instead of a bank collecting deposits and then choosing which borrowers to fund from its balance sheet, an online platform can match many individual fund providers with borrowers or projects.


#heading(level: 2)[Why lending is a target for FinTech disruption]


The lecture identifies several characteristics of traditional bank lending that create friction for smaller or riskier borrowers:

- centralized legacy infrastructure and expensive branch networks;

- manual and multilayered underwriting processes;

- higher capital and regulatory constraints;

- reluctance to make small loans because fixed underwriting costs are high;

- collateral requirements designed to improve recovery if the borrower defaults;

- uncertainty and delay in disbursement;

- processing fees, lock-in periods, and pre-closure charges.

These features are not presented as evidence that banks serve no useful purpose. Rather, they explain why the bank model can become uneconomic for some customers. If the fixed cost of assessing and servicing a loan is high, a small loan may cost almost as much to process as a large one while generating much less revenue.

#callout("intuition", title: [Plain idea])[If a loan application requires many manual steps, the process contains a high fixed cost. That fixed cost is easier to absorb on a large corporate loan than on a small business or personal loan. Automation changes this cost equation and therefore changes which customers can be served profitably.]


#heading(level: 2)[What crowdfunding means]


#strong[Crowdfunding] is an umbrella term for raising relatively small contributions from a large number of individuals or organizations, typically through an online platform, to fund a project, business, personal loan, or other goal. The platform replaces some functions of the traditional financial intermediary by organizing information, matching contributors and fund seekers, processing transactions, and enforcing platform rules.

The lecture uses the term #strong[backers] for the people who contribute financial resources toward a common goal.


#heading(level: 2)[Traditional lending versus alternative lending]



#heading(level: 3)[Traditional lending intermediaries]


Traditional intermediaries pool savings and loans. The Week 3 slides highlight two major advantages:

- savings may be protected by the intermediary's reserves and deposit-insurance arrangements;

- pooling many deposits and many loans can reduce exposure to any one borrower's default.

However, lenders have little flexibility to choose their own desired risk/return profile, and a bank that focuses on low-risk lending may exclude higher-risk borrowers.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/FINTECH INNOVATION/figures/diagrams/a8f6bc5963fb7040.cetz.json")], caption: [Traditional intermediation compared with marketplace funding. In a bank a default is absorbed on the bank's own balance sheet, behind reserves and deposit insurance; on a marketplace platform it falls on the individual lender.]) <fig:p2p-default-risk>


#heading(level: 3)[Alternative lending platforms]


Alternative platforms seek to reduce transaction costs and give underserved borrowers access to funding while allowing investors with different risk appetites to participate. Their major limitations are also explicit in the lecture:

- investors may be more exposed to individual borrower defaults;

- diversification helps but does not remove credit risk;

- guarantees are limited compared with protected bank deposits.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Dimension], [Traditional bank lending], [Alternative / P2P platform],),
    table.hline(),
    [Funding model], [Bank intermediates pooled deposits and loans], [Investors fund loans through an online marketplace],
    [Protection], [Reserves and deposit insurance may protect depositors], [Investment protection and guarantees are more limited],
    [Risk selection], [Bank chooses portfolio and underwriting standards], [Investor may have more choice over risk/return exposure],
    [Borrower access], [Higher-risk and small borrowers may be excluded], [Underserved and thin-file borrowers may gain access],
    [Processing], [Often layered and tied to legacy systems], [Leaner, partly automated digital process],
    [Cost base], [Branches, staff, legacy IT, regulatory capital], [Lower physical overhead and more flexible digital distribution],
  )]
  , kind: table
  )


#heading(level: 2)[What P2P lending is]


#strong[Peer-to-peer (P2P) lending] is a lending arrangement in which private investors provide funds to borrowers through an online platform rather than through a traditional bank balance sheet. The platform still performs important functions: it onboards participants, assesses eligibility, presents loan opportunities, handles contracts and payments, and attempts to mitigate risk.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/FINTECH INNOVATION/figures/diagrams/6ca762ff94f9f0ca.cetz.json")], caption: [Peer-to-peer lending. Investors fund borrowers through an online platform that matches, scores, and services the loans rather than lending from its own balance sheet.]) <fig:p2p-marketplace>

The critical difference is that the platform can operate as a marketplace. It can match money without necessarily taking deposits and funding loans in the same way as a traditional depository institution.


#heading(level: 2)[Problems of traditional lending highlighted by the lecture]


The slides group the pain points into six ideas.

/ Limited access: #block[
Higher-risk profiles can fall into a lending gap.
]

/ Slow speed: #block[
Multiple approval layers can delay decisions and disbursement.
]

/ Margin for error: #block[
Conventional scores and adjudication models can miss viable opportunities, especially in a more digital economy.
]

/ Poor customer experience: #block[
Manual requirements may not match modern expectations for transparent, fast service.
]

/ Limited control: #block[
Savers have limited visibility over where funds are used and what specific risk is taken.
]

/ Low return: #block[
Operational inefficiency and a conservative risk appetite can contribute to low returns on savings.
]


#heading(level: 2)[Core capabilities of alternative lending platforms]


The Week 3 deck emphasizes three capabilities.


#heading(level: 3)[Direct digital matching]


Online platforms and legal contracts connect savers and borrowers more directly. Because the platform does not need the same branch footprint as a depository bank, its funding and servicing structure can be cheaper.


#heading(level: 3)[Alternative processes and metrics]


Alternative lenders may assess borrowers with information beyond conventional credit scores, including social, mobile, payment, or accounting data. These models can be updated more frequently as new empirical performance data arrive.


#heading(level: 3)[Lean, automated processing]


Borrower assessment is often at least partly automated against predefined rules. This reduces manual work, speeds onboarding, and can make the decision process more transparent to users.

#callout("keyidea", title: [Key idea])[The central P2P advantage is not simply "the internet." It is the combination of a marketplace funding model, a lower operating structure, automated workflow, and alternative credit information.]


#heading(level: 2)[The four main crowdfunding models]


The lecture distinguishes four models by what the contributor expects in return.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/FINTECH INNOVATION/figures/diagrams/05eb2cb8c9c8f1d2.cetz.json")], caption: [The four crowdfunding models, ordered by what the contributor expects in return. Donation and reward crowdfunding offer a non-financial return; P2P lending and equity crowdfunding offer a debt or ownership claim.]) <fig:crowdfunding-models>

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Model], [Contributor receives], [Typical purpose in the lecture],),
    table.hline(),
    [Donation], [No financial or material return], [Charities, disaster relief, community or campaign causes],
    [Reward], [Tangible non-financial gift, product, or benefit], [Pre-selling products and community fundraising],
    [P2P lending], [Repayment of principal plus interest], [Personal or business loans funded by many investors],
    [Equity], [Ownership stake, potentially dividends and capital gains], [Seed or risk capital for startups and existing firms],
  )]
  , kind: table
  )


#heading(level: 3)[Donation crowdfunding]


Backers contribute because they support the project or cause and do not expect a return. The lecture points to not-for-profit and charitable uses.


#heading(level: 3)[Reward crowdfunding]


The contributor receives a non-financial reward. It can function like pre-ordering a product: the business raises money while backers receive the product or another tangible benefit. Donation and reward models are collectively described in the lecture as forms of community crowdfunding.


#heading(level: 3)[P2P lending]


The crowd supplies debt funding. The borrower repays the loan with interest, so the backer's return is financial but does not involve ownership of the company.


#heading(level: 3)[Equity crowdfunding]


Investors buy stakes in a company. Returns may come from dividends or capital gains, and voting rights may or may not be included. The lecture notes P2B equity crowdfunding, in which individuals fund businesses, and B2B equity crowdfunding, in which firms form part of the investor crowd.

#callout("pitfall", title: [Common mistake])[Do not confuse reward crowdfunding with equity crowdfunding. A reward can be valuable, but it is explicitly non-financial. Equity crowdfunding gives the investor a financial ownership claim.]


#heading(level: 2)[Platform fees and fundraising models]


The slides describe crowdfunding portals as mostly for-profit organizations. Historical lecture figures cite success fees in ranges such as 3--12% or 5--11%, depending on platform and model. These are lecture snapshots rather than universal current pricing.

A useful distinction is between fundraising rules:

/ All-or-nothing: #block[
Funds are released only if the target is reached.
]

/ Keep-it-all / take-it-all: #block[
The fundraiser receives the amount collected even if the target is not fully met; the lecture notes that the fee may be higher for this model.
]

The economic purpose of the fee is to pay for the marketplace's matching, payment, technology, compliance, marketing, and servicing functions.


#heading(level: 2)[Risk, compliance, and credit scoring]


P2P platforms do not remove credit risk. They must decide which applicants are legitimate and how likely borrowers are to repay.


#heading(level: 3)[Formal checks]


The Week 3 materials mention checks for anti-money-laundering requirements and for opportunistic or fraudulent behavior. These controls reduce the chance that the marketplace becomes a channel for illegitimate funding activity.


#heading(level: 3)[Adverse selection and moral hazard]


The lecture refers to two classic information problems.

/ Adverse selection: #block[
Higher-risk borrowers may be more likely to seek funding when the platform cannot perfectly distinguish risk before the loan.
]

/ Moral hazard: #block[
A borrower may behave differently after receiving funds because the lender cannot perfectly observe or control later behavior.
]

Proximity relationships, communities, platform data, and screening can reduce these problems but do not make them disappear.


#heading(level: 3)[Credit-scoring algorithms]


P2P platforms use scoring models to estimate creditworthiness. The lecture suggests that a competitive advantage may come from combining conventional credit logic with "soft" information and big data. However, this advantage may be temporary because incumbent banks can also adopt similar data and analytics.

#callout("intuition", title: [Plain idea])[Alternative data is an advantage only while it improves decisions better or faster than competitors can. Once every major lender can use similar data, the durable advantage shifts to execution quality: data governance, model design, speed of learning, customer experience, and cost.]


#heading(level: 2)[Diversification as a risk-mitigation mechanism]


Some platforms reduce lender exposure by limiting the amount invested in one project or forcing investments to be spread across many loans.

Suppose an investor has a fixed amount of capital. Putting everything into one borrower makes the outcome depend heavily on that one borrower's repayment. Splitting the amount across many independent borrowers reduces the damage caused by any one default.

#callout("workedexample", title: [Worked example])[An investor has RM1,000. If all RM1,000 is placed into one unsecured loan and that borrower defaults, the loss can be severe. If the platform allocates RM50 across 20 different loans, one default affects only part of the portfolio. Diversification does not eliminate correlated or systemic defaults, but it reduces concentration in a single borrower.]


#heading(level: 2)[Why borrowers and investors use crowdfunding]


The Week 3 deck groups the motivations into several system-level benefits.


#heading(level: 3)[Fills a financing gap]


Crowdfunding offers an alternative channel when traditional credit or early-stage capital is difficult to obtain, especially for SMEs and micro-businesses.


#heading(level: 3)[Rapid aggregation of small contributions]


A project can collect money from many small investors rather than relying on a few large financiers. Online processing can make application and fundraising faster.


#heading(level: 3)[Potentially lower cost of capital and higher investor returns]


A lower operating cost can allow borrowers to pay less while investors receive more of the economics that otherwise fund branch and administrative overhead. This is a potential advantage, not a guarantee.


#heading(level: 3)[Risk spreading and portfolio diversification]


Many investors can each take a small position, and P2P loans create a distinct form of uncollateralized debt exposure that investors can use for diversification.


#heading(level: 3)[Economic recovery and SME financing]


The lecture links access to capital for SMEs and micro-businesses with job creation, development, and economic recovery.


#heading(level: 3)[Competition]


Alternative platforms pressure banks to improve pricing, efficiency, decision speed, and credit assessment. Competition can therefore benefit users even when the customer stays with a traditional institution.


#heading(level: 2)[Where lending disruption occurs]


The slides identify three important areas of change for underbanked or thin-file borrowers.

+ #strong[New sources of data.] Social/mobile data for individuals and payment/accounting data for businesses can supplement conventional credit files.

+ #strong[Better use of existing data.] Incumbents possess large stores of data but often face silos and unstructured records, motivating investments in data transformation and analytics.

+ #strong[More agile credit models.] New entrants can iterate their risk engines more frequently, giving them a temporary advantage when customer behavior or available data changes quickly.

This connects directly back to Chapter~#ref(label("ch:financial-inclusion"), supplement: none): better information can make previously invisible customers assessable.


#heading(level: 2)[Competitive advantages of P2P lending]



#heading(level: 3)[Cost structure]


P2P platforms can replace some personnel, building, and equipment costs with cheaper digital distribution and communication. The lecture also contrasts their lighter historical regulatory cost with the financial and operational compliance burden of banks.

#callout("pitfall", title: [Common mistake])[The claim that P2P regulatory costs are "extremely low" is a statement from the lecture's comparative framing, not a timeless rule. Regulation varies by jurisdiction and can evolve substantially. The structural idea to remember is that regulatory perimeter and balance-sheet requirements affect business-model economics.]


#heading(level: 3)[Speed and convenience]


Online borrower selection and loan issuance can be faster, while investors can access and manage portfolios at any time. A digital operating model can also be updated and expanded more quickly than branch-based processes.


#heading(level: 3)[Familiar digital interaction]


Users may find web-based tools less intimidating than formal bank processes. Daily internet habits make online forms, dashboards, and communities familiar.


#heading(level: 3)[Lenders' responsiveness to social or ethical projects]


P2P and crowdfunding allow investors to respond directly to the social purpose of a project. The lecture mentions education, social housing, art, music, and other community-oriented niches. This creates a motivation beyond pure financial return.


#heading(level: 2)[Why banks should care]


Traditional banks earn money by taking deposits, making loans, and keeping a margin between the cost of funding and lending returns. A P2P platform attacks that spread by directly connecting fund providers and borrowers.

The Week 3 lecture uses Zopa as an example of a P2P lender that aims to give borrowers a better rate while giving lenders a higher return than ordinary cash deposits. The strategic threat is therefore not just that a new company offers loans; it is that it redesigns the economics of the intermediary itself.

Banks, however, retain important advantages: market knowledge, compliance experience, scale, trust, and the ability to fund through established balance sheets. The lecture notes that large institutions may react slowly because of organizational complexity, but they can eventually build, partner, invest, or adapt.


#heading(level: 2)[A decision framework for comparing lending models]


When asked to compare a bank loan with P2P lending, do not stop at "P2P is cheaper." Analyze the entire trade-off.

+ #strong[Funding source.] Is the money funded by a bank balance sheet or directly by marketplace investors?

+ #strong[Protection.] What deposit insurance, reserve, guarantee, or recovery mechanism exists?

+ #strong[Underwriting.] What data and scoring method determine eligibility and price?

+ #strong[Cost structure.] Which physical, manual, regulatory, and technology costs must be covered?

+ #strong[Speed and experience.] How long do onboarding, assessment, and disbursement take?

+ #strong[Risk allocation.] Who ultimately bears borrower default risk?

+ #strong[Access.] Does the model reach borrowers excluded by conventional criteria?

+ #strong[Sustainability.] Can the platform maintain risk controls and economics as it scales?

#callout("tryit", title: [Try it yourself])[A micro-business needs RM20,000 but has limited collateral and a short operating history. Compare how a traditional bank and a P2P platform might assess the application. Identify one advantage and one risk for the borrower, the fund provider, and the intermediary in each model.]

#callout("quickcheck", title: [Check your understanding])[+ Define crowdfunding and P2P lending.

+ What four crowdfunding models are used in the lecture, and what does the contributor receive in each?

+ Why are small loans expensive for a high-fixed-cost bank to underwrite?

+ What is the difference between adverse selection and moral hazard?

+ How can alternative data help an underbanked borrower?

+ Why does portfolio diversification reduce but not eliminate P2P investment risk?

+ Name three competitive advantages and two limitations of P2P lending.]
