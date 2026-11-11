#import "/.shared/typst/utp.typ": *
#show: book.with(title: [Data Communication & Networking], summary: [Built from the supplied laboratory materials for Wireshark, eNSP/Huawei VRP, \
routing, FTP, DHCP, LACP, VLANs, and WAN configuration.], lab-total: 9, mono-font: "Inconsolatazi4")

#cover(title: [Data Communication & Networking], summary: [Built from the supplied laboratory materials for Wireshark, eNSP/Huawei VRP, \
routing, FTP, DHCP, LACP, VLANs, and WAN configuration.])
#outline(depth: 1)
#pagebreak()
#include "chapters/course-map.typ"

#include "/DATA COMMUNICATION & NETWORKING/chapters/00-toolkit.typ"


#stage[Observe and Configure] 
#include "/DATA COMMUNICATION & NETWORKING/chapters/01-foundation.typ"



#include "/DATA COMMUNICATION & NETWORKING/chapters/02-wireshark.typ"
 
#include "/DATA COMMUNICATION & NETWORKING/labs/01-wireshark-capture.typ"



#include "/DATA COMMUNICATION & NETWORKING/chapters/03-ensp-vrp.typ"
 
#include "/DATA COMMUNICATION & NETWORKING/labs/02-ensp-vrp.typ"


#stage[Make Networks Reachable] 
#include "/DATA COMMUNICATION & NETWORKING/chapters/04-static-routing.typ"
 
#include "/DATA COMMUNICATION & NETWORKING/labs/03-static-routing.typ"



#include "/DATA COMMUNICATION & NETWORKING/chapters/05-ospf.typ"
 
#include "/DATA COMMUNICATION & NETWORKING/labs/04-ospf.typ"


#stage[Add Network Services] 
#include "/DATA COMMUNICATION & NETWORKING/chapters/06-ftp.typ"
 
#include "/DATA COMMUNICATION & NETWORKING/labs/05-ftp.typ"



#include "/DATA COMMUNICATION & NETWORKING/chapters/07-dhcp.typ"
 
#include "/DATA COMMUNICATION & NETWORKING/labs/06-dhcp.typ"


#stage[Build the Switched LAN] 
#include "/DATA COMMUNICATION & NETWORKING/chapters/08-lacp.typ"
 
#include "/DATA COMMUNICATION & NETWORKING/labs/07-lacp.typ"



#include "/DATA COMMUNICATION & NETWORKING/chapters/09-vlan.typ"
 
#include "/DATA COMMUNICATION & NETWORKING/labs/08-vlan.typ"


#stage[Connect Sites Across a WAN] 
#include "/DATA COMMUNICATION & NETWORKING/chapters/10-wan.typ"
 
#include "/DATA COMMUNICATION & NETWORKING/labs/09-wan.typ"



#include "/DATA COMMUNICATION & NETWORKING/chapters/capstone-project.typ"
 
#include "/DATA COMMUNICATION & NETWORKING/chapters/command-reference.typ"

