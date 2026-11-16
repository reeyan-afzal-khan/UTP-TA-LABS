#import "/.shared/typst/utp.typ": *
#import "study-log-figures.typ": *
#unit("chapters", "26-neural-networks")

= Neural Networks <ch:deep>

#chapterguide[Logistic regression from #chapref(<ch:classification>), gradient descent from #chapref(<ch:learning>), overfitting and validation from #chapref(<ch:training>).][explain what a perceptron could not learn and why hidden layers fix it; run a small network forward by hand; choose an activation for a hidden layer and for an output; choose a loss for a number, a yes/no and one of several classes; compute one backward pass and check it by nudging; and count a network's weights.]

Logistic regression is one dimmer switch: a weighted sum, then a squash. A neural network is many of them wired together, so that the output of one becomes an input to the next. Nothing about the recipe changes. The model is richer, the loss is one you already know, and the optimizer is the same walk downhill. The new part is working out the slope for thousands of weights at once, and it turns out to be the chain rule, applied carefully.

This chapter builds a network and explains how it computes. The next three show how to train one well (#chapref(<ch:deep-training>)), how to build one for images (#chapref(<ch:cnn>)), and how to build one for sequences (#chapref(<ch:sequence>)). The worked numbers here are printed and checked by `all_experiments/book_checks/demo_advanced.py` and `demo_deep_training.py`.

== From a perceptron to a network

The oldest neural network, the #term[perceptron] of the late 1950s, was a single unit: a weighted sum of the inputs, followed by a step that outputs 1 when the sum is above zero and 0 otherwise. It learned by nudging its weights after every mistake, and it could learn any rule that a straight line can draw. That turned out to be its limit. A rule as simple as "exactly one of the two inputs is on" cannot be drawn with one straight line, and no setting of a single unit's weights can learn it. The way out is to stack units in #term[layers].

A #term[layer] computes weighted sums, passes each through a nonlinear #term[activation], and hands the results onward. The layers between the input and the output are #term[hidden layers]. The last layer has a sigmoid or a softmax for classification, and a plain linear output for regression.

#utpfig([A feed-forward network. Each hidden unit computes a weighted sum of the previous layer and passes it through an activation; the output layer produces the prediction.], label: <fig:mlp>)[
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
  passed through an activation)], font: font("script", fill: muted), align: center)
    node((5.2, -1.6), [hidden layer 2], font: font("script", fill: muted))
    node((7.8, -1), [output], font: font("script", fill: muted))
  })
]

#example[
  #strong[One forward pass.] Take inputs $x=(2,1)$, a hidden layer with two units, weights $w_1=(1,-1)$ and $w_2=(0.5,0.5)$, no biases, and the activation ReLU, which keeps a positive sum and replaces a negative one by 0. The two sums are $2-1=1$ and $1+0.5=1.5$, and ReLU leaves both as they are. An output unit with weights $(1,-2)$ then gives $1-3=-2$, which a sigmoid turns into a chance of 0.119. Change $x$ to $(1,2)$: the first sum becomes $-1$, ReLU sets it to 0, and the output becomes $0-3=-3$.
]

=== Why hidden layers matter: XOR

Without nonlinear activations, stacked linear layers collapse into one linear map, however many there are: a weighted sum of weighted sums is still a weighted sum. Here is the problem that stopped the perceptron.

#example[
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
  The hidden units built new features, "first but not second" and "second but not first", and a straight line on those features solves it. Training finds such features instead of having them written by hand.
  ]]]
]

#note[
  Hidden units create new features out of the inputs; later layers combine them into richer decision boundaries. This is why a network needs no feature engineering of the kind in #chapref(<ch:feature-engineering>) for images or sound: the early layers do it.
]

== Activation functions

The activation is the only nonlinear part of a unit, and the choice matters more than its small size suggests. Each one is judged on two things: the values it produces, and its #term[slope], because training sends the error backward through every activation and multiplies it by that slope.

#utpfig([Three activations and their slopes. The sigmoid squeezes every input into 0 to 1, and its slope is never more than 0.25. Tanh squeezes into $-1$ to 1, with a slope of 1 at zero. ReLU keeps positive inputs unchanged, with a slope of exactly 1, and gives 0 for negative ones.], label: <fig:activations>)[
  #canvas({
    groupplot(group-size: (2, 1), horizontal-sep: 1.6cm, ..logaxis, width: 6.9cm, height: 4.6cm, xmin: -4, xmax: 4, xtick: (-4, -2, 0, 2, 4),
      nextgroupplot(title: [the activation], ymin: -1.2, ymax: 2.2, ytick: (-1, 0, 1, 2), legend-style: logaxis.at("legend-style", default: (:)) + (at: (0.03, 0.97), anchor: "north-west"),
        addplot(draw: blue, line-width: widths.thick, domain: (-4, 4), samples: 81, x => 1 / (1 + calc.exp(-x)), legend: [sigmoid]),
        addplot(draw: teal, line-width: widths.thick, domain: (-4, 4), samples: 81, x => calc.tanh(x), legend: [tanh]),
        addplot(draw: orange, line-width: widths.thick, coords: ((-4, 0), (0, 0), (2.2, 2.2)), legend: [ReLU]),
      ),
      nextgroupplot(title: [its slope], ymin: -0.1, ymax: 1.15, ytick: (0, 0.25, 0.5, 0.75, 1),
        addplot(draw: blue, line-width: widths.thick, domain: (-4, 4), samples: 81, x => calc.exp(-x) / calc.pow(1 + calc.exp(-x), 2)),
        addplot(draw: teal, line-width: widths.thick, domain: (-4, 4), samples: 81, x => 1 - calc.pow(calc.tanh(x), 2)),
        addplot(draw: orange, line-width: widths.thick, coords: ((-4, 0), (0, 0), (0, 1), (4, 1))),
      ),
    )
  })
]

