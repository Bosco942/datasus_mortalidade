
# Limpando dados ----------------------------------------------------------

rm(list = ls())

# Pacotes -----------------------------------------------------------------

library(tidyverse)

# Parametros --------------------------------------------------------------

path_data_1 <- "data/Cap.I"


leitura_datasus_csv(path = 'data/Cap.II', nome_variavel = 'neoplasias_tumores')


# Funções -----------------------------------------------------------------

source('fcts/leitura_datasus_csv.R', echo = F)

# Importando - Doenças infecciosas e parastárias --------------------------

doencas_infc_parasitas <- path_data_1 %>% 
  dir_ls() %>% 
  map(
    .f = ~read.csv2(
      file = .
    ) %>% 
      janitor::clean_names() %>%
      pivot_longer(
        !municipio,
        names_to = "date", values_to = "doencas_infc_parasitas"
      ) %>%
      mutate(
        date = recode(
          date,
          "abril" = "apr",
          "agosto" = "aug",
          "dezembro" = "dec",
          "fevereiro" = "feb",
          "janeiro" = "jan",
          "julho" = "jul",
          "junho" = "jun",
          "maio" = "may",
          "marco" = "mar",
          "novembro" = "nov",
          "outubro" = "oct",
          "setembro" = "sep"
        ),
        doencas_infc_parasitas = as.numeric(
          str_replace_all(doencas_infc_parasitas, "-", "0")
        )
      ) %>% 
      relocate(date)
  )


doencas_infc_parasitas <- map_df(
  doencas_infc_parasitas, 
  ~as.data.frame(.x), .id = "id"
  )

doencas_infc_parasitas <- doencas_infc_parasitas %>% 
  mutate(
    ano = regmatches(id, gregexpr("[[:digit:]]+", id)),
    date = parse_date(paste(date, ano, sep = '_'), '%b_%Y')
  ) %>% 
  select(-id, -ano) %>% 
  arrange(date) %>% 
  as_tibble() %>% 
  mutate(
    ano = year(date),
    mes = month(date),
    .after = date
  )

