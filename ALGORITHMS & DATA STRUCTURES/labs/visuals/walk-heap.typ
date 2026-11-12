#import "/.shared/typst/utp.typ": *

#utpcompactlabfigure[Sift-up and sift-down on the lab heap][
  #labgraphic[
    #canvas(compact: true, {
      node((0, 0), [50], font: font("small"), ..utpcell, min-width: 0.88, min-height: 0.65)
      node((0, 0.6), [0], font: font("small"), ..utplabel)
      node((0.92, 0), [20], font: font("small"), ..utpcell, min-width: 0.88, min-height: 0.65)
      node((0.92, 0.6), [1], font: font("small"), ..utplabel)
      node((1.84, 0), [30], font: font("small"), ..utpcell, min-width: 0.88, min-height: 0.65)
      node((1.84, 0.6), [2], font: font("small"), ..utplabel)
      node((2.76, 0), [10], font: font("small"), ..utpcell, min-width: 0.88, min-height: 0.65)
      node((2.76, 0.6), [3], font: font("small"), ..utplabel)
      node((3.68, 0), [40], font: font("small"), ..utphot, min-width: 0.88, min-height: 0.65)
      node((3.68, 0.6), [4], font: font("small"), ..utplabel)
      node((4.8, 0), [Append 40: i=4, parent p=1], font: font("small"), ..utplabel, anchor: "west", align: left, text-width: 5.2)
      connect((-0.85, -0.35), (-0.85, -0.85), ..utparrow)
      node((0, -1.2), [50], font: font("small"), ..utpcell, min-width: 0.88, min-height: 0.65)
      node((0.92, -1.2), [40], font: font("small"), ..utphot, min-width: 0.88, min-height: 0.65)
      node((1.84, -1.2), [30], font: font("small"), ..utpcell, min-width: 0.88, min-height: 0.65)
      node((2.76, -1.2), [10], font: font("small"), ..utpcell, min-width: 0.88, min-height: 0.65)
      node((3.68, -1.2), [20], font: font("small"), ..utpcell, min-width: 0.88, min-height: 0.65)
      node((4.8, -1.2), [40 $>$ 20: swap 4 and 1 \
    50 $>=$ 40: stop sifting up], font: font("small"), ..utplabel, anchor: "west", align: left, text-width: 5.2)
      connect((-0.85, -1.55), (-0.85, -2.05), ..utparrow)
      node((0, -2.4), [20], font: font("small"), ..utphot, min-width: 0.88, min-height: 0.65)
      node((0.92, -2.4), [40], font: font("small"), ..utpcell, min-width: 0.88, min-height: 0.65)
      node((1.84, -2.4), [30], font: font("small"), ..utpcell, min-width: 0.88, min-height: 0.65)
      node((2.76, -2.4), [10], font: font("small"), ..utpcell, min-width: 0.88, min-height: 0.65)
      node((3.68, -2.4), [--], font: font("small"), ..utpdim, min-width: 0.88, min-height: 0.65)
      node((4.8, -2.4), [Remove 50; move last value 20 to root \
    Shorten active size to 4], font: font("small"), ..utplabel, anchor: "west", align: left, text-width: 5.2)
      connect((-0.85, -2.75), (-0.85, -3.25), ..utparrow)
      node((0, -3.6), [40], font: font("small"), ..utphot, min-width: 0.88, min-height: 0.65)
      node((0.92, -3.6), [20], font: font("small"), ..utphot, min-width: 0.88, min-height: 0.65)
      node((1.84, -3.6), [30], font: font("small"), ..utpcell, min-width: 0.88, min-height: 0.65)
      node((2.76, -3.6), [10], font: font("small"), ..utpcell, min-width: 0.88, min-height: 0.65)
      node((3.68, -3.6), [--], font: font("small"), ..utpdim, min-width: 0.88, min-height: 0.65)
      node((4.8, -3.6), [Choose larger child 40; swap with 20 \
    20 $>=$ 10: stop sifting down], font: font("small"), ..utplabel, anchor: "west", align: left, text-width: 5.2)
    })
  ]
]
