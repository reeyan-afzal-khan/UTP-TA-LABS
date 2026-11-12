#import "/.shared/typst/utp.typ": *
#import "study-log-figures.typ": *
#unit("chapters", "20-neural-networks")

= Neural Networks, CNNs, and Sequence Models <ch:deep>

#chapterguide[Logistic regression from #chapref(<ch:classification>), gradient descent from #chapref(<ch:learning>), overfitting and validation from #chapref(<ch:training>).][run a small network forward by hand; solve XOR with two ReLU units; compute one backward pass and check it by nudging; count a network’s weights; slide a filter over an image; explain what memory does in a recurrent network; and validate a network against simpler baselines.]

Logistic regression is one dimmer switch: a weighted sum, then a squash. A neural network is many of them wired together, so that the output of one becomes an input to the next. Nothing about the recipe changes. The model is richer, the loss is one you already know, and the optimizer is the same walk downhill. The new part is working out the slope for thousands of weights at once, and it turns out to be the chain rule, applied carefully.

== From logistic regression to a neural network

A #term[layer] computes weighted sums, passes each through a nonlinear #term[activation], and hands the results onward. The last layer has a sigmoid or softmax for classification, and a plain linear output for regression.

#utpfig([A feed-forward network. Each hidden unit computes a weighted sum of the previous layer and passes it through a ReLU; the output layer produces the prediction.], label: <fig:mlp>)[
  #canvas({
    let n = (shape: "circle", draw: blue, fill: pale-blue, min-size: 0.65, inner-sep: 0pt, font: font("script", fill: navy))
    let h-style = (shape: "circle", draw: teal, fill: pale-teal, min-size: 0.65, inner-sep: 0pt, font: font("script", fill: navy))
    let o = (shape: "circle", draw: orange, fill: pale-orange, min-size: 0.65, inner-sep: 0pt, font: font("script", fill: navy))
    let e = (draw: mix(muted, 55%), line-width: widths.thin)
    for (i, y) in ((1, 1.6), (2, 0.8), (3, 0), (4, -0.8)) {
      node((0, y), [$x_(#(i))$], name: "x" + str(i), ..n)
    }
    for (j, y) in ((1, 1.6), (2, 0.8), (3, 0), (4, -0.8), (5, -1.6)) {
      node((2.6, y), [], name: "h" + str(j), ..h-style)
    }
    for (k, y) in ((1, 0.8), (2, 0), (3, -0.8)) {
      node((5.2, y), [], name: "g" + str(k), ..h-style)
    }
    node((7.8, 0), [$hat(y)$], name: "out", ..o)
    for i in range(1, 5) {
      for j in range(1, 6) {
        connect("x" + str(i), "h" + str(j), ..e)
      }
    }
    for j in range(1, 6) {
      for k in range(1, 4) {
        connect("h" + str(j), "g" + str(k), ..e)
      }
    }
    for k in range(1, 4) {
      connect("g" + str(k), "out", ..e)
    }
    node((0, -1.6), [inputs], font: font("script", fill: muted))
    node((2.6, -2.4), [hidden layer 1 \
  (5 weighted sums, each \
  passed through ReLU)], font: font("script", fill: muted), align: center)
    node((5.2, -1.6), [hidden layer 2], font: font("script", fill: muted))
    node((7.8, -1), [output], font: font("script", fill: muted))
  })
]

#term[ReLU], $max(0,z)$, keeps positive inputs and zeroes negative ones. Think of it as a one-way valve. It is a very small amount of nonlinearity, and it is enough.

#workedexample[
  #strong[One forward pass.] Take inputs $x=(2,1)$, a hidden layer with two units, weights $w_1=(1,-1)$ and $w_2=(0.5,0.5)$, no biases, and ReLU. The two sums are $2-1=1$ and $1+0.5=1.5$, and ReLU leaves both as they are. An output unit with weights $(1,-2)$ then gives $1-3=-2$, which a sigmoid turns into a chance of 0.119. Change $x$ to $(1,2)$: the first sum becomes $-1$, ReLU sets it to 0, and the output becomes $0-3=-3$.
]

