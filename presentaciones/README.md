Ejecutar desde esta carpeta (`cd presentaciones`).

Para compilar una presentación:

```bash
typst compile 01_presentacion.typ
```

Para generar su handout:

```bash
typst compile --input handout=true 01_presentacion.typ 01_handout.pdf
```

Para compilar la presentación 3 con videos (requiere Typst y qpdf):

```bash
uv run --no-sync python 03_exportar_video.py
pdfpc 03_presentacion.pdf
```
