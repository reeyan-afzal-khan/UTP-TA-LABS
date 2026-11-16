#import "/.shared/typst/utp.typ": *
#unit("chapters", "09-local-search")

= Local Search: When Only the Answer Counts <ch:localsearch>

#chapterguide[Know the search loop of #chapref(<ch:uninformed>) and the heuristic idea of #chapref(<ch:informed>), and be comfortable with random numbers in Python.][explain when a problem needs a final answer rather than a route; run hill climbing by hand; say what a local maximum is and why random restarts and simulated annealing escape it; compute an annealing acceptance probability; and use beam search to keep several options alive.]

Until now the route was the answer. The robot needed the whole path to the charger, and we judged a search by what that path cost. Many problems are not like that. When you hand in a solved Sudoku, nobody asks what order you filled it in. A school timetable, a chip layout and the coefficients of a model are all judged only as finished products.

That changes what a search has to remember. If nobody needs the route, there is no reason to keep it. #term[Local search] keeps one candidate, or a few, and keeps improving them. It answers the fourth question from #chapref(<ch:uninformed>): #emph[what if only the final answer counts?] This chapter has no lab of its own; it sets up the genetic algorithm of #chapref(<ch:ga>), which Lab~8 practises. Every number below comes from `all_experiments/demo_local_search.py`.

== The eight-queens puzzle

Place eight queens on a chessboard so that no two attack each other. A queen attacks along its row, its column and both diagonals. Keep one queen in each column and each queen can sit on any of eight squares, which gives $8^8$, more than 16.7 million boards, and only 92 of them work.

We can run the search loop of #chapref(<ch:uninformed>) on this. The goal test is “no attacks” and a move shifts one queen. But breadth-first search has to hold a huge to-do list of boards just to reach an answer whose route nobody wants. So what if we keep just one board and keep making it better?

== Hill climbing

Call fewer attacks higher ground, so that every better board is a step uphill. A board’s #term[neighbours] are the boards we get by moving one queen up or down its own column. Eight queens with seven other squares each give $8 times 7=56$ neighbours. #term[Hill climbing] moves to the best neighbour, then looks around and repeats, and it stops when no neighbour is better (#figref(<fig:queens-board>)).

Picture yourself on a hillside in thick fog. You can only feel the ground right next to your feet, so you never plan ahead and you never look back. You take the steepest step up and repeat. When every step would go down, you stop and declare that you have reached the top. That may be a small foothill, with a far taller peak hidden across the valley.

#utpfig([Left: a random board, written below it as the row of each column’s queen, counting rows from zero at the top. Red lines join the 6 attacking pairs. Middle: hill climbing scores all 56 neighbours and moves to the best, which here has 3 attacking pairs. Right: the algorithm in plain words. Between moves it keeps only one board.], label: <fig:queens-board>)[
  #canvas({
    let q = 0.38
    for r in range(0, 8) {
      for c in range(0, 8) {
        let odd = int(calc.rem(r + c, 2))
        if odd == 1 {
          rectangle((q * c, -q * r), (rel: (q, -q), to: (q * c, -q * r)), fill: pale-blue, draw: none)
        } else {
          rectangle((q * c, -q * r), (rel: (q, -q), to: (q * c, -q * r)), fill: white, draw: none)
        }
      }
    }
    rectangle((0, 0), (8 * q, -8 * q), draw: mix(blue, 55%))
    for (c, r) in ((0, 7), (1, 4), (2, 6), (3, 1), (4, 4), (5, 5), (6, 3), (7, 4)) {
      coordinate("Q" + str(c), (q * c + q / 2, -q * r - q / 2))
    }
    for (a, b) in ((1, 4), (1, 7), (2, 4), (4, 5), (4, 7), (6, 7)) {
      connect("Q" + str(a), "Q" + str(b), draw: red, line-width: widths.thick)
    }
    for c in range(0, 8) {
      node("Q" + str(c), [Q], shape: "circle", fill: navy, text: white, inner-sep: 0pt, min-size: 0.27, font: font("tiny", weight: "bold"))
    }
    node((4 * q, -8 * q - 0.08), [7 4 6 1 4 5 3 4], font: font("small"), ..utplabel, anchor: "north", align: center)
    draw.scope({
      draw.translate((4, 0))
      draw.translate((0, -1.5))
      connect((-0.35, 0), (0.3, 0), ..utparrow)
      node((1.65, 0), [score 56 neighbours \
  take the fewest attacks], ..utpbox, min-width: 2.5, fill: pale-orange, draw: orange, align: center, font: font("script", fill: navy))
      connect((3, 0), (3.6, 0), ..utparrow)
    })
    node((7.75, -1.5), [#strong[Hill climbing] \ #v(1.9925pt)
   `board` $arrow.l$ a random board \
   #strong[repeat:] \
   #h(1em)score every neighbour of `board` \
   #h(1em)#strong[if] the best is no better: #strong[stop] \
   #h(1em)`board` $arrow.l$ the best neighbour], anchor: "west", align: left, text-width: 5.4, font: font("script", fill: navy))
  })
]

