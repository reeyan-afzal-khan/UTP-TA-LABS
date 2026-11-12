#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #box(baseline: 100%, canvas({
      axis(width: 6.777cm, height: 4.8cm, axis-lines: "left", title-style: font("small", weight: "bold", fill: navy) + (yshift: 3.9851pt), title: [Regression losses], xlabel: [Error $(y-hat(y))$], ylabel: [Penalty], label-style: font("script", fill: muted), tick-label-style: font("script", fill: muted), legend-style: (size: font("script").size, draw: none, fill: white, at: (0.5, 0.94), anchor: "north", columns: 3), domain: (-3, 3), samples: 101, xmin: -3, xmax: 3, ymin: 0, ymax: 6.5, ytick: (0, 2, 4, 6),
        addplot(draw: blue, line-width: widths.very-thick, x => calc.pow(x, 2), legend: [squared]),
        addplot(draw: teal, line-width: widths.very-thick, x => calc.abs(x), legend: [absolute]),
        addplot(draw: orange, line-width: widths.very-thick, dash: "dashed", x => (if calc.abs(x) < 1 { 0.5 * calc.pow(x, 2) } else { calc.abs(x) - 0.5 }), legend: [Huber]),
      )
    }))
  ]
]
