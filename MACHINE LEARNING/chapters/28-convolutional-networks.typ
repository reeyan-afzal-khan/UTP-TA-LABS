#import "/.shared/typst/utp.typ": *
#import "/MACHINE LEARNING/course-tools.typ": *
#import "study-log-figures.typ": *
#unit("chapters", "28-convolutional-networks")

#let cnn-demo = "/MACHINE LEARNING/all_experiments/book_checks/demo_cnn.py"

= Convolutional Networks <ch:cnn>

#chapterguide[The dense networks of #chapref(<ch:deep>), trained the way #chapref(<ch:deep-training>) describes\; images as rows of pixel values from #chapref(<ch:dimred>).][explain why a dense layer is a poor fit for images; slide a filter over an image by hand; work out the size of a layer's output from its padding and stride; count a convolutional layer's weights; say what pooling does and how far one unit can see; tell which part of a network makes it indifferent to where a pattern is; augment training photos without changing their labels; and read a difference between two networks against the spread from one random start to another.]

Lab~4 turned each photo of a wood defect into a row of 3,072 numbers and compressed the row. That works, but it throws away the most important fact about a photo: which pixels are next to which. A knot is a knot because of how neighbouring pixels change, and it is the same knot whether it sits in the middle of the photo or near its edge. A #term[convolutional neural network], or CNN, is built around those two facts.

This chapter uses the photos of Labs~4 and~7: 32 by 32 pixels in colour, seven kinds of defect, 9,357 photos to fit and 3,210 to validate, taken from different boards so that no board is on both sides. Lab~7’s test boards are not touched. Every number about these photos comes from `all_experiments/book_checks/demo_cnn.py`, and the small worked examples from `demo_advanced.py`.

== A photo is a grid of numbers

A colour photo is three grids of the same size, one each for red, green and blue: three #term[channels]. Each cell holds a brightness, from 0 to 255 in the file and from 0 to 1 after dividing. A $32 times 32$ colour photo is therefore $3 times 32 times 32 = 3","072$ numbers, and PyTorch stores a batch of them as a tensor of shape (photos, channels, height, width), which is why Lab~7 reorders the axes of the file.

A dense layer treats those 3,072 numbers as an unordered list. Its first layer in Lab~7 gives every pixel its own weight into every one of 128 units: $3","072 times 128 + 128 = 393","344$ weights before anything has been learned about the photos. Worse, a pattern learned at one place teaches the layer nothing about the same pattern elsewhere, because each place has its own weights. Move every validation photo a few pixels to the right and see what that does to Lab~7’s dense network:

#utptable[
  #tabularx(
    columns: (1fr, auto, auto, auto, auto, auto),
    align: (left, center, center, center, center, center),
    styles: (navy-bold,),
    header: ([Validation accuracy when the photos move], [Weights], [0 pixels], [2], [4], [8]),
    [Dense network], [394,247], [0.573], [0.556], [0.441], [0.336],
  )
]

A defect that the network classified correctly is, four pixels later, often a defect it has never seen.

== Convolution: one small filter, slid everywhere

#analogy[
  Lay a small stencil on a photo and slide it across, recording at each position how well the patch beneath matches the stencil. Wherever the pattern appears, the score is high. A #term[convolutional layer] does exactly this, except that it learns its own stencils, called #term[filters]. Each filter's scores form a #term[feature map].
]

