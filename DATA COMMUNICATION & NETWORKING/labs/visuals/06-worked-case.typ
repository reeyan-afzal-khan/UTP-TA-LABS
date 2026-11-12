#import "/.shared/typst/utp.typ": *

#courselabtrace([Trace the remote-client DHCP path], [1\. Input / state], [Server 10.0.12.1 serves the 192.168.3.0/24 pool through relay 10.0.12.2.], [2\. Operation], [The client-facing gateway is 192.168.3.1; exclusions reserve .2 through .10 from dynamic allocation.], [3\. Check], [Inspect the client lease, mask and gateway; the server needs the configured route back to the client network.])
