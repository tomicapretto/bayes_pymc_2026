"""Internet: normal–normal y normal–gamma inversa. Normal(media, varianza).

Datos docentes de Villani, conservados del encargo. sigma=5 es un supuesto.
El segundo prior es una elección propia: v ~ IG(2.5,73.5), mu|v ~ N(20,v).
IG(a,b) tiene densidad b**a/Gamma(a) * v**(-a-1) * exp(-b/v).
Las marginales y predictiva se evalúan con scipy.stats.t, sin desarrollar esa
familia en clase. No se normalizan densidades sobre las ventanas de dibujo.
"""

from pathlib import Path

import matplotlib.pyplot as plt
from matplotlib.colors import PowerNorm
import numpy as np
from scipy.integrate import quad
from scipy.stats import invgamma, norm, t

from estilo import guardar_pdf

OUTPUT = Path(__file__).resolve().parent
plt.style.use(OUTPUT.parent / "curso.mplstyle")
AZUL, NARANJA, VERDE = "#0072B2", "#D55E00", "#009E73"
Y = np.array([15.77, 20.50, 8.26, 14.37, 21.09])
N, YBAR = Y.size, Y.mean()
S = np.sum((Y - YBAR) ** 2)
MU0, TAU02, SIGMA2 = 20.0, 49.0, 25.0
TAUN2 = 1 / (1 / TAU02 + N / SIGMA2)
MUN = TAUN2 * (MU0 / TAU02 + N * YBAR / SIGMA2)
POST = norm(MUN, np.sqrt(TAUN2))
PRED = norm(MUN, np.sqrt(SIGMA2 + TAUN2))
K0, A0, B0 = 1.0, 2.5, 73.5
KN, AN = K0 + N, A0 + N / 2
BN = B0 + S / 2 + K0 * N / (2 * KN) * (YBAR - MU0) ** 2
MN = (K0 * MU0 + N * YBAR) / KN
VPOST = invgamma(AN, scale=BN)
MPOST = t(2 * AN, loc=MN, scale=np.sqrt(BN / (AN * KN)))
PRED2 = t(2 * AN, loc=MN, scale=np.sqrt(BN * (KN + 1) / (AN * KN)))


def conjunta(mu, v):
    return VPOST.pdf(v) * norm.pdf(mu, MN, np.sqrt(v / KN))


def cond_v(mu):
    return invgamma(AN + 0.5, scale=BN + KN * (mu - MN) ** 2 / 2)


def verificar():
    assert np.isclose(Y.sum(), 79.99) and np.isclose(YBAR, 15.998)
    assert np.isclose(S, 108.77548) and np.isclose(Y.var(ddof=1), 27.19387)
    assert np.isclose(MUN, 883.902 / 54) and np.isclose(TAUN2, 245 / 54)
    assert np.allclose([TAUN2 / TAU02, TAUN2 * N / SIGMA2], [5 / 54, 49 / 54])
    assert np.isclose(PRED.var(), 1595 / 54)
    assert np.isclose(BN, 134.561075)
    assert np.isclose(B0 / (K0 * (A0 - 1)), TAU02)
    assert np.isclose(np.sqrt(TAU02), 7)
    for dist in (POST, MPOST, VPOST):
        assert np.isclose(np.diff(dist.cdf(dist.ppf([0.025, 0.975])))[0], 0.95)
    # Verificación independiente de marginales y condicionales integrando
    # la conjunta completa; la ventana gráfica no interviene en estos cálculos.
    for m in (15.0, 20.0):
        marginal = quad(lambda v: conjunta(m, v), 0, np.inf, epsabs=1e-11)[0]
        assert np.isclose(marginal, MPOST.pdf(m), rtol=1e-9)
        for v in (15.0, 25.0, 40.0):
            assert np.isclose(conjunta(m, v) / MPOST.pdf(m), cond_v(m).pdf(v))
    assert np.isclose(quad(VPOST.pdf, 0, np.inf)[0], 1)
    assert np.isclose(
        quad(lambda m: conjunta(m, 25), -np.inf, np.inf)[0], VPOST.pdf(25)
    )
    # Integrar primero mu da una normal con varianza v*(1+1/KN).
    for z in (12.0, 20.0, 28.0):
        integrado = quad(
            lambda v: norm.pdf(z, MN, np.sqrt(v * (1 + 1 / KN))) * VPOST.pdf(v),
            0,
            np.inf,
            epsabs=1e-11,
        )[0]
        assert np.isclose(integrado, PRED2.pdf(z), rtol=1e-9)
    p_media = quad(
        lambda v: norm.cdf(20, MN, np.sqrt(v / KN)) * VPOST.pdf(v), 0, np.inf
    )[0]
    p_nueva = quad(
        lambda v: norm.cdf(20, MN, np.sqrt(v * (1 + 1 / KN))) * VPOST.pdf(v), 0, np.inf
    )[0]
    assert np.isclose(p_media, MPOST.cdf(20)) and np.isclose(p_nueva, PRED2.cdf(20))
    assert np.isclose(PRED2.var(), VPOST.mean() + MPOST.var())
    for nombre, dist in [
        ("Media, sigma conocido", POST),
        ("Predictiva, sigma conocido", PRED),
        ("Media, ambos desconocidos", MPOST),
        ("Varianza", VPOST),
        ("Predictiva, ambos desconocidos", PRED2),
    ]:
        print(
            f"{nombre}: media={dist.mean():.9f}; var={dist.var():.9f}; "
            f"IC95={dist.ppf([.025,.975])}; P(<20)={dist.cdf(20):.9f}"
        )
    print(f"Posterior NIG: m={MN}, k={KN}, a={AN}, b={BN}")
    print("Prior v: IC95=", invgamma(A0, scale=B0).ppf([0.025, 0.975]))


