#import "@preview/touying:0.8.0": *
#import "@preview/algorythmst:0.1.0" as algorythmst: pseudo
#import "@preview/mannot:0.4.0": mark, markrect, annot, tiptoe
#import "@preview/fletcher:0.5.8" as fletcher: node, edge

#import "template.typ": setup-template, highlight-box, grayed
#import "template.typ": c-orange, c-green, c-pink, c-blue, c-gold
#import "template.typ": new-section-slide, inverted-slide
#import "template.typ": mark-orange, mark-blue, mark-green
#import "template.typ": text-orange, text-blue, text-green

#let fletcher-diagram = fletcher.diagram
#let es-handout = sys.inputs.at("handout", default: "false") == "true"

// El PDF muestra los cambios al avanzar. El handout conserva el último estado.
#let pasos(archivos, pies, altura: 250pt) = {
  let cuadro(i) = if pies == none {
    image("figuras/03/" + archivos.at(i), height: altura)
  } else {
    stack(
      dir: ttb, spacing: 8pt,
      image("figuras/03/" + archivos.at(i), height: altura),
      text(size: 20pt, pies.at(i)),
    )
  }
  align(center)[
    #if es-handout {
      cuadro(archivos.len() - 1)
    } else {
      for i in range(archivos.len()) {
        only(str(i + 1), cuadro(i))
        if i < archivos.len() - 1 { pause }
      }
    }
  ]
}


#show: setup-template.with(
  handout: es-handout,
  title: [Estadística bayesiana con PyMC],
  subtitle: [Clase 3: Métodos de muestreo],
  footer-label: [Estadística bayesiana con PyMC],
  author: [Tomás Capretto],
)

= Hasta ahora...

Postulamos un modelo observacional y un _prior_:

$ p(y | theta), quad p(theta) $

#pause
Para actualizar usamos la regla de Bayes:

#v(2em)
$
  p(theta | y) = (mark(p(y | theta) p(theta), #<producto>)) /
    (mark(integral p(y | theta) p(theta) dif theta, #<integral>))
  #annot(<producto>, pos: top, dy: -26pt, anchor-inset: 8pt,
    leader: true, leader-stroke: 1pt + c-blue, leader-tip: none,
    annot-text-props: (size: 21pt, fill: c-blue))[Verosimilitud × prior]
  #annot(<integral>, pos: bottom, dy: 30pt, anchor-inset: 8pt,
    leader: true, leader-stroke: 1pt + c-orange, leader-tip: none,
    annot-text-props: (size: 21pt, fill: c-orange))[Constante de normalización]
$
#v(2.5em)

#pause
A veces es posible obtener $p(theta | y)$ de manera exacta (e.g. modelos conjugados).

#pause
Pero muchas otras veces, no.

#new-section-slide[Método de la grilla]

= Método de la grilla

Siempre podemos obtener una expresión para el _posterior_ sin normalizar:

$ p^*(theta | y) = p(y | theta) p(theta), $

#pause
A esa expresión se la puede evaluar en una grilla de puntos representativos de $theta$:

$
  theta_1, theta_2, dots, theta_S
$

y se obtiene

$
  p^*(theta_1 | y), p^*(theta_2 | y), dots, p^*(theta_S | y)
$

Esas alturas se pueden *normalizar* para que...

- Caso discreto: sumen 1
- Caso continuo: integren a 1

= Volvemos a los tiros libres

En la clase anterior observamos 17 aciertos en 23 intentos.

$
  Y | theta &~ "Binomial"(23, theta) \
  theta &~ "Beta"(1,1)
$

#pause
Y obtuvimos $theta | y ~ "Beta"(18,7)$.

Para este posterior podemos calcular los valores exactos:

$ EE(theta | y) = 0.72, quad op("V")(theta | y) approx 0.007754 $

$ op("Med")(theta | y) approx 0.7259, quad P(theta > 0.7 | y) approx 0.6114 $

Ahora vamos a aproximar ese mismo _posterior_ usando una grilla.

= Evaluación del _posterior_ en una grilla

#grid(
  columns: (460pt, 1fr), column-gutter: 20pt, align: horizon,
  image("figuras/03/grilla_4.pdf", height: 340pt),
  [
    *4 puntos*

    #v(0.7em)
    $EE(theta | y) approx 0.6979$

    #v(0.7em)
    $op("V")(theta | y) approx 0.01323$

    #v(0.7em)
    $op("Med")(theta | y) approx 0.6768$

    #v(0.7em)
    $P(theta > 0.7 | y) approx 0.4348$
  ],
)

= Evaluación del _posterior_ en una grilla

#grid(
  columns: (460pt, 1fr), column-gutter: 20pt, align: horizon,
  image("figuras/03/grilla_10.pdf", height: 340pt),
  [
    *10 puntos*

    #v(0.7em)
    $EE(theta | y) approx 0.7202$

    #v(0.7em)
    $op("V")(theta | y) approx 0.007771$

    #v(0.7em)
    $op("Med")(theta | y) approx 0.7270$

    #v(0.7em)
    $P(theta > 0.7 | y) approx 0.6199$
  ],
)

= Evaluación del _posterior_ en una grilla

#grid(
  columns: (460pt, 1fr), column-gutter: 20pt, align: horizon,
  image("figuras/03/grilla_20.pdf", height: 340pt),
  [
    *20 puntos*

    #v(0.7em)
    $EE(theta | y) approx 0.7200$

    #v(0.7em)
    $op("V")(theta | y) approx 0.007754$

    #v(0.7em)
    $op("Med")(theta | y) approx 0.7256$

    #v(0.7em)
    $P(theta > 0.7 | y) approx 0.6133$
  ],
)

= Evaluación del _posterior_ en una grilla

#grid(
  columns: (460pt, 1fr), column-gutter: 20pt, align: horizon,
  image("figuras/03/grilla_40.pdf", height: 340pt),
  [
    *40 puntos*

    #v(0.7em)
    $EE(theta | y) approx 0.7200$

    #v(0.7em)
    $op("V")(theta | y) approx 0.007754$

    #v(0.7em)
    $op("Med")(theta | y) approx 0.7260$

    #v(0.7em)
    $P(theta > 0.7 | y) approx 0.6119$
  ],
)

= Normalización de alturas

Cada punto $theta_j$ es el centro de un intervalo de ancho $Delta_j$.
La altura de su barra es:

$ h_j = frac(p^*(theta_j), sum_k p^*(theta_k) Delta_k) $

#pause
La probabilidad de ese intervalo es el *área* de la barra:

$ a_j = h_j Delta_j, quad sum_j a_j = 1 $

