# Capture checklist — Lab 1

Work top to bottom. The order matters: everything below step 2 assumes the
question is already written down.

## Before

- [ ] I am authorised to capture on this network (my own machine, my own lab
      segment, or the eNSP simulation).
- [ ] **The question this capture must answer is written down.**
      Not "look at traffic" — something like "did the DNS lookup succeed, and
      how long did it take?"
- [ ] Correct interface identified (check the sparklines on the start screen).
- [ ] Capture filter left empty, or deliberately broad.

## During

- [ ] Capture started **before** the traffic was generated.
- [ ] Exactly one transaction performed.
- [ ] Capture stopped immediately afterwards.

## After

- [ ] Raw `.pcapng` saved before any filtering. This is the evidence.
- [ ] Display filter recorded exactly as typed.
- [ ] Relevant packets cited by number.
- [ ] Screenshot annotated — arrows and labels, not a bare window.

## Evidence quality

A screenshot showing packets is not evidence. Evidence is:

| Weak | Strong |
| --- | --- |
| "Traffic was captured" | "Packets 14–16 show the three-way handshake" |
| "The ping worked" | "RTT measured 1.4 ms across 5 replies, 0% loss" |
| "I filtered for HTTP" | "Filter `http.request.method == \"GET\"` returned 3 packets" |

## Common mistakes

- Capturing for minutes and then hunting through 40,000 packets.
- Using a capture filter that was too narrow — traffic you did not record
  cannot be recovered.
- Writing `ip.addr != x` and wondering why nothing is excluded.
- Submitting a screenshot with no packet numbers, so nothing can be checked.
