"""Modelo Poisson, posterior de llamadas (Bayes Rules!, §5.2) y resúmenes.

Gamma en forma–tasa; SciPy recibe scale=1/rate.
Los datos son del libro; el prior Gamma(2, 1) es la elección de Tomás.
La gamma inversa de cola pesada es un ejemplo independiente, en forma–escala.
Ejecutar desde cualquier directorio. Solo se exportan figuras usadas en Typst.
"""

from pathlib import Path

import matplotlib.pyplot as plt
from matplotlib.ticker import MultipleLocator
import numpy as np
from scipy.optimize import brentq, minimize_scalar
from scipy.stats import gamma, invgamma, poisson

from estilo import guardar_pdf

OUTPUT = Path(__file__).resolve().parent
plt.style.use(OUTPUT.parent / "curso.mplstyle")
AZUL, NARANJA, VERDE = "#0072B2", "#D55E00", "#009E73"
DATOS = np.array([6, 2, 2, 1])
ALPHA, BETA = 2, 1
ALPHA_N, BETA_N = ALPHA + DATOS.sum(), BETA + DATOS.size
POSTERIOR = gamma(a=ALPHA_N, scale=1 / BETA_N)
MEDIA = POSTERIOR.mean()
MEDIANA = POSTERIOR.median()
MODA = (ALPHA_N - 1) / BETA_N
MASA = 0.95
ETI = POSTERIOR.ppf([(1 - MASA) / 2, (1 + MASA) / 2])


# En esta gamma unimodal con moda interior, el HDI tiene extremos de igual
# densidad. Parametrizamos por la probabilidad en la cola izquierda: al usar
# cuantiles separados por MASA, la restricción de masa se cumple por construcción.
def diferencia_logdensidad(q):
    lo, hi = POSTERIOR.ppf([q, q + MASA])
    return POSTERIOR.logpdf(lo) - POSTERIOR.logpdf(hi)


q_hdi = brentq(diferencia_logdensidad, 1e-10, 1 - MASA - 1e-10, xtol=1e-14)
HDI = POSTERIOR.ppf([q_hdi, q_hdi + MASA])


def verificar():
    assert (ALPHA_N, BETA_N) == (13, 5)
    assert np.isclose(MEDIA, 13 / 5)
    assert MODA < MEDIANA < MEDIA
    for intervalo in (ETI, HDI):
        assert np.isclose(np.diff(POSTERIOR.cdf(intervalo))[0], MASA, atol=1e-12)
    assert np.isclose(POSTERIOR.pdf(HDI[0]), POSTERIOR.pdf(HDI[1]), rtol=1e-10)
    assert HDI[0] < MODA < HDI[1]
    assert np.diff(HDI)[0] < np.diff(ETI)[0]
    # La densidad crece hasta la moda y decrece después. La igualdad de los
    # extremos verifica por ello la condición de máxima densidad en todo el HDI.
    assert ALPHA_N > 1
    print(f"Posterior Gamma({ALPHA_N}, {BETA_N}); forma–tasa")
    print(f"Media={MEDIA:.9f}, mediana={MEDIANA:.9f}, moda={MODA:.9f}")
    for nombre, intervalo in (("ETI", ETI), ("HDI", HDI)):
        colas = [POSTERIOR.cdf(intervalo[0]), POSTERIOR.sf(intervalo[1])]
        print(
            f"{nombre}: {intervalo}; masa={np.diff(POSTERIOR.cdf(intervalo))[0]:.12f}; "
            f"longitud={np.diff(intervalo)[0]:.9f}; colas={colas}"
        )


def base(altura=270):
    # Ancho físico 480 pt: se inserta a la misma altura, sin reducción.
    fig, ax = plt.subplots(figsize=(480 / 72, altura / 72))
    x = np.linspace(0.5, 6.5, 1601)
    ax.plot(x, POSTERIOR.pdf(x), color=AZUL, linewidth=2.5)
    ax.set(
        xlabel=r"$\lambda$",
        ylabel=r"$p(\lambda\mid \mathrm{𝐲})$",
        xlim=(0.5, 6.5),
        ylim=(0, 0.7),
        xticks=np.arange(1, 7),
    )
    ax.yaxis.set_major_locator(MultipleLocator(0.2))
    return fig, ax


