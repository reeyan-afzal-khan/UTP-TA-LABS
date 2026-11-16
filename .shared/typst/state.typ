// Book settings and the markers the contents page, running heads and the
// publishing script read. Kept apart so every other module can import it.

// Everything a course sets in main.typ. Each key names the LaTeX macro it replaces.
#let defaults = (
  title: [Course Notes],                        // \utpcoursetitle
  running-head: none,                           // \utprunninghead (Course Notes when unset)
  subtitle: [Teaching Assistant Guide],         // \utpdocumentsubtitle
  outline: [],                                  // \utpcourseoutline
  outline-heading: [COURSE OUTLINE],            // \utpoutlineheading
  author: [Reeyan Afzal Khan],                  // \utpauthor
  author-role: [Graduate Research Assistant],   // \utpauthorrole
  chapter-label: [CHAPTER],                     // \utpchapterlabel
  lab-total: 10,                                // \utplabtotal
  chapter-toc-word: [Chapter],                  // \utpchaptertocword
  chapter-toc-indent: 1.5em,                    // \utpchaptertocindent
  chapter-toc-numwidth: 6em,                    // \utpchaptertocnumwidth
  mono: "Source Code Pro",                      // \utpmonofont
  // \utpcontentspage{size}{part size}{before a part}{before a chapter}{before a lab}
  contents: (size: "normal", part-size: "large", part: 1.15em, chapter: 0.38em, lab: 0.30em),
  listing: "text",                              // \lstset{style=...}, as a fence language
  diagram-size: (1.0, 0.8),                     // \utpdiagramsize, in cm
  keep-headings: none,                          // \utpkeepheadings{section}{subsection}
  titles: (:),                                  // relabel a callout or element: (note: [Remember])
  routine-intro: [For each question, do four things in order:],
  routine-compare: [Check your output against the reference output.],
)

#let config = state("utp-config", defaults)
#let cfg(key) = config.get().at(key)

#let lecture-export = sys.inputs.at("lecture", default: "false") == "true"

// The start of a chapter, lab or appendix file, for splitting the PDF.
#let unit(kind, slug) = if not lecture-export {
  context [#metadata((kind: kind, slug: slug, page: here().page())) <unit>]
}

// An entry on the Learning Path page, a running-head mark, and the page
// styles LaTeX called plain (number only) and empty (nothing).
#let toc-entry(kind, title, number: none) = [#metadata((kind: kind, title: title, number: number))<utp-toc>]
#let mark(body) = [#metadata(body)<utp-mark>]
#let plain-page = [#metadata("plain")<utp-plain>]
#let empty-page = [#metadata("empty")<utp-empty>]

// A heading that only feeds the PDF bookmarks; the page shows something else.
#let bookmark(level, body, label: none) = {
  let h = heading(level: level, numbering: none, outlined: false, body)
  place(top, hide(if label == none { h } else { [#h#label] }))
}
