#import "@preview/touying:0.8.0": *
#import "@preview/fletcher:0.5.8" as fletcher: node, edge
#import "@preview/mannot:0.4.0": annot

#import "template.typ": setup-template, highlight-box, grayed, cita
#import "template.typ": c-orange, c-green, c-pink, c-blue
#import "template.typ": new-section-slide, inverted-slide
#import "template.typ": mark-orange, mark-blue
#import "template.typ": text-orange, text-blue

#let fletcher-diagram = touying-reducer.with(reduce: fletcher.diagram, cover: fletcher.hide)

#let imagen-historia(archivo, pie: none, altura: 325pt) = align(center,
  stack(
    dir: ttb,
    spacing: 8pt,
    image("figuras/01/historia/" + archivo, width: 100%, height: altura, fit: "contain"),
    ..if pie == none { () } else { (text(size: 22pt, pie),) },
  ),
)

#let esquema-monedas(archivo, pie) = stack(
  dir: ttb,
  spacing: 8pt,
  block(width: 100%, inset: (x: 8%),
    grid(
      columns: (1fr, 1fr, 1fr, 1fr, 1fr),
      align: center,
      ..([*Oro*], [Falsa], [Falsa], [Falsa], [Falsa]).map(it => text(size: 17pt, it)),
    ),
  ),
  image("figuras/01/historia/" + archivo, width: 100%, height: 230pt, fit: "cover"),
  align(center, text(size: 22pt, pie)),
)

#show: setup-template.with(
  // Compilar con --input handout=true para la versión para estudiantes.
  handout: sys.inputs.at("handout", default: "false") == "true",
  title: [Estadística bayesiana con PyMC],
  subtitle: [Clase 1: Inferencia bayesiana],
  footer-label: [Estadística bayesiana con PyMC],
  author: [Tomás Capretto],
)

= Quién soy

#grid(columns: (2.25fr, 1fr))[
  - Licenciado en Estadística (UNR)
    - En progreso: doctorado en Estadística (UNR)
  #pause
  - Docente universitario
    - Estadística bayesiana
    - Programación
    - Antes: métodos numéricos, estadística multivariada
  #pause
  - Consultor
    - Trabajé durante \~5 años en PyMC Labs
    - Ahora de manera independiente
  #pause
  - Desarrollador de proyectos de código abierto
][

  #only("4-")[
    #set align(center)
    #image("figuras/01/arviz-logo.png", width: 80%, height: 100pt, fit: "contain")
    #image("figuras/01/pymc-logo.png", width: 80%, height: 100pt, fit: "contain")
    #image("figuras/01/bambi-logo.png", width: 80%, height: 100pt, fit: "contain")
  ]

]

= Sobre el curso

Conceptos fundamentales del análisis de datos bayesiano usando Python, PyMC, ArviZ, etc.

- 5 clases de 2 horas
- Sobre las clases
  #item-by-item[
    - Exposición de conceptos
    - Ejemplos
    - Notebooks (en Google Colab)
    - Preguntas
    - Trabajo en grupo
    - Actividades propuestas (opcionales)
  ]

= Sobre el curso

#[
  #set text(size: 22pt)

  - *Clase 1:* Probabilidad e incertidumbre, regla de Bayes y modelo beta-binomial.
  - *Clase 2:* Modelos conjugados y distribuciones predictivas.
  - *Clase 3:* Aproximación numérica y muestreo Monte Carlo con cadenas de Markov. Primeros pasos con PyMC.
  - *Clase 4:* Ajuste de modelos con PyMC y diagnóstico con ArviZ.
  - *Clase 5:* Más regresión, más uso de PreliZ, pruebas predictivas y modelos jerárquicos.
]

= Qué asumo sobre ustedes

Tomaron uno o dos cursos básicos de probabilidad y estadística.

#pause

No huyen si les menciono:

#pause

#grayed(text-size: 20pt)[
  #pause probabilidad, densidad de probabilidad, masa de probabilidad,
  #pause función de densidad de probabilidad (pdf), función de masa de probabilidad (pmf), función de distribución (cdf),
  #pause regla de la probabilidad total, regla de Bayes,
  #pause distribución de probabilidad, variable aleatoria, variable continua, variable discreta,
  #pause distribución conjunta, marginal y condicional,
  #pause esperanza y varianza, #pause marginal y condicional,
  #pause función de verosimilitud.
]

#pause

y...

#pause

alguna vez usaron Python o no tienen problema de aprender mientras lo usan #emoji.face.beam

#new-section-slide("Un último juego")

= El festejo

#pdfpc.speaker-note("Un amigo me contó lo que le pasó después de un coloquio de la Sociedad Argentina de Estadística en Tandil.\nEl coloquio había sido un éxito y, para celebrarlo, se organizó una juntada en el bar El Desvío.\nDespués de varios días de exposiciones, tocaba seguir la conversación sin mirar el reloj.\n\nLa mesa estaba animada. Que aquella charla había estado buenísima, que esa aplicación era interesantísima,\nque habría que probar algo parecido con los datos de uno.\n\nPor supuesto, también había comentarios menos entusiastas: que uno se había extendido muchísimo, como siempre,\nque a otro no se le había entendido nada, que para qué tantas ecuaciones.")
#imagen-historia("01-el-festejo.png")

= Los de siempre

#pdfpc.speaker-note("Pasaron las horas y la mesa se fue achicando.\nQuedaron los más entusiastas, que entre chanzas y anécdotas empezaron a desafiarse con juegos de azar y problemas de probabilidades.\n\nRamiro estaba especialmente inspirado. Cada vez que parecía que un problema había quedado resuelto, encontraba una vuelta más.\n\nMi amigo ya había perdido la cuenta de cuántas veces había dicho «depende».")
#imagen-historia("02-los-de-siempre.png")

= La cuenta

#pdfpc.speaker-note("Pero todo concluye al fin.\nEl encargado les trajo la cuenta y empezó a acomodar las sillas de las mesas vecinas.\nEsta vez no había mucho que discutir: había que irse.")
#imagen-historia("03-la-cuenta.png")

= Cada uno por su lado

#pdfpc.speaker-note("En la puerta mi amigo se despidió de los demás asistentes al coloquio.\nEllos iban al hotel del centro, hacia la derecha.\nÉl había reservado a último momento y había conseguido lugar para el otro lado. Bastante más lejos.")
#imagen-historia("03b-la-despedida.png")

= El camino al hotel

#pdfpc.speaker-note("Mi amigo caminaba con las manos en los bolsillos, todavía dándoles vueltas a los desafíos de Ramiro.\nQue la probabilidad de esto, que aquello es constante, que esos eventos son disjuntos…\n\nCuando por fin cruzó la última plaza antes del hotel, escuchó un chistido.\n\nUn hombre sentado en un banco le hizo una seña.")
#imagen-historia("04-el-camino-al-hotel.png")