def guardar(fig, nombre):
    guardar_pdf(fig, OUTPUT / f"gamma_{nombre}.pdf")
    plt.close(fig)


def ejemplos_prior():
    """Distintas formas del prior gamma, con parametrización forma–tasa."""
    tasas = np.linspace(0, 12, 2401)
    fig, ax = plt.subplots(figsize=(650 / 72, 300 / 72))
    for forma, tasa in ((1, 1), (2, 1), (5, 1), (5, 2)):
        ax.plot(
            tasas,
            gamma.pdf(tasas, a=forma, scale=1 / tasa),
            linewidth=2.5,
            label=rf"$\alpha={forma},\ \beta={tasa}$",
        )
    ax.set(
        xlabel=r"$\lambda$",
        ylabel=r"$p(\lambda)$",
        xlim=(0, 12),
        ylim=(0, 1.05),
        xticks=np.arange(0, 13, 2),
    )
    ax.yaxis.set_major_locator(MultipleLocator(0.2))
    ax.legend(loc="upper right", frameon=False)
    guardar(fig, "prior_ejemplos")


def prior_llamadas():
    """Prior de la tasa de llamadas y su intervalo central del 95%."""
    prior = gamma(a=ALPHA, scale=1 / BETA)
    inferior, superior = prior.ppf([0.025, 0.975])
    tasas = np.linspace(0, 8, 1601)
    fig, ax = plt.subplots(figsize=(650 / 72, 240 / 72))
    ax.plot(tasas, prior.pdf(tasas), color=AZUL, linewidth=2.5)
    ax.plot(
        [inferior, superior],
        [0, 0],
        color=AZUL,
        linewidth=3,
        marker="|",
        markersize=9,
        clip_on=False,
        zorder=4,
    )
    ax.plot(
        prior.mean(),
        0,
        "o",
        color="0.2",
        markersize=8,
        markeredgecolor="white",
        clip_on=False,
        zorder=5,
    )
    ax.set(
        xlabel=r"$\lambda$",
        ylabel=r"$p(\lambda)$",
        xlim=(0, 8),
        ylim=(0, 0.42),
        xticks=np.arange(0, 9),
    )
    ax.yaxis.set_major_locator(MultipleLocator(0.2))
    guardar(fig, "prior_llamadas")
    print(
        f"Prior Gamma({ALPHA}, {BETA}): media={prior.mean():.2f}; "
        f"intervalo central del 95%=[{inferior:.6f}, {superior:.6f}]"
    )


