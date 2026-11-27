#import "@preview/touying:0.8.0": *
#import "@preview/mannot:0.4.0": mark, annot, tiptoe
#import "@preview/fletcher:0.5.8" as fletcher: node, edge

#import "template.typ": setup-template, highlight-box, grayed, cita
#import "template.typ": c-orange, c-green, c-pink, c-blue, c-gold
#import "template.typ": new-section-slide, inverted-slide, register-section
#import "template.typ": mark-orange, mark-blue, mark-green, mark-pink, mark-gold
#import "template.typ": text-orange, text-blue, text-green, text-pink, text-gold
#import "template.typ": markrect-orange, markrect-blue, markrect-green, markrect-pink, markrect-gold

#let fletcher-diagram = touying-reducer.with(reduce: fletcher.diagram, cover: fletcher.hide)

#let argmax = math.op("arg max", limits: true)
#let argmin = math.op("arg min", limits: true)

#show: setup-template.with(
  handout: sys.inputs.at("handout", default: "false") == "true",
  title: [Estadística bayesiana con PyMC],
  subtitle: [Clase 2: Modelos conjugados],
  footer-label: [Estadística bayesiana con PyMC],
  author: [Tomás Capretto],
)

#new-section-slide[Repaso]

= Repaso: modelo beta-binomial

#align(center)[*¿Cuál es la proporción de agua en la Tierra?*]

El experimento que consiste en girar un globo terráqueo, seleccionar un punto al azar con nuestro dedo y registrar si el resultado es #text-blue([*Agua (A)*]) o #text-orange([*Tierra (T)*]).

#pause

Luego definimos:

- $Y$: cantidad de veces que observamos #text-blue([*A*]) en $n$ ensayos independientes.
- $theta$: proporción de agua, desconocida.

#pause

El modelo observacional es:

#block(width: 100%)[
  $
    Y | theta &~ "Binomial"(n, theta) \
    p(y | theta) &= binom(n, y) theta^y (1-theta)^(n-y)
  $
  #place(right + bottom)[_Función de masa \ de probabilidad_ #v(0.25em)]
]

= Repaso: modelo observacional

El modelo observacional es función de #text-orange[$y$], dados $n$ y $theta$.

#v(-0.5em)
#block(width: 100%)[
  $
  p(#mark-orange($y$) | theta) = binom(n, #mark-orange($y$))
    theta^#mark-orange($y$) (1-theta)^(n-#mark-orange($y$))
  $
  #place(right + horizon)[$n = 3, quad theta = 2\/3$]
]

#v(-0.75em)
#align(center)[
  #image("figuras/02/repaso_modelo_3.pdf", width: 100%, height: 270pt, fit: "contain")
]

= Repaso: modelo observacional

El modelo observacional es función de #text-orange[$y$], dados $n$ y $theta$.

#v(-0.5em)
#block(width: 100%)[
  $
  p(#mark-orange($y$) | theta) = binom(n, #mark-orange($y$))
    theta^#mark-orange($y$) (1-theta)^(n-#mark-orange($y$))
$
  #place(right + horizon)[$n = 9, quad theta = 0.4$]
]
#v(-0.75em)
#align(center)[
  #image("figuras/02/repaso_modelo_9.pdf", width: 100%, height: 270pt, fit: "contain")
]

= Repaso: función de verosimilitud

La verosimilitud es función de #text-blue[$theta$], dados #text-orange[$y$] y #text-orange[$n$].

#v(-0.5em)
#block(width: 100%)[
  $
  p(y | #mark-blue($theta$)) = binom(n, y)
    #mark-blue($theta$)^y (1-#mark-blue($theta$))^(n-y)
$
  #place(right + horizon)[$n = 9, quad y = 3$]
]
#v(-0.75em)
#align(center)[
  #image("figuras/02/repaso_verosimilitud.pdf", width: 100%, height: 270pt, fit: "contain")
]


= Repaso: modelo completo

#block(width: 100%)[
  #align(center + horizon)[$ Y | theta ~ "Binomial"(n, theta) $]
  #place(right + horizon)[#text-orange[*Modelo observacional*]]
]

#block(width: 100%)[
  #align(center + horizon)[$ theta ~ "Beta"(alpha, beta) $]
  #place(right + horizon)[#text-blue[*Prior*]]
]

#pause

Para obtener el _posterior_ estudiamos:

$ p(theta | y) prop p(y | theta) p(theta) $

#pause

y llegamos a:

#block(width: 100%)[
  #align(center + horizon)[
    $
      theta | y ~ "Beta"(
        mark(alpha + y, #<repaso-alpha-n>),
        mark(beta + n - y, #<repaso-beta-n>)
      )
      #annot(<repaso-alpha-n>, pos: bottom, dy: 30pt,
        anchor-inset: 8pt, leader: true, leader-stroke: 1pt + c-green,
        leader-toe: tiptoe.stealth, leader-tip: none,
        annot-text-props: (size: 21pt, fill: c-green))[$alpha_n$]
      #annot(<repaso-beta-n>, pos: bottom, dy: 30pt,
        anchor-inset: 8pt, leader: true, leader-stroke: 1pt + c-green,
        leader-toe: tiptoe.stealth, leader-tip: none,
        annot-text-props: (size: 21pt, fill: c-green))[$beta_n$]
    $
  ]
  #place(right + horizon)[#text-green[*Posterior*]]
]
#v(1.5em)

= Repaso: aprendimos de los datos

Con un _prior_ $"Beta"(1,1)$ e $y = 6$ aguas en $n=9$ ensayos:

$ theta | y ~ "Beta"(7,4) $

#align(center)[
  #image("figuras/02/repaso_posterior.pdf", width: 100%, height: 270pt, fit: "contain")
]

= Repaso: resumir el posterior

#highlight-box(title: [Estimación puntual])[
  Podemos usar una medida de centralidad como la media:
  #v(-0.5em)
  $ EE(theta | y) = (alpha+y)/(alpha+beta+n) = 7/11 approx 0.636 $
]

#pause
#v(-0.5em)
#block(width: 100%)[
 Estimamos que la proporción de agua en la Tierra es *\~64%*.
  #pause
  #place(right + horizon)[
    #set align(center)
    #text(fill: c-orange)[*¡Oculta nuestra\ incertidumbre!*]
  ]
]
#v(-0.25em)
#pause

#highlight-box(title: [Estimación por intervalo])[
  Por ejemplo, a partir de los cuantiles del _posterior_ $"Beta"(7,4)$.\
  Si $F(t) = P(theta <= t | y)$, el cuantil es $Q(q) = F^(-1)(q)$.
  $ "IC"_(95%) = [Q(0.025), Q(0.975)] approx [0.348, 0.878] $
]
#v(-0.25em)

#pause

Asignamos un 95% de probabilidad a que $theta$ esté entre *34.8% y 87.8%*.

= Repaso: _posterior_ $prop$ _prior_ $times$ _verosimilitud_

#align(center)[
  #image("figuras/02/repaso_base.pdf", width: 100%, height: 300pt, fit: "contain")
]


= Repaso: _posterior_ $prop$ _prior_ $times$ _verosimilitud_

#align(center)[
  Mismo prior, más datos

  #image("figuras/02/repaso_mas_datos.pdf", height: 300pt)
]

= Repaso: _posterior_ $prop$ _prior_ $times$ _verosimilitud_

#align(center)[
  Mismos datos, otro prior

  #image("figuras/02/repaso_otro_prior.pdf", height: 300pt)
]

= Repaso: _posterior_ $prop$ _prior_ $times$ _verosimilitud_

#align(center)[
  Cuando solo observamos agua

  #image("figuras/02/repaso_solo_agua.pdf", height: 300pt)
]

= Repaso: _posterior_ $prop$ _prior_ $times$ _verosimilitud_

#align(center)[
  Cuando solo observamos tierra

  #image("figuras/02/repaso_solo_tierra.pdf", height: 300pt)
]

