#import "/.shared/typst/utp.typ": *

#utpcompactlabfigure[Exact-length search: undo the failed branch][
  #labgraphic[
    #canvas(compact: true, {
      node((0, 0), [A], name: "r0n0", font: font("small"), ..utpnodehot, min-size: 0.8)
      node((3.8, 0), [Initial call: remaining=2; mark A], font: font("small"), ..utplabel, anchor: "west", align: left, text-width: 5.5)
      node((0, -1.35), [A], name: "r1n0", font: font("small"), ..utpnode, min-size: 0.8)
      node((1.35, -1.35), [B], name: "r1n1", font: font("small"), ..utpnodehot, min-size: 0.8)
      connect("r1n0", "r1n1", ..utparrow)
      node((3.8, -1.35), [Try B: push B, mark B; remaining=1], font: font("small"), ..utplabel, anchor: "west", align: left, text-width: 5.5)
      node((0, -2.7), [A], name: "r2n0", font: font("small"), ..utpnode, min-size: 0.8)
      node((1.35, -2.7), [B], name: "r2n1", font: font("small"), ..utpnode, min-size: 0.8)
      connect("r2n0", "r2n1", ..utparrow)
      node((2.7, -2.7), [D], name: "r2n2", font: font("small"), ..utpnodehot, min-size: 0.8)
      connect("r2n1", "r2n2", ..utparrow)
      node((3.8, -2.7), [Try D: remaining=0, but D is not E \
    Undo: pop D and clear its on-path marker], font: font("small"), ..utplabel, anchor: "west", align: left, text-width: 5.5)
      node((0, -4.05), [A], name: "r3n0", font: font("small"), ..utpnode, min-size: 0.8)
      node((1.35, -4.05), [B], name: "r3n1", font: font("small"), ..utpnode, min-size: 0.8)
      connect("r3n0", "r3n1", ..utparrow)
      node((2.7, -4.05), [E], name: "r3n2", font: font("small"), ..utpnodehot, min-size: 0.8)
      connect("r3n1", "r3n2", ..utparrow)
      node((3.8, -4.05), [Try E: remaining=0 and target matches \
    Return true; retain the successful path], font: font("small"), ..utplabel, anchor: "west", align: left, text-width: 5.5)
    })
  ]
]
