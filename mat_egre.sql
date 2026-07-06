CREATE TABLE matricula_2025{
};

CREATE TABLE matricula_2024{
};

CREATE TABLE matricula_2023{
};

CREATE TABLE titulacion_2024{
};

CREATE TABLE titulacion_2023{
};

LOAD DATA INFILE '2025/20250729_Matrícula_Ed_Superior_2025_PUBL_MRUN.csv'
INTO TABLE matricula_2025
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA INFILE '2024/20250729_Matrícula_Ed_Superior_2024_PUBL_MRUN.csv'
INTO TABLE matricula_2024
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA INFILE '2024/20250729_Matrícula_Ed_Superior_2024_PUBL_MRUN.csv'
INTO TABLE matricula_2024
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA INFILE '2023/20250729_Matrícula_Ed_Superior_2023_PUBL_MRUN.csv'
INTO TABLE matricula_2023
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA INFILE '2024/20250718_Titulados_Ed_Superior_2024_WEB.csv'
INTO TABLE titulacion_2024
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA INFILE '2023/20250718_Titulados_Ed_Superior_2023_WEB.csv'
INTO TABLE titulacion_2024
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

CREATE TABLE hecho_matricula{
    id INT,
    cat_periodo INT,
    codigo_unico VARCHAR(255),
    mrun INT,
    anio_ing_carr_ori INR,
    cod_inst INT,
    valor_matricula INT,
    valor_arancel INT
}

INSERT INTO hecho_matricula (cat_periodo, id, codigo_unico, mrun, anio_ing_carr_ori, cod_inst valor_matricula, valor_arancel)
SELECT * FROM(
    (SELECT cat_periodo, id, codigo_unico, mrun, anio_ing_carr_ori, cod_inst valor_matricula, valor_arancel
    FROM matricula_2025
    LIMIT 3333)

    UNION ALL

    (SELECT cat_periodo, id, codigo_unico, mrun, anio_ing_carr_ori, cod_inst valor_matricula, valor_arancel
    FROM matricula_2024
    LIMIT 3333)

    UNION ALL

    (SELECT cat_periodo, id, codigo_unico, mrun, anio_ing_carr_ori, cod_inst valor_matricula, valor_arancel
    FROM matricula_2023
    LIMIT 3333)
)

CREATE TABLE hecho_titulacion{
    id INT AUTO_INCREMENT,
    cat_periodo INT,
    codigo_unico VARCHAR(255),
    mrun int,
    anio_ing_carr_ori INT,
    cod_inst int,
    fecha_obtencion_titulo INT,
    nombre_titulo_obtenido VARCHAR(255),
    nombre_grado_obtenido VARCHAR(255)
}

INSERT INTO hecho_titulacion (id, cat_periodo, codigo_unico, mrun, anio_ing_carr_ori, cod_inst, fecha_obtencion_titulo, nombre_titulo_obtenido, nombre_grado_obtenido)
SELECT * FROM(
    (SELECT id, cat_periodo, codigo_unico, mrun, anio_ing_carr_ori, cod_inst, fecha_obtencion_titulo, nombre_titulo_obtenido, nombre_grado_obtenido
    FROM titulacion_2024
    LIMIT 5000)

    UNION ALL
    (SELECT id, cat_periodo, codigo_unico, mrun, anio_ing_carr_ori, cod_inst, fecha_obtencion_titulo, nombre_titulo_obtenido, nombre_grado_obtenido
    FROM titulacion_2023
    LIMIT 5000)
)