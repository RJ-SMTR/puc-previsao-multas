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
df <- read.csv("E:\\Dropbox\\transito\\microdados\\2022\\out_dez_2022.csv")

# Converter as colunas de datas para o formato Date
df$datetime_autuacao <- as.Date(df$datetime_autuacao, format = "%Y-%m-%d")
df$data_pagamento <- as.Date(df$data_pagamento, format = "%Y-%m-%d")

# Criar uma nova coluna 'paid' que indica se a multa foi paga
df$paid <- df$valor_pago > 0

# Calcular o número de dias para pagar, se pago
df$days_to_pay <- as.numeric(df$data_pagamento - df$datetime_autuacao)

# Calcular a média dos dias para pagamento condicionada a múltiplas características onde 'paid' é TRUE
media_dias_por_caracteristicas <- df %>%
  filter(paid == TRUE, days_to_pay > 0) %>%
  group_by(status_infracao, pontuacao, especie_veiculo) %>%
  summarise(
    mean_days_to_pay = mean(days_to_pay, na.rm = TRUE),
    count = n()  # Contagem do número de observações em cada grupo
  )

# Exibir o resultado
print(media_dias_por_caracteristicas)

beep(sound = 1)

rm(list = setdiff(ls(), c("media_dias_por_caracteristicas")))
gc() 

######################################################
### Ajeitando as datas de pgto de 2020 ###############
######################################################
nova_base <- read.csv("E:\\Dropbox\\transito\\microdados\\2020\\2020-01-01_2020-06-30.csv")

# Converter as colunas de datas para o formato Date
nova_base$datetime_autuacao <- as.Date(nova_base$datetime_autuacao, format = "%Y-%m-%d")
nova_base$data_pagamento <- as.Date(nova_base$data_pagamento, format = "%Y-%m-%d")

# Realizar o left join e calcular a data estimada de pagamento
nova_base %<>%  
  left_join(media_dias_por_caracteristicas, by = c("status_infracao", "pontuacao", "especie_veiculo")) %>%
  mutate(
    data_estimada_pagamento = datetime_autuacao + days(round(mean_days_to_pay)),  # Arredondar os dias para valores inteiros
    data_est_pag = if_else(
      is.na(data_pagamento), 
      as.Date(NA),  # Manter NA se datetime_pagamento for NA
      if_else(data_estimada_pagamento < data_pagamento, 
              data_estimada_pagamento, 
              data_pagamento)
    )
  )

beep(sound = 1)

write.csv(nova_base, 'E:\\Dropbox\\transito\\microdados\\2020\\2020_1.csv')

# Remover todos os objetos, exceto 'media_dias_caracteristicas'
rm(list = setdiff(ls(), c("media_dias_por_caracteristicas")))
gc()

nova_base <- read.csv("E:\\Dropbox\\transito\\microdados\\2020\\2020-07-01_2020-12-31.csv")

# Converter as colunas de datas para o formato Date
nova_base$datetime_autuacao <- as.Date(nova_base$datetime_autuacao, format = "%Y-%m-%d")
nova_base$data_pagamento <- as.Date(nova_base$data_pagamento, format = "%Y-%m-%d")

# Realizar o left join para trazer a média de dias de pagamento para a nova base
nova_base %<>%  
  left_join(media_dias_por_caracteristicas, by = c("status_infracao", "pontuacao", "especie_veiculo")) %>%
  mutate(
    data_estimada_pagamento = datetime_autuacao + days(round(mean_days_to_pay)),  # Arredondar os dias para valores inteiros
    data_est_pag = if_else(
      is.na(data_pagamento), 
      as.Date(NA),  # Manter NA se datetime_pagamento for NA
      if_else(data_estimada_pagamento < data_pagamento, 
              data_estimada_pagamento, 
              data_pagamento)
    )
  )
write.csv(nova_base, 'E:\\Dropbox\\transito\\microdados\\2020\\2020_2.csv')
beep(sound = 1)

# Remover todos os objetos, exceto 'nova_base' e 'media_dias_caracteristicas'
rm(list = setdiff(ls(), c("media_dias_por_caracteristicas")))
gc()

######################################################
### Ajeitando as datas de pgto de 2021 ###############
######################################################
# Caminho para a pasta onde estão os arquivos CSV
pasta <- "E:\\Dropbox\\transito\\microdados\\2021"

# Listar todos os arquivos na pasta que terminam com '.csv'
arquivos_csv <- list.files(pasta, pattern = "\\.csv$", full.names = TRUE)

# Função para processar cada arquivo
processar_arquivo <- function(arquivo) {
  # Ler o arquivo CSV
  nova_base <- read.csv(arquivo)
  
  # Converter as colunas de datas para o formato Date
  nova_base$datetime_autuacao <- as.Date(nova_base$datetime_autuacao, format = "%Y-%m-%d")
  nova_base$data_pagamento <- as.Date(nova_base$data_pagamento, format = "%Y-%m-%d")
  
  # Realizar o left join para trazer a média de dias de pagamento para a nova base
  nova_base %<>%  
    left_join(media_dias_por_caracteristicas, by = c("status_infracao", "pontuacao", "especie_veiculo")) %>%
    mutate(
      data_estimada_pagamento = datetime_autuacao + days(round(mean_days_to_pay)),  # Arredondar os dias para valores inteiros
      data_est_pag = if_else(
        is.na(data_pagamento), 
        as.Date(NA),  # Manter NA se datetime_pagamento for NA
        if_else(data_estimada_pagamento < data_pagamento, 
                data_estimada_pagamento, 
                data_pagamento)
      )
    )
  
  # Gerar um nome para o novo arquivo baseado no nome original
  nome_arquivo_saida <- file.path(dirname(arquivo), paste0(basename(arquivo), "_processed.csv"))
  
  # Salvar o resultado no novo arquivo CSV
  write.csv(nova_base, nome_arquivo_saida, row.names = FALSE)
  
  # Mensagem de confirmação para o usuário
  print(paste("Arquivo processado:", nome_arquivo_saida))
  
  # Apagar o dataframe para liberar memória
  rm(nova_base)
  gc()  # Realizar a coleta de lixo para liberar memória
}

# Aplicar a função de processamento a todos os arquivos da pasta
lapply(arquivos_csv, processar_arquivo)

# Emitir um som ao final
beep(sound = 1)
