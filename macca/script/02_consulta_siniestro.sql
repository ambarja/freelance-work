/* Consulta y preprocesamiento de la base de datos de siniestros */
SELECT 
    latitud,
    longitud,
    make_point(longitud, latitud, 4326) AS geometría -- Crear geometría con ST_MakePoint
FROM (
    SELECT 
        coordenadas_norte_latitud AS latitud,
        coordenadas_utm_este_longitud AS longitud
    FROM 
        siniestro
) AS subquery;
