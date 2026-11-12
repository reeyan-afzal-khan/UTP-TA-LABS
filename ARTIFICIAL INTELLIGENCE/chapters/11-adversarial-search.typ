#import "/.shared/typst/utp.typ": *
#import "robot-maze-figures.typ": *
#unit("chapters", "11-adversarial-search")

= Adversarial Search: When Someone Fights Back <ch:games>

#chapterguide[Know the search loop and DFS from #chapref(<ch:uninformed>), and the idea of a heuristic from #chapref(<ch:informed>).][draw a game tree and pass scores up it by minimax; explain why a program must assume its opponent’s best reply; say what alpha-beta pruning saves; explain what an evaluation function trades away; describe the four steps of Monte Carlo Tree Search; and place every search in this book on one cheat sheet.]

So far the robot has played alone. A maze wall does not move to block you, so once a route is found you can simply drive it. Now the robot plays noughts and crosses against a person, and the person is trying to win. This is the last of the five questions from #chapref(<ch:uninformed>): #emph[what if someone fights back?]

It is still a search, with one twist: every other pick belongs to your opponent. A search with an opponent is called #term[adversarial search]. It is the idea behind the chess and Go results that opened #chapref(<ch:uninformed>). This chapter has no lab, and every number in it is printed by `all_experiments/demo_game_search.py`, which needs no dataset and finishes in about a second.

== Playing out every future

The robot plays X and its opponent plays O. When a game ends, it gets a score: $+1$ if X wins, $-1$ if O wins, and $0$ for a draw. X wants the score as high as possible, so we call X the #term[Max] player. O wants it as low as possible, so O is the #term[Min] player.

Here is a game halfway through, with X to move and three squares empty: top left, top right and centre (#figref(<fig:game-tree>)). To choose, the robot plays out every possible future. That picture is a #term[game tree]: a search tree whose levels take turns.

#utpfig([Every future from the halfway board. Levels alternate: X moves, then O, then X. Scores on the leaves are for X. Passing them up, O takes the smallest and X the largest. Only the top-right move is worth $+1$, because it makes two lines X can finish and O can block only one.], label: <fig:game-tree>)[
  #canvas({
    let val = (shape: "circle", inner-sep: 0.6974pt, min-size: 0.46, font: font("script", weight: "bold", fill: white))
    let vwin = (..val, fill: green)
    let vdraw = (..val, fill: muted)
    let tline = (line-width: widths.semithick, draw: mix(teal, 70%))
    let lvl = (..utplabel, anchor: "east", font: font("script", weight: "bold", fill: navy), align: right)
    tttboard((5.6, 0), ("", "X", "", "O", "", "X", "X", "O", "O"), white)
    node((6.72, -0.42), [+1], font: font("small"), ..vwin)
    tttboard((1, -2), ("X", "X", "", "O", "", "X", "X", "O", "O"), white)
    tttboard((5.6, -2), ("", "X", "X", "O", "", "X", "X", "O", "O"), pale-teal)
    tttboard((10.2, -2), ("", "X", "", "O", "X", "X", "X", "O", "O"), white)
    node((2.12, -2.42), [0], font: font("small"), ..vdraw)
    node((6.72, -2.42), [+1], font: font("small"), ..vwin)
    node((11.32, -2.42), [0], font: font("small"), ..vdraw)
    node((1.405, -2.84), [top left], font: font("small"), ..utplabel, anchor: "north")
    node((6.005, -2.84), [top right], font: font("small"), ..utplabel, anchor: "north")
    node((10.605, -2.84), [centre], font: font("small"), ..utplabel, anchor: "north")
    connect((6.005, -0.82), (1.405, -2), ..tline)
    connect((6.005, -0.82), (6.005, -2), ..tline, line-width: 1.4944pt, draw: green)
    connect((6.005, -0.82), (10.605, -2), ..tline)
    tttboard((0, -4.15), ("X", "X", "O", "O", "", "X", "X", "O", "O"), white)
    tttboard((1.85, -4.15), ("X", "X", "", "O", "O", "X", "X", "O", "O"), white)
    node((1.12, -4.45), [0], font: font("small"), ..vdraw)
    node((2.97, -4.45), [+1], font: font("small"), ..vwin)
    tttboard((4.7, -4.15), ("O", "X", "X", "O", "", "X", "X", "O", "O"), white)
    tttboard((6.55, -4.15), ("", "X", "X", "O", "O", "X", "X", "O", "O"), white)
    node((5.82, -4.45), [+1], font: font("small"), ..vwin)
    node((7.67, -4.45), [+1], font: font("small"), ..vwin)
    tttboard((9.3, -4.15), ("O", "X", "", "O", "X", "X", "X", "O", "O"), white)
    tttboard((11.15, -4.15), ("", "X", "O", "O", "X", "X", "X", "O", "O"), white)
    node((10.42, -4.45), [+1], font: font("small"), ..vwin)
    node((12.27, -4.45), [0], font: font("small"), ..vdraw)
    for (a, b) in ((1.405, 0.405), (1.405, 2.255), (6.005, 5.105), (6.005, 6.955), (10.605, 9.705), (10.605, 11.555)) {
      connect((a, -3.14), (b, -4.15), ..tline)
    }
    for (x, t) in ((0.405, "draw"), (2.255, "X wins"), (5.105, "X wins"), (6.955, "X wins"), (9.705, "X wins"), (11.555, "draw")) {
      node((x, -4.98), [#t], font: font("small"), ..utplabel, anchor: "north")
    }
    node((-0.15, -0.4), [X (Max) \
  takes the largest], font: font("small"), ..lvl)
    node((-0.15, -2.4), [O (Min) \
  takes the smallest], font: font("small"), ..lvl)
    node((-0.15, -4.55), [X’s last move \
  is forced], font: font("small"), ..lvl)
  })
]

