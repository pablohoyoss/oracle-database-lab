-- scripts/lab5/09-controlfile.sql inspección y respaldo a traza del control file
WHENEVER SQLERROR EXIT FAILURE
SET LINESIZE 160 PAGESIZE 100 FEEDBACK OFF
COLUMN name FORMAT A60
COLUMN status FORMAT A10

PROMPT
PROMPT ===== 1. Ubicación y estado actual de los Control Files =====
SELECT name, status, is_recovery_dest_file, block_size * file_size_blks AS bytes
FROM v$controlfile;

PROMPT
PROMPT ===== 2. Parámetro SPFILE control_files =====
SELECT name, value FROM v$parameter WHERE name = 'control_files';

PROMPT
PROMPT ===== 3. Generar script de reconstrucción en traza (CREATE CONTROLFILE) =====
ALTER DATABASE BACKUP CONTROLFILE TO TRACE AS '/tmp/controlfile_backup.sql' REUSE;

PROMPT [OK] Respaldo de control file a traza generado en /tmp/controlfile_backup.sql
EXIT
