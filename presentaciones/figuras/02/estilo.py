"""Exportar los PDF al tamaño físico con el que se insertan en Typst."""

from pathlib import Path
import re

from matplotlib.text import Text

PRESENTACIONES = Path(__file__).resolve().parents[2]
FONT_SIZE = 21  # Mismo tamaño que el texto de presentaciones/template.typ.
ANCHO_MAXIMO = 750  # Área útil de una diapositiva, en puntos.


def guardar_pdf(fig, destino, **kwargs):
    destino = Path(destino)
    alturas = {}
    for documento in ("02_presentacion.typ",):
        contenido = (PRESENTACIONES / documento).read_text()
        alturas.update(
            {
                nombre: float(altura)
                for nombre, altura in re.findall(
                    r'image\("figuras/02/([^"\n]+\.pdf)",[^)\n]*height:\s*([\d.]+)pt',
                    contenido,
                )
            }
        )
    altura = alturas.get(destino.name, 270)
    ancho_original, alto_original = fig.get_size_inches()
    ancho = altura * ancho_original / alto_original
    # Las barras de color también son ejes, pero pueden no tener SubplotSpec.
    columnas = max(
        (
            spec.get_gridspec().ncols
            for ax in fig.axes
            if (spec := ax.get_subplotspec()) is not None
        ),
        default=1,
    )
    if columnas > 1:
        ancho = max(ancho, 240 * columnas)
    if any(ax.get_legend() is not None for ax in fig.axes):
        ancho = max(ancho, 650)
    # Se ensancha el lienzo en comparaciones; nunca se reduce el PDF en Typst.
    ancho = min(ancho, ANCHO_MAXIMO)
    fig.set_size_inches(ancho / 72, altura / 72)
    for texto in fig.findobj(Text):
        texto.set_fontsize(FONT_SIZE)
    # Sin bbox_inches="tight": un recorte cambiaría el tamaño físico del PDF.
    fig.savefig(destino, **kwargs)
