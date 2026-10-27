/* ============================================================
   KPI 5: CATEGORY INTELLIGENCE
   ============================================================

   GOAL
   ----
   Analyze category-level performance to understand how different
   SKU categories contribute to revenue, sales volume, and
   transaction activity.

   BUSINESS QUESTIONS
   ------------------
   1. Which categories generate the most revenue?
   2. Which categories sell the most units?
   3. Which categories have the highest transaction activity?
   4. Which categories have the highest revenue per unit?
   5. How much does each category contribute to total revenue?
   6. Are high-revenue categories also high-volume categories?
   7. Which categories show strong or weak performance over time?

   KEY METRICS
   -----------
   - Category Revenue
   - Category Units Sold
   - Category Transactions
   - Revenue per Unit
   - Revenue Contribution %
   - Monthly Category Revenue
   - Month-over-Month Category Growth %

   ANALYTICAL APPROACH
   -------------------
   - Join fact_sales with dim_product using product_key
   - Aggregate sales at the SKU category level
   - Compare revenue, units, and transaction activity
   - Calculate revenue per unit
   - Calculate each category's contribution to total revenue
   - Analyze category performance over time

   BUSINESS PURPOSE
   ----------------
   Understand the category mix driving retail performance and
   establish the category-level baseline required for the later
   revenue decline and recovery analysis.

*/


/* ============================================================
   QUERY 1: CATEGORY PERFORMANCE
   ============================================================

   Business Question:
   Which categories generate the most revenue?

   Purpose:
   Establish the overall performance of each SKU category.
*/

SELECT
    p.sku_category,
    COUNT(DISTINCT f.transaction_id) AS total_transactions,
    SUM(f.quantity) AS total_units_sold,
    ROUND(SUM(f.sales_amount), 2) AS total_revenue,
    ROUND(
        SUM(f.sales_amount)
        / NULLIF(SUM(f.quantity), 0),
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
   QUERY 2: CATEGORY REVENUE CONTRIBUTION
   ============================================================

   Business Question:
   How much does each category contribute to total revenue?

   Purpose:
   Measure the relative importance of each category within
   the overall retail business.
*/

WITH category_revenue AS (
    SELECT
        p.sku_category,
        SUM(f.sales_amount) AS category_revenue
    FROM fact_sales f
    JOIN dim_product p
        ON f.product_key = p.product_key
    GROUP BY
        p.sku_category
)

SELECT
    sku_category,
    ROUND(category_revenue, 2) AS total_revenue,
    ROUND(
        category_revenue
        / NULLIF(SUM(category_revenue) OVER (), 0)
        * 100,
        2
    ) AS revenue_contribution_pct
FROM category_revenue
ORDER BY
    total_revenue DESC;


/* ============================================================
   QUERY 3: CATEGORY PERFORMANCE BY SALES VOLUME
   ============================================================

   Business Question:
   Which categories sell the most units?

   Purpose:
   Compare category sales volume independently from revenue
   to identify high-volume categories.
*/

SELECT
    p.sku_category,
    SUM(f.quantity) AS total_units_sold,
    COUNT(DISTINCT f.transaction_id) AS total_transactions,
    ROUND(SUM(f.sales_amount), 2) AS total_revenue
FROM fact_sales f
JOIN dim_product p
    ON f.product_key = p.product_key
GROUP BY
    p.sku_category
ORDER BY
    total_units_sold DESC;


/* ============================================================
   QUERY 4: CATEGORY REVENUE PER UNIT
   ============================================================

   Business Question:
   Which categories generate the most revenue per unit sold?

   Purpose:
   Compare category monetization independently from sales
   volume.
*/

SELECT
    p.sku_category,
    SUM(f.quantity) AS total_units_sold,
    ROUND(SUM(f.sales_amount), 2) AS total_revenue,
    ROUND(
        SUM(f.sales_amount)
        / NULLIF(SUM(f.quantity), 0),
        2
    ) AS revenue_per_unit
FROM fact_sales f
JOIN dim_product p
    ON f.product_key = p.product_key
GROUP BY
    p.sku_category
ORDER BY
    revenue_per_unit DESC;


/* ============================================================
   QUERY 5: MONTHLY CATEGORY PERFORMANCE
   ============================================================

   Business Question:
   How does each category perform over time?

   Purpose:
   Establish a monthly category-level baseline that can later
   be used to identify category declines and recoveries.

   Ordering:
   Categories are grouped together so that all months belonging
   to the same category appear consecutively.
*/

SELECT
    d.year,
    d.month,
    d.month_name,
    p.sku_category,
    COUNT(DISTINCT f.transaction_id) AS total_transactions,
    SUM(f.quantity) AS total_units_sold,
    ROUND(SUM(f.sales_amount), 2) AS total_revenue
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
ORDER BY
    p.sku_category,
    d.year,
    d.month;


/* ============================================================
   QUERY 6: MONTH-OVER-MONTH CATEGORY REVENUE GROWTH
   ============================================================

   Business Question:
   Which categories are growing or declining from month to month?

   Purpose:
   Identify category-level changes over time and provide a
   direct input for later decline/recovery investigation.
*/

WITH monthly_category_revenue AS (
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
),

category_growth AS (
    SELECT
        year,
        month,
        month_name,
        sku_category,
        category_revenue,

        LAG(category_revenue) OVER (
            PARTITION BY sku_category
            ORDER BY year, month
        ) AS previous_month_revenue

    FROM monthly_category_revenue
)

SELECT
    year,
    month,
    month_name,
    sku_category,

    ROUND(category_revenue, 2) AS total_revenue,

    ROUND(previous_month_revenue, 2)
        AS previous_month_revenue,

    ROUND(
        (
            category_revenue - previous_month_revenue
        )
        / NULLIF(previous_month_revenue, 0)
        * 100,
        2
    ) AS revenue_growth_pct

FROM category_growth

ORDER BY
    sku_category,
    year,
    month;