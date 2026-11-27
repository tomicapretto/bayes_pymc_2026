"""Animaciones de HMC; exportan MP4 y estados PDF reproducibles.

Ejecutar: MPLBACKEND=Agg python presentaciones/figuras/03/hmc_animacion.py
Requiere ffmpeg para codificar el video H.264.
"""
from pathlib import Path

import matplotlib.pyplot as plt
from matplotlib.animation import FFMpegWriter
import numpy as np

from animacion_utils import texto_vector_theta

OUTPUT = Path(__file__).resolve().parent


def generar_animacion():
    plt.style.use(OUTPUT.parent / "curso.mplstyle")
    plt.rcParams.update({
        "figure.constrained_layout.use": False,
        "font.size": 18, "axes.labelsize": 18, "axes.titlesize": 18,
        "xtick.labelsize": 18, "ytick.labelsize": 18,
    })
    # U(theta) = theta²/2, masa 1: solución exacta de Hamilton.
    inicio, phi_0, duracion = 0.7, -1.1, 2.0
    tiempos = np.linspace(0, duracion, 151)
    posiciones = inicio * np.cos(tiempos) + phi_0 * np.sin(tiempos)
    momentos = phi_0 * np.cos(tiempos) - inicio * np.sin(tiempos)
    assert np.all(np.diff(posiciones) < 0), "El ejemplo no debe pegar la vuelta"
    assert np.allclose((posiciones**2 + momentos**2) / 2, (inicio**2 + phi_0**2) / 2)

    fig, ax = plt.subplots(figsize=(480 / 72, 300 / 72), layout=None)
    # Márgenes fijos: el video y los estados PDF tienen exactamente la misma geometría.
    fig.set_layout_engine("none")
    fig.subplots_adjust(left=0.14, right=0.90, bottom=0.23, top=0.90)
    coordenadas = np.linspace(-2, 2, 601)
    ax.plot(coordenadas, coordenadas**2 / 2, color="0.65", linewidth=1.5)
    trayectoria, = ax.plot([], [], color="#0072B2", linewidth=3.5, zorder=3)
    ax.scatter([inicio], [inicio**2 / 2], color="black", s=35, zorder=5)
    particula, = ax.plot([], [], "o", color="black", markersize=6, zorder=6)
    eje_horizontal = -0.1
    ax.plot([inicio], [eje_horizontal], marker="|", color="black", markersize=9,
            markeredgewidth=1.5, clip_on=False, zorder=8)
    marca_final, = ax.plot([posiciones[-1]], [eje_horizontal], marker="|", color="black",
                          markersize=9, markeredgewidth=1.5, clip_on=False, zorder=8)
    ax.annotate(r"$\theta_t$", (inicio, eje_horizontal), xytext=(0, -12),
                textcoords="offset points", ha="center", va="top", color="black")
    final = ax.annotate(r"$\theta'$", (posiciones[-1], eje_horizontal),
                        xytext=(0, -12), textcoords="offset points", ha="center", va="top", color="black")
    ax.annotate("", xy=(inicio + phi_0, eje_horizontal), xytext=(inicio, eje_horizontal),
                arrowprops={"arrowstyle": "->", "color": "black", "lw": 2.2}, zorder=7)
    ax.set_title(r"$\phi_0=-1.1$", color="black", pad=10)
    reloj = ax.text(0.98, 0.96, "", transform=ax.transAxes, ha="right", va="top", color="black")
    ax.set(xlabel=r"$\theta$", ylabel=r"$U(\theta)$", xlim=(-2, 2), ylim=(eje_horizontal, 2.2),
           xticks=[-2, 0, 2], yticks=[0, 1, 2])
    ax.xaxis.set_label_coords(1.10, -0.02)

    def actualizar(i):
        trayectoria.set_data(posiciones[:i + 1], posiciones[:i + 1]**2 / 2)
        particula.set_data([posiciones[i]], [posiciones[i]**2 / 2])
        reloj.set_text(rf"$t={tiempos[i]:.2f}$")
        final.set_visible(i == len(tiempos) - 1)
        marca_final.set_visible(i == len(tiempos) - 1)

    actualizar(0)
    fig.savefig(OUTPUT / "hmc_impulso_1_inicio.pdf")
    actualizar(len(tiempos) - 1)
    fig.savefig(OUTPUT / "hmc_impulso_1.pdf")
    # Una pausa inicial, cinco segundos de movimiento y dos segundos al final.
    frames = [0] * 30 + list(range(1, len(tiempos))) + [len(tiempos) - 1] * 60
    writer = FFMpegWriter(fps=30, codec="libx264", extra_args=["-crf", "18", "-pix_fmt", "yuv420p", "-movflags", "+faststart"])
    with writer.saving(fig, str(OUTPUT / "hmc_impulso_1.mp4"), dpi=216):
        for i in frames:
            actualizar(i)
            writer.grab_frame(facecolor="white")
    plt.close(fig)
    print(f"HMC animado: t={duracion}, theta inicial={inicio}, theta final={posiciones[-1]:.6f}; sin retorno")


