#import "/.shared/typst/utp.typ": *

#utpcompactlabfigure[Separate fields versus one shared storage area][
  #labgraphic[
    #canvas(compact: true, {
      node((2, 1), [structure: separate members], font: font("small"), ..utplabel)
      node((0, 0), [count], font: font("small"), ..utpcell, min-width: 2)
      node((2.2, 0), [reading], font: font("small"), ..utpcell, min-width: 2)
      node((4.4, 0), [grade], font: font("small"), ..utpcell, min-width: 2)
      node((2, -1.1), [union: use the member most recently written], font: font("small"), ..utplabel)
      node((0, -2), [`u.count = 42` \
    read count: 42], name: "a", font: font("small"), ..utpstep, text-width: 3.4, align: center)
      node((6, -2), [`u.reading = 3.75` \
    read reading: 3.75], name: "b", font: font("small"), ..utpstep, text-width: 3.7, align: center)
      connect("a", "b", ..utparrow)
      node(along("a", "b", t: 50%), [same storage], font: font("small"), ..utplabel, anchor: "south")
    })
  ]
]
