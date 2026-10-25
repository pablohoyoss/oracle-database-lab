-- scripts/lab5/10-redolog.sql: Inspección y estado del Redo Log
WHENEVER SQLERROR EXIT FAILURE
SET LINESIZE 160 PAGESIZE 100 FEEDBACK OFF
COLUMN member FORMAT A55
COLUMN status FORMAT A12
COLUMN group# FORMAT 999
COLUMN bytes_mb FORMAT 999,999

PROMPT
PROMPT ===== 1. Grupos de Redo Log y su estado de actividad =====
SELECT group#, thread#, sequence#, bytes/1024/1024 AS bytes_mb, members, archived, status, first_change#
FROM v$log ORDER BY group#;

PROMPT
PROMPT ===== 2. Miembros físicos asignados a cada Grupo =====
SELECT group#, status, type, member
FROM v$logfile ORDER BY group#, member;

PROMPT
PROMPT ===== 3. Forzar un cambio de log (Log Switch) =====
ALTER SYSTEM SWITCH LOGFILE;

PROMPT
PROMPT ===== 4. Verificación del cambio de estado y secuencia =====
SELECT group#, sequence#, status, first_change#
FROM v$log ORDER BY group#;
EXIT;