def generar_caidas():
    """Soltar desde reposo en el mismo potencial, con y sin disipación."""
    plt.style.use(OUTPUT.parent / "curso.mplstyle")
    plt.rcParams.update({
        "figure.constrained_layout.use": False,
        "font.size": 18, "axes.labelsize": 18, "axes.titlesize": 18,
        "xtick.labelsize": 18, "ytick.labelsize": 18,
    })
    inicio, gamma = 1.5, 0.5
    for con_friccion in (True, False):
        nombre = "hmc_con_friccion" if con_friccion else "hmc_sin_friccion"
        # 121 estados: cuatro segundos de movimiento a 30 fps.
        tiempos = np.linspace(0, 16 if con_friccion else 4 * np.pi, 121)
        if con_friccion:
            # theta'' + 2 gamma theta' + theta = 0, theta(0)=1.5, phi(0)=0.
            omega = np.sqrt(1 - gamma**2)
            posiciones = inicio * np.exp(-gamma * tiempos) * (
                np.cos(omega * tiempos) + gamma / omega * np.sin(omega * tiempos))
            momentos = -inicio / omega * np.exp(-gamma * tiempos) * np.sin(omega * tiempos)
            energia = (posiciones**2 + momentos**2) / 2
            assert np.all(np.diff(energia) <= 1e-12)
            assert abs(posiciones[-1]) < 0.001 and abs(momentos[-1]) < 0.001
            # El residuo final es menor que un píxel; mostrar reposo exacto en la moda.
            posiciones[-1] = 0
        else:
            posiciones = inicio * np.cos(tiempos)
            momentos = -inicio * np.sin(tiempos)
            assert np.allclose((posiciones**2 + momentos**2) / 2, inicio**2 / 2)
            assert np.allclose(posiciones[[0, 60, 120]], inicio)
            assert np.allclose(posiciones[[30, 90]], -inicio)

        fig, ax = plt.subplots(figsize=(480 / 72, 300 / 72), layout="none")
        fig.subplots_adjust(left=0.14, right=0.90, bottom=0.23, top=0.90)
        coordenadas = np.linspace(-2, 2, 601)
        ax.plot(coordenadas, coordenadas**2 / 2, color="0.65", linewidth=1.5)
        trayectoria, = ax.plot([], [], color="#0072B2", linewidth=3.5, zorder=3)
        particula, = ax.plot([], [], "o", color="black", markersize=7, zorder=6)
        ax.set(xlabel=r"$\theta$", ylabel=r"$U(\theta)$", xlim=(-2, 2),
               ylim=(-0.1, 2.2), xticks=[-2, 0, 2], yticks=[0, 1, 2])
        ax.xaxis.set_label_coords(1.10, -0.02)
        ax.set_title(r"$\phi_0=0$", color="black", pad=10)
        reloj = ax.text(0.98, 0.96, "", transform=ax.transAxes, ha="right", va="top", color="black")

        def actualizar(i):
            # Interpolar la curva entre estados para que el trazo siga siendo suave.
            recorrido = np.linspace(np.min(posiciones[:i + 1]), np.max(posiciones[:i + 1]), 401)
            trayectoria.set_data(recorrido, recorrido**2 / 2)
            particula.set_data([posiciones[i]], [posiciones[i]**2 / 2])
            reloj.set_text(rf"$t={tiempos[i]:.2f}$")

        actualizar(0)
        fig.savefig(OUTPUT / f"{nombre}_inicio.pdf")
        actualizar(120)
        fig.savefig(OUTPUT / f"{nombre}.pdf")
        # 0.4 segundos de inicio + 4 de movimiento + 0.6 al final = 5 segundos.
        frames = [0] * 12 + list(range(1, 121)) + [120] * 18
        writer = FFMpegWriter(fps=30, codec="libx264", extra_args=[
            "-crf", "18", "-pix_fmt", "yuv420p", "-movflags", "+faststart"])
        with writer.saving(fig, str(OUTPUT / f"{nombre}.mp4"), dpi=216):
            for i in frames:
                actualizar(i)
                writer.grab_frame(facecolor="white")
        plt.close(fig)
        print(f"{nombre}: 5 segundos de video; tiempo físico final={tiempos[-1]:.3f}")


