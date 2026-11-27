# Introducción a la estadística bayesiana con PyMC

Este repositorio contiene las presentaciones y notebooks de un curso introductorio de estadística bayesiana con Python.
El recorrido comienza con la regla de Bayes y los modelos conjugados, continúa con el muestreo y los modelos lineales, 
y termina con modelos jerárquicos.

Se asumen conocimientos básicos de probabilidad, estadística y Python.
No hace falta tener experiencia con PyMC, ArviZ, PreliZ o Bambi.

## Material

En [notebooks](notebooks/) se encuentra el siguiente material:

- [01_inferencia_bayesiana.ipynb](notebooks/01_inferencia_bayesiana.ipynb): regla de Bayes, modelos bayesianos y actualización de una proporción.
- [02_modelos_conjugados.ipynb](notebooks/02_modelos_conjugados.ipynb): modelos conjugados, resúmenes del _posterior_ y predicción.
- [03_introduccion_pymc.ipynb](notebooks/03_introduccion_pymc.ipynb): especificación de modelos, muestreo y diagnósticos con PyMC y ArviZ.
- [04_modelos_lineales.ipynb](notebooks/04_modelos_lineales.ipynb): regresión lineal con PyMC, chequeos predictivos y comparación de modelos.
- [04b_modelos_lineales_bambi.ipynb](notebooks/04b_modelos_lineales_bambi.ipynb): especificación de los modelos lineales mediante fórmulas con Bambi.
- [04c_temperaturas.ipynb](notebooks/04c_temperaturas.ipynb): aplicación de regresión con predictores continuos y categóricos.
- [05_modelos_jerarquicos.ipynb](notebooks/05_modelos_jerarquicos.ipynb): _complete pooling_, _no pooling_ y _partial pooling_.
- [05b_crecimiento_mandibular.ipynb](notebooks/05b_crecimiento_mandibular.ipynb): ejemplo de regresión lineal jerárquica.

Las [presentaciones](presentaciones/) están disponibles en PDF junto con sus fuentes Typst.

Los conjuntos de datos están en [datos](datos/), con sus fuentes en el [README de datos](datos/README.md).

Los ejemplos tomados o adaptados de otros materiales se reconocen en [Créditos](creditos.md).

## Cómo usar el material

Primero hay que [instalar uv](https://docs.astral.sh/uv/getting-started/installation/). Luego, desde una terminal:

```bash
git clone https://github.com/tomicapretto/intro_bayes_2026.git
cd intro_bayes_2026
uv sync --locked
```

Esto crea el entorno `.venv` e instala las versiones registradas en `uv.lock`. El proyecto usa Python 3.14; uv puede descargarlo si no está instalado.

Para abrir las notebooks con JupyterLab:

```bash
uv run --locked --with jupyter jupyter lab
```

Abrir los archivos desde la carpeta `notebooks` y ejecutar las celdas en orden
Las rutas de los datos y las figuras son relativas a esa carpeta, por lo que c.onviene conservar la estructura del repositorio.

Para visualizar los diagramas de los modelos también hace falta instalar Graphviz en el sistema.

