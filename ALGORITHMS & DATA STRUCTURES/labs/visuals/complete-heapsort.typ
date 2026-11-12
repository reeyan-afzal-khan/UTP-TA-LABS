#import "/.shared/typst/utp.typ": *

#utpcompactlabfigure[The heap shrinks while the sorted suffix grows][
  #labgraphic[
    #canvas(compact: true, {
      node((0, 0), [37], font: font("small"), ..utpcell)
      node((1.1, 0), [29], font: font("small"), ..utpcell)
      node((2.2, 0), [14], font: font("small"), ..utpcell)
      node((3.3, 0), [10], font: font("small"), ..utpcell)
      node((4.4, 0), [13], font: font("small"), ..utpcell)
      node((6, 0), [Active prefix: 5; sorted suffix: 0], font: font("small"), ..utplabel, anchor: "west")
      node((0, -1), [29], font: font("small"), ..utpcell)
      node((1.1, -1), [13], font: font("small"), ..utpcell)
      node((2.2, -1), [14], font: font("small"), ..utpcell)
      node((3.3, -1), [10], font: font("small"), ..utpcell)
      node((4.4, -1), [37], font: font("small"), ..utpdim)
      node((6, -1), [Active prefix: 4; sorted suffix: 1], font: font("small"), ..utplabel, anchor: "west")
      node((0, -2), [14], font: font("small"), ..utpcell)
      node((1.1, -2), [13], font: font("small"), ..utpcell)
      node((2.2, -2), [10], font: font("small"), ..utpcell)
      node((3.3, -2), [29], font: font("small"), ..utpdim)
      node((4.4, -2), [37], font: font("small"), ..utpdim)
      node((6, -2), [Active prefix: 3; sorted suffix: 2], font: font("small"), ..utplabel, anchor: "west")
      node((0, -3), [10], font: font("small"), ..utpcell)
      node((1.1, -3), [13], font: font("small"), ..utpdim)
      node((2.2, -3), [14], font: font("small"), ..utpdim)
      node((3.3, -3), [29], font: font("small"), ..utpdim)
      node((4.4, -3), [37], font: font("small"), ..utpdim)
      node((6, -3), [Finished: all values ascending], font: font("small"), ..utplabel, anchor: "west")
    })
  ]
]
