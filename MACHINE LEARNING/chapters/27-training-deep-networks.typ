#import "/.shared/typst/utp.typ": *
#import "/MACHINE LEARNING/course-tools.typ": *
#import "study-log-figures.typ": *
#unit("chapters", "27-training-deep-networks")

#let training-demo = "/MACHINE LEARNING/all_experiments/book_checks/demo_deep_training.py"

= Training Deep Networks <ch:deep-training>

#chapterguide[The network, activations, losses and backpropagation of #chapref(<ch:deep>)\; gradient descent from #chapref(<ch:learning>)\; overfitting, validation and the ROC AUC from #chapref(<ch:evaluation>) and #chapref(<ch:training>).][explain why gradients vanish or explode in a deep stack and what ReLU and batch normalization do about it; say why weights must start random; tell SGD, momentum, RMSprop and Adam apart by their update rules and their training curves; read a learning rate from a training curve; hold back a large network with early stopping, dropout and weight decay; and judge a network against a simpler model on the same test rows.]

Two people follow the same recipe in two kitchens and serve two different dishes. The recipe was the same; the oven temperature, the timing and the moment each one took the dish out were not. A neural network is the same. The architecture of #chapref(<ch:deep>) fixes what the network can compute. Whether it ever learns to compute it depends on choices that are not part of the architecture at all: how its weights start, how its steps are taken, how big they are, and when training stops.

This chapter makes each choice on one real table: 7,043 customers of a telephone company and whether they left, the Telco table of Labs~1 and~2. After encoding there are 45 columns. The customers are split into 4,225 for training, 1,409 for validation and 1,409 for the test, and 26.5% of them left. Every number comes from `all_experiments/book_checks/demo_deep_training.py`. Network results move a little from one computer to another, so the script's checks allow for small differences.

#codefrom(training-demo, "def fit(model, optimizer, epochs, batch_size=64, seed=0, keep_best=False):", "return pd.DataFrame(history")

The function above is the whole training loop of this chapter. Everything that follows changes one of its ingredients: the model, the optimizer, the learning rate, or the brake.

== When the gradient fades

#chapref(<ch:deep>) ended on a warning. The slope of an early weight is a product with one factor per layer above it, and the sigmoid's slope is never more than 0.25. Build a network with ten hidden layers of 32 units and look at the gradient each layer's weights receive on the first pass, before any training:

#utpfig([The size of each layer's gradient at the start of training, from the first hidden layer (left) to the output layer (right), in a network of ten hidden layers. The scale is in powers of ten. With sigmoids the output layer's gradient is 374 million times the first layer's. With ReLU the gap is a factor of 570, and with batch normalization it is 5.], label: <fig:vanishing>)[
  #canvas({
    axis(width: 12cm, height: 5.4cm, ..logaxis, xlabel: [layer, from the first hidden layer to the output], ylabel: [gradient size], xmin: 0.5, xmax: 11.5, ymin: -9.2, ymax: 0.4, xtick: (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11), xticklabels: ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [out]), ytick: (-8, -6, -4, -2, 0), yticklabels: ([$10^(-8)$], [$10^(-6)$], [$10^(-4)$], [$10^(-2)$], [1]), legend-style: logaxis.at("legend-style", default: (:)) + (at: (0.97, 0.03), anchor: "south-east"),
      addplot(draw: blue, mark: "*", mark-size: 1.7pt, line-width: widths.thick, coords: ((1, -8.76), (2, -7.9), (3, -6.97), (4, -6.1), (5, -5.24), (6, -4.38), (7, -3.6), (8, -2.73), (9, -1.94), (10, -0.98), (11, -0.18)), legend: [sigmoid]),
      addplot(draw: orange, mark: "*", mark-size: 1.7pt, line-width: widths.thick, coords: ((1, -3.85), (2, -3.91), (3, -3.62), (4, -3.29), (5, -2.99), (6, -2.79), (7, -2.46), (8, -2.21), (9, -1.81), (10, -1.35), (11, -1.09)), legend: [ReLU]),
      addplot(draw: teal, mark: "*", mark-size: 1.7pt, line-width: widths.thick, coords: ((1, -0.86), (2, -1.0), (3, -1.0), (4, -0.99), (5, -0.96), (6, -1.02), (7, -1.06), (8, -1.1), (9, -1.16), (10, -1.15), (11, -0.16)), legend: [sigmoid with batch norm]),
    )
  })
]