Now the tempting mistake. There is a $+1$ under the top-left move, so why not play it? Because a maze wall is not trying to stop you, and O is. If X takes the top left, O simply blocks at the top right and the game is drawn. The $+1$ only exists if O makes a mistake, and a robot cannot plan on mistakes. It has to assume O makes its best reply.

== Minimax

So pass the scores up the tree. On O’s level, O picks the reply that is worst for X, the smallest number. Under the top-left move O picks the 0. Under the centre, the same. But under the top-right move #emph[both] of O’s replies lose, because X now has two lines to finish and O can block only one. On X’s level, X takes the largest number, so X plays the top right and wins on its next move.

That is #term[minimax]: score every move by what happens after your opponent’s best reply. In code, the passing up happens by itself through recursion.

#lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/demo_game_search.py", first: 53, last: 60, lang: "python")

Like DFS, this plays one line all the way to the end of the game before backing up to try the next, so it needs little memory: only the moves along the game it is currently imagining. And how good is the robot? Against an opponent moving at random, over 2,000 games it wins 1,746, draws 254 and loses none. When two minimax robots play each other the game is always drawn. From the empty board, minimax visits 549,946 positions and returns 0, which proves that with perfect play noughts and crosses is a draw.

#analogy[
  A careful chess player thinks “if I do this, the best they can do is that, and then the best I can do is this”. Minimax is that sentence as an algorithm. Hoping your opponent will blunder is the beginner’s version, and it is the error the top-left move in #figref(<fig:game-tree>) tempts you into.
]

=== Alpha-beta: skipping futures that cannot matter

Minimax looks at everything, and much of that is wasted. Suppose you have already found a move worth $+1$. While examining another move you discover that the opponent has a reply worth $-1$. You do not need to look at that opponent’s other replies, because you already know you will not choose this move. #term[Alpha-beta pruning] tracks those two bounds and stops examining a move as soon as it cannot change the answer. The result is the same, and the work is far less: on the empty board 18,297 positions instead of 549,946, or 3.3 % of the work.

== When the tree is too big: guess and stop

Chess is far bigger. In 1950 Claude Shannon, the father of information theory, estimated that a chess program would face about $10^120$ possible games. No computer could ever play them all out. So a chess program looks a few moves ahead, stops, and gives each board a score with a guess. That guess is an #term[evaluation function], a heuristic for games. For chess the simplest guess adds up piece values: pawn 1, knight or bishop 3, rook 5, queen 9.

What does trusting a guess cost? Test it on our small game. A second robot gets a simple guess, the lines X could still finish minus the lines O could still finish, and looks only two moves ahead. It looks at about 142 positions per game, whereas full search visits 549,945 positions for its opening move alone. Over 200 games the full-search robot wins 34, draws 166 and loses none. The guess is far cheaper, and it costs games.

#pitfall[
  A robot that stops early is only as smart as its guess, exactly as A$""^(star.op)$ with a bad heuristic can only do so much. A good evaluation function took chess programmers decades to develop, and building one requires knowing the game.
]

#libnote[
  Deep Blue beat Garry Kasparov in 1997 by doing exactly this: a fast version of minimax with pruning, a rich evaluation function, and special hardware examining around 200 million positions a second. Its strength came largely from raw search rather than from human-style understanding of chess, a point that Rich Sutton draws out in his 2019 essay #emph[The Bitter Lesson].
]

== Monte Carlo Tree Search

Go is much harder than chess. A chess player has about 35 moves to choose from each turn, while a Go player has about 250, and it is notoriously difficult to score a Go board by hand. So how do you search a tree that wide when you cannot even write an evaluation function?

