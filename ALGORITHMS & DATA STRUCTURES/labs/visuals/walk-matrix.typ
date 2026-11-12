#import "/.shared/typst/utp.typ": *

#utpcompactlabfigure[Build each output cell with the same inner loop][
  #labgraphic[
    #canvas(compact: true, {
      for (x, y, a, b, c, d, hot, expr) in ((0, 0, 58, "–", "–", "–", 0, [$1(7)+2(9)+3(11)=58$]), (5, 0, 58, "64", "–", "–", 1, [$1(8)+2(10)+3(12)=64$]), (0, -2.35, 58, "64", "139", "–", 2, [$4(7)+5(9)+6(11)=139$]), (5, -2.35, 58, "64", "139", "154", 3, [$4(8)+5(10)+6(12)=154$])) {
        draw.scope({
          draw.translate((x, y))
          for (vv, i, xx, yy) in (([#a], 0, 0, 0), ([#b], 1, 0.95, 0), ([#c], 2, 0, -0.68), ([#d], 3, 0.95, -0.68)) {
            let st = none
            if i == hot {
              st = utphot
            } else {
              st = utpcell
            }
            node((xx, yy), [#vv], font: font("small"), ..st, min-width: 0.9, min-height: 0.62)
          }
          node((0.475, -1.2), [#expr], font: font("small"), ..utplabel)
        })
      }
      node((2.975, -4.15), [`i`: row of A #h(1em)`j`: column of B #h(1em)`t`: shared index \
    Reset the sum before computing each cell.], font: font("small"), ..utplabel, align: center)
    })
  ]
]
