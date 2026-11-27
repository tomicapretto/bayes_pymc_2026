#set document(title: "Intercambiabilidad y el teorema de de Finetti")
#set page(paper: "a4", margin: (x: 20mm, y: 18mm),
  footer: context align(center)[#text(size: 9pt, fill: luma(45%))[#counter(page).display()]],
)
#set text(font: "Libertinus Serif", size: 10.5pt, lang: "es")
#set par(justify: true, leading: 0.5em)
#set heading(numbering: none)
#show heading.where(level: 1): set text(size: 13pt)
#let Bernoulli = math.op("Bernoulli")
#let Beta = math.op("Beta")
#let Cov = math.op("Cov")
#let Var = math.op("Var")
#let EE = math.op("E")
#import "figuras/05/intercambiabilidad.typ": hospitales, hospitales-complejidad, probabilidad-compartida
#show figure.caption: set text(size: 9pt)

#align(center)[
  #text(size: 18pt, weight: "bold")[Intercambiabilidad y el teorema de de Finetti]
]
#v(0.8em)

En el ejemplo de los hospitales vimos dos formas de estimar las probabilidades de supervivencia.
Podíamos usar una única probabilidad para todos los hospitales o estimar una probabilidad para cada uno,
con distribuciones _a priori_ independientes. La primera opción no permitía describir diferencias entre hospitales.
La segunda sí, pero los datos de un hospital no aportaban información sobre los demás.

El modelo jerárquico nos permitió combinar ambas ideas: cada hospital tenía su propia probabilidad,
pero todas provenían de una distribución común.

En este apunte vamos a ver cómo se relaciona esta
construcción con la *intercambiabilidad* (_exchangeability_) y con el teorema de de Finetti.

= Intercambiabilidad

Supongamos que, antes de observar los resultados, no tenemos información que nos permita distinguir
las probabilidades de supervivencia de los hospitales. En ese caso, cambiar las etiquetas de dos
hospitales no debería modificar la distribución conjunta _a priori_ de sus probabilidades.
Este supuesto se conoce como intercambiabilidad.

En general, un conjunto de variables aleatorias es intercambiable si su distribución conjunta no cambia
al permutar sus índices. Para las probabilidades de los hospitales, esto significa que

$ p(pi_1, dots.c, pi_I) = p(pi_(rho(1)), dots.c, pi_(rho(I))) $

para cualquier permutación $rho$.

Por ejemplo, intercambiar las etiquetas de los hospitales A y B deja la distribución conjunta _a priori_ igual.
Esto no exige que $pi_A$ y $pi_B$ tengan el mismo valor. El supuesto se refiere a cómo representamos
nuestra incertidumbre sobre esas probabilidades antes de observar los datos. Después de observar
las operaciones y los supervivientes de cada hospital, sus distribuciones _a posteriori_ pueden ser distintas (de hecho, probablemente, lo sean).

#figure(
  hospitales(),
  caption: [Intercambiar las probabilidades de los hospitales A y B conserva la distribución conjunta _a priori_.],
) <fig-hospitales-intercambiabilidad>

#pagebreak()

= Independencia condicional

Las variables independientes e idénticamente distribuidas (i.i.d.) son intercambiables.
Sin embargo, unas variables pueden ser intercambiables sin ser independientes.
Para ver cómo ocurre esto, consideremos tres variables aleatorias binarias $X_1, X_2, X_3$ que comparten
una probabilidad desconocida $pi$.

#block(breakable: false)[
Primero generamos un valor de $pi$ a partir de una distribución $F$. Luego, usando ese mismo valor,
generamos resultados Bernoulli independientes:

$
  pi & tilde.op F \
  X_j | pi & tilde.op Bernoulli(pi), quad j = 1, 2, 3.
$
]

Si conocemos $pi$, observar $X_1$ no cambia la distribución de $X_2$ ni la de $X_3$. Por eso decimos que las variables son *condicionalmente independientes* dado $pi$.

#figure(
  probabilidad-compartida(),
  caption: [Las tres variables aleatorias comparten una misma probabilidad desconocida $pi$. Condicionalmente a ella son independientes. Aprender sobre $pi$ a partir de una de las observaciones cambia lo que esperamos de las otras dos.],
) <fig-probabilidad-compartida>

