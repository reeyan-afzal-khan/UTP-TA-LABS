#import "/.shared/typst/utp.typ": *

#utpcompactlabfigure[At a matching node: return the subtree that replaces it][
  #labgraphic[
    #canvas(compact: true, {
      node((5, 0), [`value == root->data`], name: "q", font: font("small"), ..utpstep, align: center)
      node((1, -2), [#strong[Zero or one child] \
    Choose the existing child (or null). \
    Delete root; return child.], name: "a", font: font("small"), ..utpstep, align: left, text-width: 4.8)
      node((9, -2), [#strong[Two children] \
    Find leftmost node of right subtree. \
    Copy its data; delete it below. \
    Return the original root.], name: "b", font: font("small"), ..utpstep, align: left, text-width: 5.3)
      connect("q", "a", ..utparrow)
      node(along("q", "a", t: 50%), [left is null \
    or right is null], font: font("small"), ..utplabel, align: center, anchor: "south-east")
      connect("q", "b", ..utparrow)
      node(along("q", "b", t: 50%), [both children exist], font: font("small"), ..utplabel, anchor: "south-west")
      node((5, -3.5), [The caller assigns the returned pointer to its child link (or to the tree root).], font: font("small"), ..utplabel, align: center)
    })
  ]
]
