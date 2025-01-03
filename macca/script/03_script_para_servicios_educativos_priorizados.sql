--1. Crear la tabla padron_web_geo con geometría espacial 
DROP TABLE IF EXISTS padron_web_geo;
CREATE TABLE padron_web_geo AS
SELECT
    substr('000000' || REPLACE(codlocal, '.', '0'), -6, 6) AS codlocal,
    substr('000000' || codgeo, -6, 6) AS codgeo,
    dareacenso,
    CAST(nlat_ie AS REAL) AS lat,
    CAST(nlong_ie AS REAL) AS long,
    CAST(talumno AS INTEGER) AS talumno,
    ST_GeomFromText('POINT(' || nlong_ie || ' ' || nlat_ie || ')', 4326) AS geom
FROM padron_web
WHERE codlocal IS NOT NULL AND TRIM(codlocal) != ''
ORDER BY talumno ASC;

--2. Crear la tabla siniestro con geometría espacial 
DROP TABLE IF EXISTS siniestro_geo;
CREATE TABLE siniestro_geo AS
SELECT 
    ST_GeomFromText('POINT(' || CAST(coordenadas_utm_este_longitud AS REAL) || ' ' || CAST(coordenadas_norte_latitud AS REAL) || ')', 4326) AS geom,
    *
FROM siniestro;

--3. Obtener el percentil 10 de los servicios educativos con mayor cantidad de alumnos
DROP TABLE IF EXISTS padron_web_geo_percentil_10;
CREATE TABLE padron_web_geo_percentil_10 AS
WITH ordered_data AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (ORDER BY talumno DESC) AS row_num, -- Asignar número de fila en orden descendente
        COUNT(*) OVER () AS total_rows -- Total de filas en la tabla
    FROM padron_web_geo
),
percentil_10 AS (
    SELECT 
        row_num,
        total_rows,
        CEIL(0.1 * total_rows) AS cutoff_row -- Calcular el límite para el percentil 10
    FROM ordered_data
    LIMIT 1
)
SELECT *
FROM ordered_data
WHERE row_num <= (SELECT cutoff_row FROM percentil_10)
ORDER BY talumno DESC;

--4. Crear la tabla de los servicios educativos con el total de siniestro que están dentro de los 100 metros de influencia
SELECT 
    pwg.codlocal,
    pwg.codgeo,
    pwg.dareacenso,
    pwg.lat,
    pwg.long,
    pwg.talumno,
    COUNT(sg.*) AS num_siniestros
FROM 
    padron_web_geo pwg
LEFT JOIN 
    siniestro_geo sg
ON 
    ST_DWithin(
        ST_Transform(pwg.geom, 3857), -- Transformar la geometría de padron_web_geo a SRID 3857
        ST_Transform(sg.geom, 3857),  -- Transformar la geometría de siniestro_geo a SRID 3857
        100 -- Radio en metros
    )
GROUP BY 
    pwg.codlocal, pwg.codgeo, pwg.dareacenso, pwg.lat, pwg.long, pwg.talumno, pwg.geom
ORDER BY 
    num_siniestros DESC;