Normalizamos para que la suma de las áreas sea 1.

= Resumir el _posterior_ con la grilla

#grid(
  columns: (120pt, 1fr), column-gutter: 15pt, row-gutter: 30pt,
  align: horizon,
  [*Media*], [$hat(mu) = sum_j theta_j a_j$],
  [*Varianza*], [$op("V")(theta | y) approx sum_j (theta_j - hat(mu))^2 a_j$],
  [*Probabilidad*], [$P(theta > 0.7 | y) approx sum_(j: theta_j > 0.7) a_j$],
  [*Mediana*], [$hat(m) = theta_j - Delta_j / 2 + Delta_j / a_j (0.5 - sum_(k < j) a_k)$],
)

Para la mediana, $j$ es la primera celda donde el área acumulada alcanza 0.5.
Interpolamos dentro de esa celda.

= ¿Y si tenemos más parámetros?

#align(center)[#image("figuras/03/grilla_dimension_2d.pdf", height: 350pt)]

= El costo de agregar dimensiones

Con 500 puntos por eje:

#table(
  columns: (1fr, 1.5fr, 1fr),
  stroke: none, inset: 8pt,
  [*Parámetros*], [*Puntos de la grilla*], [],
  [1], [$500$], [Sencillo],
  [2], [$500^2 = 250.000$], [Todavía...],
  [3], [$500^3 = 125.000.000$], [Hmmm],
  [4], [$500^4 = 62.500.000.000$], [¡No!],
)

#v(1em)

#pause
- La cantidad de evaluaciones crece *exponencialmente* con la dimensión.
#pause
- Más y más puntos están en una región de densidad practicamente nula.


#new-section-slide[Trabajar con muestras]

= ¿Qué queremos calcular?

El _posterior_ contiene todo lo que sabemos de los parámetros, dados el modelo y los datos.

En la práctica, resumimos el _posterior_ en diferentes cantidades de interés:

- Media
- Varianza
- Mediana
- Cuantiles
  - Mediana
  - Intervalos de credibilidad
- $P(theta in A)$

También derivamos cantidades como $p(tilde(y) | y)$.

= Muchas preguntas son esperanzas

Para una función $phi$ del parámetro, queremos calcular:

$ mu_phi = EE[phi(theta) | y] = integral phi(theta) p(theta | y) dif theta $

#grid(
  columns: (1.5fr, 0.6fr, 1.6fr), column-gutter: 20pt, row-gutter: 20pt,
  [*Cantidad de interés*], [], [*Función $phi(theta)$*],
  [Media _a posteriori_], [$EE(theta | y)$], [$theta$],
  [Varianza _a posteriori_], [$op("Var")(theta | y)$], [$(theta - EE(theta | y))^2$],
  [Probabilidad de una región $A$], [$P(theta in A | y)$], [$bb(1)(theta in A)$],
  [Función de distribución], [$F(t)$], [$bb(1)(theta <= t) quad arrow quad #text(size: 15pt)[permite estimar cuantiles]$],
  [Distribución predictiva], [$p(tilde(y) | y)$], [$p(tilde(y) | theta)$],
)

= Métodos de Monte Carlo

Muchas cantidades de interés se expresan como integrales respecto de una distribución de probabilidad.

La *integración de Monte Carlo* permite aproximarlas mediante promedios:

$ integral phi(x) p(x) dif x approx hat(mu)_(phi,S) = 1 / S sum_(s=1)^S phi(x_s) $

Para muestras independientes $x_1, dots, x_S$ de la distribución $p(x)$:

+ Evaluamos la función $phi$ en cada muestra.
+ Promediamos los valores obtenidos.

La función $phi$ determina qué cantidad queremos calcular.

Para cuantiles, se aproxima $F$ y se busca donde alcanza la probabilidad deseada.

= Un ejemplo: aproximar $pi$

Consideramos el vector aleatorio:

$ (X,Y) ~ "Uniforme"([-1,1] times [-1,1]) $

Su densidad es $1/4$ dentro del cuadrado y 0 fuera. Definimos:

$ phi(x,y) = bb(1)(x^2 + y^2 <= 1) $

La esperanza que queremos aproximar es la probabilidad de caer en el círculo:

$ EE[phi(X,Y)] = 1/4 integral_(-1)^1 integral_(-1)^1 bb(1)(x^2 + y^2 <= 1) dif x dif y = pi/4 $

= Un ejemplo: aproximar $pi$

Generamos $S$ vectores independientes $(x_s,y_s)$ de esa distribución uniforme.

Aproximamos la esperanza con la proporción de puntos dentro del círculo:

$ EE[phi(X,Y)] approx 1/S sum_(s=1)^S bb(1)(x_s^2 + y_s^2 <= 1) $

Como $pi = 4 EE[phi(X,Y)]$, obtenemos:

$ hat(pi)_S = 4/S sum_(s=1)^S bb(1)(x_s^2 + y_s^2 <= 1) $

= Un ejemplo: aproximar $pi$

#align(center)[#image("figuras/03/monte_carlo_pi.png", height: 350pt)]

= Algunos ejemplos...

*Media de una distribución*

Queremos aproximar $mu = EE(X)$.

Con $phi(x) = x$, promediamos las muestras:

$ hat(mu) = 1 / S sum_(s=1)^S x_s $

Cada muestra aporta su valor al promedio.

= Algunos ejemplos...

*Varianza de una distribución*

Queremos aproximar $sigma_x^2 = op("Var")(X)$.

Primero estimamos la media con $hat(mu)$ y luego calculamos:

$ hat(sigma)_x^2 = 1 / (S - 1) sum_(s=1)^S (x_s - hat(mu))^2 $

Medimos la dispersión de las muestras alrededor de la media estimada.

= Algunos ejemplos...

*Probabilidad de superar un umbral*

Queremos aproximar $P(X > 0.7)$.

Con $phi(x) = bb(1)(x > 0.7)$, promediamos ceros y unos:

$ hat(P)(X > 0.7) = 1 / S sum_(s=1)^S bb(1)(x_s > 0.7) $

El resultado es la proporción de muestras que supera 0.7.

= Algunos ejemplos...

*Mediana de una distribución*

Implícitamente aproximamos la función de distribución:

$ hat(F)_(S)(t) = 1 / S sum_(s=1)^S bb(1)(x_s <= t) $

Luego buscamos el primer valor que acumula al menos la mitad de la probabilidad:

$ hat(m) = hat(q)_(0.5), quad hat(F)_(S)(hat(m)) >= 0.5 $

En la práctica, ordenamos las muestras y seleccionamos el cuantil 0.5.

