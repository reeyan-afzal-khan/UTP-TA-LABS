// The UTP book design. Every chapter and lab file starts with
//   #import "/.shared/typst/utp.typ": *
// and each course's main.typ applies it with  #show: book.with(...).
//
// One module per LaTeX style file:
//   palette.typ   theme.tex (colours)         theme.typ     sizes and spacing
//   state.typ     configuration.tex           layout.typ    headings, contents, frontmatter
//   boxes.typ     boxes.tex                   figures.typ   figures.tex, labs/visuals.tex
//   tables.typ    the tabularx house style    listings.typ  listings.tex
//   labs.typ      labs/layout.tex, labs/activities.tex
//   commands.typ  commands.tex                cover.typ     cover.tex
//   diagrams.typ  diagrams.tex and diagrams/*.tex, drawn with CeTZ
//   plots.typ     pgfplots charts, drawn with CeTZ
#import "palette.typ": *
#import "theme.typ": sizes, skips, fsize, fsize-at, keepspace, em-normal, par-spacing, leading-for, mono-scale
#import "state.typ": unit, config, cfg, lecture-export
#import "layout.typ": book, part, substage, chapter-star, contents, mainmatter
#import "boxes.typ": *
#import "figures.typ": utpfig, utpfigure, utptable, sourceimage, compactsourceimage, fignote, labvisual, labgraphic, fitted-image
#import "tables.typ": tabularx, th, multicolumn, navy-bold, mono-cell, italic-cell, rule-color
#import "listings.typ": lstinput, numbered
#import "labs.typ": *
#import "commands.typ": *
#import "cover.typ": cover
#import "diagrams.typ": *
#import "plots.typ": axis, addplot, groupplot, nextgroupplot, pgf-num
