CREATE DATABASE IF NOT EXISTS gestion;
USE gestion;

DROP TABLE IF EXISTS hecho_matricula;
DROP TABLE IF EXISTS hecho_titulacion;
DROP TABLE IF EXISTS matricula_2025;
DROP TABLE IF EXISTS matricula_2024;
DROP TABLE IF EXISTS matricula_2023;
DROP TABLE IF EXISTS titulacion_2024;
DROP TABLE IF EXISTS titulacion_2023;

CREATE TABLE matricula_2025 (
    cat_periodo INT, id INT, codigo_unico VARCHAR(255), mrun INT, 
    anio_ing_carr_ori INT, cod_inst INT, valor_matricula INT, valor_arancel INT
);
CREATE TABLE matricula_2024 LIKE matricula_2025;
CREATE TABLE matricula_2023 LIKE matricula_2025;

CREATE TABLE titulacion_2024 (
    cat_periodo INT, codigo_unico VARCHAR(255), mrun INT, anio_ing_carr_ori INT, 
    nombre_titulo_obtenido VARCHAR(255), nombre_grado_obtenido VARCHAR(255), 
    fecha_obtencion_titulo INT, cod_inst INT
);
CREATE TABLE titulacion_2023 LIKE titulacion_2024;

LOAD DATA LOCAL INFILE '2025/20250729_Matrícula_Ed_Superior_2025_PUBL_MRUN.csv'
INTO TABLE matricula_2025
FIELDS TERMINATED BY ';' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
(cat_periodo, @d , codigo_unico, mrun, @d, @d, @d, anio_ing_carr_ori, @d, @d, @d, @d, @d, @d, cod_inst, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, valor_matricula, valor_arancel, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d);

LOAD DATA LOCAL INFILE '2024/20250729_Matrícula_Ed_Superior_2024_PUBL_MRUN.csv'
INTO TABLE matricula_2024
FIELDS TERMINATED BY ';' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
(cat_periodo, @d, codigo_unico, mrun, @d, @d, @d, anio_ing_carr_ori, @d, @d, @d, @d, @d, @d, cod_inst, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, valor_matricula, valor_arancel, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d);

LOAD DATA LOCAL INFILE '2023/20250729_Matrícula_Ed_Superior_2023_PUBL_MRUN.csv'
INTO TABLE matricula_2023
FIELDS TERMINATED BY ';' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
(cat_periodo, @d, codigo_unico, mrun, @d, @d, @d, anio_ing_carr_ori, @d, @d, @d, @d, @d, @d, cod_inst, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, valor_matricula, valor_arancel, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d);

LOAD DATA LOCAL INFILE '2024/20250718_Titulados_Ed_Superior_2024_WEB.csv'
INTO TABLE titulacion_2024
FIELDS TERMINATED BY ';' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
(cat_periodo, codigo_unico, mrun, @d, @d, @d, anio_ing_carr_ori, @d, @d, @d, nombre_titulo_obtenido, nombre_grado_obtenido, fecha_obtencion_titulo, @d, @d, @d, cod_inst, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d);

LOAD DATA LOCAL INFILE '2023/20250718_Titulados_Ed_Superior_2023_WEB.csv'
INTO TABLE titulacion_2023
FIELDS TERMINATED BY ';' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
(cat_periodo, codigo_unico, mrun, @d, @d, @d, anio_ing_carr_ori, @d, @d, @d, nombre_titulo_obtenido, nombre_grado_obtenido, fecha_obtencion_titulo, @d, @d, @d, cod_inst, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d, @d);

CREATE TABLE hecho_matricula(
    id INT AUTO_INCREMENT PRIMARY KEY, cat_periodo INT, codigo_unico VARCHAR(255), mrun INT,
    anio_ing_carr_ori INT, cod_inst INT, valor_matricula INT, valor_arancel INT
);

INSERT INTO hecho_matricula (cat_periodo, codigo_unico, mrun, anio_ing_carr_ori, cod_inst, valor_matricula, valor_arancel)
(SELECT cat_periodo, codigo_unico, mrun, anio_ing_carr_ori, cod_inst, valor_matricula, valor_arancel FROM matricula_2025 LIMIT 3333)
UNION ALL
(SELECT cat_periodo, codigo_unico, mrun, anio_ing_carr_ori, cod_inst, valor_matricula, valor_arancel FROM matricula_2024 LIMIT 3333)
UNION ALL
(SELECT cat_periodo, codigo_unico, mrun, anio_ing_carr_ori, cod_inst, valor_matricula, valor_arancel FROM matricula_2023 LIMIT 3333);

CREATE TABLE hecho_titulacion(
    id INT AUTO_INCREMENT PRIMARY KEY, cat_periodo INT, codigo_unico VARCHAR(255), mrun INT,
    anio_ing_carr_ori INT, cod_inst INT, fecha_obtencion_titulo INT,
    nombre_titulo_obtenido VARCHAR(255), nombre_grado_obtenido VARCHAR(255)
);

INSERT INTO hecho_titulacion (cat_periodo, codigo_unico, mrun, anio_ing_carr_ori, cod_inst, fecha_obtencion_titulo, nombre_titulo_obtenido, nombre_grado_obtenido)
(SELECT cat_periodo, codigo_unico, mrun, anio_ing_carr_ori, cod_inst, fecha_obtencion_titulo, nombre_titulo_obtenido, nombre_grado_obtenido FROM titulacion_2024 LIMIT 5000)
UNION ALL
(SELECT cat_periodo, codigo_unico, mrun, anio_ing_carr_ori, cod_inst, fecha_obtencion_titulo, nombre_titulo_obtenido, nombre_grado_obtenido FROM titulacion_2023 LIMIT 5000);

DROP TABLE titulacion_2023;
DROP TABLE titulacion_2024;
DROP TABLE matricula_2023;
DROP TABLE matricula_2024;
DROP TABLE matricula_2025;