=== Why hidden layers matter: XOR

Without nonlinear activations, stacked linear layers collapse into one linear map, however many there are. Here is a problem that shows why that matters.

#workedexample[
  XOR is 1 when exactly one of two inputs is 1. The best possible straight-line fit predicts 0.5 for all four cases, so it has learned nothing.

  Now use two ReLU units, $h_1=max(0,x_1-x_2)$ and $h_2=max(0,x_2-x_1)$, and output $h_1+h_2$.

  #v(6pt)
  #align(center)[#fsize("small")[

  #tabularx(
    columns: (auto, auto, auto, auto, auto, auto),
    align: (center, center, center, center, center, center),
    header: ([$x_1$], [$x_2$], [$h_1$], [$h_2$], [Output], [Target]),
    [0], [0], [0], [0], [0], [0],
    [1], [0], [1], [0], [1], [1],
    [0], [1], [0], [1], [1], [1],
    [1], [1], [0], [0], [0], [0],
  )

  #raggedright[
  #v(6pt)
  The hidden units built new features, “first but not second” and “second but not first”, and a straight line on those features solves it. Training finds such features instead of having them written by hand.
  ]]]
]

#intuition[
  Hidden units create nonlinear features; later layers combine them into richer decision boundaries.
]

== How a network is trained

Train by gradient-based optimization (#secref(<sec:gradient-descent>)):

#utpsteps[
  + #term[Forward pass.] Predict a minibatch and compute classification cross-entropy or regression squared loss.
  + #term[Backward pass.] Backpropagation applies the chain rule to compute every weight’s gradient.
  + #term[Update.] An optimizer uses those gradients; the learning rate controls step size. The labs use Adam.
  + #term[Repeat.] One pass through training batches is an #term[epoch]. Record validation performance each epoch.
]

=== One backward pass by hand

#term[Backpropagation] sounds grand, and it is the chain rule, used from the output backward so that each weight’s slope reuses work already done.

#workedexample[
  A two-weight network: input $x=1$, hidden $h=op("ReLU")(a thin x)$, output $hat(y)=b thin h$, target $y=2$, loss $(y-hat(y))^2$. Start with $a=2$ and $b=0.5$.

  #emph[Forward:] $h=2$, $hat(y)=1$, loss $=1$.

  #emph[Backward:] the error’s slope with respect to $hat(y)$ is $-2(y-hat(y))=-2$. Moving back one step, $hat(y)$ changes with $b$ at the rate $h=2$, so $partial L\/ partial b=-2 times 2=-4$. Moving back again, $hat(y)$ changes with $h$ at the rate $b=0.5$ and $h$ with $a$ at the rate $x=1$, so $partial L\/ partial a=-2 times 0.5 times 1=-1$.

  #emph[Check by nudging:] changing $a$ by 0.00001 changes the loss at a rate of $-1.000$, and $b$ at a rate of $-4.000$. The chain rule is right.

  #emph[Step] with a learning rate of 0.1: $a=2.1$ and $b=0.9$. Now $hat(y)=1.89$ and the loss is 0.0121, down from 1.
]

#utptable[
  #tabularx(
    columns: (20%, 18%, 1fr),
    styles: ((weight: "bold", fill: navy, font: "Source Code Pro", size: 0.88em),),
    header: ([Setting], [Typical value], [What raising it does]),
    [learning rate], [0.001--0.01], [Bigger steps: faster at first, unstable if too big],
    [batch size], [32--128], [Smoother gradients, fewer updates per epoch],
    [epochs], [10--50], [More passes; watch validation, not training],
    [hidden units], [32--256], [More capacity; more risk of memorising],
    [dropout], [0.1--0.5], [Randomly silences units during training; a regularizer],
  )
]

Monitor overfitting (#chapref(<ch:training>)). #term[Early stopping] retains the best validation weights; #term[dropout] randomly disables units during training.

#keyidea[
  Extra capacity makes validation and a one-time final test more important, not less.
]

#pitfall[
  Scale inputs before training and save any training-fitted scaling statistics.
]

=== Counting weights

