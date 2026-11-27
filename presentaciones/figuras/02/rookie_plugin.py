"""Predicción plug-in y predictiva posterior para el ejemplo del rookie."""

from pathlib import Path

from estilo import guardar_pdf

import matplotlib.pyplot as plt
from matplotlib.ticker import MultipleLocator
import numpy as np
from scipy.stats import beta, betabinom, binom

OUTPUT = Path(__file__).resolve().parent
plt.style.use(OUTPUT.parent / "curso.mplstyle")
AZUL, VERDE = "#0072B2", "#009E73"
MEDIA = beta.mean(18, 7)


def bastones(ax, y, probabilidades, color, m, limite):
    ax.vlines(y, 0, probabilidades, color=color, linewidth=2.4)
    ax.scatter(y, probabilidades, color=color, s=45, zorder=3)
    ax.set(
        xlabel=r"$\tilde y$",
        xlim=(-0.5, m + 0.5),
        ylim=(0, limite),
        xticks=y if m == 2 else y[::5],
    )
    ax.yaxis.set_major_locator(MultipleLocator(0.2 if m == 2 else 0.05))


for m in (2, 20):
    y = np.arange(m + 1)
    plugin = binom.pmf(y, m, MEDIA)
    predictiva = betabinom.pmf(y, m, 18, 7)
    limite = np.ceil(max(plugin.max(), predictiva.max()) * 1.15 * 100) / 100

    if m == 2:
        fig, ax = plt.subplots(figsize=(4.6, 4))
        bastones(ax, y, plugin, AZUL, m, limite)
        ax.set_ylabel(r"$p(\tilde y\mid\theta=0.72)$")
        guardar_pdf(fig, OUTPUT / "rookie_plugin_2.pdf")
        plt.close(fig)

    fig, axes = plt.subplots(1, 2, figsize=(9, 4), sharex=True, sharey=True)
    for ax, probabilidades, color, titulo, etiqueta in zip(
        axes,
        (plugin, predictiva),
        (AZUL, VERDE),
        (f"Binomial({m}, 0.72)", f"BetaBinomial({m}, 18, 7)"),
        (r"$p(\tilde y\mid\theta=0.72)$", r"$p(\tilde y\mid y)$"),
    ):
        bastones(ax, y, probabilidades, color, m, limite)
        ax.set(title=titulo, ylabel=etiqueta)
        ax.tick_params(labelleft=True)
    guardar_pdf(fig, OUTPUT / f"rookie_comparacion_{m}.pdf")
    plt.close(fig)