The memory saving is dramatic. Hill climbing holds at most 56 boards at any moment, and only one between moves. On one random board with 5 attacking pairs, the breadth-first loop expands 67,836 boards and its to-do list peaks at 456,001. Here is the whole of hill climbing in Python:

#lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/demo_local_search.py", first: 39, last: 49, lang: "python")

#note[
  You have met this idea already if you have trained a machine learning model. #term[Gradient descent] is hill climbing turned upside down: it walks downhill on the loss, the number that says how wrong the model is. ANFIS in #chapref(<ch:fuzzy>) used exactly this walk for its membership functions.
]

== Stuck on a local maximum

The foggy hillside hides a weakness. Run hill climbing on the maze from #chapref(<ch:uninformed>) with higher ground meaning a smaller Manhattan guess, and the robot goes $(5,1) arrow.r (4,1) arrow.r (3,1) arrow.r (2,1)$ and stops, with a guess of 8. Ahead of it is a wall, and every open neighbour guesses 9. No move looks better, so it quits long before the charger.

The same thing happens on the queens. A board where no single move helps is a #term[local maximum]. It can look fine from where you stand, and it still has attacking queens. How often does that happen? Over 1,000 random boards, hill climbing solves 150 and gets stuck on the other 850.

== Two ways to get unstuck

=== Random restarts

The first fix is blunt. When you get stuck, throw the board away and climb again from a fresh random one. Keep doing that and you will eventually land on the right hillside, so #term[random-restart hill climbing] always solves the board in the end. It takes 7.3 climbs on average and looks at about 1,700 boards per puzzle solved.

=== Simulated annealing

Restarts throw away a whole board every time you are stuck. Is there a gentler way off a hilltop? What if the robot sometimes took a step downhill on purpose? It sounds like the dumbest idea in this book, and it works.

The trick comes from metalworking and crystal growing. Melt a material and then cool it slowly. While it is hot its atoms move around freely, and as it cools they settle into a neat, low-energy crystal. Cool it too fast and the atoms freeze in a disordered jumble. That slow cooling is called #term[annealing].

In 1983 Kirkpatrick, Gelatt and Vecchi, then at IBM, turned this into a search and used it to design computer chips. #term[Simulated annealing] picks one random move at each step. If the move is no worse, it always takes it. If the move is worse, it may still take it, with a chance that depends on how much worse the move is and on a #term[temperature] $T$ that falls a little at every step:

$ P("accept a move that adds " Delta " attacks") med = med e^(- Delta \/T). $

#figref(<fig:annealing>) shows what that formula does. At $T=1$ a move adding one attack gets through 37 times in 100, and a move adding three gets through about 5 times in 100. At $T=0.1$, one extra attack counts as heavily as ten did before, so it gets through only about 5 times in 100,000. While the search is hot it wanders freely; as it cools it behaves more and more like plain hill climbing.

