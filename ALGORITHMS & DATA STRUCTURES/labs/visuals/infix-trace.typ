#import "/.shared/typst/utp.typ": *

#utpcompactlabfigure[Infix to postfix conversion traced][
  #labgraphic[
    #canvas(compact: true, {
      node((0, 0), [#tabularx(
      columns: (auto, 3.9cm, auto, auto),
      align: (center, left, left, left),
      styles: (navy-bold, none, (fill: blue, font: "Source Code Pro", size: 0.88em), (fill: mix(green, 70%, other: black), font: "Source Code Pro", size: 0.88em)),
      header: ([Read], [Action], [Stack], [Output]),
      [A], [operand: emit], [#hide[x]], [A],
      [\+], [stack empty: push], [\+], [A],
      [B], [operand: emit], [\+], [A B],
      [\*], [higher than +: push], [\+ \*], [A B],
      [C], [operand: emit], [\+ \*], [A B C],
      [\-], [pop \* then +, push -], [\-], [A B C \* +],
      [D], [operand: emit], [\-], [A B C \* + D],
      table.hline(stroke: 0.55pt + rule-color),
      [#emph[end]], [pop remaining], [#hide[x]], [A B C \* + D -],
    )], font: font("small"), anchor: "north-west", inner-sep: 0pt)
    })
  ]
]
