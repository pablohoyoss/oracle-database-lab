He leído la política de uso de IA de la asignatura.

# Declaración de uso de IA · Lab 6 · 

<!--
CÓMO SE RELLENA (léelo y borra este comentario si quieres; el script de evaluación lo ignora)
- La PRIMERA línea es obligatoria y no se toca: «He leído la política de uso de IA de la asignatura.»
- Copia este archivo como docs/bitacora/lab6-ia.md (junto a lab6-respuestas.md) y pon tu código en el título.
  Cada laboratorio tiene el suyo: en el Lab 7 será docs/bitacora/lab7-ia.md.
- Si NO has usado IA: deja solo la línea «No he usado IA.» y borra la entrada de ejemplo.
- Si la has usado: borra la línea «No he usado IA.» y escribe UNA entrada por cada uso, con los 7 campos.
  Un campo vacío es una entrada incompleta (D3: −0,5 por entrada).
- Preguntar a la IA como tutor o corregir la ortografía de un texto propio está permitido: decláralo también.
  Si no copiaste código, escribe «no aplica» en «Código recibido» y en «Evidencia de ejecución» (no cuentan como vacíos).
  Los demás campos son siempre obligatorios.
- Una entrada con TODOS los campos vacíos (la de ejemplo sin tocar) no cuenta: se ignora.
- El código copiado de una IA puntúa si lo EJECUTAS en tu contenedor, lo EXPLICAS con tus palabras,
  dices para qué lo usaste y adjuntas aquí el código y el prompt LITERAL.
-->


## Entrada 1
- **Herramienta:** Gemini
- **Prompt (literal, copiado tal cual):**
```text
Guíame con la A.2 empezando por inspeccionar el zip sin extraerlo a ciegas.
```
- **Código recibido (el fragmento, o la ruta del archivo donde está):**
```sql 
unzip -l /mnt/c/Users/pablo/Downloads/P2_Lab6_v1.3_Estudiante.zip
unzip -q /mnt/c/Users/pablo/Downloads/P2_Lab6_v1.3_Estudiante.zip -d /tmp/lab6_extract
cp -r /tmp/lab6_extract/repo-kit/* .
rm -rf /tmp/lab6_extract

```
- **Dónde lo usé (parte, script o pregunta):** Parte A.2 (inspección y extracción del kit del Lab 6)
- **Propósito (para qué lo necesitaba):** Ver qué carpetas traía el archivo zip antes de descomprimirlo y copiar el contenido de repo-kit/ en las rutas correspondientes del repositorio.
- **Qué hace (con mis palabras; línea a línea si es SQL corto):** Primero, utilicé el comando unzip -l para comprobar el contenido del archivo comprimido sin necesidad de extraerlo, verificando que todos los archivos estaban dentro de la carpeta repo-kit/. Después, utilicé unzip -q -d /tmp/lab6_extract para descomprimir su contenido en una carpeta temporal. A continuación, copié las carpetas config/, scripts/ y docs/ a la raíz de mi repositorio mediante el comando cp -r. Por último, ejecuté rm -rf /tmp/lab6_extract para eliminar la carpeta temporal y dejar el entorno limpio.
- **Evidencia de ejecución (archivo de docs/bitacora/lab6/evidencia con mi cabecera):** no aplica
