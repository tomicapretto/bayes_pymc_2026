"""Figuras y secuencias de la clase 3. Ejecutar desde cualquier directorio.

Las secuencias se revelan con Touying: el PDF se presenta avanzando por pasos.
El ejemplo animado de HMC requiere ffmpeg y se presenta con pdfpc.
"""

from pathlib import Path

import matplotlib.pyplot as plt
from matplotlib.collections import LineCollection
from matplotlib.colors import LinearSegmentedColormap
import numpy as np
from scipy.stats import beta, binom, multivariate_normal, norm

OUTPUT = Path(__file__).resolve().parent
plt.style.use(OUTPUT.parent / "curso.mplstyle")
plt.rcParams.update({
    "font.size": 18,
    "axes.titlesize": 18,
    "axes.labelsize": 18,
    "xtick.labelsize": 18,
    "ytick.labelsize": 18,
    "legend.fontsize": 18,
})
AZUL, NARANJA, VERDE = "#0072B2", "#D55E00", "#009E73"


def guardar(fig, nombre, altura=250, ancho=400):
    """Exportar al tamaño de inserción en Typst, sin recortar el lienzo."""
    fig.set_size_inches(ancho / 72, altura / 72)
    fig.savefig(OUTPUT / f"{nombre}.pdf")
    plt.close(fig)


# Grilla: alturas de densidad normalizadas por el área de las barras.
posterior = beta(18, 7)
eje = np.linspace(0, 1, 1001)
for m in (4, 10, 20, 40):
    puntos = (np.arange(m) + 0.5) / m
    ancho = 1 / m
    alturas = binom.pmf(17, 23, puntos)
    densidades = alturas / np.sum(alturas * ancho)
    areas = densidades * ancho
    assert np.isclose(areas.sum(), 1)
    fig, ax = plt.subplots()
    ax.bar(
        puntos, densidades, width=ancho, align="center",
        facecolor="none", edgecolor="0.25", linewidth=0.8,
    )
    ax.plot(eje, posterior.pdf(eje), color=AZUL, linewidth=2.4)
    ax.scatter(puntos, densidades, color="0.15", s=14, zorder=3)
    ax.set(xlabel=r"$\theta$", ylabel="Densidad", xlim=(0, 1), ylim=(0, 5), xticks=[0, 0.5, 1])
    guardar(fig, f"grilla_{m}", altura=340, ancho=460)
    # Si el umbral corta una barra, solo contamos el área a su derecha.
    anchos_sobre_umbral = np.clip(puntos + ancho / 2 - 0.7, 0, ancho)
    media = np.dot(puntos, areas)
    varianza = np.dot((puntos - media) ** 2, areas)
    mediana = np.interp(0.5, np.r_[0, np.cumsum(areas)], np.linspace(0, 1, m + 1))
    probabilidad = np.dot(densidades, anchos_sobre_umbral)
    print(f"Grilla de {m}: área={areas.sum():.6f}, media={media:.6f}, varianza={varianza:.8f}, mediana={mediana:.6f}, P(theta>0.7)={probabilidad:.6f}")
assert abs(media - posterior.mean()) < 1e-5
assert abs(probabilidad - posterior.sf(0.7)) < 1e-3

# Grilla bidimensional para ilustrar el costo de aumentar la dimensión.
bordes_2d = np.linspace(-3.5, 3.5, 21)
eje_2d = (bordes_2d[:-1] + bordes_2d[1:]) / 2
xx, yy = np.meshgrid(eje_2d, eje_2d)
densidad_2d = multivariate_normal.pdf(
    np.stack([xx, yy], axis=-1), mean=[0, 0], cov=[[1, 0.7], [0.7, 1]]
)
assert xx.size == 20 * 20
fig, ax = plt.subplots(layout="compressed")
ax.pcolormesh(
    bordes_2d, bordes_2d, densidad_2d,
    cmap=LinearSegmentedColormap.from_list("naranja_curso", ["white", NARANJA]),
    shading="flat", vmin=0,
)
ax.scatter(
    xx.ravel(),
    yy.ravel(),
    color="black",
    s=5, zorder=3,
)
ax.set(
    xlabel=r"$\theta_1$",
    ylabel=r"$\theta_2$",
    xticks=[-3, 0, 3],
    yticks=[-3, 0, 3],
    xlim=(-3.6, 3.6),
    ylim=(-3.6, 3.6),
    aspect="equal",
)
guardar(fig, "grilla_dimension_2d", altura=350, ancho=390)