def perdidas():
    """Costo según el error y riesgo posterior según la estimación elegida."""
    estimaciones = np.linspace(0.5, 4.5, 1201)
    errores = np.linspace(-2, 2, 1001)
    epsilon = 0.1

    def riesgo_cuadratico(a):
        return POSTERIOR.var() + (a - MEDIA) ** 2

    def riesgo_absoluto(a):
        # E[lambda * 1(lambda <= a)] = MEDIA * F_Gamma(alpha_n+1, beta_n)(a).
        momento_truncado = MEDIA * gamma.cdf(a, a=ALPHA_N + 1, scale=1 / BETA_N)
        return MEDIA - a + 2 * (a * POSTERIOR.cdf(a) - momento_truncado)

    def riesgo_tolerancia(a):
        return 1 - (POSTERIOR.cdf(a + epsilon) - POSTERIOR.cdf(a - epsilon))

    for nombre, riesgo, minimo, etiqueta in (
        ("cuadratica", riesgo_cuadratico, MEDIA, f"Media: {MEDIA:.1f}"),
        ("absoluta", riesgo_absoluto, MEDIANA, f"Mediana: {MEDIANA:.3f}"),
        ("tolerancia", riesgo_tolerancia, None, None),
    ):
        ajuste = minimize_scalar(
            riesgo, bounds=(0.5, 4.5), method="bounded", options={"xatol": 1e-12}
        )
        assert ajuste.success
        if minimo is None:
            minimo = ajuste.x
            etiqueta = f"Mínimo: {minimo:.3f}"
            # Para esta gamma, la condición de igual densidad en a±epsilon
            # tiene solución exacta epsilon*coth(beta_n*epsilon/(alpha_n-1)).
            exacto = epsilon / np.tanh(BETA_N * epsilon / (ALPHA_N - 1))
            assert np.isclose(minimo, exacto, atol=1e-7)
        else:
            assert np.isclose(ajuste.x, minimo, atol=1e-7)
        fig, (ax, ax_riesgo) = plt.subplots(1, 2, figsize=(750 / 72, 300 / 72))
        if nombre == "tolerancia":
            ax.plot([-0.4, -epsilon], [1, 1], color=AZUL, linewidth=2.5)
            ax.plot([-epsilon, epsilon], [0, 0], color=AZUL, linewidth=2.5)
            ax.plot([epsilon, 0.4], [1, 1], color=AZUL, linewidth=2.5)
            ax.scatter(
                [-epsilon, epsilon],
                [1, 1],
                facecolors="white",
                edgecolors=AZUL,
                s=40,
                zorder=4,
            )
            ax.scatter([-epsilon, epsilon], [0, 0], color=AZUL, s=40, zorder=4)
            ax.set(
                xlim=(-0.4, 0.4),
                ylim=(-0.08, 1.15),
                xticks=[-0.4, -0.1, 0.1, 0.4],
                yticks=[0, 1],
            )
            ax_riesgo.set_ylim(0.87, 1.005)
            ax_riesgo.yaxis.set_major_locator(MultipleLocator(0.05))
        else:
            costo = errores**2 if nombre == "cuadratica" else np.abs(errores)
            ax.plot(errores, costo, color=AZUL, linewidth=2.5)
            ax.set(
                xlim=(-2, 2),
                ylim=(0, 4.5 if nombre == "cuadratica" else 2.2),
                xticks=[-2, 0, 2],
            )
            ax_riesgo.set_ylim(0, 5.5 if nombre == "cuadratica" else 2.3)
        ax.set(
            title="Costo del error",
            xlabel=r"$\lambda-\hat{\lambda}$",
            ylabel=r"$L(\lambda,\hat{\lambda})$",
        )
        ax_riesgo.plot(estimaciones, riesgo(estimaciones), color=AZUL, linewidth=2.5)
        ax_riesgo.plot(
            minimo, riesgo(minimo), "o", color=NARANJA, markersize=8, zorder=5
        )
        ax_riesgo.text(
            0.5,
            0.88,
            etiqueta,
            transform=ax_riesgo.transAxes,
            ha="center",
            va="top",
            color=NARANJA,
        )
        ax_riesgo.set(
            title="Pérdida esperada",
            xlabel=r"$\hat{\lambda}$",
            ylabel=r"$\rho(\hat{\lambda}\mid \mathrm{𝐲})$",
            xlim=(0.5, 4.5),
            xticks=[1, 2, 3, 4],
        )
        ax_riesgo.hlines(
            riesgo(minimo),
            ax_riesgo.get_xlim()[0],
            minimo,
            color=NARANJA,
            linewidth=1.5,
            linestyles="--",
        )
        ax_riesgo.vlines(
            minimo,
            ax_riesgo.get_ylim()[0],
            riesgo(minimo),
            color=NARANJA,
            linewidth=1.5,
            linestyles="--",
        )
        referencia = MODA if nombre == "tolerancia" else minimo
        ax_riesgo.plot(
            referencia,
            ax_riesgo.get_ylim()[0],
            marker="|",
            color=NARANJA,
            markersize=12,
            markeredgewidth=2,
            clip_on=False,
            zorder=5,
        )
        valor_eje = f"{referencia:.3f}" if nombre == "absoluta" else f"{referencia:.1f}"
        ax_riesgo.set_xticks([1, referencia, 4], ["1", valor_eje, "4"])
        guardar(fig, f"perdida_{nombre}")
        print(f"Pérdida {nombre}: mínimo en {minimo:.9f}; riesgo={riesgo(minimo):.9f}")