#workedexample[
  A $5 times 5$ image, dark on the left and bright on the right, and a $3 times 3$ vertical-edge filter. Each output is the sum of the filter times the patch beneath it.

  #v(6pt)
  #align(center)[

  #canvas({
    for (r, row) in ((0, (0, 0, 0, 9, 9)), (1, (0, 0, 0, 9, 9)), (2, (0, 0, 0, 9, 9)), (3, (0, 0, 0, 9, 9)), (4, (0, 0, 0, 9, 9))) {
      for (c, vv) in row.enumerate() {
        node((c * 0.62, -r * 0.62), [#vv], ..hcell, fill: mix(blue, vv * 1%, other: white))
      }
    }
    for r in range(0, 3) {
      for (c, vv) in ((0, -1), (1, 0), (2, 1)) {
        node((4.1 + c * 0.62, -0.62 - r * 0.62), [$#(vv)$], ..hkey)
      }
    }
    for r in range(0, 3) {
      for (c, vv) in ((0, 0), (1, 27), (2, 27)) {
        node((7.4 + c * 0.62, -0.62 - r * 0.62), [#vv], ..hhot)
      }
    }
    node((1.24, 0.32), [image], ..utplabel, anchor: "south")
    node((4.72, -0.28), [filter], ..utplabel, anchor: "south")
    node((8.02, -0.28), [feature map], ..utplabel, anchor: "south")
    node((3.45, -1.24), [$*$], font: font("Large", fill: muted))
    node((6.75, -1.24), [$=$], font: font("Large", fill: muted))
  })

  #raggedright[
  #v(6pt)
  The top-left output covers columns 0 to 2: left column $-1 times (0+0+0)$, right column $+1 times (0+0+0)$, so 0. One position to the right, the patch's right column is $9,9,9$, so the output is 27. The map is bright exactly where the edge lies. A horizontal-edge filter gives all zeros on this image, because it has no horizontal edge.
  ]]
]

#utpfig([One $3 times 3$ filter slides across an $8 times 8$ image of a vertical stroke. With padding, the feature map is $8 times 8$ too. It is positive (teal) where the stroke begins, negative (orange) where it ends, and strongest where the filter's whole height lies along the stroke. The blue square marks the filter's current position and the output it produces.], label: <fig:conv-filter>)[
  #canvas({
    for i in range(1, 7) {
      for j in (3, 4) {
        rectangle((j * 0.4, -i * 0.4), (rel: (0.4, -0.4), to: (j * 0.4, -i * 0.4)), fill: mix(navy, 70%), draw: none)
      }
    }
    for i in range(0, 8) {
      for j in range(0, 8) {
        rectangle((j * 0.4, -i * 0.4), (rel: (0.4, -0.4), to: (j * 0.4, -i * 0.4)), draw: mix(muted, 50%))
      }
    }
    rectangle((0.4, -0.8), (1.6, -2), line-width: widths.very-thick, draw: blue)
    node((1.6, 0.3), [image $8 times 8$], font: font("small", weight: "bold", fill: navy))
    draw.scope({
      draw.translate((4.3, 0))
      draw.translate((0, -0.85))
      for i in range(0, 3) {
        for j in range(0, 3) {
          rectangle((j * 0.5, -i * 0.5), (rel: (0.5, -0.5), to: (j * 0.5, -i * 0.5)), draw: mix(muted, 60%))
        }
      }
      for i in range(0, 3) {
        node((0.25, -0.25 - i * 0.5), [$-1$], font: font("script"))
        node((0.75, -0.25 - i * 0.5), [$0$], font: font("script"))
        node((1.25, -0.25 - i * 0.5), [$1$], font: font("script"))
      }
      node((0.75, 0.35), [one filter], font: font("small", weight: "bold", fill: navy))
      node((0.75, -2.05), [it responds to \
  vertical edges], font: font("script"), align: center, text: muted)
    })
    draw.scope({
      draw.translate((7.3, 0))
      for (i, n) in ((0, 1), (1, 2), (2, 3), (3, 3), (4, 3), (5, 3), (6, 2), (7, 1)) {
        let shade = int(n * 25)
        for j in (2, 3) {
          rectangle((j * 0.4, -i * 0.4), (rel: (0.4, -0.4), to: (j * 0.4, -i * 0.4)), fill: mix(teal, shade * 1%), draw: none)
        }
        for j in (4, 5) {
          rectangle((j * 0.4, -i * 0.4), (rel: (0.4, -0.4), to: (j * 0.4, -i * 0.4)), fill: mix(orange, shade * 1%), draw: none)
        }
      }
      for i in range(0, 8) {
        for j in range(0, 8) {
          rectangle((j * 0.4, -i * 0.4), (rel: (0.4, -0.4), to: (j * 0.4, -i * 0.4)), draw: mix(muted, 50%))
        }
      }
      rectangle((0.8, -1.2), (rel: (0.4, -0.4), to: (0.8, -1.2)), line-width: widths.very-thick, draw: blue)
      node((1.6, 0.3), [feature map], font: font("small", weight: "bold", fill: navy))
    })
    connect((3.3, -1.6), (4.2, -1.6), line-width: widths.thick, draw: blue, end: tip("Stealth", length: 2mm, line: widths.thick))
    connect((5.9, -1.6), (7.2, -1.6), line-width: widths.thick, draw: blue, end: tip("Stealth", length: 2mm, line: widths.thick))
  })
]

