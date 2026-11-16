// The tutor's study log, the running example of the book, and the drawing
// vocabulary built on it (chapters/study-log-figures.tex in the LaTeX book).
// The numbers are printed and checked by all_experiments/book_checks/demo_study_log.py.
#import "/.shared/typst/utp.typ": *

// \studylog: one row per student.
#let studylog = (
  (name: "A", hours: 2, lectures: 8, sleep: 8, mark: 47, passed: 0, pcone: 0.93, pctwo: -1.78),
  (name: "B", hours: 4, lectures: 6, sleep: 8, mark: 50, passed: 1, pcone: 0.59, pctwo: -1.83),
  (name: "C", hours: 6, lectures: 7, sleep: 7, mark: 59, passed: 1, pcone: 0.69, pctwo: -0.88),
  (name: "D", hours: 8, lectures: 9, sleep: 7, mark: 65, passed: 1, pcone: 1.09, pctwo: -0.08),
  (name: "E", hours: 10, lectures: 11, sleep: 7, mark: 68, passed: 1, pcone: 1.35, pctwo: 0.60),
  (name: "F", hours: 12, lectures: 13, sleep: 6, mark: 77, passed: 1, pcone: 1.60, pctwo: 1.72),
  (name: "G", hours: 14, lectures: 12, sleep: 5, mark: 62, passed: 1, pcone: 0.35, pctwo: 1.33),
  (name: "H", hours: 16, lectures: 10, sleep: 4, mark: 52, passed: 1, pcone: -0.83, pctwo: 0.95),
  (name: "I", hours: 18, lectures: 5, sleep: 3, mark: 43, passed: 0, pcone: -2.41, pctwo: 0.07),
  (name: "J", hours: 20, lectures: 3, sleep: 2, mark: 38, passed: 0, pcone: -3.38, pctwo: -0.10),
)

// logaxis: the axis every chart here starts from.
#let logaxis = (
  axis-lines: "left", grid: "major", grid-style: (draw: pale-blue),
  label-style: font("script", fill: navy), tick-label-style: font("script", fill: muted),
  title-style: font("small", weight: "bold", fill: navy),
  legend-style: (size: sizes.script, draw: mix(blue, 22%), fill: white), legend-cell-align: "left",
)
// logdots: one labelled dot per student.
#let logdots = (
  only-marks: true, mark: "*", mark-size: 1.9pt, draw: blue, fill: blue, nodes-near-coords: true,
  node-style: (font: font("tiny", weight: "bold", fill: navy), anchor: "south", inner-sep: 1.5pt),
)

// Node styles of the study-log figures.
#let recipebox(width: 3.45cm) = (..utpbox, text-width: width, min-height: 1.25)
#let mapgate = (draw: navy, fill: navy, text: white, rounded: 2mm, align: center,
  font: font("small", weight: "bold"), inner-sep: 2.2mm)
#let mapleaf = (draw: blue, fill: pale-blue, rounded: 2mm, align: center, font: font("script", fill: navy),
  text-width: 3.25, min-height: 1.45, inner-sep: 1.5mm)
#let mapleafb = (..mapleaf, draw: orange, fill: pale-orange)
#let hcell = (draw: mix(blue, 55%), fill: white, min-width: 0.62, min-height: 0.62, inner-sep: 0pt,
  font: font("script", fill: navy))
#let hhot = (..hcell, draw: orange, fill: pale-orange, font: font("script", weight: "bold", fill: navy))
#let hkey = (..hcell, draw: teal, fill: pale-teal)

// \recipecard{name}{model}{loss}{optimizer}: the three steps of one method,
// in the same words every time.
#let recipecard(name, model, loss, optimizer) = {
  element-head([The recipe: #name])
  tabularx(
    columns: (17%, 1fr),
    styles: (navy-bold,),
    rules: "none",
    [1. Model], model,
    [2. Loss], loss,
    [3. Optimizer], optimizer,
  )
}