= El desconocido

#pdfpc.speaker-note("Lo saludó por su nombre y lo felicitó por su charla.\nLe dijo que había estado muy buena, que siempre le había interesado ese tema.\n\nMi amigo le agradeció, aunque no terminaba de ubicarlo.\n\n—Disculpame, ¿cómo era tu nombre?\n\n—Amadeo.\n\nLe explicó que estaba muy cansado, que al día siguiente salía temprano y que prefería ir a dormir.\nMientras hablaba, se dio cuenta de que ya había vuelto a olvidarse de su nombre.\n\nEl hombre puso cara de pena. Se lo veía entusiasmado por conversar.\nPero justo cuando mi amigo se estaba por dar vuelta, sacó del bolsillo una pequeña bolsa de tela.\n\n—Antes de que te vayas, te propongo un juego.")
#imagen-historia("05-el-desconocido.png")

= Cinco monedas

#pdfpc.speaker-note("La bolsa contenía cinco monedas.\nUna era de oro puro y valía $1000.\nLas otras cuatro brillaban igual, pero eran imitaciones sin valor alguno.\n\nHabía una diferencia más: la moneda de oro tenía cara y cruz. Las falsas tenían cara de los dos lados.\n\n**Aclaración docente:** para el juego, se da por cierto lo que el hombre le contó:\nhabía una moneda de oro, cuatro falsas y todas tenían la misma probabilidad de salir.")
#imagen-historia("06-cinco-monedas-dorado.png")

= Cinco monedas

#esquema-monedas("10a-diez-lados.svg", [Oro: cara y cruz. \ Imitaciones: cara de los dos lados.])

= La primera oferta

#pdfpc.speaker-note("—Por $125 sacás una moneda al azar, sin mirar, y te la quedás.\n\nMi amigo miró la bolsa. Una moneda valía $1000 y las otras cuatro, nada.\n\n¿Le convenía aceptar la oferta?")
#imagen-historia("07-la-primera-oferta.png", pie: [*\$125* por una moneda al azar. ¿Le conviene aceptar?])

#slide[
  #set text(size: 18pt)
  #let gris = rgb("#737b83")
  #let posiciones = (50pt, 190pt, 330pt, 470pt, 610pt)

  #align(center + horizon)[
    #fletcher-diagram(
      node-corner-radius: 5pt,
      node-stroke: 1.4pt,
      node-inset: 6pt,
      edge-stroke: 1pt + gris,
      label-size: 14pt,

      node((330pt, 0pt), [Seleccionar moneda], name: <seleccion>,
        width: 190pt, height: 46pt,
        stroke: c-blue, fill: c-blue.lighten(92%)),

      pause,
      // Una moneda de oro y cuatro falsas.
      {
        for (i, x) in posiciones.enumerate() {
          let nombre = label("moneda-" + str(i))
          let color = if i == 0 { c-orange } else { gris }
          node((x, -90pt), if i == 0 { [Oro] } else { [Falsa] },
            name: nombre, width: 94pt, height: 34pt,
            stroke: color, fill: color.lighten(92%))
          edge(<seleccion>, nombre, "-|>")
        }
      },

      pause,
      {
        for (i, x) in posiciones.enumerate() {
          let nombre = label("premio-inicial-" + str(i))
          let color = if i == 0 { c-green } else { c-pink }
          node((x, -225pt), if i == 0 { [\$1000] } else { [\$0] },
            name: nombre, width: 68pt, height: 32pt,
            stroke: color, fill: color.lighten(92%))
          edge(label("moneda-" + str(i)), nombre, "-|>")
        }
      },

      pause,
      {
        for x in posiciones {
          node((x + 28pt, -47pt), $1/5$, stroke: none)
        }
      }
    )
  ]
]

#inverted-slide[
  #set text(size: 48pt)
  ¿Conviene aceptar?
]

#slide[
  #set text(size: 18pt)
  #let gris = rgb("#737b83")
  #let posiciones = (50pt, 190pt, 330pt, 470pt, 610pt)

  #align(center + horizon)[
    #fletcher-diagram(
      node-corner-radius: 5pt,
      node-stroke: 1.4pt,
      node-inset: 6pt,
      edge-stroke: 1pt + gris,
      label-size: 14pt,

      node((330pt, 0pt), [Seleccionar moneda], name: <seleccion>,
        width: 190pt, height: 46pt,
        stroke: c-blue, fill: c-blue.lighten(92%)),
      // Una moneda de oro y cuatro falsas.
      {
        for (i, x) in posiciones.enumerate() {
          let nombre = label("moneda-" + str(i))
          let color = if i == 0 { c-orange } else { gris }
          node((x, -90pt), if i == 0 { [Oro] } else { [Falsa] },
            name: nombre, width: 94pt, height: 34pt,
            stroke: color, fill: color.lighten(92%))
          edge(<seleccion>, nombre, "-|>")
        }
      },
      {
        for (i, x) in posiciones.enumerate() {
          let nombre = label("premio-inicial-" + str(i))
          let color = if i == 0 { c-green } else { c-pink }
          node((x, -225pt), if i == 0 { [\$1000] } else { [\$0] },
            name: nombre, width: 68pt, height: 32pt,
            stroke: color, fill: color.lighten(92%))
          edge(label("moneda-" + str(i)), nombre, "-|>")
        }
      },

      {
        for x in posiciones {
          node((x + 28pt, -47pt), $1/5$, stroke: none)
        }
      },

      node(
        (330pt, -300pt),
        [Valor esperado: \$200],
        width: 270pt,
        height: 40pt,
        stroke: c-blue,
        fill: c-blue.lighten(92%)
      ),
    )
  ]
]

= Una moneda al aire

#pdfpc.speaker-note("Antes de que mi amigo respondiera, el hombre sacó una moneda al azar de la bolsa y la tiró al aire.")
#imagen-historia("08a-la-moneda-en-el-aire.png")

= Cara

#pdfpc.speaker-note("La atajó y se la mostró.\n\nCara.\n\n—La oferta sigue en pie. Por $125, esta moneda es tuya.\n\nAntes podía sacar una moneda al azar. Ahora el hombre le ofrecía comprar esa que acababa de mostrar cara.\n\n¿Le convenía comprarla ahora?")
#imagen-historia("08b-cara.png", pie: [*\$125* por esta moneda. ¿Y ahora?])

= Después de observar cara

#pdfpc.speaker-note("Pero las falsas siempre mostraban cara. La de oro, solamente la mitad de las veces.\n\nVer cara favorecía la posibilidad de que mi amigo tuviera delante una imitación.\nLa probabilidad de oro bajaba de un quinto a un noveno.\nEl valor esperado quedaba en unos $111,11: menos de lo que le pedía el hombre.")
#esquema-monedas("10a-diez-lados.svg", [Diez lados igualmente probables: nueve caras y una cruz.])

