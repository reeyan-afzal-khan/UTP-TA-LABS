#import "/.shared/typst/utp.typ": *

#utpfigure(title: [Insert 15, then delete 20: preserve the next live node])[
  #canvas({
    node((0, 0), [10], name: "r0n0", font: font("small"), ..utpnode, min-size: 0.8)
    node((1.35, 0), [20], name: "r0n1", font: font("small"), ..utpnode, min-size: 0.8)
    connect("r0n0", "r0n1", ..utparrow)
    node((2.7, 0), [30], name: "r0n2", font: font("small"), ..utpnode, min-size: 0.8)
    connect("r0n1", "r0n2", ..utparrow)
    node((3.2, 0), [NULL], font: font("small"), ..utplabel, anchor: "west")
    node((6.2, 0), [Initial list: `p` points to 10], font: font("small"), ..utplabel, anchor: "west", align: left, text-width: 6)
    node((0, -1.35), [10], name: "r1n0", font: font("small"), ..utpnode, min-size: 0.8)
    node((1.35, -1.35), [15], name: "r1n1", font: font("small"), ..utpnodehot, min-size: 0.8)
    connect("r1n0", "r1n1", ..utparrow)
    node((2.7, -1.35), [20], name: "r1n2", font: font("small"), ..utpnode, min-size: 0.8)
    connect("r1n1", "r1n2", ..utparrow)
    node((4.05, -1.35), [30], name: "r1n3", font: font("small"), ..utpnode, min-size: 0.8)
    connect("r1n2", "r1n3", ..utparrow)
    node((4.55, -1.35), [NULL], font: font("small"), ..utplabel, anchor: "west")
    node((6.2, -1.35), [`n->next = p->next` \
  then `p->next = n`], font: font("small"), ..utplabel, anchor: "west", align: left, text-width: 6)
    node((0, -2.7), [10], name: "r2n0", font: font("small"), ..utpnode, min-size: 0.8)
    node((1.35, -2.7), [15], name: "r2n1", font: font("small"), ..utpnodehot, min-size: 0.8)
    connect("r2n0", "r2n1", ..utparrow)
    node((2.7, -2.7), [30], name: "r2n2", font: font("small"), ..utpnodehot, min-size: 0.8)
    connect("r2n1", "r2n2", ..utparrow)
    node((3.2, -2.7), [NULL], font: font("small"), ..utplabel, anchor: "west")
    node((6.2, -2.7), [`old` points to 20; connect 15 to 30 \
  then `delete old`], font: font("small"), ..utplabel, anchor: "west", align: left, text-width: 6)
  })
]