#inverted-slide[¡Continuamos!]
#new-section-slide[Modelo beta-binomial]

= Beta-binomial: interpretación del _prior_

En el modelo beta-binomial, la actualización suma los conteos observados a los parámetros del _prior_:

$ "Beta"(alpha, beta) arrow.r "Beta"(alpha+y, beta+n-y) $

#pause
Podemos interpretar el _prior_ como información equivalente a:

- $alpha$ pseudoconteos de agua (éxitos).
- $beta$ pseudoconteos de tierra (fracasos).

#pause
Su total, $m = alpha + beta$, da una medida del peso del _prior_ en el _posterior_.

#pause
$m = alpha + beta$ es conocido como pseudo tamaño muestral.

= Beta-binomial: media _a posteriori_

En el modelo beta-binomial, la media _a posteriori_ resulta:

$ EE(theta | y) = (alpha+y)/(alpha+beta+n) $

#pause
#v(2em)
$
  EE(theta | y) =
    mark((alpha+beta)/(alpha+beta+n), #<peso-prior>) dot
    mark(alpha/(alpha+beta), #<media-prior>)
    + mark(n/(alpha+beta+n), #<peso-datos>) dot
    mark(y/n, #<media-datos>)

  #annot(<peso-prior>, pos: top, dy: -26.25pt,
    anchor-inset: 8pt, leader: true, leader-stroke: 1pt + c-blue,
    leader-toe: tiptoe.stealth, leader-tip: none,
    annot-text-props: (size: 18pt, fill: c-blue))[Peso del prior]
  #annot(<peso-datos>, pos: top, dy: -33.92pt,
    anchor-inset: 8pt, leader: true, leader-stroke: 1pt + c-orange,
    leader-toe: tiptoe.stealth, leader-tip: none,
    annot-text-props: (size: 18pt, fill: c-orange))[Peso de los datos]
  #annot(<media-prior>, pos: bottom, dy: 26.25pt,
    anchor-inset: 8pt, leader: true, leader-stroke: 1pt + c-blue,
    leader-toe: tiptoe.stealth, leader-tip: none,
    annot-text-props: (size: 18pt, fill: c-blue))[Media a priori]
  #annot(<media-datos>, pos: bottom, dy: 30.95pt,
    anchor-inset: 8pt, leader: true, leader-stroke: 1pt + c-orange,
    leader-toe: tiptoe.stealth, leader-tip: none,
    annot-text-props: (size: 18pt, fill: c-orange))[Media observada]
$
#v(2.75em)

#pause

Es un compromiso entre la media _a priori_ y la proporción observada. \
Sus pesos están dados por la cantidad de información en el _prior_ y en los datos.

#new-section-slide[Un _rookie_ en la NBA]

= Un _rookie_ en la NBA

#grid(
  columns: (0.7fr, 1.8fr),
  gutter: 24pt,
  align: top,
  [
    #align(center)[
      #image("figuras/02/caleb-wilson.png", width: 100%, height: 220pt, fit: "contain")
      #text(size: 16pt)[Caleb Wilson \ Chicago Bulls]
    ]
  ],
  [
    Al 27 de octubre de 2026, Caleb Wilson lleva *4 partidos y unos 135 minutos* en su primera temporada de la NBA.

    Convirtió *17 de sus 23 tiros libres*.

    #pause
    Sea $theta$ la probabilidad de que Caleb Wilson acierte un tiro libre.

    #pause
    ¿Qué podemos decir sobre $theta$? ¿Cómo usamos lo aprendido para predecir nuevos tiros?

    #pause
    ¿Podemos predecir la cantidad de tiros libres que acertará en el futuro?
  ],
)

= Un _rookie_ en la NBA

Suponemos una probabilidad de acierto constante y tiros independientes dado $theta$

$
  Y | theta &~ "Binomial"(23, theta) \
  theta &~ "Beta"(1,1)
$

#pause
Aplicamos la misma actualización:

$
  theta | y &~ "Beta"(1+17, 1+23-17) \ //#pause
    &~ "Beta"(18,7)
$

= Un _rookie_ en la NBA

#align(center)[
  #image("figuras/02/rookie_intervalo.pdf", width: 100%, height: 280pt, fit: "contain")
]

- Media _a posteriori_: $0.72$
- IC del 95%: $[0.53, 0.87]$

#inverted-slide[¿Cuál es la probabilidad de que acierte el siguiente disparo?\ ¿Y los dos siguientes?]

= ¿Cómo podemos predecir?

La pregunta ahora es sobre un resultado futuro: $tilde(Y)$, la cantidad de aciertos en *dos nuevos tiros*.

Suponemos que el modelo binomial sigue siendo válido para los tiros futuros, con el mismo $theta$.

#pause
Una idea es «enchufar» una estimación puntual de $theta$, por ejemplo la media _a posteriori_:

#pause
$ hat(theta) = EE(theta | y) = 18/25 = 0.72 $

#pause
Fijamos ese valor y predecimos con:

$ tilde(Y) | theta=0.72 ~ "Binomial"(2, 0.72) $

= Predicción con un valor fijo de $theta$

$ p(tilde(y) | theta=0.72) = binom(2, tilde(y)) 0.72^tilde(y) (1-0.72)^(2-tilde(y)) $

#grid(
  columns: (400pt, 1fr),
  column-gutter: 40pt,
  [
    #set align(center)
    #image("figuras/02/rookie_plugin_2.pdf", height: 275pt)
  ],
  [
    #v(1em)
    Este procedimiento se conoce como predicción *_plug-in_*.
  ],
)

= ¿Tiene sentido usar el _plug-in_?

Después de observar los datos, todavía tenemos incertidumbre sobre $theta$:

$ theta | y ~ "Beta"(18,7) $

#pause
Reemplazarla por $hat(theta) = 0.72$ implica actuar como si conociéramos $theta$ con certeza.

#pause
La binomial resultante incorpora la variabilidad de los tiros dado ese valor, pero omite la incertidumbre que queda sobre $theta$.

#v(1em)

#pause
#grayed[
  ¿Cómo usamos toda la distribución _a posteriori_ para predecir?
]

= Predecir en base al modelo completo

Para los dos nuevos tiros, usamos el modelo completo:

$
  tilde(Y) | theta &~ "Binomial"(n=2, theta) \
  theta | y &~ "Beta"(18,7)
$

#pause
Promediamos sobre la incertidumbre que queda en $theta$:

$ p(tilde(y) | y) = integral_0^1 p(tilde(y) | theta) p(theta | y) dif theta $

Esta es la *distribución predictiva _a posteriori_*.

= Un _rookie_ en la NBA

Dado $theta$, los tiros son independientes.

$ P(tilde(Y)=2 | theta) = binom(2,2) theta^2 (1-theta)^0 = theta dot theta = theta^2 $

#pause

#block(width: 100%)[
$
  P(tilde(Y)=2 | y) &= integral_0^1 theta^2 p(theta | y) dif theta \ //#pause
    &= EE(theta^2 | y) = (alpha_n (alpha_n+1))/((alpha_n+beta_n)(alpha_n+beta_n+1)) \ //#pause
    &= (18 dot 19)/(25 dot 26) approx 0.526
$
  #uncover("3-")[
    #place(right + horizon)[
      #block(width: 130pt)[
        #set text(size: 16pt)
        $alpha_n=18$, $beta_n=7$: parámetros de la beta _a posteriori_.
      ]
    ]
  ]
]

#pause
Usar solo la media daría $0.72^2 = 0.5184$

= ¿Y para cualquier valor?

¿Cuál es la probabilidad de acertar $k$ de los próximos $m$ tiros?

#pause
Recordemos el modelo completo:

$
  tilde(Y) | theta &~ "Binomial"(m,theta) \
  theta | y &~ "Beta"(alpha_n,beta_n)
$