Each dense layer has one weight per input per unit, plus one bias per unit. Lab~7’s dense network, for $32 times 32$ colour images, has $(3(,)072 times 128+128)+(128 times 7+7)=394(,)247$ weights.

#recipecard([Neural network], [Layers of weighted sums and nonlinear activations, with many thousands of weights.], [Cross-entropy for classes; squared error for numbers.], [Gradient descent on minibatches, usually with Adam. Backpropagation computes the slopes.])

== Convolutional networks for images

#analogy[
  Lay a small stencil on a photo and slide it across, recording at each position how well the patch beneath matches the stencil. Wherever the pattern appears, the score is high. A #term[convolutional layer] does exactly this, except that it learns its own stencils, called #term[filters]. Each filter’s scores form a #term[feature map].
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
  The top-left output covers columns 0 to 2: left column $-1 times (0+0+0)$, right column $+1 times (0+0+0)$, so 0. One position to the right, the patch’s right column is $9,9,9$, so the output is 27. The map is bright exactly where the edge lies. A horizontal-edge filter gives all zeros on this image, because it has no horizontal edge.
  ]]
]

#utpfig([One $3 times 3$ filter slides across an $8 times 8$ image of a vertical stroke. With padding, the feature map is $8 times 8$ too. It is positive (teal) where the stroke begins, negative (orange) where it ends, and strongest where the filter’s whole height lies along the stroke. The blue square marks the filter’s current position and the output it produces.], label: <fig:conv-filter>)[
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

Filters share weights across locations: the same few numbers slide everywhere, so a stroke found in one corner is found in every corner, and the layer needs far fewer weights than a dense one. #term[Max pooling] keeps the largest value in each block, which shrinks the map while keeping what fired. Pooling the $4 times 4$ map with rows $1,3,2,0$; $4,2,0,1$; $0,0,5,6$; $1,2,3,0$ into $2 times 2$ blocks gives $4,2$ and $2,6$. A small CNN repeats convolution, ReLU and pooling, then flattens the maps into a dense classifier.

#keepspace(271pt)

#workedexample[
  Lab~7’s CNN for $32 times 32$ colour photos of wood defects, with weights counted per layer. A filter layer has (input channels $times$ filters $times$ $3 times 3$) weights plus one bias per filter, and a colour image has three input channels. The two filter layers need 5,088 weights between them, the first dense layer 131,136, which is why the pooling before it matters.

  #v(6pt)
  #align(center)[#fsize("small")[

  #tabularx(
    columns: (auto, auto, auto),
    align: (left, center, center),
    header: ([Layer], [Output shape], [Weights]),
    [Input], [$3 times 32 times 32$], [],
    [Conv, 16 filters, then pool], [$16 times 16 times 16$], [$3 times 16 times 9+16=448$],
    [Conv, 32 filters, then pool], [$32 times 8 times 8$], [$16 times 32 times 9+32=4(,)640$],
    [Flatten], [2,048], [],
    [Dense, 64 units], [64], [$2(,)048 times 64+64=131(,)136$],
    [Dense, 7 classes], [7], [$64 times 7+7=455$],
    table.hline(stroke: 0.55pt + rule-color),
    [Total], [], [136,679],
  )

  ]]
]

#intuition[
  Training learns filters that reduce loss, rather than relying on hand-specified edges or shapes.
]

== Sequence models: RNNs and LSTMs

#analogy[
  Reading a sentence, you do not start afresh at each word: you carry a running sense of what has happened so far. A #term[recurrent network] carries a #term[hidden state] in the same way, like a reader keeping a small notepad. Each step combines the new input with the notes so far and writes new notes.
]

#workedexample[
  A toy recurrent unit with fixed weights: $"state"=0.5 times "previous state"+"input"$. Inputs $1,2,3$ give states $1, space 2.5, space 4.25$. The final state holds all three inputs, with the oldest counting least.

  That fading is also the weakness. At 0.5 per step, an input’s weight after 8 steps is 0.0039, and after 24 steps it is about 0.00000006. A plain network has trouble remembering yesterday by the time it reaches today.
]

