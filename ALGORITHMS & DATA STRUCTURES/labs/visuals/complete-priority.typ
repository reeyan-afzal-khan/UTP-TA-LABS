#import "/.shared/typst/utp.typ": *

#utpcompactlabfigure[Higher priority first; equal priorities keep arrival order][
  #labgraphic[
    #canvas(compact: true, {
      node((0, 0), [A/2], font: font("small"), ..utpcell, min-width: 1, min-height: 0.62)
      node((6.35, 0), [A arrives], font: font("small"), ..utplabel, anchor: "west")
      node((0, -0.85), [B/5], font: font("small"), ..utpcell, min-width: 1, min-height: 0.62)
      node((1.1, -0.85), [A/2], font: font("small"), ..utpcell, min-width: 1, min-height: 0.62)
      node((6.35, -0.85), [B shifts A], font: font("small"), ..utplabel, anchor: "west")
      node((0, -1.7), [B/5], font: font("small"), ..utpcell, min-width: 1, min-height: 0.62)
      node((1.1, -1.7), [A/2], font: font("small"), ..utpcell, min-width: 1, min-height: 0.62)
      node((2.2, -1.7), [C/2], font: font("small"), ..utpcell, min-width: 1, min-height: 0.62)
      node((6.35, -1.7), [C stays after A], font: font("small"), ..utplabel, anchor: "west")
      node((0, -2.55), [B/5], font: font("small"), ..utpcell, min-width: 1, min-height: 0.62)
      node((1.1, -2.55), [D/5], font: font("small"), ..utpcell, min-width: 1, min-height: 0.62)
      node((2.2, -2.55), [A/2], font: font("small"), ..utpcell, min-width: 1, min-height: 0.62)
      node((3.3, -2.55), [C/2], font: font("small"), ..utpcell, min-width: 1, min-height: 0.62)
      node((6.35, -2.55), [D stays after B], font: font("small"), ..utplabel, anchor: "west")
      node((0, -3.4), [B/5], font: font("small"), ..utpcell, min-width: 1, min-height: 0.62)
      node((1.1, -3.4), [D/5], font: font("small"), ..utpcell, min-width: 1, min-height: 0.62)
      node((2.2, -3.4), [F/3], font: font("small"), ..utpcell, min-width: 1, min-height: 0.62)
      node((3.3, -3.4), [A/2], font: font("small"), ..utpcell, min-width: 1, min-height: 0.62)
      node((4.4, -3.4), [C/2], font: font("small"), ..utpcell, min-width: 1, min-height: 0.62)
      node((5.5, -3.4), [E/1], font: font("small"), ..utpcell, min-width: 1, min-height: 0.62)
      node((6.35, -3.4), [After E then F arrive], font: font("small"), ..utplabel, anchor: "west")
    })
  ]
]
