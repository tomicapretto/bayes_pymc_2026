from pathlib import Path

from estilo import guardar_pdf

import numpy as np
import matplotlib.pyplot as plt
from scipy.stats import beta, betabinom

OUTPUT = Path(__file__).resolve().parent
OUTPUT.mkdir(parents=True, exist_ok=True)
plt.style.use(OUTPUT.parent / "curso.mplstyle")


def save_figure(fig, name, **kwargs):
    guardar_pdf(fig, OUTPUT / f"{name}.pdf", **kwargs)
    plt.close(fig)


# Okabe–Ito, incluido el tono dorado.
azul = "#0072B2"
dorado = "#E69F00"
plt.rcParams.update(
    {"font.size": 14, "axes.labelsize": 15, "axes.titlesize": 16, "legend.fontsize": 12}
)
theta = np.linspace(0.0001, 0.9999, 1200)


def marcar_intervalo(ax, posterior, color):
    lo, hi = posterior.ppf([0.025, 0.975])
    ax.plot([lo, hi], [0, 0], color=color, linewidth=4, clip_on=False, zorder=4)
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


# Resumen del posterior: 17 aciertos en 23 tiros, prior Beta(1, 1).
posterior = beta(18, 7)
fig, ax = plt.subplots(figsize=(6.8, 4))
ax.plot(theta, posterior.pdf(theta), color=azul, linewidth=2.5)
marcar_intervalo(ax, posterior, azul)
ax.set(xlabel=r"$\theta$", ylabel=r"$p(\theta\mid y)$", xlim=(0, 1), ylim=(0, None))
save_figure(fig, "rookie_intervalo")

# Distribución predictiva para veinte nuevos tiros.
y_new = np.arange(21)
probabilities = betabinom.pmf(y_new, 20, 18, 7)
fig, ax = plt.subplots(figsize=(5.4, 4))
ax.vlines(y_new, 0, probabilities, color=azul, linewidth=2.4)
ax.scatter(y_new, probabilities, color=azul, s=45, zorder=3)
ax.set(
    xlabel=r"$\tilde y$",
    ylabel=r"$p(\tilde y\mid y)$",
    xticks=y_new[::5],
    ylim=(0, max(probabilities) * 1.22),
)

fig_suma, ax_suma = plt.subplots(figsize=(5.4, 4))
colors = [dorado if k > 15 else azul for k in y_new]
ax_suma.vlines(y_new, 0, probabilities, color=colors, linewidth=2.4)
ax_suma.scatter(y_new, probabilities, color=colors, s=45, zorder=3)
ax_suma.set(
    xlabel=ax.get_xlabel(),
    ylabel=ax.get_ylabel(),
    xticks=ax.get_xticks(),
    ylim=ax.get_ylim(),
)
save_figure(fig_suma, "rookie_predictiva_20_suma")
save_figure(fig, "rookie_predictiva_20")
