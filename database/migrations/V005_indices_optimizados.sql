-- database/migrations/V005_indices_optimizados.sql
-- Índices optimizados según protocolo de 5 preguntas (Lab 5)
WHENEVER SQLERROR EXIT FAILURE
ALTER SESSION SET CONTAINER = FREEPDB1;

-- 1. Índice compuesto para búsquedas específicas de ciudad y país en CLIENTE
CREATE INDEX tiendasur.ix_cli_ciudad_pais ON tiendasur.cliente(ciudad, pais);

-- 2. Índice filtrado/cubriente en PEDIDO para estado 'P' y fecha de pedido
CREATE INDEX tiendasur.ix_ped_estado_fecha ON tiendasur.pedido(estado, fecha_pedido);

-- 3. Índice para búsquedas por prefijo de apellidos en CLIENTE
CREATE INDEX tiendasur.ix_cli_apellidos ON tiendasur.cliente(apellidos);

-- Actualizar estadísticas de los nuevos índices
BEGIN
  DBMS_STATS.GATHER_INDEX_STATS('TIENDASUR', 'IX_CLI_CIUDAD_PAIS');
  DBMS_STATS.GATHER_INDEX_STATS('TIENDASUR', 'IX_PED_ESTADO_FECHA');
  DBMS_STATS.GATHER_INDEX_STATS('TIENDASUR', 'IX_CLI_APELLIDOS');
END;
/
EXIT