def cola_pesada():
    """Ejemplo independiente: gamma inversa de forma 2 y escala 1."""
    distribucion = invgamma(a=2, scale=1)
    eti = distribucion.ppf([0.025, 0.975])

    def extremos(q):
        return distribucion.ppf([q, q + MASA])

    def diferencia(q):
        lo, hi = extremos(q)
        return distribucion.logpdf(lo) - distribucion.logpdf(hi)

    q = brentq(diferencia, 1e-12, 1 - MASA - 1e-12, xtol=1e-14)
    hdi = extremos(q)
    for intervalo in (eti, hdi):
        assert np.isclose(np.diff(distribucion.cdf(intervalo))[0], MASA, atol=1e-12)
    assert np.isclose(distribucion.pdf(hdi[0]), distribucion.pdf(hdi[1]), rtol=1e-10)
    assert hdi[0] < 1 / 3 < hdi[1]  # Moda interior y densidad unimodal.
    assert np.diff(hdi)[0] < np.diff(eti)[0]
    print(
        f"Gamma inversa(2,1): ETI={eti}; HDI={hdi}; colas HDI={q:.9f}, {1-MASA-q:.9f}"
    )
    fig, ax = plt.subplots(figsize=(700 / 72, 350 / 72))
    x = np.linspace(0.02, 6, 2401)
    ax.plot(x, distribucion.pdf(x), color=AZUL, linewidth=2.5)
    ax.set(
        xlabel=r"$\theta$",
        ylabel=r"$p(\theta)$",
        xlim=(0, 6),
        ylim=(-0.32, 1.5),
        xticks=np.arange(0, 7),
    )
    ax.yaxis.set_major_locator(MultipleLocator(0.5))
    ax.spines["bottom"].set_position(("data", 0))
    ax.tick_params(axis="x", pad=48)
    for intervalo, nivel, color, etiqueta in (
        (eti, -0.10, AZUL, "ETI"),
        (hdi, -0.27, NARANJA, "HDI"),
    ):
        ax.plot(
            intervalo,
            [nivel, nivel],
            color=color,
            linewidth=3,
            marker="|",
            markersize=9,
            clip_on=False,
        )
        ax.text(5.8, nivel, etiqueta, color=color, ha="right", va="center")
    for intervalo, color, etiqueta, posicion in (
        (eti, AZUL, "ETI", 0.90),
        (hdi, NARANJA, "HDI", 0.78),
    ):
        ax.text(
            0.97,
            posicion,
            f"Longitud {etiqueta}: {intervalo[1] - intervalo[0]:.3f}",
            transform=ax.transAxes,
            color=color,
            ha="right",
            va="top",
        )
    guardar(fig, "inversa_intervalos")


