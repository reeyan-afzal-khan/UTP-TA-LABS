#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas({
      node((0, 0), [S1], name: "s1", ..switch, min-width: 1.5, min-height: 2.4)
      node((7.4, 0), [S2], name: "s2", ..switch, min-width: 1.5, min-height: 2.4)
      connect((0.78, 0.45), (6.6, 0.45), line-width: 1.9925pt, draw: blue)
      connect((0.78, -0.45), (6.6, -0.45), line-width: 1.9925pt, draw: teal)
      node((3.7, 0.72), [member 1 --- G0/0/9], ..costlabel, text: blue)
      node((3.7, -0.72), [member 2 --- G0/0/10], ..costlabel, text: teal)
      node((-1, 0.75), [flow A #text(fill: blue)[$bullet$]], anchor: "east", font: font("script", fill: ink), align: right)
      node((-1, 0.25), [flow B #text(fill: teal)[$bullet$]], anchor: "east", font: font("script", fill: ink), align: right)
      node((-1, -0.25), [flow C #text(fill: blue)[$bullet$]], anchor: "east", font: font("script", fill: ink), align: right)
      node((-1, -0.75), [flow D #text(fill: teal)[$bullet$]], anchor: "east", font: font("script", fill: ink), align: right)
      node((8.3, 0.2), [The hash uses source and destination addresses, so a given pair always takes the same member.], anchor: "west", font: font("script", fill: muted), text-width: 4, align: left)
      node((3.7, -1.5), [Two flows land on each link here. With one flow, one link would sit idle --- which is the usual reason a bandwidth test on a new trunk disappoints.], anchor: "north", font: font("tiny", fill: muted), align: center, text-width: 11)
    })
  ]
]
