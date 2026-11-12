#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas({
      node((0, 3.1), [toolbar --- new, open, and the #strong[start / stop] buttons], ..hdrm, min-width: 13, min-height: 0.55, anchor: "west", font: font("script", fill: navy))
      node((0, 2.75), [#strong[device palette] \ #v(1.9925pt)
     routers \
     switches \
     end devices \
     connections], ..hdrb, min-width: 3, min-height: 2.9, anchor: "north-west", align: center, font: font("script", fill: navy))
      node((3.1, 2.75), [#strong[canvas] \ #v(2.9888pt)
     drag a device here, then drag a #emph[connection] from the palette \
     and click the two interfaces you want joined], ..hdrpay, min-width: 9.9, min-height: 2.9, anchor: "north-west", align: center, font: font("script"))
      node((3.1, -0.45), [#strong[right-click a device] \ #v(1.9925pt)
      • #strong[CLI] --- open the VRP console \
      • #strong[Settings] --- add an interface card \
      • #strong[Data Capture] --- start Wireshark on one interface], ..hdro, min-width: 6, min-height: 1.55, anchor: "north-west", align: left, font: font("script", fill: navy))
      connect((6.1, -0.5), (6.1, 0.1), line-width: widths.thick, draw: orange, end: tip("Stealth", length: 2mm, line: widths.thick))
      node((9.4, -1.2), [A device must be #strong[started] before its CLI will respond.], font: font("tiny", fill: muted), anchor: "west", text-width: 3.5)
    })
  ]
]