También podemos interpolar entre valores vecinos.

= Algunos ejemplos...

*Intervalo central del 95%*

Usamos la misma función de distribución estimada $hat(F)_(S)$.

Buscamos los valores que acumulan probabilidades 0.025 y 0.975:

$ hat(q)_p = inf {t : hat(F)_(S)(t) >= p} $

El intervalo estimado es:

$ hat(I)_(0.95) = [hat(q)_(0.025), hat(q)_(0.975)] $

Entre sus extremos queda aproximadamente el 95% de las muestras de la distribución.

= ¿Por qué funciona Monte Carlo?

La *ley de los grandes números* justifica aproximar esperanzas con promedios.

Para muestras independientes de $p(x)$, con $mu_phi = EE[phi(X)]$, si
$EE[abs(phi(X))] < infinity$:

$ hat(mu)_(phi,S) arrow mu_phi quad "cuando" S arrow infinity $

Más muestras permiten acercarnos al valor buscado.

= Estimación de la media por Monte Carlo

Una secuencia de muestras independientes de $"Beta"(18,7)$.

#align(center)[#image("figuras/03/monte_carlo_trayectoria_1.pdf", height: 300pt)]

= Estimación de la media por Monte Carlo

Agregamos una segunda secuencia independiente.

#align(center)[#image("figuras/03/monte_carlo_trayectorias_2.pdf", height: 300pt)]

= Estimación de la media por Monte Carlo

Doce secuencias independientes de la misma distribución.

#align(center)[#image("figuras/03/monte_carlo_trayectorias.pdf", height: 300pt)]

= Estimación de la media por Monte Carlo

#align(center)[#image("figuras/03/monte_carlo_banda.pdf", height: 300pt)]

La dispersión del promedio disminuye... *¿cuánto?*

= Error estándar de Monte Carlo

Para muestras independientes de la misma distribución, con
$sigma_phi^2 = op("Var")[phi(X)] < infinity$, la varianza del promedio es:

$ op("Var")(hat(mu)_(phi,S)) = sigma_phi^2 / S $

El _Monte Carlo Standard Error_ (*MCSE*) es el desvío estándar del estimador:

$ "MCSE"(hat(mu)_(phi,S)) = sigma_phi / sqrt(S) $

Mide la variabilidad de la estimación debida a usar una cantidad finita de muestras.

= ¿Cómo estimamos el MCSE?

Estimamos la varianza de $phi(X)$ a partir de las muestras:

$ hat(sigma)_phi^2 = 1 / (S - 1) sum_(s=1)^S (phi(x_s) - hat(mu)_(phi,S))^2 $

Luego estimamos el error estándar:

$ hat("MCSE") = hat(sigma)_phi / sqrt(S) $

Para estimar la media de $X$, usamos $phi(x) = x$.

= ¿Cómo cambia el error al aumentar $S$?

El error estándar decrece como $1\/sqrt(S)$:

$ "MCSE"_(k S) = "MCSE"_S / sqrt(k) $

- Cuatro veces más muestras reducen el MCSE a la mitad.
- Cien veces más muestras reducen el MCSE a una décima parte.

// = El teorema central del límite

// Ya conocemos el desvío estándar del estimador.

// El TCL nos permite describir la *forma de su distribución* (¡en el muestreo!)

// Para muestras independientes de la misma distribución y $0 < sigma_phi^2 < infinity$:

// $ sqrt(S) (hat(mu)_(phi,S) - mu_phi) / sigma_phi arrow^d N(0,1) $

// cuando $S arrow infinity$.

// Esto permite construir intervalos de confianza para la cantidad que estimamos mediante Monte Carlo.

// = Un intervalo de confianza Monte Carlo

// Para $S$ suficientemente grande, un intervalo de confianza aproximado del 95% para $mu_phi$ es:

// $ hat(mu)_(phi,S) plus.minus 1.96 hat("MCSE") $

// Cuantifica la incertidumbre en la estimación asociada a usar una cantidad finita de muestras.

// Al repetir la simulación completa, aproximadamente el 95% de los intervalos construidos así contendría el valor verdadero $mu_phi$.

// La amplitud disminuye al aumentar $S$.

// = ¿Y si las muestras están correlacionadas?

// // NOTE: ESTO VA PARA DESPUES

// La fórmula $hat(sigma)_phi / sqrt(S)$ supone independencia.

// Con muestras correlacionadas, debemos tener en cuenta la dependencia para calcular el MCSE.

// Más adelante vamos a usar el tamaño efectivo de muestra y diagnósticos de las cadenas.

// Monte Carlo da una receta para aproximar esperanzas. Todavía necesitamos una manera de obtener muestras de la distribución de interés.

#inverted-slide[
  ¡Buenísimo!\
  #pause
  \
  ¿Y cómo conseguimos las muestras?
]

= Algoritmos basados en cadenas de Markov

Seguimos contando con:

$ p^*(theta) = p(y | theta) p(theta) $

Hay métodos que permiten usar esa información:

- Muestreo por rechazo.
- Muestreo por importancia, que utiliza muestras ponderadas.
- Algoritmos basados en cadenas de Markov.

#pause
Vamos a concentrarnos en estos últimos.

#new-section-slide[Cadenas de Markov]

= ¿Qué es una cadena de Markov?

Una secuencia aleatoria donde el próximo estado depende del estado actual.

Dado ese estado, el resto de la historia no aporta información adicional:

$ p(X_(t+1) | X_t, dots, X_0) = p(X_(t+1) | X_t) $

#pause
La regla que usamos para pasar de un estado al siguiente se llama *regla de transición*.

= Una cadena con dos estados

#let construir-dos(i) = {
  let flechas = (
    edge(<inicio-a>, <inicio-b>, "-|>", [0.2], bend: 25deg),
    edge(<inicio-b>, <inicio-a>, "-|>", [0.3], bend: 25deg),
    edge(<inicio-a>, <inicio-a>, "-|>", [0.8], bend: 140deg),
    edge(<inicio-b>, <inicio-b>, "-|>", [0.7], bend: 140deg),
  )
  align(center, fletcher-diagram(
    node-stroke: 1.5pt, edge-stroke: 1.2pt + c-blue, label-size: 18pt,
    node((0pt, 0pt), [A], name: <inicio-a>, radius: 28pt, fill: white),
    node((220pt, 0pt), [B], name: <inicio-b>, radius: 28pt, fill: white),
    ..flechas.enumerate().map(par => if par.first() < i {
      par.last()
    } else {
      fletcher.hide(par.last())
    }),
  ))
}

