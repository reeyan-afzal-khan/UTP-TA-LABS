#import "/.shared/typst/utp.typ": *
#unit("chapters", "11-adversarial-search")


#heading(level: 1)[Adversarial Search: When Someone Fights Back]
 <ch:games>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Know the search loop and DFS from #ref(label("ch:uninformed"), supplement: [Chapter]), and the idea of a heuristic from #ref(label("ch:informed"), supplement: [Chapter]).

*By the end, you can:* draw a game tree and pass scores up it by minimax; explain why a program must assume its opponent's best reply; say what alpha-beta pruning saves; explain what an evaluation function trades away; describe the four steps of Monte Carlo Tree Search; and place every search in this book on one cheat sheet.]

So far the robot has played alone. A maze wall does not move to block you, so once a route is found you can simply drive it. Now the robot plays noughts and crosses against a person, and the person is trying to win. This is the last of the five questions from #ref(label("ch:uninformed"), supplement: [Chapter]): #emph[what if someone fights back?]

It is still a search, with one twist: every other pick belongs to your opponent. A search with an opponent is called #strong[adversarial search]. It is the idea behind the chess and Go results that opened #ref(label("ch:uninformed"), supplement: [Chapter]). This chapter has no lab, and every number in it is printed by `all_experiments/demo_game_search.py`, which needs no dataset and finishes in about a second.


#heading(level: 2)[Playing out every future]


The robot plays X and its opponent plays O. When a game ends, it gets a score: $+ 1$ if X wins, $- 1$ if O wins, and $0$ for a draw. X wants the score as high as possible, so we call X the #strong[Max] player. O wants it as low as possible, so O is the #strong[Min] player.

