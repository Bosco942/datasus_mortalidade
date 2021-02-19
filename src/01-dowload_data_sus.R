# Limpando dados ----------------------------------------------------------

rm(list = ls())

# Pacotes -----------------------------------------------------------------

library(tidyverse)
library(lubridate)
library(memoise)

# Parametros --------------------------------------------------------------

path_data <- fs::dir_ls('data/datasus') %>% as.character()

# Funções -----------------------------------------------------------------

#' * Lendo função de leitura dos arquivos *

source('fcts/leitura_datasus_csv.R', echo = F)

#'* Criando arquivo para memorização *

my_cache_folder <- cache_filesystem(path = 'data/mem')

mem_leitura_datasus_csv <- memoise(
  f = leitura_datasus_csv,
  cache = my_cache_folder
)


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


# Importando - Cap.I - Doenças infecciosas e parastárias ------------------

doencas_infc_parasitas <- mem_leitura_datasus_csv(
  path = path_data[1],
  nome_variavel = 'doencas_infc_parasitas'
  )

# Importando - Cap.II - Neoplasias (tumores) ------------------------------

neoplasias_tumores <- mem_leitura_datasus_csv(
  path = path_data[2],
  nome_variavel = 'neoplasias_tumores'
)

# Importando  - Cap.III - Doenças sangue órgãos hemat e transt imu --------

ds_hemat_transt_imunitar <- mem_leitura_datasus_csv(
  path = path_data[3],
  nome_variavel = 'ds_hemat_transt_imunitar'
)

# Importando - Cap.IV - Doenças endócrinas nutricionais e metabóli --------

do_endocrinas_nutr_metabolicas <- mem_leitura_datasus_csv(
  path = path_data[4],
  nome_variavel = 'do_endocrinas_nutr_metabolicas'
)

# Importando - Cap.IX - Doenças do aparelho circulatório ------------------

do_aparelho_circulatorio <- mem_leitura_datasus_csv(
  path = path_data[5],
  nome_variavel = 'do_aparelho_circulatorio'
)

# Importando - Cap.V - Transtornos mentais e comportamentais --------------

transtornos_mentais_comportamentos <- mem_leitura_datasus_csv(
  path = path_data[6],
  nome_variavel = 'transtornos_mentais_comportamentos'
)

# Importando - Cap.VI - Doenças do sistema nervoso ------------------------

do_sistema_nervoso <- mem_leitura_datasus_csv(
  path = path_data[7],
  nome_variavel = 'do_sistema_nervoso'
)

# Importando - Cap.VII - Doenças do olho e anexos -------------------------

do_olho_anexos <- mem_leitura_datasus_csv(
  path = path_data[8],
  nome_variavel = 'do_olho_anexos'
)

# Impoortando - Cap.VIII - Doenças do ouvido e da apófise mastóide --------

do_ouvido_apofise_mastoide <- mem_leitura_datasus_csv(
  path = path_data[9],
  nome_variavel = 'do_ouvido_apofise_mastoide'
)

# Importando - Cap.X - Doenças do aparelho respiratório -------------------

do_aparelho_respiratorio <- mem_leitura_datasus_csv(
  path = path_data[10],
  nome_variavel = 'do_aparelho_respiratorio'
)

# Importando - Cap.XI - Doenças do aparelho digestivo ---------------------

do_aparelho_respiratorio <- mem_leitura_datasus_csv(
  path = path_data[11],
  nome_variavel = 'do_aparelho_respiratorio'
)

# Importando - Cap.XII - Doenças da pele e do tecido subcutâneo -----------

do_pele_tecido_subcutaneo <- mem_leitura_datasus_csv(
  path = path_data[12],
  nome_variavel = 'do_pele_tecido_subcutaneo'
)

# Importando - Cap.XIII - Doenças sist osteomuscular e tec conjunt --------

do_sist_osteomuscular_tec_conjunt <- mem_leitura_datasus_csv(
  path = path_data[13],
  nome_variavel = 'do_sist_osteomuscular_tec_conjunt'
)

# Importando - Cap.XIV - Doenças do aparelho geniturinário ----------------

do_aparelho_geniturinario <- mem_leitura_datasus_csv(
  path = path_data[14],
  nome_variavel = 'do_aparelho_geniturinario'
)

# Importando - Cap.XV - Gravidez parto e puerpério ------------------------

gravidez_parto_puerperio <- mem_leitura_datasus_csv(
  path = path_data[15],
  nome_variavel = 'gravidez_parto_puerperio'
)

# Importando - Cap.XVI - Algumas afec originadas no período perina --------

afec_orig_period_perinatal <- mem_leitura_datasus_csv(
  path = path_data[16],
  nome_variavel = 'afec_orig_period_perinatal'
)

# Importando - Cap.XVII - Malf cong deformid e anomalias cromossôm --------

malf_cong_deformid_anom_cromo <- mem_leitura_datasus_csv(
  path = path_data[17],
  nome_variavel = 'malf_cong_deformid_anom_cromo'
)

# Importando - Cap.XVIII - Sint sinais e achad anorm ex clín e lab --------

sint_sinais_achad_anorm_ex_clin_lab <- mem_leitura_datasus_csv(
  path = path_data[18],
  nome_variavel = 'sint_sinais_achad_anorm_ex_clin_lab'
)

# Importanddo - Cap.XX - Causas externas de morbidade e mortalidade -------

causas_ext_morbidad_mortalidade <- mem_leitura_datasus_csv(
  path = path_data[19],
  nome_variavel = 'causas_ext_morbidad_mortalidade'
)

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
  full_join(do_aparelho_respiratorio) %>% 
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

write_csv(base_datasus, 'out/base_datasus.csv')
write_rds(base_datasus, 'out/base_datasus.rds')


