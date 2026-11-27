"""Esquema geométrico de discretización inspirado en la referencia del docente.

La curva y las aproximaciones son ilustrativas: no representan una simulación
ni un plano de fase. Se compara visualmente seguir una curva con pasos cortos
y alejarse de ella con pasos demasiado grandes.
"""
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
from scipy.interpolate import CubicSpline

OUTPUT = Path(__file__).resolve().parent


def generar_leapfrog():
    plt.style.use(OUTPUT.parent / "curso.mplstyle")
    plt.rcParams.update({"figure.constrained_layout.use": False, "font.size": 18,
                         "axes.titlesize": 18})
    parametro = np.array([0, 0.18, 0.32, 0.48, 0.68, 0.85, 1])
    horizontal = CubicSpline(parametro, [0.15, 0.28, 0.65, 0.84, 0.43, 0.22, 0.29])
    t = np.linspace(0, 1, 601)
    referencia = np.column_stack((horizontal(t), 1 - t))
    pasos_cortos = np.linspace(0, 1, 13)
    fino = np.column_stack((horizontal(pasos_cortos), 1 - pasos_cortos))
    grueso = np.array([[0.15, 1], [0.37, 0.74], [0.91, 0.63],
                       [0.94, 0.33], [1.24, 0.03]])
    fig, axes = plt.subplots(1, 3, figsize=(480 / 72, 300 / 72), layout="none")
    fig.subplots_adjust(left=0.025, right=0.985, bottom=0.025, top=0.87, wspace=0.13)
    for ax, titulo, camino in zip(axes, ("Trayectoria", "Convergente", "Divergente"),
                                  (None, fino, grueso)):
        ax.plot(*referencia.T, color="0.4", linewidth=2, solid_capstyle="round")
        if camino is not None:
            ax.plot(*camino.T, color="#0072B2", linewidth=1.5, zorder=2)
            for inicio, final in zip(camino[:-1], camino[1:]):
                # Dejar visible el segmento azul y poner la punta negra al final.
                ax.annotate("", xy=final, xytext=inicio + 0.62 * (final - inicio),
                            arrowprops={"arrowstyle": "-|>", "lw": 1.0,
                                        "color": "black", "mutation_scale": 12,
                                        "shrinkA": 0, "shrinkB": 0}, zorder=3)
        ax.set(title=titulo, xlim=(-0.02, 1.30), ylim=(-0.03, 1.04))
        ax.set_axis_off()
    fig.savefig(OUTPUT / "hmc_leapfrog.pdf")
    plt.close(fig)
    print("Leapfrog: esquema de curva suave, pasos pequeños y pasos grandes; 480 × 300 pt")


if __name__ == "__main__":
    generar_leapfrog()