#utpfig([The chance of accepting a move that adds $Delta$ attacks, as the temperature falls. Hot searches accept even bad moves often, which lets them walk off a local maximum. Cold searches almost never do. A move that is no worse ($Delta <= 0$) is always accepted.], label: <fig:annealing>)[
  #canvas({
    axis(width: 11.5632cm, height: 5cm, xlabel: [temperature $T$ (the search cools from right to left)], ylabel: [chance of accepting], xmin: 0, xmax: 1, ymin: 0, ymax: 0.42, ytick: (0, 0.1, 0.2, 0.3, 0.4), axis-lines: "left", grid: "major", grid-style: (draw: pale-blue), domain: (0.03, 1), samples: 80, clip: false,
      addplot(draw: blue, line-width: widths.very-thick, x => calc.exp(-1 / x)),
      addplot(draw: teal, line-width: widths.very-thick, x => calc.exp(-2 / x)),
      addplot(draw: orange, line-width: widths.very-thick, x => calc.exp(-3 / x)),
      {
        node((0.98, 0.37), [$Delta =1$], font: font("script", fill: blue), anchor: "south-east")
        node((0.98, 0.14), [$Delta =2$], font: font("script", fill: mix(teal, 70%, other: black)), anchor: "south-east")
        node((0.98, 0.05), [$Delta =3$], font: font("script", fill: mix(orange, 85%, other: black)), anchor: "south-east")
      },
    )
  })
]

#lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/demo_local_search.py", first: 63, last: 76, lang: "python")

Annealing has the restart built in. Instead of throwing the whole board away when stuck, it takes a small random step back, keeps the rest of its board, and climbs on from there. It solves 990 of the same 1,000 boards and looks at about 1,100 boards per puzzle solved, roughly 600 fewer than restarts.

#warning[
  Annealing has settings: a starting temperature, a cooling rate and a stopping temperature. Cool too quickly and it behaves like hill climbing and freezes on a local maximum. Cool too slowly and it wastes work. The demo starts at $T=1$, multiplies by 0.999 per step and stops below 0.01. Those values suit eight queens and are not universal.
]

== Beam search: keep a few options

Local search with one board has a blind spot. Suppose a phone keyboard wants the most likely short message that starts “the flight”. It gives each possible next word a chance, and a message’s chance is its words’ chances multiplied together. #figref(<fig:beam>) uses a small table of chances written by hand.

Keeping one option means taking the single best word each time: “is” at 0.5, then “late” at 0.45, for a message scoring $0.5 times 0.45=0.225$. But look at what got thrown away. “Was” scored only 0.4 at the first word, yet “cancelled” follows it with 0.8, for a message scoring $0.4 times 0.8=0.32$. The best complete message started with a word that looked second best.

#utpfig([A hand-written table of next-word chances. With width 1 the search commits to “is” at the first word and can never recover. With width 2 it keeps both “is” and “was”, scores every continuation, and finds the better message. Numbers on the right are whole-message chances.], label: <fig:beam>)[
  #canvas({
    let w = (..utpcell, min-width: 1.55, min-height: 0.62, font: font("script", weight: "bold", fill: navy))
    let wk = (..utpdone, min-width: 1.55, min-height: 0.62, font: font("script", weight: "bold", fill: navy))
    let wd = (..utpdim, min-width: 1.55, min-height: 0.62, font: font("script", fill: muted))
    let lk = (line-width: widths.semithick, draw: teal)
    let pl = (..utplabel, fill: white, inner-sep: 0.797pt)
    node((0, 0), [the flight], name: "s", font: font("small"), ..w)
    node((3, 1), [is], name: "a", font: font("small"), ..wk)
    node((3, -0.2), [was], name: "b", font: font("small"), ..wk)
    node((3, -1.3), [left], name: "c", font: font("small"), ..wd)
    connect("s", "a", ..lk)
    node(along("s", "a", t: 50%), [0.5], font: font("small"), ..pl)
    connect("s", "b", ..lk)
    node(along("s", "b", t: 50%), [0.4], font: font("small"), ..pl)
    connect("s", "c", draw: mix(muted, 50%), line-width: widths.semithick)
    node(along("s", "c", t: 50%), [0.1], font: font("small"), ..pl)
    node((6.2, 1.65), [late], name: "a1", font: font("small"), ..wd)
    node((6.2, 0.9), [full], name: "a2", font: font("small"), ..wd)
    node((6.2, 0.15), [here], name: "a3", font: font("small"), ..wd)
    connect("a", "a1", draw: mix(muted, 50%), line-width: widths.semithick)
    node(along("a", "a1", t: 50%), [0.45], font: font("small"), ..pl)
    connect("a", "a2", draw: mix(muted, 50%), line-width: widths.semithick)
    node(along("a", "a2", t: 50%), [0.35], font: font("small"), ..pl)
    connect("a", "a3", draw: mix(muted, 50%), line-width: widths.semithick)
    node(along("a", "a3", t: 50%), [0.20], font: font("small"), ..pl)
    node((6.2, -0.6), [cancelled], name: "b1", font: font("small"), ..wk, fill: mix(green, 30%))
    node((6.2, -1.3), [late], name: "b2", font: font("small"), ..wd)
    connect("b", "b1", ..lk, line-width: 1.1955pt)
    node(along("b", "b1", t: 50%), [0.80], font: font("small"), ..pl)
    connect("b", "b2", draw: mix(muted, 50%), line-width: widths.semithick)
    node(along("b", "b2", t: 50%), [0.15], font: font("small"), ..pl)
    node((7.1, 1.65), [0.225: width 1 stops here], font: font("script", fill: muted), anchor: "west")
    node((7.1, 0.9), [0.175], font: font("script", fill: muted), anchor: "west")
    node((7.1, 0.15), [0.100], font: font("script", fill: muted), anchor: "west")
    node((7.1, -0.6), [0.320: width 2 finds this], font: font("script", weight: "bold", fill: mix(green, 80%, other: black)), anchor: "west")
    node((7.1, -1.3), [0.060], font: font("script", fill: muted), anchor: "west")
  })
]

