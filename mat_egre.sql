-- ====================================================================
-- 1. CONFIGURACIÓN INICIAL Y LIMPIEZA
-- ====================================================================
CREATE DATABASE IF NOT EXISTS gestion;
USE gestion;

DROP TABLE IF EXISTS hecho_matricula;
DROP TABLE IF EXISTS hecho_titulacion;
DROP TABLE IF EXISTS dim_carrera;
DROP TABLE IF EXISTS dim_establecimiento;
DROP TABLE IF EXISTS dim_tiempo;

DROP TABLE IF EXISTS matricula_2025;
DROP TABLE IF EXISTS matricula_2024;
DROP TABLE IF EXISTS matricula_2023;
DROP TABLE IF EXISTS titulacion_2024;
DROP TABLE IF EXISTS titulacion_2023;

-- ====================================================================
-- 2. CREACIÓN DE TABLAS TEMPORALES PARA CARGA RAW (CSV)
-- ====================================================================
CREATE TABLE matricula_2025 (
    cat_periodo INT,
    id INT,
    codigo_unico VARCHAR(255),
    mrun INT,
    gen_alu VARCHAR(50),
    rango_edad VARCHAR(50),
    anio_ing_carr_ori INT,
    sem_ing_carr_act INT,
    tipo_inst_1 VARCHAR(255),
    tipo_inst_2 VARCHAR(255), 
    tipo_inst_3 VARCHAR(255),
    cod_inst INT,
    nomb_inst VARCHAR(255), 
    cod_sede INT,
    nomb_sede VARCHAR(255),
    cod_carrera INT,
    nomb_carrera VARCHAR(255), 
    modalidad VARCHAR(100),
    jornada VARCHAR(100),
    dur_estudio_carr INT,
    dur_proceso_tit INT, 
    dur_total_carr INT,
    region_sede VARCHAR(100),
    provincia_sede VARCHAR(100), 
    comuna_sede VARCHAR(100), 
    valor_matricula INT,
    valor_arancel INT, 
    area_conocimiento VARCHAR(255)
);
CREATE TABLE matricula_2024 LIKE matricula_2025;
CREATE TABLE matricula_2023 LIKE matricula_2025;

CREATE TABLE titulacion_2024 (
    cat_periodo INT,
    codigo_unico VARCHAR(255),
    mrun INT,
    gen_alu VARCHAR(50),
    rango_edad VARCHAR(50),
    anio_ing_carr_ori INT,
    nombre_titulo_obtenido VARCHAR(255),
    nombre_grado_obtenido VARCHAR(255), 
    fecha_obtencion_titulo INT,
    tipo_inst_1 VARCHAR(255),
    tipo_inst_2 VARCHAR(255), 
    tipo_inst_3 VARCHAR(255),
    cod_inst INT,
    nomb_inst VARCHAR(255), 
    cod_sede INT,
    nomb_sede VARCHAR(255),
    cod_carrera INT,
    nomb_carrera VARCHAR(255),
    dur_estudio_carr INT,
    dur_proceso_tit INT,
    dur_total_carr INT,
    region_sede VARCHAR(100),
    provincia_sede VARCHAR(100),
    comuna_sede VARCHAR(100), 
    jornada VARCHAR(100),
    modalidad VARCHAR(100),
    area_conocimiento VARCHAR(255)  
);
CREATE TABLE titulacion_2023 LIKE titulacion_2024;

