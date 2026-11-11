#import "/.shared/typst/utp.typ": *

#callout("labvisual", title: [TCP connection establishment])[#flow([*Client to server*

SYN starts a connection attempt], [*Server to client*

SYN plus ACK acknowledges and responds], [*Client to server*

ACK completes the three-way handshake])]