#v(2em)
#if es-handout {
  construir-dos(4)
} else {
  for i in range(5) {
    only(str(i + 1), construir-dos(i))
    if i < 4 { pause }
  }
}

= Una cadena con dos estados

#let estilo-transicion(secuencia, i, origen, destino) = {
  let usada = i > 0 and secuencia.at(i - 1) == origen and secuencia.at(i) == destino
  let grosor = if usada { 3.5pt } else { 1.2pt }
  (stroke: grosor + c-blue, mark-scale: 100% * (1.2pt / grosor))
}

#let estados = (0, 0, 1, 1, 1, 0)
#let dibujar-estado(i) = grid(
  columns: (410pt, 1fr), column-gutter: 20pt, align: horizon,
  fletcher-diagram(
    node-stroke: 1.5pt, edge-stroke: 1.2pt + c-blue, label-size: 18pt,
    node((0pt, 0pt), [A], name: <a>, radius: 28pt,
      fill: if estados.at(i) == 0 { c-blue.lighten(80%) } else { white }),
    node((220pt, 0pt), [B], name: <b>, radius: 28pt,
      fill: if estados.at(i) == 1 { c-blue.lighten(80%) } else { white }),
    edge(<a>, <b>, "-|>", [0.2], bend: 25deg, ..estilo-transicion(estados, i, 0, 1)),
    edge(<b>, <a>, "-|>", [0.3], bend: 25deg, ..estilo-transicion(estados, i, 1, 0)),
    edge(<a>, <a>, "-|>", [0.8], bend: 140deg, ..estilo-transicion(estados, i, 0, 0)),
    edge(<b>, <b>, "-|>", [0.7], bend: 140deg, ..estilo-transicion(estados, i, 1, 1)),
  ),
  [
    Filas: estado actual.\ Columnas: siguiente estado.

    $ P = mat(0.8, 0.2; 0.3, 0.7) $

    Iteración: *#i*\
    Estado: *#if estados.at(i) == 0 { [A] } else { [B] }*

    Estados visitados:\
    #text-blue[
      #estados.slice(0, i + 1).map(estado => if estado == 0 { "A" } else { "B" }).join(", ")
    ]
  ],
)

#v(0.5em)
#if es-handout {
  dibujar-estado(5)
} else {
  for i in range(6) {
    only(str(i + 1), dibujar-estado(i))
    if i < 5 { pause }
  }
}
#v(1em)
Cada fila de la matriz suma 1.

= Frecuencias de visita a los estados

Contamos qué proporción de los primeros $T$ estados observados corresponde a A y a B:

$ hat(pi)_T = mat(
  1/T sum_(t=0)^(T-1) bb(1)(X_t = "A"),
  1/T sum_(t=0)^(T-1) bb(1)(X_t = "B")
) $

Una simulación de la misma cadena, empezando en A:

#table(
  columns: (1fr, 1fr), stroke: none, inset: 6pt,
  [*Estados observados $T$*], [*Frecuencias relativas $hat(pi)_T$*],
  [100], [$mat(0.6600, 0.3400)$],
  [1000], [$mat(0.5820, 0.4180)$],
  [10.000], [$mat(0.5961, 0.4039)$],
)

Las dos proporciones suman 1: forman una distribución sobre los estados.

= La distribución estacionaria

La *distribución estacionaria* de esta cadena es:

$ pi = mat(0.6, 0.4) $

Si elegimos el estado inicial con probabilidad 0.6 para A y 0.4 para B, después de un paso las probabilidades de estar en A y en B siguen siendo 0.6 y 0.4:

$ pi P = mat(0.6, 0.4) mat(0.8, 0.2; 0.3, 0.7) = mat(0.6, 0.4) = pi $

En cada iteración se conservan esas probabilidades, aunque los estados individuales puedan cambiar.

En esta cadena, a largo plazo las frecuencias se acercan a $pi$ aunque empecemos en A o en B.

= Una cadena con tres estados

#grid(
  columns: (410pt, 1fr), column-gutter: 20pt, align: horizon,
  fletcher-diagram(
    node-stroke: 1.5pt, edge-stroke: 1.2pt + c-blue, label-size: 18pt,
    node((0pt, 0pt), [A], name: <tres-a>, radius: 24pt,
      fill: white),
    node((200pt, 0pt), [B], name: <tres-b>, radius: 24pt,
      fill: white),
    node((100pt, 140pt), [C], name: <tres-c>, radius: 24pt,
      fill: white),
    edge(<tres-a>, <tres-b>, "-|>", [0.3], bend: 18deg),
    edge(<tres-b>, <tres-a>, "-|>", [0.2], bend: 18deg),
    edge(<tres-a>, <tres-c>, "-|>", [0.1], bend: 22deg, label-pos: 0.3),
    edge(<tres-c>, <tres-a>, "-|>", [0.2], bend: 22deg, label-pos: 0.45, label-sep: 3pt, label-side: right),
    edge(<tres-b>, <tres-c>, "-|>", [0.3], bend: 22deg, label-pos: 0.55, label-sep: 3pt, label-side: right),
    edge(<tres-c>, <tres-b>, "-|>", [0.2], bend: 22deg, label-pos: 0.3),
    edge(<tres-a>, <tres-a>, "-|>", [0.6], bend: 140deg, loop-angle: 180deg),
    edge(<tres-b>, <tres-b>, "-|>", [0.5], bend: 140deg, loop-angle: 0deg),
    edge(<tres-c>, <tres-c>, "-|>", [0.6], bend: 140deg, loop-angle: 90deg),
  ),
  [
    $ P = mat(0.6, 0.3, 0.1; 0.2, 0.5, 0.3; 0.2, 0.2, 0.6) $

    La distribución estacionaria es:

    $ pi = mat(1/3, 1/3, 1/3) $

    $ pi P = pi $

    A largo plazo, un tercio de las visitas corresponde a cada estado.
  ],
)

= Una cadena con estados continuos

Empezamos en cero y sumamos incrementos normales independientes:

$
  X_0 &= 0\
  X_t &= X_(t-1) + Z_t\
  Z_t &~ N(0,1)
$

#pause
Construimos un *paseo aleatorio gaussiano*.

Veamos algunas trayectorias de esa misma cadena.

= Un paseo aleatorio

Cada línea muestra una trayectoria completa, desde $t=0$ hasta $t=150$.

#pasos(
  ("paseo_trayectorias_1.pdf", "paseo_trayectorias_2.pdf", "paseo_trayectorias_3.pdf", "paseo_trayectorias_500.pdf"),
  none,
  altura: 300pt,
)

= ¿Cómo se distribuye $X_t$?