-- ====================================================================
-- 3. EJECUCIÓN DE LA CARGA DESDE ARCHIVOS CSV
-- ====================================================================
LOAD DATA LOCAL INFILE '2025/20250729_Matrícula_Ed_Superior_2025_PUBL_MRUN.csv'
INTO TABLE matricula_2025 FIELDS TERMINATED BY ';' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE '2024/20250729_Matrícula_Ed_Superior_2024_PUBL_MRUN.csv'
INTO TABLE matricula_2024 FIELDS TERMINATED BY ';' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE '2023/20250729_Matrícula_Ed_Superior_2023_PUBL_MRUN.csv'
INTO TABLE matricula_2023 FIELDS TERMINATED BY ';' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE '2024/20250718_Titulados_Ed_Superior_2024_WEB.csv'
INTO TABLE titulacion_2024 FIELDS TERMINATED BY ';' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE '2023/20250718_Titulados_Ed_Superior_2023_WEB.csv'
INTO TABLE titulacion_2023 FIELDS TERMINATED BY ';' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;

-- ====================================================================
-- 4. CREACIÓN DE TABLAS DE DIMENSIONES (MODELO ESTRELLA)
-- ====================================================================
CREATE TABLE dim_carrera (
    id_carrera INT AUTO_INCREMENT PRIMARY KEY,
    codigo_unico VARCHAR(255),
    nomb_carrera VARCHAR(255),
    modalidad VARCHAR(100),
    jornada VARCHAR(100),
    area_conocimiento VARCHAR(255),
    dur_estudio_carr INT,
    dur_proceso_tit INT,
    dur_total_carr INT
);

CREATE TABLE dim_establecimiento (
    id_establecimiento INT AUTO_INCREMENT PRIMARY KEY,
    cod_inst INT,
    nomb_inst VARCHAR(255),
    cod_sede INT,
    nomb_sede VARCHAR(255),
    region_sede VARCHAR(100),
    provincia_sede VARCHAR(100),
    comuna_sede VARCHAR(100),
    tipo_inst_1 VARCHAR(255),
    tipo_inst_2 VARCHAR(255),
    tipo_inst_3 VARCHAR(255)
);

CREATE TABLE dim_tiempo (
    id_tiempo INT AUTO_INCREMENT PRIMARY KEY,
    cat_periodo INT,                         
    semestre VARCHAR(20)                     
);

-- ====================================================================
-- 5. POBLACIÓN DE DIMENSIONES CON ELIMINACIÓN EXPLÍCITA DE DUPLICADOS
-- ====================================================================

-- Desduplicar Carreras mediante agrupación limpia
INSERT INTO dim_carrera (codigo_unico, nomb_carrera, modalidad, jornada, area_conocimiento)
SELECT codigo_unico, nomb_carrera, modalidad, jornada, area_conocimiento 
FROM (
    (SELECT codigo_unico, nomb_carrera, modalidad, jornada, area_conocimiento, dur_estudio_carr, dur_proceso_tit, dur_total_carr FROM matricula_2025 LIMIT 3333)
    UNION ALL
    (SELECT codigo_unico, nomb_carrera, modalidad, jornada, area_conocimiento, dur_estudio_carr, dur_proceso_tit, dur_total_carr  FROM matricula_2024 LIMIT 3333)
    UNION ALL
    (SELECT codigo_unico, nomb_carrera, modalidad, jornada, area_conocimiento, dur_estudio_carr, dur_proceso_tit, dur_total_carr  FROM matricula_2023 LIMIT 3333)
    UNION ALL
    (SELECT codigo_unico, nomb_carrera, modalidad, 'No Especificado', dur_estudio_carr, dur_proceso_tit, dur_total_carr  AS jornada, area_conocimiento FROM titulacion_2024 LIMIT 5000)
    UNION ALL
    (SELECT codigo_unico, nomb_carrera, modalidad, 'No Especificado', dur_estudio_carr, dur_proceso_tit, dur_total_carr AS jornada, area_conocimiento FROM titulacion_2023 LIMIT 5000)
) AS src_carreras
WHERE codigo_unico IS NOT NULL
GROUP BY codigo_unico, nomb_carrera, modalidad, jornada, area_conocimiento, dur_estudio_carr, dur_proceso_tit, dur_total_carr ;

