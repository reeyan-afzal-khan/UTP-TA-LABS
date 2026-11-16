#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas(scale: 0.99, transform-shape: true, {
      let b = (draw: blue, fill: pale-blue, rounded: 2mm, min-width: 2.2, min-height: 1, align: center, font: font("small", fill: navy))
      let arr = (line-width: widths.thick, draw: teal, end: arrow-tip("Stealth", length: 2mm, line: widths.thick))
      node((0, 0), [Acquire \
    #fsize("script")[photo, audio, keyboard]], name: "acq", ..b)
      node(right-of("acq", 0.26), [Normalise \
    #fsize("script")[case, punctuation, tokens]], name: "norm", ..b)
      node(right-of("norm", 0.26), [Represent \
    #fsize("script")[counts, n-grams, vectors]], name: "rep", ..b)
      node(right-of("rep", 0.26), [Model \
    #fsize("script")[classify, translate, search]], name: "model", ..b)
      node(right-of("model", 0.26), [Evaluate \
    #fsize("script")[against references]], name: "eval", ..b)
      connect("acq", "norm", ..arr)
      connect("norm", "rep", ..arr)
      connect("rep", "model", ..arr)
      connect("model", "eval", ..arr)
      connect((-1.3, -0.75), (3.9, -0.75), ..utpbrace, draw: orange)
      node((1.3, -0.95), [Lab~6: OCR, normalisation, measurement], font: font("script", fill: orange), anchor: "north")
      connect((4.1, -0.75), (12, -0.75), ..utpbrace, draw: green)
      node((8.1, -0.95), [Lab~7: bag of words, Naive Bayes, evaluation], font: font("script", fill: green), anchor: "north")
    })
  ]
]
