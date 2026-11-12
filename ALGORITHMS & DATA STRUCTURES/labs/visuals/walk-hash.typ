#import "/.shared/typst/utp.typ": *

#utpcompactlabfigure[Insert 15 by double hashing: home 0, step 4][
  #labgraphic[
    #canvas(compact: true, {
      node((0, 0), [10], font: font("small"), ..utphot, min-width: 0.88, min-height: 0.65)
      node((0, 0.6), [0], font: font("small"), ..utplabel)
      node((0.92, 0), [--], font: font("small"), ..utpdim, min-width: 0.88, min-height: 0.65)
      node((0.92, 0.6), [1], font: font("small"), ..utplabel)
      node((1.84, 0), [12], font: font("small"), ..utpcell, min-width: 0.88, min-height: 0.65)
      node((1.84, 0.6), [2], font: font("small"), ..utplabel)
      node((2.76, 0), [--], font: font("small"), ..utpdim, min-width: 0.88, min-height: 0.65)
      node((2.76, 0.6), [3], font: font("small"), ..utplabel)
      node((3.68, 0), [14], font: font("small"), ..utpcell, min-width: 0.88, min-height: 0.65)
      node((3.68, 0.6), [4], font: font("small"), ..utplabel)
      node((4.8, 0), [i=0: $(0+0 times 4) mod 5=0$ \
    Occupied by 10: continue], font: font("small"), ..utplabel, anchor: "west", align: left, text-width: 5.2)
      connect((-0.85, -0.35), (-0.85, -0.85), ..utparrow)
      node((0, -1.2), [10], font: font("small"), ..utpcell, min-width: 0.88, min-height: 0.65)
      node((0.92, -1.2), [--], font: font("small"), ..utpdim, min-width: 0.88, min-height: 0.65)
      node((1.84, -1.2), [12], font: font("small"), ..utpcell, min-width: 0.88, min-height: 0.65)
      node((2.76, -1.2), [--], font: font("small"), ..utpdim, min-width: 0.88, min-height: 0.65)
      node((3.68, -1.2), [14], font: font("small"), ..utphot, min-width: 0.88, min-height: 0.65)
      node((4.8, -1.2), [i=1: $(0+1 times 4) mod 5=4$ \
    Occupied by 14: continue], font: font("small"), ..utplabel, anchor: "west", align: left, text-width: 5.2)
      connect((-0.85, -1.55), (-0.85, -2.05), ..utparrow)
      node((0, -2.4), [10], font: font("small"), ..utpcell, min-width: 0.88, min-height: 0.65)
      node((0.92, -2.4), [--], font: font("small"), ..utpdim, min-width: 0.88, min-height: 0.65)
      node((1.84, -2.4), [12], font: font("small"), ..utpcell, min-width: 0.88, min-height: 0.65)
      node((2.76, -2.4), [15], font: font("small"), ..utphot, min-width: 0.88, min-height: 0.65)
      node((3.68, -2.4), [14], font: font("small"), ..utpcell, min-width: 0.88, min-height: 0.65)
      node((4.8, -2.4), [i=2: $(0+2 times 4) mod 5=3$ \
    Empty: store 15 and return 3], font: font("small"), ..utplabel, anchor: "west", align: left, text-width: 5.2)
    })
  ]
]
