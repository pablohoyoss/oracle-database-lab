-- scripts/lab5/03-tipos-indice.sql
WHENEVER SQLERROR CONTINUE
ALTER SESSION SET CONTAINER = FREEPDB1;

-- Limpieza preventiva de intentos anteriores
BEGIN
  FOR r IN (SELECT index_name FROM dba_indexes WHERE owner = 'TIENDASUR' AND index_name IN ('BX_PED_ESTADO','BX_PED_CANAL','IX_CLI_DNI_REV','FBI_CLI_NOMBRE_UPPER')) LOOP
    EXECUTE IMMEDIATE 'DROP INDEX tiendasur.' || r.index_name;
  END LOOP;
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

WHENEVER SQLERROR EXIT FAILURE
SET SERVEROUTPUT ON SIZE UNLIMITED FORMAT WRAPPED
SET LINESIZE 180 PAGESIZE 100 FEEDBACK OFF VERIFY OFF TAB OFF

PROMPT ===== 1. Comparación: B-tree vs Bitmap en baja cardinalidad =====
EXEC lab_tools.medir.consulta('btree_estado_canal', 'SELECT /*+ INDEX(p IX_PED_IMPORTE) */ COUNT(*) FROM tiendasur.pedido p WHERE estado = ''P'' AND canal = ''W''');

-- Crear índices Bitmap en estado y canal
CREATE BITMAP INDEX tiendasur.bx_ped_estado ON tiendasur.pedido(estado);
CREATE BITMAP INDEX tiendasur.bx_ped_canal ON tiendasur.pedido(canal);

BEGIN
  DBMS_STATS.GATHER_INDEX_STATS('TIENDASUR', 'BX_PED_ESTADO');
  DBMS_STATS.GATHER_INDEX_STATS('TIENDASUR', 'BX_PED_CANAL');
END;
/

EXEC lab_tools.medir.consulta('bitmap_and', 'SELECT COUNT(*) FROM tiendasur.pedido WHERE estado = ''P'' AND canal = ''W''');

PROMPT ===== 2. Reverse Key Index =====
CREATE INDEX tiendasur.ix_cli_dni_rev ON tiendasur.cliente(dni) REVERSE;

SELECT index_name, index_type, blevel + 1 AS altura, leaf_blocks
FROM dba_indexes
WHERE owner = 'TIENDASUR' AND index_name = 'IX_CLI_DNI_REV';

PROMPT ===== 3. Índice Invisible =====
ALTER INDEX tiendasur.bx_ped_estado INVISIBLE;

SELECT index_name, visibility FROM dba_indexes WHERE owner = 'TIENDASUR' AND index_name = 'BX_PED_ESTADO';

EXEC lab_tools.medir.consulta('invisible_test', 'SELECT COUNT(*) FROM tiendasur.pedido WHERE estado = ''P'' AND canal = ''W''');

-- Restaurar visibilidad
ALTER INDEX tiendasur.bx_ped_estado VISIBLE;

PROMPT ===== 4. Índice basado en función =====
CREATE INDEX tiendasur.fbi_cli_nombre_upper ON tiendasur.cliente(UPPER(nombre));

EXEC lab_tools.medir.consulta('fbi_upper_nombre', 'SELECT id_cliente, email FROM tiendasur.cliente WHERE UPPER(nombre) = ''NOMBRE100''');

-- Limpieza final de índices temporales
BEGIN
  FOR r IN (SELECT index_name FROM dba_indexes WHERE owner = 'TIENDASUR' AND index_name IN ('BX_PED_ESTADO','BX_PED_CANAL','IX_CLI_DNI_REV','FBI_CLI_NOMBRE_UPPER')) LOOP
    EXECUTE IMMEDIATE 'DROP INDEX tiendasur.' || r.index_name;
  END LOOP;
END;
/

EXIT
