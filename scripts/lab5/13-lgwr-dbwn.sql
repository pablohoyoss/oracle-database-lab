-- scripts/lab5/13-lgwr-dbwn.sql: Análisis del ciclo de vida de bloques sucios (DBWn) y escrituras Redo (LGWR)
WHENEVER SQLERROR EXIT FAILURE
SET LINESIZE 160 PAGESIZE 100 FEEDBACK OFF
COLUMN name FORMAT A35
COLUMN description FORMAT A50
COLUMN status FORMAT A15
COLUMN dirty FORMAT A5
COLUMN metric_value FORMAT 999,999,999

PROMPT
PROMPT ===== 1. Procesos de fondo clave (DBWn, LGWR, CKPT, MMON) =====
SELECT name, description FROM v$bgprocess WHERE paddr != '00' AND name IN ('DBW0', 'LGWR', 'CKPT', 'MMON', 'SMON', 'PMON') ORDER BY name;

PROMPT
PROMPT ===== 2. Estado de los bloques en el Buffer Cache (v$bh) =====
SELECT status, dirty, COUNT(*) AS cantidad_bloques FROM v$bh GROUP BY status, dirty ORDER BY cantidad_bloques DESC;

PROMPT
PROMPT ===== 3. Generación de bloques sucios (Dirty Buffers) mediante DML masivo =====
ALTER SESSION SET CONTAINER = FREEPDB1;
UPDATE admin_academia.aca_estudiantes SET estado = estado WHERE ROWNUM <= 5000;
COMMIT;

PROMPT
PROMPT ===== 4. Inspección de bloques sucios pendientes en memoria (antes del Checkpoint) =====
ALTER SESSION SET CONTAINER = CDB$ROOT;
SELECT dirty, COUNT(*) AS cantidad_bloques FROM v$bh WHERE dirty = 'Y' GROUP BY dirty;

PROMPT
PROMPT ===== 5. Forzado de Checkpoint completo (DBWn vuelca los bloques sucios a los Datafiles) =====
ALTER SYSTEM CHECKPOINT;

PROMPT
PROMPT ===== 6. Inspección tras el Checkpoint (Verificación de vaciado de bloques sucios) =====
SELECT dirty, COUNT(*) AS cantidad_bloques FROM v$bh WHERE dirty = 'Y' GROUP BY dirty;

PROMPT
PROMPT ===== 7. Estadísticas acumuladas de actividad para DBWn y LGWR =====
SELECT name, value AS metric_value 
FROM v$sysstat 
WHERE name IN ('dirty buffers inspected', 'db block writes', 'physical writes', 'redo writes', 'redo buffer allocation retries')
ORDER BY name;
EXIT;
