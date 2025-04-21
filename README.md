# Predicción de Delitos en CABA
Una app interactiva en Shiny que estima la probabilidad de delitos según ubicación y hora en la Ciudad Autónoma de Buenos Aires (CABA).

# ¿Qué hace esta app?
Esta aplicación permite:

📍 Seleccionar una ubicación en el mapa.

🕒 Elegir una hora del día.

📊 Ver la probabilidad estimada de distintos tipos de delitos en ese punto y horario.

Usa un modelo de machine learning (Random Forest) entrenado con datos reales de delitos ocurridos en CABA entre el 2016 al 2023 (https://data.buenosaires.gob.ar/dataset/delitos).

# ¿Qué delitos predice?
Los siguientes tipos de delitos son considerados por el modelo:

- Robo Automotor

- Hurto Total

- Hurto Automotor

- Lesiones Dolosas (falta fixear)

- Robo Total

# 🗺️ ¿Cómo usar la app?
Elegí una hora con el slider de la izquierda.

Hacé clic en cualquier punto dentro del mapa de CABA.

La app mostrará las probabilidades de los distintos tipos de delito en esa ubicación y horario.

Podés activar o desactivar la visualización de comunas.

Si hacés clic fuera de los límites de CABA, la app te avisará con un mensaje.

# 🎨 Interfaz
La app tiene un diseño moderno y responsive gracias a:

Tema Minty (Bootswatch) con bslib

Tipografía Roboto desde Google Fonts

Barras de probabilidad codificadas por color:

🔴 Alto riesgo (>75%)

🟠 Medio-alto (50–75%)

🟡 Medio-bajo (25–50%)

🟢 Bajo (<25%)

#🚀 Cómo ejecutar
## En R-studio:
```bash
install.packages(c("shiny", "leaflet", "dplyr", "randomForest", "sf", "openxlsx", 
                   "readxl", "leaflet.extras2", "shinyWidgets", "bslib", 
                   "viridisLite", "purrr", "stringr", "thematic"))
```
# Correr la app
shiny::runApp("ruta/al/proyecto")
Asegurate de que los archivos .xlsx y .geojson estén dentro del directorio datos/.

#📁 Estructura de archivos
```bash
📂 datos/
├── ..._2016.xlsx
... etc.
├── ..._.xlsx
├── delitos_2023.xlsx
├── comunas.geojson
└── perimetro.geojson
```

📌 Créditos
Desarrollado con ❤️ en R por DataTalesByAgos.

Pendientes:
- Descartar datos sin usar
-  Lograr renderizado en web, ir por react/js
-  Agregar variables segun dias para mejorar la precision
-  Pasarlo a python para despliegue web
