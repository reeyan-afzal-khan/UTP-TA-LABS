#import "/.shared/typst/utp.typ": *
#unit("labs", "01-wireshark-capture")

#lab("1")[Capture, filter, and read a live conversation] <sec:lab01-wireshark>

#callout("labproject", title: [Turn a packet capture into evidence])[#strong[Coverage.] Chapter~#ref(label("ch:wireshark"), supplement: none). \
#strong[Goal.] Produce a capture that answers a specific question, rather than a screenshot that shows traffic existed.


#include "/DATA COMMUNICATION & NETWORKING/labs/visuals/01-flow.typ"


#strong[Worked implementation: One host, two terminals, one capture.]

#strong[HTTP server.] Start a capture on the loopback interface, then run this in terminal A. Leave it running during the request. #source-code("/DATA COMMUNICATION & NETWORKING/labs/configs/lab01-01.txt", first: 1, last: none, lang: "text")

#strong[HTTP request.] In terminal B, request the page. On Windows use curl.exe; on Linux/macOS use curl. #source-code("/DATA COMMUNICATION & NETWORKING/labs/configs/lab01-02.txt", first: 1, last: none, lang: "text")

#strong[Display filter.] Apply this in Wireshark after the request. Locate SYN, SYN/ACK, ACK, the GET request and the response. Stop the server with Ctrl+C. #source-code("/DATA COMMUNICATION & NETWORKING/labs/configs/lab01-03.txt", first: 1, last: none, lang: "text")

#strong[Expected evidence.] The response should contain a directory listing and a successful HTTP status. Save a pcapng containing the exchange. Loopback traffic has no physical Ethernet hop; use the existing LAN exercise for ARP.

#callout("labmode", title: [How to use this lab])[Capture on a network you are authorised to observe --- your own machine, your own lab segment, or the eNSP simulation. Capturing on a shared campus or corporate network without permission is a disciplinary matter and in many jurisdictions an offence.

Everything below works on loopback or your own interface, so there is no reason to point Wireshark at anyone else's traffic.]

#strong[Part A --- Ask the question first.]

The single most common mistake is starting the capture before deciding what it is meant to prove. You then face 40,000 packets and no criterion for which matter.

Write the question down before you press start. Good questions look like:

- Did the DNS lookup for `example.com` succeed, and how long did it take?

- Did the TCP handshake complete, or was it reset?

- Which host sent the first packet of this conversation?

#callout("keyidea", title: [Key idea])[A capture filter decides what is #emph[recorded]. A display filter decides what is #emph[shown]. They use different syntaxes, and confusing them is the most common source of an empty result window.

Capture filter (BPF): `tcp port 80` \
Display filter (Wireshark): `tcp.port == 80`

Capture broadly and filter afterwards. A capture filter that was too narrow cannot be widened once the traffic has passed.]

#strong[Part B --- A disciplined capture.]

+ Choose the interface carrying the traffic. If unsure, watch the sparklines in the Wireshark start screen.

+ Start the capture, then generate the traffic --- not the other way round.

+ Perform exactly one transaction. One page load, one ping sequence, one login.

+ Stop the capture immediately. Ten seconds of relevant traffic beats ten minutes of noise.

+ Save the raw `.pcapng` before filtering. That file is your evidence.

#strong[Part C --- Filters that earn their keep.]

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Display filter], [Shows],),
    table.hline(),
    [ip.addr == 192.168.1.10], [Everything to or from one host],
    [tcp.port == 80 || tcp.port == 443], [Web traffic in both directions],
    [tcp.flags.syn == 1 && tcp.flags.ack == 0], [Connection attempts only],
    [tcp.analysis.retransmission], [Packets Wireshark believes were resent],
    [dns], [Name resolution],
    [icmp], [Ping and unreachable messages],
    [http.request.method == \"GET\"], [Page requests],
  )]
  , kind: table
  )

#callout("pitfall", title: [Common mistake])[`ip.addr != 192.168.1.10` does not mean what it appears to. A packet has both a source and a destination address, so the expression is true whenever #emph[either] differs --- which is nearly always.

Write `!(ip.addr == 192.168.1.10)` instead. The same trap applies to every address and port field.]

#strong[Part D --- Read one TCP handshake end to end.]

Filter to a single conversation (right-click a packet, then #emph[Follow $arrow.r$ TCP Stream]) and identify the three-way handshake:


#include "/DATA COMMUNICATION & NETWORKING/labs/visuals/01-trace.typ"


#strong[Use the chapter while coding.] Revisit #link(label("ch:wireshark"))[the earlier chapter explanation]; match its operation to the variables and state changes below.

#strong[Follow the supplied implementation.] Use the lab's generated traffic so the expected exchange is under your control. The HTTP display filter hides unrelated traffic but does not create a capture. If no packets appear, check the interface and capture timing before changing the server. 
#include "/DATA COMMUNICATION & NETWORKING/labs/visuals/01-worked-case.typ"


#code-block("No.  Source        Destination   Proto  Info\n1    192.168.1.10  93.184.216.34 TCP    49152 > 80 [SYN] Seq=0 Win=64240\n2    93.184.216.34 192.168.1.10  TCP    80 > 49152 [SYN, ACK] Seq=0 Ack=1\n3    192.168.1.10  93.184.216.34 TCP    49152 > 80 [ACK] Seq=1 Ack=1", lang: "text")

Answer from your own capture: which host initiated, what ephemeral port did it choose, and how long elapsed between packets 1 and 3? That last figure is the round-trip time, and it is the number a network engineer actually cares about.

#callout("troubleshoot", title: [Troubleshooting])[#strong[No packets at all.] Wrong interface, or a capture filter with a typo. Clear the capture filter and try again.

#strong[Traffic appears but not yours.] You are probably on a switched network seeing only broadcast and your own frames --- which is normal and correct.

#strong[HTTPS shows no readable content.] That is TLS doing its job. You can still see the handshake, the SNI hostname, and the timing. Analyse those instead.]

#callout("tryit", title: [Try it yourself])[Capture a `ping` to an address that does not exist on your subnet. No reply arrives --- so what #emph[does] the capture contain, and what does that tell you about how the host tried to find the destination? Look for ARP.]]

#strong[Chapter connection.] Revisit #link(label("ch:wireshark"))[the chapter explanation] and map its states to the steps below. 
#include "/DATA COMMUNICATION & NETWORKING/labs/visuals/01-wireshark-capture-chapter.typ"


#callout("verification", title: [Verification checklist])[#strong[Explain and extend your result.] Match one client request to its response using endpoints and stream identity. Record the status and explain where the request path and response body appear.

- The raw `.pcapng` is saved and submitted, not only screenshots.

- The question the capture answers is stated before the evidence.

- Display filters are quoted exactly as used.

- Packet numbers are cited when referring to specific packets.

- The capture was taken on a network you are authorised to observe.]