En la @fig-probabilidad-compartida usamos una distribución $Beta(1,1)$ para $pi$.
Antes de observar resultados, tanto $X_2$ como $X_3$ tienen probabilidad $1\/2$ de valer $1$.
Después de observar $X_1 = 1$, la distribución de $pi$ pasa a ser $Beta(2,1)$ y la probabilidad
de un éxito sube a $2\/3$ para cada uno de los otros dos resultados.
Observar el primer resultado cambia lo que creemos sobre la probabilidad compartida y, por eso,
cambia nuestras predicciones de $X_2$ y $X_3$.

De este modo, los resultados pueden ser dependientes cuando no condicionamos en $pi$.
Para $j != k$, esa dependencia se puede expresar como

$ Cov(X_j, X_k) = EE(pi^2) - EE(pi)^2 = Var(pi). $

Si $F$ tiene varianza positiva, la covarianza entre los resultados también es positiva.
La dependencia aparece porque todos comparten una misma cantidad desconocida.

= El teorema de de Finetti

La construcción anterior produce una secuencia intercambiable: cambiar el orden de los resultados
no modifica su distribución conjunta. Podemos preguntarnos si también es posible recorrer el camino
inverso. Es decir, si partimos de una secuencia intercambiable, ¿podemos representarla usando
resultados independientes que comparten una probabilidad desconocida?

Para una secuencia binaria infinitamente intercambiable, el teorema de de Finetti establece que sí.
Existe una única distribución de probabilidad $F$ sobre $[0,1]$ tal que, para cualquier $n$,

$
  P(X_1 = x_1, dots.c, X_n = x_n)
  = integral_0^1 product_(j=1)^n pi^(x_j) (1-pi)^(1-x_j) thin F(upright(d) pi).
$

Para interpretar esta expresión, fijemos primero un valor de $pi$. El producto dentro de la integral
es la probabilidad de los resultados $x_1, dots.c, x_n$ bajo un modelo Bernoulli i.i.d.
Luego integramos sobre los valores posibles de $pi$, con los pesos que indica $F$.
Así obtenemos una *mezcla* de distribuciones Bernoulli i.i.d.

Cuando $F$ tiene densidad, podemos escribir $F(upright(d) pi) = p(pi) thin upright(d) pi$.
En ese caso reconocemos los dos componentes que venimos usando: la verosimilitud Bernoulli y
la distribución _a priori_ $p(pi)$.

La condición de *intercambiabilidad infinita* es necesaria para esta representación general.
Suponemos que la secuencia puede continuar indefinidamente y que cualquier segmento finito es
intercambiable. Esto no requiere observar infinitos datos: es un supuesto sobre el modelo.
Un vector finito puede ser intercambiable sin admitir esta representación exacta si no puede
extenderse a una secuencia infinitamente intercambiable.

#pagebreak()

= Modelos jerárquicos

Hasta acá aplicamos la intercambiabilidad a resultados binarios. La versión general del teorema
permite representar secuencias infinitamente intercambiables como variables i.i.d. condicionalmente
a una distribución aleatoria. Podemos usar esta idea para pensar en los parámetros de distintos grupos:
si los consideramos parte de una secuencia infinitamente intercambiable, podemos representarlos
como valores generados por una distribución común desconocida.

Volvamos a los hospitales. Para construir el modelo elegimos una distribución beta para las
probabilidades de supervivencia:

$ pi_i | alpha, beta tilde.op Beta(alpha, beta), $

con independencia entre hospitales dados $alpha$ y $beta$. Como tampoco conocemos estos
hiperparámetros, les asignamos una distribución conjunta _a priori_ $p(alpha, beta)$.
Al integrarlos, obtenemos la distribución conjunta _a priori_ de las probabilidades:

$
  p(pi_1, dots.c, pi_I)
  = integral_0^infinity integral_0^infinity
  [product_(i=1)^I Beta(pi_i | alpha, beta)]
  p(alpha, beta) thin upright(d) beta thin upright(d) alpha.
