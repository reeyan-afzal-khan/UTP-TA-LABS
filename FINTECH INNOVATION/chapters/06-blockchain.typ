#import "/.shared/typst/utp.typ": *
#unit("chapters", "06-blockchain")

= Blockchain and Distributed Ledger Technology <ch:blockchain>

#chapterguide[Earlier chapters focused on new business models built on conventional financial infrastructure. Weeks 6--7 move down a layer and ask whether the shared record itself can be redesigned.][explain blockchain and distributed ledgers, identify the five benefits emphasized in the lecture, describe public/private keys and digital signatures, explain blocks and Merkle trees, trace how new data are added, and compare blockchain with a centralized database.]

The lecture defines blockchain as a #term[peer-to-peer system for transacting value without a trusted third party sitting between every transaction]. The record of transactions is maintained as a shared ledger replicated across many nodes.

#note[
  Blockchain moves trust away from a single authoritative database and toward a combination of replicated records, cryptography, network rules, and a consensus process.
]

== From a central ledger to a distributed ledger

In a centralized system, one organization controls the authoritative record. Other participants trust that authority to maintain the database correctly. In a distributed ledger, many peers hold copies and the network needs rules for deciding which records belong in the accepted state.

The lecture emphasizes three properties:

+ the ledger is #term[shared] across multiple nodes;
+ new records are #term[append-only] in the course’s simplified model;
+ the current state is determined through a #term[consensus process] rather than by one authoritative copy.

#utpfig([From a central ledger to a distributed ledger. One organization’s authoritative copy is replaced by many copies held by peers, with consensus rules deciding which records belong in the accepted state.], label: <fig:central-vs-distributed>)[
  #canvas({
    let c = (draw: blue, fill: pale-blue, rounded: 2mm, min-width: 2.2, min-height: 0.95, align: center, font: font("script", weight: "bold", fill: navy))
    let auth = (draw: navy, fill: navy, text: white, rounded: 2mm, min-width: 2.7, min-height: 1.15, align: center, font: font("script", weight: "bold"))
    let peer = (draw: teal, fill: pale-teal, shape: "circle", min-size: 1.2, align: center, font: font("script", weight: "bold", fill: navy))
    let arr = (line-width: widths.thick, draw: muted, end: arrow-tip("Stealth", length: 1.8mm, line: widths.thick))
    node((-4.3, 0), [Central \
  authoritative ledger], name: "a", ..auth)
    node((-4.3, 2), [User], name: "u1", ..c)
    node((-4.3, -2), [User], name: "u2", ..c)
    connect("u1", "a", ..arr)
    connect("u2", "a", ..arr)
    node((1.7, 1.7), [P1], name: "p1", ..peer)
    node((4.3, 1.7), [P2], name: "p2", ..peer)
    node((1.7, -1.7), [P3], name: "p3", ..peer)
    node((4.3, -1.7), [P4], name: "p4", ..peer)
    connect("p1", "p2", ..arr)
    connect("p2", "p4", ..arr)
    connect("p4", "p3", ..arr)
    connect("p3", "p1", ..arr)
    connect("p1", "p4", ..arr)
    connect("p2", "p3", ..arr)
    node((3, 0), [Distributed copies \
  \+ consensus rules], font: font("script", fill: muted), align: center)
  })
]

The advantage is that anyone with appropriate access can obtain a copy and there is no single authoritative copy whose compromise automatically defines the ledger. The disadvantage is that integrity is harder: the network must coordinate agreement across peers.

== Centralized, decentralized, and distributed systems

The Week 6--7 deck contrasts system structures. In practical terms:

/ Centralized: Control and authoritative state are concentrated in one central component.
/ Decentralized: Control is spread across multiple centers rather than one.
/ Distributed: Independent computers cooperate over a network to achieve a shared objective without depending on one central element for all coordination.

The lecture lists major advantages of distributed systems as higher aggregate computing power, cost reduction, higher reliability, and the ability to grow naturally by adding resources.

== The five blockchain benefits emphasized in the lecture

=== 1\. Enhanced security

The course argues that replicated storage and end-to-end cryptographic protection can make unauthorized alteration harder. Data are not kept only on one server, and permissioning can restrict who can see sensitive information.

=== 2\. Greater transparency