#pause
La probabilidad que buscamos se obtiene integrando sobre $theta$:

$ P(tilde(Y)=k | y) = integral_0^1 P(tilde(Y)=k | theta) p(theta | y) dif theta $

= Sustituimos el modelo y el posterior

El modelo para los nuevos tiros y la densidad _a posteriori_ son:

$
  P(tilde(Y)=k | theta) = binom(m,k) theta^k (1-theta)^(m-k), quad quad quad
  p(theta | y) = (theta^(alpha_n-1) (1-theta)^(beta_n-1))/B(alpha_n,beta_n)
$
#pause
Los sustituimos en la integral predictiva:
#v(-0.25em)

$
  P(tilde(Y)=k | y) = integral_0^1 binom(m,k) theta^k (1-theta)^(m-k)
    (theta^(alpha_n-1) (1-theta)^(beta_n-1))/B(alpha_n,beta_n) dif theta
$
#v(-0.25em)
#pause
Y se obtiene la masa de una distribución *beta-binomial*:

$
  P(tilde(Y)=k | y) = binom(m,k) (B(alpha_n+k,beta_n+m-k))/B(alpha_n,beta_n)
$

= La función de masa de la beta-binomial

Si $tilde(Y) | y ~ "BetaBinomial"(m,alpha_n,beta_n)$, su pmf es:

$ P(tilde(Y)=k | y) = binom(m,k) (B(alpha_n+k,beta_n+m-k))/B(alpha_n,beta_n) $

para $k=0,1,dots,m$, con $m$ entero no negativo y $alpha_n,beta_n>0$.

#pause
- $m$: cantidad de intentos.
#pause
- $alpha_n,beta_n$: parámetros de la beta _a posteriori_, que incorporan el _prior_ y los datos.
#pause
- $B$: función beta, que aparece al integrar la probabilidad de acierto.

Para Caleb: $tilde(Y) | y ~ "BetaBinomial"(m,18,7)$.

= ¿Qué describe la beta-binomial?

Es una *mezcla de binomiales* que promedia las predicciones para distintos valores de $theta$ usando su distribución _a posteriori_.

Si $mu=alpha_n\/(alpha_n+beta_n)$ y $s=alpha_n+beta_n$:

$
  EE(tilde(Y) | y) &= m mu \
  "Var"(tilde(Y) | y) &= m mu(1-mu) (s+m)/(s+1)
$

Tiene la misma media que una $"Binomial"(m, mu)$, pero para $m>1$, mayor varianza.

#pause
Cuanto más concentrada está la beta _a posteriori_, más se parece la predictiva a una binoamial esa binomial.

= Distribución predictiva con $m=2$

#align(center)[
  #image("figuras/02/rookie_comparacion_2.pdf", width: 100%, height: 300pt, fit: "contain")
]

#v(-0.5em)
#align(center)[
  #grid(
    columns: (210pt, 210pt), align: center,
    text-blue[$ "Var"(tilde(Y) | hat(theta)) = 0.4032 $],
    text-green[$ "Var"(tilde(Y) | y) approx 0.4187 $],
  )
]

= Distribución predictiva con $m=20$

#align(center)[
  #image("figuras/02/rookie_comparacion_20.pdf", width: 100%, height: 300pt, fit: "contain")
]

#v(-0.5em)
#align(center)[
  #grid(
    columns: (210pt, 210pt),
    align: center,
    text-blue[$ "Var"(tilde(Y) | hat(theta)) = 4.032 $],
    text-green[$ "Var"(tilde(Y) | y) approx 6.978 $],
  )
]
#inverted-slide[
  ¿Incertidumbre epistémica?

  #pause
  ¿Incertidumbre aleatoria?

  #pause
  Sigamos...
]

= Un _rookie_ en la NBA

Para 20 nuevos tiros, ¿cuál es la probabilidad de que acierte *más de 15*?

#grid(
  columns: (410pt, 1fr), column-gutter: 24pt, align: horizon,
  image("figuras/02/rookie_predictiva_20.pdf", height: 300pt),
  [],
)

= Un _rookie_ en la NBA

Para 20 nuevos tiros, ¿cuál es la probabilidad de que acierte *más de 15*?

#grid(
  columns: (410pt, 1fr), column-gutter: 24pt, align: horizon,
  image("figuras/02/rookie_predictiva_20_suma.pdf", height: 300pt),
  [
    #pause
    $
      P(tilde(Y) > 15 | y)
        &= sum_(k=16)^20 p(tilde(Y)=k | y) \
        &approx 0.366
    $
  ],
)

= Un _rookie_ en la NBA: el desafío

#align(center)[
  #image("figuras/02/cooper-flagg.png", width: 100%, height: 160pt, fit: "contain")
  Cooper Flagg · Dallas Mavericks
]

En 2025-2026 fue el _rookie_ con más tiros libres convertidos: *283 aciertos en 342 intentos*.

#pause
Si Caleb terminara con 342 intentos en total, ¿qué probabilidad tendría de superar esos 283 aciertos?

= Un _rookie_ en la NBA: el desafío

Primero podemos comparar $theta$ con la proporción observada de Flagg:

$ theta_0 = 283\/342 approx 0.827 $

#pause
$
  P(theta > theta_0 | y) &= integral_(theta_0)^1 p(theta | y) dif theta \
    &approx 0.1055
$

#pause
Pero... esta pregunta es sobre $theta$.

Para comparar cantidades de aciertos usamos la distribución predictiva.

= Un _rookie_ en la NBA: el desafío

Ya convirtió *17 de 23 tiros*. Si termina con 342 intentos, le quedan $342-23=319$.

#pause
Sea $tilde(Y)$ la cantidad de aciertos en esos *319 tiros futuros*:

$ tilde(Y) | y ~ "BetaBinomial"(319,18,7) $

#pause
Su cantidad final de aciertos será $17+tilde(Y)$. Superar los 283 de Flagg requiere:

$ 17+tilde(Y)>283 quad arrow.double.l.r quad tilde(Y)>=267 $

Necesita *al menos 267 nuevos aciertos*: $17+267=284$ en total.

= Un _rookie_ en la NBA: el desafío

Sumamos las masas beta-binomiales para todos los resultados favorables: $267,268,dots,319$ nuevos aciertos.

$
  P(17 + tilde(Y) > 283 | y) &= P(tilde(Y) >= 267 | y) \
    &= sum_(k=267)^319 P(tilde(Y)=k | y) #pause
    approx 0.0964
$

#v(1em)
#pause
#grayed[
  La probabilidad de que Caleb Wilson convierta más tiros libres que Cooper Flagg el año anterior, si realiza la misma cantidad de disparos, es de aproximadamente *9.64%*.

  #pause
  ¡Dados todos los supuestos que hicimos!
]

#new-section-slide[Momento de reflexionar]

= Momento de reflexionar

Si hacemos explícito el modelo $cal(M)$:

$ p(theta | y, cal(M)) prop p(y | theta, cal(M)) p(theta | cal(M)) $

#pause
La regla de Bayes actualiza la incertidumbre *dentro del modelo*.\
Que disminuya la incertidumbre del _posterior_ no garantiza que el modelo sea adecuado.

#pause
Para estimar el agua en la Tierra, supusimos que los puntos se eligen de manera independiente y uniforme sobre la superficie.

#pause
Para estimar la probabilidad de Wilson acierte un tiro libre, asumimos que los tiros son independientes entre sí y que tienen la misma probabilidad de ser convertidos.
Esos supuestos también se utilizaron para predecir la cantidad de aciertos futuros
y si superará al mejor _rookie_ de la temporada anterior.

= Momento de reflexionar

La regla de Bayes indica cómo actualizar un modelo. Construirlo requiere otras decisiones.

#pause
Elegimos qué representar, qué información incorporar y qué simplificaciones aceptar.

#pause

En el ejemplo del globo, también podríamos:

#pause
- Revisar cómo se seleccionan los puntos y si el modelo representa ese procedimiento.
#pause
- Evaluar cuánto cambian las conclusiones al usar otro _prior_ razonable.

#new-section-slide[Resumen]

= Del modelo a las respuestas

Especificamos un modelo para las observaciones y un _prior_:

$ p(y, theta) = p(y | theta) p(theta) $

#pause
Actualizamos la incertidumbre sobre el parámetro:

$ p(theta | y) prop p(y | theta) p(theta) $

#pause
*El _posterior_ es la respuesta bayesiana completa*. Todo lo que
sabemos del parámetro dado el modelo y los datos, está allí.
#pause
En la práctica, se suele resumir usando resúmenes puntuales o de intervalo.

#pause
Para predecir un resultado nuevo, promediamos sobre esa incertidumbre:

$ p(tilde(y) | y) = integral_Theta p(tilde(y) | theta) p(theta | y) dif theta $

#new-section-slide[Familias conjugadas]

= Familias conjugadas

#register-section[Modelos conjugados]

Una familia de distribuciones $cal(F)$ es *conjugada* con una verosimilitud $cal(L)$ si para todo _prior_ de esa familia el _posterior_ también pertenece a $cal(F)$.

#pause
$
  p(theta) in cal(F) quad arrow.double.r quad p(theta | y) in cal(F) \
  "siempre que" p(y | theta) in cal(L)
$

#pause

La familia Beta es conjugada con la verosimilitud Binomial
#pause
(cuando se desconoce $theta$ y $n$ está fijo).

#pause

Hay muchos otros ejemplos de familias conjugadas.

#pause
Veamos el modelo *gamma-Poisson*.

= Distribución de Poisson

Sea $Y$ la cantidad de veces que se observa un evento en un intervalo de tiempo, longitud, superficie, volumen, etc. Un modelo posible es:

#pause
$ Y | lambda ~ "Poisson"(lambda), quad y = 0, 1, 2, dots $

#pause
Suponemos $n$ v. a. independientes dado $lambda > 0$. Luego:

#pause
$
  p(y_i | lambda) = (lambda^(y_i) e^(-lambda))/(y_i !)\
  quad EE(Y_i | lambda) = VV(Y_i | lambda) = lambda
$

Así, $lambda$ es la cantidad esperada de eventos por unidad de exposición (día, metro, hectárea, etc.),
y también la varianza.

= Poisson: modelo observacional

El modelo observacional es función de #text-orange[$y$], dado $lambda$.

#v(-0.5em)
#block(width: 100%)[
  $ p(#mark-orange($y$) | lambda) = (lambda^(#mark-orange($y$)) e^(-lambda))/(#mark-orange($y$) !) $
  #place(right + horizon)[$lambda = 3$]
]
#v(-1.25em)
#align(center)[
  #image("figuras/02/gamma_modelo.pdf", height: 270pt)
]

= Poisson: función de verosimilitud

Para el vector $bold(y) = (y_1, dots, y_n)$, la independencia condicional permite escribir:

$ p(bold(y) | lambda) = product_(i=1)^n p(y_i | lambda)
  = (lambda^(sum_(i=1)^n y_i) e^(-n lambda))/(product_(i=1)^n y_i !) $

#pause
Como en la binomial, la misma expresión tiene dos lecturas:

- Con $lambda$ fijo, describe las probabilidades de los datos.
- Con los datos fijos, es la verosimilitud de $lambda$.

#pause
Como función de $lambda$:

$ p(bold(y) | lambda) prop lambda^(sum_(i=1)^n y_i) e^(-n lambda) $

= Función de verosimilitud

La verosimilitud es función de #text-blue[$lambda$], dado el vector de datos #text-orange[$bold(y)$].

#v(-0.5em)
#block(width: 100%)[
  $ p(bold(y) | #mark-blue($lambda$)) = (#mark-blue($lambda$)^10 e^(-4 #mark-blue($lambda$)))/288 $
  #place(right + horizon)[
    #align(left)[
      $bold(y) = (1, 3, 2, 4)$ \
      $n = 4$
    ]
  ]
]
#v(-0.75em)
#align(center)[
  #image("figuras/02/gamma_verosimilitud.pdf", height: 270pt)
]

= Modelo _a priori_ para $lambda$

Para $lambda$ elegimos un _prior_ gamma, con parametrización *forma-tasa* (shape-rate):

$ lambda ~ "Gamma"(alpha, beta), quad alpha > 0, quad beta > 0 $

$ p(lambda) = (beta^alpha)/(Gamma(alpha)) lambda^(alpha-1) e^(-beta lambda), quad lambda > 0 $

#pause
$ EE(lambda) = alpha/beta, quad "Var"(lambda) = alpha/beta^2 $

$alpha$ controla la forma y $beta$ la tasa de la gamma.

= Modelo _a priori_ para $lambda$

Distintas elecciones de los hiperparámetros $alpha$ y $beta$:

#align(center)[
  #image("figuras/02/gamma_prior_ejemplos.pdf", height: 300pt)
]

= Modelo gamma-Poisson

#v(-1.5em)
#align(horizon)[
  #set text(size: 30pt)
  $
    y_i | lambda &~ "Poisson"(lambda) \
    lambda &~ "Gamma"(alpha, beta) \
    lambda | bold(y) &~ "       " ¿?
  $
]


= Modelo gamma-Poisson: el _posterior_

Se multiplica la verosimilitud y el _prior_, omitiendo factores que no dependen de $lambda$:

$
  p(lambda | bold(y)) &prop p(bold(y) | lambda) p(lambda) \
    &prop lambda^(sum_(i=1)^n y_i) e^(-n lambda) dot lambda^(alpha-1) e^(-beta lambda) \
    &= lambda^(alpha + sum_(i=1)^n y_i - 1) e^(-(beta+n) lambda)
$

#pause
Esta expresión es el _kernel_ de una gamma:

$
  lambda | bold(y) ~ "Gamma"(
    mark(alpha + sum_(i=1)^n y_i, #<gamma-alpha-n>),
    mark(beta+n, #<gamma-beta-n>)
  )
  #annot(<gamma-alpha-n>, pos: bottom, dy: 14pt,
    anchor-inset: 6pt, leader: true, leader-stroke: 1pt + c-green,
    leader-toe: tiptoe.stealth, leader-tip: none,
    annot-text-props: (size: 21pt, fill: c-green))[$alpha_n$]

  #annot(<gamma-beta-n>, pos: bottom, dy: 34.56pt,
    anchor-inset: 6pt, leader: true, leader-stroke: 1pt + c-green,
    leader-toe: tiptoe.stealth, leader-tip: none,
    annot-text-props: (size: 21pt, fill: c-green))[$beta_n$]
$
#v(2em)

La familia gamma es conjugada para la verosimilitud Poisson.

= Balance entre _prior_ y datos

La media _a posteriori_:

#v(-0.5em)
$
  EE(lambda | bold(y)) = (alpha + sum_(i=1)^n y_i)/(beta+n)
  = beta/(beta+n) alpha/beta + n/(beta+n) overline(y)
$

es un promedio ponderado de la media _a priori_ y la media muestral.

#pause
Los parámetros del _prior_ pueden interpretarse como:
- $beta$: número de pseudo-observaciones (tamaño de muestra equivalente _a priori_).
- $alpha$: total de pseudo-eventos en esas observaciones.

#new-section-slide[Llamadas sospechosas]

= Llamadas sospechosas

Sea $Y$ la cantidad de llamadas sospechosas que se registran en un día.
Los autores de _Bayes Rules!_ registraron la cantidad de llamadas sospechosas en cuatro días de la segunda semana de agosto.

#pause
Queremos conocer $lambda$, la tasa de llamadas sospechosas por día.

Suponemos conteos Poisson, independientes dado $lambda$, y una tasa constante durante esos días.

#pause

¿Que _prior_ podemos utilizar?

