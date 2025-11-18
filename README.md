# 🍎 Apple Retail Sales Analysis

**¿Qué diferencia a una Apple Store exitosa de una que no lo es?**

Este proyecto nació de una pregunta aparentemente simple pero profunda: en un mundo donde Apple mantiene precios uniformes globalmente y productos idénticos en todas las tiendas, ¿por qué algunas tiendas venden 10 veces más que otras?

## 🔍 Metodología del Análisis

Utilizando SQL avanzado, hemos diseccionado los datos de ventas globales de Apple Store para descubrir los patrones ocultos detrás del rendimiento comercial. Nuestro enfoque investigativo se basa en **análisis comparativo** entre tiendas top y bottom performers.

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

## 🚀 Hipótesis

Comenzamos identificando los extremos de la performance:

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

**🎯 Primera Revelación:** Existe una **brecha dramática** en el rendimiento. Mientras algunas tiendas venden miles de unidades, otras apenas alcanzan las centenas.

---

**Hipótesis:** *"Las tiendas exitosas deben estar concentradas en países ricos"*

```sql
-- Mapeando la distribución geográfica del éxito
SELECT st.city, st.country, SUM(sa.quantity) AS total_sales
FROM stores st
JOIN sales sa ON st.store_id = sa.store_id
GROUP BY st.city, st.country
ORDER BY total_sales DESC;
```

**🔍 Descubrimiento Sorprendente:**
- **A nivel país:** Estados Unidos, Australia, China y Japón lideran
- **A nivel ciudad:** Dubai, Londres y París dominan el volumen total
- **PERO:** La tienda #1 individual está en **Australia**, no en Dubai

**💡 Insight Clave:** No hay correlación directa entre país-rendimiento, pero sí entre **grandes ciudades cosmopolitas** y alto volumen de ventas.

---

**Hipótesis:** *"Las tiendas con bajo rendimiento deben tener más problemas de calidad"*

```sql
-- Investigando el ratio de reclamaciones por garantía
SELECT st.store_name, COUNT(w.claim_id) AS total_claims,
       SUM(sa.quantity) AS total_sales,
       ROUND(COUNT(w.claim_id) * 100.0 / NULLIF(SUM(sa.quantity), 0), 2) AS claim_ratio_pct
FROM stores st
JOIN sales sa ON st.store_id = sa.store_id
LEFT JOIN warranty w ON sa.sale_id = w.sale_id
GROUP BY st.store_id, st.store_name
ORDER BY claim_ratio_pct DESC;
```

**❌ Hipótesis Refutada:** El porcentaje de reclamaciones es **prácticamente idéntico** en todas las tiendas (~uniforme). La calidad del servicio post-venta no es el diferenciador.

---

**Hipótesis:** *"Las tiendas exitosas venden más productos premium (+$1000)"*

```sql
-- Analizando el mix premium vs estándar
SELECT st.store_name,
       SUM(CASE WHEN p.price >= 1000 THEN sa.quantity ELSE 0 END) AS premium_quantity,
       ROUND(SUM(CASE WHEN p.price >= 1000 THEN sa.quantity ELSE 0 END) * 100.0 / 
             NULLIF(SUM(sa.quantity), 0), 2) AS premium_ratio_pct
FROM stores st
JOIN sales sa ON st.store_id = sa.store_id
JOIN products p ON sa.product_id = p.product_id
GROUP BY st.store_id, st.store_name
ORDER BY premium_ratio_pct DESC;
```

**❌ Otra Hipótesis Derribada:** Todas las tiendas mantienen prácticamente el **mismo porcentaje de productos premium**. La estrategia de precios no es el factor diferenciador.

---

**Teoría:** *"El tipo de productos vendidos debe marcar la diferencia"*

```sql
-- Comparando el mix de categorías: Top 10 vs Bottom 10
WITH top_stores AS (
  SELECT store_id FROM stores st
  JOIN sales sa ON st.store_id = sa.store_id
  GROUP BY store_id ORDER BY SUM(sa.quantity) DESC LIMIT 10
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
-- Analizando el impacto de productos 2024 en ventas 2024
WITH top_stores AS (...), bottom_stores AS (...)
SELECT p.product_name, c.category_name,
       SUM(sa.quantity) AS ventas_2024_new_products
FROM sales sa
JOIN products p ON sa.product_id = p.product_id
JOIN category c ON p.category_id = c.category_id
WHERE EXTRACT(YEAR FROM p.launch_date) = 2024
  AND EXTRACT(YEAR FROM sa.sale_date) = 2024
GROUP BY p.product_name, c.category_name
ORDER BY ventas_2024_new_products DESC;
```
---

### 🚫 **Los Mitos Que Destruimos**

Después de este exhaustivo análisis investigativo, hemos **derribado sistemáticamente** todas las hipótesis tradicionales sobre el éxito retail:

❌ **MITO 1:** *"Las tiendas exitosas están en países más ricos"*  
**REALIDAD:** Australia supera a Dubai individualmente, pero la geografía no lo explica todo

❌ **MITO 2:** *"Las mejores tiendas tienen menos reclamaciones"*  
**REALIDAD:** El ratio de garantías es prácticamente **idéntico** en todas las tiendas

❌ **MITO 3:** *"El éxito viene de vender más productos premium"*  
**REALIDAD:** Todas las tiendas mantienen el **mismo mix premium/estándar**

❌ **MITO 4:** *"Las categorías de productos marcan la diferencia"*  
**REALIDAD:** Top y bottom performers venden **exactamente los mismos productos**

❌ **MITO 5:** *"La innovación es clave - vender productos nuevos"*  
**REALIDAD:** Ambos grupos venden los **mismos lanzamientos 2024**

---

### 🔍 **La Verdad Oculta**

**La conclusión es tan simple como sorprendente:**

> Las tiendas exitosas NO venden productos diferentes, NO tienen mejor calidad de servicio, NO están necesariamente en mejores países.

### 🍎 **El Modelo de Negocio Secreto de Apple**

**Revelación Inesperada:** Los **ACCESORIOS** generan más ingresos que los propios iPhones. Apple no es solo una empresa de smartphones - es una empresa de ecosistema completo donde los "add-ons" son el verdadero motor económico.

---

### 🧩 **¿Dónde Está Realmente La Diferencia?**

Si los productos, precios y calidad son idénticos, **¿qué hace que una tienda venda 10x más que otra?**

Los datos apuntan hacia factores **externos al producto**:

🏙️ **Factores de Ubicación:**
- Densidad poblacional y tráfico peatonal
- Poder adquisitivo de la zona específica (no del país)
- Competencia local y concentración de retail

📊 **El Factor X:** La diferencia parece estar en la **capacidad de convertir tráfico en ventas**, no en qué vender, sino en **cómo vender más del mismo producto a más gente**.

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