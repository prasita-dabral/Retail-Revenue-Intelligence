/*
GOAL
----
Establish the overall baseline performance of the retail business
for the full analysis period.

BUSINESS QUESTIONS
------------------
1. How much total revenue was generated?
2. How many transactions were completed?
3. How many unique customers made purchases?
4. How many total units were sold?
5. What is the average sales value per line item?

KEY METRICS
-----------
- Total Revenue
- Total Transactions
- Total Customers
- Total Units Sold
- Average Line-Item Sales

ANALYTICAL APPROACH
-------------------
- Use fact_sales as the primary source
- Aggregate transaction-level sales data
- Use COUNT(DISTINCT transaction_id) to measure actual transactions
- Use COUNT(DISTINCT customer_key) to measure unique customers
- Use SUM(quantity) to measure sales volume
- Use SUM(sales_amount) to measure total revenue

BUSINESS PURPOSE
----------------
Create a baseline view of overall business performance that can be
used as a reference point for subsequent time-series, product,
customer, and root-cause analysis.
*/

-- ============================================
-- KPI 1: Overall Sales Performance
-- ============================================

SELECT
    COUNT(*) AS total_line_items,
    COUNT(DISTINCT transaction_id) AS total_transactions,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_units_sold,
    ROUND(SUM(sales_amount), 2) AS total_revenue,
    ROUND(AVG(sales_amount), 2) AS avg_line_item_sales
FROM fact_sales;

-- ============================================
-- KPI 2: Monthly Revenue & Transaction Trend
-- ============================================

SELECT
    d.year,
    d.month,
    d.month_name,
    ROUND(SUM(f.sales_amount), 2) AS total_revenue,
    COUNT(DISTINCT f.transaction_id) AS total_transactions,
    SUM(f.quantity) AS total_units_sold
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


-- ============================================
-- KPI 3: Product Category Performance
-- ============================================

SELECT
    p.sku_category,
    COUNT(DISTINCT f.transaction_id) AS total_transactions,
    SUM(f.quantity) AS total_units_sold,
    ROUND(SUM(f.sales_amount), 2) AS total_revenue
FROM fact_sales f
JOIN dim_product p
    ON f.product_key = p.product_key
GROUP BY
    p.sku_category
ORDER BY
    total_revenue DESC;


-- ============================================
-- KPI 4: Customer Performance
-- ============================================

SELECT
    f.customer_key,
    COUNT(DISTINCT f.transaction_id) AS total_transactions,
    SUM(f.quantity) AS total_units_sold,
    ROUND(SUM(f.sales_amount), 2) AS total_revenue
FROM fact_sales f
GROUP BY
    f.customer_key
ORDER BY
    total_revenue DESC
LIMIT 10;


-- ============================================
-- KPI 5: Average Transaction Value
-- ============================================

SELECT
    ROUND(
        SUM(sales_amount) / COUNT(DISTINCT transaction_id),
        2
    ) AS avg_transaction_value
FROM fact_sales;


-- ============================================
-- KPI 6: AVG Units per Transaction
-- ============================================

SELECT
    ROUND(
        SUM(quantity) / COUNT(DISTINCT transaction_id),
        2
    ) AS units_per_transaction
FROM fact_sales;


-- ============================================
-- KPI 7: Revenue per Unit
-- ============================================

SELECT
    ROUND(
        SUM(sales_amount) / SUM(quantity),
        2
    ) AS revenue_per_unit
FROM fact_sales;