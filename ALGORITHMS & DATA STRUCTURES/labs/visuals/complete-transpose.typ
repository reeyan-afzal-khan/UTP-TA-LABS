#import "/.shared/typst/utp.typ": *

#utpcompactlabfigure[Transpose: keep the value, exchange the indexes][
  #labgraphic[
    #canvas(compact: true, {
      for (x, a, b, c, d, ee, f, g, hh, i) in ((0, 1, 2, 3, 4, 5, 6, 7, 8, 9), (6, 1, 4, 7, 2, 5, 8, 3, 6, 9)) {
        for (val, xx, yy) in (([#a], 0, 0), ([#b], 0.85, 0), ([#c], 1.7, 0), ([#d], 0, -0.68), ([#ee], 0.85, -0.68), ([#f], 1.7, -0.68), ([#g], 0, -1.36), ([#hh], 0.85, -1.36), ([#i], 1.7, -1.36)) {
          node((x + xx, yy), [#val], font: font("small"), ..utpcell, min-width: 0.8, min-height: 0.62)
        }
      }
      connect((2.4, -0.68), (5.3, -0.68), ..utparrow)
      node((3.85, -0.25), [`T[j][i] = M[i][j]`], font: font("small"), ..utplabel, align: center)
      node((0.85, 0.65), [M: original], font: font("small"), ..utplabel)
      node((6.85, 0.65), [T: transposed], font: font("small"), ..utplabel)
      node((3.85, -2.2), [M row sums: 6, 15, 24 #h(1em)Diagonal sum: 15 \
    Maximum: 9 #h(1em)M is not symmetric.], font: font("small"), ..utplabel, align: center)
    })
  ]
]
