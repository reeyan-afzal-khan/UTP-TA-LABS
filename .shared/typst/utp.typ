// The UTP book design. Every chapter and lab file starts with
//   #import "/.shared/typst/utp.typ": *
// and each course's main.typ applies it with  #show: book.with(...).
//
//   palette.typ   colours, including the callout colours
//   theme.typ     sizes and spacing           state.typ     book settings
//   layout.typ    headings, contents, frontmatter
//   callouts.typ  Note, Tip and Warning: the only framed asides
//   elements.typ  unframed teaching elements: chapter guide, example,
//                 exercises, questions, answers, summary, checklist
//   labs.typ      lab banners and lab-sheet structure
//   frames.typ    the frame behind figures, tables and transcripts
//   figures.typ   figure and table frames     tables.typ    the tabularx house style
//   listings.typ  code listings               commands.typ  inline commands
//   cover.typ     the cover                   diagrams.typ  drawings, with CeTZ
//   plots.typ     charts, with CeTZ
#import "palette.typ": *
#import "theme.typ": sizes, skips, fsize, fsize-at, keepspace, em-normal, par-spacing, leading-for, mono-scale
#import "state.typ": unit, config, cfg, lecture-export
#import "layout.typ": book, part, substage, chapter-star, contents, mainmatter
#import "frames.typ": tcb, tcolorbox
#import "callouts.typ": callout, note, tip, warning
#import "elements.typ": chapterguide, example, exercises, questions, answers, summary, checklist, submission, element-head
#import "figures.typ": utpfig, utpfigure, utptable, sourceimage, compactsourceimage, fignote, labvisual, labgraphic, fitted-image
#import "tables.typ": tabularx, th, multicolumn, navy-bold, mono-cell, italic-cell, rule-color
#import "listings.typ": lstinput, numbered
#import "labs.typ": *
#import "commands.typ": *
#import "cover.typ": cover
#import "diagrams.typ": *
#import "plots.typ": axis, addplot, groupplot, nextgroupplot, pgf-num
