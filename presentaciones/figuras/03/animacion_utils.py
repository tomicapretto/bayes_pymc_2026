"""Textos compartidos por las animaciones de muestreo."""


def texto_vector_theta(valores):
    """Conservar el orden y las repeticiones en una sola fila."""
    return r"$\theta = (" + r",\ ".join(f"{valor:.2f}" for valor in valores) + ")$"