Two properties make convolution fit photos.

/ Weight sharing.: The same nine numbers slide over every position, so a stroke found in one corner is found in every corner, and the layer needs far fewer weights than a dense one.
/ Locality.: Each output depends only on a small patch of neighbours, which is where the evidence for an edge or a texture lies.

On a colour photo a filter covers all three channels at once, so each $3 times 3$ filter has $3 times 3 times 3 = 27$ weights and a bias. Lab~7’s first layer has 16 such filters: $16 times 28 = 448$ weights, against 393,344 for the dense layer it replaces. Each of the 16 filters produces its own feature map, so the layer's output has 16 channels, and the next layer's filters span all 16.

=== Padding and stride

A $3 times 3$ filter fits in a $32 times 32$ image at only 30 positions across, so the output shrinks by two pixels. #term[Padding] adds a border of zeros so that the filter fits everywhere and the output keeps the input's size. #term[Stride] is the step between positions: a stride of 2 visits every other position and halves the output. For an input $n$ pixels wide, a filter $k$ wide, padding $p$ and stride $s$, the output is

$ floor((n + 2p - k) \/ s) + 1 $

pixels wide. With $n = 32$ and $k = 3$: no padding gives 30, a padding of 1 gives 32, and a padding of 1 with a stride of 2 gives 16.

=== Pooling

#term[Max pooling] keeps the largest value in each block, which shrinks the map while keeping what fired. Pooling the $4 times 4$ map with rows $1,3,2,0$; $4,2,0,1$; $0,0,5,6$; $1,2,3,0$ into $2 times 2$ blocks gives $4,2$ and $2,6$. Average pooling keeps each block's mean instead, and min pooling its smallest value, which is rarely useful after a ReLU. A $2 times 2$ pool with a stride of 2 halves the width and the height, from 32 to 16.

=== How far one unit can see

A unit in the first layer sees a $3 times 3$ patch. A unit in the next layer combines several first-layer units, so it sees further, and pooling widens the view again because each of its inputs already summarizes a block. The width of the patch of the original photo that one unit depends on is its #term[receptive field]. For a stack of convolution, pooling, convolution, pooling and convolution, it grows like this:

#utptable[
  #tabularx(
    columns: (1fr, auto, auto, auto, auto, auto),
    align: (left, center, center, center, center, center),
    header: ([After], [conv 3], [pool 2], [conv 3], [pool 2], [conv 3]),
    [Pixels seen across], [3], [4], [8], [10], [18],
  )
]

Early layers see edges and small textures; later layers see whole parts of the photo. This is how a CNN builds large patterns out of small ones.

== A full CNN

A small CNN repeats convolution, ReLU and pooling, then turns its last maps into a dense classifier. Lab~7’s network, with its weights counted layer by layer:

#block(breakable: false, width: 100%)[#workedexample[
  A filter layer has (input channels $times$ filters $times$ $3 times 3$) weights plus one bias per filter. The two filter layers need 5,088 weights between them, the first dense layer 131,136, which is why the pooling before it matters.

  #v(6pt)
  #align(center)[#fsize("small")[

  #tabularx(
    columns: (auto, auto, auto),
    align: (left, center, center),
    header: ([Layer], [Output shape], [Weights]),
    [Input], [$3 times 32 times 32$], [],
    [Conv, 16 filters, then pool], [$16 times 16 times 16$], [$3 times 16 times 9+16=448$],
    [Conv, 32 filters, then pool], [$32 times 8 times 8$], [$16 times 32 times 9+32=4","640$],
    [Flatten], [2,048], [],
    [Dense, 64 units], [64], [$2","048 times 64+64=131","136$],
    [Dense, 7 classes], [7], [$64 times 7+7=455$],
    table.hline(stroke: 0.55pt + rule-color),
    [Total], [], [136,679],
  )

  ]]
]]

With a third as many weights as the dense network, it classifies far better: 0.702 of the validation photos against 0.573. Now repeat the moving test:

#utptable[
  #tabularx(
    columns: (1fr, auto, auto, auto, auto, auto),
    align: (left, center, center, center, center, center),
    styles: (navy-bold,),
    header: ([Validation accuracy when the photos move], [Weights], [0 pixels], [2], [4], [8]),
    [Dense network], [394,247], [0.573], [0.556], [0.441], [0.336],
    [Lab~7’s CNN], [136,679], [0.702], [0.660], [0.588], [0.472],
    [CNN that averages each map], [24,039], [0.600], [0.590], [0.587], [0.556],
  )
]

The second row is a surprise worth understanding. Lab~7’s CNN is better everywhere, but moving the photos eight pixels costs it as much as it costs the dense network: 0.230 against 0.237. Its convolutions do not care where a pattern is, but its flatten layer does. Flattening gives every position of every map its own weight in the dense layer, exactly as the dense network does with pixels, so the classifier at the end still remembers where things were.

The third row removes that memory. After three blocks of filters, it averages each of its 64 maps over the whole photo, which is called #term[global average pooling], and classifies the 64 averages. Where a pattern appeared no longer matters, only how strongly. That network is less accurate on photos that have not moved, because position carried some information, but an eight-pixel move costs it only 0.044. And it has 24,039 weights, a sixth of Lab~7’s.

#keyidea[
  Convolution makes a layer respond the same way to a pattern wherever it is. Whether the whole network ignores where the pattern is depends on its end: flattening keeps positions, and global average pooling throws them away. Choose by asking whether position matters for the label.
]

== Data augmentation

A network learns only the variation its training photos show it. #term[Data augmentation] shows it more: every time a photo is used for training, it is changed a little in a way that cannot change its label. For wood surfaces, a flip left to right or top to bottom is still the same defect, and so is a photo moved a few pixels. Train Lab~7’s CNN twice more, once with random flips and once with random moves of up to four pixels, and compare with the CNN trained on the photos as they are:

#utptable[
  #tabularx(
    columns: (1fr, auto, auto, auto, auto),
    align: (left, center, center, center, center),
    styles: (navy-bold,),
    header: ([Lab~7’s CNN, trained on], [0 pixels], [2], [4], [8]),
    [The photos as they are], [0.702], [0.660], [0.588], [0.472],
    [Randomly flipped photos], [0.715], [0.685], [0.612], [0.455],
    [Randomly moved photos], [0.695], [0.688], [0.674], [0.507],
  )
]

Before reading the rows, look at how much the result moves on its own. The same CNN, trained from three other random starts, reaches 0.708, 0.673 and 0.701 on the unmoved photos: a spread of 0.035 from nothing but luck. Against that spread, flipping did not change the accuracy on unmoved photos, and neither did moving: their 0.715 and 0.695 are inside the luck. What moving did change is the network's behaviour on moved photos. At four pixels it keeps 0.674 instead of 0.588, a gain more than twice the spread. Augmentation taught the network the one thing the moves were about.

