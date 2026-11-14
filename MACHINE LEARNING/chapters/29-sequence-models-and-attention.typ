#import "/.shared/typst/utp.typ": *
#import "/MACHINE LEARNING/course-tools.typ": *
#import "study-log-figures.typ": *
#unit("chapters", "29-sequence-models-and-attention")

#let sequence-demo = "/MACHINE LEARNING/all_experiments/book_checks/demo_sequence.py"

= Sequence Models and Attention <ch:sequence>

#chapterguide[Networks and their training from #chapsref(<ch:deep>, <ch:deep-training>)\; splitting by date from #chapref(<ch:data>)\; the softmax and the vanishing gradient.][turn a series into windows and split them by date; explain what a recurrent network's state carries and why a plain one forgets; follow an LSTM's three gates and a GRU's two; say when to read a sequence both ways; explain the bottleneck of an encoder and decoder and how attention removes it; compute self-attention by hand; explain why a transformer needs positions; and compare five sequence models fairly against free forecasts.]

Reading a sentence, you do not start afresh at each word. You carry a running sense of what has happened so far, and the meaning of a word depends on what came before it, sometimes long before. Forecasting tomorrow's demand works the same way: the last few hours matter, and so does the same hour yesterday. The models of this chapter are built for inputs whose order is part of their meaning: series, sentences, sound.

The running example is Lab~8’s: forecast the next hour's total electricity demand of 158 customers from the 24 hours before it. To keep the experiments short, the networks here train on 2013 only (8,760 windows), stop early on January to June 2014 (4,344 windows), and are scored once on July to December 2014 (4,416 windows); Lab~8 trains on three years. Every number comes from `all_experiments/book_checks/demo_sequence.py`, except the small worked examples, which come from `demo_advanced.py`.

== From a series to windows

A sequence model does not take a table of separate rows; it takes the last few values and predicts the next.

#workedexample[
  From series to windows. With lookback 3, the series $16,40,32,13,1,1,2,3$ gives five rows:

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
  $N$ values give $N$ minus lookback windows. Neighbouring rows overlap, so a random split would put almost the same row on both sides: split in date order. The simplest forecast, #term[persistence], says the next value equals the last, and on these targets its misses are 19, 12, 0, 1 and 1.
  ]]]
]

Free forecasts like persistence set the bar for any model. On the validation half-year, "the same as the last hour" misses by 5.77~MWh in an average hour and "the same as this hour yesterday" by 3.07; on the test half-year, by 6.12 and 3.69.

== Recurrent networks

#analogy[
  A #term[recurrent network] carries a #term[hidden state], like a reader keeping a small notepad. Each step combines the new input with the notes so far and writes new notes: $h_t = tanh(W x_t + U h_(t-1) + b)$. The same weights $W$ and $U$ are used at every step, however long the sequence.
]

#workedexample[
  A toy recurrent unit with fixed weights: $"state"=0.5 times "previous state"+"input"$. Inputs $1,2,3$ give states $1, space 2.5, space 4.25$. The final state holds all three inputs, with the oldest counting least.

  That fading is also the weakness. At 0.5 per step, an input's weight after 8 steps is 0.0039, and after 24 steps it is about 0.00000006. A plain network has trouble remembering yesterday by the time it reaches today.
]

Training a recurrent network unrolls it over the window and runs backpropagation through all the copies, which is called #term[backpropagation through time]. The gradient for an early step is a product with one factor per step, exactly the product that faded in the deep sigmoid networks of #chapref(<ch:deep-training>), and it fades or explodes in the same way. Gradient clipping handles the explosions. The fading needs a different design.

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

=== The LSTM: a memory with gates

An #term[LSTM], for long short-term memory, adds a second notepad, the #term[memory cell] $c_t$, and three learned #term[gates]. Each gate is a small sigmoid layer that looks at the new input and the previous state and outputs numbers between 0 and 1, one per memory slot:

/ Forget gate $f_t$.: How much of each slot of the old memory to keep.
/ Input gate $i_t$.: How much of a new candidate, $tilde(c)_t = tanh(dots.c)$, to write.
/ Output gate $o_t$.: How much of the memory to show as the new state, $h_t = o_t dot.o tanh(c_t)$.

The memory is updated by adding, not by multiplying through a squashing function:

$ c_t = f_t dot.o c_(t-1) + i_t dot.o tilde(c)_t. $

With a keep gate of 0.8 on a note of 10, and a write gate of 0.5 on a new value of 4, the note becomes $0.8 times 10+0.5 times 4=10$. When the forget gate stays near 1, the memory passes from step to step almost untouched, and so does its gradient, which is what lets an LSTM learn from inputs many steps back. The gates' values come from small learned networks, so the model decides for itself what is worth keeping.

Four sets of weights (three gates and the candidate), each with weights for the input, for the previous state and two bias vectors in PyTorch's layout, make $4 times (32 + 32 times 32 + 32 + 32) = 4","480$ weights for 32 memory slots and one input per step; the output layer adds 33, for Lab~8’s 4,513.

=== The GRU: two gates

A #term[GRU], for gated recurrent unit, keeps the idea and drops a gate. It has no separate memory cell. An #term[update gate] $z_t$ decides how much of the old state to replace, and a #term[reset gate] $r_t$ decides how much of the old state to use when proposing the new one:

$ h_t = (1 - z_t) dot.o h_(t-1) + z_t dot.o tilde(h)_t. $

Three sets of weights instead of four make it about a quarter smaller: 3,393 weights against 4,513 here. Which of the two works better depends on the data, and the only way to know is to try both.

=== Reading both ways

A #term[bidirectional] network runs one recurrent layer forward through the sequence and a second one backward, and joins their states. For a word in a sentence, what comes after is often as informative as what came before, so bidirectional layers are common in text classification and tagging. For a forecast they are useless, because the future is exactly what is not available.

== Encoders, decoders and attention

Many tasks turn one sequence into another of a different length: a sentence into its translation, a question into its answer, a month of demand into next week's. The classic design is an #term[encoder] and a #term[decoder]. The encoder reads the input sequence and ends with a state, and the decoder starts from that state and writes the output one step at a time, each step fed the step before.

The weak point is the hand-over. Everything the decoder will ever know about the input must pass through the encoder's final state, a single vector of fixed size, whether the input is five words or five hundred. Long inputs overflow it.

#term[Attention] removes the bottleneck. Instead of one final state, the decoder keeps all the encoder's states, and at every output step it computes a score for each of them: how relevant that input step is to what is being written now. A softmax turns the scores into weights that add up to one, and the decoder reads the weighted average of the encoder states. Translating a word, it can look straight at the word it translates, wherever that word sits.

== Transformers: attention all the way

A #term[transformer] drops the recurrence altogether and builds the whole network out of attention. In #term[self-attention], every position of a sequence attends to every position of the same sequence. Each position's vector is mapped three ways: to a #term[query] (what it is looking for), a #term[key] (what it offers) and a #term[value] (what it passes on). The output for each position is

$ op("Attention")(Q, K, V) = op("softmax")(Q K^T \/ sqrt(d)) thin V, $

a weighted average of the values, weighted by how well each key matches the position's query. Dividing by $sqrt(d)$, where $d$ is the vectors' length, keeps the scores in a range where the softmax still has a slope.

#workedexample[
  Three tokens with vectors $(1, 0)$, $(0, 1)$ and $(1, 1)$, and, to keep the arithmetic visible, queries, keys and values equal to the vectors themselves.

  #emph[Scores:] each pair's dot product divided by $sqrt(2)$. The first token scores 0.707 with itself, 0 with the second and 0.707 with the third; the third scores 1.414 with itself.

  #emph[Weights:] a softmax of each row. The first token gives weights 0.401, 0.198 and 0.401; the third gives 0.248, 0.248 and 0.503.

  #emph[Outputs:] the weighted averages of the vectors. The first token receives $(0.802, 0.599)$: mostly itself, plus some of the second. The third receives $(0.752, 0.752)$.

  Now reverse the order of the three tokens. Every token receives exactly what it received before; only the order of the outputs is reversed. Self-attention compares contents and never looks at positions.
]

