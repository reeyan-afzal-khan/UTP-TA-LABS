# Typst style guide

Import `/.shared/typst/utp.typ` in content files. The shared palette retains navy `18324A`, blue `246B9E`, teal `138A80`, gold `D4A13E`, and the other teaching accents. The book uses A4, 21 mm margins, Source Sans 3 body text, and Source Code Pro listings.

```typst
#import "/.shared/typst/utp.typ": *
#unit("chapters", "01-introduction")
#heading(level: 1)[Introduction] <ch:introduction>

#callout("keyidea", title: [Key idea])[Explain one central idea.]
#flow([Prepare], [Observe], [Explain], [Verify])
#source-code("/COURSE/all_experiments/example.py", first: 1, last: 20, lang: "python")
```

Use heading levels 1/2/3 for chapters/sections/subsections. Give each reference target one unique label. Put `#unit` before each standalone chapter or lab so publication can find its page boundary. Keep labels stable when renaming headings.

Use `#lab("1")[Title]` for lab banners. Put a `labproject` callout around the activity and use `verification`, `pitfall`, `workedexample`, `tryit` and `labanswer` for their respective teaching roles.

Edit `.shared/typst/cover.typ` for cover geometry and `.shared/typst/palette.typ` for colours. Course cover titles, summaries and book metadata live in each course's `main.typ`. Changing a shared component affects all books; run step 04 and review representative pages before step 05 publishes them.

New diagrams should use the bundled Fletcher functions or `flow`. Keep complex course-specific drawings in the course's `figures/` folder. Do not change vendored drawing algorithms to customize a course.
