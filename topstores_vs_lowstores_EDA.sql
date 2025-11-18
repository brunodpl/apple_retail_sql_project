--Paises con más ventas
SELECT
  st.country,
  SUM(sa.quantity) AS total_quantity_sold
FROM stores AS st
LEFT JOIN sales AS sa ON st.store_id = sa.store_id
GROUP BY st.country
ORDER BY total_quantity_sold DESC;

--Top 10 mejores tiendas

SELECT
  st.store_id,
  st.store_name,
  st.country,
  SUM(sa.quantity) AS total_quantity_sold
FROM stores AS st
LEFT JOIN sales AS sa
  ON st.store_id = sa.store_id
GROUP BY st.store_id, st.store_name
ORDER BY total_quantity_sold DESC
LIMIT 10;

--Top 10 peores tiendas

SELECT
  st.store_id,
  st.store_name,
  st.country,
  SUM(sa.quantity) AS total_quantity_sold
FROM stores AS st
LEFT JOIN sales AS sa
  ON st.store_id = sa.store_id
GROUP BY st.store_id, st.store_name
ORDER BY total_quantity_sold ASC
LIMIT 10;

--¿Porque van bien/mal esas tiendas?

--¿Las tiendas top/bottom están en ciertas ciudades/paises?

SELECT
  st.city,
  st.country,
  SUM(sa.quantity) AS total_sales
FROM stores st
JOIN sales sa ON st.store_id = sa.store_id
GROUP BY st.city, st.country
ORDER BY total_sales DESC;

--Los paises con más ventas son United States, Australia, China, Japan, UAE
--Tenemos gran diferencia de ventas en Dubai, London y París con el resto del mundo.
--En cambio, la mejor tienda está en Australia, despues, Japón, US, y ya despues Dubai.
--Las peor está en francia, pero no hay ninguna ni de UK ni Dubai entre las peores.
--No observamos gran correlacción entre País-Rendimiento, pero si entre Ciudad-Rendimiento(Capitales y ciudades importantes venden más)

--¿Cuales tienen mas reclamaciones?

SELECT
  st.store_id,
  st.store_name,
  st.country,
  COUNT(w.claim_id) AS total_claims,
  SUM(sa.quantity) AS total_sales,
  ROUND(COUNT(w.claim_id) * 100.0 / NULLIF(SUM(sa.quantity), 0), 2) AS claim_ratio_pct
FROM stores st
JOIN sales sa ON st.store_id = sa.store_id
LEFT JOIN warranty w ON sa.sale_id = w.sale_id
GROUP BY st.store_id, st.store_name
ORDER BY claim_ratio_pct DESC;
--Tenemos porcentaje de devolución muy similar en todas las tiendas, no es significativo

--¿Cuales venden productos premium a mayor escala?

SELECT
  st.store_id,
  st.store_name,
  st.country,
  SUM(CASE WHEN p.price >= 1000 THEN sa.quantity ELSE 0 END) AS premium_quantity,
  SUM(sa.quantity) AS total_quantity,
  ROUND(SUM(CASE WHEN p.price >= 1000 THEN sa.quantity ELSE 0 END) * 100.0 / NULLIF(SUM(sa.quantity), 0), 2) AS premium_ratio_pct
FROM stores st
JOIN sales sa ON st.store_id = sa.store_id
JOIN products p ON sa.product_id = p.product_id
GROUP BY st.store_id, st.store_name
ORDER BY premium_ratio_pct DESC;

--Mas o menos todas venden el mismo porcentage de productos premium


--HAGAMOS UN ESTUDIO POR CATEGORÍA

--TOP 10 MEJORES TIENDAS
WITH store_sales AS (
  SELECT
    st.store_id,
    SUM(sa.quantity) AS total_quantity
  FROM stores st
  JOIN sales sa ON st.store_id = sa.store_id
  GROUP BY st.store_id
),
top_stores AS (
  SELECT store_id FROM store_sales ORDER BY total_quantity DESC LIMIT 10
)
SELECT
  c.category_name,
  SUM(sa.quantity) AS ventas_categoria_top,
  SUM(sa.quantity * p.price) AS suma_precio_categoria_top
FROM stores st
JOIN sales sa ON st.store_id = sa.store_id
JOIN products p ON sa.product_id = p.product_id
JOIN category c ON p.category_id = c.category_id
WHERE st.store_id IN (SELECT store_id FROM top_stores)
GROUP BY c.category_name
ORDER BY ventas_categoria_top DESC;
--Podemos observar que donde más se gana es con los accesorios, en las mejores tiendas

--TOP 10 PEORES TIENDAS

WITH store_sales AS (
  SELECT
    st.store_id,
    SUM(sa.quantity) AS total_quantity
  FROM stores st
  JOIN sales sa ON st.store_id = sa.store_id
  GROUP BY st.store_id
),
bottom_stores AS (
  SELECT store_id FROM store_sales ORDER BY total_quantity ASC LIMIT 10
)
SELECT
  c.category_name,
  SUM(sa.quantity) AS ventas_categoria_bottom,
  SUM(sa.quantity * p.price) AS suma_precio_categoria_bottom
FROM stores st
JOIN sales sa ON st.store_id = sa.store_id
JOIN products p ON sa.product_id = p.product_id
JOIN category c ON p.category_id = c.category_id
WHERE st.store_id IN (SELECT store_id FROM bottom_stores)
GROUP BY c.category_name
ORDER BY ventas_categoria_bottom DESC;
--Tampoco es significativo el tipo de producto, la peores tiendas tienden a vender los mismos tipos de productos
--Podemos observar un modelo de negocio generalizado con la venta de accesorios de Apple, superior a los telefonos

