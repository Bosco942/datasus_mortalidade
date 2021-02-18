
# Limpando dados ----------------------------------------------------------

rm(list = ls())

# Pacotes -----------------------------------------------------------------

library(tidyverse)

library(lubridate)

# Parametros --------------------------------------------------------------

path_data_1 <- "data/Cap.I"

# Importando dados --------------------------------------------------------


cap.I2018 <- read_csv2(
  
  paste(
    path_data_1,
    "Cap.I - Algumas doenças infecciosas e parasitárias - 2008 - residência.csv",
    sep = "/"
  ),
  locale = locale(encoding = "latin1")
) %>%  janitor::clean_names()


# Arrumando dados ---------------------------------------------------------

cap.I2018 <- cap.I2018 %>% 
  pivot_longer(
    !municipio,
    names_to = "date", values_to = "valor"
    )  
## Recoding cap.I2018$date
cap.I2018$date[cap.I2018$date == "abril"] <- "apr"
cap.I2018$date[cap.I2018$date == "agosto"] <- "aug"
cap.I2018$date[cap.I2018$date == "dezembro"] <- "dec"
cap.I2018$date[cap.I2018$date == "fevereiro"] <- "feb"
cap.I2018$date[cap.I2018$date == "janeiro"] <- "jan"
cap.I2018$date[cap.I2018$date == "julho"] <- "jul"
cap.I2018$date[cap.I2018$date == "junho"] <- "jun"
cap.I2018$date[cap.I2018$date == "maio"] <- "may"
cap.I2018$date[cap.I2018$date == "marco"] <- "mar"
cap.I2018$date[cap.I2018$date == "novembro"] <- "nov"
cap.I2018$date[cap.I2018$date == "outubro"] <- "oct"
cap.I2018$date[cap.I2018$date == "setembro"] <- "sep"

cap.I2018 <- cap.I2018 %>% 
  mutate(
    
    date = parse_date(paste0(date, "_2018"), "%b_%Y"),
    valor = as.numeric(valor)
  )
