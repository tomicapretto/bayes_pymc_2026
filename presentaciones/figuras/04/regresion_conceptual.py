from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np

OUTPUT = Path(__file__).resolve().parent
AZUL = "#0072B2"
NARANJA = "#D55E00"
VERDE = "#009E73"


def datos_y_posterior():
    rng = np.random.default_rng(123)
    x_obs = np.linspace(0.25, 5.75, 65)
    sigma = 0.7
    y_obs = 1 + 0.65 * x_obs + rng.normal(0, sigma, len(x_obs))
    diseno = np.column_stack((np.ones_like(x_obs), x_obs))
    # Prior N(0, 10² I), independiente para ambos coeficientes.
    precision_prior = np.eye(2) / 100
    cov = np.linalg.inv(precision_prior + diseno.T @ diseno / sigma**2)
    media = cov @ (diseno.T @ y_obs / sigma**2)
    return x_obs, y_obs, sigma, media, cov


def preparar_ejes(ax, titulo):
    ax.set(title=titulo, xlabel="$X$", ylabel="$Y$", xlim=(-0.3, 6.7), ylim=(-0.8, 6.8))
    ax.set_xticks(np.arange(7))
    ax.set_yticks(np.arange(0, 7, 2))


def dibujar_media(ax, x, mu, ancho=None):
    if ancho is not None:
        ax.fill_between(x, mu - ancho, mu + ancho, color=AZUL, alpha=0.2, linewidth=0)
    ax.plot(x, mu, color=AZUL, linewidth=2.3)


def guardar(fig, nombre):
    fig.savefig(OUTPUT / f"{nombre}.png", dpi=180, facecolor="white")
    plt.close(fig)


def generar_figuras():
    plt.style.use(OUTPUT.parent / "curso.mplstyle")
    plt.rcParams.update({"font.size": 14, "axes.titlesize": 15})
    x_obs, y_obs, sigma, beta, cov = datos_y_posterior()
    x = np.linspace(0, 6, 401)
    diseno = np.column_stack((np.ones_like(x), x))
    mu = diseno @ beta
    # Cuantil 0.95 de chi² con 2 grados de libertad, sin depender de SciPy.
    radio2 = -2 * np.log(0.05)
    ancho = np.sqrt(radio2 * np.einsum("ij,jk,ik->i", diseno, cov, diseno))

    fig, ax = plt.subplots(figsize=(6, 4))
    preparar_ejes(ax, "Observaciones")
    ax.scatter(x_obs, y_obs, s=19, color="0.3", alpha=0.65)
    guardar(fig, "regresion_dispersion")

    fig, axes = plt.subplots(1, 2, figsize=(11, 4), sharex=True, sharey=True)
    titulos = ["Recta de regresión", "Intervalo de credibilidad para la recta de regresión"]
    for ax, titulo in zip(axes, titulos):
        preparar_ejes(ax, titulo)
    dibujar_media(axes[0], x, mu)
    dibujar_media(axes[1], x, mu, ancho)
    ax = axes[0]
    ax.scatter(0, beta[0], color=NARANJA, s=45, zorder=4)
    ticks_y = np.sort(np.append(ax.get_yticks(), beta[0]))
    etiquetas_y = [r"$\beta_0 = \mu(0)$" if valor == beta[0] else f"{valor:g}" for valor in ticks_y]
    ax.set_yticks(ticks_y, etiquetas_y)
    ax.plot([ax.get_xlim()[0], 0], [beta[0], beta[0]], color=NARANJA, ls=":", lw=1)
    x0, x1 = 2.6, 3.6
    y0, y1 = beta[0] + beta[1] * np.array([x0, x1])
    ax.plot([x0, x1, x1], [y0, y0, y1], color=NARANJA, linewidth=1.8)
    ax.text((x0 + x1) / 2, y0 - 0.2, r"$\Delta X = 1$", ha="center", va="top")
    ax.text(x1 + 0.13, (y0 + y1) / 2, r"$\Delta\mu = \beta_1$", va="center")
    ax.text(0.55, 4.5, r"$\mu(x) = \mathrm{E}[Y\mid X=x] = \beta_0 + \beta_1 x$", fontsize=18)
    guardar(fig, "regresion_media_incertidumbre")

    fig, axes = plt.subplots(1, 2, figsize=(11, 4), sharex=True, sharey=True)
    titulos = ["Observaciones alrededor de la media", "Distribución de Y para valores fijos de X"]
    for ax, titulo in zip(axes, titulos):
        preparar_ejes(ax, titulo)
        dibujar_media(ax, x, mu, ancho)
        ax.scatter(x_obs, y_obs, s=19, color="0.3", alpha=0.65, zorder=3)
    ax = axes[1]
    for x_fijo in (0.8, 2.8, 4.8):
        centro = beta[0] + beta[1] * x_fijo
        ys = np.linspace(centro - 2.8 * sigma, centro + 2.8 * sigma, 201)
        densidad = np.exp(-0.5 * ((ys - centro) / sigma) ** 2) / (sigma * np.sqrt(2 * np.pi))
        # La densidad se despliega horizontalmente para conservar la escala de Y.
        perfil = x_fijo + 1.05 * densidad
        ax.plot([x_fijo, x_fijo], [ys[0], ys[-1]], color=VERDE, ls=":", lw=1)
        ax.fill_betweenx(ys, x_fijo, perfil, color=VERDE, alpha=0.16, zorder=4)
        ax.plot(perfil, ys, color=VERDE, lw=1.8, zorder=5)
        ax.scatter(x_fijo, centro, color=VERDE, s=28, zorder=6)
        if x_fijo == 4.8:
            x_flecha = x_fijo + 0.9
            ax.annotate(
                "",
                xy=(x_flecha, centro),
                xytext=(x_flecha, ys[0]),
                arrowprops={"arrowstyle": "<->", "color": VERDE, "lw": 2},
                zorder=7,
            )
            ax.text(
                x_flecha + 0.12,
                (centro + ys[0]) / 2,
                r"$\propto\sigma$",
                color=VERDE,
                fontsize=18,
                va="center",
                zorder=7,
                bbox={"facecolor": "white", "edgecolor": "none", "alpha": 0.85, "pad": 2},
            )
    ax.text(
        0.35,
        6.05,
        r"$Y\mid X=x,\beta_0,\beta_1,\sigma\sim\mathrm{Normal}(\mu(x),\sigma^2)$",
        fontsize=18,
    )
    guardar(fig, "regresion_observaciones_sigma")


if __name__ == "__main__":
    generar_figuras()
