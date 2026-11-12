// The robot maze of Chapters 2-4 (chapters/robot-maze-figures.tex in the
// LaTeX book): one drawing vocabulary built from the shared palette and
// node styles, so the figures match the rest of the book. The maze data
// comes from all_experiments/demo_robot_maze.py.
//
//   mazegrid(prefix, rows, size: 0.56)    one maze, cell by cell
//   mazepins(prefix, size: 0.56)          the robot and charger on top
//   mazeroute(prefix, cells, ..style)     a route through named cells
//   mazegraph(prefix, rows, size: 0.56)   the same maze as dots and lines
//   mazelabels(prefix, rows)              numbers again, above a route
//   mazeaxes(prefix)                      row and column numbers
//
// A cell in the rows is one of:
//   "W" wall   "." floor   "P" puddle   "o" expanded   "a", "b" the two ripples
//   "*" where they meet   a number, on a blue tint that deepens as it grows
// Cells are named prefix-row-column, so (5,1) in maze "m" is node "m-5-1".
#import "/.shared/typst/utp.typ": *

// ------------------------------------------------------------------ styles
// The cell styles take the cell size s (centimetres).
#let mzcell(s) = (min-width: s, min-height: s, inner-sep: 0pt, font: font("script", weight: "bold", fill: navy))
#let mzwall(s) = (..mzcell(s), draw: navy, fill: mix(navy, 82%))
#let mzfloor(s) = (..mzcell(s), draw: mix(muted, 35%), fill: white)
#let mzseen(s) = (..mzcell(s), draw: mix(blue, 50%), fill: mix(blue, 24%))
#let mzother(s) = (..mzcell(s), draw: mix(teal, 60%), fill: mix(teal, 26%))
#let mzpuddle(s) = (..mzcell(s), draw: teal, fill: mix(teal, 38%),
  font: font("small", weight: "bold", fill: mix(teal, 60%, other: black)))
#let mzmeet(s) = (..mzcell(s), draw: orange, fill: mix(orange, 45%), line-width: 1pt)
#let mzrobot(s) = (shape: "circle", draw: orange, fill: pale-orange, line-width: 0.9pt, inner-sep: 0pt,
  min-size: 0.84 * s, font: font("script", weight: "bold", fill: navy))
#let mzcharger(s) = (..mzrobot(s), draw: green, fill: pale-teal)
#let mzroute = (line-width: 1.7pt, draw: orange, opacity: 90%)
#let mzroutealt = (..mzroute, draw: green)
#let mzroutebad = (..mzroute, draw: red)
#let mzedge = (draw: mix(blue, 55%), line-width: 0.7pt)
#let mzdot = (shape: "circle", draw: blue, fill: pale-blue, inner-sep: 0pt, min-size: 2.1mm)
#let mztitle = (font: font("small", weight: "bold", fill: navy), align: center)
#let mznote = (font: font("script", fill: muted), align: center)

#let _mzname(prefix, r, c) = prefix + "-" + str(r) + "-" + str(c)

// ------------------------------------------------------------------ drawings
// A numbered cell: a blue tint that deepens by `step` percent per unit.
#let mznumber(prefix, r, c, v, s, step: 5) = node((s * c, -s * r), [#v], name: _mzname(prefix, r, c),
  ..mzcell(s), draw: mix(blue, 45%), fill: mix(blue, (6 + step * v) * 1%))

// One maze, cell by cell. `number` draws the numbered cells (a figure may
// pass its own, as the f map does).
#let mazegrid(prefix, rows, size: 0.56, step: 5, number: auto) = {
  let s = size
  for (r, row) in rows.enumerate() {
    for (c, v) in row.enumerate() {
      let at = (s * c, -s * r)
      let name = _mzname(prefix, r, c)
      if v == "W" { node(at, [], name: name, ..mzwall(s)) }
      else if v == "." { node(at, [], name: name, ..mzfloor(s)) }
      else if v == "P" { node(at, [$approx$], name: name, ..mzpuddle(s)) }
      else if v == "o" or v == "a" { node(at, [], name: name, ..mzseen(s)) }
      else if v == "b" { node(at, [], name: name, ..mzother(s)) }
      else if v == "*" { node(at, [], name: name, ..mzmeet(s)) }
      else if number == auto { mznumber(prefix, r, c, v, s, step: step) }
      else { number(prefix, r, c, v, s) }
    }
  }
}

