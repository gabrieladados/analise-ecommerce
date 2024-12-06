-- Análise do faturamento 2023

SELECT 
  FORMAT_DATE('%Y-%m', o.created_at) AS mes,
  ROUND(SUM(o.num_of_item*oi.sale_price),2) AS faturamento
FROM bigquery-public-data.thelook_ecommerce.orders AS o
JOIN bigquery-public-data.thelook_ecommerce.order_items AS oi  
ON o.order_id = oi.order_id
WHERE oi.status NOT IN ('Cancelled', 'Returned') AND FORMAT_DATE('%Y-%m', o.created_at) BETWEEN '2023-01' AND '2023-03'
GROUP BY mes
ORDER BY mes;

-- Análise do faturamento 2024
SELECT 
  FORMAT_DATE('%Y-%m', o.created_at) AS mes,
  ROUND(SUM(o.num_of_item*oi.sale_price),2) AS faturamento
FROM bigquery-public-data.thelook_ecommerce.orders AS o
JOIN bigquery-public-data.thelook_ecommerce.order_items AS oi  
ON o.order_id = oi.order_id
WHERE oi.status NOT IN ('Cancelled', 'Returned') AND FORMAT_DATE('%Y-%m', o.created_at) BETWEEN '2024-01' AND '2024-03'
GROUP BY mes
ORDER BY mes;

-- Análise do Ticket Médico

SELECT 
  FORMAT_DATE('%Y-%m', o.created_at) AS mes,
  ROUND(SUM(o.num_of_item*oi.sale_price) / COUNT(o.order_id),2) AS ticket_medio
FROM bigquery-public-data.thelook_ecommerce.orders AS o
JOIN bigquery-public-data.thelook_ecommerce.order_items AS oi 
ON o.order_id = oi.order_id
WHERE oi.status NOT IN ('Cancelled', 'Returned') 
GROUP BY mes
ORDER BY mes;

-- Marcas com maior faturamento

SELECT 
  p.brand,
  ROUND(SUM(o.num_of_item * oi.sale_price),2) AS faturamento
FROM bigquery-public-data.thelook_ecommerce.order_items AS oi
JOIN bigquery-public-data.thelook_ecommerce.orders AS o
ON oi.order_id = o.order_id
JOIN bigquery-public-data.thelook_ecommerce.products AS p
ON oi.product_id = p.id
WHERE oi.status NOT IN ('Cancelled', 'Returned')
GROUP BY p.brand
ORDER BY faturamento DESC;

--Marcas com maior quantidade de itens vendidos

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

--Categorias que geram maior faturamento.

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

--Categorias com maior número de itens vendidos

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

--Marcas com mais produtos cancelados e devolvidos

SELECT 
  p.brand,
  SUM(CASE WHEN oi.status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelado,
  SUM(CASE WHEN oi.status = 'Returned' THEN 1 ELSE 0 END) AS devolvido
FROM bigquery-public-data.thelook_ecommerce.order_items AS oi
JOIN bigquery-public-data.thelook_ecommerce.products AS p
ON oi.product_id = p.id
GROUP BY p.brand
ORDER BY cancelado DESC;


--Categorias com mais produtos cancelados ou devolvidos

SELECT 
  p.category,
  SUM(CASE WHEN oi.status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelado,
  SUM(CASE WHEN oi.status = 'Returned' THEN 1 ELSE 0 END) AS devolvido
FROM bigquery-public-data.thelook_ecommerce.order_items AS oi
JOIN bigquery-public-data.thelook_ecommerce.products AS p
ON oi.product_id = p.id
GROUP BY p.category
ORDER BY cancelado DESC;

-- Taxa de Conversão de Vendas Geral

SELECT 
  ROUND((COUNT(DISTINCT o.order_id) / COUNT(DISTINCT e.id))*100,2) AS taxa_conversao
FROM bigquery-public-data.thelook_ecommerce.orders AS o
JOIN bigquery-public-data.thelook_ecommerce.events AS e
ON o.user_id = e.user_id;

-- Taxa de Conversão de Vendas dos últimos meses

SELECT 
  ROUND((COUNT(DISTINCT o.order_id) / COUNT(DISTINCT e.id))*100,2) AS taxa_conversao,
  FORMAT_DATE('%Y-%m', o.created_at) AS mes
FROM bigquery-public-data.thelook_ecommerce.orders AS o
JOIN bigquery-public-data.thelook_ecommerce.events AS e
ON o.user_id = e.user_id
GROUP BY mes
ORDER BY mes;

-- Análise Perfil clientes por países

SELECT 
  u.country,
  COUNT(DISTINCT o.user_id) AS total_clientes
FROM bigquery-public-data.thelook_ecommerce.users AS u
JOIN bigquery-public-data.thelook_ecommerce.orders AS o
ON u.id = o.user_id
GROUP BY u.country
ORDER BY total_clientes DESC;

-- Análise Perfil clientes por gênero

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


-- Análise Perfil clientes por idade

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
  ORDER BY FaixaEtaria

-- Análise do Canal de Marketing

SELECT  
  u.traffic_source,
  COUNT(o.user_id) AS total_clientes
FROM bigquery-public-data.thelook_ecommerce.users AS u
JOIN bigquery-public-data.thelook_ecommerce.orders AS o
ON u.id = o.user_id
WHERE o.status NOT IN ('Cancelled', 'Returned')
GROUP BY u.traffic_source
ORDER BY total_clientes DESC;

-- Análise do tempo para a próxima compra

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


-- Resumo sobre os usuários

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

-- Top 10 clientes com maior total de compras

SELECT 
  RANK()OVER(ORDER BY ROUND(SUM(o.num_of_item * oi.sale_price),2) DESC) AS rank_faturamento,
  o.user_id,
  u.email,
  ROUND(SUM(o.num_of_item * oi.sale_price),2) AS faturamento
FROM bigquery-public-data.thelook_ecommerce.orders AS o
JOIN bigquery-public-data.thelook_ecommerce.order_items AS oi ON o.order_id = oi.order_id
JOIN bigquery-public-data.thelook_ecommerce.users AS u ON u.id = o.user_id
GROUP BY 2, 3
ORDER BY rank_faturamento