= Después de observar cara

#esquema-monedas("10b-nueve-caras.svg", [Ver cara *descarta* la única cruz. Quedan nueve posibilidades.])

#slide[
  #set text(size: 18pt)
  #let gris = rgb("#737b83")
  #let posiciones = (50pt, 190pt, 330pt, 470pt, 610pt)

  #align(center + horizon)[
    #fletcher-diagram(
      node-corner-radius: 5pt,
      node-stroke: 1.4pt,
      node-inset: 6pt,
      edge-stroke: 1pt + gris,
      label-size: 14pt,

      node((330pt, 0pt), [Seleccionar moneda], name: <seleccion>,
        width: 190pt, height: 46pt,
        stroke: c-blue, fill: c-blue.lighten(92%)),

      // Una moneda de oro y cuatro falsas.
      {
        for (i, x) in posiciones.enumerate() {
          let nombre = label("moneda-" + str(i))
          let color = if i == 0 { c-orange } else { gris }
          node((x, -90pt), if i == 0 { [Oro] } else { [Falsa] },
            name: nombre, width: 94pt, height: 34pt,
            stroke: color, fill: color.lighten(92%))
          edge(<seleccion>, nombre, "-|>")
        }
      },

      // Dos caras por moneda; sólo la de oro tiene una cruz.
      {
        for (i, x) in posiciones.enumerate() {
          for j in range(2) {
            let cara = label("cara-" + str(i) + "-" + str(j))
            let premio = label("premio-" + str(i) + "-" + str(j))
            let premio-color = if i == 0 { c-green } else { c-pink }
            let xx = x + if j == 0 { -34pt } else { 34pt }
            node((xx, -165pt), if i == 0 and j == 1 { [X] } else { [C] },
              name: cara, width: 36pt, height: 32pt,
              stroke: c-blue, fill: c-blue.lighten(92%))
            node((xx, -225pt), if i == 0 { [\$1000] } else { [\$0] },
              name: premio, width: 60pt, height: 32pt,
              stroke: premio-color, fill: premio-color.lighten(92%))
            edge(label("moneda-" + str(i)), cara, "-|>", stroke: 1pt + c-blue)
            edge(cara, premio, "-|>", stroke: 1pt + c-blue)
            node((xx + 16pt, -195pt), text(size: 14pt)[$1/10$], stroke: none,
              width: 22pt, height: 26pt, inset: 0pt, fill: white)
          }
        }
      },

      pause,
      // Observar cara descarta la cruz de la moneda de oro.
      node((100pt, -195pt), [], stroke: none,
        width: 22pt, height: 26pt, inset: 0pt, fill: white),
      node((84pt, -195pt), stroke: none, inset: 0pt,
        box(width: 46pt, height: 108pt)[
          #place(top + left, line(start: (0pt, 0pt), end: (46pt, 108pt), stroke: 2.5pt + red))
          #place(top + left, line(start: (46pt, 0pt), end: (0pt, 108pt), stroke: 2.5pt + red))
        ]),

      pause,
      {
        for (i, x) in posiciones.enumerate() {
          for j in range(2) {
            if i != 0 or j != 1 {
              let xx = x + if j == 0 { -34pt } else { 34pt }
              node((xx + 16pt, -195pt), text(size: 14pt)[$1/9$], stroke: none,
                width: 22pt, height: 26pt, inset: 0pt, fill: white)
            }
          }
        }
      },
      node((330pt, -267pt), text(size: 15pt)[9 resultados posibles · 1 con premio], stroke: none),
    )
  ]
]

#inverted-slide[
  #set text(size: 48pt)
  ¿Y ahora, conviene aceptar?
]

#slide[
  #set text(size: 18pt)
  #let gris = rgb("#737b83")
  #let posiciones = (50pt, 190pt, 330pt, 470pt, 610pt)

  #align(center + horizon)[
    #fletcher-diagram(
      node-corner-radius: 5pt,
      node-stroke: 1.4pt,
      node-inset: 6pt,
      edge-stroke: 1pt + gris,
      label-size: 14pt,

      node((330pt, 0pt), [Seleccionar moneda], name: <seleccion>,
        width: 190pt, height: 46pt,
        stroke: c-blue, fill: c-blue.lighten(92%)),

      // Una moneda de oro y cuatro falsas.
      {
        for (i, x) in posiciones.enumerate() {
          let nombre = label("moneda-" + str(i))
          let color = if i == 0 { c-orange } else { gris }
          node((x, -90pt), if i == 0 { [Oro] } else { [Falsa] },
            name: nombre, width: 94pt, height: 34pt,
            stroke: color, fill: color.lighten(92%))
          edge(<seleccion>, nombre, "-|>")
        }
      },

      // Dos caras por moneda; sólo la de oro tiene una cruz.
      {
        for (i, x) in posiciones.enumerate() {
          for j in range(2) {
            let cara = label("cara-" + str(i) + "-" + str(j))
            let premio = label("premio-" + str(i) + "-" + str(j))
            let premio-color = if i == 0 { c-green } else { c-pink }
            let xx = x + if j == 0 { -34pt } else { 34pt }
            node((xx, -165pt), if i == 0 and j == 1 { [X] } else { [C] },
              name: cara, width: 36pt, height: 32pt,
              stroke: c-blue, fill: c-blue.lighten(92%))
            node((xx, -225pt), if i == 0 { [\$1000] } else { [\$0] },
              name: premio, width: 60pt, height: 32pt,
              stroke: premio-color, fill: premio-color.lighten(92%))
            edge(label("moneda-" + str(i)), cara, "-|>", stroke: 1pt + c-blue)
            edge(cara, premio, "-|>", stroke: 1pt + c-blue)
            node((xx + 16pt, -195pt), text(size: 14pt)[$1/10$], stroke: none,
              width: 22pt, height: 26pt, inset: 0pt, fill: white)
          }
        }
      },
      // Observar cara descarta la cruz de la moneda de oro.
      node((100pt, -195pt), [], stroke: none,
        width: 22pt, height: 26pt, inset: 0pt, fill: white),
      node((84pt, -195pt), stroke: none, inset: 0pt,
        box(width: 46pt, height: 108pt)[
          #place(top + left, line(start: (0pt, 0pt), end: (46pt, 108pt), stroke: 2.5pt + red))
          #place(top + left, line(start: (46pt, 0pt), end: (0pt, 108pt), stroke: 2.5pt + red))
        ]),
      {
        for (i, x) in posiciones.enumerate() {
          for j in range(2) {
            if i != 0 or j != 1 {
              let xx = x + if j == 0 { -34pt } else { 34pt }
              node((xx + 16pt, -195pt), text(size: 14pt)[$1/9$], stroke: none,
                width: 22pt, height: 26pt, inset: 0pt, fill: white)
            }
          }
        }
      },
      node((330pt, -267pt), text(size: 15pt)[9 resultados posibles · 1 con premio],
        stroke: none),
      node((330pt, -300pt), [Valor esperado: \$111,11],
        width: 270pt, height: 40pt,
        stroke: c-blue, fill: c-blue.lighten(92%)),
    )
  ]
]

