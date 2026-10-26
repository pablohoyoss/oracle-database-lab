-- scripts/lab5/06-protocolo-diseno.sql
WHENEVER SQLERROR EXIT FAILURE
ALTER SESSION SET CONTAINER = FREEPDB1;
SET SERVEROUTPUT ON SIZE UNLIMITED FORMAT WRAPPED
SET LINESIZE 180 PAGESIZE 100 FEEDBACK OFF VERIFY OFF TAB OFF

PROMPT ===== 1. Medición de consultas optimizadas con V005 =====
EXEC lab_tools.medir.consulta('q_lorca_optimizada', 'SELECT id_cliente, nombre FROM tiendasur.cliente WHERE ciudad = ''Lorca'' AND pais = ''ES''');
EXEC lab_tools.medir.consulta('q_pedidos_pendientes_opt', 'SELECT id_pedido, importe FROM tiendasur.pedido WHERE estado = ''P'' AND fecha_pedido >= TIMESTAMP ''2023-06-01 00:00:00''');
EXEC lab_tools.medir.consulta('q_apellidos_gonz_opt', 'SELECT id_cliente, email FROM tiendasur.cliente WHERE apellidos LIKE ''Gonzalez%''');

PROMPT ===== 2. Medición del costo de escritura (DML Write Cost) =====
PROMPT Inserción unitaria en PEDIDO (mide bloques modificados y redo generado por índice):
EXEC lab_tools.medir.dml('insert_pedido_test', 'INSERT INTO tiendasur.pedido (id_pedido, id_cliente, fecha_pedido, estado, importe, canal, codigo_postal) VALUES (9999999, 1, SYSTIMESTAMP, ''P'', 99.99, ''W'', ''28001'')');

PROMPT Actualización de estado en PEDIDO (impacta en IX_PED_ESTADO_FECHA):
EXEC lab_tools.medir.dml('update_estado_pedido', 'UPDATE tiendasur.pedido SET estado = ''C'' WHERE id_pedido = 100');

EXIT