#term[Beam search] fixes this by keeping the best $k$ options. At every step it grows every option it is holding, scores them all, keeps the best $k$ and drops the rest. The number $k$ is the #term[beam width], and $k=1$ is hill climbing.

#lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/demo_local_search.py", first: 136, last: 144, lang: "python")

Real systems use exactly this idea. Machine translation systems choose each translated sentence by beam search, typically keeping a small handful of options at a time. A wider beam buys a slightly better sentence for more work, because every option you keep is one more to grow at every word. Once beam search drops an option, though, it never goes back, so it is not complete.

== The local search scorecard

Here are the three board searches side by side, on the same 1,000 random boards. All three keep just one board between moves.

#utptable[
  #tabularx(
    columns: (24%, 17%, 20%, 1fr),
    align: (left, center, center, left),
    styles: (navy-bold,),
    header: ([Search, eight queens], [Boards solved], [Looked at per solve], [Note]),
    [Hill climbing], [150 of 1,000], [1,555], [Stuck on the other 850],
    [Random restarts], [1,000 of 1,000], [1,713], [7.3 climbs on average],
    [Simulated annealing], [990 of 1,000], [1,107], [Can run out of temperature first],
  )
]

Read the third column with care. It divides all the work done by the boards actually solved, so plain hill climbing looks oddly close to the others. It only looks that way: hill climbing fails 85 % of the time, and one more climb on a failed board is exactly what random restarts adds.

#note[
  When only the answer matters, keep one board and keep making it better. When it gets stuck, restart it, or take a worse step on purpose while it is still warm. When one option is too few, keep several.
]

#summary[
  - Local search keeps candidates rather than routes, so it uses very little memory and suits problems judged only by the final answer.
  - Hill climbing always takes the best neighbour and stops when none is better, which traps it on local maxima.
  - Random restarts escape by starting over. Simulated annealing escapes by accepting worse moves with probability $e^(- Delta \/T)$ while it cools.
  - Beam search keeps the best $k$ options at each step, because the option that looks second best now can turn out best later.
]

#exercises[
  Run `python all_experiments/demo_local_search.py` from the course folder; it takes about a minute. Then, in a copy of the file, change `cooling=0.999` to `0.99`. The search now cools about ten times faster. Predict what happens to the number of boards solved and to the work per solve before you run it, and explain the result using #figref(<fig:annealing>).

  #emph[What to expect.] Boards solved falls from about 990 to about 490, because the search freezes before it has wandered enough. Work per solved board also falls, from about 1,100 to about 720, because a fast-cooling run gives up early. Speed has been bought with reliability.
]

#questions[
  + Why does a Sudoku not need the path-cost piece of a search problem?
  + How many neighbours does an eight-queens board have, and how does hill climbing use them?
  + What is a local maximum on the eight-queens puzzle, in terms of attacking pairs?
  + At temperature $T=0.5$, what is the chance of accepting a move that adds one attack?
  + Explain why beam search with $k=1$ cannot find “the flight was cancelled”.
]
