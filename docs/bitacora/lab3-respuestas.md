# Lab 3 - Respuestas de comprobación

## Docker

### 1. ¿Qué diferencia hay entre una imagen y un contenedor? Usa como ejemplo lo que hiciste en los ejercicios G2 y G4.
Respuesta: La imagen es la plantilla de solo lectura, la receta. El contenedor es la instancia viva que se crea a partir de ella, el plato cocinado.
En G2 con docker run hello-world lo vi claro: la imagen hello-world ya estaba descargada, y Docker creó un contenedor con nombre aleatorio tipo eager_turing que imprimió el mensaje y murió.
En G4 con docker run -it --name prueba alpine:3.20 sh entré dentro: el prompt cambió a /#, el hostname me devolvió el ID del contenedor y cat /etc/os-release me mostró Alpine aunque mi portátil sea Windows.
Con la misma imagen puedo crear N contenedores.

### 2. En el Ejercicio G5 el archivo nota.txt desapareció y en el G6 no. Explica por qué.
Respuesta: En G5 escribí /tmp/nota.txt dentro del contenedor. Al hacer docker rm prueba borré el contenedor y con él su capa de escritura.
Al crear prueba2 desde la misma imagen partí de la plantilla limpia -> No such file or directory.
En G6 monté -v datos-prueba:/datos. Ahí el archivo no está en el contenedor, está en el volumen gestionado por Docker en /var/lib/docker/volumes/....
Aunque hice --rm en los dos contenedores, el volumen sigue vivo y el segundo contenedor ve el dato importante. Es justo lo que hacemos con Oracle: -v oralab-26ai-data:/opt/oracle/oradata.

### 3. ¿Qué diferencia hay entre docker ps y docker ps -a, y qué significa STATUS = Exited (0)?
Respuesta: docker ps solo lista los que están Up, en marcha. docker ps -a lista todos, incluidos detenidos.
STATUS = Exited (0) significa que el contenedor ya terminó pero terminó bien, código 0 = éxito en Linux. Exited (1) o más es que falló.

### 4. En -p 8181:8181, ¿qué número corresponde a tu equipo y cuál al contenedor? ¿Qué pasaría con -p 80:8080 en el ejercicio de nginx?
Respuesta: El formato siempre es anfitrión:contenedor. O sea, primero lo mío, después lo del contenedor.
En -p 8181:8181, el primer 8181 es mi Ubuntu/Windows, el segundo es el puerto interno del contenedor.
Si en el ejercicio de nginx pongo -p 80:8080, estoy diciendo "mi puerto 80 -> puerto 8080 del contenedor", pero nginx escucha en el 80 interno, no en el 8080. El navegador en localhost:80 no cargaría nada.

### 5. ¿Por qué un contenedor de Oracle se queda en marcha y el de hello-world termina solo?
Respuesta: Un contenedor vive exactamente lo que vive su proceso principal.
hello-world ejecuta /hello que imprime y termina, por eso pasa a Exited solo.
El alpine de G4 se mantuvo porque su proceso era sh y no terminó hasta que escribí exit.
Oracle se queda Up porque su proceso principal es el motor de base de datos que nunca termina, está en bucle esperando conexiones.

### 6. ¿Qué es el digest de una imagen y por qué lo registramos si ya sabemos que usamos :latest?
Respuesta: El digest sha256:... es la huella hash exacta de la imagen, bit a bit. Dos personas con el mismo digest tienen exactamente la misma imagen.
Lo registramos porque :latest es una etiqueta móvil, puede cambiar cuando Oracle publica una versión nueva.
Hoy latest apunta a una versión y en un momento a otra. Si solo digo "usé latest" no se puede reproducir. Con el digest hacemos pin the version, es el audit trail.

### 7. ¿Qué comando borraría realmente los datos de Oracle? ¿Por qué docker rm oralab-26ai no lo hace?
Respuesta: docker rm oralab-26ai NO los borra, borra el contenedor y su capa de escritura, pero el volumen se queda.
Lo que sí los borra es:
docker volume rm oralab-26ai-data
# o peor:
docker system prune -a --volumes
Por eso la regla del lab: nunca hacer prune sin mirar docker volume ls.

## Git, organización y evidencia