def guardar(fig, nombre):
    guardar_pdf(fig, OUTPUT / f"normal_{nombre}.pdf")
    plt.close(fig)


def base(altura=270, ancho=480):
    return plt.subplots(figsize=(ancho / 72, altura / 72))


def curva(dist, nombre, variable, etiqueta, intervalo=False):
    x = np.linspace(
        0 if variable != r"$\mu$" else 5, 35 if variable != r"$\mu$" else 28, 1601
    )
    fig, ax = base()
    ax.plot(x, dist.pdf(x), color=AZUL, lw=2.5)
    ax.fill_between(x, 0, dist.pdf(x), where=x <= 20, color=AZUL, alpha=0.18)
    ax.axvline(20, color=NARANJA, ls="--", lw=1.5)
    if intervalo:
        lo, hi = dist.ppf([0.025, 0.975])
        ax.plot([lo, hi], [0, 0], color=AZUL, lw=4, clip_on=False, zorder=4)
        ax.plot(dist.mean(), 0, "o", color="0.2", ms=8, clip_on=False, zorder=5)
    ax.set(
        xlabel=variable,
        ylabel=etiqueta,
        xlim=(x[0], x[-1]),
        ylim=(0, None),
        xticks=[10, 20, 30] if x[0] == 0 else [5, 10, 15, 20, 25],
    )
    guardar(fig, nombre)


def mapa_conjunto(m, v, z, nombre, etiqueta):
    fig, ax = plt.subplots(figsize=(420 / 72, 330 / 72), layout="none")
    fig.subplots_adjust(left=0.16, right=0.77, bottom=0.23, top=0.84)
    # Una escala de color no lineal hace visibles las densidades intermedias;
    # no modifica la distribución ni su variabilidad.
    im = ax.pcolormesh(
        m,
        v,
        z,
        cmap="viridis",
        norm=PowerNorm(gamma=0.45, vmin=0, vmax=z.max()),
        shading="auto",
        rasterized=True,
    )
    ax.set_box_aspect(1)
    ax.set(
        ylabel=r"$\sigma^2$", xlim=(m[0], m[-1]), ylim=(0, v[-1]), xticks=[], yticks=[]
    )
    ax.yaxis.labelpad = 28
    for spine in ax.spines.values():
        spine.set_visible(False)
    # Las flechas indican continuación del soporte, no valores infinitos
    # alcanzados en los bordes de la ventana numérica de cálculo.
    arrow = dict(color="#343a40", lw=1.2, mutation_scale=14)
    # Fuera del mapa, las flechas no quedan tapadas por su borde oscuro.
    for extremo, inicio in ((0.04, 0.17), (0.96, 0.83)):
        ax.annotate(
            "",
            xy=(extremo, -0.14),
            xytext=(inicio, -0.14),
            xycoords="axes fraction",
            arrowprops=dict(arrowstyle="->", **arrow),
            annotation_clip=False,
        )
    ax.annotate(
        "",
        xy=(0, 1.07),
        xytext=(0, 0),
        xycoords="axes fraction",
        arrowprops=dict(arrowstyle="->", **arrow),
        annotation_clip=False,
    )
    ax.text(-0.025, 0, "0", transform=ax.transAxes, ha="right", va="center")
    ax.text(0.015, -0.14, r"$-\infty$", transform=ax.transAxes, ha="right", va="center")
    ax.text(0.5, -0.14, r"$\mu$", transform=ax.transAxes, ha="center", va="center")
    ax.text(0.985, -0.14, r"$+\infty$", transform=ax.transAxes, ha="left", va="center")
    ax.text(0, 1.10, r"$+\infty$", transform=ax.transAxes, ha="center", va="bottom")
    cb = fig.colorbar(im, ax=ax, pad=0.035)
    cb.set_ticks([0, z.max()], labels=["Menor", "Mayor"])
    cb.set_label(etiqueta)
    guardar(fig, nombre)


