"""RWMH en cuatro transiciones: propuesta, cociente de densidades y decisión."""
from pathlib import Path

import matplotlib.pyplot as plt
from matplotlib.animation import FFMpegWriter
from matplotlib.patches import FancyArrowPatch
import numpy as np
from scipy.stats import norm

from animacion_utils import texto_vector_theta

OUTPUT = Path(__file__).resolve().parent
AZUL = "#0072B2"


def generar_rwmh():
    plt.style.use(OUTPUT.parent / "curso.mplstyle")
    plt.rcParams.update({
        "figure.constrained_layout.use": False, "font.size": 18,
        "axes.labelsize": 18, "axes.titlesize": 18,
        "xtick.labelsize": 18, "ytick.labelsize": 18,
    })

    def objetivo(x):
        return 4 * (0.65 * norm.pdf(x, -1.6, 0.55) + 0.35 * norm.pdf(x, 1.35, 0.9))

    rng = np.random.default_rng(36)
    actual, transiciones = -1.0, []
    for _ in range(4):
        candidato = actual + rng.normal(scale=0.9)
        u = rng.uniform()
        alpha = min(1.0, objetivo(candidato) / objetivo(actual))
        aceptado = u < alpha
        transiciones.append((actual, candidato, alpha, u, aceptado))
        actual = candidato if aceptado else actual
    estados_registrados = [transiciones[0][0]] + [
        candidato if aceptado else origen
        for origen, candidato, alpha, u, aceptado in transiciones]
    assert estados_registrados[-1] == estados_registrados[-2]
    assert [t[-1] for t in transiciones] == [True, True, True, False]
    assert any(t[2] < 1 and t[-1] for t in transiciones)
    assert np.isclose(transiciones[-1][0], transiciones[-2][1])

    fig, ax = plt.subplots(figsize=(480 / 72, 350 / 72), layout="none")
    fig.subplots_adjust(left=0.10, right=0.92, bottom=0.08, top=0.98)
    x = np.linspace(-4, 4, 1001)
    ax.fill_between(x, objetivo(x), color="0.9", zorder=0)
    ax.plot(x, objetivo(x), color="0.5", linewidth=1.8)
    ax.text(0.98, 0.65, r"$p^*(\theta)$", transform=ax.transAxes, ha="right", va="top", color="0.4", zorder=21, fontsize=14)
    propuesta, = ax.plot([], [], color=AZUL, linewidth=1.7)
    relleno = None
    salto = FancyArrowPatch((0, 0), (1, 0), connectionstyle="arc3,rad=0",
                            arrowstyle="->", mutation_scale=11, color="black", linewidth=2,
                            shrinkA=0, shrinkB=0,
                            zorder=20, clip_on=False)
    ax.add_patch(salto)
    guias, = ax.plot([], [], color="black", linestyle=":", linewidth=1)
    alturas, = ax.plot([], [], "o", color="black", markersize=4)
    punto, = ax.plot([], [], "o", color="black", markersize=5, clip_on=False, zorder=8)
    candidato_marca, = ax.plot([], [], marker="|", color="black", markersize=8,
                              linestyle="none", markeredgewidth=1.5, clip_on=False)
    etiqueta_actual = ax.annotate(r"$\theta_t$", (0, -0.08), xytext=(12, -12),
                                  textcoords="offset points", ha="center", va="top", color="black")
    etiqueta_candidato = ax.annotate(r"$\theta'$", (1, -0.08), xytext=(-12, -12),
                                     textcoords="offset points", ha="center", va="top", color="black")
    ax.text(0.98, 0.54, r"$q(\theta\mid\theta_t)$", transform=ax.transAxes,
            color=AZUL, ha="right", va="top", zorder=21, fontsize=14)
    titulo = ax.text(0.02, 0.87, "", transform=ax.transAxes, ha="left", va="top", color="black", fontsize=14, linespacing=1.15)
    ax.text(0.02, 0.72, r"$\theta'\sim N(\theta_t,\ 0.9^2)$", transform=ax.transAxes,
            ha="left", va="top", color="black", fontsize=14)
    vector = ax.text(0.98, 0.98, "", transform=ax.transAxes, ha="right", va="top", color="black", fontsize=12)
    estado = ax.text(0.5, 0.02, "", transform=ax.transAxes, ha="center", va="bottom", color="black", fontsize=14)
    ax.set(xlabel=r"$\theta$", xlim=(-4, 4), ylim=(-1.05, 3.8),
           xticks=[-4, 0, 4], yticks=[0, 1, 2])
    ax.spines["bottom"].set_position(("data", -0.08))
    ax.xaxis.set_label_coords(1.08, 0.19)

    def actualizar(k, fase):
        nonlocal relleno
        origen, candidato, alpha, u, aceptado = transiciones[k]
        q = norm.pdf(x, origen, 0.9)
        propuesta.set_data(x, q)
        if relleno is not None:
            relleno.remove()
        relleno = ax.fill_between(x, q, color=AZUL, alpha=0.16, zorder=1)
        # Extremos sobre el eje y un arco pequeño hacia arriba: distinto de HMC.
        diferencia = candidato - origen
        curvatura = -np.sign(diferencia) * max(0.35, 0.25 / abs(diferencia))
        salto.set_connectionstyle(f"arc3,rad={curvatura}")
        salto.set_positions((origen, -0.08), (candidato, -0.08))
        salto.set_visible(fase == 1)
        cantidad = k + (fase == 3)
        vector.set_text(texto_vector_theta(estados_registrados[:cantidad + 1]))
        candidato_marca.set_data([candidato], [-0.08])
        candidato_marca.set_visible(fase >= 1)
        etiqueta_actual.xy = (origen, -0.08)
        etiqueta_actual.set_position((12 if candidato < origen else -12, -12))
        etiqueta_candidato.xy = (candidato, -0.08)
        etiqueta_candidato.set_position((-12 if candidato < origen else 12, -12))
        etiqueta_candidato.set_visible(fase >= 1)
        punto.set_data([candidato if fase == 3 and aceptado else origen], [-0.08])
        if fase >= 2:
            a, b = objetivo(origen), objetivo(candidato)
            guias.set_data([origen, origen, np.nan, candidato, candidato, np.nan,
                            -4, origen, np.nan, -4, candidato],
                           [0, a, np.nan, 0, b, np.nan, a, a, np.nan, b, b])
            alturas.set_data([origen, candidato], [a, b])
        else:
            guias.set_data([], [])
            alturas.set_data([], [])
        fases = ["Proponer", "Candidato", "Comparar densidades", "Aceptar" if aceptado else "Rechazar"]
        titulo.set_text(f"Iteración {k + 1}\n{fases[fase]}")
        if fase < 2:
            estado.set_text("" if fase == 0 else r"$\theta_t\longrightarrow\theta'$")
        elif fase == 2:
            estado.set_text(rf"$\alpha=\min(1,\ p^*(\theta')/p^*(\theta_t))={alpha:.2f}$")
        else:
            comparacion = "<" if aceptado else r"\geq"
            resultado = r"\theta_{t+1}=\theta'" if aceptado else r"\theta_{t+1}=\theta_t"
            estado.set_text(rf"$u={u:.2f} {comparacion} \alpha={alpha:.2f}$: ${resultado}$")

    actualizar(0, 0)
    fig.savefig(OUTPUT / "rwmh_ejemplo_inicio.pdf")
    actualizar(3, 3)
    fig.savefig(OUTPUT / "rwmh_ejemplo.pdf")
    frames = [(k, fase) for k in range(4)
              for fase, cantidad in enumerate((45, 45, 60, 60)) for _ in range(cantidad)]
    frames += [(3, 3)] * 60
    assert len(frames) == 900
    writer = FFMpegWriter(fps=30, codec="libx264", extra_args=[
        "-crf", "18", "-pix_fmt", "yuv420p", "-movflags", "+faststart"])
    with writer.saving(fig, str(OUTPUT / "rwmh_ejemplo.mp4"), dpi=216):
        for k, fase in frames:
            actualizar(k, fase)
            writer.grab_frame(facecolor="white")
    plt.close(fig)
    print("RWMH: 30 segundos; tres aceptaciones y un rechazo; semilla 36")
    for t in transiciones:
        print(t)


if __name__ == "__main__":
    generar_rwmh()