def generar_cadena_hmc():
    """Cinco transiciones exactas con momentos N(0, 1) independientes."""
    from matplotlib.patches import FancyArrowPatch

    plt.style.use(OUTPUT.parent / "curso.mplstyle")
    plt.rcParams.update({
        "figure.constrained_layout.use": False,
        "font.size": 18, "axes.labelsize": 18, "axes.titlesize": 18,
        "xtick.labelsize": 18, "ytick.labelsize": 18,
    })
    impulsos = np.random.default_rng(2026).normal(size=5)
    tiempos = np.linspace(0, 2, 61)
    estados, caminos = [0.7], []
    for phi in impulsos:
        camino = estados[-1] * np.cos(tiempos) + phi * np.sin(tiempos)
        momento = phi * np.cos(tiempos) - estados[-1] * np.sin(tiempos)
        assert np.allclose((camino**2 + momento**2) / 2, (estados[-1]**2 + phi**2) / 2)
        caminos.append(camino)
        estados.append(camino[-1])
    estados = np.array(estados)
    nombre = "hmc_cinco_muestras"
    fig, ax = plt.subplots(figsize=(480 / 72, 300 / 72), layout="none")
    fig.subplots_adjust(left=0.14, right=0.90, bottom=0.14, top=0.98)
    eje_horizontal = -0.25
    coordenadas = np.linspace(-3.2, 3.2, 801)
    ax.plot(coordenadas, coordenadas**2 / 2, color="0.65", linewidth=1.5)
    trayectoria, = ax.plot([], [], color="#0072B2", linewidth=3.5, zorder=3)
    particula, = ax.plot([], [], "o", color="black", markersize=6, zorder=6)
    impulso = FancyArrowPatch((0, eje_horizontal), (1, eje_horizontal),
                              arrowstyle="->", mutation_scale=14, color="black",
                              linewidth=2.2, clip_on=False, zorder=7)
    ax.add_patch(impulso)
    reloj = ax.text(0.02, 0.67, "", transform=ax.transAxes, ha="left", va="top", color="black", fontsize=14)
    vector = ax.text(0.98, 0.98, "", transform=ax.transAxes, ha="right", va="top",
                     color="black", fontsize=12)
    titulo = ax.text(0.02, 0.87, "", transform=ax.transAxes, ha="left", va="top",
                     color="black", fontsize=14)
    contador = ax.text(0.02, 0.77, "", transform=ax.transAxes, ha="left", va="top", color="black", fontsize=14)
    ax.set(xlabel=r"$\theta$", ylabel=r"$U(\theta)$", xlim=(-3.2, 3.2),
           ylim=(eje_horizontal, 8.5), xticks=[-3, 0, 3], yticks=[0, 2, 4])
    ax.xaxis.set_label_coords(1.10, -0.02)

    def actualizar(iteracion, i):
        camino = caminos[iteracion]
        trayectoria.set_data(camino[:i + 1], camino[:i + 1]**2 / 2)
        particula.set_data([camino[i]], [camino[i]**2 / 2])
        cantidad = iteracion + (i == 60)
        impulso.set_positions((estados[iteracion], eje_horizontal),
                              (estados[iteracion] + 0.55 * impulsos[iteracion], eje_horizontal))
        titulo.set_text(f"Iteración {iteracion + 1}: " + rf"$\phi_0={impulsos[iteracion]:.2f}$")
        reloj.set_text(rf"$t={tiempos[i]:.2f}$")
        contador.set_text(f"Muestras: {cantidad}/5")
        vector.set_text(texto_vector_theta(estados[:cantidad + 1]))

    actualizar(0, 0)
    fig.savefig(OUTPUT / f"{nombre}_inicio.pdf")
    actualizar(4, 60)
    # El handout conserva las cinco muestras y todos los recorridos.
    for camino in caminos:
        ax.plot(camino, camino**2 / 2, color="#0072B2", linewidth=3.5, zorder=3)
    fig.savefig(OUTPUT / f"{nombre}.pdf")
    # Quitar los recorridos adicionales al volver a la versión animada.
    for linea in list(ax.lines[-5:]):
        linea.remove()
    frames = []
    for k in range(5):
        # 0.6 s para leer el impulso, 1.8 s de recorrido y 0.4 s en la muestra.
        frames += [(k, 0)] * 18
        frames += [(k, round(i * 60 / 54)) for i in range(1, 55)]
        frames += [(k, 60)] * 12
    frames += [(4, 60)] * 30
    assert len(frames) == 450
    writer = FFMpegWriter(fps=30, codec="libx264", extra_args=[
        "-crf", "18", "-pix_fmt", "yuv420p", "-movflags", "+faststart"])
    with writer.saving(fig, str(OUTPUT / f"{nombre}.mp4"), dpi=216):
        for k, i in frames:
            actualizar(k, i)
            writer.grab_frame(facecolor="white")
    plt.close(fig)
    print(f"HMC: cinco impulsos independientes={impulsos}; estados={estados}; video de 15 segundos")


if __name__ == "__main__":
    generar_animacion()
    generar_caidas()
    generar_cadena_hmc()