def priors_bidimensionales():
    """Priors ilustrativos; no se usan los datos ni el posterior."""
    m = np.linspace(0, 40, 451)
    v = np.linspace(0.2, 85, 451)
    mm, vv = np.meshgrid(m, v)
    z = invgamma.pdf(vv, A0, scale=B0) * norm.pdf(mm, MU0, np.sqrt(vv / K0))
    mapa_conjunto(m, v, z, "prior_conjunto", r"$p(\mu,\sigma^2)$")

    parametros = ((10.0, 1.0, A0, B0), (20.0, 1.0, A0, B0), (30.0, 4.0, A0, B0))
    densidades = [
        invgamma.pdf(vv, a, scale=b) * norm.pdf(mm, media, np.sqrt(vv / k))
        for media, k, a, b in parametros
    ]
    # Misma ventana; cada panel tiene su propia escala de color.
    fig, axes = plt.subplots(
        1, 3, figsize=(750 / 72, 330 / 72), sharex=True, sharey=True
    )
    for ax, z, (media, k, a, b) in zip(axes, densidades, parametros):
        escala = PowerNorm(gamma=0.45, vmin=0, vmax=z.max())
        ax.pcolormesh(
            m, v, z, cmap="viridis", norm=escala, shading="auto", rasterized=True
        )
        ax.contour(
            m,
            v,
            z,
            levels=z.max() * np.array([0.05, 0.2, 0.5, 0.8]),
            colors="white",
            linewidths=1,
        )
        ax.set(
            xlim=(0, 40),
            ylim=(0, 85),
            xlabel=r"$\mu$",
            xticks=[0, 20, 40],
            yticks=[0, 40, 80],
            title=rf"$m_0={media:g},\ \kappa_0={k:g}$"
            + "\n"
            + rf"$a_0={a:g},\ b_0={b:g}$",
        )
    axes[0].set_ylabel(r"$\sigma^2$")
    guardar(fig, "priors_ejemplos")