With sigmoids, each layer back receives a gradient about 7.2 times smaller than the one above it, and the first layer's is $1.8 times 10^(-9)$. Its weights will hardly move, however long training runs. This is the #term[vanishing gradient] problem, and it is not a curiosity. Train the sigmoid network for 20 epochs and its training loss stays at 0.579: exactly the loss of predicting the share of leavers, 26.5%, for every customer. The network has learned the average and nothing else. Its validation AUC climbs to 0.840 by epoch 20, a sign that some ordering is starting to form, but the loss has not moved.

The ReLU network's gradients shrink too, but only by a factor of 1.9 per layer, so the first layer's is 570 times smaller than the last's instead of 374 million times. It learns: its training loss falls to 0.386 in 20 epochs.

#utptable[
  #tabularx(
    columns: (1fr, auto, auto, auto, auto),
    align: (left, center, center, center, center),
    styles: (navy-bold,),
    header: ([Ten hidden layers of 32 units], [Training loss, epoch 1], [Epoch 20], [Validation AUC, epoch 1], [Epoch 20]),
    [Sigmoid], [0.579], [0.579], [0.482], [0.840],
    [ReLU], [0.485], [0.386], [0.835], [0.846],
    [Sigmoid with batch normalization], [0.479], [0.407], [0.847], [0.837],
  )
]

The third row is the second cure. #term[Batch normalization] rescales every unit's sums, batch by batch, to a mean of 0 and a standard deviation of 1 before the activation, and then lets the network learn a scale and a shift of its own. The sums stay in the range where the sigmoid's slope is largest, so the gradient no longer fades: every layer's is about $10^(-1)$ (#figref(<fig:vanishing>)). The network learns as fast as the ReLU one.

The opposite failure, an #term[exploding gradient], happens when the factors are larger than one, as they can be in recurrent networks that apply the same weights at every step. The gradient then grows from layer to layer until a single step throws the weights far away. The standard remedy is #term[gradient clipping]: when the gradient's length exceeds a set limit, scale it down to the limit before the step.

#note[
  A deep network trains only if the gradient reaches its early layers at a usable size. Use ReLU or one of its relatives in hidden layers, and add batch normalization when a deep stack still trains slowly. If the training loss sits at the value of predicting the average, the gradient is not getting through.
]

== Where the weights start

Why not start every weight at the same value, say 0.1? Then every unit of a layer computes the same sum, receives the same gradient, takes the same step, and stays identical to the others forever. Try it with two hidden layers of 32 units:

```terminal
constant start: 1 different units out of 32 after training; valid AUC 0.829
```

After 20 epochs the 32 units of the first layer are still 32 copies of one unit. The network still reaches a validation AUC of 0.829, because a single unit per layer is a model too, but it has thrown away nearly all its capacity. Random starting weights break this #term[symmetry]: units that start different receive different gradients and learn different features.

The scale of the random start matters as well. Each unit adds up many inputs, so with weights that are too large the sums grow from layer to layer, and with weights that are too small they shrink towards zero. #term[Xavier initialization] draws each weight with a variance of $1 \/ n$, where $n$ is the number of inputs to the unit, which keeps the size of the signal roughly constant through a layer of sigmoid or tanh units. #term[He initialization] uses $2 \/ n$, which does the same for ReLU, since ReLU sets about half its inputs to zero. PyTorch's dense layers start from a uniform draw between $-1 \/ sqrt(n)$ and $1 \/ sqrt(n)$, a scale of the same kind, so for the networks of this book the defaults are sound. The lesson is never to replace them with a constant.

== How the steps are taken

Every optimizer moves each weight against its gradient $g$. They differ in how they turn the gradient into a step.

/ Gradient descent.: One step per pass through all the data, using the exact gradient: slow, since a pass over a large table buys one step. #term[Stochastic gradient descent] (SGD) takes one step per example, which is fast but noisy. In practice "SGD" means #term[mini-batches]: one step per small batch, 64 customers here, which keeps the speed and averages away most of the noise. The update is $w <- w - eta g$, with learning rate $eta$.
/ Momentum.: Keep a running average of past gradients, $v <- beta v + g$, and step along it, $w <- w - eta v$, with $beta$ about 0.9. Steps that agree build up speed, and steps that zigzag cancel out, like a ball rolling down a valley.
/ Adagrad and RMSprop.: Give every weight its own step size. RMSprop keeps a running average of each weight's squared gradient, $s <- rho s + (1 - rho) g^2$, and divides the step by its square root, $w <- w - eta g \/ (sqrt(s) + epsilon)$. A weight that always gets large gradients takes smaller steps, and one that rarely gets any takes larger ones. Adagrad did the same with a running total instead of an average, so its steps shrank for good.
/ Adam.: Momentum and RMSprop together: a running average of the gradient for the direction, a running average of its square for the step size, and a small correction for the first steps, when both averages start at zero. It is the usual default, and the one Labs~7 and~8 use.

