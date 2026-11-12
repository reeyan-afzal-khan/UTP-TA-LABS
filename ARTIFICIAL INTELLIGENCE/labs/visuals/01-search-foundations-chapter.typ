#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas({
      node((0, 0), [Start \
    state], name: "start", font: font("small"), ..utpbox, min-width: 2.3)
      node((3.6, 0), [#strong[Select from] \
    #strong[frontier]], name: "pick", font: font("small"), ..utpbox, min-width: 2.6, fill: pale-orange, draw: orange, line-width: 0.9963pt)
      node((7.2, 0), [Goal \
    test?], name: "goal", font: font("small"), ..utpbox, min-width: 2.4)
      node((10.7, 0), [Return \
    the path], name: "done", font: font("small"), ..utpbox, min-width: 2.6, fill: pale-teal, draw: green)
      node((7.2, -2.1), [Generate \
    successors], name: "expand", font: font("small"), ..utpbox, min-width: 2.6)
      node((3.6, -2.1), [Not already \
    seen?], name: "vis", font: font("small"), ..utpbox, min-width: 2.6)
      connect("start", "pick", ..utparrow)
      connect("pick", "goal", ..utparrow)
      connect("goal", "done", ..utparrow)
      node(along("goal", "done", t: 50%), [yes], font: font("small"), ..utplabel, text: green, anchor: "south")
      connect("goal", "expand", ..utparrow)
      node(along("goal", "expand", t: 50%), [no], font: font("small"), ..utplabel, text: red, anchor: "west")
      connect("expand", "vis", ..utparrow)
      connect("vis", "pick", ..utparrow)
      node(along("vis", "pick", t: 50%), [keep], font: font("small"), ..utplabel, text: green, anchor: "west")
      node((3.6, 0.72), [#strong[the only line that changes:] FIFO / LIFO / min-cost], font: font("small"), ..utplabel, anchor: "south", align: center, text: orange)
      node((2.15, -2.1), [discard \
    duplicates], font: font("small"), ..utplabel, anchor: "east", align: right)
    })
  ]
]