= Llamadas sospechosas: el _prior_

#pause
Elegimos $lambda ~ "Gamma"(2, 1)$.

#v(-0.5em)
#align(center)[
  #image("figuras/02/gamma_prior_llamadas.pdf", height: 240pt)
]

Este _prior_ tiene una media de $2$ llamadas por día y asigna un 95% de probabilidad
a que $lambda$ esté entre $0.24$ y $5.57$ llamadas por día.

= Llamadas sospechosas: el _posterior_

Los conteos observados fueron:

$ bold(y) = (6, 2, 2, 1), quad n = 4, quad sum_(i=1)^4 y_i = 11 $

El modelo completo es:

$
  Y_i | lambda &~ "Poisson"(lambda), quad i=1,dots,4 \
  lambda &~ "Gamma"(2,1)
$

#pause
Y el _posterior_ resulta:

$
  lambda | bold(y) &~ "Gamma"(2+11, 1+4) \
    &~ "Gamma"(13,5)
$


= Llamadas sospechosas

#align(center)[
  #image("figuras/02/gamma_actualizacion.pdf", height: 300pt)
]

#new-section-slide[¿Cómo resumir el _posterior_?]

= Resumir el _posterior_: estimación puntual

El _posterior_ es la respuesta bayesiana completa sobre $lambda$, dados el modelo, el _prior_ y los datos.

#pause
Podemos resumirlo con una estimación puntual:

- *Media*: $EE(lambda | bold(y)) = alpha_n\/beta_n = 2.6$.
- *Mediana*: $P(lambda <= m | bold(y)) = 0.5$, con $m approx 2.534$.
- *Moda*: maximiza la densidad _a posteriori_: $(alpha_n-1)\/beta_n approx 2.4$, ya que $alpha_n > 1$.

#pause

= Media, mediana y moda

#align(center)[
  #image("figuras/02/gamma_resumenes.pdf", height: 300pt)
]

= ¿Qué estimación puntual elegimos?

Un *estimador* $hat(lambda)$ utiliza los datos $bold(y)$ para aproximar un parámetro desconocido $lambda$.
#pause
La *función de pérdida* $L(lambda, hat(lambda))$ mide el costo del error que cometemos al usar $hat(lambda)$ para estimar el verdadero $lambda$.


#pause
El *riesgo _a posteriori_* de un estimador $hat(lambda)$ es el valor esperado de la pérdida $L(lambda,hat(lambda))$, calculado respecto del _posterior_ de $lambda$.

#v(-0.25em)
$
  rho(hat(lambda) | bold(y)) &= EE[L(lambda,hat(lambda)) | bold(y)] = integral L(lambda,hat(lambda)) p(lambda | bold(y)) dif lambda
$
#v(-0.25em)

#pause
El *estimador de Bayes* es aquel que minimiza ese riesgo _a posteriori_:
#v(-0.25em)

$ hat(lambda)_("Bayes") = argmin_(hat(lambda)) rho(hat(lambda) | bold(y)) $

Elegimos el $hat(lambda)$ que minimiza la pérdida esperada bajo el _posterior_.

= Pérdida cuadrática

La media minimiza el riesgo _a posteriori_ $rho(hat(lambda) | bold(y)) = EE[(lambda - hat(lambda))^2 | bold(y)]$.

#align(center)[
  #image("figuras/02/gamma_perdida_cuadratica.pdf", height: 300pt)
]

= Pérdida absoluta

La mediana minimiza el riesgo _a posteriori_ $rho(hat(lambda) | bold(y)) = EE[abs(lambda-hat(lambda)) | bold(y)]$.

#align(center)[
  #image("figuras/02/gamma_perdida_absoluta.pdf", height: 300pt)
]

= ¿Y la moda _a posteriori_?

La moda _a posteriori_ (MAP) maximiza la densidad del _posterior_:

$ hat(lambda)_("MAP") = argmax_lambda p(lambda | bold(y)) = 12/5 = 2.4 $

En el caso discreto, minimiza la pérdida 0–1: 0 al acertar y 1 al equivocarse.

#pause
En este caso continuo, la probabilidad de acertar un valor exacto es 0. Por eso, consideramos una tolerancia $epsilon > 0$:

$ L_epsilon(lambda,hat(lambda)) = cases(0 & "si" abs(lambda-hat(lambda)) <= epsilon, 1 & "si" abs(lambda-hat(lambda)) > epsilon) $

= Pérdida 0–1 con tolerancia

Con $epsilon=0.1$, el mínimo está en $hat(lambda) approx 2.401$. Para este _posterior_, tiende a la moda $2.4$ cuando $epsilon$ tiende a cero.

#align(center)[
  #image("figuras/02/gamma_perdida_tolerancia.pdf", height: 270pt)
]

= #text(size: 34pt)[Resumir el _posterior_: estimación por intervalo]

#pause
Un intervalo de credibilidad de nivel $1-a$, con $0 < a < 1$, es $"IC"_(1-a) = [l,u]$ y satisface:

$ P(l <= lambda <= u | bold(y)) = integral_l^u p(lambda | bold(y)) dif lambda = 1-a $

#pause
Hay muchos intervalos que contienen esa probabilidad.

Necesitamos un criterio para elegir los extremos.

¿Cómo distribuimos la probabilidad $a$ que queda afuera?

= Intervalo de colas iguales: ETI

Si $Q$ es la función de cuantil, dejamos una probabilidad $a\/2$ en cada cola:

$ "IC"_("ETI", 1-a) = [Q(a\/2), Q(1-a\/2)] $

#pause
Para un 95% de credibilidad, $a=0.05$:

$ "IC"_("ETI", 0.95) = [Q(0.025), Q(0.975)] $

Es el intervalo central que ya usamos con la beta.

#pause
Las colas tienen la misma probabilidad.

#pause
Eso no implica que el intervalo sea simétrico alrededor de la media.

= Intervalo de máxima densidad: HDI

El *HDI* es el intervalo más corto que contiene una probabilidad $1-a$.#footnote[La situación es distinta para distribuciones multimodales.]

La densidad dentro del intervalo es al menos tan alta como fuera.

#pause
$
  min_(l < u) & (u - l) "sujeto a" & P(l <= lambda <= u | bold(y)) >= 1-a
$

No exige dejar la misma probabilidad en cada cola.

#pause

En esta gamma, continua y unimodal, también se cumple $p(l | bold(y)) = p(u | bold(y))$.

= Modelo gamma-Poisson: ETI vs HDI

#grid(
  columns: (480pt, 1fr), column-gutter: 24pt, align: horizon,
  image("figuras/02/gamma_intervalos.pdf", height: 300pt),
  [
    $
      "IC"_("ETI", 95%) approx [1.384, 4.192] \
      "IC"_("HDI", 95%) approx [1.279, 4.038]
    $

    Longitudes:

    - ETI: *2.808*
    - HDI: *2.759*

  ],
)

= ETI vs HDI en distribución de  cola pesada

#register-section[ETI y HDI]

Usemos ahora una gamma inversa con $alpha=2$, $beta=1$:

$ theta ~ "GammaInversa"(2,1), quad p(theta) = theta^(-3) e^(-1/theta), quad theta > 0 $

Su densidad decrece como $1/theta^3$ para valores grandes de $theta$: tiene una cola pesada.

#pause
Para el ETI del 95%, usamos los cuantiles:

$ "IC"_("ETI", 0.95) = [Q(0.025), Q(0.975)] approx [0.179, 4.129] $

Para el HDI del 95%, buscamos el IC de menor ancho $u-l$ que contenga un 95% de probabilidad _a posteriori_:

$ "IC"_("HDI", 0.95) approx [0.095, 2.824] $

= ETI vs HDI en distribución de  cola pesada

#align(center)[
  #image("figuras/02/gamma_inversa_intervalos.pdf", height: 350pt)
]


