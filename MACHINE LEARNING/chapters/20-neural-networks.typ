#import "/.shared/typst/utp.typ": *
#unit("chapters", "20-neural-networks")


#heading(level: 1)[Neural Networks, CNNs, and Sequence Models]
 <ch:deep>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Logistic regression from #ref(label("ch:classification"), supplement: [Chapter]), gradient descent from #ref(label("ch:learning"), supplement: [Chapter]), overfitting and validation from #ref(label("ch:training"), supplement: [Chapter]).

*By the end, you can:* run a small network forward by hand; solve XOR with two ReLU units; compute one backward pass and check it by nudging; count a network's weights; slide a filter over an image; explain what memory does in a recurrent network; and validate a network against simpler baselines.]

Logistic regression is one dimmer switch: a weighted sum, then a squash. A neural network is many of them wired together, so that the output of one becomes an input to the next. Nothing about the recipe changes. The model is richer, the loss is one you already know, and the optimizer is the same walk downhill. The new part is working out the slope for thousands of weights at once, and it turns out to be the chain rule, applied carefully.


#heading(level: 2)[From logistic regression to a neural network]


A #strong[layer] computes weighted sums, passes each through a nonlinear #strong[activation], and hands the results onward. The last layer has a sigmoid or softmax for classification, and a plain linear output for regression.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/MACHINE LEARNING/figures/diagrams/9d7c7ce97783783e.svg")], caption: [A feed-forward network. Each hidden unit computes a weighted sum of the previous layer and passes it through a ReLU; the output layer produces the prediction.]) <fig:mlp>

#strong[ReLU], $max \( 0 \, z \)$, keeps positive inputs and zeroes negative ones. Think of it as a one-way valve. It is a very small amount of nonlinearity, and it is enough.

#callout("workedexample", title: [Worked example])[#strong[One forward pass.] Take inputs $x = \( 2 \, 1 \)$, a hidden layer with two units, weights $w_1 = \( 1 \, - 1 \)$ and $w_2 = \( 0.5 \, 0.5 \)$, no biases, and ReLU. The two sums are $2 - 1 = 1$ and $1 + 0.5 = 1.5$, and ReLU leaves both as they are. An output unit with weights $\( 1 \, - 2 \)$ then gives $1 - 3 = - 2$, which a sigmoid turns into a chance of 0.119. Change $x$ to $\( 1 \, 2 \)$: the first sum becomes $- 1$, ReLU sets it to 0, and the output becomes $0 - 3 = - 3$.]


#heading(level: 3)[Why hidden layers matter: XOR]


Without nonlinear activations, stacked linear layers collapse into one linear map, however many there are. Here is a problem that shows why that matters.

#callout("workedexample", title: [Worked example])[XOR is 1 when exactly one of two inputs is 1. The best possible straight-line fit predicts 0.5 for all four cases, so it has learned nothing.

Now use two ReLU units, $h_1 = max \( 0 \, x_1 - x_2 \)$ and $h_2 = max \( 0 \, x_2 - x_1 \)$, and output $h_1 + h_2$.

#figure(
  align(center)[#table(
    columns: 6,
    align: (center,center,center,center,center,center,),
    table.header([$x_1$], [$x_2$], [$h_1$], [$h_2$], [Output], [Target],),
    table.hline(),
    [0], [0], [0], [0], [0], [0],
    [1], [0], [1], [0], [1], [1],
    [0], [1], [0], [1], [1], [1],
    [1], [1], [0], [0], [0], [0],
  )]
  , kind: table
  )

The hidden units built new features, "first but not second" and "second but not first", and a straight line on those features solves it. Training finds such features instead of having them written by hand.]

#callout("intuition", title: [Plain idea])[Hidden units create nonlinear features; later layers combine them into richer decision boundaries.]


#heading(level: 2)[How a network is trained]


