# WildlifeInsights---Dashboards---IAVH_MFT

Código para reproducir un dashboard para el mes del Fototrampeo.

Para ver la aplicación ingrese a https://jcanas.shinyapps.io/DCT2023/

## Reproducir la aplicación localmente y utilizar nuevos datos:

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

3. Descomprimir archivos de WI y dejarlos en la carpeta data/. Agregar imágenes representativas manualmente dejando el mismo nombre que la columna site_name del archivo sites.csv


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
```


7.  (Opcional) Una forma de desplegar la aplicación es usando [shynnyaps](https://www.shinyapps.io/). Para eso instale la dependencia y cree una cuenta. 

```
conda install conda-forge::r-rsconnec
R -e "install.packages('rsconnect')"   
```

A sus credenciales sobre el archivo deploy y ejecute

```
Rscript deploy.R  
```


### Tareas pendientes:

- Revisar último preprocesamiento del proyecto (o [este](https://jaap.shinyapps.io/IaVH_MFT/
)) original: Cómo agregar columnas 'threatStatus''establishmentMeans''Est_conservacion''Endemismo''Am_y_End' a data?
- Revisar último preprocesamiento: Cómo calcular "Imágenes totales"
- Incorporar tabla de deployments
- Agregar curva de rarefracción



Créditos a los autores iniciales del proyecto en https://github.com/ConservationInternational/WildlifeInsights---Dashboards---DDCT/