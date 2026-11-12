#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas({
      node((0, 0), [R2], name: "c", ..router)
      node((7, 0), [R1], name: "s", ..server)
      node(below-of("c", 0.1), [client 10.0.12.2], ..netlabel)
      node(below-of("s", 0.1), [server 10.0.12.1], ..netlabel)
      connect((rel: (0.55, 0.45), to: "c"), (rel: (-0.9, 0.45), to: "s"), ..flowarrow, draw: teal, start: tip("to", line: 0.4pt), end: tip("to", line: 0.4pt))
      node(along((rel: (0.55, 0.45), to: "c"), (rel: (-0.9, 0.45), to: "s"), t: 50%), [control --- TCP port 21], ..netlabel, text: teal, anchor: "south")
      connect((rel: (0.55, -0.45), to: "c"), (rel: (-0.9, -0.45), to: "s"), ..flowarrow, draw: orange, dash: "dashed", start: tip("to", line: 0.4pt), end: tip("to", line: 0.4pt))
      node(along((rel: (0.55, -0.45), to: "c"), (rel: (-0.9, -0.45), to: "s"), t: 50%), [data --- TCP port 20, one per transfer], ..netlabel, text: orange, anchor: "north")
      node((-0.4, -1.6), [#strong[Control] carries `USER`, `PASS`, `dir`, `get`, `bye` --- and every reply code.], anchor: "west", font: font("script", fill: muted), text-width: 5.2, align: left)
      node((5.4, -1.6), [#strong[Data] carries the file bytes and the directory listing. It opens and closes around each command.], anchor: "west", font: font("script", fill: muted), text-width: 5.2, align: left)
    })
  ]
]