# Repeticiones independientes para observar el error de integración Monte Carlo.
rng_mc = np.random.default_rng(312)
cantidades_mc = np.arange(1, 1001)
medias_mc = rng_mc.beta(18, 7, size=(1000, len(cantidades_mc)))
np.cumsum(medias_mc, axis=1, out=medias_mc)
medias_mc /= cantidades_mc
limites_mc = np.quantile(medias_mc, [0.025, 0.975], axis=0)
assert np.isclose(medias_mc[:, -1].std(ddof=1), posterior.std() / np.sqrt(cantidades_mc[-1]), rtol=0.1)
assert np.ptp(limites_mc[:, -1]) < np.ptp(limites_mc[:, 99])

for cantidad, con_banda, nombre in (
    (1, False, "monte_carlo_trayectoria_1"),
    (2, False, "monte_carlo_trayectorias_2"),
    (12, False, "monte_carlo_trayectorias"),
    (12, True, "monte_carlo_banda"),
):
    fig, ax = plt.subplots()
    if con_banda:
        ax.fill_between(
            cantidades_mc, *limites_mc, color=AZUL, alpha=0.2,
            linewidth=0, label="Banda central del 95%",
        )
    for trayectoria in medias_mc[:cantidad]:
        ax.plot(cantidades_mc, trayectoria, color=AZUL, alpha=0.65, linewidth=1)
    ax.axhline(posterior.mean(), color="0.5", linestyle="--", linewidth=2.4, label="Media exacta: 0.72")
    ax.set(
        xscale="log", xlim=(1, 1000), ylim=(0.5, 0.9),
        xlabel="Cantidad de muestras independientes",
        ylabel="Promedio acumulado",
        xticks=[1, 10, 100, 1000], yticks=[0.5, 0.6, 0.7, 0.8, 0.9],
    )
    ax.minorticks_off()
    guardar(fig, nombre, altura=300, ancho=480)

# Ejemplo de integración por Monte Carlo: área del círculo en un cuadrado.
rng_pi = np.random.default_rng(95)
puntos_pi = rng_pi.uniform(-1, 1, size=(5000, 2))
dentro_pi = (puntos_pi**2).sum(axis=1) <= 1
angulo_pi = np.linspace(0, 2 * np.pi, 301)
fig, axes = plt.subplots(1, 2)
for ax, cantidad in zip(axes, (200, 5000)):
    ax.scatter(
        *puntos_pi[:cantidad].T,
        c=np.where(dentro_pi[:cantidad], AZUL, NARANJA),
        s=3, alpha=0.6, rasterized=True,
    )
    ax.plot(np.cos(angulo_pi), np.sin(angulo_pi), color="0.2", linewidth=1)
    ax.set(
        xlim=(-1, 1), ylim=(-1, 1), aspect="equal", xticks=[], yticks=[],
        title=rf"$S={cantidad}$: $\hat{{\pi}}={4 * dentro_pi[:cantidad].mean():.3f}$",
    )
    for spine in ax.spines.values():
        spine.set_visible(False)
fig.set_size_inches(560 / 72, 350 / 72)
fig.savefig(OUTPUT / "monte_carlo_pi.png", dpi=216)
plt.close(fig)

# Frecuencias de visita de la cadena de dos estados mostrada en las slides.
transicion_dos = np.array([[0.8, 0.2], [0.3, 0.7]])
estacionaria_dos = np.array([0.6, 0.4])
transicion_tres = np.array([[0.6, 0.3, 0.1], [0.2, 0.5, 0.3], [0.2, 0.2, 0.6]])
estacionaria_tres = np.full(3, 1 / 3)
assert np.allclose(estacionaria_dos @ transicion_dos, estacionaria_dos)
assert np.allclose(estacionaria_tres @ transicion_tres, estacionaria_tres)
rng_estados = np.random.default_rng(2026)
estado_actual = 0
visitas = np.zeros(2, dtype=int)
for cantidad in range(1, 10001):
    visitas[estado_actual] += 1
    if cantidad in (100, 1000, 10000):
        print(f"Cadena de dos estados, T={cantidad}: {visitas / cantidad}")
    estado_actual = int(rng_estados.random() >= transicion_dos[estado_actual, 0])

# Reutilizar exactamente los mismos incrementos en los dos procesos.
rng_cadenas = np.random.default_rng(41)
z = rng_cadenas.normal(size=(500, 150))
rw = np.column_stack([np.zeros(len(z)), np.cumsum(z, axis=1)])
ar = np.zeros_like(rw)
for t in range(1, 151):
    ar[:, t] = 0.7 * ar[:, t - 1] + z[:, t - 1]
