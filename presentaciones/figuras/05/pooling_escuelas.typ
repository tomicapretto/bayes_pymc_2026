#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#set page(width: auto, height: auto, margin: 14pt)
#set text(font: "Libertinus Serif", size: 15pt)
#let Normal = math.op("Normal")
#let azul = rgb("0072B2")
#let naranja = rgb("D98200")
#let verde = rgb("009E73")
#let media(i) = text(fill: azul)[$italic(mu)_#i$]
#let observacion(i) = text(fill: verde)[$italic(Y)_(#i j)$]
#let hiper(body) = text(fill: naranja, math.italic(body))
#let obs(pos, i) = node(pos, observacion(i), fill: verde.lighten(92%), stroke: verde + .8pt, radius: 19pt)
#let par(pos, i) = node(pos, media(i), fill: azul.lighten(94%), stroke: azul + .8pt, radius: 17pt)
#align(center)[
    #diagram(spacing: (22mm, 15mm),
      node((1,0), hiper($mu_0$), fill: naranja.lighten(93%), stroke: naranja + .8pt, radius: 18pt),
      node((2,0), hiper($tau^2$), fill: naranja.lighten(93%), stroke: naranja + .8pt, radius: 17pt),
      par((0,1), 1), par((1,1), 2), node((2,1.5), $dots.h$), par((3,1), 100),
      obs((0,2), 1), obs((1,2), 2), obs((3,2), 100),
      edge((1,0),(0,1),"->"), edge((1,0),(1,1),"->"), edge((1,0),(3,1),"->"),
      edge((2,0),(0,1),"->"), edge((2,0),(1,1),"->"), edge((2,0),(3,1),"->"),
      edge((0,1),(0,2),"->"), edge((1,1),(1,2),"->"), edge((3,1),(3,2),"->"),
    )
    #v(8pt)
    $
      #media($i$) & tilde.op Normal(#hiper($mu_0$), #hiper($tau^2$)) \
      #observacion($i$) & tilde.op Normal(#media($i$), sigma^2)
    $
]