// Numbers drawn again above a route, on a small pale patch, so a route line
// crossing a numbered cell never hides the number: grid, route, labels, pins.
#let mazelabels(prefix, rows) = {
  for (r, row) in rows.enumerate() {
    for (c, v) in row.enumerate() {
      if v != "W" {
        node(_mzname(prefix, r, c) + ".center", [#v], inner-sep: 0.4pt, fill: white, fill-opacity: 72%,
          rounded: 0.5pt, font: font("script", weight: "bold", fill: navy))
      }
    }
  }
}

// The robot at (5,1) and the charger at (2,9), drawn over whatever is under them.
#let mazepins(prefix, size: 0.56) = {
  node(prefix + "-5-1.center", [R], ..mzrobot(size))
  node(prefix + "-2-9.center", [C], ..mzcharger(size))
}

// Row and column numbers around a 7-by-10 maze.
#let mazeaxes(prefix) = {
  for col in range(10) {
    node((rel: (0, 0.02), to: _mzname(prefix, 0, col) + ".north"), [#col], ..utplabel, anchor: "south")
  }
  for line in range(7) {
    node((rel: (-0.03, 0), to: _mzname(prefix, line, 0) + ".west"), [#line], ..utplabel, anchor: "east")
  }
}

// A route through cells named row-column: mazeroute("m", ((5, 1), (4, 1), (3, 1))).
#let mazeroute(prefix, cells, ..style) = {
  let style = if style.named() == (:) { mzroute } else { style.named() }
  for k in range(1, cells.len()) {
    let (r0, c0) = cells.at(k - 1)
    let (r1, c1) = cells.at(k)
    connect(_mzname(prefix, r0, c0) + ".center", _mzname(prefix, r1, c1) + ".center", ..style)
  }
}

// The state space: one dot per floor cell, one line per pair of adjacent cells.
#let mazegraph(prefix, rows, size: 0.56) = {
  let s = size
  let open(r, c) = r < rows.len() and c < rows.at(r).len() and rows.at(r).at(c) != "W"
  for (r, row) in rows.enumerate() {
    for (c, v) in row.enumerate() {
      if v != "W" { coordinate(_mzname(prefix, r, c), (s * c, -s * r)) }
    }
  }
  for (r, row) in rows.enumerate() {
    for (c, v) in row.enumerate() {
      if v != "W" {
        if open(r, c + 1) { connect(_mzname(prefix, r, c), _mzname(prefix, r, c + 1), ..mzedge) }
        if open(r + 1, c) { connect(_mzname(prefix, r, c), _mzname(prefix, r + 1, c), ..mzedge) }
      }
    }
  }
  for (r, row) in rows.enumerate() {
    for (c, v) in row.enumerate() {
      if v != "W" { node(_mzname(prefix, r, c), [], ..mzdot) }
    }
  }
}

// ------------------------------------------------------------------ the data
// Printed by the demo: the plain maze, then the numbers each search works out.
#let mazedry = (
  (".", ".", ".", ".", ".", ".", ".", ".", ".", "W"),
  (".", ".", "W", "W", "W", ".", "W", "W", ".", "W"),
  (".", ".", "W", "W", "W", ".", "W", ".", ".", "."),
  ("W", ".", ".", ".", ".", ".", ".", ".", ".", "W"),
  (".", ".", "W", "W", "W", ".", "W", ".", ".", "."),
  (".", ".", ".", "W", ".", "W", ".", ".", ".", "W"),
  ("W", ".", ".", ".", ".", ".", ".", ".", ".", "W"),
)
#let mazerain = (
  (".", ".", ".", ".", ".", ".", ".", ".", ".", "W"),
  (".", ".", "W", "W", "W", ".", "W", "W", ".", "W"),
  (".", ".", "W", "W", "W", ".", "W", ".", ".", "."),
  ("W", ".", "P", ".", "P", ".", ".", ".", ".", "W"),
  (".", ".", "W", "W", "W", ".", "W", ".", ".", "."),
  (".", ".", ".", "W", ".", "W", ".", ".", ".", "W"),
  ("W", ".", ".", ".", ".", ".", ".", ".", ".", "W"),
)
// BFS rings: steps from the robot on the dry maze.
#let mazerings = (
  (6, 5, 6, 7, 8, 9, 10, 11, 12, "W"),
  (5, 4, "W", "W", "W", 8, "W", "W", 11, "W"),
  (4, 3, "W", "W", "W", 7, "W", 9, 10, 11),
  ("W", 2, 3, 4, 5, 6, 7, 8, 9, "W"),
  (2, 1, "W", "W", "W", 7, "W", 9, 10, 11),
  (1, 0, 1, "W", 5, "W", 7, 8, 9, "W"),
  ("W", 1, 2, 3, 4, 5, 6, 7, 8, "W"),
)
// Battery spent reaching each cell on the rainy maze (g).
#let mazecost = (
  (6, 5, 6, 7, 8, 9, 10, 11, 12, "W"),
  (5, 4, "W", "W", "W", 10, "W", "W", 13, "W"),
  (4, 3, "W", "W", "W", 11, "W", 11, 12, 13),
  ("W", 2, 7, 8, 13, 12, 11, 10, 11, "W"),
  (2, 1, "W", "W", "W", 13, "W", 9, 10, 11),
  (1, 0, 1, "W", 5, "W", 7, 8, 9, "W"),
  ("W", 1, 2, 3, 4, 5, 6, 7, 8, "W"),
)
// The Manhattan guess (h).
#let mazeguess = (
  (11, 10, 9, 8, 7, 6, 5, 4, 3, "W"),
  (10, 9, "W", "W", "W", 5, "W", "W", 2, "W"),
  (9, 8, "W", "W", "W", 4, "W", 2, 1, 0),
  ("W", 9, 8, 7, 6, 5, 4, 3, 2, "W"),
  (11, 10, "W", "W", "W", 6, "W", 4, 3, 2),
  (12, 11, 10, "W", 8, "W", 6, 5, 4, "W"),
  ("W", 12, 11, 10, 9, 8, 7, 6, 5, "W"),
)
// The best possible f = g + h of each cell on the rainy maze.
#let mazef = (
  (17, 15, 15, 15, 15, 15, 15, 15, 15, "W"),
  (15, 13, "W", "W", "W", 15, "W", "W", 15, "W"),
  (13, 11, "W", "W", "W", 15, "W", 13, 13, 13),
  ("W", 11, 15, 15, 19, 17, 15, 13, 13, "W"),
  (13, 11, "W", "W", "W", 19, "W", 13, 13, 13),
  (13, 11, 11, "W", 13, "W", 13, 13, 13, "W"),
  ("W", 13, 13, 13, 13, 13, 13, 13, 13, "W"),
)
// Cells each search expands.
#let mazebfs = (
  ("o", "o", "o", "o", "o", "o", "o", "o", ".", "W"),
  ("o", "o", "W", "W", "W", "o", "W", "W", "o", "W"),
  ("o", "o", "W", "W", "W", "o", "W", "o", "o", "."),
  ("W", "o", "o", "o", "o", "o", "o", "o", "o", "W"),
  ("o", "o", "W", "W", "W", "o", "W", "o", "o", "."),
  ("o", "o", "o", "W", "o", "W", "o", "o", "o", "W"),
  ("W", "o", "o", "o", "o", "o", "o", "o", "o", "W"),
)
#let mazedfs = (
  (".", "o", "o", "o", "o", "o", "o", "o", "o", "W"),
  (".", "o", "W", "W", "W", ".", "W", "W", "o", "W"),
  (".", "o", "W", "W", "W", ".", "W", ".", "o", "."),
  ("W", "o", ".", ".", ".", ".", ".", ".", ".", "W"),
  (".", "o", "W", "W", "W", ".", "W", ".", ".", "."),
  (".", "o", ".", "W", ".", "W", ".", ".", ".", "W"),
  ("W", ".", ".", ".", ".", ".", ".", ".", ".", "W"),
)
#let mazebidir = (
  ("a", "a", "a", ".", ".", ".", ".", "b", "b", "W"),
  ("a", "a", "W", "W", "W", ".", "W", "W", "b", "W"),
  ("a", "a", "W", "W", "W", ".", "W", "b", "b", "b"),
  ("W", "a", "a", "a", "a", "*", "b", "b", "b", "W"),
  ("a", "a", "W", "W", "W", ".", "W", "b", "b", "b"),
  ("a", "a", "a", "W", "a", "W", ".", ".", "b", "W"),
  ("W", "a", "a", "a", "a", ".", ".", ".", ".", "W"),
)
#let mazeucs = (
  ("o", "o", "o", "o", "o", "o", "o", "o", "o", "W"),
  ("o", "o", "W", "W", "W", "o", "W", "W", "o", "W"),
  ("o", "o", "W", "W", "W", "o", "W", "o", "o", "."),
  ("W", "o", "o", "o", "o", "o", "o", "o", "o", "W"),
  ("o", "o", "W", "W", "W", "o", "W", "o", "o", "o"),
  ("o", "o", "o", "W", "o", "W", "o", "o", "o", "W"),
  ("W", "o", "o", "o", "o", "o", "o", "o", "o", "W"),
)
#let mazegreedy = (
  (".", ".", ".", ".", ".", ".", ".", ".", ".", "W"),
  (".", ".", "W", "W", "W", ".", "W", "W", ".", "W"),
  (".", "o", "W", "W", "W", "o", "W", "o", "o", "."),
  ("W", "o", "o", "o", "o", "o", "o", "o", ".", "W"),
  (".", "o", "W", "W", "W", ".", "W", ".", ".", "."),
  (".", "o", ".", "W", ".", "W", ".", ".", ".", "W"),
  ("W", ".", ".", ".", ".", ".", ".", ".", ".", "W"),
)
#let mazeastar = (
  (".", ".", ".", ".", ".", ".", ".", ".", ".", "W"),
  (".", "o", "W", "W", "W", ".", "W", "W", ".", "W"),
  ("o", "o", "W", "W", "W", ".", "W", "o", "o", "."),
  ("W", "o", ".", ".", ".", ".", ".", "o", "o", "W"),
  ("o", "o", "W", "W", "W", ".", "W", "o", "o", "o"),
  ("o", "o", "o", "W", "o", "W", "o", "o", "o", "W"),
  ("W", "o", "o", "o", "o", "o", "o", "o", "o", "W"),
)
#let mazetriple = (
  (".", ".", ".", ".", ".", ".", ".", ".", ".", "W"),
  (".", "o", "W", "W", "W", ".", "W", "W", ".", "W"),
  ("o", "o", "W", "W", "W", "o", "W", "o", "o", "."),
  ("W", "o", "o", "o", "o", "o", "o", "o", ".", "W"),
  (".", "o", "W", "W", "W", ".", "W", ".", ".", "."),
  (".", "o", "o", "W", ".", "W", ".", ".", ".", "W"),
  ("W", ".", ".", ".", ".", ".", ".", ".", ".", "W"),
)
// The three routes home, as (row, column) cells.
#let routecorridor = ((5, 1), (4, 1), (3, 1), (3, 2), (3, 3), (3, 4), (3, 5), (3, 6), (3, 7), (2, 7), (2, 8), (2, 9))
#let routebottom = ((5, 1), (5, 2), (6, 2), (6, 3), (6, 4), (6, 5), (6, 6), (5, 6), (5, 7), (4, 7), (3, 7),
  (2, 7), (2, 8), (2, 9))
#let routetop = ((5, 1), (4, 1), (3, 1), (2, 1), (1, 1), (0, 1), (0, 2), (0, 3), (0, 4), (0, 5), (0, 6), (0, 7),
  (0, 8), (1, 8), (2, 8), (2, 9))

// ------------------------------------------------------- the game boards
// \tttboard{x,y}{nine squares}{fill} of Chapter 12: a small noughts-and-crosses
// board, drawn at 0.27 scale with its marks.
#let tttboard(at, squares, fill) = draw.scope({
  draw.translate(at)
  draw.scale(0.27)
  rectangle((0, 0), (3, -3), draw: mix(blue, 70%), line-width: widths.thick, fill: fill)
  for k in (1, 2) {
    connect((k, 0), (k, -3), draw: mix(blue, 70%))
    connect((0, -k), (3, -k), draw: mix(blue, 70%))
  }
  for (k, sq) in squares.enumerate() {
    node((calc.rem(k, 3) + 0.5, -calc.quo(k, 3) - 0.5), sq, font: font(0.27 * sizes.Huge, weight: "bold", fill: navy))
  }
})