= Ganancia esperada

#pdfpc.speaker-note("Antes del lanzamiento, mi amigo tenía una posibilidad entre cinco de llevarse la moneda de oro.\n\nEl valor esperado era de $200. Descontando los $125 de la apuesta, la ganancia esperada era de $75.")

Para una variable discreta $X$, su valor esperado resulta:

$
  EE(X) = sum_x x P(X=x)
$

#pause
La ganancia es el valor de la moneda menos el precio de participar:

$ G = X - 125 quad arrow.r quad EE(G) = EE(X) - 125 $

#pause

Antes del lanzamiento:

$
  EE(X) = 1/5 dot 1000 + 4/5 dot 0 = 200
$

#grayed[La ganancia esperada es *\$75*.]

= ¿Por qué cambió la probabilidad de oro?

Sean

#v(-0.5em)
- $O$: La moneda es de oro.
- $F$: La moneda falsa.
- $C$: Se observa cara.

$
  P(C) &= P(C | O) P(O) + P(C | F) P(F)\
  &= 1/2 dot 1/5 + 1 dot 4/5 = 9/10
$

#pause

#grid(columns: (1fr, 1fr))[
  $
    P(O | C) = (P(C | O) P(O)) / P(C) = (1/10)/(9/10) = 1/9
  $
][
  #pause
  $
    P(F | C) = (P(C | F) P(F)) / P(C) = (4/5) / (9/10) = 8/9
  $
]

= La ganancia después de observar cara

$
  EE(X | C) &= sum_x x P(X=x | C). \
  &= 1/9 dot 1000 + 8/9 dot 0 approx 111.11
$

#pause
#grayed[
  $ EE(G | C) = 1000/9 - 125 approx -13.89 $
]

#pause

#v(1em)

No conviene jugar después de ver cara.

#pause

Pero... ¿qué cambió?

#inverted-slide[
  #pdfpc.speaker-note("El lanzamiento no convirtió el oro en una imitación ni una imitación en oro.\nPero ver cara le dio información sobre la moneda que tenía delante.\nY esa información cambió cuánto estaba dispuesto a pagar por ella.")

  ¿El valor de la moneda?

  #pause

  ¿Su información?

]

= Al otro día...

#pdfpc.speaker-note("Justo cuando mi amigo estaba por contestarle, sonó una alarma.\n\nAbrió los ojos. Estaba en la cama del hotel.\nNo había ningún hombre, ninguna bolsa, ninguna moneda.\nHabía sido otro sueño delirante después de pasar demasiadas horas hablando de probabilidades.\nY tal vez demasiadas cervezas.")
#imagen-historia("11-el-despertador.png")

= Lo que queda del juego

#pdfpc.speaker-note("**En pantalla:** «La moneda ya estaba elegida. La incertidumbre era suya».\n\nEl juego no ocurrió, pero la pregunta queda: una vez elegida la moneda,\n¿qué significaba decir que tenía cierta probabilidad de ser de oro?\n\nLa moneda ya era de oro o falsa. Mi amigo no sabía cuál de las dos cosas era.\nY aun así, las probabilidades le permitían usar lo que sabía para decidir.")
#imagen-historia("12-lo-que-queda-del-juego.png", altura: 270pt,
  pie: [La moneda ya estaba elegida. La incertidumbre era suya.])

#new-section-slide[¿Qué significa la probabilidad?]

= Interpretación clásica

Razón entre casos favorables y posibles, bajo el supuesto de equiprobabilidad.

#v(1.5em)
#align(center)[
  $P(A) = display("Cantidad de casos favorables a A" / "Cantidad de casos posibles")$
]

= Interpretación frecuentista

Límite de la frecuencia relativa de un evento al repetir un experimento un número muy grande de veces.

#v(1.5em)
#align(center)[
  $P(A) = display(lim_(n -> infinity) "Cantidad de veces que ocurre A" / n)$
]

= Interpretación subjetiva

Medida de la certidumbre o plausibilidad que una persona asigna a un evento o proposición.

#v(1.5em)
#align(center)[
  $P(A) = display("Grado de creencia sobre la ocurrencia de A")$
]

= Probabilidad subjetiva

Cuantifica la plausibilidad de una proposición a partir de la información disponible.

- Es *general*: no requiere eventos equiprobables ni repetibles.
#pause
- Es *personal*: distinta información puede llevar a distintas probabilidades.
#pause
- Es *coherente*: respeta las mismas reglas del cálculo de probabilidades.

= La probabilidad no existe

#pause

#align(center + horizon)[
  _My thesis, paradoxically, and a little provocatively, but nonetheless genuinely, is simply this:_

  #pause

  #v(2em)
  #text(size: 32pt, fill: c-blue)[PROBABILITY DOES NOT EXIST.]

  #pause
  #v(2em)
  — Bruno de Finetti

  #v(0.5em)
  #text(size: 14pt)[
    #link("https://books.google.com/books?id=ToRGAAAAYAAJ")[_Theory of Probability: A Critical Introductory Treatment_],
    vol. 1, Wiley, 1974, prefacio, p. x.
  ]
]

= ¿Qué quiere decir de Finetti?

Desde esta interpretación, la probabilidad…

#pause
- Refleja nuestra ignorancia sobre el mundo.
#pause
- Depende del observador y de su información.
#pause
- Es una herramienta para expresar grados de creencia, conocimiento o plausibilidad.

#pause
No es una propiedad física como la masa de un objeto o la temperatura de un líquido.

= Personal #sym.eq.not incoherente

Podemos asignar probabilidades distintas si tenemos información distinta.

#pause
Pero las probabilidades de cada persona deben ser *coherentes entre sí*.

#v(0.5em)

#grayed[
  $0 <= P(A) <= 1 quad "y" quad P(A) + P(A^c) = 1$
]

#v(0.5em)

#pause
Si se asigna $P(A) = 0.7$, se tiene que asignar $P(A^c) = 0.3$

#v(0.5em)

Puede cambiar la interpretación, pero las reglas del cálculo de probabilidades son las mismas.

= Aprender también tiene reglas

Cuando incorporamos evidencia, actualizamos nuestras probabilidades con la *regla de Bayes*.

#pause
#grayed(text-size: 26pt)[
  $P(cal(H) | cal(E)) = (P(cal(E) | cal(H)) P(cal(H))) / P(cal(E))$
]

- $cal(H)$: hipótesis
- $cal(E)$: evidencia nueva

