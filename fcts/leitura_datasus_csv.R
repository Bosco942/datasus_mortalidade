
# Função para leitura dos dados do datasus --------------------------------

leitura_datasus_csv <- function(
  path = "data/Cap.I", 
  nome_variavel = "doencas_infc_parasitas") {
  
  df <- path %>% 
    fs::dir_ls() %>% 
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
  
  df <- map_df(df, ~as.data.frame(.x), .id = "id")
  
  df <- df %>% 
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
  
  return(df)
  
}
