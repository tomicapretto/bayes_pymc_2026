#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#set page(width: auto, height: auto, margin: 14pt)
#set text(font: "Libertinus Serif", size: 15pt)
#let Binomial = math.op("Binomial")
#let Beta = math.op("Beta")
#let azul = rgb("0072B2")
#let naranja = rgb("D98200")
#let verde = rgb("009E73")
// Forzar la cursiva matemática también cuando el contenido está coloreado.
#let prob(i) = text(fill: azul)[$italic(pi)_#i$]
#let conteo(i) = text(fill: verde)[$italic(Y)_#i$]
#let pi-comun = text(fill: azul)[$italic(pi)$]
#let hiper(body) = text(fill: naranja, math.italic(body))
#let obs(pos, i) = node(pos, conteo(i), fill: verde.lighten(92%), stroke: verde + .8pt, radius: 17pt)
#let par(pos, i) = node(pos, prob(i), fill: azul.lighten(94%), stroke: azul + .8pt, radius: 17pt)
#let tipo = sys.inputs.at("tipo", default: "parcial")
#align(center)[
  #if tipo == "independiente" [
    *Sin pooling* \
    #v(8pt)
    #diagram(spacing: (22mm, 15mm),
      par((0,0), 1), par((1,0), 2), node((2,0.5), $dots.h$), par((3,0), 12),
      obs((0,1), 1), obs((1,1), 2), obs((3,1), 12),
      edge((0,0),(0,1),"->"), edge((1,0),(1,1),"->"), edge((3,0),(3,1),"->"),
    )
    #v(8pt)
    $
      #prob($i$) & tilde.op Beta(1,1) \
      #conteo($i$) & tilde.op Binomial(n_i, #prob($i$))
    $
  ] else if tipo == "completo" [
    *Pooling completo* \
    #v(8pt)
    #diagram(spacing: (22mm, 15mm),
      node((1.5,0), pi-comun, fill: azul.lighten(94%), stroke: azul + .8pt, radius: 17pt),
      obs((0,1), 1), obs((1,1), 2), node((2,1), $dots.h$), obs((3,1), 12),
      edge((1.5,0),(0,1),"->"), edge((1.5,0),(1,1),"->"), edge((1.5,0),(3,1),"->"),
    )
    #v(8pt)
    $
      #pi-comun & tilde.op Beta(1,1) \
      #conteo($i$) & tilde.op Binomial(n_i, #pi-comun)
    $
  ] else [
    *Pooling parcial* \
    #v(8pt)
    #diagram(spacing: (22mm, 15mm),
      node((1,0), hiper($alpha$), fill: naranja.lighten(93%), stroke: naranja + .8pt, radius: 17pt),
      node((2,0), hiper($beta$), fill: naranja.lighten(93%), stroke: naranja + .8pt, radius: 17pt),
      par((0,1), 1), par((1,1), 2), node((2,1.5), $dots.h$), par((3,1), 12),
      obs((0,2), 1), obs((1,2), 2), obs((3,2), 12),
      edge((1,0),(0,1),"->"), edge((1,0),(1,1),"->"), edge((1,0),(3,1),"->"),
      edge((2,0),(0,1),"->"), edge((2,0),(1,1),"->"), edge((2,0),(3,1),"->"),
      edge((0,1),(0,2),"->"), edge((1,1),(1,2),"->"), edge((3,1),(3,2),"->"),
    )
    #v(8pt)
    $
      #prob($i$) & tilde.op Beta(#hiper($alpha$), #hiper($beta$)) \
      #conteo($i$) & tilde.op Binomial(n_i, #prob($i$))
    $
  ]
]
