#import "/.shared/typst/utp.typ": *

#utpcompactlabfigure[Anatomy of a singly linked list][
  #labgraphic[
    #canvas(compact: true, {
      let nw = 1.15
      for (i, (vv, addr, nxt)) in ((10, 2040, "3160"), (20, 3160, "1004"), (30, 1004, none)).enumerate() {
        let x = 4.3 * i
        node((x, 0), [#vv], name: "d" + str(i), font: font("small"), ..utpcell, min-width: nw, min-height: 0.9)
        if nxt == none or nxt == "" {
          node((x + nw, 0), [NULL], name: "p" + str(i), ..utpcell, min-width: nw, min-height: 0.9, fill: pale-gray, font: font("script", fill: muted))
        } else {
          node((x + nw, 0), [#nxt], name: "p" + str(i), ..utpcell, min-width: nw, min-height: 0.9, fill: white, font: font("script", fill: blue))
        }
        node((x + 0.575 * nw, -0.58), [node at #mono[#addr]], font: font("small"), ..utplabel, anchor: "north", align: center)
      }
      node((0, 0.52), [data], font: font("small"), ..utplabel, anchor: "south")
      node((nw, 0.52), [next], font: font("small"), ..utplabel, anchor: "south")
      for i in (0, 1) {
        let j = int(i + 1)
        connect("p" + str(i) + ".east", "d" + str(j) + ".west", ..utpptr)
      }
      node((-0.85, 0), [HEAD], font: font("small"), ..utptag, anchor: "east")
      connect((-0.8, 0), "d0.west", ..utpptr, draw: orange)
    })
  ]
]