#pitfall[
  Augment only with changes that cannot change the label. Flipping a photo of wood is safe; flipping a photo of the digit 6 can make a 9, and flipping a road sign that points left makes one that points right. And judge every gain against the spread between random starts: a difference smaller than that spread is not yet a result.
]

== Borrowing a trained network

The networks in this book learn from a few thousand photos on a laptop. Networks trained by others on millions of photos are freely available, and their early layers have learned edges, textures and shapes that are useful for almost any photo. #term[Transfer learning] reuses them: keep the trained layers, replace the last layer with one for your classes, and train only that last layer, or the last few layers with a small learning rate. With a few hundred labeled photos, this usually beats any network trained from scratch. It needs the trained weights, which are downloaded once from a library such as `torchvision`, and enough memory to run a large network, which is why the labs train their own.

== Seeing what a CNN learned

A CNN can be inspected more directly than most models. Lab~7 draws the 16 filters of its first layer, which are small grids of weights, and the 16 feature maps they produce from one photo: some respond to vertical or horizontal edges, others to colour or dark patches. Later layers are harder to read, because their filters span many channels, but the same idea applies: feed a photo forward and look at which maps respond, and where.

#utptable[
  #tabularx(
    columns: (25%, 1fr),
    styles: (navy-bold,),
    header: ([Part], [What it does]),
    [Convolution], [Slides learned filters over the image; shares weights across positions.],
    [ReLU], [Keeps positive responses, zeroes the rest.],
    [Max pooling], [Halves the size; keeps the strongest response in each block; widens what later layers see.],
    [Flatten], [Turns the maps into one row for dense layers; keeps the position of every response.],
    [Global average pooling], [Averages each map into one number; throws positions away; few weights.],
    [Dropout], [Silences random units during training, as in #chapref(<ch:deep-training>).],
  )
]

#tryit[
  In `demo_cnn.py`, set `CHECK_BOOK_NUMBERS = False`. In `nudges`, change `most=4` to `most=8` and run the script. Does the CNN trained on moved photos now keep its accuracy at an eight-pixel move? What does it cost on photos that have not moved? Compare the change with the spread between random starts before you draw a conclusion.
]

#chapterrecap[
  - A dense layer gives every pixel its own weights: 393,344 in Lab~7’s first layer. A convolutional layer slides a few shared filters: 448 weights for 16 filters.
  - The output width is $floor((n + 2p - k) \/ s) + 1$; padding keeps the size, stride and pooling shrink it.
  - Each layer sees further than the one below: after conv, pool, conv, pool, conv, one unit sees 18 pixels across.
  - Lab~7’s CNN beat the dense network, 0.702 against 0.573, with a third of the weights, yet an eight-pixel move cost both about 0.23. Flattening keeps positions; global average pooling dropped the cost to 0.044.
  - Augmenting with moves kept 0.674 at a four-pixel move instead of 0.588. Flips changed nothing beyond the 0.035 spread between random starts.
  - Transfer learning reuses networks trained on millions of photos and is the usual choice when labeled photos are few.
]

#quickcheck[
  + Why does a dense layer need so many weights for a photo, and what does it fail to learn that a convolutional layer learns for free?
  + Slide the vertical-edge filter of this chapter over a $5 times 5$ image whose left three columns are 9 and right two are 0. What is the top row of the feature map?
  + A layer applies 32 filters of $3 times 3$ to an input with 16 channels. How many weights does it have?
  + What is the output width of a $28$-pixel input after a $5 times 5$ filter with no padding and a stride of 1? After a $2 times 2$ max pool?
  + Lab~7’s CNN uses convolutions, yet moving the photos eight pixels cost it as much as the dense network. Why, and what change fixed it?
  + Name an augmentation that is safe for photos of wood and unsafe for photos of handwritten digits.
  + Two CNNs score 0.715 and 0.702 on the same validation photos. Can you say that one is better? What would you need to know?
]
