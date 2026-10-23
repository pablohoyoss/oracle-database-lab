WHENEVER SQLERROR CONTINUE
SET LINESIZE 160 PAGESIZE 100 FEEDBACK OFF
COLUMN name FORMAT A16
COLUMN en_memoria FORMAT A12
COLUMN en_spfile FORMAT A16
COLUMN contenedor FORMAT A10
COLUMN update_comment FORMAT A40

PROMPT ===== 1. SCOPE MEMORY: cambia ya, se pierde al reiniciar =====
ALTER SYSTEM SET open_cursors = 400 SCOPE = MEMORY;
SELECT p.name, p.value AS en_memoria, NVL(s.value, '(sin valor)') AS en_spfile
FROM v$parameter p JOIN v$spparameter s ON s.name = p.name
WHERE p.name = 'open_cursors';

PROMPT ===== 2. SCOPE BOTH con comentario =====
ALTER SYSTEM SET open_cursors = 500 COMMENT = 'Lab4: prueba SCOPE=BOTH' SCOPE = BOTH;
SELECT p.name, p.value AS en_memoria, s.value AS en_spfile, p.update_comment
FROM v$parameter p JOIN v$spparameter s ON s.name = p.name
WHERE p.name = 'open_cursors';

PROMPT Deshacer: volver al valor original en memoria y SPFILE
ALTER SYSTEM SET open_cursors = 300 COMMENT = '' SCOPE = BOTH;

PROMPT ===== 3. Parámetro ESTÁTICO: en memoria falla (ORA-02095 esperado) =====
ALTER SYSTEM SET db_files = 300 SCOPE = MEMORY;

PROMPT En SPFILE si es posible (queda PENDIENTE para el próximo arranque)
ALTER SYSTEM SET db_files = 300 SCOPE = SPFILE;
SELECT p.name, p.value AS en_memoria, s.value AS en_spfile
FROM v$parameter p JOIN v$spparameter s ON s.name = p.name
WHERE p.name = 'db_files';

PROMPT Deshacer con RESET: elimina la línea del SPFILE
ALTER SYSTEM RESET db_files SCOPE = SPFILE;
SELECT p.name, p.value AS en_memoria, NVL(s.value, '(no especificado)') AS en_spfile
FROM v$parameter p JOIN v$spparameter s ON s.name = p.name
WHERE p.name = 'db_files';

PROMPT ===== 4. Dos casos que el examen adora =====
ALTER SYSTEM SET processes = 250 SCOPE = MEMORY;
ALTER SYSTEM SET memory_size = 1600M SCOPE = MEMORY;

PROMPT ===== 5. Parámetros a nivel de PDB =====
ALTER SESSION SET CONTAINER = FREEPDB1;
ALTER SYSTEM SET open_cursors = 350 SCOPE = MEMORY;
SELECT SYS_CONTEXT('USERENV', 'CON_NAME') AS contenedor, name, value AS en_memoria
FROM v$parameter WHERE name = 'open_cursors';

PROMPT Cambio no permitido desde PDB (ORA-65040 esperado)
ALTER SYSTEM SET processes = 300 SCOPE = SPFILE;

PROMPT Deshacer en la PDB
ALTER SYSTEM RESET open_cursors SCOPE = MEMORY;
ALTER SESSION SET CONTAINER = CDB$ROOT;
SELECT SYS_CONTEXT('USERENV', 'CON_NAME') AS contenedor, name, value AS en_memoria
FROM v$parameter WHERE name = 'open_cursors';

PROMPT ===== 6. Nivel SESIÓN =====
ALTER SESSION SET nls_date_format = 'YYYY-MM-DD HH24:MI:SS';
SELECT SYSDATE AS ahora_con_formato_de_sesion FROM dual;

PROMPT ===== 7. Generar PFILE legible para versionar =====
CREATE PFILE = '/tmp/initFREE_lab4.ora' FROM SPFILE;
CREATE PFILE = '/tmp/initFREE_lab4_memoria.ora' FROM MEMORY;
EXIT
