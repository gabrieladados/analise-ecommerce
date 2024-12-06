# Análise de Dados de um E-commerce com Big Query

> Este projeto demonstra como utilizar **SQL** para analisar dados de um e-commerce fictício, **The Look**, disponível no **Google BigQuery**. O objetivo é responder perguntas estratégicas sobre o negócio e fornecer insights para apoiar a tomada de decisões.
>

<br>

## 🗂️ Base de Dados  

A base de dados utilizada é a **The Look**, um conjunto de dados públicos hospedados no Google BigQuery.  
Ela contém informações relacionadas a:  
- Clientes  
- Produtos  
- Pedidos  
- Logística  
- Eventos no site  
- Campanhas de marketing
<br>

### 📋 Tabelas Utilizadas  
Das 7 tabelas disponíveis, 5 serão usadas nesta análise:  
1. **Users**  
2. **Products**  
3. **Orders**  
4. **Orders_Items**  
5. **Events**  

Mais informações sobre como acessar a base de dados estão disponíveis [aqui](https://console.cloud.google.com/marketplace/product/bigquery-public-data/thelook-ecommerce?project=projeto-1-405620&pli=1).

<br>

## 🎯 Objetivo da Análise  

Responder a **10 perguntas-chave** para a liderança do e-commerce, cobrindo faturamento, comportamento dos clientes, e eficiência de marketing.  

1. **Faturamento**: Quanto faturamos nos meses de janeiro, fevereiro e março de 2024? Como esse valor se compara ao mesmo período de 2023?  
2. **Ticket médio**: Qual é o valor médio por pedido?  
3. **Desempenho por categoria e marca**: Quais marcas e categorias de produtos vendemos mais e menos?  
4. **Devoluções e cancelamentos**: Quais são as marcas e categorias de produtos mais canceladas e devolvidas?  
5. **Taxa de conversão**: Qual é a taxa de conversão de vendas?  
6. **Perfil dos clientes**: Quem são nossos clientes? De quais países vêm os mais importantes? Qual faixa etária e gênero geram mais lucro?  
7. **Marketing**: Em que canal de marketing estamos indo bem?  
8. **Tempo entre compras**: Retorne o tempo em dias entre uma compra e outra para cada usuário. Qual usuário tem o maior tempo entre compras?  
9. **Visão geral dos usuários**: Traga informações detalhadas de todos os usuários (tendo ou não realizado compras), incluindo:  
   - ID do usuário  
   - Quantidade de compras realizadas  
   - Quantidade de itens comprados  
   - Ticket médio  
   - Quantidade de produtos distintos comprados  
   - Quantidade de criações de carrinhos  
10. **Top clientes**: Forneça uma lista com os IDs e e-mails dos 10 clientes com maior total de compras.  
---
<br>

## 📊 Análise do Faturamento  

_Pergunta: Quanto faturamos nos meses de janeiro, fevereiro e março do ano de 2024? Comparado ao ano anterior, o faturamento é baixo ou alto?_

Primeiramente, analisamos o faturamento nos meses de **janeiro, fevereiro e março de 2023**, desconsiderando pedidos cancelados ou devolvidos.  

### Consulta SQL: Faturamento 2023  
```sql
SELECT 
  FORMAT_DATE('%Y-%m', o.created_at) AS mes,
  ROUND(SUM(o.num_of_item * oi.sale_price), 2) AS faturamento
FROM bigquery-public-data.thelook_ecommerce.orders AS o
JOIN bigquery-public-data.thelook_ecommerce.order_items AS oi  
      ON o.order_id = oi.order_id
WHERE oi.status NOT IN ('Cancelled', 'Returned') 
  AND FORMAT_DATE('%Y-%m', o.created_at) BETWEEN '2023-01' AND '2023-03'
GROUP BY mes
ORDER BY mes;
```
![eco1](https://github.com/user-attachments/assets/7d1593c2-416e-412a-af0e-3715d31ded36)

Agora vamos ver como foi o faturamento nos mesmos meses do ano de 2024:

```sql
SELECT 
  FORMAT_DATE('%Y-%m', o.created_at) AS mes,
  ROUND(SUM(o.num_of_item*oi.sale_price),2) AS faturamento
FROM bigquery-public-data.thelook_ecommerce.orders AS o
JOIN bigquery-public-data.thelook_ecommerce.order_items AS oi  
    ON o.order_id = oi.order_id
WHERE oi.status NOT IN ('Cancelled', 'Returned') AND FORMAT_DATE('%Y-%m', o.created_at) BETWEEN '2024-01' AND '2024-03'
GROUP BY mes
ORDER BY mes;
```

![eco2](https://github.com/user-attachments/assets/9bf0d784-d0bb-43d9-9508-41f15eaef5a8)

Os resultados de 2024 comparado a 2023, mostram-que:

* Em janeiro, houve um aumento de R$ 466.186,57, representando um aumento de **127,90%** em relação ao mesmo mês no ano anterior.
* Em fevereiro, houve um aumento de R$ 569.989,74, representando um aumento de **158,12%**.
* Em março, houve um aumento de R$ 840.269,93, o que equivale a um aumento de **219,88%**.
  
Portanto, comparado aos meses do ano anterior, o faturamento vem se mostrando crescente.

<br>

## 🛒 Análise do Ticket Médio  

_Pergunta: Qual é o ticket médio?_

Para calcular o ticket médio, somamos o faturamento por mês e dividimos pela quantidade de compras realizadas no mesmo período. Isso nos dá uma média do valor gasto por compra.  

### Consulta SQL: Ticket Médio  
```sql
SELECT 
  FORMAT_DATE('%Y-%m', o.created_at) AS mes,
  ROUND(SUM(o.num_of_item * oi.sale_price) / COUNT(o.order_id), 2) AS ticket_medio
FROM bigquery-public-data.thelook_ecommerce.orders AS o
JOIN bigquery-public-data.thelook_ecommerce.order_items AS oi 
ON o.order_id = oi.order_id
WHERE oi.status NOT IN ('Cancelled', 'Returned') 
GROUP BY mes
ORDER BY mes;
```
![eco3](https://github.com/user-attachments/assets/c29f80c6-2746-44d1-ade0-0b307cddd91d)

O ticket médio do mês de março de 2024 é de $ 112,53.

<br>

## 🛍️ Análise dos Produtos Mais e Menos Vendidos  

_Pergunta: Quais marcas e categorias de produtos vendemos mais e menos?_

### Marcas 
Primeiramente, vamos analisar as marcas dos produtos mais vendidos por uma ótica de produtos com maior faturamento gerado:


```sql
SELECT 
  p.brand,
  ROUND(SUM(o.num_of_item * oi.sale_price), 2) AS faturamento
FROM bigquery-public-data.thelook_ecommerce.order_items AS oi
JOIN bigquery-public-data.thelook_ecommerce.orders AS o
    ON oi.order_id = o.order_id
JOIN bigquery-public-data.thelook_ecommerce.products AS p
ON oi.product_id = p.id
WHERE oi.status NOT IN ('Cancelled', 'Returned')
GROUP BY p.brand
ORDER BY faturamento DESC;
```
![eco4](https://github.com/user-attachments/assets/d7d327ad-05af-4dd1-a226-0bbaceafb501)

Agora vamos analisar por perspectiva das marcas que possuem a maior quantidade de produtos vendidos.

```sql
SELECT 
  p.brand,
  SUM(o.num_of_item) AS quantidade
FROM bigquery-public-data.thelook_ecommerce.order_items AS oi
JOIN bigquery-public-data.thelook_ecommerce.orders AS o
    ON oi.order_id = o.order_id
JOIN bigquery-public-data.thelook_ecommerce.products AS p
    ON oi.product_id = p.id
WHERE oi.status NOT IN ('Cancelled', 'Returned')
GROUP BY p.brand
ORDER BY quantidade DESC;
```
![eco5](https://github.com/user-attachments/assets/d28f18da-13b8-4b06-a596-b43ddf7437d9)

Destaque-se a marca Calvin Klein por apresentar o maior faturamento histórico da empresa e, também, ser marca em 2º lugar com o maior número de itens vendidos.

Um ponto que merece destaque são os exemplos de marcas como a Diesel, que ocupa a 2ª posição em termos de faturamento, porém fica em 10º lugar na quantidade de itens vendidos. Uma estratégia para impulsionar ainda mais o faturamento dessa marca seria adotar a venda de kits de produtos, incentivando os clientes a adquirirem mais itens de uma só vez. Dessa forma, poderíamos elevar o ticket médio.

Agora vamos analisar as marcas com menor faturamento:

![eco6](https://github.com/user-attachments/assets/f0950a7e-d0c8-4db0-931c-c191ac2a4013)

Já sobre uma perspectiva das marcas com menor quantidade de itens vendidos, temos:

![eco7](https://github.com/user-attachments/assets/43131ac0-f1e9-47b7-bd15-c8b8988fa230)

No quesito faturamento, Marshal é a marca que gera menor resultado. Já em relação à quantidade de itens vendidos, percebe-se que uma quantidade considerável de marcas com apenas um item vendido (21 marcas ao total).


### Categorias

As categorias que geram maior faturamento para a empresa são:

```sql
SELECT 
  p.category,
  ROUND(SUM(o.num_of_item * oi.sale_price),2) AS faturamento
FROM bigquery-public-data.thelook_ecommerce.order_items AS oi
JOIN bigquery-public-data.thelook_ecommerce.orders AS o
    ON oi.order_id = o.order_id
JOIN bigquery-public-data.thelook_ecommerce.products AS p
    ON oi.product_id = p.id
WHERE oi.status NOT IN ('Cancelled', 'Returned')
GROUP BY p.category
ORDER BY faturamento DESC;
```
![eco8](https://github.com/user-attachments/assets/9d650b09-9942-4741-9dbb-6d55b04d9ef8)

Já as categorias com maior número de itens vendidos são:

```sql
SELECT 
  p.category,
  SUM(o.num_of_item) AS quantidade
FROM bigquery-public-data.thelook_ecommerce.order_items AS oi
JOIN bigquery-public-data.thelook_ecommerce.orders AS o
ON oi.order_id = o.order_id
JOIN bigquery-public-data.thelook_ecommerce.products AS p
ON oi.product_id = p.id
WHERE oi.status NOT IN ('Cancelled', 'Returned')
GROUP BY p.category
ORDER BY quantidade DESC;
```

![eco9](https://github.com/user-attachments/assets/ad9fb087-4bb1-41a2-a050-dc33561e9fae)

Em termos de faturamento, a categoria de Agasalhos & Casacos se sobressai, enquanto em termos de volume de vendas, roupas íntimas lideram, apresentando o maior número de itens vendidos.

Agora, analisaremos as categorias que geram menor faturamento e vendas do número de itens.

![eco10](https://github.com/user-attachments/assets/fed7d749-c537-41bb-8a85-651dc532739a)

![eco11](https://github.com/user-attachments/assets/98c1a17c-88d3-401a-81dd-e80ce06c3124)


Nota-se que Conjuntinhos de Roupas e Macacões são as categorias que apresentam tanto o menor faturamento como também o menor número de itens vendidos.

<br>

## 🚫 Análise dos Produtos Mais Cancelados e Devolvidos  

_Pergunta:  Quais são as marcas e categorias de produtos mais canceladas e devolvidas?_ 

Inicialmente, vamos analisar quais são as marcas com maior número de produtos cancelados ou devolvidos:

```sql
SELECT 
  p.brand,
  SUM(CASE WHEN oi.status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelado,
  SUM(CASE WHEN oi.status = 'Returned' THEN 1 ELSE 0 END) AS devolvido
FROM bigquery-public-data.thelook_ecommerce.order_items AS oi
JOIN bigquery-public-data.thelook_ecommerce.products AS p
    ON oi.product_id = p.id
GROUP BY p.brand
ORDER BY cancelado DESC;
```
![eco12](https://github.com/user-attachments/assets/953e57d3-3715-4277-ba98-7478f62499f8)

Nota-se que a Allegra K e Calvin Klein se destacam tanto na quantidade de cancelados como de devolvidos.

Agora vamos analisar as categorias:

```sql
SELECT 
  p.category,
  SUM(CASE WHEN oi.status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelado,
  SUM(CASE WHEN oi.status = 'Returned' THEN 1 ELSE 0 END) AS devolvido
FROM bigquery-public-data.thelook_ecommerce.order_items AS oi
JOIN bigquery-public-data.thelook_ecommerce.products AS p
    ON oi.product_id = p.id
GROUP BY p.category
ORDER BY cancelado DESC;
```
![eco13](https://github.com/user-attachments/assets/d1763c59-dc22-40ce-8f3b-9488a86acc71)

As categorias de roupas íntimas, tops & camisetas e jeans são as categorias com maior número de produtos cancelados e devolvidos.

<br>

## 📈 Análise da Taxa de Conversão de Vendas  

_Pergunta: Qual é a taxa de conversão de vendas?_

Para calcular a taxa de conversão de vendas, vamos considerar o número total de pedidos realizados divido pelo número total de visitas realizas no site.

```sql
SELECT 
  ROUND((COUNT(DISTINCT o.order_id) / COUNT(DISTINCT e.id)) * 100, 2) AS taxa_conversao
FROM bigquery-public-data.thelook_ecommerce.orders AS o
JOIN bigquery-public-data.thelook_ecommerce.events AS e
    ON o.user_id = e.user_id;
```
![eco14](https://github.com/user-attachments/assets/59f88f8e-1f41-4ec0-9687-5154a39982d7)

Agora vamos analisar como foi a taxa de conversão dos últimos meses:

```sql
SELECT 
  ROUND((COUNT(DISTINCT o.order_id) / COUNT(DISTINCT e.id))*100,2) AS taxa_conversao,
  FORMAT_DATE('%Y-%m', o.created_at) AS mes
FROM bigquery-public-data.thelook_ecommerce.orders AS o
JOIN bigquery-public-data.thelook_ecommerce.events AS e
    ON o.user_id = e.user_id
GROUP BY mes
ORDER BY mes
```

![eco15](https://github.com/user-attachments/assets/ad65a380-3ca3-4fb4-a247-df17c7d7106e)

Analisando historicamente, a taxa de conversão do site é de 9,6%. Nos últimos meses, a taxa tem se mostrado crescente, chegando a 6,67% no mês de março de 2024.

<br>

## 👥 Análise do Perfil dos Clientes  

_Pergunta:  Quem são os nossos clientes? De qual país são os nossos clientes mais importantes? Qual grupo de gênero e idade gerou mais lucro?  

### Países  
    
```sql
SELECT 
  u.country,
  COUNT(DISTINCT o.user_id) AS total_clientes
FROM bigquery-public-data.thelook_ecommerce.users AS u
JOIN bigquery-public-data.thelook_ecommerce.orders AS o
ON u.id = o.user_id
GROUP BY u.country
ORDER BY total_clientes DESC;
````
![eco16](https://github.com/user-attachments/assets/926f9847-e33e-4cbd-9d67-24b21bd71843)

### Gênero
```sql
SELECT 
  u.gender,
  COUNT(DISTINCT o.user_id) AS total_clientes,
  ROUND(SUM(o.num_of_item * oi.sale_price),2) AS faturamento
FROM bigquery-public-data.thelook_ecommerce.users AS u
JOIN bigquery-public-data.thelook_ecommerce.orders AS o
ON u.id = o.user_id
JOIN bigquery-public-data.thelook_ecommerce.order_items AS oi
ON oi.user_id = u.id
GROUP BY u.gender
ORDER BY total_clientes DESC;
````
![eco17](https://github.com/user-attachments/assets/4c8128d3-30e1-4fcd-9e46-2f95157c8826)



### Faixa Etária 

```sql
SELECT
  CASE 
    WHEN age >= 11 AND age <= 20 THEN "11-20"
    WHEN age >=21 AND age <= 30 THEN "21-30"
    WHEN age >= 31 AND age <=40 THEN "31-40"
    WHEN age >= 41 AND age <= 50 THEN "41-50"
    WHEN age >= 51 AND age <=60 THEN "51-60"
    WHEN age >= 61 AND age<=70 THEN "61-70"
  END AS FaixaEtaria,
  COUNT(DISTINCT oi.user_id) AS total_clientes,
  ROUND(SUM(o.num_of_item * oi.sale_price),2) AS faturamento
  FROM bigquery-public-data.thelook_ecommerce.users AS u
  JOIN bigquery-public-data.thelook_ecommerce.order_items AS oi
  ON u.id = oi.user_id
  JOIN bigquery-public-data.thelook_ecommerce.orders AS o 
  ON u.id = o.user_id
  GROUP BY FaixaEtaria
  ORDER BY FaixaEtaria;
````
![eco18](https://github.com/user-attachments/assets/87ab2ceb-915d-4dcc-8560-6b7d2305a80d)

Em suma, os principais países em termos de número de clientes são: China (27.221), Estados Unidos (17.807) e Brasil (11.492). Já em relação a gênero, os resultados são bem equilibrados, sendo o gênero masculino um pouco maior em número de clientes e faturamento comparado ao gênero feminino. Por fim, no que tange à faixa etária, as que se destacam em número total de clientes e faturamento são de 21 a 30 e 31 a 40 anos.


<br>

## 📢 Análise do Canal de Marketing  

_Pergunta: Em que canal de marketing estamos indo bem?_

Para identificar qual canal de marketing está trazendo mais clientes para a loja, vamos contabilizar o número de clientes por tipo de canal de marketing utilizado.  

```sql
SELECT  
  u.traffic_source,
  COUNT(o.user_id) AS total_clientes
FROM bigquery-public-data.thelook_ecommerce.users AS u
JOIN bigquery-public-data.thelook_ecommerce.orders AS o
      ON u.id = o.user_id
WHERE o.status NOT IN ('Cancelled', 'Returned')
GROUP BY u.traffic_source
ORDER BY total_clientes DESC;
```

![eco19](https://github.com/user-attachments/assets/ea950b75-d0b2-496e-9764-ccbd14117f6f)

Os mecanismos de pesquisas sobre o e-commerce representa o principal canal de marketing na geração de clientes (65.114), seguido pelo tráfego orgânico (14.172) e o Facebook (5.568).


<br>

## ⏳ Análise do Tempo para a Próxima Compra  

_Pergunta: Retorne o tempo em dias entre uma compra e outra para cada usuário. Traga, depois, o usuário com maior tempo._ 

Para realizar esse cálculo, vamos trazer a data do pedido atual, a data do último pedido e calcular a diferença em dias entre a data atual e a última compra do usuário.  

```sql
SELECT 
  u.id,
  o.order_id,
  o.created_at AS data_pedido_atual,
  LAG(o.created_at) OVER(PARTITION BY u.id ORDER BY o.created_at) AS data_ultimo_pedido,
  TIMESTAMP_DIFF(o.created_at, LAG(o.created_at) OVER(PARTITION BY u.id ORDER BY o.created_at), day) AS dias_ultima_compra
FROM bigquery-public-data.thelook_ecommerce.users AS u
INNER JOIN bigquery-public-data.thelook_ecommerce.orders AS o 
ON u.id = o.user_id
ORDER BY dias_ultima_compra DESC;
````

![eco20](https://github.com/user-attachments/assets/952cb810-2ebc-45bf-bb9f-d35241f2a729)


<br>

## 📊 Resumo sobre os Usuários  

_Pergunta: Traga informações sobre os usuários (de todos, tendo ou não compras). Incluindo: Id do usuário, quantidade de compras realizadas, quantidade de itens comprados, ticket médio, quantidade de produtos distintos comprados e a quantidade de criações de carrinho._

Para obter essas informações, vamos combinar dados de usuários, pedidos, itens de pedido e eventos para calcular métricas chave para cada usuário.  
  
```sql
SELECT 
  u.id,
  COUNT(DISTINCT o.order_id) AS quant_compras,
  SUM(o.num_of_item) AS quant_itens,
  ROUND(SUM(o.num_of_item * oi.sale_price)/COUNT(o.order_id),2) AS ticket_medio,
  COUNT(DISTINCT p.id) AS produtos_distintos,
  COUNT(DISTINCT e.id) AS num_carrinhos
FROM bigquery-public-data.thelook_ecommerce.users AS u
LEFT JOIN bigquery-public-data.thelook_ecommerce.orders AS o ON u.id = o.user_id
LEFT JOIN bigquery-public-data.thelook_ecommerce.order_items AS oi ON oi.user_id = u.id
LEFT JOIN bigquery-public-data.thelook_ecommerce.products AS p ON oi.product_id = p.id
LEFT JOIN bigquery-public-data.thelook_ecommerce.events AS e ON e.user_id = u.id
GROUP BY u.id;
````

![eco21](https://github.com/user-attachments/assets/042f0d47-4d1e-4a96-826f-f6e59f97669a)


<br>

## 🏆 Análise do Top 10 Clientes com Maior Total de Compras  

_Pergunta:  Forneça uma lista de 10 IDs de clientes e e-mails com o maior total de compras. A equipe de marketing fornecerá um desconto._

Para identificar os 10 clientes com maior total de compras, vamos classificar os clientes com base no valor total gasto, calculando o faturamento por usuário.  

```sql
SELECT 
  RANK()OVER(ORDER BY ROUND(SUM(o.num_of_item * oi.sale_price),2) DESC) AS rank_faturamento,
  o.user_id,
  u.email,
  ROUND(SUM(o.num_of_item * oi.sale_price),2) AS faturamento
FROM bigquery-public-data.thelook_ecommerce.orders AS o
JOIN bigquery-public-data.thelook_ecommerce.order_items AS oi ON o.order_id = oi.order_id
JOIN bigquery-public-data.thelook_ecommerce.users AS u ON u.id = o.user_id
GROUP BY 2, 3
ORDER BY rank_faturamento;
````

![eco22](https://github.com/user-attachments/assets/c5c27cfa-7960-4a8f-b665-36607752fc3d)


<br>

# 💡 Principais Insights  
A partir da análise da base de dados do The Look E-commerce, os principais insights encontrados foram:

- **Faturamento em Ascensão:** Os primeiros meses de 2024 revelam um crescimento expressivo, com março registrando um aumento de **219,88%** em relação ao ano anterior.
  
- **Estabilidade do Ticket Médio:** O ticket médio em **março de 2024** mantém-se estável, não apresentando crescimento significativo nos últimos 6 meses.
  
- **Liderança da Calvin Klein:** **Calvin Klein** destaca-se como a marca com **maior faturamento** e o **segundo maior número de itens vendidos**.
  
- **Categorias em Destaque:** **Agasalhos & Casacos** lideram em **faturamento**, enquanto **roupas íntimas** são líderes em **volume de vendas**.
  
- **Categorias com Baixo Desempenho:** **Conjuntinhos de Roupas** e **Macacões** apresentam o **menor faturamento** e **número de itens vendidos**.
  
- **Problemas com Cancelamentos e Devoluções:** **Allegra K** e **Calvin Klein** enfrentam desafios com **cancelamentos e devoluções**.
  
- **Desafios nas Categorias Populares:** **Roupas íntimas, tops & camisetas e jeans** enfrentam **problemas com cancelamentos e devoluções**.
  
- **Tendência de Conversão do Site:** Historicamente, a **taxa de conversão do site** é de **9,6%**. Nos últimos meses, apresenta uma **tendência crescente**, saindo de **5,27% em janeiro de 2024** para **6,67% em março** do mesmo ano.
  
- **Demografia dos Clientes:** Os principais **países em número de clientes** são **China, Estados Unidos e Brasil**, com o **gênero masculino** liderando em **clientes e faturamento** nas faixas etárias de **21 a 30** e **31 a 40 anos**.
  
- **Canais de Marketing Eficientes:** **Mecanismos de pesquisa** são o **principal canal de marketing**, seguidos pelo **tráfego orgânico** e pelo **Facebook**.


---
<br>

# 🎯 Recomendações Estratégicas 
Diante dessas informações, segue uma lista de recomendações visando o aumento de faturamento do E-commerce e uma melhor experiência do lead com a empresa.

1. **Investimento em Marcas de Destaque:** Dada a liderança da **Calvin Klein** em faturamento e vendas, considere expandir a oferta de produtos dessa marca ou explorar **parcerias** para lançar **produtos exclusivos**.

2. **Gestão do Estoque:** Avaliar a possibilidade de diversificar o estoque, especialmente em **categorias de alto desempenho** como **Agasalhos & Casacos** e **Roupas íntimas**.

3. **Gestão de Cancelamentos e Devoluções:** Analise os motivos por trás dos **cancelamentos e devoluções**, especialmente para marcas como **Allegra K** e **Calvin Klein**, e implemente **medidas corretivas**, como melhorar as **descrições dos produtos** ou oferecer **políticas de devolução mais flexíveis**.

4. **Segmentação de Mercado e Marketing:** Segmente a campanha de **marketing** de acordo com a **demografia dos clientes**, adaptando **mensagens e ofertas** para diferentes **faixas etárias** e **regiões geográficas**.

5. **Canais de Marketing:** Aproveite os **canais de marketing comprovadamente eficazes**, como **mecanismos de pesquisa**, **tráfego orgânico** e **Facebook**. Além disso, experimente **novas estratégias**, como **marketing de influenciadores**, para ampliar o alcance da marca e atrair novos públicos.


---


## Constribuições

Muito obrigada por acompanhar meu projeto até aqui! 🎉

Contribuições são **muito bem-vindas**. Se você tem sugestões ou melhorias, fique à vontade para abrir uma **issue** ou enviar um **pull request**.

Gostou do projeto? Não esqueça de dar uma ⭐️! 


**Meus Contatos:**

💻 [LinkedIn](https://www.linkedin.com/in/gabrielasantanamorais/)  
📩 [E-mail](mailto:gabrielasmorais01@gmail.com)

**Até a próxima!** 🚀
