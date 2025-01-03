import os 
import glob
import janitor
import pandas as pd
import geopandas as gpd
# Establecer directorio de trabajo 
path_url = r'D:\2025\GitHub\freelance-work\macca'
os.chdir(path_url)
# Listado de archivos excel del directorio de trabajo
path_excel = r'data\rawdata\*.xlsx'
archivo_excel = glob.glob(path_excel)

# Nuevo nombre de los archivos
new_names = ['padron_web','siniestro']

# Lectura, procesamineto y exportación de archivos Excel en formatos adecuados
for i, file in enumerate(archivo_excel):
    print(f"Leyendo archivo: {file}")
    # Leer el archivo Excel
    df = pd.read_excel(file)
    
    # Limpieza básica con pyjanitor
    df = (
        df.clean_names()      # Convierte nombres de columnas a formato snake_case
          .remove_empty()     # Elimina filas/columnas vacías
          .dropna(how="all")  # Elimina filas completamente vacías
    )
    
    # Exportar el archivo procesado como CSV con el nuevo nombre
    output_path = f'data/processed/{new_names[i]}.csv'
    df.to_csv(output_path, index=False)
    print(f"Archivo exportado: {output_path}")