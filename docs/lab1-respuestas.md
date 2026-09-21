\# Respuestas Teóricas - Laboratorio 1: Git Fundamentals



\*\*Estudiante:\*\* Jose Pablo Hoyos del Rey  

\*\*Repositorio:\*\* https://github.com/pablohoyoss/oracle-database-lab.git



\---



\### 1. ¿Cuál es la diferencia entre Working Directory, Staging Area y Local Repository? Da un ejemplo de un archivo pasando por las tres.

\- \*\*Working Directory (Directorio de trabajo):\*\* Es la carpeta real en tu disco duro donde creas, editas y eliminas archivos. Git ve estos cambios pero aún no los rastrea oficialmente.

\- \*\*Staging Area (Área de preparación o Index):\*\* Es una zona intermedia o "borrador" donde seleccionas exactamente qué cambios de tu directorio de trabajo quieres incluir en la próxima foto o commit.

\- \*\*Local Repository (Repositorio Local):\*\* Es la base de datos interna de Git (la carpeta `.git`) donde se guardan de forma permanente e inmutable todos los commits e historial de tu proyecto.



\*\*Ejemplo de flujo:\*\*

1\. Creas el archivo `script.sql` en tu carpeta -> Está en el \*\*Working Directory\*\* (Untracked / Modified).

2\. Ejecutas `git add script.sql` -> El archivo pasa al \*\*Staging Area\*\* (Staged).

3\. Ejecutas `git commit -m "feat: add initial SQL script"` -> El archivo queda guardado en el \*\*Local Repository\*\*.



\---



\### 2. Si modificas un archivo pero no haces `git add`, ¿aparece ese cambio en tu próximo commit? Explica por qué.

No, no aparecerá. Ocurre porque Git no guarda automáticamente todo lo que editas en tu disco; únicamente incluye en la confirmación (commit) los cambios que hayas preparado explícitamente dentro del \*\*Staging Area\*\* mediante el comando `git add`. Si no haces `git add`, el cambio se queda suspendido únicamente en tu Working Directory.



\---



\### 3. ¿Por qué `git status` no mostraba las carpetas vacías que creaste en la Parte C? ¿Qué truco usamos para solucionarlo?

Git está diseñado para rastrear el contenido de los \*\*archivos\*\*, no las estructuras de carpetas en sí mismas. Si una carpeta no tiene ningún archivo dentro, Git la ignora por completo y no la detecta en `git status`.

Para solucionarlo, usamos el truco convencional de crear un archivo oculto y vacío llamado \*\*`.gitkeep`\*\* dentro de cada carpeta vacía. Al existir un archivo, Git ya puede rastrearlo y mantener la estructura del directorio.



\---



\### 4. Explica con tus palabras qué es `HEAD`.

`HEAD` es un indicador o "puntero" transparente de Git que señala en todo momento cuál es tu ubicación actual dentro del historial. Indica en qué rama (`branch`) estás parado y cuál es el commit más reciente sobre el que estás trabajando. Es el equivalente a la barra de reproducción que marca el segundo actual de una película.



\---



\### 5. ¿Qué diferencia hay entre crear una branch con `git switch -c` y crear una carpeta nueva con `mkdir`? ¿Cómo lo comprobamos en la Parte G?

\- `mkdir` crea una carpeta física tangible en el sistema de archivos del disco duro.

\- `git switch -c` crea una nueva línea de tiempo o puntero conceptual en Git, no una carpeta física.

En la \*\*Parte G\*\* lo comprobamos al cambiar entre ramas: los archivos en nuestro disco duro aparecían y desaparecían mágicamente según la rama en la que nos ubicábamos, sin que en ningún momento se crearan carpetas llamadas `feature/...` en el Explorador de Archivos de Windows.



\---



\### 6. Durante el conflicto de la Parte H, ¿qué representaba el contenido entre `<<<<<<< HEAD` y `=======`? ¿Y entre `=======` y `>>>>>>>`?

