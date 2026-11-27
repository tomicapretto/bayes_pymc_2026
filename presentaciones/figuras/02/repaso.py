"""Figuras del repaso de la clase 2. Ejecutar desde cualquier directorio."""

from pathlib import Path

from estilo import guardar_pdf

import matplotlib.pyplot as plt
import numpy as np
from matplotlib.ticker import MultipleLocator
from scipy.stats import beta, binom

OUTPUT = Path(__file__).resolve().parent
plt.style.use(OUTPUT.parent / "curso.mplstyle")
AZUL, NARANJA, VERDE = "#0072B2", "#D55E00", "#009E73"
theta = np.linspace(0, 1, 1201)


def guardar(fig, nombre):
    guardar_pdf(fig, OUTPUT / f"repaso_{nombre}.pdf")
    plt.close(fig)


# Dos ejemplos del modelo observacional, con n y theta fijados.
for n, prob_agua in ((3, 2 / 3), (9, 0.4)):
    y = np.arange(n + 1)
    fig, ax = plt.subplots(figsize=(6.4, 4))
    probabilidades = binom.pmf(y, n, prob_agua)
    ax.vlines(y, 0, probabilidades, color=AZUL, linewidth=2.4)
    ax.scatter(y, probabilidades, color=AZUL, s=45, zorder=3)
    theta_label = "0.4" if n == 9 else "2/3"
    ax.set(
        xlabel=r"$y$",
        ylabel=rf"$p(y\mid\theta={theta_label})$",
        xticks=y if n < 10 else y[::2],
        xlim=(-0.7, n + 0.7),
        ylim=(0, np.ceil(probabilidades.max() * 1.2 * 100) / 100),
    )
    ax.yaxis.set_major_locator(MultipleLocator(0.1))
    guardar(fig, f"modelo_{n}")


fig, ax = plt.subplots(figsize=(6.4, 4))
ax.plot(theta, binom.pmf(3, 9, theta), color=AZUL, linewidth=2.5)
ax.set(
    xlabel=r"$\theta$",
    ylabel=r"$p(y=3\mid\theta)$",
    xlim=(0, 1),
    ylim=(0, np.ceil(binom.pmf(3, 9, theta).max() * 1.2 * 100) / 100),
)
ax.yaxis.set_major_locator(MultipleLocator(0.1))
guardar(fig, "verosimilitud")


posterior = beta(7, 4)
lo, hi = posterior.ppf([0.025, 0.975])
fig, ax = plt.subplots(figsize=(6.4, 4))
ax.plot(theta, posterior.pdf(theta), color=AZUL, linewidth=2.5)
ax.plot([lo, hi], [0, 0], color=AZUL, linewidth=4, clip_on=False, zorder=4)
ax.plot(
    posterior.mean(),
    0,
    "o",
    color="0.2",
    markersize=8,
    markeredgecolor="white",
    markeredgewidth=1,
    clip_on=False,
    zorder=5,
)
ax.set(xlabel=r"$\theta$", ylabel=r"$p(\theta\mid y)$", xlim=(0, 1), ylim=(0, None))
guardar(fig, "posterior")


# Paneles con escalas verticales independientes: la verosimilitud no es
# una densidad sobre theta. Conservamos los valores de cada escala.
for nombre, a, b, y, n in (
    ("base", 1, 1, 6, 9),
    ("mas_datos", 1, 1, 20, 30),
    ("otro_prior", 10, 10, 6, 9),
    ("solo_agua", 2, 2, 1, 1),
    ("solo_tierra", 2, 2, 0, 3),
):
    fig, axes = plt.subplots(1, 3, figsize=(10.5, 3.4))
    for ax, valores, titulo, color in zip(
        axes,
        (
            beta.pdf(theta, a, b),
            binom.pmf(y, n, theta),
            beta.pdf(theta, a + y, b + n - y),
        ),
        (
            f"Prior\nBeta({a}, {b})",
            f"Verosimilitud\ny={y}, n={n}",
            f"Posterior\nBeta({a+y}, {b+n-y})",
        ),
        (AZUL, NARANJA, VERDE),
    ):
        ax.plot(theta, valores, color=color, linewidth=2.3)
        ax.axvline(y / n, color="0.6", ls=":", linewidth=1)
        ax.set(
            title=titulo,
            xlabel=r"$\theta$",
            xlim=(0, 1),
            ylim=(0, valores.max() * 1.12),
            xticks=[0, 0.5, 1],
            yticks=[],
        )
    guardar(fig, nombre)
