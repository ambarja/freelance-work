/* Consulta y preprocesamiento de la base de datos de patron_web */
WITH DistinctCodlocal AS (
    SELECT
        lpad(cast(REPLACE(codlocal, '.', '0') AS TEXT), 6, '0') AS codlocal, -- Código con 6 cifras y reemplazar el punto por cero
        lpad(cast(codgeo AS TEXT), 6, '0') AS codgeo,     -- Código con 6 cifras
        dareacenso,
        nlat_ie AS latitud,
        nlong_ie AS longitud,
        CAST(talumno AS INTEGER) AS talumno,
        make_point(nlong_ie, nlat_ie, 4326) AS geometría   -- Crear geometría con make_point
    FROM
        padron_web
    WHERE
        codlocal IS NOT NULL AND TRIM(codlocal) != ''      -- Filtrar valores vacíos
    GROUP BY
        codlocal, dareacenso, nlat_ie, nlong_ie, talumno   -- Especificar todas las columnas no agregadas
    HAVING
        MAX(CAST(talumno AS INTEGER))                      -- Conserva el registro con la mayor cantidad de alumnos
)
SELECT *
FROM DistinctCodlocal
ORDER BY talumno DESC
LIMIT (SELECT CAST(COUNT(*) * 0.9 AS INT) FROM padron_web); -- Selecionar el percentil 10 del total de centros educativos con mayor cantidad de alumnos
