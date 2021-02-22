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
