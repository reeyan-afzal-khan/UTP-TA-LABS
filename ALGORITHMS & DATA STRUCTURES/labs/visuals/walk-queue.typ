#import "/.shared/typst/utp.typ": *

#utpcompactlabfigure[Capacity 5: storage and indexes after each operation][
  #labgraphic[
    #canvas(compact: true, {
      node((0, 0), [10], font: font("small"), ..utpcell, min-width: 0.88, min-height: 0.65)
      node((0, 0.6), [0], font: font("small"), ..utplabel)
      node((0.92, 0), [20], font: font("small"), ..utpcell, min-width: 0.88, min-height: 0.65)
      node((0.92, 0.6), [1], font: font("small"), ..utplabel)
      node((1.84, 0), [30], font: font("small"), ..utpcell, min-width: 0.88, min-height: 0.65)
      node((1.84, 0.6), [2], font: font("small"), ..utplabel)
      node((2.76, 0), [40], font: font("small"), ..utphot, min-width: 0.88, min-height: 0.65)
      node((2.76, 0.6), [3], font: font("small"), ..utplabel)
      node((3.68, 0), [--], font: font("small"), ..utpdim, min-width: 0.88, min-height: 0.65)
      node((3.68, 0.6), [4], font: font("small"), ..utplabel)
      node((4.8, 0), [Enqueue 10,20,30,40 \
    `front=0, rear=4, count=4`], font: font("small"), ..utplabel, anchor: "west", align: left, text-width: 5.2)
      connect((-0.85, -0.35), (-0.85, -0.85), ..utparrow)
      node((0, -1.2), [--], font: font("small"), ..utpdim, min-width: 0.88, min-height: 0.65)
      node((0.92, -1.2), [--], font: font("small"), ..utpdim, min-width: 0.88, min-height: 0.65)
      node((1.84, -1.2), [30], font: font("small"), ..utphot, min-width: 0.88, min-height: 0.65)
      node((2.76, -1.2), [40], font: font("small"), ..utpcell, min-width: 0.88, min-height: 0.65)
      node((3.68, -1.2), [--], font: font("small"), ..utpdim, min-width: 0.88, min-height: 0.65)
      node((4.8, -1.2), [Dequeue twice: return 10, then 20 \
    `front=2, rear=4, count=2`], font: font("small"), ..utplabel, anchor: "west", align: left, text-width: 5.2)
      connect((-0.85, -1.55), (-0.85, -2.05), ..utparrow)
      node((0, -2.4), [--], font: font("small"), ..utpdim, min-width: 0.88, min-height: 0.65)
      node((0.92, -2.4), [--], font: font("small"), ..utpdim, min-width: 0.88, min-height: 0.65)
      node((1.84, -2.4), [30], font: font("small"), ..utpcell, min-width: 0.88, min-height: 0.65)
      node((2.76, -2.4), [40], font: font("small"), ..utpcell, min-width: 0.88, min-height: 0.65)
      node((3.68, -2.4), [50], font: font("small"), ..utphot, min-width: 0.88, min-height: 0.65)
      node((4.8, -2.4), [Enqueue 50 at index 4; rear wraps to 0 \
    `front=2, rear=0, count=3`], font: font("small"), ..utplabel, anchor: "west", align: left, text-width: 5.2)
      connect((-0.85, -2.75), (-0.85, -3.25), ..utparrow)
      node((0, -3.6), [60], font: font("small"), ..utphot, min-width: 0.88, min-height: 0.65)
      node((0.92, -3.6), [--], font: font("small"), ..utpdim, min-width: 0.88, min-height: 0.65)
      node((1.84, -3.6), [30], font: font("small"), ..utpcell, min-width: 0.88, min-height: 0.65)
      node((2.76, -3.6), [40], font: font("small"), ..utpcell, min-width: 0.88, min-height: 0.65)
      node((3.68, -3.6), [50], font: font("small"), ..utpcell, min-width: 0.88, min-height: 0.65)
      node((4.8, -3.6), [Enqueue 60 at index 0 \
    `front=2, rear=1, count=4`], font: font("small"), ..utplabel, anchor: "west", align: left, text-width: 5.2)
      connect((-0.85, -3.95), (-0.85, -4.45), ..utparrow)
      node((0, -4.8), [60], font: font("small"), ..utpcell, min-width: 0.88, min-height: 0.65)
      node((0.92, -4.8), [70], font: font("small"), ..utphot, min-width: 0.88, min-height: 0.65)
      node((1.84, -4.8), [30], font: font("small"), ..utpcell, min-width: 0.88, min-height: 0.65)
      node((2.76, -4.8), [40], font: font("small"), ..utpcell, min-width: 0.88, min-height: 0.65)
      node((3.68, -4.8), [50], font: font("small"), ..utpcell, min-width: 0.88, min-height: 0.65)
      node((4.8, -4.8), [Enqueue 70: full \
    `front=2, rear=2, count=5`], font: font("small"), ..utplabel, anchor: "west", align: left, text-width: 5.2)
    })
  ]
]
