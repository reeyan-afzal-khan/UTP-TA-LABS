#import "/.shared/typst/utp.typ": *
#unit("chapters", "08-cryptocurrencies")


#heading(level: 1)[Cryptocurrencies and Bitcoin]
 <ch:cryptocurrencies>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Chapter~#ref(label("ch:blockchain"), supplement: none) explained the shared ledger, hashes, signatures, blocks, nodes, and proof-of-work context. Week 9 applies those mechanisms to a digital monetary system.

*By the end, you can:* distinguish digital currency from cryptocurrency, explain Bitcoin wallets and double spending, describe mining and forks, evaluate Bitcoin against the three functions of money, and analyze major benefits, risks, and macroeconomic concerns.]

A cryptocurrency is one application of distributed-ledger ideas. The Week 9 lecture uses Bitcoin as the main example because it combines public-key cryptography, a peer-to-peer network, a blockchain, and proof of work to support electronic transfers without a traditional financial intermediary authorizing every transaction.


#heading(level: 2)[Digital currency versus cryptocurrency]


The lecture first defines #strong[digital currency] broadly as a digital representation of value that can function like money. It uses the familiar three functions of money:

+ #strong[medium of exchange] --- used to buy and sell;

+ #strong[unit of account] --- used to quote and compare prices;

+ #strong[store of value] --- preserves purchasing power for later use.

A #strong[cryptocurrency] is presented as a subset of digital currency that uses cryptography and a distributed system. Bitcoin is therefore a cryptocurrency and, more broadly, a digital currency.

The slides also mention airline miles, game tokens, local currencies, and other closed- or open-system digital values as examples of the wider digital-currency concept.

#callout("libnote", title: [Reference note])[The Week 9 slides contain historically layered regulatory statements. One early definition says digital currency is not legal tender in any jurisdiction, while a later slide notes El Salvador's 2021 adoption of Bitcoin as legal tender. These statements reflect different source dates within the lecture deck. For course revision, focus on the conceptual distinction and cite the specific lecture context if a legal-status question is asked.]


#heading(level: 2)[The nature of cryptocurrency]


The lecture describes cryptocurrency in its purest form as a peer-to-peer version of electronic cash: value can be transferred directly between parties without a financial institution sitting in the middle of every payment.

Bitcoin relies on cryptography in two major ways:

- public/private keys and digital signatures authorize transactions;

- proof-of-work and hashing contribute to transaction ordering, block creation, and tamper resistance.

The lecture also notes that Bitcoin's open-source nature enabled many alternative cryptocurrencies, commonly called #strong[altcoins], to build on or modify similar ideas.


#heading(level: 2)[Features of a successful cryptocurrency in the lecture]


The Week 9 deck lists a broad set of desirable characteristics.

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Feature], [Course meaning],),
    table.hline(),
    [Open source], [A trusted developer community can inspect, verify, and improve the code.],
    [Decentralized], [No single person or organization should exercise unilateral control over the system.],
    [Peer-to-peer], [Participants can transact through the network rather than relying on a central intermediary.],
    [Global], [The system can cross geographic borders and support international financial integration.],
    [Fast], [Transactions and confirmation should be sufficiently quick for the intended use.],
    [Reliable], [The system should reduce settlement uncertainty and support non-repudiable records.],
    [Secure], [Identity, privacy, encryption, KYC, and AML/TF concerns must be addressed appropriately.],
    [Flexible], [The platform should be able to support different assets, instruments, and markets.],
    [Automated], [Payment and contractual logic can be executed programmatically.],
    [Scalable], [The network must support a large population and transaction load.],
    [Integrable], [It should be able to connect digital finance, legal agreements, and smart-contract ecosystems.],
  )]
  , kind: table
  )

The lecture uses these as a design checklist rather than claiming Bitcoin perfectly satisfies every item.


#heading(level: 2)[The double-spending problem]


Digital information can normally be copied. If "digital money" were only a file, Alice could email Bob a copy and still retain the original file, allowing the same unit to be spent again.

This is the #strong[double-spending problem]: how can a digital payment system ensure that the same value is not validly spent twice?

Traditional payment systems solve the problem with a central ledger. A bank records Alice's balance and refuses a second payment after the first has consumed the funds. Bitcoin attempts to solve the problem without that central bank by using a shared transaction history, digital signatures, and network consensus.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/FINTECH INNOVATION/figures/diagrams/96d3403533827cfc.svg")], caption: [The double-spending problem. Alice cannot spend the same coin with both Bob and Charlie, because the shared network validates each payment against the accepted spend history.]) <fig:double-spending>

The key is that the network does not treat each file copy as independent money. It evaluates transactions against the accepted ledger state.


