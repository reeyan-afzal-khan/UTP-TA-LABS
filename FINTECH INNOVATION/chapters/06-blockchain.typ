#import "/.shared/typst/utp.typ": *
#unit("chapters", "06-blockchain")


#heading(level: 1)[Blockchain and Distributed Ledger Technology]
 <ch:blockchain>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Earlier chapters focused on new business models built on conventional financial infrastructure. Weeks 6--7 move down a layer and ask whether the shared record itself can be redesigned.

*By the end, you can:* explain blockchain and distributed ledgers, identify the five benefits emphasized in the lecture, describe public/private keys and digital signatures, explain blocks and Merkle trees, trace how new data are added, and compare blockchain with a centralized database.]

The lecture defines blockchain as a #strong[peer-to-peer system for transacting value without a trusted third party sitting between every transaction]. The record of transactions is maintained as a shared ledger replicated across many nodes.

#callout("keyidea", title: [Key idea])[Blockchain moves trust away from a single authoritative database and toward a combination of replicated records, cryptography, network rules, and a consensus process.]


#heading(level: 2)[From a central ledger to a distributed ledger]


In a centralized system, one organization controls the authoritative record. Other participants trust that authority to maintain the database correctly. In a distributed ledger, many peers hold copies and the network needs rules for deciding which records belong in the accepted state.

The lecture emphasizes three properties:

+ the ledger is #strong[shared] across multiple nodes;

+ new records are #strong[append-only] in the course's simplified model;

+ the current state is determined through a #strong[consensus process] rather than by one authoritative copy.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/FINTECH INNOVATION/figures/diagrams/ca56b6c6cdff52d5.cetz.json")], caption: [From a central ledger to a distributed ledger. One organization's authoritative copy is replaced by many copies held by peers, with consensus rules deciding which records belong in the accepted state.]) <fig:central-vs-distributed>

The advantage is that anyone with appropriate access can obtain a copy and there is no single authoritative copy whose compromise automatically defines the ledger. The disadvantage is that integrity is harder: the network must coordinate agreement across peers.


#heading(level: 2)[Centralized, decentralized, and distributed systems]


The Week 6--7 deck contrasts system structures. In practical terms:

/ Centralized: #block[
Control and authoritative state are concentrated in one central component.
]

/ Decentralized: #block[
Control is spread across multiple centers rather than one.
]

/ Distributed: #block[
Independent computers cooperate over a network to achieve a shared objective without depending on one central element for all coordination.
]

The lecture lists major advantages of distributed systems as higher aggregate computing power, cost reduction, higher reliability, and the ability to grow naturally by adding resources.


#heading(level: 2)[The five blockchain benefits emphasized in the lecture]



#heading(level: 3)[\1. Enhanced security]


The course argues that replicated storage and end-to-end cryptographic protection can make unauthorized alteration harder. Data are not kept only on one server, and permissioning can restrict who can see sensitive information.


#heading(level: 3)[\2. Greater transparency]


Organizations often maintain separate databases that later require reconciliation. A distributed ledger can give permissioned participants the same recorded information at the same time, with transactions time- and date-stamped.


#heading(level: 3)[\3. Instant traceability]


A blockchain can create a provenance trail showing the history of an asset. This is particularly useful where counterfeiting, ethical sourcing, contamination, or supply-chain delays matter.


#heading(level: 3)[\4. Increased efficiency and speed]


Paper-heavy processes create repeated data entry, reconciliation, and human error. A shared record can reduce the need to exchange and reconcile multiple documents or ledgers.


#heading(level: 3)[\5. Automation through smart contracts]


A #strong[smart contract] can trigger an action when specified conditions are satisfied. The lecture gives insurance as an example: once the required claim documentation is verified, a later processing step can be triggered automatically.

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Benefit], [What problem it targets],),
    table.hline(),
    [Security], [Unauthorized change and concentration on a single server],
    [Transparency], [Separate records and information asymmetry between participants],
    [Traceability], [Difficulty proving provenance and locating an asset's history],
    [Efficiency], [Paper, reconciliation, duplicate entry, and manual mediation],
    [Automation], [Human intervention in rule-based contract or process steps],
  )]
  , kind: table
  )

#callout("pitfall", title: [Common mistake])[The five benefits are not automatic properties of every blockchain implementation. The lecture presents them as potential advantages when the architecture, permissions, data, governance, and use case are designed appropriately.]


#heading(level: 2)[A simple ledger example: Alice, Bob, and Charlie]


The Week 6--7 slides build intuition with a small transaction sequence.

+ The initial state says Alice has \$50. Every relevant node has the same starting information.

+ Alice pays Bob \$20. The network's ledger is updated to reflect the transfer.

+ Bob pays Charlie \$10. The new transaction is appended and propagated across copies.

The point is not the arithmetic. It is that each node maintains a consistent history, and changes are represented by new validated records rather than silently editing past transactions.


