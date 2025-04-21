library(readxl)
library(dplyr)
library(purrr)
library(stringr)

# ------------------------------
# Cargar y unir archivos
# ------------------------------
cargar_delitos <- function(archivo) {
  read_excel(archivo, col_types = "text")
}

archivos <- list.files(path = "datos", pattern = "\\.xlsx$", full.names = TRUE)
delitos_list <- map(archivos, cargar_delitos)
delitos_all <- bind_rows(delitos_list)

# ------------------------------
# Procesar y filtrar columnas necesarias
# ------------------------------
delitos_peq <- delitos_all %>%
  rename_with(tolower) %>%
  mutate(
    latitud = as.numeric(gsub(",", ".", latitud)),
    longitud = as.numeric(gsub(",", ".", longitud)),
    franja = as.integer(franja),
    subtipo = str_trim(str_to_title(subtipo))
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
  select(latitud, longitud, franja, subtipo) %>%
  mutate(subtipo = factor(subtipo))

saveRDS(delitos_peq, "datos/delitos_reducido.rds")
