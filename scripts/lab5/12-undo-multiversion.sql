-- scripts/lab5/12-undo-multiversion.sql: Undo, MVCC, Flashback Query y métricas DML
WHENEVER SQLERROR EXIT FAILURE
SET LINESIZE 160 PAGESIZE 100 FEEDBACK OFF
COLUMN name FORMAT A30
COLUMN metric_bytes FORMAT 999,999,999,999
COLUMN estado_actual FORMAT A18
COLUMN estado_pasado FORMAT A18
COLUMN estado_restaurado FORMAT A18

PROMPT
PROMPT ===== 1. Parámetros y estado del Tablespace de UNDO =====
SELECT name, value FROM v$parameter WHERE name IN ('undo_management', 'undo_tablespace', 'undo_retention');
SELECT tablespace_name, status, ROUND(SUM(bytes)/1048576, 1) AS total_mb FROM dba_undo_extents GROUP BY tablespace_name, status;

PROMPT
PROMPT ===== 2. Captura de SCN inicial y modificación del registro =====
ALTER SESSION SET CONTAINER = FREEPDB1;

VARIABLE scn_inicio NUMBER;
EXEC :scn_inicio := DBMS_FLASHBACK.GET_SYSTEM_CHANGE_NUMBER;

DECLARE
  v_actual VARCHAR2(50);
  v_nuevo  VARCHAR2(50);
BEGIN
  SELECT estado INTO v_actual FROM admin_academia.aca_estudiantes WHERE estudiante_id = 1;
  IF v_actual = 'ACTIVO' THEN v_nuevo := 'INACTIVO';
  ELSE v_nuevo := 'ACTIVO';
  END IF;
  UPDATE admin_academia.aca_estudiantes SET estado = v_nuevo WHERE estudiante_id = 1;
END;
/
COMMIT;

PROMPT
PROMPT ===== 3. Estado actual (después del UPDATE) =====
SELECT estudiante_id, estado AS estado_actual FROM admin_academia.aca_estudiantes WHERE estudiante_id = 1;

PROMPT
PROMPT ===== 4. Estado pasado (Flashback Query AS OF SCN) =====
SELECT estudiante_id, estado AS estado_pasado FROM admin_academia.aca_estudiantes AS OF SCN :scn_inicio WHERE estudiante_id = 1;

PROMPT
PROMPT ===== 5. Restauración del valor original =====
UPDATE admin_academia.aca_estudiantes SET estado = (SELECT estado FROM admin_academia.aca_estudiantes AS OF SCN :scn_inicio WHERE estudiante_id = 1) WHERE estudiante_id = 1;
COMMIT;

SELECT estudiante_id, estado AS estado_restaurado FROM admin_academia.aca_estudiantes WHERE estudiante_id = 1;

PROMPT
PROMPT ===== 6. Métricas de generación de UNDO y REDO =====
ALTER SESSION SET CONTAINER = CDB$ROOT;
SELECT name, value AS metric_bytes FROM v$sysstat WHERE name IN ('undo change vector size', 'redo size') ORDER BY name;
EXIT;
