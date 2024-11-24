# puc-previsao-multas

- Forma de adquirir os dados (query usada pra baixar os dados)
- Pré-processamento (tratamento dos dados)
- Como fazer o treinamento
- Como executar o modelo

Este repositório contém uma série de scripts e notebooks utilizados na análise dos microdados de multas de trânsito e previsões de receitas mensais. Abaixo, apresento um resumo do que cada script faz e dos desafios enfrentados ao longo do projeto.

# Scripts e Notebooks

microdados_analise.R: Código em R que analisa as porcentagens e o tempo médio, em dias, que as multas demoram para ser pagas, considerando o tipo de multa, mês e outras características. Também calcula a nova data de pagamento esperada para cada multa.

calculo_novas_receitas.R: Este script usa a nova tabela gerada por microdados_analise.R e calcula uma tabela de receitas mensais baseada nos dados ajustados.

r_microdados_analise.ipynb: Versão em Python do script microdados_analise.R.

r_calculo_novas_receitas.ipynb: Versão em Python do script calculo_novas_receitas.R.

predict.ipynb: O código principal em Python que treina e executa os modelos de previsão.

Os dados foram obtidos no Google Cloud Console, na pasta rj-smtr/transito/receita_autuacao. A query utilizada para obter a base foi uma consulta para pegar toda a base de dados disponível. O pré-processamento, treinamento e execução dos modelos estão todos no código predict.ipynb.

# Desafios e Ideias

O maior desafio do projeto foi a falta de dados precisos e consistentes. Para construir uma previsão sazonal é necessária uma quantidade considerável de dados, principalmente com um alto número de variáveis. Isso não foi possível devido a mudanças significativas na dinâmica de pagamento de multas ao longo dos anos:

Mudanças em 2019: Em 2019, houve uma alteração na política de licenciamento, que mudou a dinâmica de pagamento das multas, tornando difícil separar essas novas dinâmicas nos modelos.

Impacto da COVID-19: Em 2020, o adiamento no pagamento das multas devido à COVID-19 introduziu uma nova dinâmica, alterando os padrões normais de pagamento.

Esses efeitos comprometem a acurácia de qualquer modelo preditivo econométrico, pois introduzem um comportamento que não será mais verdadeiro.

Devido a esses problemas, nossa amostra útil foi reduzida a dados de 2019, 2022 e 2023 – cerca de 30 observações – para 15 variáveis em um modelo com sazonalidade de 12 meses, o que é insuficiente para uma análise robusta.

Inicialmente, tentamos contornar o problema da COVID-19 usando uma variável indicativa para identificar os anos afetados, mas isso se mostrou insuficiente. A COVID-19 não teve um impacto discreto, e usar dados como óbitos relacionados não se mostrou efetivo, pois não estavam diretamente correlacionados ao comportamento de pagamento das multas.

A última tentativa foi reorganizar os dados, calculando o tempo médio para pagamento de cada multa, condicional à gravidade da multa e ao tipo de recurso utilizado, para ajustar as datas de pagamento esperadas de 2020 e 2021. Infelizmente, essa abordagem não foi possível devido à inconsistência dos dados pré-tratamento, que indicava, por exemplo, possíveis duplicidades.

Modelo Escolhido

Devido às limitações de dados, o modelo escolhido foi um SARIMA(1,1,1)-(1,1,12). Este modelo é basicamente um ARMA(1,1) aplicado ao crescimento da receita, ao invés do nível absoluto, e com uma componente sazonal de 12 meses modelada como ARMA(1,1). Como esperado, o desempenho em termos de acurácia não foi bom, dado os problemas mencionados com a qualidade dos dados.
