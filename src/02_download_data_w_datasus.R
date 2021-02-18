
# Limpando dados ----------------------------------------------------------

rm(list = ls())
graphics.off()

# Pacotes -----------------------------------------------------------------

library(tidyverse)
library(datasus)

# Importando dados --------------------------------------------------------


teste <- sinasc_nv_uf(uf = "ce",
                      periodo = c(2011:2019),
                      coluna = "Ano do nascimento")