That last property is a problem for a sequence model. To a transformer as described so far, "dog bites man" and "man bites dog" are the same three words. The cure is #term[positional encoding]: before the first layer, add to each position's vector a pattern that depends only on the position. The usual pattern is a set of sines and cosines of the position at different wavelengths; for vectors of length 4, positions 0, 1 and 2 get $(0, 1, 0, 1)$, $(0.841, 0.540, 0.010, 1)$ and $(0.909, -0.416, 0.020, 1)$. With the patterns added, reversing the tokens does change what each one receives.

A full transformer layer adds three more parts around the attention:

/ Several heads.: #term[Multi-head attention] runs several attentions side by side, each with its own query, key and value maps, so that one head can follow, say, the previous hour while another follows the same hour yesterday. Their outputs are joined.
/ A feed-forward block.: A small dense network applied to each position separately.
/ Shortcuts and normalization.: Each block's input is added to its output, a #term[residual connection] that gives the gradient a direct path backward, and #term[layer normalization] rescales each position's vector, much as batch normalization does in #chapref(<ch:deep-training>).

A transformer #term[encoder] stacks such layers and lets every position see every other, which suits reading a whole input. A #term[decoder] adds #term[masked] self-attention, in which a position may attend only to positions before it, so that the model cannot peek at the words it is about to write, and an attention over the encoder's outputs. The large language models behind today's chatbots are decoders of this kind, trained to predict the next word on enormous amounts of text; models trained instead to fill in hidden words with an encoder are the ones most used for classifying and searching text. #chapref(<ch:text>) shows, on a small scale, why training first on unlabeled text helps when labels are few.

== Five models, one forecast

How do these designs compare on Lab~8’s task? Five networks forecast the next hour from the 24 before it, each trained from three random starts with early stopping on the validation half-year. The attention model embeds each hour as a vector of 32, adds positions or not, passes the 24 vectors through one transformer encoder layer with four heads, and averages them into a forecast.

#utptable[
  #tabularx(
    columns: (1fr, auto, auto, auto, auto),
    align: (left, center, center, center, center),
    styles: (navy-bold,),
    header: ([Model], [Weights], [Validation MAE, three starts], [Mean], [Test MAE, mean]),
    [Same hour yesterday], [---], [---], [3.07], [3.69],
    [Plain recurrent], [1,153], [2.78, 3.76, 2.57], [3.04], [3.35],
    [LSTM], [4,513], [2.50, 2.29, 2.80], [2.53], [2.84],
    [GRU], [3,393], [3.16, 3.06, 2.69], [2.97], [3.10],
    [Attention with positions], [8,641], [2.29, 2.04, 1.90], [2.08], [2.44],
    [Attention without positions], [8,641], [21.53, 21.70, 21.89], [21.71], [23.4],
  )
]

Four lessons, in order of importance.

/ Positions are not optional.: Without positional encoding, the attention model misses by more than 21~MWh in an average hour, seven times worse than "same hour yesterday". It cannot tell which of the 24 hours is the most recent, so it can only forecast from the general level of the window.
/ Every model uses order, and the test proves it.: Shuffle the 24 hours of every validation window and give them back to the models. The recurrent models and the attention model with positions then miss by 30 to 33~MWh. The attention model without positions misses by 21.53, exactly its error on the windows in their real order: for it, the order never existed.
/ Gates help.: The LSTM beats the plain recurrent network on average, 2.53 against 3.04. On average every recurrent model beats the free forecast, the plain one only just. The GRU, with three-quarters of the LSTM’s weights, lands between the two.
/ The spread is large.: The plain recurrent network ranges from 2.57 to 3.76 depending only on its random start. A difference between two of these models smaller than that spread is not a finding. Report several starts, as this table does.

