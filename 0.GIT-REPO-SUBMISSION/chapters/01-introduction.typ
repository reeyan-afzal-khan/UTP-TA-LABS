#import "/.shared/typst/utp.typ": *
#unit("chapters", "01-introduction")

= Introduction <ch:introduction>

This guide helps you prepare Git and GitHub for coursework. It covers setup, secure access, publishing your project, and submitting updates. Follow the chapters in order, replace examples such as `USERNAME` and `REPOSITORY`, and follow your instructor’s repository requirements.

Git tracks changes on your computer; GitHub hosts an online copy of your project. A commit saves a snapshot of your work, and pushing sends it to GitHub for review.

#heading(depth: 3, numbering: none)[The workflow]

#align(center)[
  #canvas({
    let guideIcon = (shape: "circle", draw: mix(blue, 24%), fill: mix(pale-blue, 38%), line-width: 0.5978pt, min-size: 1.05, inner-sep: 0pt)
    let guideArrow = (draw: mix(teal, 65%), line-width: 0.797pt, end: tip("Stealth", length: 2mm, line: 0.797pt))
    connect((0.55, 0), (4.6, 0), ..guideArrow)
    connect((5.7, 0), (9.75, 0), ..guideArrow)
    node((0, 0), [#fsize("large")[#text(fill: blue)[#fa-solid(0xf019)]]], name: "prepare", ..guideIcon)
    node((5.15, 0), [#fsize("large")[#text(fill: blue)[#fa-solid(0xf084)]]], name: "secure", ..guideIcon)
    node((10.3, 0), [#fsize("large")[#text(fill: blue)[#fa-brand(0xf09b)]]], name: "publish", ..guideIcon)
    node((0, -1.4), [#strong[#text(fill: navy)[01#h(1em)Prepare]] \ #v(1mm)
   #fsize("footnote")[Install Git and set your commit identity]], align: center, text-width: 4.1)
    node((5.15, -1.4), [#strong[#text(fill: navy)[02#h(1em)Connect securely]] \ #v(1mm)
   #fsize("footnote")[Add an SSH key and verify GitHub access]], align: center, text-width: 4.1)
    node((10.3, -1.4), [#strong[#text(fill: navy)[03#h(1em)Publish]] \ #v(1mm)
   #fsize("footnote")[Create a repository, push your project, and submit updates]], align: center, text-width: 4.1)
  })
]

#heading(depth: 3, numbering: none)[What you will learn]

#listopts(leftmargin: 1.5em, itemsep: 0.3em, topsep: 0.2em, marker: [#text(fill: teal)[#fa-check]])[
  - Install Git and configure the name and email recorded in your commits.
  - Create an SSH key, register its public half, and test your connection safely.
  - Initialize a local repository, link it to GitHub, and push the first commit.
  - Check, commit, and push later changes so your submitted work stays current.
]

#heading(depth: 3, numbering: none)[Common mistakes to avoid]

#listopts(leftmargin: 1.5em, itemsep: 0.3em, topsep: 0.2em, marker: [#text(fill: mix(rgb("ff0000"), 70%, other: black))[#fa-times]])[
  - Never add passwords, tokens, API keys, `.env` files, or your private SSH key to a repository.
  - Do not commit until `git status` shows only the files you intend to submit.
  - Deleting a secret in a later commit does not remove it from earlier repository history.
]

#tcolorbox(back: mix(pale-blue, 18%), frame: mix(blue, 20%), rule: 0.4981pt, arc: 2mm, left: 4mm, right: 4mm, top: 3mm, bottom: 3mm)[
  #strong[#text(fill: navy)[Before you begin.]]

  #listopts(leftmargin: 1.7em, itemsep: 0.55em, topsep: 0.55em, parsep: 0.1em)[
    + #strong[Check access.] Sign in to GitHub and confirm that you can access your account.
    + #strong[Install and configure Git.] Follow the installation and commit-identity instructions in Chapter~#ref(<ch:git-ssh-setup>).
    + #strong[Confirm course requirements.] Check your instructor’s repository naming and visibility requirements.
  ]
]