#pause
#grid(
  columns: (1fr, 1fr),
  column-gutter: 24pt,
  [*Antes:* $P(cal(H))$ \ Probabilidad _a priori_.],
  [*Después:* $P(cal(H) | cal(E))$ \ Probabilidad _a posteriori_.],
)

= Un poco de historia: Bayes

#grid(
  columns: (0.7fr, 1.8fr),
  column-gutter: 28pt,
  align: top,
  [
    #image("figuras/01/thomas-bayes.png", width: 100%, height: 200pt, fit: "contain")
    #v(0.3em)
    #text(size: 12pt)[Retrato atribuido a Thomas Bayes.]
  ],
  [
    #set text(size: 19pt)
    *Bayes (1701/1702–1761) · 1763/1764* \ Price presenta su ensayo póstumo en 1763, que se publica en 1764. Busca calcular la probabilidad de que una probabilidad desconocida esté entre dos valores, dados los resultados observados.
  ],
)

#v(0.5em)
#text(size: 11pt)[Fuente: #link("https://arxiv.org/abs/2208.00646")[Martin, Frazier y Robert (2023; _preprint_ 2022)], §§1, 3.1-3.2 y notas 2 y 4.]

= Un poco de historia: Laplace

#grid(
  columns: (0.7fr, 1.8fr),
  column-gutter: 28pt,
  align: top,
  [
    #image("figuras/01/pierre-simon-laplace.jpg", width: 100%, height: 200pt, fit: "contain")
    #v(0.3em)
    #text(size: 12pt)[Pierre-Simon Laplace.]
  ],
  [
    #set text(size: 19pt)
    *Laplace (1749–1827) · desde 1774* \ Desarrolla y amplía los métodos de la probabilidad inversa: asignar probabilidades a valores desconocidos de un parámetro, condicionadas a los datos.

    #v(0.25em)
    No hay evidencia documental de que conociera el ensayo de Bayes al elaborar su trabajo de 1774.
  ],
)

#v(0.5em)
#text(size: 11pt)[Fuente: #link("https://arxiv.org/abs/2208.00646")[Martin, Frazier y Robert (2023; _preprint_ 2022)], §§1, 3.1-3.2 y notas 2 y 4.]

= Un poco de historia: Fisher en contra

#[
  #cita(autor: [R. A. Fisher (1925), #link("https://psychclassics.yorku.ca/Fisher/Methods/chap1.htm")[_Statistical Methods for Research Workers_], cap. I, §2, p. 10.])[
    “…the theory of inverse probability is founded upon an error, and must be wholly rejected.”
  ]

  #pause
  #set text(size: 19pt)
  *¿Qué cuestionaba?* Usar probabilidades para expresar incertidumbre sobre parámetros desconocidos sin una población de referencia que justificara esas probabilidades.

  #pause
  *¿Qué proponía?* Comparar los valores del parámetro mediante su *verosimilitud*: cuánto favorecen los datos observados a cada valor. Esa función no es una distribución de probabilidad sobre el parámetro.
]

= Un poco de historia: Dieulefait a favor

#[
  #set align(center)
  #image("figuras/01/sobre_inferencia_estadística.png", width: 95%, height: 260pt, fit: "contain")
  #v(0.5em)
  #text(size: 15pt)[Carlos E. Dieulefait, _Sobre inferencia estadística_.]
]

= Un poco de historia: Dieulefait a favor

#[
  #set text(size: 19pt)

  #cita[
    Las largas discusiones que se han originado cuando se pasa a una interpretación de esa fórmula en la que `..` se identifica con un cierto acontecimiento y `.` con lo que pueda llamarse su causa, en nada pueden tocar a la validez de la fórmula en sí misma sino que deben referirse a la validez de la interpretación.
  ]

  #pause
  #v(1em)
  #cita[
    El ingeniero en una fábrica, el agrónomo en una estación o plantación, el actuario en una compañía o caja estatal, deben extraer el máximo de información de su propio fondo de experiencia.
  ]

  #pause
  #v(1em)
  #cita(autor: [Carlos E. Dieulefait, _Sobre inferencia estadística_.])[
    La reforzada apelación a la experiencia es, quizá, uno de los méritos más grandes que detenta la (1).
  ]
]

#new-section-slide[Dos tipos de incertidumbre]

= Dos tipos de incertidumbre

*Epistémica (ignorancia)*
- Se debe a la falta de conocimiento sobre el estado del mundo.
- Puede reducirse al obtener más información.

#pause
#v(1em)
*Aleatoria*
- Se debe a la variabilidad de un proceso o fenómeno.
- No se elimina obteniendo más información dentro del modelo considerado.

= La incertidumbre en el juego de las monedas

¿Podemos identificar ambos tipos de incertidumbre?

#pause
*Aleatoria:* antes de seleccionar, no sabemos qué moneda saldrá de la bolsa.

#pause
*Epistémica:* una vez seleccionada, no sabemos si esa moneda es de oro o falsa.

#pause
Observar el resultado de un lanzamiento aporta información sobre su identidad.

= Dos urnas

#align(center)[
  #fletcher-diagram(
    node-inset: 0pt,
    edge-stroke: 2pt + black,
    {
      for (i, x) in (0pt, 230pt).enumerate() {
        edge((x - 65pt, 5pt), (x - 65pt, -125pt),
          (x + 65pt, -125pt), (x + 65pt, 5pt))
        node((x, -154pt), if i == 0 { $U_1$ } else { $U_2$ })
        for (j, pos) in ((-25pt, -25pt), (28pt, -58pt), (-22pt, -94pt)).enumerate() {
          let azul = if i == 0 { j == 2 } else { j != 0 }
          node((x + pos.at(0), pos.at(1)), [],
            shape: fletcher.shapes.ellipse, width: 35pt, height: 35pt,
            fill: if azul { c-blue } else { white },
            stroke: 1.3pt + c-blue)
        }
      }
    },
  )
]

- $U_1$: dos blancas y una azul.
- $U_2$: una blanca y dos azules.

#pause
Elegimos una urna al azar, con $P(U_1) = P(U_2) = 1\/2$

#pause
Extraemos una bola de esa urna y observamos que es *azul* ($A$).

¿Cuál es ahora la probabilidad de haber elegido $U_1$?

= Dos caminos para observar una azul

Antes de observar el color, una azul puede salir de cualquiera de las dos urnas.

#pause
*Elegir $U_1$ y sacar azul $A$:*
$ P(U_1, A) = P(U_1) P(A | U_1) = 1/2 dot 1/3 = 1/6 $

#pause
*Elegir $U_2$ y sacar azul $A$:*
$ P(U_2, A) = P(U_2) P(A | U_2) = 1/2 dot 2/3 = 2/6 $

#pause
Luego:

$ P(A) = P(U_1, A) + P(U_2, A) = 1/6 + 2/6 = 1/2 $

