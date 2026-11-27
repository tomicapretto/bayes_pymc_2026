#import "@preview/fletcher:0.5.8": diagram, node, edge

#let azul = rgb("0072B2")
#let naranja = rgb("D98200")
#let Beta = math.op("Beta")

// Ícono propio: todas las tarjetas usan el mismo edificio para que la
// información que distingue los hospitales aparezca solamente en los rótulos.
#let hospital(letra, categoria: none) = align(center)[
  #image("hospital.svg", width: 10mm)
  #v(2pt)
  #text(weight: "bold")[Hospital #letra]
  #v(1pt)
  $pi_#letra$
  #if categoria != none [
    #v(3pt)
    #text(size: 8pt, fill: if categoria == "Menor" { azul } else { naranja })[#categoria\ complejidad]
  ]
]

#let hospitales() = {
  set text(size: 9pt)
  align(center,
    block(width: 145mm, inset: 8pt, radius: 4pt, stroke: luma(82%) + .6pt)[
      #align(center)[*Solo usamos las etiquetas*]
      #v(5pt)
      #align(center, diagram(
        spacing: (3mm, 12mm),
        node((0, 0), hospital("A")),
        node((1, 0), hospital("B")),
        node((2, 0), hospital("C")),
        node((3, 0), hospital("D")),
        node((4, 0), hospital("E")),
        edge((0, 0), (1, 0), "<->", bend: -65deg, stroke: azul + .8pt),
      ))
    ],
  )
}

#let hospitales-complejidad() = {
  set text(size: 9pt)
  grid(
    columns: (3fr, 2fr), gutter: 6mm,
    block(width: 100%, inset: 8pt, radius: 4pt,
      fill: azul.lighten(97%), stroke: azul + .6pt)[
      #align(center)[*Casos de menor complejidad*]
      #v(5pt)
      #align(center, diagram(
        spacing: (3mm, 12mm),
        node((0, 0), hospital("A")),
        node((1, 0), hospital("B")),
        node((2, 0), hospital("C")),
        edge((0, 0), (1, 0), "<->", bend: -65deg, stroke: azul + .8pt),
      ))
    ],
    block(width: 100%, inset: 8pt, radius: 4pt,
      fill: naranja.lighten(97%), stroke: naranja + .6pt)[
      #align(center)[*Casos de mayor complejidad*]
      #v(5pt)
      #align(center, diagram(
        spacing: (3mm, 12mm),
        node((0, 0), hospital("D")),
        node((1, 0), hospital("E")),
        edge((0, 0), (1, 0), "<->", bend: -65deg, stroke: naranja + .8pt),
      ))
    ],
  )
}

#let probabilidad-compartida() = {
  set text(size: 10pt)
  grid(
    columns: (64mm, 1fr), gutter: 8mm, align: horizon,
    align(center, diagram(
      spacing: (8mm, 10mm),
      node((1, 0), $pi$, radius: 12pt, fill: azul.lighten(94%), stroke: azul + .8pt),
      node((0, 1), $X_1$, radius: 12pt, stroke: luma(65%) + .6pt),
      node((1, 1), $X_2$, radius: 12pt, stroke: luma(65%) + .6pt),
      node((2, 1), $X_3$, radius: 12pt, stroke: luma(65%) + .6pt),
      edge((1, 0), (0, 1), "->"),
      edge((1, 0), (1, 1), "->"),
      edge((1, 0), (2, 1), "->"),
    )),
    [
      #set block(above: 4pt, below: 4pt)
      *Si conocemos $pi$*

      $ P(X_j = 1 | X_1 = 1, pi) = pi. $

      *Si $pi$ es desconocida, con $pi tilde.op Beta(1, 1)$*

      $
        P(X_j = 1) &= 1/2, \
        P(X_j = 1 | X_1 = 1) &= 2/3.
      $
      #align(center)[Vale para $j = 2, 3$.]
    ],
  )
}
