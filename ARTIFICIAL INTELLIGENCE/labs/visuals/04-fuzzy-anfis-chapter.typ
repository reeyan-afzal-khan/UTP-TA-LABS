#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas({
      axis(name: "crisp", width: 6.6cm, height: 4.2cm, xlabel: [temperature ($""^(compose)$C)], ylabel: [$mu (x)$], title: [Crisp set: “hot”], xmin: 0, xmax: 50, ymin: -0.08, ymax: 1.18, ytick: (0, 0.5, 1), xtick: (0, 10, 20, 30, 40, 50), axis-lines: "left", grid: "major", grid-style: (draw: pale-blue),
        addplot(draw: red, line-width: widths.thick, coords: ((0, 0), (30, 0))),
        addplot(draw: red, line-width: widths.thick, coords: ((30, 1), (50, 1))),
        addplot(draw: red, dash: "dashed", line-width: widths.thin, coords: ((30, 0), (30, 1))),
        addplot(only-marks: true, mark: "*", draw: red, mark-size: 1.3948pt, coords: ((30, 1),)),
        addplot(only-marks: true, mark: "o", draw: red, mark-size: 1.3948pt, coords: ((30, 0),)),
      )
      axis(anchor: "left-of-south-west", width: 6.6cm, height: 4.2cm, xlabel: [temperature ($""^(compose)$C)], ylabel: [$mu (x)$], title: [Fuzzy set: “hot”], xmin: 0, xmax: 50, ymin: -0.08, ymax: 1.18, ytick: (0, 0.5, 1), xtick: (0, 10, 20, 26, 35, 45), axis-lines: "left", grid: "major", grid-style: (draw: pale-blue), at: (rel: (1.15, 0), to: "crisp.right-of-south-east"),
        addplot(draw: green, line-width: widths.thick, coords: ((0, 0), (26, 0), (45, 1), (50, 1))),
        addplot(draw: orange, dash: "dashed", line-width: widths.thin, coords: ((35, 0), (35, 0.47))),
        addplot(draw: orange, dash: "dashed", line-width: widths.thin, coords: ((0, 0.47), (35, 0.47))),
        addplot(only-marks: true, mark: "*", draw: orange, mark-size: 1.594pt, coords: ((35, 0.47),)),
        {
          node((36, 0.36), [$mu (35)=0.47$], font: font("script", fill: orange), anchor: "west")
        },
      )
    })
  ]
]
