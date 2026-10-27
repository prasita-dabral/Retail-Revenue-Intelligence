/* ============================================================
   KPI 4: CUSTOMER INTELLIGENCE
   ============================================================

   GOAL
   ----
   Analyze customer purchasing behavior to understand which
   customers contribute most to revenue, transaction activity,
   and sales volume.

   BUSINESS QUESTIONS
   ------------------
   1. Which customers generate the most revenue?
   2. Which customers make the most transactions?
   3. Which customers purchase the most units?
   4. Which customers generate the highest revenue per transaction?
   5. How concentrated is revenue across customers?
   6. Are high-revenue customers also high-frequency customers?

   KEY METRICS
   -----------
   - Customer Revenue
   - Customer Transactions
   - Customer Units Sold
   - Average Revenue per Transaction
   - Revenue Contribution %

   ANALYTICAL APPROACH
   -------------------
   - Use fact_sales as the primary sales source
   - Aggregate sales at the customer level
   - Use COUNT(DISTINCT transaction_id) to measure
     transaction frequency
   - Use SUM(quantity) to measure purchasing volume
   - Use SUM(sales_amount) to measure customer revenue
   - Compare revenue, frequency, and volume
   - Calculate revenue per transaction
   - Calculate customer contribution to total revenue

   BUSINESS PURPOSE
   ----------------
   Identify high-value and high-frequency customers and
   understand how customer purchasing behavior contributes
   to overall retail performance.

   This analysis provides customer-level context without
   overlapping with the product/category analysis in KPI 3
   and KPI 5.
*/


/* ============================================================
   QUERY 1: TOP CUSTOMERS BY REVENUE
   ============================================================

   Business Question:
   Which customers generate the most revenue?

   Purpose:
   Identify the highest-value customers based on total
   revenue generated during the analysis period.
*/

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


/* ============================================================
   QUERY 2: TOP CUSTOMERS BY TRANSACTION FREQUENCY
   ============================================================

   Business Question:
   Which customers make the most transactions?

   Purpose:
   Identify customers with the highest purchase frequency.
*/

SELECT
    f.customer_key,
    COUNT(DISTINCT f.transaction_id) AS total_transactions,
    SUM(f.quantity) AS total_units_sold,
    ROUND(SUM(f.sales_amount), 2) AS total_revenue
FROM fact_sales f
GROUP BY
    f.customer_key
ORDER BY
    total_transactions DESC
LIMIT 10;


/* ============================================================
   QUERY 3: TOP CUSTOMERS BY UNITS SOLD
   ============================================================

   Business Question:
   Which customers purchase the most units?

   Purpose:
   Identify customers with the highest purchasing volume.
*/

SELECT
    f.customer_key,
    COUNT(DISTINCT f.transaction_id) AS total_transactions,
    SUM(f.quantity) AS total_units_sold,
    ROUND(SUM(f.sales_amount), 2) AS total_revenue
FROM fact_sales f
GROUP BY
    f.customer_key
ORDER BY
    total_units_sold DESC
LIMIT 10;


/* ============================================================
   QUERY 4: AVERAGE REVENUE PER TRANSACTION BY CUSTOMER
   ============================================================

   Business Question:
   Which customers generate the highest revenue per transaction?

   Purpose:
   Distinguish customers who generate high value per purchase
   from customers who generate high revenue primarily through
   frequent transactions.
*/

SELECT
    f.customer_key,
    COUNT(DISTINCT f.transaction_id) AS total_transactions,
    ROUND(SUM(f.sales_amount), 2) AS total_revenue,
    ROUND(
        SUM(f.sales_amount)
        / NULLIF(COUNT(DISTINCT f.transaction_id), 0),
        2
    ) AS avg_revenue_per_transaction
FROM fact_sales f
GROUP BY
    f.customer_key
ORDER BY
    avg_revenue_per_transaction DESC
LIMIT 10;


/* ============================================================
   QUERY 5: CUSTOMER REVENUE CONTRIBUTION
   ============================================================

   Business Question:
   How concentrated is revenue across customers?

   Purpose:
   Measure each customer's contribution to total revenue.

   This helps determine whether retail revenue is broadly
   distributed or driven by a relatively small group of
   customers.
*/

WITH customer_revenue AS (
    SELECT
        customer_key,
        SUM(sales_amount) AS customer_revenue
    FROM fact_sales
    GROUP BY
        customer_key
)

SELECT
    customer_key,
    ROUND(customer_revenue, 2) AS customer_revenue,
    ROUND(
        customer_revenue
        / NULLIF(SUM(customer_revenue) OVER (), 0)
        * 100,
        2
    ) AS revenue_contribution_pct
FROM customer_revenue
ORDER BY
    customer_revenue DESC
LIMIT 10;


/* ============================================================
   QUERY 6: CUSTOMER REVENUE VS TRANSACTION FREQUENCY
   ============================================================

   Business Question:
   Are high-revenue customers also high-frequency customers?

   Purpose:
   Compare customer revenue, transaction frequency, purchasing
   volume, and average transaction value in one view.

   This provides a broader customer-performance profile and
   supports identification of different customer behaviors.
*/

SELECT
    f.customer_key,
    COUNT(DISTINCT f.transaction_id) AS total_transactions,
    SUM(f.quantity) AS total_units_sold,
    ROUND(SUM(f.sales_amount), 2) AS total_revenue,
    ROUND(
        SUM(f.sales_amount)
        / NULLIF(COUNT(DISTINCT f.transaction_id), 0),
        2
    ) AS avg_revenue_per_transaction
FROM fact_sales f
GROUP BY
    f.customer_key
ORDER BY
    total_revenue DESC;