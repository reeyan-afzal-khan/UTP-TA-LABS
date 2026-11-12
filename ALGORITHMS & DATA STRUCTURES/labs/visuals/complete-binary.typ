#import "/.shared/typst/utp.typ": *

#utpcompactlabfigure[Each comparison removes a half of the remaining interval][
  #labgraphic[
    #canvas(compact: true, {
      node((0, 0), [10], font: font("small"), ..utpcell)
      node((0, 0.65), [0], font: font("small"), ..utplabel)
      node((1.1, 0), [13], font: font("small"), ..utpcell)
      node((1.1, 0.65), [1], font: font("small"), ..utplabel)
      node((2.2, 0), [14], font: font("small"), ..utphot)
      node((2.2, 0.65), [2], font: font("small"), ..utplabel)
      node((3.3, 0), [29], font: font("small"), ..utpcell)
      node((3.3, 0.65), [3], font: font("small"), ..utplabel)
      node((4.4, 0), [37], font: font("small"), ..utpcell)
      node((4.4, 0.65), [4], font: font("small"), ..utplabel)
      node((6, 0), [29 \> 14: left becomes 3], font: font("small"), ..utplabel, anchor: "west")
      node((0, -1.3), [10], font: font("small"), ..utpdim)
      node((1.1, -1.3), [13], font: font("small"), ..utpdim)
      node((2.2, -1.3), [14], font: font("small"), ..utpdim)
      node((3.3, -1.3), [29], font: font("small"), ..utphot)
      node((4.4, -1.3), [37], font: font("small"), ..utpcell)
      node((6, -1.3), [29 == 29: return index 3], font: font("small"), ..utplabel, anchor: "west")
    })
  ]
]