Play lots of random games and count who wins. Judging a position by averaging random games is called a #term[Monte Carlo] method. On our halfway board, play 100 games to the end after each of X’s three moves, with both sides moving at random. After the top right, X wins all 100. After the top left it wins 57, and after the centre 49. Those last two are really draws, and they score well only because random opponents make mistakes, but the votes still point at the right move with no evaluation function at all.

Spending the same number of games on every move is wasteful, though, and with 250 moves each turn it adds up quickly. #term[Monte Carlo Tree Search] (MCTS) spends its games more wisely by growing a tree as it plays (#figref(<fig:mcts>)).

#utpfig([One game of MCTS. Walk down the tree, mostly towards moves that have won so far; add one new move; play a random game from there; and pass the result back up. After many games, play the move that was visited most.], label: <fig:mcts>)[
  #canvas({
    let n = (shape: "circle", draw: blue, fill: pale-blue, min-size: 0.54, inner-sep: 0pt)
    let hot = (..n, draw: orange, fill: pale-orange, line-width: 0.9963pt)
    let new = (..n, draw: green, fill: pale-teal, line-width: 0.9963pt)
    let l = (line-width: widths.semithick, draw: mix(muted, 70%))
    let lh = (line-width: 1.2951pt, draw: orange)
    let ttl = (font: font("script", weight: "bold", fill: navy), align: center)
    draw.scope({
      node((0, 0.62), [1\. Selection \
  walk down], font: font("small"), ..ttl)
      node((0, 0), [], name: "a", font: font("small"), ..hot)
      node((-0.65, -0.85), [], name: "b", font: font("small"), ..n)
      node((0.65, -0.85), [], name: "c", font: font("small"), ..n)
      node((0.15, -1.7), [], name: "d", font: font("small"), ..n)
      connect("a", "b", ..l)
      connect("a", "c", ..l)
      connect("c", "d", ..l)
      node((0.65, -0.85), [], font: font("small"), ..hot)
      node((0.15, -1.7), [], font: font("small"), ..hot)
      connect((0, -0.27), (0.5, -0.63), ..lh)
      connect((0.55, -1.09), (0.27, -1.47), ..lh)
    })
    draw.scope({
      draw.translate((3.65, 0))
      node((0, 0.62), [2\. Expansion \
  add one move], font: font("small"), ..ttl)
      node((0, 0), [], name: "a", font: font("small"), ..n)
      node((-0.65, -0.85), [], name: "b", font: font("small"), ..n)
      node((0.65, -0.85), [], name: "c", font: font("small"), ..n)
      node((0.15, -1.7), [], name: "d", font: font("small"), ..n)
      connect("a", "b", ..l)
      connect("a", "c", ..l)
      connect("c", "d", ..l)
      node((-0.25, -2.55), [], name: "e", font: font("small"), ..new)
      connect("d", "e", ..l)
    })
    draw.scope({
      draw.translate((7.3, 0))
      node((0, 0.62), [3\. Simulation \
  a random game], font: font("small"), ..ttl)
      node((0, 0), [], name: "a", font: font("small"), ..n)
      node((-0.65, -0.85), [], name: "b", font: font("small"), ..n)
      node((0.65, -0.85), [], name: "c", font: font("small"), ..n)
      node((0.15, -1.7), [], name: "d", font: font("small"), ..n)
      connect("a", "b", ..l)
      connect("a", "c", ..l)
      connect("c", "d", ..l)
      node((-0.25, -2.55), [], name: "e", font: font("small"), ..new)
      connect("d", "e", ..l)
      snake("e.south", (rel: (0.1, -0.72), to: "e.south"), amplitude: 1.0959pt, segment-length: 4.9813pt, draw: orange, line-width: widths.thick)
      node((0, -3.2), [X wins], font: font("script", weight: "bold", fill: mix(orange, 85%, other: black)), anchor: "west")
    })
    draw.scope({
      draw.translate((10.95, 0))
      node((0, 0.62), [4\. Backup \
  pass it back up], font: font("small"), ..ttl)
      node((0, 0), [], name: "a", font: font("small"), ..n)
      node((-0.65, -0.85), [], name: "b", font: font("small"), ..n)
      node((0.65, -0.85), [], name: "c", font: font("small"), ..n)
      node((0.15, -1.7), [], name: "d", font: font("small"), ..n)
      connect("a", "b", ..l)
      connect("a", "c", ..l)
      connect("c", "d", ..l)
      node((-0.25, -2.55), [], name: "e", font: font("small"), ..new)
      connect("d", "e", ..l)
      connect((-0.05, -2.3), (0.08, -1.97), draw: green, line-width: widths.thick, end: tip("Stealth", length: 1.8mm, line: widths.thick))
      connect((0.28, -1.47), (0.53, -1.09), draw: green, line-width: widths.thick, end: tip("Stealth", length: 1.8mm, line: widths.thick))
      connect((0.5, -0.63), (0.13, -0.25), draw: green, line-width: widths.thick, end: tip("Stealth", length: 1.8mm, line: widths.thick))
      node((0.55, -1.65), [+1 win], font: font("script", fill: mix(green, 80%, other: black)), anchor: "west")
    })
  })
]

