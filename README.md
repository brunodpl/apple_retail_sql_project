# 🍎 Apple Retail Sales Analysis

> Análisis SQL de datos de ventas de tiendas Apple a nivel global

## 📊 Descripción del Proyecto

Este proyecto realiza un análisis exploratorio de datos (EDA) sobre el rendimiento de tiendas Apple retail utilizando SQL. El objetivo principal es identificar patrones de ventas, comparar tiendas de alto y bajo rendimiento, y entender los factores que contribuyen al éxito comercial.

## 🗂️ Estructura de Datos

El proyecto utiliza 5 tablas principales:

### **stores** - Tiendas Apple
| Campo | Descripción |
|-------|-------------|
| `store_id` | Identificador único de tienda |
| `store_name` | Nombre de la tienda |
| `city` | Ciudad |
| `country` | País |

### **category** - Categorías de Productos
| Campo | Descripción |
|-------|-------------|
| `category_id` | Identificador único de categoría |
| `category_name` | Nombre de la categoría |

### **products** - Productos Apple
| Campo | Descripción |
|-------|-------------|
| `product_id` | Identificador único de producto |
| `product_name` | Nombre del producto |
| `category_id` | Referencia a categoría |
| `launch_date` | Fecha de lanzamiento |
| `price` | Precio del producto |

### **sales** - Transacciones de Venta
| Campo | Descripción |
|-------|-------------|
| `sale_id` | Identificador único de venta |
| `sale_date` | Fecha de venta |
| `store_id` | Referencia a tienda |
| `product_id` | Referencia a producto |
| `quantity` | Unidades vendidas |

### **warranty** - Reclamaciones de Garantía
| Campo | Descripción |
|-------|-------------|
| `claim_id` | Identificador único de reclamación |
| `claim_date` | Fecha de reclamación |
| `sale_id` | Referencia a venta |
| `repair_status` | Estado (Paid Repaired, Warranty Void, etc.) |

## 🔍 Análisis Realizados

### 1️⃣ **Identificación de Tiendas Top y Bottom**

```sql
-- Top 10 mejores tiendas por volumen de ventas
SELECT
  st.store_id,
  st.store_name,
  st.country,
  SUM(sa.quantity) AS total_quantity_sold
FROM stores AS st
LEFT JOIN sales AS sa ON st.store_id = sa.store_id
GROUP BY st.store_id, st.store_name
ORDER BY total_quantity_sold DESC
LIMIT 10;
```

### 2️⃣ **Análisis Geográfico**

```sql
-- Distribución de ventas por ciudad y país
SELECT
  st.city,
  st.country,
  SUM(sa.quantity) AS total_sales
FROM stores st
JOIN sales sa ON st.store_id = sa.store_id
GROUP BY st.city, st.country
ORDER BY total_sales DESC;
```

**📌 Hallazgo:** Dubai, UK y Francia lideran en ventas totales, pero la mejor tienda individual está en Australia.

### 3️⃣ **Ratio de Reclamaciones de Garantía**

```sql
-- Porcentaje de reclamaciones por tienda
SELECT
  st.store_name,
  COUNT(w.claim_id) AS total_claims,
  SUM(sa.quantity) AS total_sales,
  ROUND(COUNT(w.claim_id) * 100.0 / NULLIF(SUM(sa.quantity), 0), 2) AS claim_ratio_pct
FROM stores st
JOIN sales sa ON st.store_id = sa.store_id
LEFT JOIN warranty w ON sa.sale_id = w.sale_id
GROUP BY st.store_id, st.store_name
ORDER BY claim_ratio_pct DESC;
```

**📌 Hallazgo:** El porcentaje de reclamaciones es similar en todas las tiendas (~no significativo).

### 4️⃣ **Análisis de Productos Premium**

```sql
-- Ratio de productos premium (precio >= 1000) por tienda
SELECT
  st.store_name,
  SUM(CASE WHEN p.price >= 1000 THEN sa.quantity ELSE 0 END) AS premium_quantity,
  ROUND(SUM(CASE WHEN p.price >= 1000 THEN sa.quantity ELSE 0 END) * 100.0 / 
        NULLIF(SUM(sa.quantity), 0), 2) AS premium_ratio_pct
FROM stores st
JOIN sales sa ON st.store_id = sa.store_id
JOIN products p ON sa.product_id = p.product_id
GROUP BY st.store_id, st.store_name
ORDER BY premium_ratio_pct DESC;
```

### 5️⃣ **Ventas por Categoría en Tiendas Top**

```sql
-- Análisis de categorías en top 10 tiendas
WITH top_stores AS (
  SELECT store_id 
  FROM stores st
  JOIN sales sa ON st.store_id = sa.store_id
  GROUP BY store_id
  ORDER BY SUM(sa.quantity) DESC
  LIMIT 10
)
SELECT
  c.category_name,
  SUM(sa.quantity) AS ventas_categoria_top,
  SUM(sa.quantity * p.price) AS revenue_categoria_top
FROM sales sa
JOIN products p ON sa.product_id = p.product_id
JOIN category c ON p.category_id = c.category_id
WHERE sa.store_id IN (SELECT store_id FROM top_stores)
GROUP BY c.category_name
ORDER BY revenue_categoria_top DESC;
```

**📌 Hallazgo:** Los **accesorios** generan más ingresos que los iPhones en las mejores tiendas.

### 6️⃣ **Impacto de Productos Nuevos (2024)**

```sql
-- Ventas de productos lanzados en 2024 durante 2024 (Top stores)
WITH top_stores AS (...)
SELECT
  p.product_name,
  SUM(sa.quantity) AS ventas_2024,
  SUM(sa.quantity * p.price) AS revenue_2024
FROM sales sa
JOIN products p ON sa.product_id = p.product_id
WHERE sa.store_id IN (SELECT store_id FROM top_stores)
  AND EXTRACT(YEAR FROM p.launch_date) = 2024
  AND EXTRACT(YEAR FROM sa.sale_date) = 2024
GROUP BY p.product_name
ORDER BY revenue_2024 DESC;
```

## 💡 Conclusiones Clave

✅ **No hay diferencia significativa en el tipo de productos vendidos** entre tiendas top y bottom  
✅ **El éxito no depende de la categoría o edad del producto**  
✅ **Los accesorios dominan el modelo de negocio** (más que los iPhones)  
✅ **La diferencia está en el volumen de ventas**, no en el mix de productos  

### 🎯 Factores de Éxito Potenciales:
- 📍 Ubicación estratégica (tráfico peatonal)
- 🏢 Tamaño y experiencia de la tienda
- 👥 Gestión comercial y atención al cliente
- 📈 Estrategias de marketing local

## 🛠️ Tecnologías Utilizadas

- **SQL** (PostgreSQL/MySQL compatible)
- **CSV** para datos de entrada

## 📁 Archivos del Proyecto

- `topstores_vs_lowstores_EDA.sql` - Análisis completo con queries SQL
- `stores.csv`, `products.csv`, `sales.csv`, `category.csv`, `warranty.csv` - Datasets
- `index.html` - Visualización de resultados

---

**Autor:** Bruno  
**Repositorio:** [apple_retail_sql_project](https://github.com/brunodpl/apple_retail_sql_project)