Organizations often maintain separate databases that later require reconciliation. A distributed ledger can give permissioned participants the same recorded information at the same time, with transactions time- and date-stamped.

=== 3\. Instant traceability

A blockchain can create a provenance trail showing the history of an asset. This is particularly useful where counterfeiting, ethical sourcing, contamination, or supply-chain delays matter.

=== 4\. Increased efficiency and speed

Paper-heavy processes create repeated data entry, reconciliation, and human error. A shared record can reduce the need to exchange and reconcile multiple documents or ledgers.

=== 5\. Automation through smart contracts

A #term[smart contract] can trigger an action when specified conditions are satisfied. The lecture gives insurance as an example: once the required claim documentation is verified, a later processing step can be triggered automatically.

#utptable[
  #tabularx(
    columns: (22%, 1fr),
    styles: (navy-bold,),
    header: ([Benefit], [What problem it targets]),
    [Security], [Unauthorized change and concentration on a single server],
    [Transparency], [Separate records and information asymmetry between participants],
    [Traceability], [Difficulty proving provenance and locating an asset’s history],
    [Efficiency], [Paper, reconciliation, duplicate entry, and manual mediation],
    [Automation], [Human intervention in rule-based contract or process steps],
  )
]

#warning[
  The five benefits are not automatic properties of every blockchain implementation. The lecture presents them as potential advantages when the architecture, permissions, data, governance, and use case are designed appropriately.
]

== A simple ledger example: Alice, Bob, and Charlie

The Week 6--7 slides build intuition with a small transaction sequence.

+ The initial state says Alice has \$50. Every relevant node has the same starting information.
+ Alice pays Bob \$20. The network’s ledger is updated to reflect the transfer.
+ Bob pays Charlie \$10. The new transaction is appended and propagated across copies.

The point is not the arithmetic. It is that each node maintains a consistent history, and changes are represented by new validated records rather than silently editing past transactions.

== Asymmetric cryptography in the lecture

The course introduces #term[asymmetric cryptography] as a pair of mathematically related keys:

- a #term[private key], which the owner keeps secret;
- a #term[public key], which can be shared and used by others in verification.

The lecture uses asymmetric cryptography for two broad goals:

+ identifying or addressing accounts;
+ authorizing transactions.

#note[
  The slides explain signatures using a simplified “encrypt the transaction hash with the private key, verify with the public key” mental model. This is useful for the course concept: the private key creates an authorization that others can verify with public information. Real signature algorithms are implemented according to their specific mathematical rules rather than as generic public-key encryption.
]

== Digital signatures

The lecture says that a blockchain digital signature should satisfy four practical requirements:

- express the owner’s agreement with the specific transaction data;
- be unique to that transaction content so it cannot simply authorize another transaction;
- be creatable only by the owner of the private key;
- be easy for others to verify.

Two operations follow: #term[signing] and #term[verifying].

=== Signing a transaction

In the lecture’s simplified flow:

#utpsteps[
  + Describe the transaction: accounts, amount, and required transaction information.
  + Compute a cryptographic hash of the transaction data.
  + Use the private key to create a signature based on that hash.
  + Attach the resulting signature to the transaction.
]

=== Verifying a transaction

A verifying node:

#utpsteps[
  + Computes the hash of the transaction data itself.
  + Uses the corresponding public information to verify the attached signature.
  + Checks whether the signature is valid for the computed transaction hash.
]

If verification succeeds, the node has evidence that the transaction was authorized by the private-key holder and that the signed content was not changed after signing.

#note[
  A digital signature is like a tamper-sensitive approval stamp. It does not hide the transaction; it proves that the holder of the private key approved a particular version of it.
]

== Hashing and hash references

A #term[cryptographic hash] maps input data to a fixed-length output. The course relies on two intuitive properties:

- changing the input changes the hash output;
- a hash can therefore act as a compact fingerprint of data.

A #term[hash reference] points to data while also committing to their content. If the referenced data change, the old hash reference no longer matches.

This is the mechanism behind the blockchain’s sensitivity to historical modification.

== The blockchain data structure

The lecture describes a blockchain as ordered units called #term[blocks]. Each block contains a header plus transaction data represented through a Merkle tree.

=== Merkle tree

A #term[Merkle tree] combines hashes of individual transactions into higher-level hashes until one top value remains: the #term[Merkle root]. The root acts as a compact commitment to the set of transactions in that block.

