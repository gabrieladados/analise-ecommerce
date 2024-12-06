# Análise de Dados de um E-commerce com Big Query

> Este projeto demonstra como utilizar **SQL** para analisar dados de um e-commerce fictício, **The Look**, disponível no Google BigQuery. O objetivo é responder perguntas estratégicas sobre o negócio e criar um dashboard no **Looker Studio** para monitorar os principais indicadores de desempenho.
>



## 🗂️ Base de Dados  

A base de dados utilizada é a **The Look**, um conjunto de dados públicos hospedados no Google BigQuery.  
Ela contém informações relacionadas a:  
- Clientes  
- Produtos  
- Pedidos  
- Logística  
- Eventos no site  
- Campanhas de marketing  

### 📋 Tabelas Utilizadas  
Das 7 tabelas disponíveis, 5 serão usadas nesta análise:  
1. **Users**  
2. **Products**  
3. **Orders**  
4. **Orders_Items**  
5. **Events**  

Mais informações sobre como acessar a base de dados estão disponíveis [aqui](https://console.cloud.google.com/marketplace/product/bigquery-public-data/thelook-ecommerce?project=projeto-1-405620&pli=1).


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

---

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

O ticket médio do mês de março de 2024 é de R$ 112,53.

---
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

---
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

---

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
