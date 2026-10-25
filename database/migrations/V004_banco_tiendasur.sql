-- database/migrations/V004_banco_tiendasur.sql
-- Banco de pruebas TiendaSur (Lab 5)
WHENEVER SQLERROR EXIT FAILURE
ALTER SESSION SET CONTAINER = FREEPDB1;

-- 1. Tablespace Bigfile
DECLARE
  n NUMBER;
BEGIN
  SELECT COUNT(*) INTO n FROM dba_tablespaces WHERE tablespace_name = 'TBS_TIENDASUR';
  IF n = 0 THEN
    EXECUTE IMMEDIATE 'CREATE BIGFILE TABLESPACE tbs_tiendasur DATAFILE ''/opt/oracle/oradata/FREE/FREEPDB1/tiendasur01.dbf'' SIZE 256M AUTOEXTEND ON NEXT 64M MAXSIZE 2G';
  END IF;
END;
/

-- 2. Usuario TIENDASUR
DECLARE
  n NUMBER;
BEGIN
  SELECT COUNT(*) INTO n FROM dba_users WHERE username = 'TIENDASUR';
  IF n = 0 THEN
    EXECUTE IMMEDIATE 'CREATE USER tiendasur NO AUTHENTICATION DEFAULT TABLESPACE tbs_tiendasur QUOTA UNLIMITED ON tbs_tiendasur';
  END IF;
END;
/

-- 3. Tablas CLIENTE y PEDIDO
CREATE TABLE tiendasur.cliente (
  id_cliente NUMBER PRIMARY KEY,
  email VARCHAR2(100),
  dni VARCHAR2(20),
  nombre VARCHAR2(50),
  apellidos VARCHAR2(50),
  telefono VARCHAR2(20),
  pais VARCHAR2(10),
  ciudad VARCHAR2(50),
  fecha_alta DATE
);

CREATE TABLE tiendasur.pedido (
  id_pedido NUMBER PRIMARY KEY,
  id_cliente NUMBER CONSTRAINT fk_ped_cliente REFERENCES tiendasur.cliente(id_cliente),
  fecha_pedido TIMESTAMP,
  estado CHAR(1),
  importe NUMBER(10,2),
  canal CHAR(1),
  codigo_postal VARCHAR2(10)
);

-- 4. Carga de CLIENTE (100.000 filas)
INSERT /*+ APPEND */ INTO tiendasur.cliente (id_cliente, email, dni, nombre, apellidos, telefono, pais, ciudad, fecha_alta)
SELECT
  n AS id_cliente,
  'cliente' || n || '@tiendasur.es' AS email,
  LPAD(n, 8, '0') || CHR(65 + MOD(n, 23)) AS dni,
  'Nombre' || MOD(n, 500) AS nombre,
  CASE WHEN MOD(ORA_HASH(n, 4294967295, 1), 50) = 0 THEN 'Gonzalez ' || n ELSE 'Apellido' || MOD(n, 1000) END AS apellidos,
  '6' || LPAD(MOD(ORA_HASH(n, 4294967295, 2), 100000000), 8, '0') AS telefono,
  CASE WHEN MOD(ORA_HASH(n, 4294967295, 3), 100) < 60 THEN 'ES' ELSE 'P' || MOD(n, 40) END AS pais,
  CASE WHEN MOD(n, 1000) = 471 THEN 'Lorca' ELSE 'Ciudad' || MOD(n, 200) END AS ciudad,
  DATE '2020-01-01' + MOD(n, 1500) AS fecha_alta
FROM (SELECT LEVEL AS n FROM dual CONNECT BY LEVEL <= 100000);
COMMIT;

-- 5. Carga de PEDIDO (1.000.000 de filas ordenadas por fecha)
INSERT /*+ APPEND */ INTO tiendasur.pedido (id_pedido, id_cliente, fecha_pedido, estado, importe, canal, codigo_postal)
SELECT
  n AS id_pedido,
  MOD(ORA_HASH(n, 4294967295, 10), 100000) + 1 AS id_cliente,
  TIMESTAMP '2023-01-01 00:00:00' + NUMTODSINTERVAL(n * 90, 'SECOND') AS fecha_pedido,
  CASE 
    WHEN h < 20 THEN 'P'
    WHEN h < 70 THEN 'E'
    WHEN h < 972 THEN 'C'
    ELSE 'D'
  END AS estado,
  ROUND(10 + MOD(ORA_HASH(n, 4294967295, 11), 49000)/100, 2) AS importe,
  SUBSTR('WTM', MOD(ORA_HASH(n, 4294967295, 12), 3) + 1, 1) AS canal,
  TO_CHAR(28000 + MOD(ORA_HASH(n, 4294967295, 13), 2000)) AS codigo_postal
FROM (
  SELECT LEVEL AS n, MOD(ORA_HASH(LEVEL, 4294967295, 14), 1000) AS h
  FROM dual CONNECT BY LEVEL <= 1000000
);
COMMIT;

-- 6. Índices iniciales
CREATE UNIQUE INDEX tiendasur.ux_cli_email ON tiendasur.cliente(email);
CREATE INDEX tiendasur.ix_cli_pais_ciudad ON tiendasur.cliente(pais, ciudad);
CREATE INDEX tiendasur.ix_ped_cliente ON tiendasur.pedido(id_cliente);
CREATE INDEX tiendasur.ix_ped_fecha ON tiendasur.pedido(fecha_pedido);
CREATE INDEX tiendasur.ix_ped_importe ON tiendasur.pedido(importe);

-- 7. Estadísticas con histogramas
BEGIN
  DBMS_STATS.GATHER_TABLE_STATS('TIENDASUR', 'CLIENTE', method_opt => 'FOR ALL COLUMNS SIZE AUTO FOR COLUMNS SIZE 254 pais, ciudad', cascade => TRUE);
  DBMS_STATS.GATHER_TABLE_STATS('TIENDASUR', 'PEDIDO', method_opt => 'FOR ALL COLUMNS SIZE AUTO FOR COLUMNS SIZE 254 estado, canal', cascade => TRUE);
END;
/
EXIT