#utpfig([Training loss, epoch by epoch, of the same network (two hidden layers of 64 units) with four optimizers. Plain SGD starts slowly and is still falling after 30 epochs. Momentum, RMSprop and Adam are near their floor after a few epochs, and RMSprop and Adam keep pushing the training loss down.], label: <fig:optimizers>)[
  #canvas({
    axis(width: 12cm, height: 5.6cm, ..logaxis, xlabel: [epoch], ylabel: [training loss], xmin: 0, xmax: 31, ymin: 0.34, ymax: 0.63, xtick: (1, 5, 10, 15, 20, 25, 30), ytick: (0.35, 0.40, 0.45, 0.50, 0.55, 0.60), legend-style: logaxis.at("legend-style", default: (:)) + (at: (0.97, 0.97), anchor: "north-east"),
      addplot(draw: muted, line-width: widths.thick, coords: ((1, 0.616), (2, 0.584), (3, 0.563), (4, 0.546), (5, 0.53), (6, 0.514), (7, 0.498), (8, 0.483), (9, 0.471), (10, 0.46), (11, 0.452), (12, 0.445), (13, 0.44), (14, 0.436), (15, 0.433), (16, 0.431), (17, 0.429), (18, 0.427), (19, 0.426), (20, 0.425), (21, 0.424), (22, 0.423), (23, 0.423), (24, 0.422), (25, 0.422), (26, 0.421), (27, 0.421), (28, 0.42), (29, 0.42), (30, 0.419)), legend: [SGD]),
      addplot(draw: blue, line-width: widths.thick, coords: ((1, 0.491), (2, 0.429), (3, 0.421), (4, 0.419), (5, 0.419), (6, 0.414), (7, 0.414), (8, 0.413), (9, 0.411), (10, 0.411), (11, 0.41), (12, 0.408), (13, 0.407), (14, 0.412), (15, 0.41), (16, 0.406), (17, 0.411), (18, 0.407), (19, 0.407), (20, 0.401), (21, 0.401), (22, 0.401), (23, 0.4), (24, 0.398), (25, 0.4), (26, 0.397), (27, 0.399), (28, 0.396), (29, 0.395), (30, 0.407)), legend: [SGD with momentum]),
      addplot(draw: teal, line-width: widths.thick, coords: ((1, 0.422), (2, 0.412), (3, 0.413), (4, 0.406), (5, 0.405), (6, 0.404), (7, 0.401), (8, 0.399), (9, 0.397), (10, 0.393), (11, 0.396), (12, 0.389), (13, 0.389), (14, 0.385), (15, 0.385), (16, 0.383), (17, 0.38), (18, 0.385), (19, 0.377), (20, 0.375), (21, 0.372), (22, 0.375), (23, 0.372), (24, 0.371), (25, 0.366), (26, 0.364), (27, 0.361), (28, 0.359), (29, 0.367), (30, 0.359)), legend: [RMSprop]),
      addplot(draw: orange, line-width: widths.thick, coords: ((1, 0.43), (2, 0.418), (3, 0.412), (4, 0.411), (5, 0.409), (6, 0.404), (7, 0.405), (8, 0.4), (9, 0.396), (10, 0.395), (11, 0.393), (12, 0.389), (13, 0.386), (14, 0.386), (15, 0.387), (16, 0.38), (17, 0.379), (18, 0.376), (19, 0.379), (20, 0.368), (21, 0.366), (22, 0.369), (23, 0.368), (24, 0.362), (25, 0.365), (26, 0.364), (27, 0.356), (28, 0.357), (29, 0.357), (30, 0.368)), legend: [Adam]),
    )
  })
]

