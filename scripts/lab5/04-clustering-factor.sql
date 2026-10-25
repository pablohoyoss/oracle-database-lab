-- scripts/lab5/04-clustering-factor.sql
WHENEVER SQLERROR EXIT FAILURE
ALTER SESSION SET CONTAINER = FREEPDB1;
SET SERVEROUTPUT ON SIZE UNLIMITED FORMAT WRAPPED
SET LINESIZE 180 PAGESIZE 100 FEEDBACK OFF VERIFY OFF TAB OFF

PROMPT ===== 1. Comparativa de Clustering Factor =====
SELECT i.index_name, i.clustering_factor AS cf, t.blocks AS bloques_tabla, t.num_rows AS filas_tabla,
       CASE 
         WHEN i.clustering_factor <= t.blocks * 1.5 THEN 'EXCELENTE (cercano a bloques)'
         ELSE 'DEFICIENTE (cercano a filas)'
       END AS evaluacion
FROM dba_indexes i JOIN dba_tables t ON t.owner = i.table_owner AND t.table_name = i.table_name
WHERE i.owner = 'TIENDASUR' AND i.index_name IN ('IX_PED_FECHA', 'IX_PED_CLIENTE')
ORDER BY i.index_name;

PROMPT ===== 2. Consulta con Buen Clustering Factor (IX_PED_FECHA) =====
EXEC lab_tools.medir.consulta('cf_bueno_fecha', 'SELECT /*+ INDEX(p IX_PED_FECHA) */ COUNT(importe) FROM tiendasur.pedido p WHERE fecha_pedido BETWEEN TIMESTAMP ''2023-01-01 00:00:00'' AND TIMESTAMP ''2023-01-05 00:00:00''');

PROMPT ===== 3. Consulta con Mal Clustering Factor (IX_PED_CLIENTE) =====
EXEC lab_tools.medir.consulta('cf_malo_cliente', 'SELECT /*+ INDEX(p IX_PED_CLIENTE) */ COUNT(importe) FROM tiendasur.pedido p WHERE id_cliente BETWEEN 100 AND 5000');

PROMPT ===== 4. Punto de equilibrio (Break-even): Crossover a Full Table Scan =====
EXEC lab_tools.medir.consulta('break_even_index', 'SELECT /*+ INDEX(p IX_PED_FECHA) */ SUM(importe) FROM tiendasur.pedido p WHERE fecha_pedido < TIMESTAMP ''2023-02-01 00:00:00''');
EXEC lab_tools.medir.consulta('break_even_fts', 'SELECT /*+ FULL(p) */ SUM(importe) FROM tiendasur.pedido p WHERE fecha_pedido < TIMESTAMP ''2023-02-01 00:00:00''');

EXIT