def main():
    verificar()
    ejemplos_prior()
    prior_llamadas()
    perdidas()
    cola_pesada()

    # Ejemplo ilustrativo, previo al caso aplicado: una observación Poisson
    # y la verosimilitud conjunta de cuatro observaciones independientes.
    conteos = np.arange(11)
    fig, ax = plt.subplots(figsize=(480 / 72, 270 / 72))
    probabilidades = poisson.pmf(conteos, mu=3)
    ax.vlines(conteos, 0, probabilidades, color=AZUL, linewidth=2.4)
    ax.scatter(conteos, probabilidades, color=AZUL, s=45, zorder=3)
    ax.set(
        xlabel=r"$y$",
        ylabel=r"$p(y\mid\lambda=3)$",
        xticks=conteos[::2],
        xlim=(-0.5, 10.5),
        ylim=(0, 0.25),
    )
    ax.yaxis.set_major_locator(MultipleLocator(0.1))
    guardar(fig, "modelo")

    muestra = np.array([1, 3, 2, 4])
    tasas = np.linspace(0, 8, 1601)
    verosimilitud = np.prod(poisson.pmf(muestra[:, None], mu=tasas), axis=0)
    assert muestra.size == 4 and muestra.sum() == 10
    assert np.isclose(tasas[np.argmax(verosimilitud)], muestra.mean())
    assert np.allclose(
        verosimilitud, tasas**10 * np.exp(-4 * tasas) / 288, rtol=1e-12, atol=1e-16
    )
    fig, ax = plt.subplots(figsize=(480 / 72, 270 / 72))
    ax.plot(tasas, verosimilitud, color=AZUL, linewidth=2.5)
    ax.set(
        xlabel=r"$\lambda$",
        ylabel=r"$p(\mathrm{𝐲}\mid\lambda)$",
        xlim=(0, 8),
        ylim=(0, 0.002),
        xticks=np.arange(0, 9, 2),
    )
    ax.yaxis.set_major_locator(MultipleLocator(0.001))
    ax.ticklabel_format(axis="y", style="plain", useOffset=False)
    guardar(fig, "verosimilitud")

    # Comparación del caso aplicado: escalas verticales independientes.
    tasas_llamadas = np.linspace(0, 10, 2001)
    prior = gamma(a=ALPHA, scale=1 / BETA)
    likelihood = np.prod(poisson.pmf(DATOS[:, None], mu=tasas_llamadas), axis=0)
    fig, axes = plt.subplots(1, 3, figsize=(750 / 72, 300 / 72))
    for ax, valores, titulo, color in zip(
        axes,
        (prior.pdf(tasas_llamadas), likelihood, POSTERIOR.pdf(tasas_llamadas)),
        (
            f"Prior\nGamma({ALPHA}, {BETA})",
            "Verosimilitud\n" + r"$n=4,\ \sum y_i=11$",
            f"Posterior\nGamma({ALPHA_N}, {BETA_N})",
        ),
        (AZUL, NARANJA, VERDE),
    ):
        ax.plot(tasas_llamadas, valores, color=color, linewidth=2.5)
        ax.set(
            title=titulo,
            xlabel=r"$\lambda$",
            xlim=(0, 10),
            ylim=(0, valores.max() * 1.12),
            xticks=[0, 5, 10],
            yticks=[],
        )
    guardar(fig, "actualizacion")

    fig, ax = base(300)
    ax.set_ylim(0, 0.85)
    # Posiciones reales; los textos se separan mediante segmentos sin flechas.
    for valor, texto, posicion, color, simbolo in (
        (MODA, f"Moda\n{MODA:.1f}", (1.5, 0.74), AZUL, "s"),
        (MEDIANA, f"Mediana\n{MEDIANA:.3f}", (3.45, 0.74), VERDE, "^"),
        (MEDIA, f"Media\n{MEDIA:.1f}", (5.4, 0.74), NARANJA, "o"),
    ):
        ax.plot(valor, 0, simbolo, color=color, markersize=8, clip_on=False, zorder=5)
        ax.annotate(
            texto,
            xy=(valor, 0.01),
            xytext=posicion,
            ha="center",
            va="center",
            color=color,
            arrowprops=dict(
                arrowstyle="-", color=color, linewidth=1, shrinkA=5, shrinkB=5
            ),
        )
    guardar(fig, "resumenes")

    fig, ax = base(300)
    ax.set_ylim(-0.17, 0.62)
    ax.spines["bottom"].set_position(("data", 0))
    ax.tick_params(axis="x", pad=48)
    for intervalo, nivel, color, etiqueta in (
        (ETI, -0.05, AZUL, "ETI"),
        (HDI, -0.13, NARANJA, "HDI"),
    ):
        ax.plot(
            intervalo,
            [nivel, nivel],
            color=color,
            linewidth=3,
            marker="|",
            markersize=9,
            clip_on=False,
        )
        ax.text(6.25, nivel, etiqueta, ha="right", va="center", color=color)
    ax.plot(
        MEDIA,
        0,
        "o",
        color="0.2",
        markersize=8,
        markeredgecolor="white",
        clip_on=False,
        zorder=5,
    )
    guardar(fig, "intervalos")


if __name__ == "__main__":
    main()