#slide[
  = Actualizar después de una azul

  Observamos una bola azul. ¿Cuál es ahora la probabilidad de haber elegido $U_1$?

  #pause
  $
    P(U_1 | A) &= P(U_1, A) / P(A) \ #pause
    & = (P(A | U_1) P(U_1)) / (P(A | U_1) P(U_1) + P(A | U_2) P(U_2)) \
    & = (1\/6) / (1\/6 + 2\/6) = 1/3
 $

  #pause

  La probabilidad de $U_1$ baja de $1\/2$ a $1\/3$

  #pause

  Observar una bola azul favorece a la urna que tiene más azules.
]

= Otra bola azul, con reposición

Conservamos la urna elegida. Devolvemos la bola y mezclamos antes de volver a extraer. La segunda bola también es azul.

Llamamos $A_1$ y $A_2$ a observar azul en la primera y segunda extracción.

Si supiéramos cuál es la urna, las extracciones serían independientes:
$ P(A_1, A_2 | U_1) = 1/3 dot 1/3 = 1/9, $

#pause
$ P(A_1, A_2 | U_2) = 2/3 dot 2/3 = 4/9 $

Dos azules son cuatro veces más probables con $U_2$ que con $U_1$

= Actualizar después de dos azules

Sin embargo, observamos *dos azules* de la misma urna, desconocida.

#pause
$
  P(U_1 | A_1, A_2) &= (P(A_1, A_2 | U_1) P(U_1)) / (P(A_1, A_2 | U_1) P(U_1) + P(A_1, A_2 | U_2) P(U_2)) \ #pause
  &= (1\/9 dot 1\/2) / (1\/9 dot 1\/2 + 4\/9 dot 1\/2) \ #pause
  &= (1\/18) / (1\/18 + 4\/18) = 1/5
$

#pause
Antes de la primera extracción: $P(U_1) = 1/2$

#pause
Después de observar una bola azul: $P(U_1 | A_1) = 1/3$

#pause
Después de observar dos bolas azules: $P(U_1 | A_1, A_2) = 1/5$

= Otra forma: aprender de a una bola

Después de la primera azul, las probabilidades de las urnas se actualizan a $1/3$ y $2/3$

#pause
Para incorporar la segunda azul, partimos de esas probabilidades actualizadas:
#v(1.5em)
$ P(U_1 | A_1, A_2) =
  (#mark-orange($1\/3$, <azul-con-u1>) dot #mark-blue($1\/3$, <u1-tras-azul>)) /
  (1/3 dot 1/3 + 2/3 dot 2/3) = 1/5
  #annot(<azul-con-u1>, pos: top + left, dy: -1em,
    annot-text-props: (size: 14pt))[Azul con $U_1$]
  #annot(<u1-tras-azul>, pos: top + right, dy: -1em,
    annot-text-props: (size: 14pt))[$U_1$ tras una azul]
$

#pause
Obtenemos el mismo resultado que al incorporar las dos observaciones juntas.

*Lo aprendido con una observación es el punto de partida para la siguiente.*

#inverted-slide[
  ¿Cuál es la $P(U_1)$ si seguimos observando bolas azules?
]

= ¿Y si observamos azules una y otra vez?

Seguimos extrayendo de la misma urna, *con reposición*, y todas salen azules.

Escribimos $D_n$ para abreviar «las primeras $n$ bolas fueron azules».

#pause
Con $U_1$, esa secuencia tiene probabilidad $(1/3)^n$, mientras que con $U_2$ es $(2/3)^n$

#pause
$ P(U_1 | D_n) = ((1/3)^n (1/2)) /
    ((1/3)^n (1/2) + (2/3)^n (1/2)) $

#pause
Dividimos numerador y denominador por $(1/3)^n (1/2)$:
$ P(U_1 | D_n) = 1/(1 + 2^n), quad P(U_2 | D_n) = 2^n/(1 + 2^n) $

= ¿Y si observamos azules una y otra vez?

#[
  #set align(center)

  #image("figuras/01/plot_01.pdf", width: 100%, height: 300pt, fit: "contain")

  #pause
  Cada extracción azul hace menos plausible que la urna sea $U_1$
]

#inverted-slide[
  ¿Cuál es la $P(A)$ si seguimos observando bolas azules?
]

= Que la próxima bola sea azul

La urna elegida sigue siendo la misma. Lo que cambia es cuánto creemos que sea cada una.

#pause
Si fuera $U_1$, la próxima bola sería azul con probabilidad $1\/3$

Si fuera $U_2$, esa probabilidad sería $2\/3$

#pause
Promediamos esas probabilidades dando más peso a la urna que creemos más probable.

Después de una azul, los pesos son $1\/3$ para $U_1$ y $2\/3$ para $U_2$:

$ P("próxima azul" | A) = 1/3 dot 1/3 + 2/3 dot 2/3 = 5/9$

= Que la próxima bola sea azul

Llamamos $A_(n+1)$ al evento «la próxima bola es azul», después de $n$ extracciones.

#pause
Promediamos usando las probabilidades actualizadas de las dos urnas:

$ P(A_(n+1) | D_n) = 1/3 dot P(U_1 | D_n) + 2/3 dot P(U_2 | D_n) $

#pause
Reemplazamos los pesos por las expresiones que acabamos de obtener:
$ = 1/3 dot 1/(1 + 2^n) + 2/3 dot 2^n/(1 + 2^n) $

#pause
$ = (1 + 2^(n+1))/(3(1 + 2^n)) $

= Que la próxima bola sea azul

#[
  #set align(center)
  #v(-0.5em)
  #image("figuras/01/plot_02.pdf", width: 100%, height: 280pt, fit: "contain")

  #pause
  La probabilidad se acerca a $2/3$, la proporción de azules de $U_2$.

  #pause
  Conocer la urna no elimina la incertidumbre sobre el color de la próxima bola.
]

= _The unknown and the unknowables_

#cita(autor: [Tony O'Hagan])[
  #set text(size: 24pt)
  There are things that I am uncertain about simply because I lack knowledge,
  #pause and in principle my uncertainty might be reduced by gathering more information. #pause
  Others are subject to random variability, which is unpredictable no matter how much information I might get; #pause these are the *unknowables*.
  #pause
  The two kinds of uncertainty have been debated by philosophers, who have given them the names *epistemic* uncertainty (due to lack of knowledge) and
  *aleatory* uncertainty (due to randomness).
]

#new-section-slide[Inferencia bayesiana]

= Regla de Bayes

No es más que una consecuencia directa de la regla del producto:

$
  P(A, B) &= P(A | B) P(B) \
  P(A, B) &= P(B | A) P(A)
$

#pause
Igualamos los términos de la derecha...

$
P(A | B) P(B) = P(B | A) P(A)
$