def actualizacion_bidimensional():
    m = np.linspace(7, 27, 451)
    v = np.linspace(0.2, 85, 451)
    mm, vv = np.meshgrid(m, v)
    log_prior = invgamma.logpdf(vv, A0, scale=B0) + norm.logpdf(
        mm, MU0, np.sqrt(vv / K0)
    )
    log_like = sum(norm.logpdf(dato, mm, np.sqrt(vv)) for dato in Y)
    log_posterior = invgamma.logpdf(vv, AN, scale=BN) + norm.logpdf(
        mm, MN, np.sqrt(vv / KN)
    )
    # El producto del prior y la verosimilitud coincide con el posterior
    # salvo una constante que no depende de los parámetros.
    diferencia = log_posterior - log_prior - log_like
    assert np.allclose(diferencia, diferencia[0, 0], rtol=0, atol=1e-8)
    fig, axes = plt.subplots(
        1, 3, figsize=(750 / 72, 330 / 72), sharex=True, sharey=True
    )
    for ax, valores, titulo in zip(
        axes,
        (np.exp(log_prior), np.exp(log_like), np.exp(log_posterior)),
        (
            "Prior\n" + r"$p(\mu,\sigma^2)$",
            "Verosimilitud\n" + r"$p(\mathrm{𝐲}\mid\mu,\sigma^2)$",
            "Posterior\n" + r"$p(\mu,\sigma^2\mid\mathrm{𝐲})$",
        ),
    ):
        ax.pcolormesh(
            m,
            v,
            valores,
            cmap="viridis",
            norm=PowerNorm(gamma=0.45, vmin=0, vmax=valores.max()),
            shading="auto",
            rasterized=True,
        )
        ax.contour(
            m,
            v,
            valores,
            levels=valores.max() * np.array([0.03, 0.12, 0.3, 0.55, 0.8]),
            colors="white",
            linewidths=1,
        )
        ax.set_box_aspect(1)
        ax.set(
            title=titulo,
            xlabel=r"$\mu$",
            xlim=(7, 27),
            ylim=(0, 85),
            xticks=[10, 15, 20, 25],
            yticks=[0, 20, 40, 60, 80],
        )
    axes[0].set_ylabel(r"$\sigma^2$")
    guardar(fig, "actualizacion_conjunta")


def marginales_paneles():
    fig, axes = plt.subplots(1, 2, figsize=(750 / 72, 330 / 72))
    for ax, dist, x, titulo, variable in (
        (axes[0], MPOST, np.linspace(7, 27, 1201), r"$p(\mu\mid\mathrm{𝐲})$", r"$\mu$"),
        (
            axes[1],
            VPOST,
            np.linspace(0, 85, 1201),
            r"$p(\sigma^2\mid\mathrm{𝐲})$",
            r"$\sigma^2$",
        ),
    ):
        ax.plot(x, dist.pdf(x), color=AZUL, lw=2.5)
        ax.set(title=titulo, xlabel=variable, xlim=(x[0], x[-1]), ylim=(0, None))
    axes[0].set(xticks=[10, 15, 20, 25], yticks=[0, 0.05, 0.10, 0.15, 0.20])
    axes[1].set(xticks=[0, 20, 40, 60, 80], yticks=[0, 0.01, 0.02, 0.03, 0.04, 0.05])
    guardar(fig, "marginales_paneles")


