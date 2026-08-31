# PAP vs CHAP — Lab 9

## PAP

**Authenticator (HQ):**

```
aaa
 local-user branch password cipher Branch@123
 local-user branch service-type ppp
quit
interface Serial 0/0/0
 ppp authentication-mode pap
quit
```

**Authenticated (Branch):**

```
interface Serial 0/0/0
 ppp pap local-user branch password cipher Branch@123
quit
```

PAP sends the password **in plaintext**, once, at link setup. Anyone
capturing the link has the credential permanently.

## CHAP

**Authenticator (HQ):**

```
interface Serial 0/0/0
 ppp authentication-mode chap
quit
```

**Authenticated (Branch):**

```
interface Serial 0/0/0
 ppp chap user branch
 ppp chap password cipher Branch@123
quit
```

CHAP **never sends the password**:

1. The authenticator sends a random challenge.
2. The peer replies with a hash of the challenge combined with the secret.
3. The authenticator computes the same hash and compares.

A captured exchange yields nothing reusable, because the next challenge
differs. CHAP also re-challenges periodically during the session, so a
link cannot be hijacked after setup.

## Prove the difference

Capture both exchanges. With PAP the password is readable in the capture.
With CHAP you see only a challenge and a hash.

This is the same lesson as Lab 5, where FTP sends its password in the
clear. Both labs show a credential crossing a link; only one design
survives an observer.

## Troubleshooting

| Symptom | Cause |
| --- | --- |
| Physical down | Cable not connected in eNSP, or the device is not started |
| Physical up, Protocol down | Encapsulation mismatch, missing clock rate on the DCE end, or failed authentication — check in that order |
| LCP completes, IPCP never does | Authentication is failing, not addressing |
| Works with PAP, fails with CHAP | CHAP matches on hostname by default; confirm `ppp chap user` matches the configured `local-user` |

Note: HDLC is vendor-specific in practice. Huawei's and Cisco's
implementations do not interoperate, which is one reason PPP is the safer
default between equipment from different vendors.