#new-section-slide[El modelo normal-normal]

= Normal–normal: el modelo observacional

Sea $Y_i$ una medición continua y $mu$ su media desconocida.

$ Y_i | mu ~ "Normal"(mu, sigma^2), quad i=1,dots,n, quad y_i in RR $

Suponemos mediciones independientes dado $mu$  y $sigma^2$ *conocida*.

#pause
$sigma^2$ describe la variabilidad entre mediciones.

La incertidumbre sobre $mu$ se representa con otra distribución.


= Normal-normal: la verosimilitud

Para $bold(y)=(y_1,dots,y_n)$:

$ p(bold(y) | mu) = product_(i=1)^n p(y_i | mu)
  = (2 pi sigma^2)^(-n/2) exp[-(sum_(i=1)^n (y_i-mu)^2)/(2 sigma^2)] $

#pause
Con $mu$ fijo, es una densidad sobre los datos continuos.

#pause
Con $bold(y)$ fijo, es la verosimilitud de $mu$, que resulta:


$ p(bold(y) | mu) prop exp[-n/(2 sigma^2) (mu-overline(y))^2] $

Tiene forma normal en $mu$, pero no es una distribución sobre $mu$.

= Modelo normal-normal

Suponemos observaciones independientes dado $mu$:

#grid(
  columns: (390pt, 1fr),
  column-gutter: 24pt,
  align: left + horizon,
  [
    $
      Y_i | mu &~ "Normal"(mu, sigma^2), quad i=1,dots,n \
      mu &~ "Normal"(mu_0, tau_0^2)
    $
  ],
  [
    $sigma^2>0$: varianza conocida.
    #v(0.5em)
    $mu_0$: media _a priori_.\
    $tau_0^2$: varianza _a priori_ de $mu$.
  ],
)

#pause
Se puede demostrar que el _posterior_ es:

$ mu | bold(y) ~ "Normal"(mu_n, tau_n^2) $

$ mu_n = tau_n^2 (mu_0/tau_0^2 + (n overline(y))/sigma^2), quad
  tau_n^2 = (1/tau_0^2 + n/sigma^2)^(-1) $

= Normal-normal: la media _a posteriori_

#v(3em)
$
  mu_n = mark((1/tau_0^2)/(1/tau_0^2+n/sigma^2), #<normal-peso-prior>)
    mark(mu_0, #<normal-media-prior>)
    + mark((n/sigma^2)/(1/tau_0^2+n/sigma^2), #<normal-peso-datos>)
    mark(overline(y), #<normal-media-datos>)
  #annot(<normal-peso-prior>, pos: top, dx: -55pt, dy: -30pt, anchor-inset: 8pt,
    leader: true, leader-connect: (top, bottom),
    leader-stroke: 1pt + c-blue, leader-toe: tiptoe.stealth,
    leader-tip: none, annot-text-props: (size: 21pt, fill: c-blue))[Peso del prior]
  #annot(<normal-peso-datos>, pos: top, dx: 60pt, dy: -46pt, anchor-inset: 8pt,
    leader: true, leader-connect: (top, bottom),
    leader-stroke: 1pt + c-orange, leader-toe: tiptoe.stealth,
    leader-tip: none, annot-text-props: (size: 21pt, fill: c-orange))[Peso de los datos]
  #annot(<normal-media-prior>, pos: bottom, dx: -65pt, dy: 36pt, anchor-inset: 8pt,
    leader: true, leader-connect: "elbow",
    leader-stroke: 1pt + c-blue, leader-toe: tiptoe.stealth,
    leader-tip: none, annot-text-props: (size: 21pt, fill: c-blue))[Media del prior]
  #annot(<normal-media-datos>, pos: bottom, dx: 65pt, dy: 40pt, anchor-inset: 8pt,
    leader: true, leader-connect: "elbow",
    leader-stroke: 1pt + c-orange, leader-toe: tiptoe.stealth,
    leader-tip: none, annot-text-props: (size: 21pt, fill: c-orange))[Media de los datos]
$
#v(2em)
Los pesos suman 1. La media _a posteriori_ combina $mu_0$ y $overline(y)$.

- Un _prior_ con menor varianza $tau_0^2$ tiene más peso.
- Más observaciones o menor varianza $sigma^2$ dan más peso a los datos.

= Normal-normal: la varianza _a posteriori_

La incertidumbre sobre $mu$ combina la información del _prior_ y de la media muestral:

$ 1/tau_n^2 = 1/tau_0^2 + 1/(sigma^2/n) $

- $tau_0^2$: varianza _a priori_ de $mu$.
- $sigma^2/n$: varianza de la media muestral $overline(Y)$, dado $mu$.
- $tau_n^2$: varianza _a posteriori_ de $mu$.

La varianza _a posteriori_ es menor que cada una de las dos varianzas que combinamos. Disminuye al aumentar $n$.

#new-section-slide[Velocidad de internet]

= Velocidad de internet

Un proveedor promete una *velocidad media de descarga de al menos 20 Mbit/s*.

Suponemos que el desvío entre mediciones es conocido: $sigma=5$ Mbit/s.

Sea $Y_i$ una medición de velocidad bajo condiciones estables:

$ Y_i | mu ~_"iid" "Normal"(mu, 5^2) $

¿Qué podemos decir sobre esa media?

¿Y sobre la velocidad que observar en el futuro?

= Internet: el modelo observacional

La densidad es función de #text-orange[$y_i$], con $mu=20$ y $sigma=5$ fijos.

#v(-0.5em)

#align(center)[#image("figuras/02/normal_modelo.pdf", height: 270pt)]

= Velocidad de internet: el _prior_

Elegimos un _prior_ para la velocidad media:

$ mu ~ "Normal"(20, 7^2) $

La media _a priori_ es *20 Mbit/s* y el desvío _a priori_ es *7 Mbit/s*.
Este desvío expresa incertidumbre sobre $mu$.

Por otro lado, $sigma=5$ describe la variabilidad entre mediciones.

El modelo completo es:

$
  Y_i | mu &~ "Normal"(mu, 5^2) \
  mu &~ "Normal"(20, 7^2)
$

= Velocidad de internet: los datos

Observamos cinco mediciones de velocidad:

$ bold(y) = (15.77, 20.50, 8.26, 14.37, 21.09) " Mbit/s" $

Su tamaño muestral y su media son:

$ n=5, quad overline(y) approx 16.00 " Mbit/s" $

= Internet: la verosimilitud

La verosimilitud es función de #text-blue[$mu$], dado el vector #text-orange[$bold(y)$].

$ bold(y) = (15.77, 20.50, 8.26, 14.37, 21.09), quad sigma=5 $

#align(center)[#image("figuras/02/normal_verosimilitud.pdf", height: 270pt)]

= Velocidad de internet: la actualización

Sustituimos en las fórmulas que obtuvimos:

$ tau_n^2 = (1/49+5/25)^(-1) approx 4.54 $

$ mu_n = (20/49 + (5 dot overline(y))/25)/(1/49+5/25) approx 16.37 $

#pause
$ mu | bold(y) ~ "Normal"(16.37, 4.54) $

La media _a posteriori_ es *16.37 Mbit/s* y su desvío es *2.13 Mbit/s*.

¿Cómo podríamos saber qué afecta más a la media del _posterior_?

= Internet: _prior_, verosimilitud y _posterior_

#align(center)[#image("figuras/02/normal_actualizacion.pdf", height: 300pt)]

= ¿La media es menor que 20 Mbit/s?

#grid(
  columns: (480pt, 1fr), column-gutter: 24pt, align: horizon,
  image("figuras/02/normal_intervalo.pdf", height: 270pt),
  [
    $ P(mu < 20 | bold(y)) approx 0.96 $

    IC del 95%:\ *[12.19, 20.54]* Mbit/s.

  ],
)

= ¿Cómo interpretamos la respuesta?