# Primero las trayectorias completas. Luego, cortes de esas mismas simulaciones.
tiempos = np.arange(151)
colores_trayectorias = [AZUL, NARANJA, VERDE]


def dibujar_trayectorias(ax, simulaciones, cantidad, limite, destacar=True):
    if cantidad > 3 or not destacar:
        segmentos = np.stack(
            [np.broadcast_to(tiempos, (cantidad, len(tiempos))), simulaciones[:cantidad]],
            axis=-1,
        )
        # Rasterizar solo la nube conserva livianos los PDF y deja ejes y texto vectoriales.
        ax.add_collection(
            LineCollection(segmentos, colors="0.4", linewidths=0.6, alpha=0.12, rasterized=True)
        )
    colores = colores_trayectorias[: min(cantidad, 3)] if destacar else []
    for i, color in enumerate(colores):
        ax.plot(tiempos, simulaciones[i], color=color, linewidth=1.3)
    ax.set(
        xlabel="Iteración",
        ylabel=r"$X_t$",
        xlim=(-2, 152),
        ylim=(-limite, limite),
        xticks=[0, 50, 100, 150],
    )


for nombre, simulaciones, limite in (("paseo", rw, 50), ("ar1", ar, 7)):
    assert np.max(np.abs(simulaciones)) < limite
    for cantidad in (1, 2, 3, 500):
        fig, ax = plt.subplots()
        dibujar_trayectorias(ax, simulaciones, cantidad, limite)
        guardar(fig, f"{nombre}_trayectorias_{cantidad}", altura=300, ancho=480)

    for t in (1, 10, 40, 100, 150):
        fig, axes = plt.subplots(
            1, 2, sharey=True, gridspec_kw={"width_ratios": [1.5, 1], "wspace": 0.08}
        )
        dibujar_trayectorias(axes[0], simulaciones, 500, limite, destacar=False)
        axes[0].axvline(t, color=NARANJA, linestyle="--", linewidth=1.8)
        axes[0].text(
            t,
            1.025,
            f"t = {t}",
            transform=axes[0].get_xaxis_transform(),
            ha="right" if t == 150 else "left",
            color=NARANJA,
        )
        # Mostrar la distribución teórica, sin puntos ni conexiones individuales.
        valores = np.linspace(-limite, limite, 1501)
        sd = np.sqrt(t) if nombre == "paseo" else np.sqrt((1 - 0.7 ** (2 * t)) / (1 - 0.7**2))
        densidad = norm.pdf(valores, scale=sd)
        axes[1].plot(densidad, valores, color=AZUL)
        axes[1].set(xlim=(0, 1.15 * densidad.max()), xticks=[], xlabel="")
        axes[1].spines["bottom"].set_visible(False)
        axes[1].tick_params(axis="y", left=False, labelleft=False)
        guardar(fig, f"{nombre}_{t}", altura=350, ancho=600)
assert np.isclose(ar[:, -1].var(), 1 / (1 - 0.7**2), rtol=0.08)

# HMC: ilustraciones con potenciales gaussianos y masa identidad.
coordenadas_hmc = np.linspace(-3.2, 3.2, 601)
potencial_hmc = coordenadas_hmc**2 / 2
fig, axes = plt.subplots(1, 2)
axes[0].plot(coordenadas_hmc, np.exp(-potencial_hmc), color=AZUL, linewidth=2.4)
axes[0].set(xlabel=r"$\theta$", ylabel=r"$p^*(\theta)$", xticks=[-3, 0, 3], yticks=[0, 1])
axes[1].plot(coordenadas_hmc, potencial_hmc, color=NARANJA, linewidth=2.4)
axes[1].set(xlabel=r"$\theta$", ylabel=r"$U(\theta)$", xticks=[-3, 0, 3], yticks=[0, 2, 4])
guardar(fig, "hmc_paisaje", altura=300, ancho=576)

from hmc_animacion import generar_animacion, generar_caidas, generar_cadena_hmc

generar_animacion()
generar_caidas()
generar_cadena_hmc()

# Esquema geométrico de las aproximaciones convergente y divergente.
from leapfrog_comparacion import generar_leapfrog
from rwmh_animacion import generar_rwmh

generar_leapfrog()
generar_rwmh()

# Diagnósticos: autocorrelación, estabilización y comparación de cadenas.
from diagnosticos import generar_diagnosticos

generar_diagnosticos()

print(f"Figuras guardadas en {OUTPUT}")
