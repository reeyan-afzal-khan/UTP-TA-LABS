#import "/.shared/typst/utp.typ": *

#utpcompactlabfigure[The “false full” problem][
  #labgraphic[
    #canvas(compact: true, {
      for (i, vv) in (none, none, "C", "D", "E").enumerate() {
        if vv == none or vv == "" {
          node((1.2 * i, 0), [], name: "z" + str(i), font: font("small"), ..utpdim, min-width: 1.15, min-height: 0.85)
        } else {
          node((1.2 * i, 0), [#vv], name: "z" + str(i), font: font("small"), ..utpcell, min-width: 1.15, min-height: 0.85)
        }
        node((1.2 * i, -0.68), [#i], font: font("small"), ..utplabel)
      }
      node((2.4, 1.15), [FRONT], name: "fronttag", draw: orange, fill: pale-orange, rounded: 1mm, font: font("script", weight: "bold", fill: mix(orange, 70%, other: black)), inner-xsep: 2.2mm, inner-ysep: 1mm)
      connect("fronttag.south", (rel: (0, 0.07), to: "z2.north"), line-width: 0.8966pt, draw: orange, end: arrow-tip("Stealth", length: 2.1mm, width: 1.45mm, line: 0.8966pt))
      node((4.8, 1.15), [REAR], name: "reartag", draw: orange, fill: pale-orange, rounded: 1mm, font: font("script", weight: "bold", fill: mix(orange, 70%, other: black)), inner-xsep: 2.2mm, inner-ysep: 1mm)
      connect("reartag.south", (rel: (0, 0.07), to: "z4.north"), line-width: 0.8966pt, draw: orange, end: arrow-tip("Stealth", length: 2.1mm, width: 1.45mm, line: 0.8966pt))
      brace((-0.62, -0.9), (0.62, -0.9), mirror: true, amplitude: 3.9851pt, raise: 2.9888pt, draw: green, line-width: widths.semithick)
      node((0, -1.3), [free, but \
    unreachable], font: font("small"), ..utplabel, anchor: "north", align: center, text: green)
      node((5.7, 0), [`enqueue(F)` fails: \
    `rear` is at the last index], font: font("small"), ..utplabel, anchor: "west", align: left, text: red)
    })
  ]
]
