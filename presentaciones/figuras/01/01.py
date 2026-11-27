from pathlib import Path

import numpy as np
import matplotlib.pyplot as plt

OUTPUT = Path(__file__).resolve().parent
OUTPUT.mkdir(parents=True, exist_ok=True)
plt.style.use(OUTPUT.parent / "curso.mplstyle")


def save_figure(fig, name, **kwargs):
    fig.savefig(OUTPUT / f"{name}.pdf", **kwargs)
    plt.close(fig)


# ------------------------------------------------------------------------- #
#                                  Figura 1                                 #
# ------------------------------------------------------------------------- #
fig, ax = plt.subplots(figsize=(6.4, 3.6))

n = np.arange(13)
# Cada punto corresponde a una cantidad entera de observaciones.
ax.plot(n, 1 / (1 + 2**n), marker="o", linestyle=":", linewidth=2, markersize=5)
ax.axhline(y=0, ls="--", color="0.5", linewidth=1)
ax.set(
    xlabel="$n$",
    ylabel=r"$P(U_1\mid D_n)$",
    xticks=n[::2],
    yticks=np.arange(0, 0.6, 0.1),
    xlim=(-0.3, 12.3),
    ylim=(-0.025, 0.55),
)
save_figure(fig, "plot_01")

# ------------------------------------------------------------------------- #
#                                  Figura 2                                 #
# ------------------------------------------------------------------------- #
fig, ax = plt.subplots(figsize=(6.4, 3.6))

# n = 0 muestra la predicción antes de realizar extracciones.
n = np.arange(13)
ax.axhline(y=2 / 3, ls="--", color="0.5", linewidth=1)

ax.plot(
    n,
    (1 + 2 ** (n + 1)) / (3 * (1 + 2**n)),
    marker="o",
    linestyle=":",
    linewidth=2,
    markersize=5,
)

ax.set(
    xlabel="$n$",
    ylabel=r"$P(A_{n+1}\mid D_n)$",
    xticks=n[::2],
    yticks=[0.5, 0.55, 0.6, 2 / 3],
    yticklabels=["0.50", "0.55", "0.60", "$2/3$"],
    xlim=(-0.3, 12.3),
    ylim=(0.48, 0.69),
)
save_figure(fig, "plot_02")

# ------------------------------------------------------------------------- #
#               Modelo del globo y actualización beta-binomial         #
# ------------------------------------------------------------------------- #
from scipy.stats import beta, binom

# Okabe–Ito, incluido el tono dorado.
azul = "#0072B2"
naranja = "#D55E00"
verde = "#009E73"
violeta = "#CC79A7"
dorado = "#E69F00"
plt.rcParams.update(
    {"font.size": 14, "axes.labelsize": 15, "axes.titlesize": 16, "legend.fontsize": 12}
)
theta = np.linspace(0.0001, 0.9999, 1200)

# Distribución de observaciones, con theta fijo.
fig, axes = plt.subplots(1, 3, figsize=(9.6, 4), sharey=True)
for ax, p in zip(axes, [0.25, 0.5, 0.75]):
    ax.bar(
        np.arange(10),
        binom.pmf(np.arange(10), 9, p),
        color=azul,
        edgecolor=azul,
        width=0.75,
    )
    ax.set(
        title=rf"$\theta={p}$",
        xlabel="$y$",
        xticks=[0, 3, 6, 9],
        yticks=[0, 0.1, 0.2, 0.3],
        ylim=(0, 0.34),
    )
axes[0].set_ylabel(r"$p(y\mid\theta)$")
save_figure(fig, "globo_modelo")

fig, ax = plt.subplots(figsize=(6.8, 4))
ax.plot(theta, binom.pmf(6, 9, theta), color=azul, linewidth=2.5)
ax.axvline(6 / 9, color="0.5", ls=":", linewidth=1.5)
ax.set(
    xlabel=r"$\theta$",
    ylabel=r"$p(y\mid\theta)$",
    yticks=[0, 0.1, 0.2, 0.3],
    xlim=(0, 1),
    ylim=(0, 0.31),
)
ax.text(6 / 9 + 0.02, 0.035, "$6/9$", color="0.35")
save_figure(fig, "globo_verosimilitud")

fig, ax = plt.subplots(figsize=(6.8, 4))
ax.plot([0, 1], [1, 1], color=azul, linewidth=2.5)
ax.set(
    xlabel=r"$\theta$",
    ylabel=r"$p(\theta)$",
    xlim=(0, 1),
    ylim=(0, 1.4),
    yticks=[0, 0.5, 1],
)
save_figure(fig, "globo_prior")

# Pocas curvas por panel para separar localización y concentración.
fig, axes = plt.subplots(1, 3, figsize=(9.6, 4))
for ax, params, title in zip(
    axes,
    [[(1, 1)], [(2, 5), (5, 2)], [(2, 2), (10, 10)]],
    ["Uniforme", "Distintas medias", "Misma media"],
):
    for (a, b), color in zip(params, [azul, dorado]):
        ax.plot(
            theta,
            beta.pdf(theta, a, b),
            color=color,
            linewidth=2.2,
            label=f"Beta({a}, {b})",
        )
    ax.set(
        title=title,
        xlabel=r"$\theta$",
        xlim=(0, 1),
        ylim=(0, 4.8),
        xticks=[0, 0.5, 1],
        yticks=[0, 2, 4],
        ylabel="Densidad",
    )
    ax.legend(loc="upper center", frameon=False, fontsize=11)
