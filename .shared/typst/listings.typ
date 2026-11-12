// Code and terminal listings, as style/listings.tex set them: \scriptsize
// Source Code Pro on a pale grey ground, a 0.4pt frame set 5pt outside the
// text, keywords bold blue, comments italic grey and strings dark green.
//
// A fenced block's language picks the LaTeX style:
//   python, r, c, cpp, bash   utppython, utpr, utpc, utpcpp, utpbash
//   text                      utpcode with no language
//   terminal                  utpterminal: commands typed and output printed
// #numbered[...] around a block gives utpcnumbered / utpbashnumbered.
#import "palette.typ": *
#import "theme.typ": *

#let listing-back = mix(pale-gray, 72%)
#let code-frame = mix(blue, 28%)
#let terminal-frame = mix(muted, 35%)
#let terminal-langs = ("terminal", "bash", "sh", "console", "powershell", "bat")
#let numbered-listing = state("utp-numbered-listing", false)

// LaTeX's aboveskip/belowskip, as the gap between the text and the frame.
#let listing-kinds = (
  code: (frame: code-frame, above: 6.65pt, below: 12.21pt),
  terminal: (frame: terminal-frame, above: 5.56pt, below: 11.51pt),
)

// The frame: 5pt outside the text (framesep), so the code lines up with the
// text margin; the first baseline 11.81pt below the top rule.
// A numbered listing indents its text 1.7em and opens the frame 1.4em wider.
#let listing-frame(body, kind: "code", numbered: false, size: 7.01pt) = {
  let k = listing-kinds.at(kind)
  block(width: 100%, breakable: true, above: k.above, below: k.below,
    fill: listing-back, stroke: 0.4pt + k.frame,
    outset: (left: if numbered { 1.9pt } else { 5.18pt }, right: 5.18pt),
    inset: (top: 11.81pt - 0.712 * size, bottom: 8.02pt - 0.2 * size,
      left: if numbered { 18.55pt } else { 0pt }),
    body)
}

// The show rule for fenced code blocks; book() installs it.
#let show-listing(it, mono: "Source Code Pro", scale: 0.88) = context {
  let size = sizes.script * scale
  let kind = if it.lang in terminal-langs { "terminal" } else { "code" }
  let numbered = numbered-listing.get()
  set text(size: size, font: mono)
  set par(justify: false, leading: skips.script - line-box * size)
  show raw.line: line => {
    if numbered {
      box(width: 0pt, align(right, text(size: sizes.tiny, fill: muted)[#line.number#h(7pt)]))
    }
    line.body
  }
  listing-frame(kind: kind, numbered: numbered, size: size, it)
}

// utpcnumbered / utpbashnumbered: the same listing with line numbers.
#let numbered(body) = {
  numbered-listing.update(true)
  body
  numbered-listing.update(false)
}

// \lstinputlisting[firstline=a,lastline=b]{file}: lines a..b of a real file.
#let lstinput(path, first: 1, last: none, lang: "text") = {
  let lines = read(path).replace("\r\n", "\n").split("\n")
  if lines.len() > 0 and lines.last() == "" { lines = lines.slice(0, -1) }
  let stop = if last == none { lines.len() } else { calc.min(last, lines.len()) }
  let shown = lines.slice(first - 1, stop)
  // listings drops blank lines at the end of what it shows (showlines=false)
  while shown.len() > 0 and shown.last().trim() == "" { shown = shown.slice(0, -1) }
  raw(shown.join("\n"), lang: lang, block: true)
}
