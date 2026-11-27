#import "@preview/touying:0.8.0": *
#import "@preview/gentle-clues:1.3.1": clue
#import "@preview/mannot:0.4.0": mark, markrect

// Paleta del curso.
#let c-orange = rgb("#D55E00")
#let c-gold = rgb("#E69F00")
#let c-green = rgb("#009E73")
#let c-pink = rgb("#CC79A7")
#let c-blue = rgb("#0072B2")

// Marcas matemáticas con los colores del curso.
#let mark-orange = mark.with(color: c-orange)
#let mark-blue = mark.with(color: c-blue)
#let mark-green = mark.with(color: c-green)
#let mark-pink = mark.with(color: c-pink)
#let mark-gold = mark.with(color: c-gold)

// Texto fuera de las ecuaciones.
#let text-orange = text.with(fill: c-orange)
#let text-blue = text.with(fill: c-blue)
#let text-green = text.with(fill: c-green)
#let text-pink = text.with(fill: c-pink)
#let text-gold = text.with(fill: c-gold)

// Resaltados matemáticos con fondo suave y sin bordes.
#let course-markrect = markrect.with(stroke: none, outset: 0.12em, radius: 3pt)
#let markrect-orange = course-markrect.with(color: c-orange, fill: c-orange.lighten(90%))
#let markrect-blue = course-markrect.with(color: c-blue, fill: c-blue.lighten(90%))
#let markrect-green = course-markrect.with(color: c-green, fill: c-green.lighten(90%))
#let markrect-pink = course-markrect.with(color: c-pink, fill: c-pink.lighten(90%))
#let markrect-gold = course-markrect.with(color: c-gold, fill: c-gold.lighten(90%))

#let course-primary = c-blue
#let course-data = c-orange
#let course-posterior = c-green

#let cita(body, autor: none) = [
  #block(fill: rgb("#f5f5f5"), stroke: (left: 2pt), inset: (x: 14pt, y: 6pt))[
    #set text(size: 19pt, style: "italic")
    #body
  ]
  #if autor != none {
    align(right, text(size: 16pt, style: "normal")[— #autor])
  }
]

// Recuadro gris centrado para ecuaciones o texto, al estilo de Typslides.
#let grayed(content, text-size: 22pt, width: auto) = align(center, block(
  width: width,
  fill: rgb("#eeedeb"),
  inset: (x: 20pt, y: 14pt),
  radius: 4pt,
  above: 0.6em,
  below: 0.6em,
  breakable: false,
)[
  #set text(size: text-size)
  #align(center, content)
])


#let highlight-box(title: none, body) = clue(
  title: title,
  accent-color: course-primary,
  header-color: rgb("#e9ecef"),
  border-color: rgb("#d3d3d3"),
  body-color: rgb("#f8f9fa"),
  width: 100%,
  radius: 4pt,
  border-width: 0.5pt,
  stroke-width: 3pt,
  content-inset: (x: 12pt, y: 10pt),
  header-inset: (x: 12pt, y: 8pt),
  breakable: false,
  body,
)

#let page-stroke = stroke(thickness: 2pt, paint: course-primary, cap: "butt")
#let new-section-stroke = stroke(thickness: 3pt, paint: course-primary, cap: "butt")
#let margin-text-size = 0.6em

#let slide-number = context counter("touying-slide-counter").display()
#let current-section = context {
  let sections = query(<course-section>).filter(
    it => it.location().page() <= here().page(),
  )
  if sections.len() > 0 { sections.last().value }
}
#let register-section(title) = [#metadata(title)<course-section>]

#let setup-template(
  title: none,
  subtitle: none,
  author: none,
  date: none,
  footer-label: none,
  institution: none,
  handout: false,
  body,
) = {
  show: touying-slides.with(
    config-page(
      paper: "presentation-16-9",
      margin: (x: 1.5cm, top: 1cm, bottom: 1.3cm),
      footer: box(stroke: (top: page-stroke), inset: (x: 0pt, y: 8pt))[
        #set text(size: margin-text-size)
        #set align(horizon)

        #grid(
          columns: (1fr, 1fr, 1fr),
          align: (left, center, right),
          footer-label,
          current-section,
          slide-number,
        )
      ],
      header: none,
    ),
    config-common(
      handout: handout,
      slide-level: 1,
      slide-fn: slide,
      subslide-preamble: self => {
        if self.headings.len() > 0 {
          heading(
            level: 1,
            outlined: false,
            bookmarked: false,
            self.headings.last().body,
          )
        }
      },
      zero-margin-footer: false,
    ),
)

  set text(font: "Atkinson Hyperlegible", size: 21pt, fill: rgb("#343a40"))
  show link: set text(course-primary)
  show raw: set text(font: "Cascadia Code")
  show math.equation: set text(font: "Fira Math")
  show heading: set block(below: 0.8em)
  show heading: set text(size: 1.2em, fill: course-primary)

  // Tamano de texto del codigo cuando esta en un parrafo
  show raw.where(block: false): set text(size: 1.1em)

  // Tamano de texto del codigo cuando esta en un bloque de codigo
  show raw.where(block: true): set text(size: 14pt)
  show raw.where(block: true): it => block(
    fill: rgb("#f5f5f5"),
    stroke: stroke(thickness: 1pt, paint: rgb("#d0d0d0")),
    inset: 8pt,
    radius: 4pt,
    width: 100%,
    it,
  )
  set list(spacing: 0.75em)

  slide(config: config-page(header: none, footer: none))[
    #set align(horizon)
    #stack(
      text(size: 2em, weight: "bold", fill: course-primary, title),
      {
        if subtitle != none {
            v(1.2em)
            text(size: 1.4em, subtitle)
        }
      }
    )
    #line(stroke: new-section-stroke, length: 100%)
    #author

    #institution

    #date

  ]
  body
}

#let new-section-slide(title) = {
  slide(config: config-page(header: none, footer: none, fill: course-primary))[
    #set align(horizon)
    #set align(center)
    #set text(size: 2em, fill: white)
    #strong(title)
    #register-section(title)
  ]
}

#let inverted-slide(top, bottom: none) = {
  slide(config: config-page(header: none, footer: none, fill: course-primary))[
    #set align(horizon)
    #set text(size: 2em, fill: white)
    #set align(center)
    #strong(top)
    // #line(stroke: 3pt + white, length: 100%)

    #strong(bottom)
  ]
}
