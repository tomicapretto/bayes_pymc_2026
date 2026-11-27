"""Diagnósticos de MCMC: una cadena, estabilización y comparación de cadenas.

Ejecutar desde la raíz: MPLBACKEND=Agg python presentaciones/figuras/03/diagnosticos.py
Los ejemplos comparten una estacionaria N(0,1). R-hat, ESS y MCSE se calculan
con ArviZ; el dibujo de varianzas usa la definición clásica de R-hat.
"""
from pathlib import Path
import json

import arviz as az
import matplotlib.pyplot as plt
import numpy as np
from scipy.stats import gaussian_kde, norm

OUTPUT = Path(__file__).resolve().parent
COLORES = ("#0072B2", "#D55E00", "#009E73", "#CC79A7")


def preparar_estilo():
    plt.style.use(OUTPUT.parent / "curso.mplstyle")
    plt.rcParams.update({"font.size": 18, "axes.titlesize": 18, "axes.labelsize": 18,
                         "xtick.labelsize": 18, "ytick.labelsize": 18, "legend.fontsize": 14})


def guardar(fig, nombre, ancho=480, alto=300):
    fig.set_size_inches(ancho / 72, alto / 72)
    fig.savefig(OUTPUT / f"{nombre}.pdf")
    plt.close(fig)


def ar1(ruido, rho, inicio):
    """Innovaciones escaladas para que la estacionaria tenga varianza 1."""
    ruido = np.atleast_2d(ruido)
    valor = np.empty((ruido.shape[0], ruido.shape[1] + 1))
    valor[:, 0] = inicio
    for i in range(ruido.shape[1]):
        valor[:, i + 1] = rho * valor[:, i] + np.sqrt(1 - rho**2) * ruido[:, i]
    return valor


def acf(valores, max_lag=30):
    centrados = valores - valores.mean()
    cov = np.correlate(centrados, centrados, mode="full")[len(valores) - 1:]
    return cov[:max_lag + 1] / cov[0]


def varianzas_clasicas(cadenas):
    m, n = cadenas.shape
    w = cadenas.var(axis=1, ddof=1).mean()
    b = n * cadenas.mean(axis=1).var(ddof=1)
    v = (n - 1) / n * w + b / n
    return w, b, v, np.sqrt(v / w)