#utptable[
  #tabularx(
    columns: (1fr, auto, auto, auto, auto, auto, auto),
    align: (left, center, center, center, center, center, center),
    styles: (navy-bold,),
    header: ([Optimizer], [Training loss, epoch 1], [5], [30], [Validation AUC, epoch 1], [5], [30]),
    [SGD, $eta = 0.01$], [0.616], [0.530], [0.419], [0.703], [0.829], [0.854],
    [SGD with momentum 0.9], [0.491], [0.419], [0.407], [0.840], [0.854], [0.855],
    [RMSprop, $eta = 0.001$], [0.422], [0.405], [0.359], [0.852], [0.855], [0.841],
    [Adam, $eta = 0.001$], [0.430], [0.409], [0.368], [0.849], [0.857], [0.832],
  )
]

Read the two halves of the table together. Plain SGD needs about 30 epochs to get where the others are after five. Momentum reaches the same quality fast and then stays there. RMSprop and Adam are fastest of all, and they keep going: their training loss falls below the others', and their validation AUC falls too, from 0.855 and 0.857 at epoch 5 to 0.841 and 0.832 at epoch 30. A fast optimizer reaches the point of overfitting sooner, so it needs a brake more, and the last section of this chapter is about brakes.

== How big the steps are

The learning rate is the one setting that every optimizer has, and the one most worth tuning. Adam, with four learning rates, each ten times the one before:

#utptable[
  #tabularx(
    columns: (1fr, auto, auto, auto, auto, auto, auto),
    align: (left, center, center, center, center, center, center),
    styles: (navy-bold,),
    header: ([Learning rate], [Training loss, epoch 1], [5], [30], [Validation loss, epoch 1], [5], [30]),
    [0.0001], [0.617], [0.447], [0.409], [0.617], [0.440], [0.402],
    [0.001], [0.430], [0.409], [0.368], [0.418], [0.408], [0.453],
    [0.01], [0.419], [0.402], [0.310], [0.412], [0.411], [0.551],
    [0.1], [0.424], [0.422], [0.429], [0.421], [0.415], [0.412],
  )
]

Each row is a recognizable shape.

/ Too small (0.0001).: Slow but steady. After 30 epochs it has the lowest validation loss of the four, 0.402, because it has not yet begun to memorize. Given enough epochs it would.
/ About right (0.001).: Fast to a good point, then overfitting: the validation loss turns up after a few epochs.
/ Large (0.01).: The fastest memorizer. The training loss falls to 0.310 and the validation loss rises to 0.551.
/ Too large (0.1).: The steps overshoot. The training loss stops improving after the first epoch and is still 0.429 at epoch 30: the weights bounce around the bottom of the valley instead of settling into it.

A training curve read this way tells you which side of the right rate you are on. Many projects also change the rate during training with a #term[learning-rate schedule]: larger steps first to make progress, smaller ones later to settle. Common choices halve the rate whenever the validation loss stops improving, or let it fall smoothly towards zero along a cosine curve.

== When to stop, and other brakes

