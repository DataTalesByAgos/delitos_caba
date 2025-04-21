# Predicción de Delitos en CABA

**Versión: 0.9.0 (Beta)**  
Una app interactiva desarrollada en **R + Shiny** que estima la probabilidad de delitos en función de la **ubicación** y la **hora del día** dentro de la Ciudad Autónoma de Buenos Aires (CABA).

---

## ¿Qué hace esta app?

Esta aplicación permite:

- 📍 Seleccionar una ubicación en un mapa interactivo.
- 🕒 Elegir una hora del día (de 0 a 23 hs).
- 📊 Ver la **probabilidad estimada** de distintos tipos de delitos en esa ubicación y horario.

Utiliza ML (**Random Forest**) entrenado con datos reales de delitos ocurridos en CABA entre **2016 y 2023**, disponibles en:  
https://data.buenosaires.gob.ar/dataset/delitos

---

## Delitos considerados

El modelo predice la probabilidad de ocurrencia de los siguientes tipos de delitos:

- Robo Automotor  
- Hurto Total  
- Hurto Automotor  
- Lesiones Dolosas *(en revisión)*  
- Robo Total

---

## ¿Cómo usar la app?

1. Ajustá la **hora** con el slider en el panel lateral.
2. Hacé clic en cualquier punto dentro del mapa de CABA.
3. Visualizá las probabilidades de delito en ese lugar y horario.
4. Activá o desactivá la capa de **comunas** para mayor contexto.
5. Si seleccionás una ubicación fuera de CABA, se mostrará un mensaje de advertencia.

---

## Interfaz moderna

La app incluye un diseño responsive y accesible gracias a:

- Tema **Minty** de [Bootswatch](https://bootswatch.com/minty/)
- Tipografía **Roboto** (Google Fonts)
- Barras de probabilidad codificadas por color:

| Riesgo        | Color    | Probabilidad      |
|---------------|----------|-------------------|
| 🔴 Alto        | Rojo     | > 75%             |
| 🟠 Medio-Alto  | Naranja  | 50% – 75%         |
| 🟡 Medio-Bajo  | Amarillo | 25% – 50%         |
| 🟢 Bajo        | Verde    | < 25%             |

---

## 🚀 Cómo ejecutar

### Requisitos
Tener instalado **R** y **RStudio**.

### Instalación de paquetes
```r
install.packages(c(
  "shiny", "leaflet", "dplyr", "randomForest", "sf", "openxlsx", 
  "readxl", "leaflet.extras2", "shinyWidgets", "bslib", 
  "viridisLite", "purrr", "stringr", "thematic"
))
```
### Estructura del proyecto
```r
📂 datos/
├── delitos_reducido.rds
├── comunas.geojson
└── perimetro.geojson
📄 app.R
📄 cleaner.R #ya esta parcialmente curado de los xlsx originales del GCBA
📄 README.md
```

### Ejecución
```r
shiny::runApp("ruta/al/proyecto")
```

📌 Créditos
Desarrollado con ❤️ en R por DataTalesByAgos.
Contribuciones, issues y sugerencias son bienvenidas. 🙌

🧠 Pendientes
- Filtrar y limpiar variables innecesarias.

- Incorporar variables como día de la semana o clima.

- Exportar versión web usando React/JS para frontend.

- Migrar el modelo y lógica a Python para facilitar despliegue.

- Corregir predicciones para Lesiones Dolosas.
