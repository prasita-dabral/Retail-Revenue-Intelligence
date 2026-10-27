/* ============================================================
   KPI 3: PRODUCT & CATEGORY PERFORMANCE
   ============================================================

   GOAL
   ----
   Analyze product and category performance to understand which
   parts of the product portfolio drive revenue and sales volume.

   BUSINESS QUESTIONS
   ------------------
   1. Which products generate the most revenue?
   2. Which products sell the most units?
   3. Which products generate the highest revenue per unit?
   4. Which categories contain the strongest-performing products?
   5. Are high-revenue products also high-volume products?

   KEY METRICS
   -----------
   - Product Revenue
   - Product Units Sold
   - Revenue per Unit
   - Product Category
   - Transaction Activity

   ANALYTICAL APPROACH
   -------------------
   - Use fact_sales as the primary sales source
   - Join dim_product using product_key
   - Aggregate sales at the product level
   - Compare revenue and sales volume
   - Calculate revenue per unit
   - Rank products based on different performance measures

   BUSINESS PURPOSE
   ----------------
   Identify the products driving retail performance and provide
   the product-level foundation for deeper category and
   decline/recovery analysis.
*/


/* ============================================================
   QUERY 1: TOP PRODUCTS BY REVENUE
   ============================================================

   Business Question:
   Which products generate the most revenue?

   Purpose:
   Identify the highest-value products in the portfolio.
*/

SELECT
    p.product_key,
    p.sku,
    p.sku_category,
    SUM(f.quantity) AS total_units_sold,
    ROUND(SUM(f.sales_amount), 2) AS total_revenue
FROM fact_sales f
JOIN dim_product p
    ON f.product_key = p.product_key
GROUP BY
    p.product_key,
    p.sku,
    p.sku_category
ORDER BY
    total_revenue DESC
LIMIT 10;


/* ============================================================
   QUERY 2: TOP PRODUCTS BY UNITS SOLD
   ============================================================

   Business Question:
   Which products sell the most units?

   Purpose:
   Identify the highest-volume products and compare them
   with the highest-revenue products.
*/

SELECT
    p.product_key,
    p.sku,
    p.sku_category,
    SUM(f.quantity) AS total_units_sold,
    ROUND(SUM(f.sales_amount), 2) AS total_revenue
FROM fact_sales f
JOIN dim_product p
    ON f.product_key = p.product_key
GROUP BY
    p.product_key,
    p.sku,
    p.sku_category
ORDER BY
    total_units_sold DESC
LIMIT 10;


/* ============================================================
   QUERY 3: TOP PRODUCTS BY REVENUE PER UNIT
   ============================================================

   Business Question:
   Which products generate the highest revenue per unit?

   Purpose:
   Identify products with stronger monetization per unit.

   Note:
   Revenue per unit should be interpreted together with
   units sold because a product with very low volume can
   rank highly on this metric.
*/

SELECT
    p.product_key,
    p.sku,
    p.sku_category,
    SUM(f.quantity) AS total_units_sold,
    ROUND(SUM(f.sales_amount), 2) AS total_revenue,
    ROUND(
        SUM(f.sales_amount) / NULLIF(SUM(f.quantity), 0),
        2
    ) AS revenue_per_unit
FROM fact_sales f
JOIN dim_product p
    ON f.product_key = p.product_key
GROUP BY
    p.product_key,
    p.sku,
    p.sku_category
ORDER BY
    revenue_per_unit DESC
LIMIT 10;


/* ============================================================
   QUERY 4: CATEGORY PERFORMANCE FROM PRODUCT-LEVEL SALES
   ============================================================

   Business Question:
   Which categories contain the strongest product-level
   performance?

   Purpose:
   Provide a category-level view of revenue and volume while
   keeping KPI 3 connected to the product analysis.
*/

SELECT
    p.sku_category,
    COUNT(DISTINCT p.product_key) AS total_products,
    COUNT(DISTINCT f.transaction_id) AS total_transactions,
    SUM(f.quantity) AS total_units_sold,
    ROUND(SUM(f.sales_amount), 2) AS total_revenue,
    ROUND(
        SUM(f.sales_amount) / NULLIF(SUM(f.quantity), 0),
        2
    ) AS revenue_per_unit
FROM fact_sales f
JOIN dim_product p
    ON f.product_key = p.product_key
GROUP BY
    p.sku_category
ORDER BY
    total_revenue DESC;


/* ============================================================
   QUERY 5: PRODUCT PERFORMANCE WITHIN CATEGORY
   ============================================================

   Business Question:
   Which products are the major revenue contributors within
   each category?

   Purpose:
   Connect category performance to the products responsible
   for it.
*/

WITH product_performance AS (
    SELECT
        p.sku_category,
        p.product_key,
        p.sku,
        SUM(f.quantity) AS total_units_sold,
        ROUND(SUM(f.sales_amount), 2) AS total_revenue
    FROM fact_sales f
    JOIN dim_product p
        ON f.product_key = p.product_key
    GROUP BY
        p.sku_category,
        p.product_key,
        p.sku
)

SELECT
    sku_category,
    product_key,
    sku,
    total_units_sold,
    total_revenue,
    ROW_NUMBER() OVER (
        PARTITION BY sku_category
        ORDER BY total_revenue DESC
    ) AS product_revenue_rank
FROM product_performance
ORDER BY
    sku_category,
    product_revenue_rank;