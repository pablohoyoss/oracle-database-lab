# Bitácora de Respuestas — Laboratorio 4: Oracle DBA Workflow I

## 1. Preguntas de comprobación

### Respaldo
1. **¿Por qué la copia de la Parte B es consistente? ¿Qué pasaría si se tomara con la base abierta?**
   - Es consistente porque se tomó tras un `SHUTDOWN IMMEDIATE`. Todos los datafiles y control files comparten exactamente el mismo SCN de checkpoint.
   - Si se tomara con la base abierta sin modo `ARCHIVELOG`, los archivos tendrían SCNs desfasados y estarían en estado inconsistente, requiriendo aplicar los redo logs que no existirían.

2. **¿Para qué sirven manifiesto.txt y SHA256SUMS? ¿Qué comprueba restaurar-estado.sh antes de tocar nada?**
   - `manifiesto.txt` documenta el contexto del backup (commit, contenedor, volumen, fecha UTC).
   - `SHA256SUMS` garantiza la integridad criptográfica de los archivos. `restaurar-estado.sh` ejecuta `sha256sum -c` antes de detener o borrar ningún recurso para asegurar que la copia no está corrupta.

3. **Define RPO y RTO con los datos de tu propia copia.**
   - **RPO (Recovery Point Objective):** Tiempo/datos perdidos desde el último backup en frío (en nuestro laboratorio, el momento exacto en que se tomó la copia `lab3-final`).
   - **RTO (Recovery Time Objective):** Tiempo que tarda `restaurar-estado.sh` en detener el contenedor, desempaquetar la copia y levantar la base (aproximadamente 15-30 segundos).

### Diagnóstico y correcciones
4. **¿Dónde creó Oracle los datafiles de V000 y por qué? ¿Qué parámetro habría evitado el problema?**
   - Los creó en `$ORACLE_HOME/dbs` debido a que las sentencias usaron rutas relativas sin tener configurado el parámetro `db_create_file_dest` (OMF).
   - Definir `db_create_file_dest = '/opt/oracle/oradata'` habría redirigido automáticamente la creación al volumen persistente.

5. **¿Por qué ALTER TABLESPACE ... RENAME DATAFILE no basta para mover un archivo?**
   - Porque `RENAME DATAFILE` únicamente actualiza los metadatos dentro del *control file*; no copia ni mueve físicamente el archivo en el sistema de archivos del SO.

6. **¿Por qué no se edita V000 y se crea V003? ¿Por qué invalidar una contraseña es mejor que borrarla del archivo?**
   - Una migración ya aplicada forma parte del historial inmutable de la base de datos.
   - Invalidar la contraseña (`NO AUTHENTICATION`) deshabilita cualquier intento de inicio de sesión con esas credenciales comprometidas en el historial de Git, mientras que borrarla del archivo `.sql` no invalida la clave real cargada en la base.

7. **¿Qué demuestra la prueba de persistencia y por qué se ejecuta después de reubicar?**
   - Demuestra que los datos residen en el volumen Docker persistente (`/opt/oracle/oradata`) y no en la capa efímera del contenedor.
   - Se ejecuta después de reubicar porque si se borrara el contenedor con los datafiles en `$ORACLE_HOME/dbs`, se habrían perdido definitivamente.

### Instancia y arranque
8. **Tres datos que pertenecen a la instancia y tres a la base de datos:**
   - **Instancia:** `startup_time`, procesos de background (`PMON`, `LGWR`), memoria asignada (`SGA`/`PGA`).
   - **Base de datos:** `dbid`, datafiles (`.dbf`), control files (`.ctl`).

9. **¿Qué lee Oracle en NOMOUNT, MOUNT y OPEN? Relaciónalo con ORA-01507 y ORA-01219:**
   - **NOMOUNT:** Lee el `SPFILE`/`PFILE`. No conoce el control file, por eso consultar `v$database` devuelve `ORA-01507`.
   - **MOUNT:** Lee los `control files`. Conoce los datafiles pero no los abre; como el diccionario de datos (`SYSTEM`) sigue cerrado, consultar `dba_tables` devuelve `ORA-01219`.
   - **OPEN:** Abre los datafiles y redo logs, permitiendo transacciones normales.

10. **¿Por qué FREEPDB1 se abre sola tras ALTER DATABASE OPEN?**
    - Porque previamente se ejecutó `ALTER PLUGGABLE DATABASE FREEPDB1 SAVE STATE`. Si no se hiciera, se puede abrir manualmente con `ALTER PLUGGABLE DATABASE FREEPDB1 OPEN;` y guardar su estado.

11. **Clasifica ORA-00800 y ORA-20013 del alert log:**
    - Son avisos informativos/ruido conocido por ejecutar Oracle dentro de un contenedor Docker sin capacidades Kernel avanzadas (`CAP_SYS_NICE`). No afectan la operatividad ni la integridad de la base de datos.

### Parámetros
12. **Diferencia entre v$parameter y v$spparameter con el ejemplo de db_files:**
    - `v$parameter` muestra el valor en ejecución en la memoria RAM de la instancia.
    - `v$spparameter` muestra el valor persistido en el archivo binario `SPFILE`.
    - Al cambiar `db_files` con `SCOPE=SPFILE`, el valor cambió en `v$spparameter` (300) pero se mantuvo en `v$parameter` (200) hasta un reinicio.

