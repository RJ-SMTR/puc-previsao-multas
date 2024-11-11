library(dplyr)
library(magrittr)
library(ggplot2)
library(lubridate)
library(gridExtra)
library(beepr)
gc()
#######################
#####   data    #######
#######################
# Definindo os anos e meses
anos <- 2020:2022
meses <- 1:12

# Criando o dataframe expandido com todas as combinações de ano e mês
df_completo <- expand.grid(mes = meses, ano = anos)
receita_atualizada <-df_completo[order(df_completo$ano, df_completo$mes), ]

# Caminho para a pasta onde estão os arquivos CSV
todas_pasta <- c("E:\\Dropbox\\transito\\microdados\\2019", 
           "E:\\Dropbox\\transito\\microdados\\2020\\corrigido",
           "E:\\Dropbox\\transito\\microdados\\2021\\corrigido")

for (i in 1:3) {
  pasta <- todas_pasta[i]
  
  # Listar todos os arquivos na pasta que terminam com '.csv'
  arquivos_csv <- list.files(pasta, pattern = "\\.csv$", full.names = TRUE)
  
  # Passar por todos os arquivos da pasta
  for (j in seq_along(arquivos_csv) ) {
    
    arquivo <- arquivos_csv[j]
    data <- read.csv(arquivo) 
    
    if (i==1) {
      
      data$data_pagamento %<>% as.Date(format = "%Y-%m-%d")
      soma <- data %>% mutate(ano = year(data_pagamento),
                              mes = month(data_pagamento)) %>%
        filter(ano %in% c(2020,2021,2022)) %>%
        select(ano, mes, valor_pago)%>%
        group_by(mes, ano) %>%
        summarise(total_valor_pago = sum(valor_pago, na.rm = TRUE)) %>%
        select(total_valor_pago, mes, ano)
      
    } else {
      
      data$data_pagamento %<>% as.Date(format = "%Y-%m-%d")
      soma <- data %>% mutate(ano = year(data_pagamento),
                              mes = month(data_pagamento)) %>%
        filter(ano %in% c(2020,2021,2022)) %>%
        select(ano, mes, valor_pago)%>%
        group_by(mes, ano) %>%
        summarise(total_valor_pago = sum(valor_pago, na.rm = TRUE)) %>%
        select(total_valor_pago, mes, ano)
    }
    
    #Adicionando ao df principal
    receita_atualizada %<>% left_join(soma, by = c('mes', 'ano'))
  }
}
beep()

receita_atualizada %<>% mutate(soma_colunas = rowSums(select(., -c(1, 2)), na.rm = TRUE)) %>%
  select(mes, ano, soma_colunas)