Train by gradient-based optimization (#ref(label("sec:gradient-descent"), supplement: [Section])):

+ #strong[Forward pass.] Predict a minibatch and compute classification cross-entropy or regression squared loss.

+ #strong[Backward pass.] Backpropagation applies the chain rule to compute every weight's gradient.

+ #strong[Update.] An optimizer uses those gradients; the learning rate controls step size. The labs use Adam.

+ #strong[Repeat.] One pass through training batches is an #strong[epoch]. Record validation performance each epoch.


#heading(level: 3)[One backward pass by hand]


#strong[Backpropagation] sounds grand, and it is the chain rule, used from the output backward so that each weight's slope reuses work already done.

#callout("workedexample", title: [Worked example])[A two-weight network: input $x = 1$, hidden $h = "ReLU" \( a thin x \)$, output $hat(y) = b thin h$, target $y = 2$, loss $\( y - hat(y) \)^2$. Start with $a = 2$ and $b = 0.5$.

#emph[Forward:] $h = 2$, $hat(y) = 1$, loss $= 1$.

#emph[Backward:] the error's slope with respect to $hat(y)$ is $- 2 \( y - hat(y) \) = - 2$. Moving back one step, $hat(y)$ changes with $b$ at the rate $h = 2$, so $partial L \/ partial b = - 2 times 2 = - 4$. Moving back again, $hat(y)$ changes with $h$ at the rate $b = 0.5$ and $h$ with $a$ at the rate $x = 1$, so $partial L \/ partial a = - 2 times 0.5 times 1 = - 1$.

#emph[Check by nudging:] changing $a$ by 0.00001 changes the loss at a rate of $- 1.000$, and $b$ at a rate of $- 4.000$. The chain rule is right.

#emph[Step] with a learning rate of 0.1: $a = 2.1$ and $b = 0.9$. Now $hat(y) = 1.89$ and the loss is 0.0121, down from 1.]

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Setting], [Typical value], [What raising it does],),
    table.hline(),
    [learning rate], [0.001--0.01], [Bigger steps: faster at first, unstable if too big],
    [batch size], [32--128], [Smoother gradients, fewer updates per epoch],
    [epochs], [10--50], [More passes; watch validation, not training],
    [hidden units], [32--256], [More capacity; more risk of memorising],
    [dropout], [0.1--0.5], [Randomly silences units during training; a regularizer],
  )]
  , kind: table
  )

Monitor overfitting (#ref(label("ch:training"), supplement: [Chapter])). #strong[Early stopping] retains the best validation weights; #strong[dropout] randomly disables units during training.

#callout("keyidea", title: [Key idea])[Extra capacity makes validation and a one-time final test more important, not less.]

#callout("pitfall", title: [Common mistake])[Scale inputs before training and save any training-fitted scaling statistics.]


#heading(level: 3)[Counting weights]


Each dense layer has one weight per input per unit, plus one bias per unit. Lab~7's dense network, for $32 times 32$ colour images, has $\( 3 \, 072 times 128 + 128 \) + \( 128 times 7 + 7 \) = 394 \, 247$ weights.

#callout("modelcard", title: [The recipe: Neural network])[*1. Model* Layers of weighted sums and nonlinear activations, with many thousands of weights.

*2. Loss* Cross-entropy for classes; squared error for numbers.

*3. Optimizer* Gradient descent on minibatches, usually with Adam. Backpropagation computes the slopes.]


#heading(level: 2)[Convolutional networks for images]


#callout("analogy", title: [Analogy])[Lay a small stencil on a photo and slide it across, recording at each position how well the patch beneath matches the stencil. Wherever the pattern appears, the score is high. A #strong[convolutional layer] does exactly this, except that it learns its own stencils, called #strong[filters]. Each filter's scores form a #strong[feature map].]

#callout("workedexample", title: [Worked example])[A $5 times 5$ image, dark on the left and bright on the right, and a $3 times 3$ vertical-edge filter. Each output is the sum of the filter times the patch beneath it.

#diagram-image("/MACHINE LEARNING/figures/diagrams/ab7cd7aed8a62816.svg")

The top-left output covers columns 0 to 2: left column $- 1 times \( 0 + 0 + 0 \)$, right column $+ 1 times \( 0 + 0 + 0 \)$, so 0. One position to the right, the patch's right column is $9 \, 9 \, 9$, so the output is 27. The map is bright exactly where the edge lies. A horizontal-edge filter gives all zeros on this image, because it has no horizontal edge.]

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/MACHINE LEARNING/figures/diagrams/475d917ec1575a05.svg")], caption: [One $3 times 3$ filter slides across an $8 times 8$ image of a vertical stroke. With padding, the feature map is $8 times 8$ too. It is positive (teal) where the stroke begins, negative (orange) where it ends, and strongest where the filter's whole height lies along the stroke. The blue square marks the filter's current position and the output it produces.]) <fig:conv-filter>

