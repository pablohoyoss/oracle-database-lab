-- scripts/lab5/05-sargabilidad.sql
WHENEVER SQLERROR EXIT FAILURE
ALTER SESSION SET CONTAINER = FREEPDB1;
SET SERVEROUTPUT ON SIZE UNLIMITED FORMAT WRAPPED
SET LINESIZE 180 PAGESIZE 100 FEEDBACK OFF VERIFY OFF TAB OFF

PROMPT ===== 1. Caso 1: Función sobre columna (Non-Sargable vs Sargable) =====
EXEC lab_tools.medir.consulta('no_sargable_trunc', 'SELECT COUNT(*) FROM tiendasur.pedido WHERE TRUNC(fecha_pedido) = DATE ''2023-05-15''');
EXEC lab_tools.medir.consulta('sargable_rango', 'SELECT COUNT(*) FROM tiendasur.pedido WHERE fecha_pedido >= TIMESTAMP ''2023-05-15 00:00:00'' AND fecha_pedido < TIMESTAMP ''2023-05-16 00:00:00''');

PROMPT ===== 2. Caso 2: Búsqueda con comodín inicial (Non-Sargable vs Sargable) =====
EXEC lab_tools.medir.consulta('no_sargable_wildcard', 'SELECT COUNT(*) FROM tiendasur.cliente WHERE email LIKE ''%@tiendasur.es''');
EXEC lab_tools.medir.consulta('sargable_prefix', 'SELECT COUNT(*) FROM tiendasur.cliente WHERE email LIKE ''cliente471%''');

PROMPT ===== 3. Caso 3: Conversión implícita de tipos (Non-Sargable vs Sargable) =====
EXEC lab_tools.medir.consulta('no_sargable_implicit_conv', 'SELECT COUNT(*) FROM tiendasur.pedido WHERE codigo_postal = 28001');
EXEC lab_tools.medir.consulta('sargable_explicit_type', 'SELECT COUNT(*) FROM tiendasur.pedido WHERE codigo_postal = ''28001''');

EXIT