#utpfig([An LSTM unrolled over a 24-hour window. Each step combines the new input with the state passed from the previous step, and the final state supports the prediction.], label: <fig:lstm-unrolled>)[
  #canvas({
    let cell = (draw: teal, fill: pale-teal, rounded: 1.5mm, min-width: 1.5, min-height: 0.9, font: font("script", weight: "bold", fill: navy))
    let inp = (draw: blue, fill: pale-blue, rounded: 1.2mm, min-width: 1.2, min-height: 0.6, font: font("script", fill: navy))
    let outp = (draw: orange, fill: pale-orange, rounded: 1.2mm, min-width: 1.5, min-height: 0.6, font: font("script", fill: navy))
    let arr = (line-width: widths.thick, draw: teal, end: tip("Stealth", length: 1.8mm, line: widths.thick))
    for (t, x) in ((1, 0), (2, 2.4), (3, 4.8), (24, 8.4)) {
      node((x, 0), [LSTM], name: "c" + str(t), ..cell)
      node((x, -1.4), [$x_(#(t))$], name: "i" + str(t), ..inp)
      connect("i" + str(t), "c" + str(t), ..arr)
    }
    node((6.6, 0), [$dots.c$], font: font("Large", fill: muted))
    connect("c1", "c2", ..arr)
    node(along("c1", "c2", t: 50%), [state], font: font("script", fill: muted), anchor: "south")
    connect("c2", "c3", ..arr)
    node(along("c2", "c3", t: 50%), [state], font: font("script", fill: muted), anchor: "south")
    connect("c3", (6.1, 0), ..arr)
    connect((7.1, 0), "c24", ..arr)
    node((8.4, 1.5), [$hat(y)_25$], name: "o", ..outp)
    connect("c24", "o", ..arr)
    node((4.2, -2.3), [24 hourly demand values go in, one step at a time; the same cell (same weights) is used at every step; \
  the final state predicts the next hour], font: font("script", fill: muted), align: center)
  })
]

An #term[LSTM] adds a second notepad, the memory cell, and three learned gates that control it: what to erase, what to write, and what to read out. Because the cell is updated by adding rather than repeatedly shrinking, information can survive many steps. With a keep gate of 0.8 on a note of 10, and a write gate of 0.5 on a new value of 4, the note becomes $0.8 times 10+0.5 times 4=10$. The gates’ values come from small learned networks, so the model decides for itself what is worth keeping.

#workedexample[
  From series to windows. A sequence model does not take a table of features; it takes the last few values and predicts the next. With lookback 3, the series $16,40,32,13,1,1,2,3$ gives five rows:

  #v(6pt)
  #align(center)[#fsize("small")[

  #tabularx(
    columns: (auto, auto),
    align: (center, center),
    header: ([Input window], [Target]),
    [16, 40, 32], [13],
    [40, 32, 13], [1],
    [32, 13, 1], [1],
    [13, 1, 1], [2],
    [1, 1, 2], [3],
  )

  #raggedright[
  #v(6pt)
  $N$ values give $N$ minus lookback windows. Neighboring rows overlap, so a random split would put almost the same row on both sides: split in date order. The simplest forecast, #term[persistence], says the next value equals the last, and on these targets its misses are 19, 12, 0, 1 and 1.
  ]]]
]

Lab~8 predicts the next hour’s electricity demand of 158 customers from the previous 24. Its network has $4 times (32+32 times 32+32+32)=4(,)480$ LSTM weights plus 33 in the output layer, 4,513 in all. On the second half of 2014, persistence misses by 6.12~MWh in an average hour, “same hour yesterday” by 3.69, and the LSTM by 2.57, which is 2.4% of the average hour.

#pitfall[
  Compare against last-value and same-hour-yesterday forecasts. Keep the network only if its validated gain justifies its cost.
]

== Practical notes