#pause
y reordenando llegamos a

$
  P(A | B) = (P(B | A)P(A)) / P(B)
$

que es la famosa regla de Bayes. #pause *Pero esto no es estadística bayesiana*.

= Modelos bayesianos

Hay dos ideas centrales:

#pause
- Representamos la incertidumbre sobre las cantidades desconocidas mediante distribuciones de probabilidad.
#pause
- Usamos la regla de Bayes para actualizar esas distribuciones a la luz de los datos.

#pause
Llamamos $y$ a los datos observados y $theta$ a las cantidades desconocidas del modelo.

= Modelos bayesianos: ingredientes

*Un modelo para las observaciones*

$ p(y | theta) $

Describe los resultados que podríamos observar para un valor dado de $theta$.

#pause
*Un modelo para las cantidades desconocidas: el _prior_*

$ p(theta) $

Representa la incertidumbre sobre $theta$ antes de incorporar los datos.

= Del modelo a la verosimilitud

Los dos componentes definen el modelo bayesiano completo:

$ p(y, theta) = p(y | theta) p(theta) $

#pause
Una vez observados los datos, fijamos #text-orange[$y$] y consideramos $p(#mark-orange($y$) | #mark-blue($theta$))$ como función de #text-blue[$theta$]: la *verosimilitud*.

#pause
Compara valores de $theta$ según su compatibilidad con los datos observados. No es una distribución de probabilidad sobre $theta$

= Actualizar con los datos

Usamos Bayes para obtener la *distribución _a posteriori_*:

$
  p(theta | y) &= (p(y | theta) p(theta)) / p(y) \ #pause
    &prop p(y | theta) p(theta)
$

#pause
Para un parámetro continuo, el denominador es una integral sobre sus valores posibles:

$ p(y) = integral_Theta p(y | theta) p(theta) dif theta $

$p(y)$ no depende de $theta$ y normaliza la distribución.

= Responder preguntas

Obtener la distribución _a posteriori_ no es el final del análisis.

#pause
Podemos resumirla con una media:

$ EE(theta | y) = integral_Theta theta p(theta | y) dif theta $

#pause
O calcular la probabilidad de que el parámetro esté en un intervalo:

$ P(a <= theta <= b | y) = integral_a^b p(theta | y) dif theta $

#pause
Y más, que ya veremos...

#new-section-slide[Agua en la Tierra]

= Agua en la Tierra

#align(center)[
  #image("figuras/01/tierra.jpg", height: 300pt, fit: "contain")
]

¿Qué proporción de la superficie de la Tierra está cubierta por agua?

= Agua en la Tierra

#align(center)[
  #image("figuras/01/globo-terraqueo.jpg", height: 250pt, fit: "contain")
]

Hacemos girar un globo, señalamos un punto y registramos *agua* o *tierra*.

#v(1em)
#text(size: 14pt)[Ejemplo de McElreath, _Statistical Rethinking_, cap. 2.]

= Agua en la Tierra

Repetimos el experimento 9 veces.

Observamos *6 veces agua* y *3 veces tierra*.

#pause
- $theta$: proporción de superficie cubierta por agua, desconocida
- $n = 9$: cantidad de observaciones
- $y = 6$: cantidad de veces que observamos agua

#pause
Queremos hacer inferencia sobre $theta$

= Modelo observacional

Para un valor de $theta$, podemos describir la cantidad de veces que se observa agua en $n$ ensayos:

$ Y | theta ~ "Binomial"(n, theta) $

#pause

Cuya función de masa de probabilidad (pmf) es:
$ p(y | theta) = binom(n, y) theta^y (1-theta)^(n-y) $

#pause
Este es nuestro *modelo para las observaciones*.

= Agua en la Tierra

#align(center)[
  #image("figuras/01/globo_modelo.pdf", width: 100%, height: 300pt, fit: "contain")
]

= Modelo para los parámetros, _a priori_

Necesitamos una distribución para representar lo que sabemos sobre $theta$ antes de observar los datos.

#pause
Para este primer cálculo usamos un *_prior_ uniforme*:

$ theta ~ "Uniforme"(0, 1) $

#pause
Asigna la misma probabilidad a intervalos de igual longitud dentro de $[0,1]$

= Modelo para los parámetros, _a priori_

#align(center)[
  #image("figuras/01/globo_prior.pdf", width: 100%, height: 300pt, fit: "contain")
]

Este _prior_ es uniforme en $theta$

= Modelo completo

El modelo bayesiano completo resulta:

$
  Y | theta &~ "Binomial"(n, theta) \
  theta &~ "Uniforme"(0, 1) \
$

#pause
El objetivo es obtener la distribución de $theta | Y = y$.

#pause

En nuestro caso:

$
  p(theta | Y = 6)
$

= Entran los datos

Fijados los datos observados $Y = 6$, la siguiente expresión es función de $theta$:

$
  p(Y=6 | theta) = binom(9, 6) theta^6 (1-theta)^3
$

#pause

- Esta función no es más que la función de verosimilitud de toda la vida.
#pause
- Mide la compatibilidad de valores de $theta$ con $Y=6$ en $n=9$ bajo nuestro modelo.
#pause
- ¡No es una distribución de probabilidad sobre $theta$!

= Entran los datos, función de verosimilitud

#align(center)[
  #image("figuras/01/globo_verosimilitud.pdf", width: 100%, height: 320pt, fit: "contain")
]

= El _posterior_

Dado nuestro modelo,

$
  Y | theta &~ "Binomial"(n, theta) \
  theta &~ "Uniforme"(0, 1) \
$

y los datos $Y=6$, $n=9$, el _posterior_ se obtiene como:

$
  p(theta | y=6) &prop p(y=6 | theta) p(theta) \ #pause
    &prop binom(9, 6) theta^6 (1-theta)^3 dot 1 \ #pause
    &prop theta^6 (1-theta)^3
$

#pause
Reconocer esta forma nos permite obtener el _posterior_ sin calcular la integral.

= Distribución beta

La beta es una familia de distribuciones para v.a. continuas entre 0 y 1. Notamos:

$ theta ~ "Beta"(alpha, beta), quad alpha > 0, quad beta > 0 $

#pause
Su función de densidad tiene la forma:

$ p(theta) = 1 / B(alpha, beta) theta^(alpha-1) (1-theta)^(beta-1) $

Donde $B(alpha, beta)$ es la función beta y cumple la función de constante de normalización.

#pause
$ EE(theta) = alpha / (alpha + beta) quad
  "Var"(theta) = (alpha beta) / ((alpha + beta)^2 (alpha + beta + 1)) $

= Distribución beta

#align(center)[
  #image("figuras/01/beta_formas.pdf", width: 100%, height: 325pt, fit: "contain")
]

= Modelo beta-binomial

$
  Y | theta &~ "Binomial"(n, theta) \
  theta &~ "Beta"(alpha, beta)