save_figure(fig, "beta_formas")


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


for name, a, b in (("globo", 7, 4),):
    posterior = beta(a, b)
    fig, ax = plt.subplots(figsize=(6.8, 4))
    ax.plot(theta, beta.pdf(theta, 1, 1), color=azul, linewidth=2, label=r"$p(\theta)$")
    ax.plot(
        theta,
        posterior.pdf(theta),
        color=dorado,
        linewidth=2.5,
        label=r"$p(\theta\mid y)$",
    )
    ax.set(xlabel=r"$\theta$", ylabel="Densidad", xlim=(0, 1), ylim=(0, None))
    ax.legend(frameon=False, loc="upper left")
    save_figure(fig, f"{name}_posterior")

    fig, ax = plt.subplots(figsize=(6.8, 4))
    ax.plot(theta, posterior.pdf(theta), color=azul, linewidth=2.5)
    marcar_intervalo(ax, posterior, azul)
    ax.set(xlabel=r"$\theta$", ylabel=r"$p(\theta\mid y)$", xlim=(0, 1), ylim=(0, None))
    save_figure(fig, f"{name}_intervalo")

# Mismos datos originales con un prior más informativo.
for name, a, b, y, n in (("globo_prior_informativo", 10, 10, 6, 9),):
    posterior = beta(a + y, b + n - y)
    fig, ax = plt.subplots(figsize=(6.8, 4))
    if (a, b) != (1, 1):
        ax.plot(
            theta,
            beta.pdf(theta, a, b),
            color=azul,
            linewidth=2,
            ls=":",
            label=f"Prior: Beta({a}, {b})",
        )
    ax.plot(
        theta,
        posterior.pdf(theta),
        color=verde,
        linewidth=2.5,
        label=f"Posterior: Beta({a+y}, {b+n-y})",
    )
    marcar_intervalo(ax, posterior, verde)
    ax.set(xlabel=r"$\theta$", ylabel="Densidad", xlim=(0, 1), ylim=(0, None))
    ax.legend(frameon=False, loc="upper left", fontsize=11)
    save_figure(fig, name)

# Prior, verosimilitud y posterior juntos: cada panel tiene su propia escala.
# Omitimos rótulos y valores verticales solo en esta comparación de formas.
compromiso_casos = [
    (1, 1, 6, 9),
    (2, 2, 3, 7),
    (2, 2, 40, 55),
    (10, 3, 3, 5),
    (10, 3, 30, 50),
    (2, 2, 1, 1),
    (2, 2, 0, 3),
]


def plot_compromiso(a, b, y, n, name, resumen=False):
    fig, axes = plt.subplots(1, 3, figsize=(9.6, 4))
    prior_pdf = beta.pdf(theta, a, b)
    likelihood = binom.pmf(y, n, theta)
    post_pdf = beta.pdf(theta, a + y, b + n - y)
    axes[0].plot(theta, prior_pdf, color=azul, linewidth=2.3)
    axes[1].plot(theta, likelihood, color=dorado, linewidth=2.3)
    axes[2].plot(theta, post_pdf, color=verde, linewidth=2.3)
    axes[0].set(
        title=rf"$\mathit{{Prior}}$" + f"\nBeta({a}, {b})",
        ylim=(0, prior_pdf.max() * 1.12),
    )
    axes[1].set_ylim(0, likelihood.max() * 1.12)
    axes[1].set_title("Verosimilitud\n" + rf"$\mathrm{{Binomial}}({y}\mid {n},\theta)$")
    axes[2].set(
        title=rf"$\mathit{{A\ posteriori}}$" + f"\nBeta({a+y}, {b+n-y})",
        ylim=(0, post_pdf.max() * 1.12),
    )
    for ax in axes:
        ax.set(xlabel=r"$\theta$", xlim=(0, 1), xticks=[0, 0.5, 1], yticks=[])
        if not resumen:
            ax.axvline(y / n, color="0.55", ls=":", linewidth=1)
    if resumen:
        posterior = beta(a + y, b + n - y)
        marcar_intervalo(axes[2], posterior, verde)
    fig.suptitle(rf"$y={y},\ n={n}$", fontsize=16)
    save_figure(fig, name)


for number, (a, b, y, n) in enumerate(compromiso_casos, 1):
    plot_compromiso(a, b, y, n, f"globo_compromiso_{number}")

# Realizaciones hipotéticas con la misma proporción observada, compatibles
# con theta=2/3. El valor generador no se usa para calcular el posterior.
for y, n in ((12, 18), (20, 30)):
    plot_compromiso(1, 1, y, n, f"globo_mas_datos_{n}", resumen=True)