$

Si permutamos los hospitales, los factores del producto cambian de orden, pero el resultado es
el mismo. Por lo tanto, esta distribución _a priori_ es intercambiable.

Dados $alpha$ y $beta$, las probabilidades de los hospitales son independientes. Pero al integrar
estos hiperparámetros, las probabilidades quedan vinculadas. Cuando observamos los datos de un
hospital, aprendemos sobre su probabilidad de supervivencia y también sobre $alpha$ y $beta$.
Como esos hiperparámetros son compartidos, lo aprendido interviene en las estimaciones de los demás
hospitales. Así es como el modelo permite compartir información entre grupos.

= Elección de la distribución común

El teorema da una representación como mezcla de distribuciones i.i.d. bajo sus supuestos.
La elección de una familia beta para los hospitales es una decisión adicional: el teorema no exige
que la distribución común sea beta, normal ni que pueda describirse con solo dos hiperparámetros.

También conviene distinguir la intercambiabilidad de la elección de una distribución _a priori_ concreta.
Si conocemos toda la distribución conjunta de una secuencia binaria infinitamente intercambiable,
la distribución de mezcla $F$ es única. Pero hay muchas distribuciones conjuntas intercambiables.
Por eso, suponer intercambiabilidad no alcanza para elegir $F$.

En nuestros modelos todavía necesitamos decidir qué familia usar, qué distribuciones _a priori_ asignar a sus
hiperparámetros y a qué población de grupos queremos extender las conclusiones.

#pagebreak()

= Intercambiabilidad parcial

En los ejemplos de la clase distinguimos grupos, edades y tamaños muestrales.
No podemos intercambiar cualquier observación sin tener en cuenta esa estructura.
Usamos una *intercambiabilidad parcial*: el supuesto se aplica dentro de la estructura que
especifica cada modelo.

En los *hospitales*, la distribución _a priori_ de las probabilidades $pi_i$ es intercambiable.
Los conteos de supervivientes $Y_i$, en cambio, también dependen del número de operaciones $n_i$.
Como esos tamaños pueden ser distintos, los conteos no son intercambiables en general.
Si además conociéramos diferencias relevantes entre los pacientes, podríamos incorporarlas como covariables.

Volvamos a los cinco hospitales de la @fig-hospitales-intercambiabilidad. Hasta ahora solo usamos
sus etiquetas. Supongamos que también sabemos que A, B y C atienden casos de menor complejidad,
mientras que D y E atienden casos de mayor complejidad. Esta información nos da una razón para revisar el supuesto inicial:
podríamos considerar intercambiables las probabilidades dentro de cada categoría y usar distribuciones
distintas para las dos categorías.

#figure(
  hospitales-complejidad(),
  caption: [Al incorporar información que distingue a los hospitales, podemos revisar qué probabilidades consideramos intercambiables.],
) <fig-hospitales-complejidad>

La intercambiabilidad depende de qué información usamos para representar el sistema. Conocer una
diferencia relevante nos permite incorporarla al modelo, necesitamos justificar cuáles de esas
diferencias dejamos fuera.

En las *escuelas*, las medias de puntajes $mu_i$ tienen una distribución _a priori_ intercambiable.
Dadas la media de cada escuela y el desvío residual, los puntajes de sus estudiantes siguen
el modelo normal. Si cambiamos un estudiante de escuela, cambia la media que le corresponde
en el modelo. Por eso no suponemos que se pueda intercambiar cualquier par de estudiantes
sin considerar a qué escuela pertenecen. Los tamaños muestrales por escuela pueden ser distintos.

En el ejemplo de *crecimiento mandibular*, los pares de interceptos y pendientes tienen una distribución _a priori_
intercambiable entre niños. Las mediciones de un mismo niño se tomaron a distintas edades y tienen
medias diferentes según la regresión. Si intercambiamos las alturas dejando fijas las edades,
la distribución de los datos puede cambiar.

En cada caso necesitamos especificar qué cantidades consideramos intercambiables y qué información
usamos para distinguirlas. Esa elección determina cómo compartimos información en el modelo jerárquico.