Here is a game halfway through, with X to move and three squares empty: top left, top right and centre (#ref(label("fig:game-tree"), supplement: [Figure])). To choose, the robot plays out every possible future. That picture is a #strong[game tree]: a search tree whose levels take turns.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ARTIFICIAL INTELLIGENCE/figures/diagrams/994af2d476a27cca.svg")], caption: [Every future from the halfway board. Levels alternate: X moves, then O, then X. Scores on the leaves are for X. Passing them up, O takes the smallest and X the largest. Only the top-right move is worth $+ 1$, because it makes two lines X can finish and O can block only one.]) <fig:game-tree>

Now the tempting mistake. There is a $+ 1$ under the top-left move, so why not play it? Because a maze wall is not trying to stop you, and O is. If X takes the top left, O simply blocks at the top right and the game is drawn. The $+ 1$ only exists if O makes a mistake, and a robot cannot plan on mistakes. It has to assume O makes its best reply.


#heading(level: 2)[Minimax]


So pass the scores up the tree. On O's level, O picks the reply that is worst for X, the smallest number. Under the top-left move O picks the 0. Under the centre, the same. But under the top-right move #emph[both] of O's replies lose, because X now has two lines to finish and O can block only one. On X's level, X takes the largest number, so X plays the top right and wins on its next move.

That is #strong[minimax]: score every move by what happens after your opponent's best reply. In code, the passing up happens by itself through recursion.

#source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/demo_game_search.py", first: 53, last: 60, lang: "python")

Like DFS, this plays one line all the way to the end of the game before backing up to try the next, so it needs little memory: only the moves along the game it is currently imagining. And how good is the robot? Against an opponent moving at random, over 2,000 games it wins 1,746, draws 254 and loses none. When two minimax robots play each other the game is always drawn. From the empty board, minimax visits 549,946 positions and returns 0, which proves that with perfect play noughts and crosses is a draw.

#callout("analogy", title: [Analogy])[A careful chess player thinks "if I do this, the best they can do is that, and then the best I can do is this". Minimax is that sentence as an algorithm. Hoping your opponent will blunder is the beginner's version, and it is the error the top-left move in #ref(label("fig:game-tree"), supplement: [Figure]) tempts you into.]


#heading(level: 3)[Alpha-beta: skipping futures that cannot matter]


Minimax looks at everything, and much of that is wasted. Suppose you have already found a move worth $+ 1$. While examining another move you discover that the opponent has a reply worth $- 1$. You do not need to look at that opponent's other replies, because you already know you will not choose this move. #strong[Alpha-beta pruning] tracks those two bounds and stops examining a move as soon as it cannot change the answer. The result is the same, and the work is far less: on the empty board 18,297 positions instead of 549,946, or 3.3 % of the work.


#heading(level: 2)[When the tree is too big: guess and stop]


Chess is far bigger. In 1950 Claude Shannon, the father of information theory, estimated that a chess program would face about $10^120$ possible games. No computer could ever play them all out. So a chess program looks a few moves ahead, stops, and gives each board a score with a guess. That guess is an #strong[evaluation function], a heuristic for games. For chess the simplest guess adds up piece values: pawn 1, knight or bishop 3, rook 5, queen 9.

What does trusting a guess cost? Test it on our small game. A second robot gets a simple guess, the lines X could still finish minus the lines O could still finish, and looks only two moves ahead. It looks at about 142 positions per game, whereas full search visits 549,945 positions for its opening move alone. Over 200 games the full-search robot wins 34, draws 166 and loses none. The guess is far cheaper, and it costs games.

#callout("pitfall", title: [Common mistake])[A robot that stops early is only as smart as its guess, exactly as A$""^star.op$ with a bad heuristic can only do so much. A good evaluation function took chess programmers decades to develop, and building one requires knowing the game.]

#callout("libnote", title: [Reference note])[Deep Blue beat Garry Kasparov in 1997 by doing exactly this: a fast version of minimax with pruning, a rich evaluation function, and special hardware examining around 200 million positions a second. Its strength came largely from raw search rather than from human-style understanding of chess, a point that Rich Sutton draws out in his 2019 essay #emph[The Bitter Lesson].]


#heading(level: 2)[Monte Carlo Tree Search]


Go is much harder than chess. A chess player has about 35 moves to choose from each turn, while a Go player has about 250, and it is notoriously difficult to score a Go board by hand. So how do you search a tree that wide when you cannot even write an evaluation function?

Play lots of random games and count who wins. Judging a position by averaging random games is called a #strong[Monte Carlo] method. On our halfway board, play 100 games to the end after each of X's three moves, with both sides moving at random. After the top right, X wins all 100. After the top left it wins 57, and after the centre 49. Those last two are really draws, and they score well only because random opponents make mistakes, but the votes still point at the right move with no evaluation function at all.

Spending the same number of games on every move is wasteful, though, and with 250 moves each turn it adds up quickly. #strong[Monte Carlo Tree Search] (MCTS) spends its games more wisely by growing a tree as it plays (#ref(label("fig:mcts"), supplement: [Figure])).

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ARTIFICIAL INTELLIGENCE/figures/diagrams/2453e3c6ebd84a8a.svg")], caption: [One game of MCTS. Walk down the tree, mostly towards moves that have won so far; add one new move; play a random game from there; and pass the result back up. After many games, play the move that was visited most.]) <fig:mcts>

Each game starts at the top and walks down. Mostly it heads for the moves that have won the most so far for whoever's turn it is, which is called #strong[exploitation]. On the opponent's turns that means the opponent's best replies, so the more it plays, the less it counts on mistakes. Now and then it tries a move it has barely tried, which is called #strong[exploration]. When the walk reaches a move never tried, MCTS adds it to the tree, plays one random game from there, and adds the result to every move on the way back up.

#callout("analogy", title: [Analogy])[Think of choosing a restaurant in a new town. You mostly return to the places that have been good, but you try somewhere new now and then in case it is better. Too much of the first and you may never find the best place. Too much of the second and you keep eating badly.]

On our halfway board, 300 games of MCTS give the top right 284 visits and the other two moves 8 each, instead of 100 each as before. MCTS then plays the move it visited most.

#callout("libnote", title: [Reference note])[AlphaGo beat Lee Sedol four games to one in 2016 using this kind of search, steered by neural networks that had learned where to look: a policy network suggested promising moves and a value network guessed who was winning. It was still a search. Sutton's essay argues that search and learning are the two methods that keep getting better the more computing power you give them.]


#heading(level: 2)[One loop, one cheat sheet]


These searches began as separate names with no lines between them. Here is the sheet that holds them all. Each one fills the to-do list and chooses from it in its own way, and in every case the question is the same: what do we look at next?

#figure(
  align(center)[#table(
    columns: 4,
    align: (left,left,left,left,),
    table.header([Search], [What it looks at next], [Strength], [Weakness],),
    table.hline(),
    [BFS], [Oldest on the list], [Fewest steps, guaranteed], [Explores nearly everything],
    [DFS], [Newest on the list], [Can be quick, little memory], [Route may be poor; order dependent],
    [Bidirectional], [Oldest, from both ends], [Skips the big outer rings], [Needs one known goal],
    [UCS (Dijkstra)], [Least cost so far, $g$], [Cheapest route, guaranteed], [Blind to direction],
    [Greedy best-first], [Smallest guess, $h$], [Very little work], [Route may be poor],
    [A$""^star.op$], [Smallest $g + h$], [Cheapest route with far less work], [Needs a guess that never overestimates],
    [Hill climbing], [The best neighbour], [One board in memory], [Stuck on local maxima],
    [Simulated annealing], [A random neighbour, maybe worse], [Escapes local maxima], [Depends on the cooling schedule],
    [Beam search], [The best $k$ options], [Keeps options open], [Never returns to what it dropped],
    [Genetic algorithm], [Children of fit parents], [Combines good parts], [Often more work than simpler methods],
    [Minimax], [Every reply, assuming the best one], [Best play against a perfect opponent], [Tree too large for big games],
    [Evaluation function], [The tree only so deep, then a guess], [Scales to chess], [Only as good as the guess],
    [MCTS], [Moves that keep winning, plus a few new], [Needs no handwritten guess], [Random games can mislead],
  )]
  , kind: table
  )

#callout("tryit", title: [Practice])[Run `python all_experiments/demo_game_search.py` from the course folder and find each number from this chapter. Then choose a different halfway board by editing `HALFWAY`, keeping X to move, and draw its game tree by hand before running the code. Do your minimax values match? Remove the final `assert` first, because it checks the book's board.]

#callout("chapterrecap", title: [Chapter recap])[- With an opponent, a found route is not enough, because the opponent gets to move too. Assume the best reply.

- Minimax passes scores up the game tree, taking the smallest on the opponent's level and the largest on yours. Alpha-beta skips moves that cannot change the answer.

- When the tree is too large, stop early and trust an evaluation function. The robot is then only as good as its guess.

- MCTS needs no guess at all: it lets random games vote and spends more of them on what keeps winning.

- Every search in this book is one loop with its own answer to one question: what do we look at next?]

#callout("quickcheck", title: [Check your understanding])[+ In #ref(label("fig:game-tree"), supplement: [Figure]), why is the top-left move worth 0 even though a $+ 1$ sits below it?

+ What does alpha-beta pruning change about minimax's answer, and what does it change about its work?

+ Which earlier idea in this book is an evaluation function closest to?

+ Why does flat Monte Carlo rate the centre move at 49 wins in 100 when minimax says it only draws?

+ In MCTS, what is the difference between exploitation and exploration?]