#heading(level: 2)[Buying and storing Bitcoin]


The Week 9 slides describe several ways a user could obtain Bitcoin: an exchange, another person, or a Bitcoin ATM/vending machine. These examples are historical and availability depends on jurisdiction.

The crucial concept is the #strong[wallet].

#callout("keyidea", title: [Key idea])[A Bitcoin wallet does not literally store coins like a physical wallet. The lecture explains that it stores the private-key material used to control addresses and authorize transactions recorded on the blockchain.]

The lecture discusses multiple wallet types:

/ Desktop wallet: #block[
Software and keys are stored on a computer under the user's control.
]

/ Mobile wallet: #block[
Wallet functionality runs on a phone, making in-person payments convenient.
]

/ Web / online wallet: #block[
A service is accessed through a browser; in the lecture example, the provider may hold the private keys.
]

/ Hardware wallet: #block[
A dedicated device protects key material outside the ordinary computing environment.
]

The security trade-off is control versus convenience. If a third party holds the key, the user depends on that provider. If the user holds the key personally, loss or theft of the key can mean loss of control over the funds.


#heading(level: 2)[Addresses, public keys, and private keys]


The lecture compares a Bitcoin address with an email address: it can be shared so other people know where to send value. The private key, by contrast, must remain secret because it authorizes spending.

A transaction therefore has an asymmetry:

- the receiving identifier can be public;

- the spending authorization must remain private.

The Week 9 deck gives historical examples of legacy address formats and a 256-bit private key. These implementation details are useful for recognizing the idea, but address formats can differ across Bitcoin software and protocol features.


#heading(level: 2)[Receiving and sending Bitcoin]


The lecture's transaction flow can be summarized in six steps.

+ The receiver shares a wallet address or QR representation.

+ The sender enters the destination, amount, and transaction-fee parameters in wallet software.

+ The wallet uses the sender's private key to authorize the transaction.

+ The transaction is broadcast to the peer-to-peer network.

+ Nodes and miners validate the transaction against network rules and the current ledger state.

+ Once included in a block, later blocks provide additional confirmations.

The lecture distinguishes between an #strong[unconfirmed] transaction that has been observed by the network and a transaction with one or more block confirmations.


#heading(level: 2)[Bitcoin mining]


#strong[Mining] is the proof-of-work process through which candidate blocks are validated and added to the Bitcoin blockchain in the lecture's model. It is computationally expensive because miners repeatedly search for a block-header hash that satisfies the target condition.

The Week 9 slides connect mining to three functions:

+ validate and order transactions;

+ secure the system against fraud and double spending;

+ issue new coins as a block reward, together with transaction fees.


#heading(level: 2)[Proof of work]


A miner constructs a candidate block and repeatedly changes a value such as the #strong[nonce]. Each attempt produces a different block hash. The goal is to find a hash below the difficulty target.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/FINTECH INNOVATION/figures/diagrams/370efaf2d5b5f1c6.svg")], caption: [The proof-of-work loop. A miner changes the nonce and recomputes the block hash until the hash meets the difficulty target, then broadcasts the valid block.]) <fig:proof-of-work>

The difficulty is adjusted so blocks are found at an approximate target rate in the Bitcoin model used by the lecture. The deck repeatedly uses roughly ten minutes per block as the key intuition.


#heading(level: 2)[Mining tasks]


The slides list several tasks performed by miners or full nodes:

- synchronize with the network and obtain blockchain history;

- validate transaction signatures and outputs;

- validate received blocks against protocol rules;

- create candidate blocks from validated transactions;

- perform proof of work;

- broadcast a successful block and receive the applicable block reward and transaction fees if accepted.


#heading(level: 2)[Bitcoin supply and halving]


The lecture states that Bitcoin has a hard maximum supply of 21 million coins and that the block reward falls by 50% every 210,000 blocks, approximately every four years. Historical examples in the deck include reward reductions from 50 to 25 to 12.5 bitcoins.

#callout("libnote", title: [Reference note])[The supplied Week 9 deck is internally inconsistent about the expected year in which Bitcoin issuance approaches the 21-million limit: several slides say 2140, while other slides say 2040. These notes preserve the consistent course concepts --- fixed maximum supply and periodic reward halving --- and flag the conflicting year rather than silently choosing one of the slide statements.]

Other historical figures in the mining slides, such as the number of bitcoins generated per day or a specific block reward "as of 2016," should be treated strictly as dated snapshots.


#heading(level: 2)[Confirmations and settlement delay]


The lecture explains that transaction messages propagate quickly but block confirmation introduces waiting time. It gives a common historical practice of waiting for multiple confirmations for high-value transactions.

