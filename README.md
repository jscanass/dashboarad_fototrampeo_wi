# WildlifeInsights---Dashboards---IAVH_MFT

Código para reproducir un dashboard para elMes del Fototrampeo.

## Instrucciones de uso:

1. Clonar el repositorio 

```
git clone https://github.com/jscanass/dashboarad_fototrampeo_wi
```

2. Instalar el entorno

```
conda env create -f environment.yml
pip install pillow
conda activate r-dashboard-env
```

3. Descomprimir archivos de WI y dejarlos en la carpeta data/. Agregar imágenes representativas manualmente.


4. Preprocesa el archivo de WI

```
cd dashboarad_fototrampeo_wi 
python create_data_table.py
python create_sites_table.py
```

5. Agregar manualmente departamentos y una fila con resultados acumulados en site.csv 

6. Correr el dashboard

```
R -e "shiny::runApp('app')"
``


Basado en https://github.com/ConservationInternational/WildlifeInsights---Dashboards---DDCT/


### Tareas pendientes:

- Revisar último preprocesamiento: Cómo agregar columnas 'threatStatus''establishmentMeans''Est_conservacion''Endemismo''Am_y_End' a data?
- Revisar último preprocesamiento: Cómo calcular "Imágenes totales"
- Incorporar tabla de deployments
- Agregar curva de rarefracción

