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

base_datasus <- doencas_infc_parasitas %>% 
  full_join(neoplasias_tumores) %>% 
  full_join(ds_hemat_transt_imunitar) %>% 
  full_join(do_endocrinas_nutr_metabolicas) %>% 
  full_join(do_aparelho_circulatorio) %>% 
  full_join(transtornos_mentais_comportamentos) %>% 
  full_join(do_sistema_nervoso) %>% 
  full_join(do_olho_anexos) %>% 
  full_join(do_ouvido_apofise_mastoide) %>% 
  full_join(do_aparelho_respiratorio) %>% 
  full_join(do_aparelho_disgestivo) %>% 
  full_join(do_pele_tecido_subcutaneo) %>% 
  full_join(do_sist_osteomuscular_tec_conjunt) %>% 
  full_join(do_aparelho_geniturinario) %>% 
  full_join(gravidez_parto_puerperio) %>% 
  full_join(afec_orig_period_perinatal) %>% 
  full_join(malf_cong_deformid_anom_cromo) %>% 
  full_join(sint_sinais_achad_anorm_ex_clin_lab) %>% 
  full_join(causas_ext_morbidad_mortalidade) %>% 
  pivot_longer(
    !c(date, municipio),
    names_to = 'variavel',
    values_to = 'valor'
  ) %>% 
  rename(cd_ibge_incompleto = municipio) %>% 
  mutate(
    valor = ifelse(is.na(valor), 0, valor),
    cd_ibge_incompleto = as.character(cd_ibge_incompleto)
  )

base_datasus <- base_datasus %>% 
  left_join(municipios_df, by = 'cd_ibge_incompleto') %>% 
  relocate(cd_uf:nm_uf, .after = date) %>%
  relocate(cd_ibge:nm_municipio, .after = cd_ibge_incompleto)

# Save Data ---------------------------------------------------------------

write_csv2(base_datasus, 'out/base_datasus.csv')
write_rds(base_datasus, 'out/base_datasus.rds')


