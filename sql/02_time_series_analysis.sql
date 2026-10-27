-- Active: 1787047598278@@127.0.0.1@3306@retail_analytics
-- 02 TIME SERIES ANALYSIS
-- ============================================================

/*
GOAL
----
Analyze how retail business performance changes over time during
2016 and identify periods of growth, decline, and unusual performance.

BUSINESS QUESTIONS
------------------
1. How does revenue change from month to month?
2. Which months experienced the strongest growth or decline?
3. Are changes in revenue driven by transaction volume?
4. Are changes in revenue driven by units sold?
5. Are there identifiable seasonal patterns?

KEY METRICS
-----------
- Monthly Revenue
- Monthly Transactions
- Monthly Units Sold
- Previous Month Revenue
- Month-over-Month Revenue Growth %

ANALYTICAL APPROACH
-------------------
- Use fact_sales as the primary source
- Join dim_date using date_key
- Aggregate sales at the monthly level
- Use LAG() to compare each month with the previous month
- Calculate month-over-month revenue growth

BUSINESS PURPOSE
----------------
Identify periods of strong or weak business performance and establish
the time periods that require deeper product, customer, and
root-cause investigation.
*/

-- ============================================================
-- Query 1: Month-over-Month Revenue Growth
-- ============================================================

WITH monthly_revenue AS (
    SELECT
        d.year,
        d.month,
        d.month_name,
        SUM(f.sales_amount) AS this_month_revenue
    FROM fact_sales f
    JOIN dim_date d
        ON f.date_key = d.date_key
    GROUP BY
        d.year,
        d.month,
        d.month_name
)

SELECT
    year,
    month,
    month_name,
    ROUND(this_month_revenue, 2) AS this_month_revenue,
    ROUND(
        LAG(this_month_revenue) OVER (ORDER BY year, month),
        2
    ) AS previous_month_revenue,
    ROUND(
        (
            this_month_revenue
            - LAG(this_month_revenue) OVER (ORDER BY year, month)
        )
        / NULLIF (
        LAG(this_month_revenue) OVER (ORDER BY year, month),
        0
        ) * 100,
        2
    ) AS revenue_growth_pct
FROM monthly_revenue
ORDER BY
    year,
    month;


-- ============================================================
-- Query 2: Monthly Revenue vs Transaction Volume
-- ============================================================

SELECT
    d.year,
    d.month,
    d.month_name,
    ROUND(SUM(f.sales_amount), 2) AS total_revenue,
    COUNT(DISTINCT f.transaction_id) AS total_transactions,
    ROUND(
        SUM(f.sales_amount) / COUNT(DISTINCT f.transaction_id),
        2
    ) AS avg_transaction_value
FROM fact_sales f
JOIN dim_date d
    ON f.date_key = d.date_key
GROUP BY
    d.year,
    d.month,
    d.month_name
ORDER BY
    d.year,
    d.month;



-- ============================================================
-- Query 3: Monthly Revenue vs Units Sold
-- ============================================================

SELECT
    d.year,
    d.month,
    d.month_name,
    ROUND(SUM(f.sales_amount), 2) AS total_revenue,
    SUM(f.quantity) AS total_units_sold,
    ROUND(
        SUM(f.quantity) / COUNT(DISTINCT f.transaction_id),
        2
    ) AS units_per_transaction,
    ROUND(
        SUM(f.sales_amount) / SUM(f.quantity),
        2
    ) AS revenue_per_unit
FROM fact_sales f
JOIN dim_date d
    ON f.date_key = d.date_key
GROUP BY
    d.year,
    d.month,
    d.month_name
ORDER BY
    d.year,
    d.month;