#utpfig([A Merkle tree. Transaction hashes are combined pairwise until one value remains, the Merkle root, which commits to every transaction in the block.], label: <fig:merkle-tree>)[
  #canvas({
    let t = (draw: blue, fill: pale-blue, rounded: 1.5mm, min-width: 2.2, min-height: 0.7, align: center, font: font("script", fill: navy))
    let h-style = (draw: teal, fill: pale-teal, rounded: 1.5mm, min-width: 2.2, min-height: 0.7, align: center, font: font("script", weight: "bold", fill: navy))
    let arr = (draw: muted, end: arrow-tip("Stealth", length: 1.7mm, line: 0.4pt))
    node((-4.2, -2.2), [Transaction 1], name: "t1", ..t)
    node((-1.4, -2.2), [Transaction 2], name: "t2", ..t)
    node((1.4, -2.2), [Transaction 3], name: "t3", ..t)
    node((4.2, -2.2), [Transaction 4], name: "t4", ..t)
    node((-2.8, -0.7), [Hash(1,2)], name: "h1", ..h-style)
    node((2.8, -0.7), [Hash(3,4)], name: "h2", ..h-style)
    node((0, 0.9), [Merkle root], name: "r", ..h-style)
    connect("t1", "h1", ..arr)
    connect("t2", "h1", ..arr)
    connect("t3", "h2", ..arr)
    connect("t4", "h2", ..arr)
    connect("h1", "r", ..arr)
    connect("h2", "r", ..arr)
  })
]

If any transaction changes, its leaf hash changes, which changes higher-level hashes and ultimately the Merkle root.

== Block headers

The lecture uses Bitcoin-style block headers to explain common fields:

/ Version: Indicates the protocol or block format used for interpretation.
/ Timestamp: Records the time associated with the block.
/ Difficulty target: Represents the threshold used in proof-of-work mining.
/ Nonce: A value miners vary while searching for a hash that satisfies the target.
/ Previous hash: A hash reference linking the block to the preceding block.
/ Merkle root: A commitment to the transactions represented by the Merkle tree.

Not every distributed ledger uses proof-of-work or the same header structure. The lecture uses Bitcoin-style fields to illustrate how cryptographic linking works.

== How blocks form a chain

Each block header contains the hash of the previous block header. This creates a sequence of dependencies.

#utpfig([How blocks form a chain. Each block header holds the hash of the previous header, so changing an old block breaks every link after it.], label: <fig:block-chain>)[
  #canvas({
    let b = (draw: blue, fill: pale-blue, rounded: 2mm, text-width: 3.1, min-height: 1.55, align: center, font: font("script", fill: navy))
    let arr = (line-width: widths.thick, draw: teal, end: arrow-tip("Stealth", length: 2mm, line: widths.thick))
    node((-4.3, 0), [#strong[Block 1] #parbreak() prev: genesis #parbreak() Merkle root 1], name: "b1", ..b)
    node((0, 0), [#strong[Block 2] #parbreak() prev: hash(Block 1) #parbreak() Merkle root 2], name: "b2", ..b)
    node((4.3, 0), [#strong[Block 3] #parbreak() prev: hash(Block 2) #parbreak() Merkle root 3], name: "b3", ..b)
    connect("b1", "b2", ..arr)
    connect("b2", "b3", ..arr)
  })
]

Changing old block data changes its hash. The next block still contains the old hash reference, creating an inconsistency. A successful historical rewrite would therefore need to update the affected block and all dependent blocks after it, while also satisfying the network’s consensus rules.

== Adding new transaction data

The lecture gives a three-step structural process.

#utpsteps[
  + Create a new Merkle tree containing the new transaction data.
  + Create a new block header containing the previous block reference and the new Merkle root.
  + Compute a hash reference to the new block header, making it the new head of the chain.
]

In a live blockchain, consensus and validation rules determine whether the proposed block becomes part of the accepted ledger.

== Nodes and miners

A #term[node] is a communication point in the blockchain network. The lecture lists node responsibilities such as maintaining a ledger copy, receiving transactions, validating transactions, saving new blocks, and broadcasting information to other peers.

A #term[miner] is a specialized node participating in a proof-of-work block-validation process. Miners validate transactions, assemble candidate blocks, perform computational work, and broadcast accepted results for other nodes to verify.

#utptable[
  #tabularx(
    columns: (20%, 1fr),
    styles: (navy-bold,),
    header: ([Role], [Lecture description]),
    [Node], [Maintains and communicates the ledger; receives, stores, validates, and broadcasts network data depending on node type.],
    [Miner], [A node that participates in block verification and proof-of-work competition, validating and proposing blocks.],
  )
]