Dados el modelo, el desvío supuesto y el _prior_, asignamos aproximadamente
un *95.59%* de probabilidad a que la velocidad media sea menor que 20 Mbit/s.

#pause
El intervalo del 95% para $mu$ incluye 20. Son dos resúmenes distintos del mismo _posterior_: no hay contradicción.

#pause

= Predecir una nueva medición

Sea $tilde(Y)$ una nueva velocidad, bajo las mismas condiciones:

$ tilde(Y) | mu ~ "Normal"(mu, sigma^2) $

Suponemos que es independiente de las mediciones anteriores dado $mu$.
Promediamos sobre el _posterior_, como hicimos con la beta-binomial:

#v(0.75em)
$
 p(tilde(y) | bold(y)) = integral_(-infinity)^infinity
   mark(p(tilde(y) | mu), #<normal-modelo-futuro>)
   mark(p(mu | bold(y)), #<normal-posterior-media>) dif mu
 #annot(<normal-modelo-futuro>, pos: bottom, dx: -60pt, dy: 30pt, anchor-inset: 8pt,
   leader: true, leader-stroke: 1pt + c-orange, leader-tip: none,
   annot-text-props: (size: 21pt, fill: c-orange))[Modelo para la nueva\ medición]
 #annot(<normal-posterior-media>, pos: bottom, dx: 90pt, dy: 30pt, anchor-inset: 8pt,
   leader: true, leader-stroke: 1pt + c-blue, leader-tip: none,
   annot-text-props: (size: 21pt, fill: c-blue))[Posterior de la media]
$

= La predictiva _a posteriori_ también es normal

Al integrar obtenemos:

$ tilde(Y) | bold(y) ~ "Normal"(mu_n, sigma^2+tau_n^2) $

#v(1em)
$
 "Var"(tilde(Y) | bold(y)) =
   mark(sigma^2, #<normal-var-mediciones>) + mark(tau_n^2, #<normal-var-media>)
 #annot(<normal-var-mediciones>, pos: bottom, dx: -100pt, dy: 30pt, anchor-inset: 8pt,
   leader: true, leader-stroke: 1pt + c-orange, leader-tip: none,
   annot-text-props: (size: 21pt, fill: c-orange))[Variabilidad de las\ mediciones]
 #annot(<normal-var-media>, pos: bottom, dx: 95pt, dy: 30pt, anchor-inset: 8pt,
   leader: true, leader-stroke: 1pt + c-blue, leader-tip: none,
   annot-text-props: (size: 21pt, fill: c-blue))[Incertidumbre sobre\ la media]
$
#v(3em)
Para internet: $tilde(Y) | bold(y) ~ "Normal"(16.37,29.54)$.

Sumamos *varianzas*.

El desvío predictivo es aproximadamente *5.43 Mbit/s*.

= ¿La próxima medición será menor que 20?

#grid(
  columns: (480pt, 1fr), column-gutter: 24pt, align: horizon,
  image("figuras/02/normal_predictiva.pdf", height: 270pt),
  [
    Para la próxima velocidad:

    $ P(tilde(Y) < 20 | bold(y)) approx 0.75 $

    #pause
    Para la media:

    $ P(mu < 20 | bold(y)) approx 0.96 $

    #pause
    Son preguntas distintas.
  ],
)

= ¿Qué aprendimos sobre la media?

Por simetría normal, media, mediana y moda coinciden en *16.37 Mbit/s*.
Los intervalos ETI y HDI del mismo nivel también coinciden.

#pause
Conocer $sigma$ fue un supuesto. Podemos levantarlo y retomar las mismas cinco mediciones.

Tendremos que representar la incertidumbre sobre *dos parámetros*.

#new-section-slide[Modelo normal-normal: $mu$ y $sigma^2$ desconocidos]

= Dos parámetros desconocidos

El modelo observacional sigue siendo normal:

$ Y_i | mu, sigma^2 ~ "Normal"(mu,sigma^2) $

Seguimos suponiendo independencia condicional y condiciones estables.
Ahora tanto $mu$ como $sigma^2$ son *desconocidos*.

$ bold(theta) = (mu, sigma^2) $

Un _prior_ sobre $bold(theta)$ es una *distribución bidimensional*, con soporte:

$ RR times RR^(+) $

#slide[
  #align(center + horizon)[#image("figuras/02/normal_prior_conjunto.pdf", height: 500pt)]
]

= ¿Qué opciones tenemos para el _prior_?

Una opción es elegir _priors_ independientes para la media y la varianza:

$ p(mu, sigma^2) = p(mu) p(sigma^2) $

En ese caso, conocer uno de los parámetros no cambia nuestra distribución _a priori_ sobre el otro.

También existe una *opción conjugada* para el modelo normal: la distribución *NormalGammaInversa*.

= Un _prior_ para la media y la varianza

Elegimos un _prior_ conjunto para la media y la varianza:

$ (mu, sigma^2) ~ "NormalGammaInversa"(m_0, kappa_0, a_0, b_0) $

Es una distribución en *dos dimensiones*, con densidad $p(mu,sigma^2)$.
Cada punto representa un par: una media y una varianza.

$ mu in RR, quad sigma^2 > 0 $

Sus hiperparámetros cumplen $m_0 in RR$ y $kappa_0,a_0,b_0>0$.

La media y la varianza *no son independientes* bajo este _prior_.

= ¿Qué representan los hiperparámetros?

- $m_0$: centro de la distribución _a priori_ de $mu$.
- $kappa_0$: concentración de $mu$ alrededor de $m_0$.
- $a_0$: parámetro de forma de la distribución de $sigma^2$.
- $b_0$: parámetro de escala de la distribución de $sigma^2$. \ Al aumentarlo, con $a_0$ fijo, favorecemos varianzas mayores.

Si $a_0>1$, sus momentos ayudan a interpretar la escala:

$ EE(sigma^2) = b_0/(a_0-1), quad
  "Var"(mu) = b_0/(kappa_0 (a_0-1)) $

= Ejemplos de NormalGammaInversa

#align(center)[#image("figuras/02/normal_priors_ejemplos.pdf", height: 330pt)]

= ¿Cómo elegimos sus hiperparámetros?

Proponemos $m_0=20$, $kappa_0=1$, $a_0=2.5$ y $b_0=73.5$.
Este _prior_ favorece varianzas mayores y permite una incertidumbre más amplia.

- $EE(sigma^2)=b_0\/(a_0-1)=49$ $("Mbit/s")^2$.
- El intervalo central _a priori_ del 95% para $sigma^2$ es aproximadamente $[11.46,176.85]$ $("Mbit/s")^2$.
- $EE(mu)=20$ Mbit/s
- $"Var"(mu)=EE(sigma^2)\/kappa_0=49$ $("Mbit/s")^2$.

#pause
Elegimos los hiperparámetros para que el _prior_ marginal de $mu$ conserve la media y la varianza del primer caso, permitiendo además incertidumbre sobre $sigma^2$. La marginal de $mu$ tiene colas más pesadas.

= Actualizamos el _prior_ conjunto

La familia se conserva:

$ (mu, sigma^2) | bold(y) ~ "NormalGammaInversa"(m_n, kappa_n, a_n, b_n) $

$
  kappa_n &= kappa_0+n \
  m_n &= (kappa_0 m_0+n overline(y))/kappa_n \
  a_n &= a_0+n/2 \
  b_n &= b_0 + 1/2 sum_(i=1)^n (y_i-overline(y))^2
    + (kappa_0 n)/(2 kappa_n)(overline(y)-m_0)^2
$

= La información muestral para actualizar

La actualización depende de tres resúmenes:

$ n, quad overline(y), quad S = sum_(i=1)^n (y_i-overline(y))^2 $

- $n$: cantidad de mediciones.
- $overline(y)$: promedio de las mediciones.
- $S$: dispersión de las mediciones alrededor de su media, que informa sobre la varianza.

