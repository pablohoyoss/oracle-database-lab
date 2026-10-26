-- scripts/lab5/01-perfil-tiendasur.sql
WHENEVER SQLERROR EXIT FAILURE
SET LINESIZE 200 PAGESIZE 100 FEEDBACK OFF
ALTER SESSION SET CONTAINER = FREEPDB1;

PROMPT ===== 1. Tablas: r filas, b bloques, R bytes por fila y bfr =====
SELECT table_name, num_rows AS r, blocks AS b, avg_row_len AS r_bytes,
       ROUND(8000 / NULLIF(avg_row_len, 0)) AS bfr,
       ROUND(blocks * 8192 / 1048576, 1) AS mb,
       TO_CHAR(last_analyzed, 'YYYY-MM-DD HH24:MI') AS last_analyzed
FROM dba_tables
WHERE owner = 'TIENDASUR' ORDER BY table_name;

PROMPT ===== 2. Índices heredados =====
SELECT table_name, index_name, uniqueness, blevel + 1 AS altura, leaf_blocks AS hojas, distinct_keys
FROM dba_indexes
WHERE owner = 'TIENDASUR' ORDER BY table_name, index_name;

PROMPT ===== 3. Los sesgos que dan juego a las consultas Q1-Q16 =====
SELECT 'cliente pais = ES' AS dato, ROUND(100 * COUNT(*) / 100000, 1) AS pct FROM tiendasur.cliente WHERE pais = 'ES'
UNION ALL
SELECT 'cliente ciudad = Lorca', ROUND(100 * COUNT(*) / 100000, 1) FROM tiendasur.cliente WHERE ciudad = 'Lorca'
UNION ALL
SELECT 'cliente apellidos LIKE Gonz%', ROUND(100 * COUNT(*) / 100000, 1) FROM tiendasur.cliente WHERE apellidos LIKE 'Gonz%'
UNION ALL
SELECT 'pedido estado = P', ROUND(100 * COUNT(*) / 1000000, 1) FROM tiendasur.pedido WHERE estado = 'P';
EXIT