### 8. ¿Por qué este laboratorio se hace dentro del repositorio oracle-database-lab, con Issue, branch y Pull Request, en vez de en una carpeta aparte?
Respuesta: Porque instalar no es "un trámite en mi PC", es un cambio de infraestructura. 
Si lo hago en una carpeta suelta del escritorio creo un snowflake server: solo funciona en mi máquina y nadie sabe cómo lo monté.
Con Issue -> branch -> commits por parte -> PR -> review consigo:
1) reproducibilidad, si se me rompe repito los scripts, 2) verificabilidad, el reviewer no me tiene que creer, ve los logs, 3) onboarding, el siguiente compañero lo lee y lo replica.

### 9. ¿Qué diferencia hay entre source 00-config.sh y bash 00-config.sh? ¿Por qué usamos source?
Respuesta: bash 00-config.sh lo ejecuta en una subshell hija que muere al terminar, las export CONT_NAME... se pierden.
source 00-config.sh lo ejecuta en mi shell actual, las variables se quedan cargadas.
Por eso siempre hacemos source al abrir una terminal nueva, si no $EVID está vacío y la evidencia sale con rutas raras tipo /script/_01....

### 10. Explica cada parte del nombre 20260915T091230Z_02-docker.script.log.
Respuesta: 
- 20260915T091230Z: timestamp UTC ISO8601 compacto. Fecha+hora, la Z = Zulu/UTC para que no dependa de mi zona horaria.
- _02: número del paso que la generó, en este caso Parte F de Docker. Enlaza script 02 con evidencia 02.
- -docker: descripción en kebab-case, minúsculas y guiones, sin espacios ni tildes para que funcione en Windows/Linux.
- .script.log: sufijo de tipo, .script = salida de terminal, .spool sería SQL, .png captura.

### 11. ¿Para qué sirve .gitattributes y qué error evita?
Respuesta: Windows guarda con CRLF \r\n y Linux con LF \n. Si un .sh llega con CRLF a Ubuntu falla con $'\r': command not found.
Con:
*.sh text eol=lf
*.sql text eol=lf
Git normaliza todo a LF para todo el equipo. Es higiene básica en equipos mixtos Windows/macOS/Linux.

### 12. ¿Por qué en este Pull Request elegimos Create a merge commit en lugar de Squash and merge?
Respuesta: Porque cada commit tiene valor propio: 01-requisitos, 02-docker, 05-contenedor, 08-migraciones... Quiero ver en main el paso a paso y cuándo se verificó cada herramienta.
Si hago Squash aplasto los ~14 commits en uno solo y pierdo esa trazabilidad.

## Seguridad

### 13. Describe las cuatro capas de la estrategia de contraseñas (Parte D) y qué pasaría si te saltas la primera.
Respuesta: 
1. Capa 1 - .gitignore: echo "config/.env" >> .gitignore ANTES de crear nada. Git ya ignora el archivo.
2. Capa 2 - plantilla: config/.env.example versionada con change_me, sin valores reales.
3. Capa 3 - archivo real: cp .env.example .env y relleno mis passwords reales en local. Verifico con git check-ignore -v y git status.
4. Capa 4 - cargar sin teclear: set -a; source config/.env; set +a y en los scripts uso "$ORACLE_PWD".

### 14. ¿Por qué no escribimos la contraseña directamente en el comando docker run, aunque el script no se suba a Git?
Respuesta: Porque todo lo que tecleo se guarda en ~/.bash_history en texto plano, y además en esta práctica lo grabamos todo con script y tee.
Si pongo -e ORACLE_PWD=MiClave123 esa clave queda en el historial y en los logs.
Usando "$ORACLE_PWD" en el historial solo queda el nombre de la variable.

### 15. Si descubres tu contraseña en un commit ya publicado, ¿basta con borrarla en un commit nuevo? ¿Qué debes hacer?
Respuesta: No. Borrarla en el siguiente commit no sirve, sigue en git log -p navegando hacia atrás.
Hay que darla por comprometida y rotarla: cambiar la password, recrear el contenedor con otra, limpiar la branch y avisar al docente. En empresa es un incidente formal.

## Oracle y herramientas

