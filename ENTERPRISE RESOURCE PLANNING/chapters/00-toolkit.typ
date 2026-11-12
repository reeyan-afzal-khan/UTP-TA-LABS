#import "/.shared/typst/utp.typ": *
#unit("chapters", "00-toolkit")

= Installing Odoo for the Practical Labs <ch:toolkit>

#chapterguide[Install and prepare Odoo 19 Community Edition on your computer for the course.][Install Odoo and its database service, create one course database, add the required apps, and verify the setup for all practicals.]

A local installation runs the Odoo application and its PostgreSQL database on
your computer; you access Odoo through a browser. Install and configure it
once, then use the same instance and database throughout the practicals. If
your instructor provides a hosted environment, use that instead of installing
a local copy.

== Install and configure Odoo

#utpsteps[
  + #strong[Prepare the computer.] Confirm whether it runs Windows or
    macOS, and make sure you can install software. Use Odoo 19 Community
    Edition. If Odoo or PostgreSQL is already installed, check with your
    instructor before changing it or adding another installation.
  + #strong[Choose the matching walkthrough.] Follow one video from
    beginning to end; do not combine steps across operating systems. The
    official Odoo 19 guides for #link("https://www.odoo.com/documentation/19.0/administration/on_premise/packages.html")[packaged]
    and #link("https://www.odoo.com/documentation/19.0/administration/on_premise/source.html")[source installations] provide additional details.

    #tcolorbox(back: white, frame: mix(blue, 55%), title-back: navy, rule: 0.7472pt, arc: 2mm, title: [Follow the installation steps in order], title-color: white, left: 3mm, right: 3mm, top: 2mm, bottom: 2mm)[
      #tabularx(
        columns: (27%, 1fr),
        styles: (navy-bold,),
        column-fill: (mix(pale-blue, 55%), none),
        [Windows], [#strong[#text(fill: blue)[#link("https://www.youtube.com/watch?v=e9ffZ97NoD8\\&t=2048s")[Installing the Odoo Community Version]]]],
        table.hline(stroke: 0.55pt + rule-color),
        [macOS], [#strong[#text(fill: blue)[#link("https://www.youtube.com/watch?v=YEh4CEFCSrM\\&t=1443s")[Installing the Odoo Community Version]]]],
      )
    ]
  + #strong[Complete the installation.] Follow the selected walkthrough
    in order. Odoo requires PostgreSQL; use the database service installed or
    configured by that method, and do not add a second one. Clone Odoo’s `19.0`
    branch. Or skip this: `ODOO-SETUP.md` in the course folder needs no installs.
  + #strong[Start Odoo and check browser access.] Start the required
    services as shown in the video. Open the local address it provides; a
    common address is `http://localhost:8069`. Confirm that the Odoo
    sign-in or database setup page appears.
  + #strong[Create one course database.] Use the name specified by your
    instructor; `west_end_bicycles` is the course example. Configure
    the company country as Malaysia, then create the administrator login. If
    prompted for a separate database-manager master password, keep it distinct
    from the login password.
  + #strong[Install the course apps.] Install or confirm Contacts, CRM,
    Employees, Inventory, Invoicing, Manufacturing, Purchase, and Sales. Set
    up the West End Bicycles company and other shared records as directed in
    the practical materials. Keep using this database so later labs can build
    on earlier work.
  + #strong[Verify the setup.] Confirm that Odoo 19 Community opens in
    your browser, you can sign in, the required apps are available, and your
    records remain after you sign out and back in.
]
