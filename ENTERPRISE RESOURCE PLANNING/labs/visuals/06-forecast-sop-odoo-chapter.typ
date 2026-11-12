#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas({
      axis(width: 14.6cm, height: 6.4cm, ymin: 3600, ymax: 7000, ylabel: [pairs], symbolic-x: ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"), xtick: "data", x-tick-label-style: font("script", fill: muted), legend-style: (at: (0.5, 1.19), anchor: "north", columns: 3), ymajorgrids: true, grid-style: (draw: mix(muted, 22%)), plot-style: (mark-size: 1.4944pt,),
        addplot(draw: muted, mark: "*", mark-fill: muted, coords: (("Jan", 4000), ("Feb", 4000), ("Mar", 4500), ("Apr", 5000), ("May", 5000), ("Jun", 5500), ("Jul", 5500), ("Aug", 5750), ("Sep", 6000), ("Oct", 6000), ("Nov", 6200), ("Dec", 6300)), legend: [previous year (as sold)]),
        addplot(draw: blue, dash: "dashed", mark: "square*", mark-fill: pale-blue, coords: (("Jan", 4000), ("Feb", 4000), ("Mar", 4500), ("Apr", 5000), ("May", 5000), ("Jun", 5300), ("Jul", 5500), ("Aug", 5750), ("Sep", 6000), ("Oct", 6000), ("Nov", 5800), ("Dec", 5900)), legend: [base (promotion removed)]),
        addplot(draw: green, mark: "triangle*", mark-fill: pale-teal, coords: (("Jan", 4120), ("Feb", 4120), ("Mar", 4635), ("Apr", 5150), ("May", 5150), ("Jun", 5459), ("Jul", 5665), ("Aug", 5922.5), ("Sep", 6180), ("Oct", 6180), ("Nov", 6474), ("Dec", 6477)), legend: [forecast]),
        {
          connect((2, 6500), (5, 5480), ..proclink)
          node((1, 6600), [June: last year’s spike removed, not replaced], ..procchipwarn, anchor: "west", font: font("tiny"))
          connect((6, 6130), (10, 6430), ..proclink)
          node((3, 6130), [new promotion added here], ..procchip, anchor: "west", font: font("tiny"))
        },
      )
    })
  ]
]
