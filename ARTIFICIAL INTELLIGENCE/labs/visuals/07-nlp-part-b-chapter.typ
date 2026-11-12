#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas({
      let stage = (..utpbox, text-width: 2.7, min-height: 1.05, font: font("script", fill: navy, family: "mono"))
      let stagelabel = (..utplabel, anchor: "north", align: center, text-width: 2.7)
      node((0, 0), [\@united Flight \
    cancelled AGAIN! \
    http:/\/t.co/x], name: "raw", ..stage)
      node(right-of("raw", 0.6), [user flight \
    cancelled again! \
    url], name: "normalized", ..stage)
      node(right-of("normalized", 0.6), [user flight \
    cancelled url], name: "filtered", ..stage)
      node(right-of("filtered", 0.6), [cancelled:1 flight:1 \
    url:1 user:1], name: "counts", ..stage, fill: pale-teal, draw: green)
      connect("raw.east", "normalized.west", ..utparrow)
      connect("normalized.east", "filtered.west", ..utparrow)
      connect("filtered.east", "counts.west", ..utparrow)
      node((rel: (0, -0.2), to: "raw.south"), [Raw tweet], ..stagelabel)
      node((rel: (0, -0.2), to: "normalized.south"), [Replace handles and \
    URLs, lowercase], ..stagelabel)
      node((rel: (0, -0.2), to: "filtered.south"), [Tokenise, drop \
    stop words], ..stagelabel)
      node((rel: (0, -0.2), to: "counts.south"), [Count terms \
    (the bag of words)], ..stagelabel)
    })
  ]
]