A network with two hidden layers of 256 units has 77,825 weights, and there are 4,225 training customers. It can memorize them, and given 60 epochs it does (#figref(<fig:overfit>)).

#utpfig([Training and validation loss, epoch by epoch, of a network with 77,825 weights. Left alone, it drives the training loss down to 0.108 while the validation loss, lowest at epoch 3, climbs to 1.043. With dropout the two curves stay close for far longer.], label: <fig:overfit>)[
  #canvas({
    axis(width: 12cm, height: 5.6cm, ..logaxis, xlabel: [epoch], ylabel: [loss], xmin: 0, xmax: 61, ymin: 0, ymax: 1.1, xtick: (1, 10, 20, 30, 40, 50, 60), ytick: (0, 0.2, 0.4, 0.6, 0.8, 1.0), legend-style: logaxis.at("legend-style", default: (:)) + (at: (0.03, 0.97), anchor: "north-west"),
      addplot(draw: blue, dash: "dashed", line-width: widths.thick, coords: ((1, 0.422), (2, 0.411), (3, 0.403), (4, 0.404), (5, 0.398), (6, 0.394), (7, 0.395), (8, 0.379), (9, 0.373), (10, 0.365), (11, 0.36), (12, 0.35), (13, 0.34), (14, 0.34), (15, 0.324), (16, 0.318), (17, 0.319), (18, 0.297), (19, 0.291), (20, 0.284), (21, 0.267), (22, 0.272), (23, 0.299), (24, 0.25), (25, 0.243), (26, 0.236), (27, 0.232), (28, 0.225), (29, 0.212), (30, 0.195), (31, 0.208), (32, 0.189), (33, 0.184), (34, 0.199), (35, 0.176), (36, 0.18), (37, 0.157), (38, 0.154), (39, 0.152), (40, 0.152), (41, 0.152), (42, 0.144), (43, 0.136), (44, 0.136), (45, 0.137), (46, 0.131), (47, 0.129), (48, 0.129), (49, 0.128), (50, 0.121), (51, 0.116), (52, 0.117), (53, 0.111), (54, 0.114), (55, 0.122), (56, 0.108), (57, 0.111), (58, 0.105), (59, 0.108), (60, 0.108)), legend: [training, no brake]),
      addplot(draw: blue, line-width: widths.thick, coords: ((1, 0.415), (2, 0.406), (3, 0.402), (4, 0.408), (5, 0.41), (6, 0.41), (7, 0.42), (8, 0.411), (9, 0.413), (10, 0.42), (11, 0.42), (12, 0.422), (13, 0.427), (14, 0.441), (15, 0.441), (16, 0.447), (17, 0.467), (18, 0.466), (19, 0.471), (20, 0.485), (21, 0.49), (22, 0.512), (23, 0.545), (24, 0.519), (25, 0.527), (26, 0.551), (27, 0.546), (28, 0.565), (29, 0.579), (30, 0.59), (31, 0.592), (32, 0.63), (33, 0.635), (34, 0.674), (35, 0.671), (36, 0.696), (37, 0.708), (38, 0.714), (39, 0.742), (40, 0.759), (41, 0.736), (42, 0.768), (43, 0.811), (44, 0.794), (45, 0.778), (46, 0.812), (47, 0.851), (48, 0.836), (49, 0.869), (50, 0.866), (51, 0.864), (52, 0.945), (53, 0.925), (54, 0.9), (55, 0.953), (56, 0.95), (57, 0.97), (58, 0.98), (59, 1.015), (60, 1.043)), legend: [validation, no brake]),
      addplot(draw: teal, dash: "dashed", line-width: widths.thick, coords: ((1, 0.424), (5, 0.406), (10, 0.394), (15, 0.385), (20, 0.373), (25, 0.361), (30, 0.353), (35, 0.339), (40, 0.326), (45, 0.318), (50, 0.308), (55, 0.295), (60, 0.28)), legend: [training, dropout 0.5]),
      addplot(draw: teal, line-width: widths.thick, coords: ((1, 0.414), (5, 0.408), (10, 0.404), (15, 0.409), (20, 0.411), (25, 0.411), (30, 0.421), (35, 0.425), (40, 0.429), (45, 0.44), (50, 0.447), (55, 0.461), (60, 0.475)), legend: [validation, dropout 0.5]),
    )
  })
]

Three brakes are in common use, and they can be combined.

/ Early stopping.: Watch the validation loss after every epoch, keep a copy of the weights from the best epoch, and put them back at the end. Here the best epoch is the third. It costs nothing but a validation set, and it is the brake that every training loop should have; Lab~8’s loop has it.
/ Dropout.: During training, set a random share of the units to zero at every step, half of them here. No unit can rely on one particular partner, so the network learns features that survive without them, much as a team in which anyone may be absent must spread its knowledge. At prediction time every unit is used. The validation loss is lowest at epoch 9 and then rises slowly.
/ Weight decay.: Shrink every weight a little at every step, which is the ridge penalty of #chapref(<ch:regression>) applied during training. PyTorch's `AdamW` does it with a separate setting, `weight_decay`.

#utptable[
  #tabularx(
    columns: (1fr, auto, auto, auto),
    align: (left, center, center, center),
    styles: (navy-bold,),
    header: ([77,825 weights, 60 epochs], [Training loss at the end], [Validation loss of the model kept], [Validation AUC]),
    [No brake], [0.108], [1.043], [0.791],
    [Dropout 0.5], [0.280], [0.475], [0.831],
    [Weight decay 1.0], [0.305], [0.458], [0.821],
    [Early stopping], [0.108], [0.402], [0.858],
  )
]

Dropout and weight decay both slow the memorizing, and the network they leave after 60 epochs is far better than the unbraked one. Early stopping does better still, because it simply keeps the network from before the memorizing began. In practice the three are combined, with early stopping as the last line of defence.