The attention model with positions is the most accurate here, on both halves of 2014. On a series this regular, it can also be checked what each model's forecast depends on: nudge each hour of the window and see how much the forecast moves. The GRU puts 58% of its sensitivity on the last hour, the attention model 46%, the LSTM 28%. The attention model also puts 10% on the hour exactly one day before the forecast, against 1% to 4% for the recurrent models: with positions and four heads, it found the daily cycle that the free forecast "same hour yesterday" relies on.

#pitfall[
  A sequence model must beat the free forecasts on a date-ordered split before it means anything. And a transformer must be given positions; without them, it treats a window as a bag of values, however good its training curve looks.
]

== Choosing a sequence model

#utptable[
  #tabularx(
    columns: (21%, 1fr, 1fr),
    styles: (navy-bold,),
    header: ([Model], [Strengths], [Weaknesses]),
    [Free forecasts], [Cost nothing; the bar every model must clear], [Know nothing beyond one fixed rule],
    [Plain recurrent], [Few weights; simple], [Forgets quickly; gradients fade through time],
    [LSTM], [Gated memory carries information across many steps], [More weights; reads one step at a time, so it is slow on long sequences],
    [GRU], [Most of the LSTM's power with fewer weights], [Neither clearly better nor worse; try both],
    [Bidirectional], [Uses context on both sides], [Useless when the future is unknown, as in forecasting],
    [Transformer], [Every position sees every other at once; trains in parallel; the basis of modern language models], [Needs positional encoding; cost grows with the square of the sequence length; needs more data],
  )
]

== The whole map

The names of the last thirty chapters are now a map with a few corners, and every method in this book lives somewhere on it. When you meet a new name, do not try to memorize it. Ask which corner it lives in, and which step of the recipe it changes.

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
    [Neural network], [Any], [Layers], [Task's loss], [Backpropagation with gradient descent],
    [CNN], [Images], [Shared filters, then layers], [Task's loss], [The same],
    [LSTM, GRU], [Sequences], [Gated recurrent state], [Task's loss], [The same, through time],
    [Transformer], [Sequences], [Layers of attention], [Task's loss], [The same],
  )
]

#keyidea[
  Machine learning is one recipe with its parts swapped. Pick a formula with numbers you are allowed to change, measure its errors with one number, and find the values that make that number smaller. Then check the result on data it has not seen.
]

#tryit[
  In `demo_sequence.py`, set `CHECK_BOOK_NUMBERS = False`, and change `LOOKBACK` from 24 to 6. Run the script. How do the five models compare when the window no longer contains the same hour yesterday? Which model loses the most, and why might that be?
]

#chapterrecap[
  - A series becomes overlapping windows; split them by date, and beat the free forecasts first: 3.07 and 3.69~MWh for "same hour yesterday" here.
  - A recurrent network carries a state; its gradient fades through time like a deep sigmoid stack's. The LSTM's memory is updated by adding, guarded by forget, input and output gates; the GRU does it with two gates and a quarter fewer weights.
  - An encoder and decoder pass everything through one final state. Attention lets each output step look at every input step, weighted by relevance.
  - Self-attention is $op("softmax")(Q K^T \/ sqrt(d)) V$. It ignores order, so a transformer adds positional encodings.
  - Without positions the attention model missed by 21.7~MWh; with them, it was the best of five, 2.08 on validation and 2.44 on the test. The plain recurrent network ranged from 2.57 to 3.76 over three random starts.
]

#quickcheck[
  + A series has 1,000 hourly values and a lookback of 24. How many windows are there, and why must they be split by date?
  + At 0.5 per step, what weight does an input keep after 10 steps in the toy recurrent unit? What does that mean for learning from yesterday?
  + An LSTM's forget gate is 0.9, its input gate 0.2, its old memory 5 and its candidate 10. What is the new memory?
  + Why is a bidirectional network fine for classifying reviews and useless for forecasting demand?
  + What problem of the encoder and decoder does attention solve?
  + Compute the attention weights of the second token in the worked example, and its output.
  + A transformer without positional encoding is given a window and the same window shuffled. What does it output, and why?
  + Two sequence models differ by 0.3~MWh, and one of them varies by 1.2~MWh across random starts. What do you conclude?
]