def graficos():
    priors_bidimensionales()
    actualizacion_bidimensional()
    marginales_paneles()
    x = np.linspace(0, 40, 1601)
    fig, ax = base()
    ax.plot(x, norm.pdf(x, 20, 5), color=AZUL, lw=2.5)
    ax.set(
        xlabel=r"$y_i$",
        ylabel=r"$p(y_i\mid\mu=20)$",
        xlim=(0, 40),
        ylim=(0, 0.09),
        xticks=[0, 10, 20, 30, 40],
    )
    guardar(fig, "modelo")
    mu = np.linspace(0, 35, 1601)
    # Verosimilitud exacta: producto de las cinco densidades; sin escalar.
    like = np.exp(norm.logpdf(Y[:, None], mu, 5).sum(axis=0))
    fig, ax = base()
    ax.plot(mu, like, color=AZUL, lw=2.5)
    ax.set(
        xlabel=r"$\mu$",
        ylabel=r"$p(\mathrm{𝐲}\mid\mu)$",
        xlim=(0, 35),
        ylim=(0, None),
        xticks=[0, 10, 20, 30],
    )
    ax.ticklabel_format(axis="y", style="sci", scilimits=(0, 0))
    guardar(fig, "verosimilitud")
    fig, axes = plt.subplots(1, 3, figsize=(750 / 72, 300 / 72))
    for ax, vals, title, col in zip(
        axes,
        (norm.pdf(mu, MU0, np.sqrt(TAU02)), like, POST.pdf(mu)),
        (
            f"Prior\nNormal({MU0:g}, {TAU02:g})",
            "Verosimilitud\nn = 5",
            f"Posterior\nNormal({MUN:.2f}, {TAUN2:.2f})",
        ),
        (AZUL, NARANJA, VERDE),
    ):
        ax.plot(mu, vals, color=col, lw=2.5)
        ax.set(
            title=title,
            xlabel=r"$\mu$",
            xlim=(0, 35),
            ylim=(0, vals.max() * 1.12),
            xticks=[0, 15, 30],
            yticks=[],
        )
    guardar(fig, "actualizacion")
    curva(POST, "intervalo", r"$\mu$", r"$p(\mu\mid\mathrm{𝐲})$", True)
    curva(PRED, "predictiva", r"$\tilde y$", r"$p(\tilde y\mid\mathrm{𝐲})$")
    curva(PRED2, "predictiva_conjunta", r"$\tilde y$", r"$p(\tilde y\mid\mathrm{𝐲})$")
    # Misma parametrización, orientación y ventana en ambas conjuntas.
    m = np.linspace(7, 27, 451)
    v = np.linspace(0.2, 85, 451)
    mm, vv = np.meshgrid(m, v)
    z = conjunta(mm, vv)
    # Posterior conjunto en viridis y marginales en azul, en sus escalas reales.
    fig = plt.figure(figsize=(420 / 72, 350 / 72), layout="none")
    # Panel cuadrado, como la conjunta sola; marginales alineadas a sus bordes.
    ax = fig.add_axes([65 / 420, 60 / 350, 225 / 420, 225 / 350])
    ax.set_box_aspect(1)
    top = fig.add_axes([65 / 420, 291 / 350, 225 / 420, 45 / 350], sharex=ax)
    right = fig.add_axes([296 / 420, 60 / 350, 90 / 420, 225 / 350], sharey=ax)
    ax.pcolormesh(
        m,
        v,
        z,
        cmap="viridis",
        norm=PowerNorm(gamma=0.45, vmin=0, vmax=z.max()),
        shading="auto",
        rasterized=True,
    )
    ax.contour(
        m,
        v,
        z,
        levels=z.max() * np.array([0.03, 0.12, 0.3, 0.55, 0.8]),
        colors="white",
        linewidths=1,
    )
    ax.set(
        xlim=(7, 27),
        ylim=(0, 85),
        xlabel=r"$\mu$",
        ylabel=r"$\sigma^2$",
        xticks=[10, 15, 20, 25],
        yticks=[0, 20, 40, 60, 80],
    )
    top.plot(m, MPOST.pdf(m), color=AZUL, lw=2.2)
    top.set_ylim(0, MPOST.pdf(m).max() * 1.08)
    top.text(0.02, 0.8, r"$p(\mu\mid\mathrm{𝐲})$", transform=top.transAxes)
    right.plot(VPOST.pdf(v), v, color=AZUL, lw=2.2)
    right.set_xlim(0, VPOST.pdf(v).max() * 1.08)
    right.text(
        0.5,
        1.10,
        r"$p(\sigma^2\mid\mathrm{𝐲})$",
        transform=right.transAxes,
        ha="center",
        va="bottom",
    )
    for spine in ax.spines.values():
        spine.set_visible(True)
    for panel in (top, right):
        panel.set_axis_off()
    guardar(fig, "marginales")
    fig, axes = plt.subplots(1, 3, figsize=(750 / 72, 300 / 72))
    ax, am, av = axes
    ax.contour(
        m, v, z, levels=z.max() * np.array([0.03, 0.12, 0.3, 0.55, 0.8]), colors=AZUL
    )
    ax.axhline(25, color=NARANJA, ls="--")
    ax.axvline(20, color=VERDE, ls="--")
    ax.set(
        title=r"$p(\mu,\sigma^2)$",
        xlabel=r"$\mu$",
        ylabel=r"$\sigma^2$",
        xlim=(7, 27),
        ylim=(0, 85),
        xticks=[10, 20],
        yticks=[0, 25, 75],
    )
    am.plot(m, norm.pdf(m, MN, np.sqrt(25 / KN)), color=NARANJA, lw=2.5)
    am.set(
        title=r"$p(\mu\mid\sigma^2=25)$",
        xlabel=r"$\mu$",
        ylabel="",
        xlim=(7, 27),
        xticks=[10, 20],
        yticks=[],
    )
    av.plot(v, cond_v(20).pdf(v), color=VERDE, lw=2.5)
    av.set(
        title=r"$p(\sigma^2\mid\mu=20)$",
        xlabel=r"$\sigma^2$",
        xlim=(0, 85),
        xticks=[0, 40, 80],
        yticks=[],
    )
    guardar(fig, "condicionales")


if __name__ == "__main__":
    verificar()
    graficos()