#utptable[
  #tabularx(
    columns: (17%, 23%, 15%, 1fr),
    styles: (navy-bold,),
    header: ([Activation], [Formula], [Range], [Where it is used]),
    [Sigmoid], [$1 \/ (1 + e^(-z))$], [0 to 1], [The output unit of a yes/no classifier. Rarely in hidden layers: its slope is at most 0.25.],
    [Tanh], [$(e^z - e^(-z)) \/ (e^z + e^(-z))$], [$-1$ to 1], [Inside recurrent networks (#chapref(<ch:sequence>)). Centred on zero, slope up to 1.],
    [ReLU], [$max(0, z)$], [0 and up], [The default for hidden layers: cheap, and a slope of 1 for every positive input.],
    [Leaky ReLU], [$z$, or $0.01 z$ when $z < 0$], [any], [When many ReLU units go silent: a negative input still passes a small slope back.],
    [ELU], [$z$, or $e^z - 1$ when $z < 0$], [$-1$ and up], [A smooth alternative to leaky ReLU.],
    [Softmax], [$e^(z_k) \/ sum_j e^(z_j)$], [0 to 1, sum 1], [The output layer of a classifier with several classes.],
    [None (linear)], [$z$], [any], [The output unit of a regression.],
  )
]

The slopes explain the column on the right. At $z = -4, -1, 0, 1, 4$ the sigmoid's slope is 0.018, 0.197, 0.25, 0.197 and 0.018; tanh's is 0.001, 0.42, 1, 0.42 and 0.001; ReLU's is 0, 0, 0, 1 and 1. A signal passed backward through ten sigmoid units is multiplied by at most $0.25^(10)$, about one in a million. #chapref(<ch:deep-training>) watches that happen in a real network.

#example[
  #strong[Softmax.] A network that sorts messages into three classes ends with three scores, say 2, 1 and 0.1. Softmax raises $e$ to each score and divides by the total: $e^2 = 7.39$, $e^1 = 2.72$ and $e^(0.1) = 1.11$ add up to 11.21, so the chances are 0.659, 0.242 and 0.099. They are positive, they add up to 1, and the largest score gets the largest chance.
]

== Loss functions

A network is trained to make one number smaller: the #term[loss], computed for each example and averaged over a batch (the average is sometimes called the #term[cost]). The loss is chosen by the kind of output, exactly as for the models of earlier chapters.

#utptable[
  #tabularx(
    columns: (24%, 26%, 1fr),
    styles: (navy-bold,),
    header: ([Predicting], [Loss], [Notes]),
    [A number], [Squared error], [The default. Large misses dominate, so a few outliers can steer the whole fit.],
    [A number, with outliers], [Absolute error, or Huber], [Absolute error grows linearly. Huber is squared near zero and linear far away: a compromise.],
    [Yes or no], [Binary cross-entropy], [With a sigmoid output. In PyTorch, `BCEWithLogitsLoss` takes the raw score and applies the sigmoid itself, which is more accurate.],
    [One of several classes], [Categorical cross-entropy], [With a softmax output. `CrossEntropyLoss` takes the raw scores, as Labs~7 and~9 do.],
  )
]

Cross-entropy charges $-ln p$, where $p$ is the chance the model gave to the true class. A confident right answer is cheap and a confident wrong one is expensive: a chance of 0.9 for the truth costs 0.105, a chance of 0.5 costs 0.693, and a chance of 0.1 costs 2.303. That steep charge for confident mistakes is what pushes a classifier to be careful with its chances.

== How a network is trained

Train by gradient-based optimization (#secref(<sec:gradient-descent>)):

#utpsteps[
  + #term[Forward pass.] Predict a small batch of examples and compute the loss.
  + #term[Backward pass.] Backpropagation applies the chain rule to compute every weight's gradient.
  + #term[Update.] An optimizer moves each weight a small step against its gradient. The learning rate sets the size of the step.
  + #term[Repeat.] One pass through all the training batches is an #term[epoch]. Record the validation score after each one.
]

