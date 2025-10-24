// #import "@preview/glossy:0.8.0"
#import "../../glossy-fork/glossy/lib.typ" as glossy
#import "@preview/codly:1.3.0": *

#import "utils.typ": *

#import "assets.typ": *
#import "pm_assets.typ": *

#let project(
  lang: "de",
  authors: (
    (
      name: "Unknown author", // required
      id: "",
      email: "",
    ),
  ),
  title: "Unknown title",
  subtitle: none,
  date: none,
  version: none,
  thesis-compliant: false,
  // Format
  side-margins: (
    left: 3.5cm, // required
    right: 3.5cm, // required
    top: 3.5cm, // required
    bottom: 3.5cm, // required
  ),
  h1-spacing: 0.5em,
  line-spacing: 0.65em,
  font: "Roboto",
  font-size: 11pt,
  hyphenate: false,
  // Color settings
  primary-color: dark-blue,
  secondary-color: blue,
  text-color: dark-grey,
  background-color: light-blue,
  // Cover sheet
  custom-cover-sheet: none,
  cover-sheet: (
    // none
    university: (
      // none
      name: none, // required
      street: none, // required
      city: none, // required
      logo: none,
    ),
    employer: (
      // none
      name: none, // required
      street: none, // required
      city: none, // required
      logo: none,
    ),
    cover-image: none,
    description: none,
    faculty: none,
    programme: none,
    semester: none,
    course: none,
    examiner: none,
    submission-date: none,
  ),
  // Declaration
  custom-declaration: none,
  declaration-on-the-final-thesis: (
    // none
    legal-reference: none, // required
    thesis-name: none, // required
    consent-to-publication-in-the-library: none, // required | true, false
    genitive-of-university: none, // required
  ),
  // Abstract
  abstract: none,
  // Outlines
  depth-toc: 4,
  outlines-indent: 1em,
  show-list-of-figures: false,
  show-list-of-abbreviations: true,
  list-of-abbreviations: (
    (
      key: "", // required
      short: "", // required
      plural: "",
      long: "",
      longplural: "",
      description: none,
      group: "",
    ),
  ),
  show-list-of-formulas: false,
  custom-outlines: (
    // none
    (
      title: none, // required
      custom: none, // required
    ),
  ),
  show-list-of-tables: false,
  show-list-of-todos: false,
  literature-and-bibliography: none,
  list-of-attachements: (
    // none
    (a: none), // required
  ),
  body,
) = context {
  import "@preview/hydra:0.6.0": hydra

  import "dictionary.typ": *
  import "cover_sheet.typ": *
  import "declaration_on_the_final_thesis.typ": *

  // Metadata
  let date-format = if lang == "de" { "[day].[month].[year]" } else {
    "[day]/[month]/[year]"
  }

  set document(
    title: title + if is-not-none-or-empty(version) { " v" + version },
    author: authors.map(a => a.name),
  )

  // Basics
  set page(
    paper: "a4",
    flipped: false,
    margin: side-margins,
  )

  set text(
    lang: lang,
    font: font,
    size: font-size,
    fill: text-color,
  )

  use-dictionary()

  // Must not be nested away so that it applies to the entire body
  show: glossy.init-glossary.with(list-of-abbreviations, term-links: false)
  show: codly-init.with()

  if is-not-none-or-empty(date) == false {
    date = datetime.today().display(date-format)
  }

  // Cover Sheet
  if (
    is-not-none-or-empty(custom-cover-sheet) == false
      and is-not-none-or-empty(cover-sheet)
  ) {
    let cover-sheet-dict-contains-key(key) = {
      return dict-contains-key(dict: cover-sheet, key)
    }

    get-cover-sheet(
      primary-color: primary-color,
      secondary-color: secondary-color,
      text-color: text-color,
      background-color: background-color,
      visualise-content-boxes: (
        flag: false,
        fill: background-color,
        stroke: text-color,
      ),
      university: if cover-sheet-dict-contains-key("university") {
        cover-sheet.university
      },
      employer: if cover-sheet-dict-contains-key("employer") {
        cover-sheet.employer
      },
      cover-image: if cover-sheet-dict-contains-key("cover-image") {
        cover-sheet.cover-image
      },
      date: date,
      version: version,
      title: title,
      subtitle: subtitle,
      description: if cover-sheet-dict-contains-key("description") {
        cover-sheet.description
      },
      authors: authors,
      faculty: if cover-sheet-dict-contains-key("faculty") {
        cover-sheet.faculty
      },
      programme: if cover-sheet-dict-contains-key("programme") {
        cover-sheet.programme
      },
      semester: if cover-sheet-dict-contains-key("semester") {
        cover-sheet.semester
      },
      course: if cover-sheet-dict-contains-key("course") { cover-sheet.course },
      examiner: if cover-sheet-dict-contains-key("examiner") {
        cover-sheet.examiner
      },
      submission-date: if cover-sheet-dict-contains-key("submission-date") {
        cover-sheet.submission-date
      },
    )
  } else {
    custom-cover-sheet
  }
  pagebreak()

  // Content basics
  show heading.where(level: 1): set text(fill: text-color, size: 1.4em)
  show heading.where(level: 1): it => {
    if thesis-compliant {
      // FIXME: Use colbreak instead to support multi-col layouts.
      // Colbreak currently gives broken page numbers and links.
      // See: https://github.com/typst/typst/issues/5471
      pagebreak(weak: true)
    }
    it
    v(h1-spacing)
  }

  set page(
    numbering: "I.",
    header: none,
    // Hide footer containing page number
    footer: none,
  )
  counter(page).update(1)

  set par(
    first-line-indent: 1em,
    spacing: line-spacing,
    leading: line-spacing,
    justify: true,
  )

  set text(
    hyphenate: hyphenate,
  )

  let get-figure-caption(it) = [
    #set align(left)
    #h(1em)
    #box[
      #it.supplement
      #context it.counter.display(it.numbering):
      #text(fill: text-color)[*#it.body*]
    ]
    #v(.25em)
  ]

  show figure.caption.where(kind: image): it => get-figure-caption(it)
  show figure.caption.where(kind: table): it => get-figure-caption(it)

  // Caption above figures like ACM
  set figure.caption(position: top)
  // Booktabs rules
  set table(stroke: none)

  show link: set text(fill: secondary-color.darken(60%))

  // Abstract
  if is-not-none-or-empty(abstract) {
    page()[
      #heading(depth: 1, outlined: false)[ #txt-abstract ]
      #abstract
    ]
  }

  // Table of contents (TOC)
  page()[
    #if is-not-none-or-empty(abstract) == false { counter(page).update(1) }

    #show outline.entry.where(level: 1): it => {
      v(1.5em, weak: true)
      upper(strong(it))
    }

    #outline(
      indent: outlines-indent,
      depth: depth-toc,
    )
  ]

  // List of Figures
  if show-list-of-figures {
    page()[
      #heading(depth: 1, outlined: false)[ #txt-list-of-figures ]

      #simple-outline(
        indent: outlines-indent,
        target: figure.where(kind: image),
      )
    ]
  }

  let todos() = context {
    let elems = query(<todo>)

    if elems.len() == 0 { return }

    heading(depth: 1, outlined: false)[ TODOs ]

    for body in elems {
      text([+ #link(body.location(), body.text)], red)
    }
  }

  if show-list-of-todos { todos() }

  // Reset page counter before body's first page is started but after ending
  // final page of frontmatter
  pagebreak(weak: true)
  counter(page).update(1)

  // Body
  set page(
    numbering: "1",
    header: context {
      set par(spacing: 2 * line-spacing)
      if thesis-compliant {
        text(weight: "bold", size: 8.5pt, fill: text-color)[
          #let h1 = hydra(1, skip-starting: false)

          #let numbered-heading = (
            to-string(h1).split(regex("[.]\s")).at(1, default: none)
          )
          #if numbered-heading != none {
            numbered-heading
          } else {
            h1
          }
          #h(1fr)
          #if here().page-numbering() != none {
            counter(page).display(here().page-numbering())
          }
        ]
        v(-.9em)
        line(length: 100%, stroke: 1.5pt + background-color)
      }
    },
    footer: if thesis-compliant == false [
      #set text(weight: "regular")
      #let size = 11pt

      #context {
        grid(
          columns: (1fr, auto, 1fr),
          align: (left, center, right),
          gutter: size,
          [
            #text(fill: text-color, size: size)[ #date ]
          ],
          [
            #text(fill: primary-color, size: size + 1pt)[ *#title* ] \
            #text(fill: secondary-color, size: size)[ #subtitle ]
          ],
          [
            #text(fill: text-color, size: size)[
              #counter(page).display() / #counter(page).final().last()
            ]
          ],
        )
      }
    ] else [
      // Don't put page number in footer when thesis-compliant
      // (it's already in header)
      // #context {
      //   set align(center)
      //   text(fill: text-color)[ #counter(page).display() ]
      // }
    ],
  )

  set heading(numbering: "1.1.")

  body

  // Literature, bibliography, attachments
  set heading(numbering: none)

  // List of Terms (Glossary or Index)
  if (
    show-list-of-abbreviations and is-not-none-or-empty(list-of-abbreviations)
  ) {
    pagebreak()
    show heading.where(level: 2): set heading(outlined: false)
    glossy.glossary(
      // title: txt-list-of-abbreviations,
      show-all: true,
      sort: true,
      ignore-case: true,
      theme: (
        // Main glossary section
        section: (title, body) => {
          heading(level: 1, title)
          body
        },
        // Group of related terms
        group: (name, index, total, body) => {
          // index = group index, total = total groups
          if name != "" and total > 1 {
            heading(level: 2, name)
          }
          body
        },
        // Individual glossary entry
        entry: (entry, index, total) => layout(size => {
          // index = entry index, total = total entries in group
          let show-dots = true

          let output-base = [
            #strong(entry.short)
            #entry.label // **NOTE:** Label here!
          ]
          let output-single-line = [
            #output-base
            #if entry.long != none [ -- #entry.long ]
          ]

          // The glossy fork provides entry.pages as array of `link`s instead
          // of a context. This allows us to group consecutive pages:
          let backlinks = entry
            .pages // Parse out integer of page number, but remember original `link`
            .map(x => (
              int(x.body.text),
              x,
            ))
            .fold((), (a, b) => {
              // Accumulater is an array of dicts (lo: .., hi: ..) which each
              // store the start and end of a span of consecutive page numbers
              if a == none or a == () {
                return ((lo: b, hi: b),)
              }
              if (
                a.last().at("hi").at(0) + 1 == b.at(0)
              ) {
                // Update hi end of active span
                a.last() = (lo: a.last().at("lo"), hi: b)
              } else {
                // Start new span
                a.push((lo: b, hi: b))
              }
              return a
            })
            .map(x => {
              if (x.at("lo").at(0) == x.at("hi").at(0)) {
                // Show single page number
                x.at("lo").at(1)
              } else [
                // Show low and high page number, seperated by a minus
                #x.at("lo").at(1)-#x.at("hi").at(1)
              ]
            })
            .join(",")
          let fits-in-one-line = (
            measure({
              output-single-line
              backlinks
            }).width
              < size.width
          )

          block(grid(
            columns: (auto, 1fr, auto),
            if fits-in-one-line { output-single-line } else { output-base },
            if show-dots {
              repeat(text(fill: luma(50%))[#h(0.05em) . #h(0.05em)])
            },
            backlinks,
          ))
          if entry.description != none {
            pad(x: 2em)[
              #if not fits-in-one-line and entry.long != none {
                entry.long + "."
                linebreak()
              }
              #emph(entry.description)
            ]
            v(.3em)
          }
        }),
      ),
    )
  }

  // List of Formulas
  if show-list-of-formulas {
    pagebreak()
    set math.equation(
      numbering: if thesis-compliant or show-list-of-formulas { "(1)" } else {
        none
      },
      supplement: [#txt-supplement-formula],
    )

    show math.equation.where(block: true): it => rect(
      width: 100%,
      fill: background-color,
    )[
      #v(0.5em)
      #it
      #v(0.5em)
    ]

    simple-outline(
      title: txt-list-of-formulas,
      indent: outlines-indent,
      target: math.equation.where(block: true),
    )
  }

  // Custom outlines
  if is-not-none-or-empty(custom-outlines) {
    for o in custom-outlines {
      if o.title != none and o.custom != none {
        pagebreak()
        if is-not-none-or-empty(o.title) {
          heading(depth: 1)[ #o.title ]
        }
        o.custom
      }
    }
  }

  // List of Tables
  if show-list-of-tables {
    pagebreak()
    simple-outline(
      title: txt-list-of-tables,
      indent: outlines-indent,
      target: figure.where(kind: table),
    )
  }

  if is-not-none-or-empty(literature-and-bibliography) {
    pagebreak()
    heading(depth: 1, outlined: true)[#txt-literature-and-bibliography]
    literature-and-bibliography
  }

  if (
    is-not-none-or-empty(list-of-attachements)
      and list-of-attachements.at(0).a != none
  ) {
    pagebreak()
    heading(depth: 1, outlined: false)[ #txt-list-of-attachements ]

    v(1.5em)

    let index = 1
    for c in list-of-attachements {
      text()[ #txt-attachement A#index: #c.a ]
      v(1em)
      index = index + 1
    }
  }

  // Declaration
  if is-not-none-or-empty(custom-declaration) {
    page(
      header: "",
      footer: "",
    )[
      #custom-declaration
    ]
  } else if (
    thesis-compliant and is-not-none-or-empty(declaration-on-the-final-thesis)
  ) {
    page(
      header: "",
      footer: "",
    )[
      #get-declaration-on-the-final-thesis(
        lang: lang,
        legal-reference: declaration-on-the-final-thesis.legal-reference,
        thesis-name: declaration-on-the-final-thesis.thesis-name,
        consent-to-publication-in-the-library: declaration-on-the-final-thesis.consent-to-publication-in-the-library,
        genitive-of-university: declaration-on-the-final-thesis.genitive-of-university,
      )
    ]
  }
}