### 16. ¿Por qué no usamos SPOOL ni @archivo.sql con sqlplus dentro del contenedor, y qué hicimos en su lugar?
Respuesta: Porque sqlplus corre DENTRO del contenedor con docker exec. Un SPOOL /ruta escribiría el archivo dentro del filesystem del contenedor, no en mi repo. 
Y un @07-primera-conexion.sql lo buscaría dentro del contenedor donde no existe -> error SP2-0310.
Lo que hicimos: redirección desde el host < archivo.sql que entra por stdin al sqlplus del contenedor, y | tee en mi Ubuntu para guardar el .spool.log en docs/....
Con SQLcl sí usamos SPOOL normal porque SQLcl ya está instalado en mi equipo.

### 17. ¿Qué hace WHENEVER SQLERROR EXIT SQL.SQLCODE al inicio de V000 y V001, y qué pasaría sin esa línea?
Respuesta: Es el set -e de SQL: si cualquier sentencia falla, el script se detiene ahí mismo devolviendo el código de error.
Sin esa línea SQL*Plus seguiría con la siguiente sentencia sobre un estado a medias.
Por ejemplo, si V000 falla a mitad, V001 se ejecutaría sobre usuarios/tablespaces incompletos y acabaríamos con compañeros con esquemas distintos.

### 18. ¿Qué es una migración y por qué V000 y V001 no se deben editar una vez aplicadas?
Respuesta: Una migración es un script SQL versionado y numerado V000, V001... que lleva la BD de un estado al siguiente, en orden. Es lo que usan Flyway/Liquibase.
No se editan una vez aplicadas porque ya están en producción/en mis compañeros. Si la cambio, mi BD y la suya divergen y no hay forma de reproducir. Si hay que corregir, se crea una V002 nueva.

### 19. ¿Por qué en SQL Developer se usa el servicio FREEPDB1 y no FREE ni un SID?
Respuesta: FREE es la CDB, el contenedor raíz. FREEPDB1 es la PDB donde trabajamos, donde están los 5 esquemas ADMIN_*.
Además hay que usar Service name, no SID. Si pongo SID o FREE me conecto al root y no veo las tablas. En SQL Developer: Host localhost, Puerto 1521, Service name FREEPDB1.

### 20. ¿Qué aporta SQLcl frente a SQL*Plus, y por qué un DBA debe dominar ambas?
Respuesta: SQLcl es la herramienta moderna del día a día: autocompletado, historial, SET SQLFORMAT ansiconsole, CONNECT -save, SPOOL directo a mi repo, integración con Liquibase. Mucho más cómodo.
SQL*Plus es el clásico que viene dentro de cualquier servidor Oracle. 
Cuando a las 3am solo tienes ssh al servidor, es lo único que hay.Un DBA domina ambas: SQLcl para desarrollar, SQL*Plus para sobrevivir en producción.

## Entorno de trabajo

### 21. ¿Por qué el curso pasa de Git Bash a Ubuntu en WSL 2? Da al menos dos problemas concretos de Git Bash que desaparecen en Ubuntu.
Respuesta: Git Bash es una emulación, no Linux. Me daba dos problemas concretos:
1. Rompía rutas y args de Docker, convertía /opt/... a rutas Windows y docker run -it daba not a TTY, tenía que usar winpty o PowerShell.
2. No trae herramientas de admin: no hay free, ss, htop, lsof y Java/SQLcl fallan pidiendo la password.

Ubuntu en WSL 2 es un Linux real con su kernel, mismos comandos, rutas y apt que los servidores y que los contenedores. Además Docker Desktop ya corre sobre WSL 2, así que trabajo sin capa intermedia.

### 22. ¿Por qué clonamos el repositorio en ~/oracle-database-lab y no trabajamos sobre la carpeta de Windows (/mnt/c/...)? ¿Y por qué recomendamos bash frente a zsh para los scripts del curso?
Respuesta: Trabajar en /mnt/c/... cruza dos filesystems distintos en cada operación: Git y Docker van varias veces más lentos, se pierden los permisos de ejecución +x y vuelven los problemas de CRLF.
En ~/oracle-database-lab es ext4 nativo, rápido y con permisos.
Recomendamos bash para scripts porque es el estándar garantizado en todos los servidores, Ubuntu, Red Hat, Oracle Linux. zsh está bien para uso interactivo en macOS (mejor autocomplete, temas),
 pero tiene diferencias sutiles en arrays/globbing y normalmente no está instalado en servidores. Regla profesional: interactivo lo que quieras, scripts compartidos siempre en bash con #!/usr/bin/env bash.