The financial trade-off is important: decentralized validation creates a different settlement experience from an instant centralized account update. The user can choose a confidence threshold depending on transaction value and risk tolerance.


#heading(level: 2)[Soft forks and hard forks]


A #strong[fork] changes protocol rules.

/ Soft fork: #block[
A backward-compatible rule change in the lecture's definition; older nodes can still accept blocks created under the new rules.
]

/ Hard fork: #block[
A non-backward-compatible rule change requiring participating nodes to upgrade; disagreement can split the chain into two persistent rule sets.
]

The Week 9 deck uses the 2017 Bitcoin Cash split as a hard-fork case. It identifies block-size policy as a central difference and explains that balances before the split are represented on both post-fork chains because both histories share the same pre-fork ledger.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/FINTECH INNOVATION/figures/diagrams/1009e18cfccf1dd0.svg")], caption: [A hard fork. Both chains share the history up to the fork, then follow incompatible rule sets, which is why balances before the split appear on both chains.]) <fig:hard-fork>

A hard fork can split mining power, users, applications, and liquidity across two networks, which is why the lecture describes it as potentially undesirable unless there is sufficient coordination.


#heading(level: 2)[Bitcoin as money: the three-function test]


The Week 9 lecture deliberately evaluates Bitcoin not only as technology but as a currency.


#heading(level: 3)[Medium of exchange]


A strong medium of exchange should be widely accepted, easy to obtain, easy to hold, and practical at the point of purchase. The lecture highlights barriers such as:

- limited merchant acceptance in the cited period;

- friction when acquiring bitcoins through exchanges or dealers;

- execution and custody risk at exchanges;

- confirmation delay for transactions where merchants require settlement confidence.


#heading(level: 3)[Unit of account]


A unit of account should make prices easy to quote and compare. The lecture argues that high price volatility forces frequent repricing and can make quoted decimal amounts unfamiliar or confusing to consumers.


#heading(level: 3)[Store of value]


A store of value should allow wealth to be held securely and predictably. The deck highlights wallet security, dependence on key management, provider risk for custodial wallets, and the use of cold storage as a security response that may reduce convenience.

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Money function], [Bitcoin challenge emphasized by the lecture],),
    table.hline(),
    [Medium of exchange], [Acceptance, acquisition friction, liquidity/custody risk, and confirmation delay],
    [Unit of account], [Price volatility and inconvenient decimal pricing],
    [Store of value], [Wallet/private-key security and uncertainty over value],
  )]
  , kind: table
  )


#heading(level: 2)[Benefits of cryptocurrency discussed in the lecture]


The Week 9 deck presents a wide range of claimed or potential benefits. They should be evaluated rather than memorized as guarantees.


#heading(level: 3)[Reduced fraud risk in some transaction contexts]


Blockchain records and signed transactions can reduce certain forms of unauthorized alteration. However, this does not eliminate wallet theft, scams, fraudulent exchanges, or key compromise.


#heading(level: 3)[Crowdfunding and new capital formation]


The slides connect cryptocurrencies with token-based fundraising such as initial coin offerings. This creates new capital-raising mechanisms but also introduces regulatory and investor-protection concerns.


#heading(level: 3)[Faster or cheaper money transfer]


A peer-to-peer digital value system can reduce reliance on correspondent banks and other intermediaries for some cross-border transfers. The lecture emphasizes the potential relevance to remittances.


#heading(level: 3)[Freedom of payments and user control]


Users can send value without asking a bank to approve every payment. Control of the private key gives direct control over spending authorization.


#heading(level: 3)[Merchant benefits]


The lecture contrasts Bitcoin with credit-card fees and chargebacks, arguing that lower transaction costs and irreversibility can benefit merchants and support micropayments.


#heading(level: 3)[Platform for further innovation]


Because the system broadcasts, validates, and stores structured transactions, the lecture argues that similar technology can support other assets, smart property, assurance contracts, and new digital-finance applications.


#heading(level: 2)[The user-control trade-off]


Direct private-key control is both a benefit and a risk. The user is not dependent on a bank to authorize every transaction, but there may be no administrator who can restore access if the private key is lost.

#callout("keyidea", title: [Key idea])[Cryptocurrency repeatedly exchanges institutional protection for user sovereignty. The gain is control; the cost is greater responsibility for key security, transaction judgment, and recovery.]


#heading(level: 2)[Volatility and internal change]


Bitcoin is a community-driven software project and its market price changes with demand, news, expectations, and speculation. The lecture notes that sharp price changes can resemble speculative bubbles and make Bitcoin a difficult store of value.