-- Desduplicar Establecimientos mediante agrupación limpia
INSERT INTO dim_establecimiento (cod_inst, nomb_inst, cod_sede, nomb_sede, region_sede, provincia_sede, comuna_sede, tipo_inst_1, tipo_inst_2, tipo_inst_3)
SELECT cod_inst, nomb_inst, cod_sede, nomb_sede, region_sede, provincia_sede, comuna_sede,tipo_inst_1, tipo_inst_2, tipo_inst_3 
FROM (
    (SELECT cod_inst, nomb_inst, cod_sede, nomb_sede, region_sede, provincia_sede, comuna_sede, tipo_inst_1, tipo_inst_2, tipo_inst_3 FROM matricula_2025 LIMIT 3333)
    UNION ALL
    (SELECT cod_inst, nomb_inst, cod_sede, nomb_sede, region_sede, provincia_sede, comuna_sede, tipo_inst_1, tipo_inst_2, tipo_inst_3 FROM matricula_2024 LIMIT 3333)
    UNION ALL
    (SELECT cod_inst, nomb_inst, cod_sede, nomb_sede, region_sede, provincia_sede, comuna_sede, tipo_inst_1, tipo_inst_2, tipo_inst_3 FROM matricula_2023 LIMIT 3333)
    UNION ALL
    (SELECT cod_inst, nomb_inst, cod_sede, nomb_sede, region_sede, provincia_sede, comuna_sede, tipo_inst_1, tipo_inst_2, tipo_inst_3 FROM titulacion_2024 LIMIT 5000)
    UNION ALL
    (SELECT cod_inst, nomb_inst, cod_sede, nomb_sede, region_sede, provincia_sede, comuna_sede, tipo_inst_1, tipo_inst_2, tipo_inst_3 FROM titulacion_2023 LIMIT 5000)
) AS src_establecimientos
GROUP BY cod_inst, nomb_inst, cod_sede, nomb_sede, region_sede, provincia_sede, comuna_sede, tipo_inst_1, tipo_inst_2, tipo_inst_3;

-- Desduplicar Tiempos (Jerarquía Año -> Semestre)
INSERT INTO dim_tiempo (cat_periodo, semestre)
SELECT cat_periodo, semestre 
FROM (
    (SELECT cat_periodo, 'Semestre 1' AS semestre FROM matricula_2025 LIMIT 3333)
    UNION ALL
    (SELECT cat_periodo, 'Semestre 2' AS semestre FROM matricula_2025 LIMIT 3333)
    UNION ALL
    (SELECT cat_periodo, 'Semestre 1' AS semestre FROM matricula_2024 LIMIT 3333)
    UNION ALL
    (SELECT cat_periodo, 'Semestre 2' AS semestre FROM matricula_2024 LIMIT 3333)
    UNION ALL
    (SELECT cat_periodo, 'Semestre 1' AS semestre FROM matricula_2023 LIMIT 3333)
    UNION ALL
    (SELECT cat_periodo, 'Semestre 2' AS semestre FROM matricula_2023 LIMIT 3333)
    UNION ALL
    (SELECT cat_periodo, 'Semestre 1' AS semestre FROM titulacion_2024 LIMIT 5000)
    UNION ALL
    (SELECT cat_periodo, 'Semestre 1' AS semestre FROM titulacion_2023 LIMIT 5000)
) AS src_tiempos
GROUP BY cat_periodo, semestre;

-- ====================================================================
-- 6. CREACIÓN DE TABLAS DE HECHOS 
-- ====================================================================
CREATE TABLE hecho_matricula (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_tiempo INT,
    id_carrera INT,
    id_establecimiento INT,
    mrun INT,
    gen_alu VARCHAR(50),
    rango_edad VARCHAR(50),
    anio_ing_carr_ori INT,
    valor_matricula INT,
    valor_arancel INT
);

