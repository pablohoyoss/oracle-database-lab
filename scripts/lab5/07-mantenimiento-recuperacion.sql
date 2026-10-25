-- scripts/lab5/07-mantenimiento-recuperacion.sql
WHENEVER SQLERROR EXIT FAILURE
ALTER SESSION SET CONTAINER = FREEPDB1;
SET SERVEROUTPUT ON SIZE UNLIMITED FORMAT WRAPPED
SET LINESIZE 180 PAGESIZE 100 FEEDBACK OFF VERIFY OFF TAB OFF

PROMPT ===== 1. Estado original del índice IX_PED_FECHA =====
SELECT index_name, blevel + 1 AS altura, leaf_blocks, distinct_keys
FROM dba_indexes WHERE owner = 'TIENDASUR' AND index_name = 'IX_PED_FECHA';

PROMPT ===== 2. Simulación de fragmentación (borrado masivo del 80% de datos) =====
DELETE FROM tiendasur.pedido WHERE MOD(id_pedido, 5) != 0;
COMMIT;

BEGIN
  DBMS_STATS.GATHER_INDEX_STATS('TIENDASUR', 'IX_PED_FECHA');
END;
/

SELECT index_name, blevel + 1 AS altura, leaf_blocks AS hojas_despues_de_delete
FROM dba_indexes WHERE owner = 'TIENDASUR' AND index_name = 'IX_PED_FECHA';

PROMPT ===== 3. Desfragmentación con COALESCE (compacta bloques hoja contiguos) =====
ALTER INDEX tiendasur.ix_ped_fecha COALESCE;

BEGIN
  DBMS_STATS.GATHER_INDEX_STATS('TIENDASUR', 'IX_PED_FECHA');
END;
/

SELECT index_name, blevel + 1 AS altura, leaf_blocks AS hojas_tras_coalesce
FROM dba_indexes WHERE owner = 'TIENDASUR' AND index_name = 'IX_PED_FECHA';

PROMPT ===== 4. Reconstrucción con REBUILD ONLINE (libera bloques y reconstruye B-tree) =====
ALTER INDEX tiendasur.ix_ped_fecha REBUILD ONLINE;

BEGIN
  DBMS_STATS.GATHER_INDEX_STATS('TIENDASUR', 'IX_PED_FECHA');
END;
/

SELECT index_name, blevel + 1 AS altura, leaf_blocks AS hojas_tras_rebuild
FROM dba_indexes WHERE owner = 'TIENDASUR' AND index_name = 'IX_PED_FECHA';

PROMPT ===== 5. Simulación de índice UNUSABLE =====
ALTER INDEX tiendasur.ix_ped_fecha UNUSABLE;

SELECT index_name, status FROM dba_indexes WHERE owner = 'TIENDASUR' AND index_name = 'IX_PED_FECHA';

EXEC lab_tools.medir.consulta('unusable_index_query', 'SELECT COUNT(*) FROM tiendasur.pedido WHERE fecha_pedido >= TIMESTAMP ''2023-01-01 00:00:00''');

PROMPT Restauración del índice UNUSABLE mediante REBUILD:
ALTER INDEX tiendasur.ix_ped_fecha REBUILD ONLINE;

SELECT index_name, status FROM dba_indexes WHERE owner = 'TIENDASUR' AND index_name = 'IX_PED_FECHA';

EXIT
