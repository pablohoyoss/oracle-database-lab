-- scripts/lab5/10-redo.sql: Multiplexación y verificación del Redo Log
WHENEVER SQLERROR CONTINUE
SET LINESIZE 160 PAGESIZE 100 FEEDBACK OFF SERVEROUTPUT ON
COLUMN member FORMAT A55
COLUMN status FORMAT A12
COLUMN archived FORMAT A8

PROMPT
PROMPT ===== 1. Estado actual antes de multiplexar =====
SELECT group#, thread#, sequence#, ROUND(bytes/1048576) AS mb, members, archived, status FROM v$log ORDER BY group#;

PROMPT
PROMPT ===== 2. Añadir un segundo miembro a cada grupo (redo01b.log, redo02b.log, redo03b.log) =====
DECLARE
  v_ruta VARCHAR2(400);
  v_n PLS_INTEGER := 0;
BEGIN
  FOR g IN (SELECT group# FROM v$log WHERE members = 1 ORDER BY group#) LOOP
    SELECT REGEXP_REPLACE(MIN(member), '\.log$', 'b.log') INTO v_ruta FROM v$logfile WHERE group# = g.group#;
    EXECUTE IMMEDIATE 'ALTER DATABASE ADD LOGFILE MEMBER ''' || v_ruta || ''' TO GROUP ' || g.group#;
    DBMS_OUTPUT.PUT_LINE('Grupo ' || g.group# || ': añadido miembro ' || v_ruta);
    v_n := v_n + 1;
  END LOOP;
  IF v_n = 0 THEN DBMS_OUTPUT.PUT_LINE('Todos los grupos ya tienen dos miembros.'); END IF;
END;
/

PROMPT
PROMPT ===== 3. Estado de los miembros (los nuevos figuran inicialmente como INVALID) =====
SELECT group#, member, status FROM v$logfile ORDER BY group#, member;

PROMPT
PROMPT ===== 4. Forzar cambios de log para que LGWR escriba en los nuevos miembros =====
ALTER SYSTEM SWITCH LOGFILE;
ALTER SYSTEM SWITCH LOGFILE;

PROMPT
PROMPT ===== 5. Verificación final: todos los miembros sincronizados y válidos =====
SELECT group#, member, status FROM v$logfile ORDER BY group#, member;
SELECT group#, sequence#, status, members FROM v$log ORDER BY group#;
EXIT;
