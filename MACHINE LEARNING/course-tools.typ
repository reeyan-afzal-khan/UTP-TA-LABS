// Course-only helpers for the Machine Learning book.
//
//   #labcode("lab01_features", 7)                  the code cell of Question 7 in that lab's script
//   #codefrom(path, "def walk(", "return path")    lines of a file, from one marker line to another
//   #readcode[ - ... ]                             the "Read the code" notes under a lab listing
//
// Listings are found by what the lines say, never by line number, so a listing cannot go stale
// when its file gains or loses a line.
#import "/.shared/typst/utp.typ": *

#let _lines(path) = read(path).replace("\r\n", "\n").split("\n")

// Blank lines at the end of what is shown are dropped, as the shared listings do.
#let _listing(lines, lang) = {
  let shown = lines
  while shown.len() > 0 and shown.last().trim() == "" { shown = shown.slice(0, -1) }
  raw(shown.join("\n"), lang: lang, block: true)
}

// The code cell of Question n: the lines under "# %% Question n - title" in
// all_experiments/<lab>/<lab>_worked.py, up to the next "# %%" marker.
#let labcode(lab, n, lang: "python") = {
  let lines = _lines("/MACHINE LEARNING/all_experiments/" + lab + "/" + lab + "_worked.py")
  let start = lines.position(l => l.starts-with("# %% Question " + str(n) + " "))
  assert(start != none, message: lab + " has no cell marked Question " + str(n))
  let rest = lines.slice(start + 1)
  let stop = rest.position(l => l.starts-with("# %% "))
  _listing(if stop == none { rest } else { rest.slice(0, stop) }, lang)
}

// Lines of a file from the first line containing `from` to the next line containing `to`.
#let codefrom(path, from, to, lang: "python") = {
  let lines = _lines(path)
  let start = lines.position(l => l.contains(from))
  assert(start != none, message: "no line of " + path + " contains: " + from)
  let stop = lines.slice(start).position(l => l.contains(to))
  assert(stop != none, message: "no later line of " + path + " contains: " + to)
  _listing(lines.slice(start, start + stop + 1), lang)
}

// "Read the code": what the lines of the listing above do, in the order they run.
#let readcode(body) = block(width: 100%, above: par-spacing, below: par-spacing, {
  block(above: 0pt, below: 4pt, sticky: true, text(weight: "bold", fill: navy)[Read the code.])
  set text(size: sizes.small)
  set par(leading: leading-for("small"), justify: false)
  listopts(leftmargin: 1.2em, itemsep: 1.2pt, topsep: 0pt, body)
})
