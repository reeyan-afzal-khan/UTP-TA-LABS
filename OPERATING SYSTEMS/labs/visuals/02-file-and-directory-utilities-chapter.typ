#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas({
      let card = (draw: blue, fill: pale-blue, rounded: 2mm, text-width: 5, min-height: 2, align: center, font: font("small", fill: navy))
      let meta = (..card, draw: orange, fill: pale-orange)
      node((-3, 0), [#strong[CONTENTS] \
    bytes read with `read()` or `fread()` \
    e.g. text, source code, records], ..card)
      node((3, 0), [#strong[METADATA] \
    size, mode, inode, links \
    read with `stat()`], ..meta)
    })
  ]
]
