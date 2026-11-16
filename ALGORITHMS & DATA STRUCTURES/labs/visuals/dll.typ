#import "/.shared/typst/utp.typ": *

#utpcompactlabfigure[A doubly linked list][
  #labgraphic[
    #canvas(compact: true, {
      let fw = 0.78
      for (i, vv) in range(10, 31, step: 10).enumerate() {
        let x = 3.55 * i
        if i == 0 {
          node((x, 0), [NULL], name: "pv" + str(i), ..utpcell, min-width: fw, min-height: 0.9, fill: pale-gray, font: font("script", fill: muted))
        } else {
          node((x, 0), [], name: "pv" + str(i), font: font("small"), ..utpcell, min-width: fw, min-height: 0.9, fill: white)
        }
        node((x + 0.89, 0), [#vv], name: "dt" + str(i), font: font("small"), ..utpcell, min-width: 1, min-height: 0.9)
        if i == 2 {
          node((x + 1.78, 0), [NULL], name: "nx" + str(i), ..utpcell, min-width: fw, min-height: 0.9, fill: pale-gray, font: font("script", fill: muted))
        } else {
          node((x + 1.78, 0), [], name: "nx" + str(i), font: font("small"), ..utpcell, min-width: fw, min-height: 0.9, fill: white)
        }
      }
      node((0, 0.52), [prev], font: font("small"), ..utplabel, anchor: "south")
      node((0.89, 0.52), [data], font: font("small"), ..utplabel, anchor: "south")
      node((1.78, 0.52), [next], font: font("small"), ..utplabel, anchor: "south")
      for i in (0, 1) {
        let j = int(i + 1)
        connect("nx" + str(i) + ".north", "dt" + str(j) + ".north", bend: 38deg, ..utparrow, name: "curve-1")
      }
      for i in (1, 2) {
        let j = int(i - 1)
        connect("pv" + str(i) + ".south", "dt" + str(j) + ".south", bend: 38deg, line-width: widths.thick, draw: orange, end: arrow-tip("Stealth", length: 2.2mm, line: widths.thick), name: "curve-2")
      }
      node((7.6, 1.05), [forward: `next`], font: font("small"), ..utplabel, anchor: "west", text: teal)
      node((7.6, -1.05), [backward: `prev`], font: font("small"), ..utplabel, anchor: "west", text: orange)
    })
  ]
]
