#import "/.shared/typst/utp.typ": *

#utpfigure(title: [One accumulator: changes after each product])[
  #canvas({
    node((0, 0), [0], font: font("small"), ..utphot, min-width: 0.88, min-height: 0.65)
    node((0, 0.6), [0], font: font("small"), ..utplabel)
    node((6, 0), [`P[0][0]=0` before the inner loop], font: font("small"), ..utplabel, anchor: "west", align: left, text-width: 6)
    connect((-0.85, -0.35), (-0.85, -0.6), ..utparrow)
    node((0, -0.95), [7], font: font("small"), ..utphot, min-width: 0.88, min-height: 0.65)
    node((6, -0.95), [`t=0`: add $1 times 7$], font: font("small"), ..utplabel, anchor: "west", align: left, text-width: 6)
    connect((-0.85, -1.3), (-0.85, -1.55), ..utparrow)
    node((0, -1.9), [25], font: font("small"), ..utphot, min-width: 0.88, min-height: 0.65)
    node((6, -1.9), [`t=1`: add $2 times 9$], font: font("small"), ..utplabel, anchor: "west", align: left, text-width: 6)
    connect((-0.85, -2.25), (-0.85, -2.5), ..utparrow)
    node((0, -2.85), [58], font: font("small"), ..utphot, min-width: 0.88, min-height: 0.65)
    node((6, -2.85), [`t=2`: add $3 times 11$], font: font("small"), ..utplabel, anchor: "west", align: left, text-width: 6)
  })
]