#heading(level: 2)[Asymmetric cryptography in the lecture]


The course introduces #strong[asymmetric cryptography] as a pair of mathematically related keys:

- a #strong[private key], which the owner keeps secret;

- a #strong[public key], which can be shared and used by others in verification.

The lecture uses asymmetric cryptography for two broad goals:

+ identifying or addressing accounts;

+ authorizing transactions.

#callout("libnote", title: [Reference note])[The slides explain signatures using a simplified "encrypt the transaction hash with the private key, verify with the public key" mental model. This is useful for the course concept: the private key creates an authorization that others can verify with public information. Real signature algorithms are implemented according to their specific mathematical rules rather than as generic public-key encryption.]


#heading(level: 2)[Digital signatures]


The lecture says that a blockchain digital signature should satisfy four practical requirements:

- express the owner's agreement with the specific transaction data;

- be unique to that transaction content so it cannot simply authorize another transaction;

- be creatable only by the owner of the private key;

- be easy for others to verify.

Two operations follow: #strong[signing] and #strong[verifying].


#heading(level: 3)[Signing a transaction]


In the lecture's simplified flow:

+ Describe the transaction: accounts, amount, and required transaction information.

+ Compute a cryptographic hash of the transaction data.

+ Use the private key to create a signature based on that hash.

+ Attach the resulting signature to the transaction.


#heading(level: 3)[Verifying a transaction]


A verifying node:

+ Computes the hash of the transaction data itself.

+ Uses the corresponding public information to verify the attached signature.

+ Checks whether the signature is valid for the computed transaction hash.

If verification succeeds, the node has evidence that the transaction was authorized by the private-key holder and that the signed content was not changed after signing.

#callout("intuition", title: [Plain idea])[A digital signature is like a tamper-sensitive approval stamp. It does not hide the transaction; it proves that the holder of the private key approved a particular version of it.]


#heading(level: 2)[Hashing and hash references]


A #strong[cryptographic hash] maps input data to a fixed-length output. The course relies on two intuitive properties:

- changing the input changes the hash output;

- a hash can therefore act as a compact fingerprint of data.

A #strong[hash reference] points to data while also committing to their content. If the referenced data change, the old hash reference no longer matches.

This is the mechanism behind the blockchain's sensitivity to historical modification.


#heading(level: 2)[The blockchain data structure]


The lecture describes a blockchain as ordered units called #strong[blocks]. Each block contains a header plus transaction data represented through a Merkle tree.


#heading(level: 3)[Merkle tree]


A #strong[Merkle tree] combines hashes of individual transactions into higher-level hashes until one top value remains: the #strong[Merkle root]. The root acts as a compact commitment to the set of transactions in that block.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/FINTECH INNOVATION/figures/diagrams/8f59a80fa479eb61.cetz.json")], caption: [A Merkle tree. Transaction hashes are combined pairwise until one value remains, the Merkle root, which commits to every transaction in the block.]) <fig:merkle-tree>

If any transaction changes, its leaf hash changes, which changes higher-level hashes and ultimately the Merkle root.


#heading(level: 2)[Block headers]


The lecture uses Bitcoin-style block headers to explain common fields:

/ Version: #block[
Indicates the protocol or block format used for interpretation.
]

/ Timestamp: #block[
Records the time associated with the block.
]

/ Difficulty target: #block[
Represents the threshold used in proof-of-work mining.
]

/ Nonce: #block[
A value miners vary while searching for a hash that satisfies the target.
]

/ Previous hash: #block[
A hash reference linking the block to the preceding block.
]

/ Merkle root: #block[
A commitment to the transactions represented by the Merkle tree.
]

Not every distributed ledger uses proof-of-work or the same header structure. The lecture uses Bitcoin-style fields to illustrate how cryptographic linking works.


#heading(level: 2)[How blocks form a chain]


Each block header contains the hash of the previous block header. This creates a sequence of dependencies.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/FINTECH INNOVATION/figures/diagrams/8b5861a7af039457.cetz.json")], caption: [How blocks form a chain. Each block header holds the hash of the previous header, so changing an old block breaks every link after it.]) <fig:block-chain>

Changing old block data changes its hash. The next block still contains the old hash reference, creating an inconsistency. A successful historical rewrite would therefore need to update the affected block and all dependent blocks after it, while also satisfying the network's consensus rules.


#heading(level: 2)[Adding new transaction data]


The lecture gives a three-step structural process.

+ Create a new Merkle tree containing the new transaction data.

+ Create a new block header containing the previous block reference and the new Merkle root.

+ Compute a hash reference to the new block header, making it the new head of the chain.

In a live blockchain, consensus and validation rules determine whether the proposed block becomes part of the accepted ledger.


#heading(level: 2)[Nodes and miners]


