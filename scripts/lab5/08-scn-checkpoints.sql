-- Parte I: SCN y Checkpoints
PROMPT === 1. SCN actual de la base de datos ===
SELECT current_scn, checkpoint_change# FROM v$database;

PROMPT === 2. Inspección de SCN en cabeceras de datafiles y control file ===
SELECT file#, name, checkpoint_change#, last_change# FROM v$datafile_header;
SELECT file#, name, checkpoint_change# FROM v$datafile;

PROMPT === 3. Forzar Checkpoint manual ===
ALTER SYSTEM CHECKPOINT;

PROMPT === 4. Re-verificación de SCN sincronizados ===
SELECT file#, checkpoint_change# FROM v$datafile;
SELECT checkpoint_change# FROM v$database;
