/*

GOAL
----
Understand how product categories perform, identify the
categories driving revenue and units sold, and determine
whether category-level performance is broad-based or driven
by a small number of products.


BUSINESS QUESTIONS
------------------
1. Which categories generate the most revenue?
2. Which categories sell the most units?
3. Which categories have the highest revenue per unit?
4. What percentage of total revenue does each category contribute?
5. How does category performance change over time?
6. Which categories are growing or declining?
7. Are category-level changes driven by a few products or
   broad category movement?


KEY METRICS
-----------
- Category Revenue
- Category Units Sold
- Category Revenue per Unit
- Category Revenue Contribution %
- Monthly Category Revenue
- Category Growth / Decline
- Product Concentration within Category


BUSINESS PURPOSE
----------------
Move from SKU-level analysis to broader category-level
insights and determine which product categories are
responsible for overall business performance and changes.

The analysis will connect product-level findings to
higher-level category performance and support root-cause
analysis of important business movements.

============================================================
*/


-- ============================================================
-- Query 1: Category Revenue per Unit
-- Business Question:
-- Which categories generate the most revenue per unit sold?
-- ============================================================

SELECT
    p.sku_category,
    ROUND(
        SUM(f.sales_amount) / SUM(f.quantity),
        2
    ) AS revenue_per_unit
FROM fact_sales f
JOIN dim_product p
    ON f.product_key = p.product_key
GROUP BY
    p.sku_category
ORDER BY
    revenue_per_unit DESC;


-- ============================================================
-- Query 2: Category Revenue Contribution %
-- Business Question:
-- Which categories contribute the largest share of total revenue?
-- ============================================================

SELECT
    p.sku_category,
    ROUND(SUM(f.sales_amount), 2) AS category_revenue,
    ROUND(
        SUM(f.sales_amount)
        / SUM(SUM(f.sales_amount)) OVER ()
        * 100,
        2
    ) AS revenue_contribution_pct
FROM fact_sales f
JOIN dim_product p
    ON f.product_key = p.product_key
GROUP BY
    p.sku_category
ORDER BY
    revenue_contribution_pct DESC;


-- ============================================================
-- Query 3: Monthly Category Performance & Growth
-- Business Question:
-- How does category revenue change over time, and which
-- categories are growing or declining?
-- ============================================================

WITH monthly_category AS (
    SELECT
        d.year,
        d.month,
        d.month_name,
        p.sku_category,
        SUM(f.sales_amount) AS category_revenue
    FROM fact_sales f
    JOIN dim_date d
        ON f.date_key = d.date_key
    JOIN dim_product p
        ON f.product_key = p.product_key
    GROUP BY
        d.year,
        d.month,
        d.month_name,
        p.sku_category
)

SELECT
    year,
    month,
    month_name,
    sku_category,
    ROUND(category_revenue, 2) AS category_revenue,
    ROUND(
        LAG(category_revenue) OVER (
            PARTITION BY sku_category
            ORDER BY year, month
        ),
        2
    ) AS previous_month_revenue,
    ROUND(
        (
            category_revenue
            - LAG(category_revenue) OVER (
                PARTITION BY sku_category
                ORDER BY year, month
            )
        )
        / NULLIF(
            LAG(category_revenue) OVER (
                PARTITION BY sku_category
                ORDER BY year, month
            ),
            0
        ) * 100,
        2
    ) AS revenue_growth_pct
FROM monthly_category
ORDER BY
    sku_category,
    year,
    month;
