#import "/.shared/typst/utp.typ": *
#unit("chapters", "04-mobile-and-internet-banking")

= Mobile and Internet Banking <ch:mobile-banking>

#chapterguide[Chapter~@ch:p2p-crowdfunding showed how digital platforms can redesign lending; this chapter shifts attention to the bank-customer interface itself.][explain mobile-banking usability principles, distinguish UX from broader CX, evaluate cost and retention benefits, identify security and integration challenges, and describe the shift toward platform banking, APIs, and cloud infrastructure.]

Mobile banking turns a general-purpose personal device into a continuous financial-service channel. The Week 4 lecture treats this as more than a smaller version of online banking: the phone combines constant connectivity with cameras, biometrics, notifications, location, contactless capability, and other features that can change how financial services are designed.

== The mobile phone as a banking channel

A branch requires the customer to travel to a place. Desktop online banking removes travel but still assumes access to a computer. A mobile service places the financial interface in a device the customer already carries.

The lecture lists common mobile activities such as checking balances and statements, depositing cheques, transferring funds, paying bills, making loan or credit-card payments, sending money to others, managing investments, and locating branches or ATMs. The percentages shown in the original slide are a lecture-era survey snapshot; what matters is the breadth of tasks that can migrate to mobile.

The deck also discusses #term[video banking]: customers can speak with experts through a phone, tablet, or PC outside conventional branch hours. This is an early example of blending digital convenience with human interaction rather than treating the two as mutually exclusive.

== Usability principle 1: intuitive, user-friendly design

A banking interface has little value if the customer cannot reliably complete the intended transaction. The lecture therefore begins with a simple rule: users should reach the desired information or task quickly without excessive screens, keys, or navigation.

#note[
  In mobile banking, usability is not cosmetic. Confusing navigation can create transaction errors, abandoned journeys, support costs, and loss of trust. A clear interface is part of operational quality.
]

The slides also encourage cross-fertilization between retail and commercial banking teams. Lessons from consumer behavior can improve business-banking design, and vice versa.

== Usability principle 2: rich functionality without complexity

A mobile app should perform enough useful tasks to reduce dependence on branches. At the same time, adding features can make the interface harder to understand. This creates a design tension:

#align(center)[
  #term[more capability] $cancel(arrow.r.double)$ #term[better experience]
]

A bank wants its mobile channel to do more than shift existing customers from one channel to another. The lecture argues that rich, convenient functionality can help the institution sell additional services, attract users, and create new relationships. But the richness must remain simple enough to use.

A pocket multi-tool is valuable because many functions are available when needed, but it fails if the user cannot find the right tool quickly. Mobile banking has the same design problem: breadth is useful only when the interface preserves clarity.

== Usability principle 3: branding and channel consistency

The mobile app becomes the bank’s visible “image” to the customer. Design, language, notifications, and service quality therefore communicate the brand every time the app is opened.

The lecture recommends consistency across physical and virtual channels:

- branches;
- ATMs;
- point-of-sale channels;
- web banking;
- mobile banking.

A customer should not feel that each channel belongs to a different institution. Information, identity, visual language, and the service promise should reinforce each other.

== Usability principle 4: alerts

Because the phone is normally switched on and close to the customer, notifications are a distinctive strength of the mobile channel. The lecture emphasizes alerts for account movements and pending transactions.

Two basic models are useful:

/ Push alert: The bank sends information automatically when a defined event occurs.
/ Pull alert: The customer requests information when needed.

Alerts can increase control by making financial activity visible quickly, but poorly designed alerts can become noise. The value comes from relevance, timing, and user-configurable preferences.

== Usability principle 5: personalization

Personalization uses customer data and interaction history to adapt the experience. The lecture uses AI-powered virtual assistants such as Bank of America’s Erica as examples of a shift from passive banking toward more proactive, conversational interactions.

The progression can be understood as:

#utpfig([The progression of personalization, from a reactive app that shows a balance to an assistive one that helps the customer act.], label: <fig:personalization>)[
  #canvas({
    let b = (draw: blue, fill: pale-blue, rounded: 2mm, text-width: 2.6, min-height: 1.1, align: center, font: font("script", weight: "bold", fill: navy))
    let arr = (line-width: widths.thick, draw: teal, end: arrow-tip("Stealth", length: 2mm, line: widths.thick))
    node((-4.5, 0), [Reactive \
  “show my balance”], name: "a", ..b)
    node((-1.5, 0), [Contextual \
  “show my spending”], name: "b", ..b)
    node((1.5, 0), [Predictive \
  “warn me early”], name: "c", ..b)
    node((4.5, 0), [Assistive \
  “help me act”], name: "d", ..b)
    connect("a", "b", ..arr)
    connect("b", "c", ..arr)
    connect("c", "d", ..arr)
  })
]

The later digital-bank chapter develops this further through budgeting tools, proactive overdraft warnings, and data-driven financial guidance.

