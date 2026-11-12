#import "/.shared/typst/utp.typ": *

#utpcompactlabfigure[DFS: returning from C resumes the suspended call at D][
  #labgraphic[
    #canvas(compact: true, {
      for (i, (states, msg)) in (("A", "enter A"), ("A B", "A calls B"), ("A B D", "B calls D"), ("A B D C", "D calls C"), ("A B D", "C returns; D continues"), ("A B D E", "D calls E")).enumerate() {
        node((0, -0.75 * i), [#mono[#states]], font: font("small"), ..utpcell, min-width: 4.2)
        node((3, -0.75 * i), [#msg], font: font("small"), ..utplabel, anchor: "west")
      }
      node((0, 0.4), [active recursive calls], font: font("small"), ..utplabel, anchor: "south")
      node((2, -4.4), [Output is recorded on entry: A B D C E. \
    C remains visited after its call returns.], font: font("small"), ..utplabel, anchor: "north", align: center)
    })
  ]
]
