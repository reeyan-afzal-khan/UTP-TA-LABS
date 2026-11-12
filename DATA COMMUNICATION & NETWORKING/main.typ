// Data Communication & Networking: the book. Settings first, then the chapters and labs in teaching order.
#import "/.shared/typst/utp.typ": *
#show: book.with(
  title: [Data Communication & Networking],
  running-head: [Data Communication & Networking Notes],
  outline: [Built from the supplied laboratory materials for Wireshark, eNSP/Huawei VRP, \
 routing, FTP, DHCP, LACP, VLANs, and WAN configuration.],
  lab-total: 9,
  titles: (worked: [Worked configuration], labmode: [How to use this lab], troubleshoot: [When it does not work], verification: [Verification evidence]),
)
#cover()
#contents()
#include "chapters/course-map.typ"
#show: mainmatter

#include "chapters/00-toolkit.typ"

#part[Observe and Configure]
#include "chapters/01-foundation.typ"

#include "chapters/02-wireshark.typ"
#include "labs/01-wireshark-capture.typ"

#include "chapters/03-ensp-vrp.typ"
#include "labs/02-ensp-vrp.typ"

#part[Make Networks Reachable]
#include "chapters/04-static-routing.typ"
#include "labs/03-static-routing.typ"

#include "chapters/05-ospf.typ"
#include "labs/04-ospf.typ"

#part[Add Network Services]
#include "chapters/06-ftp.typ"
#include "labs/05-ftp.typ"

#include "chapters/07-dhcp.typ"
#include "labs/06-dhcp.typ"

#part[Build the Switched LAN]
#include "chapters/08-lacp.typ"
#include "labs/07-lacp.typ"

#include "chapters/09-vlan.typ"
#include "labs/08-vlan.typ"

#part[Connect Sites Across a WAN]
#include "chapters/10-wan.typ"
#include "labs/09-wan.typ"

#include "chapters/capstone-project.typ"
#include "chapters/command-reference.typ"
