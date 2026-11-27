"""Compilar la presentación 3 y preparar sus videos para pdfpc."""

import json
from pathlib import Path
import shutil
import subprocess
import tempfile

CARPETA = Path(__file__).resolve().parent


def main():
    fuente = CARPETA / "03_presentacion.typ"
    destino = fuente.with_suffix(".pdf")

    with tempfile.TemporaryDirectory() as temporal:
        temporal = Path(temporal)
        pdf = temporal / destino.name
        subprocess.run(["typst", "compile", str(fuente), str(pdf)], check=True)
        datos = json.loads(subprocess.check_output([
            "qpdf", "--json-output", "--json-stream-data=none", str(pdf),
        ]))

        cambios = {}
        for clave, objeto in datos["qpdf"][1].items():
            valor = objeto.get("value")
            if not isinstance(valor, dict):
                continue
            accion = valor.get("/A")
            if not isinstance(accion, dict):
                continue
            uri = accion.get("/URI", "")
            if not uri.startswith("u:pdfpc:"):
                continue
            video = uri.removeprefix("u:pdfpc:")
            if not (CARPETA / video.split("?", 1)[0]).is_file():
                raise FileNotFoundError(video)
            valor["/A"] = {"/S": "/Launch", "/F": "u:" + video}
            cambios[clave] = objeto

        if not cambios:
            raise RuntimeError("No se encontraron enlaces a videos en la presentación")
        parche = temporal / "videos.json"
        parche.write_text(json.dumps({"qpdf": [datos["qpdf"][0], cambios]}))
        salida = temporal / "con_videos.pdf"
        subprocess.run([
            "qpdf", str(pdf), f"--update-from-json={parche}", str(salida),
        ], check=True)
        shutil.copyfile(salida, destino)

    metadatos = subprocess.check_output([
        "typst", "eval", "--in", str(fuente), "query(<pdfpc-file>).first().value",
    ])
    fuente.with_suffix(".pdfpc").write_bytes(metadatos)
    print(f"Presentación preparada con {len(cambios)} videos: {destino.name}")


if __name__ == "__main__":
    main()