$

#pause
Al multiplicar la verosimilitud por el _prior_:

$
  p(theta | y) &prop theta^y (1-theta)^(n-y) dot theta^(alpha-1) (1-theta)^(beta-1) \ #pause
    &prop theta^(alpha+y-1) (1-theta)^(beta+n-y-1)
$

#pause
#grayed[
  $ theta | y ~ "Beta"(alpha+y, beta+n-y) $
]

= Volviendo a la Tierra...

Partimos de un _prior_ $"Beta"(1,1)$ y observamos 6 aguas y 3 tierras:

$
  theta | y &~ "Beta"(1+6, 1+9-6) \ #pause
    &~ "Beta"(7,4)
$

= Agua en la Tierra

#align(center)[
  #image("figuras/01/globo_posterior.pdf", width: 100%, height: 325pt, fit: "contain")
]

= Agua en la Tierra

Entonces, ¿qué decimos sobre la proporción de agua en la Tierra?

#pause

La respuesta completa es una distribución de probabilidad: $theta | y ~ "Beta"(7, 4)$.

#pause

Sin embargo, podemos resumirla de diferentes maneras #footnote[Implícitamente se minimiza una función de pérdida, lo veremos más adelante.]:

$
  EE(theta | y) = 7\/11 approx 0.636
$

$
  "IC"_(95%) = [0.348, 0.878]
$

- Hay un 95% de probabilidad de que el porcentaje de agua en la Tierra esté entre el 35% y el 88%
#pause
- Tenemos un alto grado de certeza en que el porcentaje de agua en la Tierra está entre el 35% y el 88%

= Agua en la Tierra

#align(center)[
  #image("figuras/01/globo_intervalo.pdf", width: 100%, height: 250pt, fit: "contain")
]

Media: $0.636$ · IC del 95%: $[0.348, 0.878]$.

#text(size: 18pt)[Usamos intervalos centrales, de *colas iguales*: dejan 2.5% de probabilidad en cada cola.]

#inverted-slide[¿Podemos mejorar esta respuesta?\ Parece poco...]

= Más datos, mismo mecanismo

Imaginemos nuevas observaciones del mismo experimento, con una probabilidad de agua constante.

Para este ejemplo hipotético suponemos un valor verdadero $theta = 2/3$:

- 9 ensayos: 6 aguas y 3 tierras.
- 18 ensayos en total: 12 aguas y 6 tierras.
- 30 ensayos en total: 20 aguas y 10 tierras.

#pause
Son resultados posibles, no garantizados. Mantenemos la proporción observada para ver el efecto de tener más datos.

El análisis sigue usando el _prior_ $"Beta"(1,1)$, sin conocer el valor generador.

= Con 18 ensayos

#align(center)[
  #image("figuras/01/globo_mas_datos_18.pdf", width: 100%, height: 240pt, fit: "contain")
]

12 aguas en 18 ensayos: $theta | y ~ "Beta"(13,7)$.

Media: $0.650$ · IC del 95%: $[0.434, 0.837]$.

= Con 30 ensayos

#align(center)[
  #image("figuras/01/globo_mas_datos_30.pdf", width: 100%, height: 240pt, fit: "contain")
]

20 aguas en 30 ensayos: $theta | y ~ "Beta"(21,11)$.

Media: $0.656$ · IC del 95%: $[0.486, 0.808]$.

= Más datos, menor incertidumbre

#align(center)[
  #table(
    columns: 4,
    align: center,
    [*Ensayos*], [*Aguas*], [*Media*], [*IC 95%*],
    [9], [6], [0.636], [[0.348, 0.878]],
    [18], [12], [0.650], [[0.434, 0.837]],
    [30], [20], [0.656], [[0.486, 0.808]],
  )
]

#pause
Con la misma proporción observada, el _posterior_ se concentra y su media se acerca a $2/3$.

Un intervalo más estrecho expresa menor incertidumbre bajo el modelo.

= ¿Y con un _prior_ más informativo?

Volvemos a los datos originales: *6 aguas en 9 ensayos*.

#pause
Comparamos el _prior_ uniforme con $"Beta"(10,10)$.

Ambos tienen media $0.5$, pero $"Beta"(10,10)$ concentra más probabilidad cerca de ese valor.

#pause
Con este nuevo _prior_:

$ theta | y ~ "Beta"(10+6, 10+3) = "Beta"(16,13) $

= Mismos datos, un _prior_ más concentrado

#align(center)[
  #image("figuras/01/globo_prior_informativo.pdf", width: 100%, height: 225pt, fit: "contain")
]

Media: $0.552$ · IC del 95%: $[0.372, 0.725]$.

El _posterior_ queda más cerca de $0.5$ y es más concentrado que con el _prior_ uniforme.

= Un compromiso entre el _prior_ y los datos

El _posterior_ combina la información del _prior_ con la que aportan los datos.

#pause
- Un _prior_ más concentrado tiene más peso frente a una muestra pequeña.
#pause
- Al aumentar la muestra, la verosimilitud suele tener más peso.

#pause
Veamos distintas combinaciones, incluidos resultados en los extremos.

= El peso del _prior_ y los datos

#align(center)[
  #image("figuras/01/globo_compromiso_1.pdf", width: 100%, height: 280pt, fit: "contain")
]

Muestra original: 6 observaciones de agua en 9 intentos.

= Un _prior_ poco concentrado

#align(center)[
  #image("figuras/01/globo_compromiso_2.pdf", width: 100%, height: 280pt, fit: "contain")
]

Muestra hipotética: 3 observaciones de agua en 7 intentos.

= Un _prior_ poco concentrado

#align(center)[
  #image("figuras/01/globo_compromiso_3.pdf", width: 100%, height: 280pt, fit: "contain")
]

Mismo _prior_, más datos: 40 observaciones de agua en 55 intentos.

= Un _prior_ más concentrado

#align(center)[
  #image("figuras/01/globo_compromiso_4.pdf", width: 100%, height: 280pt, fit: "contain")
]

Muestra hipotética: 3 observaciones de agua en 5 intentos.

= Un _prior_ más concentrado

#align(center)[
  #image("figuras/01/globo_compromiso_5.pdf", width: 100%, height: 280pt, fit: "contain")
]

Mismo _prior_, más datos: 30 observaciones de agua en 50 intentos.

= Cuando todos los resultados son iguales

#align(center)[
  #image("figuras/01/globo_compromiso_6.pdf", width: 100%, height: 280pt, fit: "contain")
]

Muestra hipotética: una observación de agua en un intento.

= Cuando todos los resultados son iguales

#align(center)[
  #image("figuras/01/globo_compromiso_7.pdf", width: 100%, height: 280pt, fit: "contain")
]

Muestra hipotética: ninguna observación de agua en 3 intentos.