- #term[Set the seed] (`torch.manual_seed`) and expect small run-to-run differences anyway; training is stochastic.
- #term[Scale inputs] using training data only; save the fitted scaling.
- #term[Save weights] with `torch.save(model.state_dict(), path)`. Include the architecture and model card needed to reload them.
- #term[Windows OpenMP conflicts:] duplicate runtimes may trigger “OMP: Error \#15”. Check the environment setup before rerunning.
- #term[A CPU suffices] for these labs; larger workloads may benefit from a GPU.
- #term[Keep classical baselines.] Compare neural models with boosting on tables and simpler predictors on images or sequences.

#modelcard[Neural Networks - Quick Guide][
  #tabularx(
    columns: (22%, 1fr),
    valign: (top, horizon),
    styles: (navy-bold,),
    rules: "none",
    [Best when], [Inputs are images, sequences, or text; there is plenty of data; useful features are hard to write by hand.],
    [Start with], [A small dense network as the reference, then a CNN for grids or an LSTM for sequences; always beside a classical baseline.],
    [Preprocessing], [Scale inputs to a small range using training data; window a time series; split chronologically when rows overlap in time.],
    [Main controls], [Learning rate, epochs (with early stopping), batch size, layer sizes, dropout.],
    [Watch for], [Memorising the training set, unscaled inputs, run-to-run variation, and a baseline that was never beaten.],
  )
]

#libnote[
  Labs~7--8 use #lib("PyTorch") tensors, `nn.Sequential`, and explicit training loops. #lib("Keras") instead offers a higher-level `model.fit` interface.
]

== The whole map

An hour’s worth of names is now a map with a few corners, and every method in this book lives somewhere on it. When you meet a new name, do not try to memorize it. Ask which corner it lives in, and which step of the recipe it changes.

#utptable[
  #tabularx(
    columns: (21%, 14%, 1fr, 1fr, 1fr),
    styles: (navy-bold,),
    header: ([Method], [Corner], [Model], [Loss], [Optimizer]),
    [Linear regression], [Number], [Line], [Squared error], [Exact formula],
    [Logistic regression], [Category], [Line, squashed], [Log loss], [Gradient descent],
    [$k$-NN], [Either], [Stored rows], [None], [None],
    [Naive Bayes], [Category], [Prior times clues], [Negative likelihood], [Counting],
    [Decision tree], [Either], [Questions], [Gini or squared error], [Greedy splits],
    [Random forest], [Either], [Many deep trees], [Same, per tree], [Independent greedy fits],
    [Gradient boosting], [Either], [Sum of shallow trees], [Any differentiable loss], [Sequential fits to the gradient],
    [SVM], [Either], [Widest street], [Hinge loss], [Quadratic program],
    [$K$-means], [Groups], [$K$ landmarks], [Squared distance], [Assign, move, repeat],
    [PCA], [Fewer columns], [A few directions], [Spread lost], [Exact matrix routine],
    [Q-learning], [Rewards], [Table of values], [TD error], [Small step per move],
    [Neural network], [Any], [Layers], [Task’s loss], [Backpropagation with gradient descent],
  )
]

#keyidea[
  Machine learning is one recipe with its parts swapped. Pick a formula with numbers you are allowed to change, measure its errors with one number, and find the values that make that number smaller. Then check the result on data it has not seen.
]

#chapterrecap[
  - A network wires dimmer switches together. Without nonlinear activations it collapses to one linear map, and with them it can solve XOR.
  - Backpropagation is the chain rule from the output backward, and a nudge can check any slope.
  - A CNN slides learned filters and shares their weights, so it needs fewer weights to find a pattern anywhere. Pooling shrinks the maps.
  - A recurrent network carries a hidden state. An LSTM adds a memory cell with gates, so that older information can survive.
  - Same workflow, same honesty: compare with simple baselines, split sequences in date order, and report the variation between runs.
]

#quickcheck[
  + Why does a network with two linear layers and no activation function have no more power than one linear layer?
  + For $x=(3,1)$ and the forward-pass network above, what are the hidden values and the output score?
  + How many weights does a dense layer from 128 inputs to 64 units have?
  + What does a convolutional filter share across the image, and why does that reduce the number of weights?
  + What does a max-pooling layer do to an $8 times 8$ map with block size 2, and why is that useful?
  + Why must the rows built from a windowed time series be split chronologically rather than at random?
]