13. **¿Qué hace SCOPE=BOTH y cuál es el SCOPE por defecto con SPFILE?**
    - `SCOPE=BOTH` aplica el cambio inmediatamente en memoria y lo escribe en el `SPFILE`.
    - Cuando la instancia arrancó con `SPFILE`, el `SCOPE` por defecto de `ALTER SYSTEM` es `BOTH`.

14. **¿Por qué PROCESSES rechaza el cambio en memoria aunque v$parameter lo marque IMMEDIATE?**
    - Porque `PROCESSES` dimensiona estructuras estáticas de la SGA durante la fase `NOMOUNT`. Intentar cambiarlo en caliente lanza `ORA-02095`.

15. **¿Para qué sirve versionar el PFILE? Explica "configuration drift":**
    - Sirve para tener un registro auditable del estado de configuración de la base de datos en Git.
    - *Configuration drift* es la desviación no documentada entre la configuración real en producción y la definida originalmente.

### Memoria y procesos
16. **¿Qué modelo de gestión de memoria usa tu instancia?**
    - Usa **ASMM** (Automatic Shared Memory Management). Demostrado por `sga_target = 1536M`, `pga_aggregate_target = 512M` y `memory_target = 0`.

17. **Explica las cifras del experimento de caché:**
    - **Ronda 1 (Fría):** Realizó 253 lecturas físicas al tener que cargar los bloques de disco a la RAM.
    - **Ronda 2 (Caliente):** Realizó 0 lecturas físicas (100% de acierto en caché), leyendo los 247 bloques directamente del Buffer Cache de la SGA.

18. **¿Por qué no se suma el RSS de los procesos para saber la memoria de la instancia?**
    - Porque el RSS de cada proceso incluye el mapa de memoria compartida de la SGA. Sumarlos duplicaría el conteo N veces.

19. **Relaciona el SPID de LGWR de v$process con el PID de /proc:**
    - `SPID` es el identificador del proceso dentro del espacio de nombres de procesos (PID namespace) del contenedor. En Linux corresponde exactamente a la carpeta `/proc/<SPID>`.

20. **¿Qué hace PMON y qué hace SMON?**
    - **PMON:** Limpia procesos de usuario fallidos y libera sus bloqueos en memoria.
    - **SMON:** Realiza la recuperación de la instancia (Instance Recovery) al arrancar tras un fallo en seco y limpia segmentos temporales.

### Seguridad y trabajo profesional
21. **¿Por qué C##OPS_RO y no SYSTEM para observar?**
    - Aplicación del principio de mínimo privilegio (*least privilege*). Una cuenta de solo lectura no puede alterar datos ni estructuras ante un fallo o comando accidental.

22. **¿Qué dos vías de exposición de contraseñas corrige este laboratorio?**
    - Eliminación de la contraseña de `SYS` en la línea de comandos (`/ as sysdba` por autenticación de SO).
    - Revocación de contraseñas de los esquemas de negocio mediante cuentas sin autenticación (`NO AUTHENTICATION`).

---

## 2. Preguntas tipo examen (P1 a P12)

- **P1:** **A, D** — Un `SHUTDOWN IMMEDIATE` garantiza un estado consistente de los datafiles, permitiendo abrir la base directamente con `STARTUP`.
- **P2:** **B** — En Standard Edition no está disponible `MOVE DATAFILE` en caliente, requiriendo el método offline (OFFLINE + copia + RENAME + ONLINE).
- **P3:** **A, C** — `STARTUP_TIME` mide el inicio de la instancia actual y `CREATED` refleja la fecha de creación de la base de datos.
- **P4:** **A, C** — En `NOMOUNT` la SGA está asignada y se pueden consultar parámetros y crear los control files.
- **P5:** **B** — Cambiar el modo de registro a `ARCHIVELOG` exige que la base de datos esté montada pero no abierta (`MOUNT`).
- **P6:** **B** — Sin especificar la cláusula `SCOPE`, en una instancia iniciada con `SPFILE` se asume `SCOPE=BOTH`.
- **P7:** **C** — El parámetro `PROCESSES` es de ámbito global de instancia y no puede modificarse desde una Pluggable Database (`ORA-65040`).
- **P8:** **A, C** — Para recuperarse de un `SPFILE` corrupto o erróneo se arranca con un `PFILE` válido o se regenera el `SPFILE` desde un `PFILE`.
- **P9:** **B** — Bajo ASMM, definir `DB_CACHE_SIZE` establece un tamaño mínimo garantizado para el Buffer Cache.
- **P10:** **A, D** — La PGA de una sesión en servidor dedicado contiene la información de sesión (UGA) y áreas de trabajo como Sort Area.
- **P11:** **C** — La sentencia `COMMIT` no finaliza hasta que el proceso `LGWR` escribe el búfer de redo en los archivos de redo log en disco.
- **P12:** **B, D** — `PMON` y `SMON` son procesos obligatorios para la operatividad y recuperación básica de la instancia Oracle.