def generar_diagnosticos():
    preparar_estilo()
    # Una cadena en equilibrio: aislar autocorrelación del efecto del inicio.
    rng = np.random.default_rng(662)
    ruido = rng.normal(size=(1, 1000))
    inicio = rng.normal()
    una = [ar1(ruido, rho, inicio)[0, 1:] for rho in (0.0, 0.9)]
    fig, axes = plt.subplots(2, 1, sharex=True, sharey=True)
    for ax, valores, color, titulo in zip(axes, una, COLORES,
            ("Sin autocorrelación", "Con autocorrelación positiva")):
        ax.plot(np.arange(1, 1001), valores, color=color, linewidth=0.85)
        ax.axhline(0, color="0.5", linestyle="--", linewidth=0.8)
        ax.text(0.98, 0.95, titulo, ha="right", va="top", transform=ax.transAxes,
                fontsize=14, bbox={"facecolor": "white", "edgecolor": "none", "alpha": 0.9, "pad": 1})
        ax.set(ylabel=r"$\theta$", xlim=(1, 1000), ylim=(-4, 4), yticks=[-3, 0, 3])
    axes[-1].set(xlabel="Iteración", xticks=[1, 500, 1000])
    guardar(fig, "diagnostico_una_trazas")

    fig, axes = plt.subplots(1, 2, sharey=True)
    for ax, valores, color, titulo in zip(axes, una, COLORES,
            ("Sin dependencia", "Con dependencia")):
        correlaciones = acf(valores)
        ax.vlines(np.arange(31), 0, correlaciones, color=color, linewidth=1.4)
        ax.plot(np.arange(31), correlaciones, "o", color=color, markersize=2)
        ax.axhline(0, color="0.5", linewidth=0.8)
        ax.set(title=titulo, xlabel=r"Rezago $k$", xlim=(-0.5, 30.5), ylim=(-0.15, 1.05),
               xticks=[0, 15, 30], yticks=[0, 0.5, 1])
    axes[0].set_ylabel("Autocorrelación")
    guardar(fig, "diagnostico_una_acf")

    # Una cadena desde un inicio alejado: relajación rápida frente a persistencia.
    ruido_est = np.random.default_rng(318).normal(size=(1, 1200))
    fig, axes = plt.subplots(2, 1, sharex=True, sharey=True)
    for ax, rho, color, titulo in zip(axes, (0.97, 0.9995), COLORES,
            ("Deja atrás el inicio", "Todavía depende del inicio")):
        valores = ar1(ruido_est, rho, 6.0)[0]
        ax.axvspan(0, 200, color="0.9", zorder=0)
        ax.plot(np.arange(1201), valores, color=color, linewidth=0.9)
        ax.axhline(0, color="0.5", linestyle="--", linewidth=0.8)
        ax.text(0.98, 0.95, titulo, ha="right", va="top", transform=ax.transAxes,
                fontsize=14, bbox={"facecolor": "white", "edgecolor": "none", "alpha": 0.9, "pad": 1})
        ax.set(ylabel=r"$\theta$", xlim=(0, 1200), ylim=(-3.5, 7), yticks=[-2, 0, 6])
    axes[-1].set(xlabel="Iteración", xticks=np.arange(0, 1201, 200))
    guardar(fig, "diagnostico_una_estabilizacion", alto=350)

    # Los mismos inicios y las mismas innovaciones en las dos comparaciones.
    ruido_multi = np.random.default_rng(318).normal(size=(4, 1200))
    inicios = np.array([-3.0, -1.0, 1.0, 3.0])
    grupos = {nombre: ar1(ruido_multi, rho, inicios)[:, 201:]
              for nombre, rho in (("compatibles", 0.6), ("lentas", 0.9995))}
    rejilla = np.linspace(-5, 5, 501)
    for nombre, cadenas in grupos.items():
        fig, axes = plt.subplots(1, 2, gridspec_kw={"width_ratios": [1, 1.6]})
        for i, (fila, color) in enumerate(zip(cadenas, COLORES), 1):
            axes[0].plot(rejilla, gaussian_kde(fila)(rejilla), color=color, linewidth=1.5)
            axes[1].plot(np.arange(1, 1001), fila, color=color, linewidth=0.75, alpha=0.85)
        axes[0].plot(rejilla, norm.pdf(rejilla), color="0.5", linestyle="--", linewidth=1)
        axes[0].set(xlabel=r"$\theta$", ylabel="Densidad", xlim=(-5, 5), xticks=[-4, 0, 4],
                    title="Por cadena")
        axes[1].set(xlabel="Iteración", ylabel=r"$\theta$", xlim=(1, 1000), ylim=(-5, 5),
                    xticks=[1, 500, 1000], yticks=[-4, 0, 4], title="Trazas")
        guardar(fig, f"diagnostico_trazas_{nombre}", ancho=756, alto=350)

    # Una figura por caso: distribuciones arriba y comparación W frente a V abajo.
    for nombre, archivo in (("compatibles", "superpuestas"), ("lentas", "separadas")):
        cadenas = grupos[nombre]
        w, b, v, rhat = varianzas_clasicas(cadenas)
        media = cadenas.mean()
        fig, axes = plt.subplots(2, 1, sharex=True)
        for fila, color in zip(cadenas, COLORES):
            axes[0].plot(rejilla, gaussian_kde(fila)(rejilla), color=color, linewidth=1.5)
        axes[0].set(ylabel="Por cadena", ylim=(0, None))
        axes[0].text(0.98, 0.92, rf"$\widehat R={rhat:.2f}$",
                     ha="right", va="top", transform=axes[0].transAxes, fontsize=14)
        axes[1].plot(rejilla, norm.pdf(rejilla, media, np.sqrt(w)), color="black", linewidth=1.8)
        axes[1].plot(rejilla, norm.pdf(rejilla, media, np.sqrt(v)), color="0.5", linestyle="--", linewidth=1.8)
        axes[1].set(xlabel=r"$\theta$", ylabel="Comparación", xlim=(-5, 5),
                    xticks=[-4, 0, 4], ylim=(0, None))
        axes[1].legend([r"Varianza $W$", r"Varianza $\widehat V$"], fontsize=14,
                       loc="upper right", framealpha=0.95)
        guardar(fig, f"diagnostico_rhat_{archivo}", ancho=480, alto=350)

    # Precisión con varias cadenas en equilibrio, con igual número de muestras.
    rng_precision = np.random.default_rng(663)
    ruido_precision = rng_precision.normal(size=(4, 2500))
    inicios_precision = rng_precision.normal(size=4)
    resumen_precision = []
    for nombre, rho in (("Independientes", 0.0), ("Autocorrelacionadas", 0.9)):
        valores = ar1(ruido_precision, rho, inicios_precision)[:, 1:]
        resumen_precision.append({"nombre": nombre, "n": int(valores.size),
                                 "ess": int(round(float(az.ess(valores, method="mean")))),
                                 "mcse": f"{float(az.mcse(valores, method='mean')):.3f}",
                                 "rhat": f"{float(az.rhat(valores)):.3f}"})
    resumen = {"precision": resumen_precision}
    for nombre, valores in grupos.items():
        w, b, v, rhat = varianzas_clasicas(valores)
        resumen[nombre] = {"rhat": f"{float(az.rhat(valores)):.3f}",
                           "rhat_clasico": f"{rhat:.3f}", "w": f"{w:.3f}",
                           "b": f"{b:.3f}", "v": f"{v:.3f}"}
    assert float(resumen['compatibles']['rhat']) < 1.01
    assert float(resumen['lentas']['rhat']) > 1.1
    assert resumen_precision[1]['ess'] < resumen_precision[0]['ess'] / 5
    assert float(resumen_precision[1]['mcse']) > float(resumen_precision[0]['mcse']) * 3
    (OUTPUT / "diagnosticos_resumen.json").write_text(json.dumps(resumen, ensure_ascii=False, indent=2) + "\n")
    print(json.dumps(resumen, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    generar_diagnosticos()