== UX versus CX

The lecture distinguishes the front-end experience from the customer’s total relationship with the financial institution.

/ User experience (UX): How intuitive, fast, and understandable the product interface is while the customer uses it.
/ Customer experience (CX): The broader end-to-end experience, including reliability, security, access to funds, support, pricing, complaint resolution, and confidence in the institution.

A visually excellent app can therefore have poor CX if transfers fail, money is delayed, support is unavailable, or the customer does not trust security.

#example[
  Imagine two banking apps. App A has beautiful navigation but a transfer frequently remains pending for hours and support is difficult to reach. App B looks simpler but transactions are predictable, alerts are clear, and a customer can quickly reach a human when something fails. The lecture’s CX framing would often rate App B as the stronger overall proposition.
]

== Security and privacy are non-negotiable

The Week 4 slides place security and privacy at the center of mobile design. A bank must be able to establish that the person connecting is the legitimate customer, and the connection and stored data must be protected.

The lecture specifically mentions:

- customer authentication;
- encryption in transmission;
- protection of data stored on the device;
- penetration testing as a way to test mobile-application robustness.

Mobile security is difficult because the bank does not control the customer’s device or the network through which the device connects.

#warning[
  Convenience and security are not separate design projects. Every security control changes the customer journey, and every reduction in friction changes the attack surface. A strong mobile product must manage both at once.
]

== Digital agility

Banks must respond to changes in technology, market behavior, and law. The lecture uses #term[digital agility] to describe the ability to adapt quickly and deliver targeted, personalized, and differentiated services.

Digital agility may involve:

- new value propositions embedded in everyday customer life;
- partnerships or consortiums that expand the product range;
- technologies that make the banking experience more convenient or intelligent;
- faster response to new regulation and security needs.

== Why mobile banking is attractive to financial institutions

=== Lower service cost

The deck gives a striking historical comparison: approximately \$4.25 for a branch visit versus \$0.10 for mobile access. These figures are lecture snapshots, not universal current unit costs. The structural lesson is that a self-service digital interaction can have a dramatically lower marginal cost than a staffed physical interaction.

#utpfig([Why mobile banking is cheaper to provide. A staffed physical interaction costs staff, premises, and time on every visit; a digital self-service interaction runs on software and shared infrastructure.], label: <fig:service-cost>)[
  #canvas({
    let b = (draw: blue, fill: pale-blue, rounded: 2mm, text-width: 3.4, min-height: 1.25, align: center, font: font("small", weight: "bold", fill: navy))
    let low = (draw: green, fill: pale-teal, rounded: 2mm, text-width: 3.4, min-height: 1.25, align: center, font: font("small", weight: "bold", fill: navy))
    let arr = (line-width: widths.thick, draw: teal, end: arrow-tip("Stealth", length: 2mm, line: widths.thick))
    node((-3.1, 0), [Physical service \
  staff + premises + time], name: "a", ..b)
    node((3.1, 0), [Digital self-service \
  software + shared infrastructure], name: "b", ..low)
    connect("a", "b", ..arr)
    node(along("a", "b", t: 50%), [channel shift], font: font("script"), anchor: "south")
  })
]

=== Convenience for customers

Mobile access is available across time and location, and the device can combine geolocation, camera capture, image processing, voice, biometrics, optical character recognition, and contactless functions. The mobile channel can therefore do tasks that a static desktop browser cannot do as naturally.

=== Customer retention

The lecture cites historical studies associating mobile use with lower attrition and greater willingness to remain with the provider. The causal mechanism is plausible within the course framework: when an app becomes embedded in frequent financial routines, switching can become less attractive.

=== More activity and profitability

The slides also cite a SunTrust example in which mobile customers were more profitable and made more debit-card transactions. Again, treat the percentages as a dated case study. The key idea is that lower access friction can increase engagement and transaction frequency.

=== Network effects in P2P payments

Mobile person-to-person payments become more useful as more friends, relatives, roommates, and merchants participate. This is a #term[network effect]: the value of the service grows with the number of reachable counterparties.

== The integration challenge

Security is visible to customers; integration is often invisible, but it can be equally difficult. A mobile app must connect to core banking, financial systems, risk management, reporting, compliance, payment, and customer-data applications.

A new app running on modern infrastructure does not automatically modernize the systems behind it. The Week 4 lecture therefore describes integration as a technical problem that mirrors the organizational problem: legacy systems are connected to legacy processes and departmental boundaries.