The deck includes a January 2022 drawdown example for Bitcoin and Ethereum as a historical volatility snapshot. The number is not the point; the lesson is that price volatility can undermine the ordinary monetary functions studied above.


#heading(level: 2)[Criminal-use concerns]


The lecture discusses pseudo-anonymity and the use of Bitcoin in illicit markets such as Silk Road, ransomware, money laundering, and terrorist financing. It also notes that conventional money-transfer methods have been used for crime long before cryptocurrency.

The regulatory response discussed in the deck includes exchanges adopting anti-money-laundering controls and retaining customer records.

The balanced course conclusion is that the technology can facilitate legitimate and illegitimate transfers; the policy question is how to preserve useful innovation while reducing financial-crime risk.


#heading(level: 2)[Economic and consumer risks]


The Week 9 slides list several major risks.

- #strong[No conventional consumer-protection structure] in some decentralized settings.

- #strong[High or variable transaction/exchange costs] depending on platform and conditions.

- #strong[Technical complexity] that makes risk difficult for beginners to assess.

- #strong[Price volatility] and potential capital losses.

- #strong[Regulatory uncertainty] as governments decide how activities fit existing law.

- #strong[Financial-market disruption] if rapid adoption displaces incumbent payment or market infrastructure.

- #strong[Protocol or developer risk] if the project changes, loses support, or contains weaknesses.


#heading(level: 2)[Scalability and other technical challenges]


The lecture identifies several barriers to mass adoption:

- block-size limits;

- growing blockchain storage requirements;

- transactions-per-second limitations;

- privacy protection;

- legal status of smart contracts;

- the reliability of external data supplied by oracles.

One slide compares a low single-digit Bitcoin transaction rate with a much higher Visa average as a lecture snapshot. The conceptual issue is #strong[scalability]: a payment system must process sufficient volume at acceptable speed and cost.


#heading(level: 2)[Legal and regulatory attitude]


Governments must balance innovation against risks involving AML/CFT, taxation, consumer protection, monetary sovereignty, and market stability. The lecture gives different historical regulatory responses across countries, ranging from restrictions to recognition under financial or commodity rules.

Because this topic changes quickly, the notes intentionally preserve the lecture's comparative principle rather than treating any cited country rule as current.


#heading(level: 2)[Cryptoization and macroeconomic concerns]


The Week 9 conclusion introduces #strong[cryptoization]: residents use crypto assets instead of the local currency for meaningful parts of economic life.

The lecture identifies several potential consequences:

- weaker central-bank control over monetary policy;

- financial-stability risks from currency mismatches and funding structures;

- greater consumer-protection and financial-integrity problems;

- reduced tax effectiveness and more opportunity for tax evasion;

- lower seigniorage for the state;

- capital outflows affecting foreign-exchange markets;

- large energy consumption from proof-of-work mining;

- concentration of trading activity in a few high-liquidity exchanges.

The final point creates an interesting paradox: a decentralized asset can still develop highly concentrated #emph[market infrastructure] because traders prefer venues with the deepest liquidity.


#heading(level: 2)[A balanced cryptocurrency analysis framework]


+ #strong[Monetary function.] Is the asset actually useful as exchange medium, unit of account, or store of value?

+ #strong[Technical mechanism.] How are transactions authorized, validated, ordered, and finalized?

+ #strong[Custody.] Who controls the private keys, and what happens if access is lost or stolen?

+ #strong[Incentives.] Why do validators/miners continue to secure the network?

+ #strong[Scalability.] Can the system support the target transaction volume and storage requirements?

+ #strong[Governance.] How are protocol changes made, and what happens when the community disagrees?

+ #strong[Regulation and protection.] What AML/CFT, consumer, tax, and market rules apply?

+ #strong[Systemic effect.] What happens if adoption becomes large enough to affect banks, payments, monetary policy, or capital flows?

#callout("tryit", title: [Try it yourself])[Evaluate Bitcoin using the eight-step framework. Your answer should include at least one genuine benefit, one user-level risk, one protocol-level challenge, and one macroeconomic concern. Avoid answering only with price movements.]

#callout("quickcheck", title: [Check your understanding])[+ How is cryptocurrency related to the broader category of digital currency?

+ What is the double-spending problem, and why does a shared ledger help solve it?

+ What does a wallet actually control in the lecture's explanation?

+ What are the main tasks of miners?

+ What is the difference between a soft fork and a hard fork?

+ Evaluate Bitcoin as a medium of exchange, unit of account, and store of value.

+ Why is private-key control simultaneously a benefit and a risk?

+ Name four technical, regulatory, or macroeconomic challenges discussed in Week 9.

+ What does cryptoization mean, and why might a central bank care?]
