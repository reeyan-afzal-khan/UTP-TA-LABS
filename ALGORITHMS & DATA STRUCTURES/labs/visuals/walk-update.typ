#import "/.shared/typst/utp.typ": *

#utpcompactlabfigure[One address, two field changes][
  #labgraphic[
    #canvas(compact: true, {
      node((0, 0), [#strong[students\[3\]] \
    ID: 1004 #h(1em)Devi \
    age: 22 #h(1em)course: IS], name: "a", font: font("small"), ..utpstep, align: left, text-width: 3.7)
      node((8, 0), [#strong[students\[3\]] \
    ID: 1004 #h(1em)Devi \
    age: 23 #h(1em)course: CS], name: "b", font: font("small"), ..utpstep, align: left, text-width: 3.7, draw: green, fill: pale-teal)
      connect("a", "b", ..utparrow)
      node(along("a", "b", t: 50%), [`selected->age = 23` \
    `selected->course = "CS"`], font: font("small"), ..utplabel, align: center, anchor: "south")
      node((4, -1.3), [`selected = &students[3]` points to the original record \
    The other four records remain unchanged], font: font("small"), ..utplabel, align: center)
    })
  ]
]
