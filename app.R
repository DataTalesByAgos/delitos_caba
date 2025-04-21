library(shiny)
library(leaflet)
library(dplyr)
library(openxlsx)
library(readxl)
library(sf)
library(randomForest)
library(leaflet.extras2)
library(shinyWidgets)
library(bslib)
library(viridisLite)
library(purrr)
library(stringr)
library(thematic)

# ------------------------------
# Pickear theme
# ------------------------------
thematic::thematic_shiny()

theme <- bs_theme(
  version = 5,
  bootswatch = "minty",  # "flatly", "darkly"
  primary = "#007bff",
  base_font = font_google("Roboto")
)

# ------------------------------
# Cargar datos
# ------------------------------
cargar_delitos <- function(archivo) {
  read_excel(archivo, col_types = "text")
}

archivos <- list.files(path = "datos", pattern = "\\.xlsx$", full.names = TRUE)
delitos_list <- map(archivos, cargar_delitos)
delitos_all <- bind_rows(delitos_list)

# ------------------------------
# Preparar datos
# ------------------------------
delitos <- delitos_all %>%
  rename_with(tolower) %>%
  mutate(
    latitud = as.numeric(gsub(",", ".", latitud)),
    longitud = as.numeric(gsub(",", ".", longitud)),
    anio = as.integer(anio),
    franja = as.integer(franja),
    subtipo = str_trim(str_to_title(subtipo)),
    cantidad = as.numeric(gsub(",", ".", cantidad))
  ) %>%
  filter(
    !is.na(latitud),
    !is.na(longitud),
    !is.na(franja),
    !is.na(subtipo),
    between(latitud, -35, -34),
    between(longitud, -59, -58),
    subtipo %in% c("Robo Total", "Robo Automotor", "Hurto Total", "Hurto Automotor", "Lesiones Dolosas")
  ) %>%
  mutate(subtipo = factor(subtipo))

# ------------------------------
# Modelo Random Forest
# ------------------------------
modelo_rf <- randomForest(
  subtipo ~ latitud + longitud + franja,
  data = delitos,
  ntree = 100
)

# ------------------------------
# GeoJSON Caba + Comunas
# ------------------------------
perimetro_sf <- st_read("datos/perimetro.geojson", quiet = TRUE)
perimetro_sf <- st_make_valid(perimetro_sf)

comunas_sf <- st_read("datos/comunas.geojson", quiet = TRUE)
comunas_sf <- st_make_valid(comunas_sf)

caba_poligono <- st_coordinates(perimetro_sf)

# ------------------------------
# UI
# ------------------------------
ui <- fluidPage(
  theme = theme,
  titlePanel("🔍 Probabilidad de Delito en CABA"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("hora", "🕒 Seleccioná la hora del día:", min = 0, max = 23, value = 15),
      switchInput("mostrar_comunas", "🗺 Mostrar comunas", value = FALSE, onLabel = "Sí", offLabel = "No"),
      helpText("📍 Hacé clic en el mapa para elegir una ubicación."),
      width = 3
    ),
    mainPanel(
      leafletOutput("mapa", height = 500),
      br(),
      uiOutput("resultadoUI")
    )
  ),
  tags$style(HTML("
    .progress-bar { transition: width 1s ease-in-out; }
    .delito-bar { border-radius: 8px; margin-bottom: 8px; }
  "))
)

# ------------------------------
# Server
# ------------------------------
server <- function(input, output, session) {
  
  output$mapa <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      setView(lng = -58.42, lat = -34.61, zoom = 12) %>%
      addPolylines(
        lng = caba_poligono[, "X"],
        lat = caba_poligono[, "Y"],
        color = "blue",
        weight = 2
      )
  })
  
  observe({
    proxy <- leafletProxy("mapa")
    proxy %>% clearGroup("comunas")
    
    if (input$mostrar_comunas) {
      proxy %>%
        addPolygons(
          data = comunas_sf,
          fill = FALSE,
          color = "darkred",
          weight = 2,
          group = "comunas",
          label = ~paste("Comuna", comuna)
        )
    }
  })
  
  click_reactivo <- reactiveVal(NULL)
  
  observeEvent(input$mapa_click, {
    click <- input$mapa_click
    click_reactivo(click)
    
    leafletProxy("mapa") %>%
      clearMarkers() %>%
      addMarkers(lng = click$lng, lat = click$lat, popup = "Ubicación seleccionada")
  })
  
  output$resultadoUI <- renderUI({
    click <- click_reactivo()
    if (is.null(click)) {
      return(HTML("<b>⚠️ Hacé clic en el mapa para elegir una ubicación.</b>"))
    }
    
    # Verificación geográfica precisa
    punto_sf <- st_as_sf(
      data.frame(lon = click$lng, lat = click$lat),
      coords = c("lon", "lat"),
      crs = st_crs(perimetro_sf)
    )
    
    dentro <- st_within(punto_sf, perimetro_sf, sparse = FALSE)[1, 1]
    
    if (!dentro) {
      return(HTML("<b style='color:red;'>⚠️ Estás fuera de los límites oficiales de CABA.</b>"))
    }
    
    nuevo_dato <- data.frame(
      latitud = click$lat,
      longitud = click$lng,
      franja = input$hora
    )
    
    pred <- predict(modelo_rf, nuevo_dato, type = "prob")[1, ]
    pred_ordenado <- sort(pred, decreasing = TRUE)
    
    getColor <- function(p) {
      if (p >= 0.75) "#ff0000"
      else if (p >= 0.5) "#ff8000"
      else if (p >= 0.25) "#ffd000"
      else "#00c800"
    }
    
    barras <- map2(names(pred_ordenado), pred_ordenado, function(delito, prob) {
      color <- getColor(prob)
      HTML(sprintf(
        "<b>%s: %.1f%%</b>
        <div class='delito-bar' style='background-color:lightgray; height: 22px;'>
          <div class='progress-bar' style='width:%.1f%%; background-color:%s; height:100%%;'></div>
        </div>", delito, prob * 100, prob * 100, color
      ))
    })
    
    do.call(tagList, barras)
  })
}

# ------------------------------
# Lanzar App
# -----------------------------l-
shinyApp(ui, server)