Filters share weights across locations: the same few numbers slide everywhere, so a stroke found in one corner is found in every corner, and the layer needs far fewer weights than a dense one. #strong[Max pooling] keeps the largest value in each block, which shrinks the map while keeping what fired. Pooling the $4 times 4$ map with rows $1 \, 3 \, 2 \, 0$; $4 \, 2 \, 0 \, 1$; $0 \, 0 \, 5 \, 6$; $1 \, 2 \, 3 \, 0$ into $2 times 2$ blocks gives $4 \, 2$ and $2 \, 6$. A small CNN repeats convolution, ReLU and pooling, then flattens the maps into a dense classifier.

#callout("workedexample", title: [Worked example])[Lab~7's CNN for $32 times 32$ colour photos of wood defects, with weights counted per layer. A filter layer has (input channels $times$ filters $times$ $3 times 3$) weights plus one bias per filter, and a colour image has three input channels. The two filter layers need 5,088 weights between them, the first dense layer 131,136, which is why the pooling before it matters.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,center,center,),
    table.header([Layer], [Output shape], [Weights],),
    table.hline(),
    [Input], [$3 times 32 times 32$], [],
    [Conv, 16 filters, then pool], [$16 times 16 times 16$], [$3 times 16 times 9 + 16 = 448$],
    [Conv, 32 filters, then pool], [$32 times 8 times 8$], [$16 times 32 times 9 + 32 = 4 \, 640$],
    [Flatten], [2,048], [],
    [Dense, 64 units], [64], [$2 \, 048 times 64 + 64 = 131 \, 136$],
    [Dense, 7 classes], [7], [$64 times 7 + 7 = 455$],
    [Total], [], [136,679],
  )]
  , kind: table
  )]

#callout("intuition", title: [Plain idea])[Training learns filters that reduce loss, rather than relying on hand-specified edges or shapes.]


#heading(level: 2)[Sequence models: RNNs and LSTMs]


#callout("analogy", title: [Analogy])[Reading a sentence, you do not start afresh at each word: you carry a running sense of what has happened so far. A #strong[recurrent network] carries a #strong[hidden state] in the same way, like a reader keeping a small notepad. Each step combines the new input with the notes so far and writes new notes.]

#callout("workedexample", title: [Worked example])[A toy recurrent unit with fixed weights: $upright("state") = 0.5 times upright("previous state") + upright("input")$. Inputs $1 \, 2 \, 3$ give states $1 \, med 2.5 \, med 4.25$. The final state holds all three inputs, with the oldest counting least.

That fading is also the weakness. At 0.5 per step, an input's weight after 8 steps is 0.0039, and after 24 steps it is about 0.00000006. A plain network has trouble remembering yesterday by the time it reaches today.]

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/MACHINE LEARNING/figures/diagrams/9910d6acc597e0ed.svg")], caption: [An LSTM unrolled over a 24-hour window. Each step combines the new input with the state passed from the previous step, and the final state supports the prediction.]) <fig:lstm-unrolled>

An #strong[LSTM] adds a second notepad, the memory cell, and three learned gates that control it: what to erase, what to write, and what to read out. Because the cell is updated by adding rather than repeatedly shrinking, information can survive many steps. With a keep gate of 0.8 on a note of 10, and a write gate of 0.5 on a new value of 4, the note becomes $0.8 times 10 + 0.5 times 4 = 10$. The gates' values come from small learned networks, so the model decides for itself what is worth keeping.

#callout("workedexample", title: [Worked example])[From series to windows. A sequence model does not take a table of features; it takes the last few values and predicts the next. With lookback 3, the series $16 \, 40 \, 32 \, 13 \, 1 \, 1 \, 2 \, 3$ gives five rows:

#figure(
  align(center)[#table(
    columns: 2,
    align: (center,center,),
    table.header([Input window], [Target],),
    table.hline(),
    [16, 40, 32], [13],
    [40, 32, 13], [1],
    [32, 13, 1], [1],
    [13, 1, 1], [2],
    [1, 1, 2], [3],
  )]
  , kind: table
  )