Each of these steps hides choices, such as which optimizer, how large a step, how the weights start and when to stop, and #chapref(<ch:deep-training>) is about making them. The step that needs explaining first is the backward pass.

=== One backward pass by hand

#term[Backpropagation] sounds grand, and it is the chain rule, used from the output backward so that each weight's slope reuses work already done.

#example[
  A two-weight network: input $x=1$, hidden $h=op("ReLU")(a thin x)$, output $hat(y)=b thin h$, target $y=2$, loss $(y-hat(y))^2$. Start with $a=2$ and $b=0.5$.

  #emph[Forward:] $h=2$, $hat(y)=1$, loss $=1$.

  #emph[Backward:] the error's slope with respect to $hat(y)$ is $-2(y-hat(y))=-2$. Moving back one step, $hat(y)$ changes with $b$ at the rate $h=2$, so $partial L\/ partial b=-2 times 2=-4$. Moving back again, $hat(y)$ changes with $h$ at the rate $b=0.5$ and $h$ with $a$ at the rate $x=1$, so $partial L\/ partial a=-2 times 0.5 times 1=-1$.

  #emph[Check by nudging:] changing $a$ by 0.00001 changes the loss at a rate of $-1.000$, and $b$ at a rate of $-4.000$. The chain rule is right.

  #emph[Step] with a learning rate of 0.1: $a=2.1$ and $b=0.9$. Now $hat(y)=1.89$ and the loss is 0.0121, down from 1.
]

Notice what the slope for $a$ is made of: the slope of the loss, times the weight $b$ it passes through, times the slope of the ReLU, times the input. In a deep network the slope of an early weight is a long product of such factors, one for every layer above it. If the factors are small, as the sigmoid's are, the product fades to nothing; if they are large, it explodes. This product is the reason behind most of #chapref(<ch:deep-training>).

=== Counting weights

Each dense layer has one weight per input per unit, plus one bias per unit. Lab~7’s dense network, for $32 times 32$ colour images, has $(3","072 times 128+128)+(128 times 7+7)=394","247$ weights. Most of them sit in the first layer, which gives every pixel its own weight into every unit, and #chapref(<ch:cnn>) shows how a convolutional network avoids that.

#recipecard([Neural network], [Layers of weighted sums and nonlinear activations, with many thousands of weights.], [Cross-entropy for classes; squared error for numbers.], [Gradient descent on minibatches, usually with Adam. Backpropagation computes the slopes.])

#checklist(title: [Neural Networks - Quick Guide])[
  #tabularx(
    columns: (22%, 1fr),
    valign: (top, horizon),
    styles: (navy-bold,),
    rules: "none",
    [Best when], [Inputs are images, sounds, sequences or text; there is plenty of data; useful features are hard to write by hand.],
    [Start with], [A small network as the reference, beside a classical baseline; then a CNN for grids or a sequence model for series and text.],
    [Preprocessing], [Scale inputs to a small range using training data; encode categories; window a time series; split chronologically when rows overlap in time.],
    [Main controls], [Depth and width, activations, learning rate and optimizer, epochs with early stopping, batch size, dropout.],
    [Watch for], [Memorising the training set, unscaled inputs, run-to-run variation, and a baseline that was never beaten.],
  )
]

#note[
  Labs~7--8 use #lib("PyTorch") tensors, `nn.Sequential`, and explicit training loops. #lib("Keras") instead offers a higher-level `model.fit` interface.
]

#summary[
  - A perceptron is one unit and can learn only what a straight line can draw. Hidden layers with nonlinear activations remove that limit: two ReLU units solve XOR.
  - ReLU is the default activation for hidden layers. A sigmoid belongs on a yes/no output, softmax on a several-class output, nothing on a regression output.
  - The sigmoid's slope is at most 0.25, ReLU's is 1 for positive inputs. The slopes multiply on the way back, which matters in deep networks.
  - Squared error for numbers, cross-entropy for classes. Cross-entropy charges $-ln p$ for the chance given to the truth: 0.105 at 0.9 and 2.303 at 0.1.
  - Backpropagation is the chain rule from the output backward, and a nudge can check any slope.
  - A dense layer has one weight per input per unit, plus a bias per unit; on images, the first layer holds most of them.
]

#questions[
  + Why does a network with two linear layers and no activation function have no more power than one linear layer?
  + For $x=(3,1)$ and the forward-pass network above, what are the hidden values and the output score?
  + Which activation would you put on the output of a network that predicts a house price, one that predicts whether a loan defaults, and one that sorts photos into seven classes?
  + Compute the softmax of the scores 1, 1 and 0, to three decimals.
  + A model gives the true class a chance of 0.2. What does cross-entropy charge? And at 0.8?
  + In the backward pass above, write the slope for $a$ as a product of four factors. What happens to such a product in a network of twenty sigmoid layers?
  + How many weights does a dense layer from 128 inputs to 64 units have?
]
