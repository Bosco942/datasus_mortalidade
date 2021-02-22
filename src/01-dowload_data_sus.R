# Limpando dados ----------------------------------------------------------

rm(list = ls())

# Pacotes -----------------------------------------------------------------

library(tidyverse)
library(lubridate)
library(memoise)

# Parametros --------------------------------------------------------------

## Caminho das variáveis

path_data <- fs::dir_ls('data/datasus') %>% as.character()

nome_variavel <-  c(
  'doencas_infc_parasitas',
  'neoplasias_tumores',
  'ds_hemat_transt_imunitar',
  'do_endocrinas_nutr_metabolicas',
  'do_aparelho_circulatorio',
  'transtornos_mentais_comportamentos',
  'do_sistema_nervoso',
  'do_olho_anexos',
  'do_ouvido_apofise_mastoide',
  'do_aparelho_respiratorio',
  'do_aparelho_disgestivo',
  'do_pele_tecido_subcutaneo',
  'do_sist_osteomuscular_tec_conjunt',
  'do_aparelho_geniturinario',
  'gravidez_parto_puerperio',
  'afec_orig_period_perinatal',
  'malf_cong_deformid_anom_cromo',
  'sint_sinais_achad_anorm_ex_clin_lab',
  'causas_ext_morbidad_mortalidade'
)

# Funções -----------------------------------------------------------------

#' * Lendo função de leitura dos arquivos *

source('fcts/leitura_datasus_csv.R', echo = F)

# Importando -  Dados municipais ------------------------------------------

municipios <- readxl::read_excel(
  'data/municipios/RELATORIO_DTB_BRASIL_MUNICIPIO.xls'
)

municipios_df <- municipios %>% 
  janitor::clean_names() %>% 
  rename(
    cd_uf = uf_1,
    sigla_uf = uf_3,
    cd_ibge = codigo_municipio_completo,
    nm_municipio = nome_municipio,
    nm_uf = nome_uf
  ) %>% 
  select(cd_uf, sigla_uf, nm_uf, cd_ibge, nm_municipio) %>% 
  mutate(
    cd_ibge_incompleto = str_sub(cd_ibge, end = 6),
    .after = cd_ibge
  )


# Importando - Planilhas com os dados do SUS ------------------------------

for (i in seq_along(path_data)) {
  
  assign(
    nome_variavel[i],
    mem_leitura_datasus_csv(
      path = path_data[i], 
      nome_variavel = nome_variavel[i]
    )
  )
  
}

rm(i)

# Consolidando base de dados ----------------------------------------------

lista_objetos <-   list(
  'doencas_infc_parasitas' = doencas_infc_parasitas,
  'neoplasias_tumores' = neoplasias_tumores,
  'ds_hemat_transt_imunitar' = ds_hemat_transt_imunitar,
  'do_endocrinas_nutr_metabolicas' = do_endocrinas_nutr_metabolicas,
  'do_aparelho_circulatorio' = do_aparelho_circulatorio,
  'transtornos_mentais_comportamentos' = transtornos_mentais_comportamentos,
  'do_sistema_nervoso' = do_sistema_nervoso,
  'do_olho_anexos' = do_olho_anexos,
  'do_ouvido_apofise_mastoide' = do_ouvido_apofise_mastoide,
  'do_aparelho_respiratorio' = do_aparelho_respiratorio,
  'do_aparelho_disgestivo' = do_aparelho_disgestivo,
  'do_pele_tecido_subcutaneo' = do_pele_tecido_subcutaneo,
  'do_sist_osteomuscular_tec_conjunt' = do_sist_osteomuscular_tec_conjunt,
  'do_aparelho_geniturinario' = do_aparelho_geniturinario,
  'gravidez_parto_puerperio' = gravidez_parto_puerperio,
  'afec_orig_period_perinatal' = afec_orig_period_perinatal,
  'malf_cong_deformid_anom_cromo' = malf_cong_deformid_anom_cromo,
  'sint_sinais_achad_anorm_ex_clin_lab' = sint_sinais_achad_anorm_ex_clin_lab,
  'causas_ext_morbidad_mortalidade' = causas_ext_morbidad_mortalidade
)

base_datasus <- plyr::join_all(
  lista_objetos,
  by = c("date", "municipio"),
  type = 'full'
) %>% 
  pivot_longer(
    !c(date, municipio),
    names_to = 'variavel',
    values_to = 'valor'
  ) %>% 
  rename(cd_ibge_incompleto = municipio) %>% 
  mutate(
    valor = ifelse(is.na(valor), 0, valor),
    cd_ibge_incompleto = as.character(cd_ibge_incompleto)
  ) %>% 
  left_join(municipios_df, by = 'cd_ibge_incompleto') %>% 
  relocate(cd_uf:nm_uf, .after = date) %>%
  relocate(cd_ibge:nm_municipio, .after = cd_ibge_incompleto)

# Adicionando base na lista 

lista_objetos$base_datasus <- base_datasus

# Save Data ---------------------------------------------------------------

# Salvando em formato csv

write_csv2(base_datasus, 'out/base_datasus.csv')

# Salvando em formato xlsx

writexl::write_xlsx(
    lista_objetos,
  path = 'out/base_datasus.xlsx'
  )

# SAlvando em formato rds

write_rds(base_datasus, 'out/base_datasus.rds')