--COMPROVEMOS LAS FECHAS DE LANZAMIENTO
SELECT
  product_id,
  product_name,
  launch_date
FROM products
ORDER BY launch_date DESC
LIMIT 5;
--¿Las peores tiendas venden principalmente productos antiguos o rezagados?
WITH store_sales AS (
  SELECT
    st.store_id,
    SUM(sa.quantity) AS total_quantity
  FROM stores st
  JOIN sales sa ON st.store_id = sa.store_id
  GROUP BY st.store_id
),
bottom_stores AS (
  SELECT store_id FROM store_sales ORDER BY total_quantity ASC LIMIT 10
)
SELECT
  p.product_name,
  c.category_name,
  p.launch_date,
  SUM(sa.quantity) AS ventas_producto_bottom,
  SUM(sa.quantity * p.price) AS suma_precio_producto_bottom
FROM stores st
JOIN sales sa ON st.store_id = sa.store_id
JOIN products p ON sa.product_id = p.product_id
JOIN category c ON p.category_id = c.category_id
WHERE st.store_id IN (SELECT store_id FROM bottom_stores)
GROUP BY p.product_name, c.category_name, p.launch_date
ORDER BY ventas_producto_bottom DESC;
--Las peores tiendas suelen vender mas productos antiguos
WITH store_sales AS (
  SELECT
    st.store_id,
    SUM(sa.quantity) AS total_quantity
  FROM stores st
  JOIN sales sa ON st.store_id = sa.store_id
  GROUP BY st.store_id
),
top_stores AS (
  SELECT store_id FROM store_sales ORDER BY total_quantity DESC LIMIT 10
)
SELECT
  p.product_name,
  c.category_name,
  p.launch_date,
  SUM(sa.quantity) AS ventas_producto_top,
  SUM(sa.quantity * p.price) AS suma_precio_producto_top
FROM stores st
JOIN sales sa ON st.store_id = sa.store_id
JOIN products p ON sa.product_id = p.product_id
JOIN category c ON p.category_id = c.category_id
WHERE st.store_id IN (SELECT store_id FROM top_stores)
GROUP BY p.product_name, c.category_name, p.launch_date
ORDER BY ventas_producto_top DESC;
--Las mejores tiendas suelen vender productos antiguos, pero tienen muchas ventas de productos recién salidos

--ANALICEMOS EN PROFUNDIDAD LAS VENTAS DE PRODUCTOS DE 2024 en 2024
WITH store_sales AS (
  SELECT
    st.store_id,
    SUM(sa.quantity) AS total_quantity
  FROM stores st
  JOIN sales sa ON st.store_id = sa.store_id
  GROUP BY st.store_id
),
top_stores AS (
  SELECT store_id FROM store_sales ORDER BY total_quantity DESC LIMIT 10
)
SELECT
  p.product_name,
  c.category_name,
  SUM(sa.quantity) AS ventas_top_2024,
  SUM(sa.quantity * p.price) AS total_precio_top_2024
FROM stores st
JOIN sales sa ON st.store_id = sa.store_id
JOIN products p ON sa.product_id = p.product_id
JOIN category c ON p.category_id = c.category_id
WHERE st.store_id IN (SELECT store_id FROM top_stores)
  AND EXTRACT(YEAR FROM p.launch_date) = 2024
  AND EXTRACT(YEAR FROM sa.sale_date) = 2024
GROUP BY p.product_name, c.category_name
ORDER BY total_precio_top_2024 DESC;

--AHORA LAS PEORES TIENDAS
WITH store_sales AS (
  SELECT
    st.store_id,
    SUM(sa.quantity) AS total_quantity
  FROM stores st
  JOIN sales sa ON st.store_id = sa.store_id
  GROUP BY st.store_id
),
bottom_stores AS (
  SELECT store_id FROM store_sales ORDER BY total_quantity ASC LIMIT 10
)
SELECT
  p.product_name,
  c.category_name,
  SUM(sa.quantity) AS ventas_bottom_2024,
  SUM(sa.quantity * p.price) AS total_precio_bottom_2024
FROM stores st
JOIN sales sa ON st.store_id = sa.store_id
JOIN products p ON sa.product_id = p.product_id
JOIN category c ON p.category_id = c.category_id
WHERE st.store_id IN (SELECT store_id FROM bottom_stores)
  AND EXTRACT(YEAR FROM p.launch_date) = 2024
  AND EXTRACT(YEAR FROM sa.sale_date) = 2024
GROUP BY p.product_name, c.category_name
ORDER BY total_precio_bottom_2024 DESC;

--EL RESULTADO EN PRACTICAMENTE EL MISMO, SIMPLEMENTE VENDEN MAS UNIDADES LAS TOP

--El patrón de productos y categorías vendidos durante 2024 es prácticamente el mismo en tiendas top y bottom.

--La diferencia está en las cantidad de unidades vendidas: las tiendas top venden muchas más unidades, pero no parece que la clave esté en vender productos diferentes o exclusivos.

--Implicaciones y próximos pasos
--Esto sugiere que el éxito de las tiendas top no reside en el tipo de producto, sino probablemente en otros factores como:

--Mayor tráfico o zona/ubicación más atractiva (ciudad, país)

--Mejor gestión comercial o logística

--Promociones y captación de clientes

--Tamaño físico de la tienda, horario, personal, experiencia de compra, etc.