Como ahora también desconocemos $sigma^2$, el promedio muestral por sí solo no alcanza: necesitamos la dispersión observada.

= Retomamos las mediciones de internet

Los datos son:

$ bold(y) = (15.77,20.50,8.26,14.37,21.09) " Mbit/s" $

Sus resúmenes son:

$ n=5, quad overline(y) approx 16.00, quad S approx 108.78 $

= Internet: actualizamos ambos parámetros

Con $m_0=20$, $kappa_0=1$, $a_0=2.5$ y $b_0=73.5$:

$
  kappa_n &= 1+5 = 6.00 \
  m_n &= (20+5 dot overline(y))/6 approx 16.67 \
  a_n &= 2.5+5/2 = 5.00 \
  b_n &= 73.5 + S/2 + 5/12 (overline(y)-20)^2 approx 134.56
$

= Actualización en dos dimensiones

#align(center)[#image("figuras/02/normal_actualizacion_conjunta.pdf", height: 330pt)]

= La conjunta y sus marginales

#align(center)[#image("figuras/02/normal_marginales.pdf", height: 350pt)]



= Las distribuciones marginales

#grid(
  columns: (470pt, 1fr),
  column-gutter: 22pt,
  row-gutter: 18pt,
  align: left + horizon,
  [#align(left)[$ p(mu | bold(y)) = integral_0^infinity p(mu,sigma^2 | bold(y)) dif (sigma^2) $]],
  [Integrar $sigma^2$],
  [#align(left)[$ mu | bold(y) ~ "StudentT"(2 a_n, m_n, sqrt(b_n/(a_n kappa_n))) $]],
  [Grados de libertad, ubicación y escala.],
  [
    #v(2em)
    #align(left)[$ p(sigma^2 | bold(y)) = integral_(-infinity)^infinity p(mu,sigma^2 | bold(y)) dif mu $]
  ],
  [Integrar $mu$],
  [#align(left)[$ sigma^2 | bold(y) ~ "GammaInversa"(a_n,b_n) $]],
  [Forma y escala.],
)


= Las marginales _a posteriori_

#align(center)[#image("figuras/02/normal_marginales_paneles.pdf", height: 300pt)]

= Las distribuciones condicionales

#grid(
  columns: (520pt, 1fr),
  column-gutter: 22pt,
  row-gutter: 18pt,
  align: left + horizon,
  [#align(left)[$ p(mu | sigma^2=s^2,bold(y)) = (p(mu,sigma^2=s^2 | bold(y)))/(p(sigma^2=s^2 | bold(y))) $]],
  [Fijar $sigma^2$],
  [#align(left)[$ mu | sigma^2=s^2,bold(y) ~ "Normal"(m_n,s^2/kappa_n) $]],
  [Media y varianza.],
  [
    #v(2em)
    #align(left)[$ p(sigma^2 | mu=m,bold(y)) = (p(mu=m,sigma^2 | bold(y)))/(p(mu=m | bold(y))) $]
  ],
  [Fijar $mu$],
  [#align(left)[$ sigma^2 | mu=m,bold(y) ~ "GammaInversa"(a_n+1/2, b_n+kappa_n/2 (m-m_n)^2) $]],
  [Forma y escala.],
)

= Dos cortes de la conjunta

#align(center)[#image("figuras/02/normal_condicionales.pdf", height: 300pt)]

= Volvemos a la pregunta sobre la media

Usamos la *marginal* $p(mu | bold(y))$, integrando toda la incertidumbre sobre $sigma^2$.

$ EE(mu | bold(y)) approx 16.67 " Mbit/s" $

$ "IC"_(95%) approx [11.95,21.38] " Mbit/s", quad P(mu<20 | bold(y)) approx 0.93 $

Para la varianza, la media _a posteriori_ es *33.64* y su intervalo central del 95% es *[13.14, 82.88]*, en $("Mbit/s")^2$.

#pause
Con desvío conocido obtuvimos $P(mu<20 | bold(y)) approx 0.96$. Ambos _priors_ de $mu$ tienen media 20 y varianza 49, pero difieren en su forma: normal frente a StudentT. La comparación también refleja esa diferencia.

= Predecir con dos parámetros desconocidos

La nueva medición es independiente de los datos anteriores dados $mu$ y $sigma^2$:

$ tilde(Y) | mu,sigma^2 ~ "Normal"(mu,sigma^2) $

#v(0.5em)
$
 p(tilde(y) | bold(y)) = integral_0^infinity integral_(-infinity)^infinity
  mark(p(tilde(y) | mu,sigma^2), #<nig-modelo-futuro>)
  mark(p(mu,sigma^2 | bold(y)), #<nig-posterior-conjunto>) dif mu dif (sigma^2)
 #annot(<nig-modelo-futuro>, pos: bottom, dx: -90pt, dy: 30pt, anchor-inset: 8pt,
   leader: true, leader-stroke: 1pt + c-orange, leader-tip: none,
   annot-text-props: (size: 21pt, fill: c-orange))[$"Normal"(mu,sigma^2)$]
 #annot(<nig-posterior-conjunto>, pos: bottom, dx: 65pt, dy: 30pt, anchor-inset: 8pt,
   leader: true, leader-stroke: 1pt + c-blue, leader-tip: none,
   annot-text-props: (size: 21pt, fill: c-blue))[NormalGammaInversa]
$
#v(2em)
Al integrar ambos parámetros, la predictiva _a posteriori_ es *Student-t*:

$ tilde(Y) | bold(y) ~ "StudentT"(2 a_n, m_n, sqrt(b_n/a_n (1+1/kappa_n))) $

= Predecir con media y varianza desconocidas

#grid(
  columns: (480pt, 1fr), column-gutter: 24pt, align: horizon,
  image("figuras/02/normal_predictiva_conjunta.pdf", height: 270pt),
  [
    Para la próxima velocidad:

    $ P(tilde(Y)<20 | bold(y)) approx 0.72 $

    Para la media:

    $ P(mu<20 | bold(y)) approx 0.93 $

    Seguimos distinguiendo la media de una nueva medición.
  ],
)

#new-section-slide[Para cerrar]

= Del modelo al _posterior_

Postulamos dos componentes:

- Un *modelo observacional*: $p(bold(y) | bold(theta))$.
- Un *modelo a priori*: $p(bold(theta))$.

Juntos definen el modelo completo:

$ p(bold(y),bold(theta)) = p(bold(y) | bold(theta)) p(bold(theta)) $

Una vez fijados el modelo, el _prior_ y los datos, la actualización queda determinada por Bayes:

$ p(bold(theta) | bold(y)) prop p(bold(y) | bold(theta)) p(bold(theta)) $

= Resumir el _posterior_

*Estimación puntual:* elegimos un valor para representar la distribución.
Esa elección responde a un criterio de pérdida:

$ hat(bold(theta)) = argmin_(d) EE[L(bold(theta),d) | bold(y)] $

Por ejemplo, la media minimiza el riesgo cuadrático; para un parámetro escalar, la mediana minimiza el riesgo absoluto.

*Estimación por intervalos:* elegimos un conjunto de valores con una probabilidad _a posteriori_ determinada.

Para un parámetro escalar:

$ P(theta in "IC"_(1-a) | bold(y)) = 1-a $

= Predecir: volver al mundo de los datos

Para predecir una nueva respuesta, promediamos su modelo sobre *todo el posterior*
y obtenemos la *distribución predictiva _a posteriori_*:

$ p(tilde(y) | bold(y)) = integral_Theta
  p(tilde(y) | bold(theta)) p(bold(theta) | bold(y)) dif bold(theta) $

La dimensión del parámetro determina la dimensión de la integración:

- Un parámetro: integramos en una dimensión.
- Dos parámetros: integramos en dos dimensiones.
- $p$ parámetros: integramos en $p$ dimensiones.

El restulado incorpora la incertidumbre conjunta sobre todos los parámetros.