\- \*\*Entre `<<<<<<< HEAD` y `=======`:\*\* Representa el contenido que ya existía en la rama actual en la que estábamos parados al intentar la fusión (en este caso, la versión de la rama `main`).

\- \*\*Entre `=======` y `>>>>>>> fix/readme-subtitle`:\*\* Representa el contenido entrante que provenía de la rama que intentábamos fusionar (`fix/readme-subtitle`).



\---



\### 7. ¿Por qué NO se debe hacer `git commit --amend` sobre un commit que ya se subió con `git push`?

Porque `git commit --amend` no solo edita el texto, sino que \*\*destruye el commit anterior y crea uno totalmente nuevo con un SHA-1 (hash) distinto\*\*, reescribiendo el historial. Si ya habías subido el commit original a GitHub, tu historial local y el remoto dejarán de coincidir, lo que provocará errores de sincronización y problemas graves para cualquier compañero que haya descargado ese commit.



\---



\### 8. Si borras por accidente la carpeta `.git` de tu proyecto, ¿qué se pierde exactamente? ¿Se pierde también el código fuente que está en el disco?

\- \*\*Lo que se pierde:\*\* Se pierde absolutamente todo el historial de versiones, todos los commits anteriores, las ramas creadas, las configuraciones locales de Git y la vinculación con el repositorio remoto.

\- \*\*Lo que NO se pierde:\*\* Tu código fuente actual (archivos `.sql`, `.md`, `.py`, etc.) permanecerá intacto en el disco duro dentro del Working Directory, pero dejará de estar bajo el control de versiones de Git.



\---



\### 9. Explica con tus propias palabras la diferencia entre Git y GitHub, sin usar la palabra "nube".

\- \*\*Git:\*\* Es el programa de software instalado localmente en tu ordenador que se encarga de calcular, registrar y gestionar el historial de cambios de tus archivos.

\- \*\*GitHub:\*\* Es una plataforma web y servidor remoto centralizado donde puedes subir, respaldar y compartir las copias de tus repositorios creados con Git para colaborar con otras personas a través de internet.



\---



\### 10. ¿Por qué no se debe subir un archivo `.env` con contraseñas reales a un repositorio, aunque el repositorio sea privado?

Porque aunque el repositorio sea privado, las credenciales quedan registradas para siempre en el historial de commits y cualquier usuario con acceso al proyecto o futuras integraciones de terceros podrían verlas. Además, si en el futuro el repositorio se vuelve público por error o la cuenta sufre una brecha de seguridad, las contraseñas reales quedarían expuestas.



\---



\### 11. Un compañero te dice: "hice push y ahora GitHub me rechaza el segundo push con 'non-fast-forward'". ¿Qué ha ocurrido probablemente y qué comando ejecutarías primero?

\- \*\*Causa probable:\*\* En el servidor remoto (GitHub) existen cambios o commits nuevos que tu compañero no tiene en su ordenador local (ya sea porque otro desarrollador hizo un push previo o porque se editó un archivo directamente desde la web).

\- \*\*Comando a ejecutar primero:\*\* Debe ejecutar `git pull` (o `git fetch` seguido de `git merge`) para descargar e integrar primero los cambios remotos en su copia local antes de intentar el push de nuevo.



\---



\### 12. ¿Qué tipo de Conventional Commit (feat, fix, docs, test…) usarías para: añadir un índice de rendimiento a una tabla, corregir una restricción mal definida, y actualizar el README?

\- \*\*Añadir un índice de rendimiento a una tabla:\*\* `perf` (o `feat` si se considera una nueva funcionalidad de base de datos, aunque `perf` es la convención para optimizaciones de rendimiento).

\- \*\*Corregir una restricción mal definida:\*\* `fix` (corrección de un error o falla en el esquema).

\- \*\*Actualizar el README:\*\* `docs` (cambios en la documentación).

