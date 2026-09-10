/*
GOAL
----
Analyze product and category performance to understand which parts
of the product portfolio drive revenue, sales volume, and transaction
activity.

BUSINESS QUESTIONS
------------------
1. Which product categories generate the most revenue?
2. Which categories sell the most units?
3. Which categories have the highest transaction activity?
4. Are high-revenue categories also high-volume categories?
5. Which categories contribute most to overall revenue?
6. Are there categories that perform strongly on volume but weakly
   on revenue, or vice versa?

KEY METRICS
-----------
- Category Revenue
- Category Units Sold
- Category Transactions
- Revenue per Unit
- Revenue Contribution %

ANALYTICAL APPROACH
-------------------
- Join fact_sales with dim_product using product_key
- Aggregate sales at the category level
- Compare revenue, units, and transaction activity
- Calculate revenue per unit where useful
- Rank categories based on business performance

BUSINESS PURPOSE
----------------
Understand the product mix driving retail performance and identify
categories that deserve deeper investigation in the later analysis.
*/


-- ============================================================
-- Query 1: Top Products by Revenue
-- ============================================================

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

select * from dim_product;
select * from fact_sales;

-- ============================================================
-- Query 2: Top Products by Units Sold
-- ============================================================

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


-- ============================================================
-- Query 3: Revenue per Unit by Product
-- ============================================================


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


