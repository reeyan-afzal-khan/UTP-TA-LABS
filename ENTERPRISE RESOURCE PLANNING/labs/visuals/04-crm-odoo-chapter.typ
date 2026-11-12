#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas({
      rectangle((0, -0.55), (6.4, 3.6), draw: mix(muted, 45%), fill: pale-gray, rounded: 2.5mm)
      node((3.2, 3.25), [#strong[Contact list]], ..proccap, text: muted)
      node((3.2, 2.5), [Name and address], ..procquiet, min-width: 5.4, min-height: 0.7)
      node((3.2, 1.65), [Telephone and email], ..procquiet, min-width: 5.4, min-height: 0.7)
      node((3.2, 0.8), [Contact person], ..procquiet, min-width: 5.4, min-height: 0.7)
      node((3.2, 0), [answers #emph[who]], ..procnote, text: muted)
      rectangle((7.6, -0.55), (14.6, 3.6), draw: mix(blue, 45%), fill: mix(pale-blue, 45%), rounded: 2.5mm)
      node((11.1, 3.25), [#strong[CRM]], ..proccap, text: blue)
      for (i, t) in ((0, "Which opportunities are open, and worth how much?"), (1, "Who owns the next action, and by when?"), (2, "What has this customer bought, been promised, complained about?")) {
        let y = 2.5 - i * 0.85
        node((11.1, y), [#t], ..procstep, min-width: 6.4, text-width: 6, min-height: 0.7)
      }
      node((11.1, 0), [answers #emph[what next]], ..procnote, text: blue)
      connect((6.6, 1.5), (7.4, 1.5), ..procflow)
    })
  ]
]