A #strong[node] is a communication point in the blockchain network. The lecture lists node responsibilities such as maintaining a ledger copy, receiving transactions, validating transactions, saving new blocks, and broadcasting information to other peers.

A #strong[miner] is a specialized node participating in a proof-of-work block-validation process. Miners validate transactions, assemble candidate blocks, perform computational work, and broadcast accepted results for other nodes to verify.

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Role], [Lecture description],),
    table.hline(),
    [Node], [Maintains and communicates the ledger; receives, stores, validates, and broadcasts network data depending on node type.],
    [Miner], [A node that participates in block verification and proof-of-work competition, validating and proposing blocks.],
  )]
  , kind: table
  )


#heading(level: 2)[Why historical data are hard to change]


The lecture describes blockchain modification as an "all-or-nothing" problem. If historical data change, the hash dependencies from that point to the current head also change. Partial modification leaves an easily detectable inconsistency.

#callout("keyidea", title: [Key idea])[Immutability in the course is best understood as #emph[tamper evidence plus the cost and consensus difficulty of rewriting accepted history], not as a magical physical impossibility of changing bytes on a computer.]

The lecture also mentions Bitcoin's 1 MB block-size limit as part of its historical explanation. That is a Bitcoin-specific protocol constraint rather than a universal blockchain property.


#heading(level: 2)[Blockchain versus a typical centralized database]


A conventional relational database commonly organizes information into tables and allows authorized applications to insert, update, or delete records. A blockchain groups records into sequential blocks and cryptographically links each block to its predecessor.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Dimension], [Centralized database], [Blockchain / distributed ledger framing],),
    table.hline(),
    [Authority], [One organization controls authoritative state], [State is replicated and agreed across participating peers],
    [Data structure], [Tables / records are common], [Ordered blocks linked by hash references],
    [Change model], [Authorized updates can overwrite state], [History is append-oriented; prior records are tamper-evident],
    [Coordination], [Internal transaction controls], [Network validation and consensus],
    [Performance focus], [Efficient controlled data management], [Shared trust, provenance, and multi-party consistency],
    [Best fit], [One trusted owner and high-performance operations], [Multiple parties need a shared record without one fully trusted owner],
  )]
  , kind: table
  )

#callout("pitfall", title: [Common mistake])[Blockchain is not automatically a better database. If one trusted organization can manage the data efficiently and participants do not need a shared tamper-evident ledger, a conventional database may be simpler and faster.]


#heading(level: 2)[Industry applications from the lecture]



#heading(level: 3)[Supply chains and food]


Blockchain can create shared end-to-end visibility and provenance. In food systems, the lecture emphasizes the ability to trace contamination back to its source faster and to reduce waste through better visibility.


#heading(level: 3)[Banking and finance]


Shared ledgers can reduce paperwork, reconciliation, and delays in global trade, trade finance, clearing, settlement, consumer banking, and lending.


#heading(level: 3)[Healthcare]


A distributed record can improve the secure sharing of patient information among authorized providers, payers, and researchers while preserving controlled access.


#heading(level: 3)[Pharmaceuticals]


An audit trail can trace products from origin to pharmacy or retailer, helping identify counterfeits and locate recalled products.


#heading(level: 3)[Government]


The lecture mentions regulatory compliance, contract management, identity management, citizen services, and secure inter-agency data sharing.


#heading(level: 3)[Insurance]


Smart contracts and shared records can automate underwriting and claims processes, reduce paper, speed settlement, and reduce fraud.


#heading(level: 2)[A use-case test: when does blockchain add value?]


+ #strong[Multiple parties.] Are several organizations maintaining related versions of the same truth?

+ #strong[Trust problem.] Is there no single party everyone wants to control the authoritative record?

+ #strong[Shared history.] Is provenance or a common audit trail important?

+ #strong[Reconciliation cost.] Are participants spending time comparing separate records?

+ #strong[Automation opportunity.] Can clear rules trigger later process steps?

+ #strong[Governance.] Is there a workable method for identity, permissions, validation, consensus, and dispute handling?

If the answer to most of these questions is "no," the added complexity of distributed consensus may not be justified.

#callout("tryit", title: [Try it yourself])[Analyze a pharmaceutical supply chain. Identify the participants, the shared facts they need to agree on, the provenance problem, one smart-contract opportunity, and one reason a conventional shared database might still be preferable.]

#callout("quickcheck", title: [Check your understanding])[+ What changes when a ledger moves from one authoritative copy to replicated peer copies?

+ Name the five blockchain benefits emphasized in the lecture.

+ What roles do a private key, public key, hash, and digital signature play?

+ What is a Merkle root and why does it matter?

+ Name the six Bitcoin-style block-header elements presented in the lecture.

+ Why does changing an old block affect later blocks?

+ What is the difference between a general node and a miner in the course framing?

+ Give one situation where a normal centralized database may be a better choice than blockchain.]