$N$ values give $N$ minus lookback windows. Neighboring rows overlap, so a random split would put almost the same row on both sides: split in date order. The simplest forecast, #strong[persistence], says the next value equals the last, and on these targets its misses are 19, 12, 0, 1 and 1.]

Lab~8 predicts the next hour's electricity demand of 158 customers from the previous 24. Its network has $4 times \( 32 + 32 times 32 + 32 + 32 \) = 4 \, 480$ LSTM weights plus 33 in the output layer, 4,513 in all. On the second half of 2014, persistence misses by 6.12~MWh in an average hour, "same hour yesterday" by 3.69, and the LSTM by 2.57, which is 2.4% of the average hour.

#callout("pitfall", title: [Common mistake])[Compare against last-value and same-hour-yesterday forecasts. Keep the network only if its validated gain justifies its cost.]


#heading(level: 2)[Practical notes]


- #strong[Set the seed] (`torch.manual_seed`) and expect small run-to-run differences anyway; training is stochastic.

- #strong[Scale inputs] using training data only; save the fitted scaling.

- #strong[Save weights] with `torch.save(model.state_dict(), path)`. Include the architecture and model card needed to reload them.

- #strong[Windows OpenMP conflicts:] duplicate runtimes may trigger "OMP: Error \#15". Check the environment setup before rerunning.

- #strong[A CPU suffices] for these labs; larger workloads may benefit from a GPU.

- #strong[Keep classical baselines.] Compare neural models with boosting on tables and simpler predictors on images or sequences.

#callout("modelcard", title: [Neural Networks - Quick Guide])[#block[
ll Best when & Inputs are images, sequences, or text; there is plenty of data; useful features are hard to write by hand. Start with & A small dense network as the reference, then a CNN for grids or an LSTM for sequences; always beside a classical baseline. Preprocessing & Scale inputs to a small range using training data; window a time series; split chronologically when rows overlap in time. Main controls & Learning rate, epochs (with early stopping), batch size, layer sizes, dropout. Watch for & Memorising the training set, unscaled inputs, run-to-run variation, and a baseline that was never beaten.

]]

#callout("libnote", title: [Reference note])[Labs~7--8 use `PyTorch` tensors, `nn.Sequential`, and explicit training loops. `Keras` instead offers a higher-level `model.fit` interface.]


#heading(level: 2)[The whole map]


An hour's worth of names is now a map with a few corners, and every method in this book lives somewhere on it. When you meet a new name, do not try to memorize it. Ask which corner it lives in, and which step of the recipe it changes.

#figure(
  align(center)[#table(
    columns: 5,
    align: (left,left,left,left,left,),
    table.header([Method], [Corner], [Model], [Loss], [Optimizer],),
    table.hline(),
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
    [Neural network], [Any], [Layers], [Task's loss], [Backpropagation with gradient descent],
  )]
  , kind: table
  )

#callout("keyidea", title: [Key idea])[Machine learning is one recipe with its parts swapped. Pick a formula with numbers you are allowed to change, measure its errors with one number, and find the values that make that number smaller. Then check the result on data it has not seen.]

#callout("chapterrecap", title: [Chapter recap])[- A network wires dimmer switches together. Without nonlinear activations it collapses to one linear map, and with them it can solve XOR.

- Backpropagation is the chain rule from the output backward, and a nudge can check any slope.

- A CNN slides learned filters and shares their weights, so it needs fewer weights to find a pattern anywhere. Pooling shrinks the maps.

- A recurrent network carries a hidden state. An LSTM adds a memory cell with gates, so that older information can survive.

- Same workflow, same honesty: compare with simple baselines, split sequences in date order, and report the variation between runs.]

#callout("quickcheck", title: [Check your understanding])[+ Why does a network with two linear layers and no activation function have no more power than one linear layer?

+ For $x = \( 3 \, 1 \)$ and the forward-pass network above, what are the hidden values and the output score?

+ How many weights does a dense layer from 128 inputs to 64 units have?

+ What does a convolutional filter share across the image, and why does that reduce the number of weights?

+ What does a max-pooling layer do to an $8 times 8$ map with block size 2, and why is that useful?

+ Why must the rows built from a windowed time series be split chronologically rather than at random?]
