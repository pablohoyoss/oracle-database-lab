-- scripts/lab5/14-gameday-recovery.sql: Verificación de resiliencia y diagnóstico de cabeceras
WHENEVER SQLERROR EXIT FAILURE
SET LINESIZE 160 PAGESIZE 100 FEEDBACK OFF
COLUMN name FORMAT A50
COLUMN tablespace_name FORMAT A20
COLUMN status FORMAT A10
COLUMN error FORMAT A20
COLUMN checkpoint_change# FORMAT 999,999,999,999

PROMPT
PROMPT ===== 1. Consistencia de cabeceras de Datafiles (V$DATAFILE_HEADER) =====
SELECT file#, name, tablespace_name, status, checkpoint_change#, error
FROM v$datafile_header
ORDER BY file#;

PROMPT
PROMPT ===== 2. Estado de sincronización entre Datafiles y Control File =====
SELECT df.file#, df.name, df.checkpoint_change# AS ctl_ckpt, dh.checkpoint_change# AS hdr_ckpt,
       CASE WHEN df.checkpoint_change# = dh.checkpoint_change# THEN 'OK (SINCRONIZADO)' ELSE 'NECESITA RECOVER' END AS estado_recuperacion
FROM v$datafile df
JOIN v$datafile_header dh ON df.file# = dh.file#;

PROMPT
PROMPT ===== 3. Estado general de la PDB FREEPDB1 y Tablespaces =====
ALTER SESSION SET CONTAINER = FREEPDB1;
SELECT tablespace_name, status, contents, logging FROM dba_tablespaces ORDER BY tablespace_name;

PROMPT
PROMPT ===== 4. Inspección de corrupción de bloques (V$DATABASE_BLOCK_CORRUPTION) =====
ALTER SESSION SET CONTAINER = CDB$ROOT;
SELECT * FROM v$database_block_corruption;

PROMPT
PROMPT ===== 5. Verificación final de redundancia del sistema =====
SELECT 'Control Files' AS componente, COUNT(*) AS cantidad FROM v$controlfile
UNION ALL
SELECT 'Redo Log Members', COUNT(*) FROM v$logfile
UNION ALL
SELECT 'Archived Logs (FRA)', COUNT(*) FROM v$archived_log WHERE name IS NOT NULL;
EXIT;