CREATE TABLE hecho_titulacion (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_tiempo INT,
    id_carrera INT,
    id_establecimiento INT,
    mrun INT,
    gen_alu VARCHAR(50),
    rango_edad VARCHAR(50),
    anio_ing_carr_ori INT,
    fecha_obtencion_titulo INT,
    nombre_titulo_obtenido VARCHAR(255),
    nombre_grado_obtenido VARCHAR(255)
);

-- ====================================================================
-- 7. POBLACIÓN DE TABLAS DE HECHOS 
-- ====================================================================
INSERT INTO hecho_matricula (id_tiempo, id_carrera, id_establecimiento, mrun, gen_alu, rango_edad, anio_ing_carr_ori, valor_matricula, valor_arancel)
SELECT 
    t.id_tiempo, c.id_carrera, e.id_establecimiento, 
    m.mrun, m.gen_alu, m.rango_edad, m.anio_ing_carr_ori, m.valor_matricula, m.valor_arancel
FROM (
    (SELECT cat_periodo, sem_ing_carr_act, codigo_unico, cod_inst, cod_sede, mrun, gen_alu, rango_edad, anio_ing_carr_ori, valor_matricula, valor_arancel FROM matricula_2025 LIMIT 3333)
    UNION ALL
    (SELECT cat_periodo, sem_ing_carr_act, codigo_unico, cod_inst, cod_sede, mrun, gen_alu, rango_edad, anio_ing_carr_ori, valor_matricula, valor_arancel FROM matricula_2024 LIMIT 3333)
    UNION ALL
    (SELECT cat_periodo, sem_ing_carr_act, codigo_unico, cod_inst, cod_sede, mrun, gen_alu, rango_edad, anio_ing_carr_ori, valor_matricula, valor_arancel FROM matricula_2023 LIMIT 3333)
) AS m
JOIN dim_tiempo t ON m.cat_periodo = t.cat_periodo AND t.semestre = CONCAT('Semestre ', m.sem_ing_carr_act)
JOIN dim_carrera c ON m.codigo_unico = c.codigo_unico
JOIN dim_establecimiento e ON m.cod_inst = e.cod_inst AND m.cod_sede = e.cod_sede;

INSERT INTO hecho_titulacion (id_tiempo, id_carrera, id_establecimiento, mrun, gen_alu, rango_edad, anio_ing_carr_ori, fecha_obtencion_titulo, nombre_titulo_obtenido, nombre_grado_obtenido)
SELECT 
    t.id_tiempo, c.id_carrera, e.id_establecimiento, 
    tit.mrun, tit.gen_alu, tit.rango_edad, tit.anio_ing_carr_ori, tit.fecha_obtencion_titulo, tit.nombre_titulo_obtenido, tit.nombre_grado_obtenido
FROM (
    (SELECT cat_periodo, codigo_unico, cod_inst, cod_sede, mrun, gen_alu, rango_edad, anio_ing_carr_ori, fecha_obtencion_titulo, nombre_titulo_obtenido, nombre_grado_obtenido FROM titulacion_2024 LIMIT 5000)
    UNION ALL
    (SELECT cat_periodo, codigo_unico, cod_inst, cod_sede, mrun, gen_alu, rango_edad, anio_ing_carr_ori, fecha_obtencion_titulo, nombre_titulo_obtenido, nombre_grado_obtenido FROM titulacion_2023 LIMIT 5000)
) AS tit
JOIN dim_tiempo t ON tit.cat_periodo = t.cat_periodo AND t.semestre = 'Semestre 1'
JOIN dim_carrera c ON tit.codigo_unico = c.codigo_unico
JOIN dim_establecimiento e ON tit.cod_inst = e.cod_inst AND tit.cod_sede = e.cod_sede;

-- ====================================================================
-- 8. LIMPIEZA FINAL DE LAS TABLAS DE ORIGEN
-- ====================================================================
DROP TABLE matricula_2025;
DROP TABLE matricula_2024;
DROP TABLE matricula_2023;
DROP TABLE titulacion_2024;
DROP TABLE titulacion_2023;