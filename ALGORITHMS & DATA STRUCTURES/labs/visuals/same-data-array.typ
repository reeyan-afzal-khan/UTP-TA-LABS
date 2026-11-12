#import "/.shared/typst/utp.typ": *

#utpfigure(title: [Array: direct indexed access])[
  #canvas({
    node((-0.15, 0.95), [ARRAY], font: font("normal", weight: "bold", fill: navy))
    for (i, vv) in (12, 25, 18, 30, 22).enumerate() {
      node((0.9 * i, 0), [#vv], name: "a" + str(i), font: font("small"), ..utpcell, min-width: 0.9, min-height: 0.75)
      node((0.9 * i, -0.62), [#i], font: font("small"), ..utplabel)
    }
    node((5.9, 0), [reach item 4 #cxg[$O(1)$] \
   insert in middle #cxr[$O(n)$]], font: font("small"), ..utplabel, align: left, anchor: "west")
  })
]