#pasos(
  ("paseo_1.pdf", "paseo_10.pdf", "paseo_40.pdf", "paseo_100.pdf", "paseo_150.pdf"),
  none,
  altura: 350pt,
)

= La distribución del paseo aleatorio

El estado en el instante $t$ es la suma de los incrementos anteriores:

$ X_t = sum_(i=1)^t Z_i $

Como son normales estándar independientes:

$ X_t ~ N(0,t) $

#pause
La varianza crece con $t$ y la distribución se sigue ensanchando.

Este paseo no tiene una distribución estacionaria de probabilidad sobre $bb(R)$.

= Una cadena que se mantiene cerca de cero

Atenuamos el estado anterior antes de incorporar el nuevo incremento:

$ X_t = rho X_(t-1) + Z_t, quad abs(rho) < 1 $

#pause
Con $rho=0.7$, los efectos de los incrementos anteriores se van atenuando.

La cadena sigue incorporando ruido, pero también tiene una fuerza que la mantiene cerca de cero.

= Un proceso autorregresivo

#pasos(
  ("ar1_trayectorias_1.pdf", "ar1_trayectorias_2.pdf", "ar1_trayectorias_3.pdf", "ar1_trayectorias_500.pdf"),
  none,
  altura: 300pt,
)

= Una distribución que se estabiliza

#pasos(
  ("ar1_1.pdf", "ar1_10.pdf", "ar1_40.pdf", "ar1_100.pdf", "ar1_150.pdf"),
  none,
  altura: 350pt,
)

= La distribución estacionaria del AR(1)

Para $abs(rho) < 1$ y ruido $Z_t ~ N(0,1)$, la distribución estacionaria es:

$ N(0, 1 / (1-rho^2)) $

Si empezamos con esa distribución, se conserva en todas las iteraciones.

Si empezamos en cero, como en los gráficos:

$ X_t ~ N(0, frac(1-rho^(2t), 1-rho^2)) $

Como $rho^(2t) arrow 0$, la distribución converge a la estacionaria.

#inverted-slide[¿Y si construimos una cadena\ cuya distribución estacionaria\ sea el posterior?]

#new-section-slide[Metropolis-Hastings]

= ¿Cómo construimos esa cadena?

Una receta muy usada:

+ Elegir un estado inicial.
+ Proponer un salto desde el estado actual.
+ Decidir si aceptamos el salto o nos quedamos donde estábamos.
+ Repetir.

#pause
La clave está en las reglas de *propuesta* y de *aceptación*.

#pause
Se construyen de modo tal que la cadena:

- Tenga una distribución estacionara
- Sea el _posterior_

= Metropolis-Hastings: proponer un salto

Desde el estado actual $theta_t$, generamos un candidato a partir de una distribución de propuesta $Q$ con densidad $q$:

$ theta' ~ Q(dot | theta_t) $

#pause
Por ejemplo, podemos usar una propuesta normal centrada en el estado actual:

$ theta' ~ N(theta_t, sigma^2) $

#pause
Notar que *la propuesta se genera sin consultar la forma del _posterior_*.

= Metropolis-Hastings: aceptar el salto

Calculamos la probabilidad de aceptación:

#v(1.5em)
$
  alpha = min(1,
    markrect(frac(p^*(theta'), p^*(theta_t)), #<cociente-posterior>,
      color: #c-blue, fill: #c-blue.transparentize(85%), stroke: #none,
      outset: #0.15em, radius: #3pt)
    #h(0.6em)
    markrect(frac(q(theta_t | theta'), q(theta' | theta_t)), #<cociente-propuesta>,
      color: #c-orange, fill: #c-orange.transparentize(85%), stroke: #none,
      outset: #0.15em, radius: #3pt)
  )
  #annot(<cociente-posterior>, pos: bottom, dx: -70pt, dy: 35pt, anchor-inset: 8pt,
    leader: true, leader-stroke: 1pt + c-blue, leader-tip: none,
    annot-text-props: (size: 21pt, fill: c-blue))[Comparar las densidades]
  #annot(<cociente-propuesta>, pos: top, dx: 50pt, dy: -35pt, anchor-inset: 8pt,
    leader: true, leader-stroke: 1pt + c-orange, leader-tip: none,
    annot-text-props: (size: 21pt, fill: c-orange))[Considerar la vuelta]
$
#v(3em)

#pause
Podemos usar $p^*$ porque la constante de normalización del posterior se cancela en el cociente.

// = ¿Por qué esta regla conserva el posterior?

// La idea es que los movimientos de ida y vuelta entre $theta$ y $theta'$ se compensen cuando la cadena sigue el posterior:

// $ p(theta | y) q(theta' | theta) alpha(theta, theta')
//   = p(theta' | y) q(theta | theta') alpha(theta', theta) $

// Esta igualdad se llama *balance detallado*.

// Cada lado combina la densidad del posterior en el punto de partida, la densidad de la propuesta y la probabilidad $alpha$ de aceptar el salto.

// Metropolis-Hastings elige la aceptación para cumplir esta igualdad: si antes de un paso la cadena sigue el posterior, después del paso también.

// Por eso el posterior es una *distribución estacionaria* de la cadena.

// = Convergencia de los promedios

// El balance detallado garantiza la invariancia. La convergencia desde otros estados requiere condiciones de *ergodicidad*:

// - Poder explorar el soporte de la distribución: irreducibilidad.
// - Volver a las regiones con probabilidad positiva: recurrencia adecuada.
// - Evitar ciclos de período fijo: aperiodicidad.

// Bajo estas condiciones, la distribución estacionaria es única y, para funciones integrables:

// $ 1/S sum_(s=1)^S phi(theta_s) arrow EE[phi(theta) | y] $

// La convergencia vale para estas muestras dependientes.

= Cuando la propuesta es simétrica

La probabilidad de proponer el salto es la misma en ambas direcciones:

$ q(theta' | theta_t) = q(theta_t | theta') $

#pause

Entonces:

$ alpha = min(1, frac(p^*(theta'), p^*(theta_t))) $

#pause
- Hacia un punto de mayor densidad, aceptamos siempre.
- Hacia un punto de menor densidad, también podemos aceptar.

#pause

Queremos recorrer la distribución, incluyendo sus regiones de menor densidad.

= ¿Aceptamos o nos quedamos?

Generamos $u ~ "Uniforme"(0,1)$ y lo comparamos con $alpha$:

$
  theta_(t+1) = cases(theta' &"si" u < alpha, theta_t &"en otro caso")
$

#pause
Al rechazar un salto, el estado actual se repite.


= Algoritmo de Metropolis-Hastings

#pause

#pseudo(line-gap: 1em)[
  + Elegir $theta_1$ con $p^*(theta_1) > 0$.
  + *Para* $t = 1, dots, S - 1$:
    + *Proponer* $theta' ~ Q(dot | theta_t)$. #algorythmst.comment[Es habitual usar una normal]
    + *Calcular* $display(alpha_t <- min(1, frac(p^*(theta') q(theta_t | theta'), p^*(theta_t) q(theta' | theta_t))))$.
    + *Generar* $u ~ "Uniforme"(0,1)$.
    + *Guardar* $display(theta_(t+1) <- cases(theta' &"si" u < alpha_t, theta_t &"en otro caso"))$. #algorythmst.comment[$bb(1)(u < alpha_t) ~ "Bernoulli"(alpha_t)$]
  + *Devolver* $theta_1, dots, theta_S$.
]

= Metropolis de paseo aleatorio

La propuesta normal que vimos tiene la forma:

$ theta' ~ N(theta_t, Sigma) $

#pause

La covarianza $Sigma$ se mantiene fija durante el muestreo.

La propuesta es simétrica y está centrada en el estado actual.

#pause

Esta variante se llama *Random Walk Metropolis-Hastings* (RWMH).

= RWMH: proponer, comparar y decidir

#align(center)[
  #if es-handout {
    image("figuras/03/rwmh_ejemplo.pdf", height: 300pt)
  } else {
    link("pdfpc:figuras/03/rwmh_ejemplo.mp4", image("figuras/03/rwmh_ejemplo_inicio.pdf", height: 300pt))
  }
]

#new-section-slide[Hamiltonian Monte Carlo]

= Una propuesta guiada por la geometría

Hamiltonian Monte Carlo (HMC) usa el *gradiente* del log posterior para construir las propuestas.

#pause

- El parámetro $theta$ representa la posición de una partícula.
- Un impulso inicial $phi$ determina cómo empieza a moverse.
- La forma del _posterior_ guía la trayectoria.

#pause

El punto final de la trayectoria será el candidato $theta'$.

#pause

Esto permite proponer movimientos lejanos con alta probabilidad de aceptación.

#pause

Contracara: mayor costo computacional por propuesta.

= De la densidad a la energía potencial

Con $U(theta) = -log p^*(theta)$, los máximos de densidad son mínimos de energía.

#align(center)[#image("figuras/03/hmc_paisaje.pdf", height: 300pt)]

= Una partícula con fricción

Soltamos la bolita desde el reposo: pierde energía y termina en el fondo, la moda.

#align(center)[
  #if es-handout {
    image("figuras/03/hmc_con_friccion.pdf", height: 300pt)
  } else {
    link("pdfpc:figuras/03/hmc_con_friccion.mp4", image("figuras/03/hmc_con_friccion_inicio.pdf", height: 300pt))
  }
]

= Una partícula sin fricción

Desde el mismo inicio y en reposo, la bolita va y vuelve sin perder amplitud.

#align(center)[
  #if es-handout {
    image("figuras/03/hmc_sin_friccion.pdf", height: 300pt)
  } else {
    link("pdfpc:figuras/03/hmc_sin_friccion.mp4", image("figuras/03/hmc_sin_friccion_inicio.pdf", height: 300pt))
  }
]

= Una trayectoria con un impulso inicial

Partimos de $theta_t = 0.7$, con $phi_0 = -1.1$, e integramos hasta $t = 2$.

#align(center)[
  #if es-handout {
    image("figuras/03/hmc_impulso_1.pdf", height: 300pt)
  } else {
    // El exportador convierte este enlace en una acción Launch para pdfpc.
    link("pdfpc:figuras/03/hmc_impulso_1.mp4", image("figuras/03/hmc_impulso_1_inicio.pdf", height: 300pt))
  }
]

= Cinco iteraciones de HMC

En cada iteración: un nuevo $phi_0 ~ N(0,1)$ y tiempo de integración $t = 2$.

#align(center)[
  #if es-handout {
    image("figuras/03/hmc_cinco_muestras.pdf", height: 300pt)
  } else {
    link("pdfpc:figuras/03/hmc_cinco_muestras.mp4", image("figuras/03/hmc_cinco_muestras_inicio.pdf", height: 300pt))
  }
]

= ¿Qué aporta el momentum?

El momentum indica hacia dónde se mueve la bolita y con qué rapidez.

#pause

Al bajar, la bolita gana velocidad. Esa velocidad le permite atravesar el fondo y subir por el otro lado.

Por eso puede recorrer la superficie en lugar de quedarse en la moda.

#pause

Al seleccionar un nuevo momentum (al azar), cambiamos cómo empieza el siguiente recorrido.

= Un nuevo impulso en cada iteración

Agregamos un momentum auxiliar $phi$, independiente de la posición $theta$.

Para simplificar, elegimos:

$ phi ~ N(0,1) $

#pause

- Si $phi > 0$, arranca hacia la derecha; si $phi < 0$, hacia la izquierda.
- Cuanto mayor es $abs(phi)$, más rápido arranca y mayor es su energía cinética.

#pause

La normal favorece valores de momentum cercanos a cero. Valores grandes de $abs(phi)$ son menos frecuentes, pero dan más energía para llegar a regiones alejadas.


= ¿Cómo calculamos la posición final?

En los videos dimos un impulso a la bolita, la dejamos moverse y registramos dónde terminó.

#pause

Pero ¿cómo sabemos dónde estará después del tiempo elegido?

#pause

La posición inicial y el momentum determinan el recorrido. Para calcularlo usamos las ecuaciones de Hamilton.

Empecemos por describir la energía de la bolita.

= La energía total: el Hamiltoniano

La energía total combina dos componentes:

$ H(bold(theta),bold(phi)) = U(bold(theta)) + K(bold(phi)) $

#pause

- $U(bold(theta)) = -log p^*(bold(theta))$ es la *energía potencial*: depende de la posición.
- $K(bold(phi))$ es la *energía cinética*: depende del momentum.

#pause

En una dimensión, se simplifica a $K(phi) = phi^2 / 2$.

#pause

Con varios parámetros, $bold(M)$ es la _mass matrix_ y la covarianza de los impulsos:

$ bold(phi) ~ N(0,bold(M)), quad K(bold(phi)) = 1/2 bold(phi)^T bold(M)^(-1) bold(phi) $


= Las ecuaciones del movimiento

Las ecuaciones de Hamilton describen cómo se mueve la bolita:

$ (dif bold(theta))/(dif t) &= bold(M)^(-1) bold(phi), quad quad
  (dif bold(phi))/(dif t) &= -nabla U(bold(theta)) $

#pause

El momentum determina la velocidad. La pendiente de la superficie cambia el momentum y empuja la bolita cuesta abajo:

$ -nabla U(bold(theta)) = nabla log p^*(bold(theta)) $

#pause

La dinámica exacta conserva la energía y el volumen en $(bold(theta),bold(phi))$, y es reversible.

La reversibilidad permite recorrer la misma trayectoria en sentido inverso al cambiar el signo del momentum.

= Nos quedamos con las posiciones

Para mover la bolita usamos su posición $bold(theta)$ y su momentum $bold(phi)$. Trabajamos con ambas variables a la vez:

$ p(bold(theta),bold(phi) | y) = p(bold(theta) | y) N(bold(phi) | 0,bold(M)) prop exp(-H(bold(theta),bold(phi))) $

En esta distribución, la posición sigue el posterior y el momentum una normal independiente.

#pause

El momentum solo sirve para movernos: al terminar el recorrido, guardamos $bold(theta)$ y descartamos $bold(phi)$.

#pause

La dinámica exacta conserva la energía y el volumen, y por eso mantiene esta distribución. Generar un nuevo momentum de la misma distribución normal también conserva la distribución conjunta.

= Aproximar la trayectoria con leapfrog

En general, *no podemos obtener una solución analítica* de las ecuaciones de Hamilton.

#pause

Por eso las resolvemos de forma aproximada con un *integrador numérico*.

Usamos el integrador *leapfrog*: avanza en pequeños pasos y usa el gradiente del log posterior para actualizar $bold(phi)$ y $bold(theta)$.

#pause

Elegimos:

- Cuánto dura cada paso: $h$.
- Cuántos pasos damos antes de proponer una nueva posición: $L$.

#pause

El tiempo total del recorrido es $t = L h$.

= Un paso de leapfrog

En una dimensión un paso de tamaño $h$ es:

$
  phi_(k+1/2) &<- phi_k - h/2 U'(theta_k) && #box(width: 260pt, align(right)[medio paso de momentum]) \
  theta_(k+1) &<- theta_k + h phi_(k+1/2) && #box(width: 260pt, align(right)[paso completo de posición]) \
  phi_(k+1) &<- phi_(k+1/2) - h/2 U'(theta_(k+1)) && #box(width: 260pt, align(right)[medio paso de momentum])
$

#pause

Como $U(theta) = -log p^*(theta)$, $U'(theta)$ es el negativo de la *derivada del log posterior*.


#pause

Repetimos el paso $L$ veces para construir una propuesta. Guardamos un estado después de aceptarla o rechazarla.

= Tamaño de paso y precisión

#align(center)[#image("figuras/03/hmc_leapfrog.pdf", height: 320pt)]

= Un compromiso entre precisión y costo

Para recorrer el mismo tiempo $t$:

- Pasos pequeños requieren más evaluaciones del gradiente.
- Pasos grandes reducen ese costo, pero pueden introducir errores mayores.

#pause

En la trayectoria exacta, la energía total $H$ se mantiene constante.

Leapfrog aproxima esa trayectoria y puede terminar con una energía distinta de la inicial.

#pause

Para corregir ese error, aceptamos o rechazamos la propuesta mediante una regla de Metropolis.

// Esta corrección es válida porque leapfrog es reversible y conserva el volumen.

= Corregir el error de integración

Comparamos la energía del estado inicial con la de la propuesta:

$ Delta H = H(bold(theta)',bold(phi)') - H(bold(theta)_t,bold(phi)) $

#pause

$ alpha_t = min(1, exp(-Delta H)) $

#pause

- Si $Delta H <= 0$, aceptamos siempre.
- Si $Delta H > 0$, aceptamos con probabilidad $exp(-Delta H)$.

#pause

Con integración exacta, $Delta H = 0$ y todas las propuestas se aceptarían.

#pause

Esta corrección permite conservar la distribución objetivo a pesar del error numérico.

= Aceptar, registrar y volver a empezar

Generamos $u ~ "Uniforme"(0,1)$ y actualizamos:

$ bold(theta)_(t+1) = cases(bold(theta)' &"si" u < alpha_t, bold(theta)_t &"en otro caso") $

#pause

Registramos un estado en cada iteración, también cuando rechazamos la propuesta.

#pause

Para la siguiente trayectoria, conservamos esa posición y generamos un nuevo impulso independiente.

#pause

Una trayectoria con varias actualizaciones de leapfrog produce un solo estado nuevo de la cadena.

= HMC básico: un resumen

Fijamos $h$, $L$ y $bold(M)$. Elegimos $bold(theta)_1$ con $p^*(bold(theta)_1) > 0$.

#pause

#pseudo(line-gap: 0.8em)[
  + *Para* $t = 1, dots, S - 1$:
    + Generar $bold(phi) ~ N(0,bold(M))$ y guardar $H_0 <- H(bold(theta)_t,bold(phi))$.
    + Integrar $L$ pasos de leapfrog desde $(bold(theta)_t,bold(phi))$ para obtener $(bold(theta)',bold(phi)')$.
    + Invertir el momentum final: $bold(phi)' <- -bold(phi)'$. #algorythmst.comment[Hace reversible la propuesta.]
    + Calcular $alpha_t <- min(1, exp(H_0 - H(bold(theta)',bold(phi)')))$.
    + Generar $u ~ "Uniforme"(0,1)$.
    + Guardar $display(bold(theta)_(t+1) <- cases(bold(theta)' &"si" u < alpha_t, bold(theta)_t &"en otro caso"))$.
  + *Devolver* $bold(theta)_1, dots, bold(theta)_S$.
]

= Qué cambia respecto de RWMH

RWMH propone desplazamientos con una forma y escala elegidas de antemano.

#pause

HMC usa gradientes y un impulso aleatorio para construir una trayectoria.

#pause

Puede reducir el comportamiento de paseo aleatorio, especialmente en varias dimensiones. Cada propuesta exige más cálculo.

Requiere parámetros continuos y una densidad suficientemente regular para calcular gradientes.

#pause

Ambos métodos aceptan o rechazan la propuesta mediante una regla que garantiza que el posterior sea una distribución estacionaria.

= De HMC básico a NUTS

En HMC básico tenemos que elegir cuánto tiempo seguir cada trayectoria.

#pause

*NUTS* (_No-U-Turn Sampler_) usa un criterio de retorno para decidir cuándo dejar de extender la trayectoria de HMC. Selecciona una propuesta entre los estados explorados.

#pause

Los algoritmos actuales también adaptan el tamaño de paso y la matriz de masas durante un periodi de "calentamiento".

#pause

NUTS es la variante de HMC que vamos a usar con PyMC.

#new-section-slide[¿Podemos confiar en las muestras?]

#let diagnosticos = json("figuras/03/diagnosticos_resumen.json")

= Garantías asintóticas

Bajo condiciones generales de ergodicidad, la distribución de $theta_t$ converge al posterior cuando $t arrow infinity$.

A su vez, la ley de los grandes números para cadenas de Markov ergódicas (teorema ergódico) garantiza, si $EE[abs(g(theta)) | y] < infinity$:

$ 1/S sum_(s=1)^S g(theta_s) arrow EE[g(theta) | y] quad (S arrow infinity) $

El promedio de las muestras converge a la esperanza _a posteriori_.

#pause

*Estas garantías no dicen cuántas iteraciones se necesitan.*

En una ejecución finita debemos revisar la estabilización, el acuerdo entre cadenas y la precisión.

= Estabilización

Buscamos que la cadena deje atrás el punto inicial y explore una distribución con ubicación y dispersión estables.

#pause
Los valores individuales varían. Lo que debe estabilizarse es la distribución de los valores que recorre.

#pause
Descartamos muestras del periodo de *calentamiento* antes de resumir el _posterior_.

#pause
Si la cadena no se estabiliza, no usamos esas muestras para resumir el posterior.

Todavía no lo representan adecuadamente.

= Una traza que se estabiliza y otra que no

#align(center)[#image("figuras/03/diagnostico_una_estabilizacion.pdf", height: 350pt)]

= Autocorrelación

Las muestras consecutivas suelen estar relacionadas.

#pause
La *autocorrelación* mide cuánto se parecen dos valores separados por $k$ iteraciones:

$ rho_k = op("Corr")(theta_s, theta_(s+k)) $

- $rho_k$ cerca de 1: valores muy parecidos aun después de $k$ pasos.
- $rho_k$ cerca de 0: poca relación a esa distancia.

La medimos en el tramo que ya se estabilizó, después del calentamiento.

= Autocorrelación

Dos cadenas en equilibrio con objetivo $N(0,1)$.

#align(center)[#image("figuras/03/diagnostico_una_trazas.pdf", height: 300pt)]

= Autocorrelación

#align(center)[#image("figuras/03/diagnostico_una_acf.pdf", height: 300pt)]

= Autocorrelación y MCSE

Para estimar la media del _posterior_ usamos $hat(mu) = 1/S sum_(s=1)^S theta_s$.

Con la cadena en equilibrio y autocorrelaciones que decaen suficientemente rápido:

$ "MCSE"(hat(mu)) approx sigma_theta / sqrt(S) sqrt(1 + 2 sum_(k=1)^infinity rho_k) $

#pause

La autocorrelación positiva aumenta el error de estimación de la media.
Con $S=1000$ y $sigma_theta=1$:

#table(
  columns: (1fr, auto), stroke: none, inset: 7pt,
  [*Muestras*], [*MCSE aproximado*],
  [Independientes: $rho_k=0$], [$0.032$],
  [Autocorrelacionadas: $rho_k=0.9^k$], [$0.138$],
)

= Por qué ejecutar varias cadenas

Una sola cadena puede parecer estable y estar atrapada en una región del posterior.

Ejecutamos, por ejemplo, cuatro cadenas independientes desde puntos distintos.

#pause
Después comparamos:

- Si recorren las mismas regiones.
- Si sus distribuciones, medias y dispersiones son similares.

La comparación ayuda a detectar problemas que una sola cadena puede ocultar.

= Varias cadenas: regiones distintas

#align(center)[#image("figuras/03/diagnostico_trazas_lentas.pdf", height: 350pt)]

= Varias cadenas: recorridos compatibles

#align(center)[#image("figuras/03/diagnostico_trazas_compatibles.pdf", height: 350pt)]

= $hat(R)$: variación dentro y entre cadenas

Tenemos $M$ cadenas de $S$ muestras.

$ W = 1/M sum_(m=1)^M s_m^2, quad
  B = S/(M-1) sum_(m=1)^M (hat(mu)_m - hat(mu))^2 $

$hat(mu)_m$ y $s_m^2$ son la media y la varianza de la cadena $m$. $hat(mu)$ es la media de todas las muestras.

#pause

$ hat(V) = (S-1)/S W + B/S, quad hat(R) = sqrt(hat(V)/W) $

- $W$: variación promedio dentro de las cadenas; $B$: diferencias entre sus medias.
- $hat(V)$: varianza del posterior estimada combinando $W$ y $B$.
- Si las cadenas siguen separadas, $B$ aumenta y $hat(R)$ se aleja de 1.

= $hat(R)$: cadenas superpuestas

#align(center)[#image("figuras/03/diagnostico_rhat_superpuestas.pdf", height: 350pt)]

= $hat(R)$: cadenas separadas

#align(center)[#image("figuras/03/diagnostico_rhat_separadas.pdf", height: 350pt)]

= Cómo interpretar $hat(R)$

Buscamos un valor *cercano a 1*. Un valor mayor que *1.01* es una señal para revisar el muestreo.

Si las cadenas siguen en regiones distintas, todavía no resumimos sus muestras como si representaran el posterior.

#pause

Los programas usan una versión mejorada: dividen las cadenas en mitades y comparan rangos y dispersiones. La fórmula anterior explica la idea básica.

Un $hat(R)$ satisfactorio aporta evidencia, pero no garantiza que se haya explorado todo el posterior.

= ESS: tamaño efectivo de muestra

El *tamaño efectivo de muestra* mide la precisión que aportan las muestras dependientes.

Para estimar la media de $theta$, con $N=M S$ muestras conservadas:

$ "ESS"_mu approx N / (1 + 2 sum_(k=1)^infinity rho_k) $

#pause

- Autocorrelación positiva: el ESS suele ser menor que $N$.
- Con anticorrelación, puede superar $N$.

= ESS y MCSE

Para estimar la media, usamos el ESS correspondiente a esa media:

$ hat("MCSE")(hat(mu)) approx hat(sigma)_theta / sqrt(hat("ESS")_mu) $

#pause

Ejemplo: cuatro cadenas en equilibrio, con 2500 muestras cada una.

#table(
  columns: (1fr, auto, auto, auto), stroke: none, inset: 6pt,
  [*Muestras*], [*$N$*], [*ESS de la media*], [*MCSE*],
  ..diagnosticos.precision.map(fila => (
    [#fila.nombre], [#fila.n], [#fila.ess], [#fila.mcse],
  )).flatten(),
)

Un ESS mayor implica un MCSE menor, para una misma dispersión _a posteriori_.