== Why historical data are hard to change

The lecture describes blockchain modification as an “all-or-nothing” problem. If historical data change, the hash dependencies from that point to the current head also change. Partial modification leaves an easily detectable inconsistency.

#note[
  Immutability in the course is best understood as #emph[tamper evidence plus the cost and consensus difficulty of rewriting accepted history], not as a magical physical impossibility of changing bytes on a computer.
]

The lecture also mentions Bitcoin’s 1 MB block-size limit as part of its historical explanation. That is a Bitcoin-specific protocol constraint rather than a universal blockchain property.

== Blockchain versus a typical centralized database

A conventional relational database commonly organizes information into tables and allows authorized applications to insert, update, or delete records. A blockchain groups records into sequential blocks and cryptographically links each block to its predecessor.

#utptable[
  #tabularx(
    columns: (22%, 1fr, 1fr),
    styles: (navy-bold,),
    header: ([Dimension], [Centralized database], [Blockchain / distributed ledger framing]),
    [Authority], [One organization controls authoritative state], [State is replicated and agreed across participating peers],
    [Data structure], [Tables / records are common], [Ordered blocks linked by hash references],
    [Change model], [Authorized updates can overwrite state], [History is append-oriented; prior records are tamper-evident],
    [Coordination], [Internal transaction controls], [Network validation and consensus],
    [Performance focus], [Efficient controlled data management], [Shared trust, provenance, and multi-party consistency],
    [Best fit], [One trusted owner and high-performance operations], [Multiple parties need a shared record without one fully trusted owner],
  )
]

#warning[
  Blockchain is not automatically a better database. If one trusted organization can manage the data efficiently and participants do not need a shared tamper-evident ledger, a conventional database may be simpler and faster.
]

== Industry applications from the lecture

=== Supply chains and food

Blockchain can create shared end-to-end visibility and provenance. In food systems, the lecture emphasizes the ability to trace contamination back to its source faster and to reduce waste through better visibility.

=== Banking and finance

Shared ledgers can reduce paperwork, reconciliation, and delays in global trade, trade finance, clearing, settlement, consumer banking, and lending.

=== Healthcare

A distributed record can improve the secure sharing of patient information among authorized providers, payers, and researchers while preserving controlled access.

=== Pharmaceuticals

An audit trail can trace products from origin to pharmacy or retailer, helping identify counterfeits and locate recalled products.

=== Government

The lecture mentions regulatory compliance, contract management, identity management, citizen services, and secure inter-agency data sharing.

=== Insurance

Smart contracts and shared records can automate underwriting and claims processes, reduce paper, speed settlement, and reduce fraud.

== A use-case test: when does blockchain add value?

#utpsteps[
  + #term[Multiple parties.] Are several organizations maintaining related versions of the same truth?
  + #term[Trust problem.] Is there no single party everyone wants to control the authoritative record?
  + #term[Shared history.] Is provenance or a common audit trail important?
  + #term[Reconciliation cost.] Are participants spending time comparing separate records?
  + #term[Automation opportunity.] Can clear rules trigger later process steps?
  + #term[Governance.] Is there a workable method for identity, permissions, validation, consensus, and dispute handling?
]

If the answer to most of these questions is “no,” the added complexity of distributed consensus may not be justified.

#exercises[
  Analyze a pharmaceutical supply chain. Identify the participants, the shared facts they need to agree on, the provenance problem, one smart-contract opportunity, and one reason a conventional shared database might still be preferable.
]

#questions[
  + What changes when a ledger moves from one authoritative copy to replicated peer copies?
  + Name the five blockchain benefits emphasized in the lecture.
  + What roles do a private key, public key, hash, and digital signature play?
  + What is a Merkle root and why does it matter?
  + Name the six Bitcoin-style block-header elements presented in the lecture.
  + Why does changing an old block affect later blocks?
  + What is the difference between a general node and a miner in the course framing?
  + Give one situation where a normal centralized database may be a better choice than blockchain.
]