How many layers and how many units? There is no formula. Treat depth and width like any other setting (#secref(<sec:hyperparameter-tuning>)): start small, grow until the validation score stops improving, and stop. The network above is far larger than this table needs, and it still matches the best result once it is stopped in time.

== Does it beat a simpler model?

All of this effort deserves a fair contest. Open the test customers once, and score the early-stopped network beside two models that need none of it:

```terminal
test ROC AUC: {'logistic regression': 0.833, 'gradient boosting': 0.816, 'network, early stopping': 0.832}
```

The network ties the logistic regression and beats gradient boosting with its default settings. On a table of a few thousand rows with a few dozen columns, that is the usual outcome: the relationships are simple enough for a linear model, and there are too few rows for a network's extra capacity to find anything more. Networks earn their keep where the inputs are images, sound or text, where the useful features are hard to write down and the data is plentiful. #chapsref(<ch:cnn>, <ch:sequence>) are about those inputs.

#warning[
  A network that beats nothing is not a result. Before reporting one, score at least a logistic regression or a boosted model on the same split, and keep the network only if its validated gain pays for its cost to train, run and explain.
]

== Practical notes

- #term[Set the seed] (`torch.manual_seed`) and expect small differences between runs anyway: the starting weights and the order of the batches are random. Report the spread over a few seeds when the gap between two models is small.
- #term[Scale the inputs] using the training rows only, and save the fitted scaler with the model.
- #term[Use full batches with batch normalization.] It needs at least two examples per batch; drop a last batch of one, as the training loop above does.
- #term[Switch modes.] `model.train()` turns dropout and batch-normalization updates on, and `model.eval()` turns them off for prediction. Forgetting `eval()` gives predictions that change from call to call.
- #term[Save the weights] with `torch.save(model.state_dict(), path)`, and keep the code that builds the network, the scaler and a model card beside them, as Labs~7 and~8 do.
- #term[A CPU suffices] for every network in this book. Larger networks, and large images, need a GPU.

#utpsteps[
  + #term[Start with a baseline] that needs no training loop, and a small network with ReLU, Adam at 0.001, and the default initialization.
  + #term[Check that it learns:] the training loss must fall below the loss of predicting the average. If it does not, look at the gradient sizes.
  + #term[Read the curves:] training and validation loss, every epoch. Adjust the learning rate first.
  + #term[Add capacity] only while the validation score improves, and add brakes, with early stopping always on.
  + #term[Compare on the test set once,] against the baseline, with the spread over seeds when the gap is small.
]

#summary[
  - In ten sigmoid layers the first layer's gradient was $1.8 times 10^(-9)$ and the network learned only the average. ReLU and batch normalization keep the gradient at a usable size; clipping keeps an exploding one in check.
  - Weights must start random: a constant start left 32 units as copies of one. Xavier and He scale the random start to keep the signal's size steady.
  - SGD steps along the gradient, momentum along its running average, RMSprop scales each weight's step, and Adam does both. Adam was fastest, and it overfitted soonest.
  - Too small a learning rate is slow, too large a rate never settles. The training curve shows which.
  - A network with 77,825 weights memorized 4,225 customers. Early stopping kept the epoch-3 network, with a validation AUC of 0.858; dropout and weight decay slowed the memorizing.
  - On this table the network tied logistic regression on the test set, 0.832 against 0.833. Networks pay off on images, sound and text.
]

#exercises[
  In `demo_deep_training.py`, set `CHECK_BOOK_NUMBERS = False`. In `vanishing()`, change the network from ten hidden layers to three, `[32] * 3`, and run the script. How large is the first layer's gradient compared with the last's for the sigmoid network now, and does it learn in 20 epochs? Then try twenty layers. How deep can a sigmoid network be before it stops learning on this table?
]

#questions[
  + A deep network's training loss sits at the value of predicting the average for every row. Name two likely causes and one check for each.
  + Why does replacing sigmoid with ReLU in the hidden layers help the gradient reach early layers?
  + What does batch normalization do to a unit's sums, and why does that help a sigmoid network?
  + Every weight of a network starts at 0.1. What happens during training, and why?
  + Write the update rules of SGD with momentum and of RMSprop. What does each add to plain SGD?
  + A training loss falls quickly, then stops improving at a high value and jumps around. What would you change first?
  + Name three ways to stop a large network from memorizing its training rows, and say which one should always be used.
  + A network and a logistic regression score 0.832 and 0.833 on the same test set. Which do you ship, and why?
]
