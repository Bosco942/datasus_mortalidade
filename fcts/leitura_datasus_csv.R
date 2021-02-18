
# Função para leitura dos dados do datasus --------------------------------

leitura_datasus_csv <- function(path, nome_variavel) {
  
  df <- path %>% 
    fs::dir_ls() %>% 
    map(
      .f = ~read.csv2(file = .) %>% 
        janitor::clean_names() %>%
        pivot_longer(
          !municipio,
          names_to = "date", 
          values_to = {{nome_variavel}}
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
          )
        ) %>% 
        relocate(date)
    ) %>% 
    map(
      .x = .,
      .f = ~mutate_at(.tbl = ., c({{nome_variavel}}), as.numeric) %>% 
        drop_na()
    )
  
  df <- map_df(df, ~as.data.frame(.x), .id = "id")
  
  df <- df %>% 
    mutate(
      ano = str_extract_all(id, "[[:digit:]]+"),
      date = parse_date(paste(date, ano, sep = '_'), '%b_%Y')
    ) %>% 
    select(-id, -ano) %>% 
    arrange(date) %>% 
    as_tibble()
  
  return(df)
  
}

# Script base para a função -----------------------------------------------

# ds_hemat_transt_imunitar <- path_data[3] %>%
#   fs::dir_ls() %>%
#   map(
#     .f = ~read.csv2(
#       file = .
#     ) %>%
#       janitor::clean_names() %>%
#       pivot_longer(
#         !municipio,
#         names_to = "date"
#       ) %>%
#       mutate(
#         date = recode(
#           date,
#           "abril" = "apr",
#           "agosto" = "aug",
#           "dezembro" = "dec",
#           "fevereiro" = "feb",
#           "janeiro" = "jan",
#           "julho" = "jul",
#           "junho" = "jun",
#           "maio" = "may",
#           "marco" = "mar",
#           "novembro" = "nov",
#           "outubro" = "oct",
#           "setembro" = "sep"
#         ),
#         doencas_infc_parasitas = as.numeric(
#           str_replace_all(doencas_infc_parasitas, "-", "0")
#         )
#       ) %>%
#       relocate(date)
#   )
# 
# 
# ds_hemat_transt_imunitar <- map_df(
#   ds_hemat_transt_imunitar,
#   ~as.data.frame(.x), .id = "id"
# )
# 
# ds_hemat_transt_imunitar %>%
#   mutate(
#     id = str_extract_all(id, "[[:digit:]]+")
#   ) %>% view
# 
# doencas_infc_parasitas <- ds_hemat_transt_imunitar %>%
#   mutate(
#     #id = parse_character(locale = locale(encoding = 'latin1')),
#     ano = str_extract_all(id, "[[:digit:]]+"),
#     date = parse_date(paste(date, ano, sep = '_'), '%b_%Y')
#   ) %>%
#   select(-id, -ano) %>%
#   arrange(date) %>%
#   as_tibble() %>%
#   mutate(
#     ano = lubridate::year(date),
#     mes = lubridate::month(date),
#     .after = date
#    )


