#import "/.shared/typst/utp.typ": *

#utpcompactlabfigure[Advance only the cursor that supplies the output][
  #labgraphic[
    #canvas(compact: true, {
      for (vals, y, tag-v) in (((1, 4, 9), 0, "A"), ((2, 4, 7, 10), -1.15, "B"), ((3, 5), -2.3, "C")) {
        node((-0.8, y), [#tag-v], font: font("small"), ..utptag, anchor: "east")
        for (i, vv) in vals.enumerate() {
          let st = none
          if i == 0 {
            st = utphot
          } else {
            st = utpcell
          }
          node((0.9 * i, y), [#vv], font: font("small"), ..st, min-width: 0.85, min-height: 0.65)
        }
      }
      node((4.1, -1.1), [heads 1,2,3: emit 1; advance A \
    heads 4,2,3: emit 2; advance B \
    heads 4,4,3: emit 3; advance C \
    heads 4,4,5: emit A’s 4; B’s 4 stays], font: font("small"), ..utplabel, anchor: "west", align: left)
      connect((1.3, -2.9), (1.3, -3.35), ..utparrow)
      for (i, vv) in (1, 2, 3, 4, 4, 5, 7, 9, 10).enumerate() {
        node((0.9 * i, -3.8), [#vv], font: font("small"), ..utpcell, min-width: 0.85, min-height: 0.65)
      }
      node((3.6, -4.25), [Keep both 4s. Ignore exhausted runs; never read beyond their lengths.], font: font("small"), ..utplabel, anchor: "north")
    })
  ]
]
