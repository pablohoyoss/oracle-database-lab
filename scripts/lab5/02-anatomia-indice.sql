-- scripts/lab5/02-anatomia-indice.sql
WHENEVER SQLERROR EXIT FAILURE
SET LINESIZE 170 PAGESIZE 100 FEEDBACK OFF VERIFY OFF TAB OFF
COLUMN index_name FORMAT A18
COLUMN table_name FORMAT A8
COLUMN payload FORMAT A110
COLUMN clave_en_hexadecimal FORMAT A20
COLUMN bloque_hex FORMAT A10

ALTER SESSION SET CONTAINER = FREEPDB1;
SET SERVEROUTPUT ON FORMAT WRAPPED

PROMPT
PROMPT ===== 1. El diccionario: altura, hojas, claves distintas y factor de agrupamiento =====
SELECT i.table_name, i.index_name, i.uniqueness AS unico, i.blevel + 1 AS altura, i.leaf_blocks AS hojas,
       i.distinct_keys AS claves, i.num_rows AS entradas, i.clustering_factor AS cf, t.blocks AS bloques_tabla
FROM dba_indexes i JOIN dba_tables t ON t.owner = i.table_owner AND t.table_name = i.table_name
WHERE i.owner = 'TIENDASUR' ORDER BY i.table_name, i.index_name;

PROMPT
PROMPT ===== 2. Por dentro: ANALYZE INDEX ... VALIDATE STRUCTURE llena INDEX_STATS =====
ANALYZE INDEX tiendasur.ix_ped_cliente VALIDATE STRUCTURE;
SELECT name AS index_name, height AS altura, lf_rows AS entradas_hoja, lf_blks AS hojas, br_rows AS entradas_rama,
       br_blks AS ramas, ROUND(lf_rows_len / NULLIF(lf_rows,0), 1) AS bytes_por_entrada, lf_blk_len AS bytes_utiles_hoja,
       pct_used, del_lf_rows AS borradas
FROM index_stats;

DECLARE
  s index_stats%ROWTYPE; fo_real NUMBER; fo_max NUMBER; cap_hoja NUMBER; h NUMBER;
BEGIN
  SELECT * INTO s FROM index_stats;
  fo_real := (s.lf_blks + s.br_blks - 1) / NULLIF(s.br_blks, 0);
  fo_max := FLOOR(s.br_blk_len / NULLIF((s.br_rows_len / NULLIF(s.br_rows, 0)), 0));
  cap_hoja := FLOOR(s.lf_blk_len / NULLIF((s.lf_rows_len / NULLIF(s.lf_rows, 0)), 0));
  
  DBMS_OUTPUT.PUT_LINE('Factor de ramificación real (fo) = ' || ROUND(fo_real));
  DBMS_OUTPUT.PUT_LINE('Factor de ramificación máximo = ' || fo_max);
  DBMS_OUTPUT.PUT_LINE('Entradas por hoja: medidas ' || ROUND(s.lf_rows / NULLIF(s.lf_blks,0)) || ', máximo ' || cap_hoja);
  
  FOR r IN (SELECT COLUMN_VALUE AS filas FROM TABLE(sys.odcinumberlist(1e6, 2e7, 1e9, 1e11))) LOOP
    h := 1 + CEIL(LN(CEIL(r.filas / cap_hoja / 0.9)) / LN(fo_max));
    DBMS_OUTPUT.PUT_LINE('Con ' || LPAD(TO_CHAR(r.filas, 'FM999,999,999,999'), 15) || ' filas -> altura ' || h || ' (lecturas: ' || (h + 1) || ')');
  END LOOP;
END;
/

PROMPT
PROMPT ===== 3. Lo que cuesta DE VERDAD una búsqueda (DISPLAY_CURSOR) =====
SET SERVEROUTPUT OFF
SELECT /*+ GATHER_PLAN_STATISTICS */ id_pedido, importe FROM tiendasur.pedido WHERE id_pedido = 4711;
SELECT /*+ GATHER_PLAN_STATISTICS */ id_pedido, importe FROM tiendasur.pedido WHERE id_pedido = 4711;
SELECT plan_table_output FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(FORMAT => 'IOSTATS LAST'));

SELECT /*+ GATHER_PLAN_STATISTICS */ id_pedido FROM tiendasur.pedido WHERE id_pedido = 4711;
SELECT plan_table_output FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(FORMAT => 'IOSTATS LAST')) WHERE plan_table_output LIKE '%Buffers%';

SET SERVEROUTPUT ON FORMAT WRAPPED

PROMPT
PROMPT ===== 4. Raíz, rama y hoja: volcado real de PK_CLIENTE =====
COLUMN oid NEW_VALUE oid NOPRINT
SELECT TO_CHAR(object_id) AS oid FROM dba_objects WHERE owner = 'TIENDASUR' AND object_type = 'INDEX' AND object_name LIKE '%CLI%';

ALTER SESSION SET tracefile_identifier = 'lab5_indice';
ALTER SESSION SET EVENTS 'immediate trace name treedump level &oid';

COLUMN tf NEW_VALUE tf NOPRINT
SELECT SUBSTR(value, INSTR(value, '/', -1) + 1) AS tf FROM v$diag_info WHERE name = 'Default Trace File';

SET PAGESIZE 0
SELECT RTRIM(payload, CHR(10)) AS payload FROM v$diag_trace_file_contents
WHERE trace_filename = '&tf' AND (payload LIKE '%branch: 0x%' OR payload LIKE '%leaf: 0x%') AND ROWNUM <= 4;
SET PAGESIZE 100

PROMPT Comprobación: primera entrada de la hoja apunta al ROWID del cliente 1
SELECT id_cliente, DUMP(id_cliente, 16) AS clave_en_hexadecimal,
       DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID, 'BIGFILE') AS bloque,
       TO_CHAR(DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID, 'BIGFILE'), 'FM0XXXXXXX') AS bloque_hex,
       DBMS_ROWID.ROWID_ROW_NUMBER(ROWID) AS ranura
FROM tiendasur.cliente WHERE id_cliente = 1;

EXIT