Each game starts at the top and walks down. Mostly it heads for the moves that have won the most so far for whoever’s turn it is, which is called #term[exploitation]. On the opponent’s turns that means the opponent’s best replies, so the more it plays, the less it counts on mistakes. Now and then it tries a move it has barely tried, which is called #term[exploration]. When the walk reaches a move never tried, MCTS adds it to the tree, plays one random game from there, and adds the result to every move on the way back up.

#analogy[
  Think of choosing a restaurant in a new town. You mostly return to the places that have been good, but you try somewhere new now and then in case it is better. Too much of the first and you may never find the best place. Too much of the second and you keep eating badly.
]

On our halfway board, 300 games of MCTS give the top right 284 visits and the other two moves 8 each, instead of 100 each as before. MCTS then plays the move it visited most.

#libnote[
  AlphaGo beat Lee Sedol four games to one in 2016 using this kind of search, steered by neural networks that had learned where to look: a policy network suggested promising moves and a value network guessed who was winning. It was still a search. Sutton’s essay argues that search and learning are the two methods that keep getting better the more computing power you give them.
]

== One loop, one cheat sheet

These searches began as separate names with no lines between them. Here is the sheet that holds them all. Each one fills the to-do list and chooses from it in its own way, and in every case the question is the same: what do we look at next?

#utptable[
  #tabularx(
    columns: (21%, 33%, 1fr, 1fr),
    styles: (navy-bold,),
    header: ([Search], [What it looks at next], [Strength], [Weakness]),
    [BFS], [Oldest on the list], [Fewest steps, guaranteed], [Explores nearly everything],
    [DFS], [Newest on the list], [Can be quick, little memory], [Route may be poor; order dependent],
    [Bidirectional], [Oldest, from both ends], [Skips the big outer rings], [Needs one known goal],
    [UCS (Dijkstra)], [Least cost so far, $g$], [Cheapest route, guaranteed], [Blind to direction],
    [Greedy best-first], [Smallest guess, $h$], [Very little work], [Route may be poor],
    [A$""^(star.op)$], [Smallest $g+h$], [Cheapest route with far less work], [Needs a guess that never overestimates],
    [Hill climbing], [The best neighbour], [One board in memory], [Stuck on local maxima],
    [Simulated annealing], [A random neighbour, maybe worse], [Escapes local maxima], [Depends on the cooling schedule],
    [Beam search], [The best $k$ options], [Keeps options open], [Never returns to what it dropped],
    [Genetic algorithm], [Children of fit parents], [Combines good parts], [Often more work than simpler methods],
    [Minimax], [Every reply, assuming the best one], [Best play against a perfect opponent], [Tree too large for big games],
    [Evaluation function], [The tree only so deep, then a guess], [Scales to chess], [Only as good as the guess],
    [MCTS], [Moves that keep winning, plus a few new], [Needs no handwritten guess], [Random games can mislead],
  )
]

#tryit[
  Run `python all_experiments/demo_game_search.py` from the course folder and find each number from this chapter. Then choose a different halfway board by editing `HALFWAY`, keeping X to move, and draw its game tree by hand before running the code. Do your minimax values match? Remove the final `assert` first, because it checks the book’s board.
]

#chapterrecap[
  - With an opponent, a found route is not enough, because the opponent gets to move too. Assume the best reply.
  - Minimax passes scores up the game tree, taking the smallest on the opponent’s level and the largest on yours. Alpha-beta skips moves that cannot change the answer.
  - When the tree is too large, stop early and trust an evaluation function. The robot is then only as good as its guess.
  - MCTS needs no guess at all: it lets random games vote and spends more of them on what keeps winning.
  - Every search in this book is one loop with its own answer to one question: what do we look at next?
]

#quickcheck[
  + In #figref(<fig:game-tree>), why is the top-left move worth 0 even though a $+1$ sits below it?
  + What does alpha-beta pruning change about minimax’s answer, and what does it change about its work?
  + Which earlier idea in this book is an evaluation function closest to?
  + Why does flat Monte Carlo rate the centre move at 49 wins in 100 when minimax says it only draws?
  + In MCTS, what is the difference between exploitation and exploration?
]