#utpfig([The integration challenge. A mobile app is only the front end; behind it sit core banking, payments, risk and fraud, reporting and compliance, customer data, and product systems, each of which it must connect to.], label: <fig:app-integration>)[
  #canvas({
    let front = (draw: teal, fill: pale-teal, rounded: 2mm, text-width: 3, min-height: 1.1, align: center, font: font("small", weight: "bold", fill: navy))
    let core = (draw: muted, fill: pale-gray, rounded: 2mm, text-width: 2.5, min-height: 0.85, align: center, font: font("script", weight: "bold", fill: navy))
    let arr = (line-width: widths.thick, draw: blue, end: arrow-tip("Stealth", length: 2mm, line: widths.thick))
    node((-4.2, 0), [Mobile app], name: "m", ..front)
    node((0, 1.8), [Core banking], name: "c1", ..core)
    node((0, 0.6), [Payments], name: "c2", ..core)
    node((0, -0.6), [Risk / fraud], name: "c3", ..core)
    node((0, -1.8), [Reporting / compliance], name: "c4", ..core)
    node((4, 1.1), [Customer data], name: "c5", ..core)
    node((4, -1.1), [Product systems], name: "c6", ..core)
    for x in ("c1", "c2", "c3", "c4", "c5", "c6") {
      connect("m.east", x + ".west", ..arr)
    }
  })
]

This is why an incumbent can build a modern-looking interface yet still struggle to match the speed and flexibility of a digital-native provider.

== The shift toward platform banking

The Week 4 deck identifies three forces affecting digital banking:

+ #term[Virtual banks] improve their offers and differentiate from incumbents.
+ #term[Mobile channels] become standard across the industry, although incumbents can struggle with execution.
+ #term[Banking platforms] use technology to connect third-party applications and services.

A #term[platform bank] does not attempt to manufacture every product itself. It can distribute its own services and connect customers to specialized third parties.

== APIs and open banking

An #term[API] is a software interface that lets one program request defined functions or data from another while protecting the rest of the system. The lecture presents APIs as essential infrastructure for platform banking because they allow banks to integrate third-party applications more cleanly.

Regulatory pressure can reinforce this shift. The slides use PSD2 in Europe as an example of rules that require banks to share data or access through open APIs under appropriate conditions, giving customers greater control over third-party access to their accounts.

#note[
  Open banking weakens the idea that the bank must control every layer of the customer relationship. A customer may keep funds with one institution while using a different provider’s interface, analytics, or financial product.
]

== Why bank economics are being disrupted

The lecture identifies three connected pressures:

- #term[Technology capacity:] APIs and modern architecture make third-party integration easier.
- #term[Regulatory pressure:] open-banking rules reduce exclusive control over customer data and account access.
- #term[Shrinking margins:] competition reduces the profitability of manufacturing every financial product, encouraging banks to focus on distribution and partnerships.

The slides use N26 as a case of a curated platform that integrates “best-of-breed” partners and Venmo/Zelle as an example of new entrants raising customer expectations and triggering an incumbent response.

== Cloud migration and legacy infrastructure

Incumbents increasingly move systems toward cloud-based architecture because legacy infrastructure can limit speed, flexibility, and the ability to meet new customer needs. The lecture’s strategic point is that front-end modernization is insufficient if the core remains slow and difficult to change.

== Why physical branches still matter

The Week 4 lecture does not predict an immediate disappearance of branches. Physical presence can still matter for complex needs, high-value transactions, and customers who prefer human interaction. Challenger banks may therefore become secondary accounts if they cannot meet the full range of complex financial needs.

This introduces a broader theme developed in Chapter~#ref(<ch:digital-banks>): a digital bank can attract customers quickly but still struggle to capture the full relationship and become sustainably profitable.

== How incumbents can respond

The lecture describes two broad strengths of established banks:

- they can concentrate on retaining profitable customer segments;
- they may be able to #term[fast follow] because building an attractive digital front end has relatively low technological barriers compared with obtaining regulatory permission and operating a full bank.

The challenge is organizational and architectural: a fast follower must connect the digital proposition to reliable core systems without recreating the same old friction.

== A mobile-banking evaluation checklist

#utpsteps[
  + #term[Task clarity.] Can the user find and complete the main transaction quickly?
  + #term[Functional coverage.] Can the app replace enough branch or desktop activity to be genuinely useful?
  + #term[Trust.] Are authentication, encryption, alerts, and error handling designed to create confidence?
  + #term[Personalization.] Does customer data improve relevance without creating unnecessary complexity?
  + #term[Integration.] Can the app access core banking, payments, risk, and compliance systems reliably?
  + #term[Economics.] Does channel migration actually reduce cost or increase engagement?
  + #term[Platform readiness.] Can APIs and partners extend the service without tightly coupling every new feature to the legacy core?
]

#exercises[
  Audit a mobile banking app using the seven steps above. For each step, identify one strong design choice and one potential failure point. Separate UX problems from broader CX problems.
]

#questions[
  + Why is “more functionality” not always better in a mobile banking app?
  + What is the difference between UX and CX?
  + Why are alerts especially powerful on mobile devices?
  + Name two reasons mobile banking can reduce a bank’s operating cost.
  + Why is legacy-system integration a major challenge even when the mobile interface is modern?
  + What role do APIs play in platform banking and open banking?
  + Why might physical branches remain strategically useful even as digital adoption rises?
]
