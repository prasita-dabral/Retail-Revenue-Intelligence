/*
====================================================================
07_FINAL_SQL_VALIDATION.SQL
Retail Revenue Intelligence Platform
====================================================================

PURPOSE
-------
Final validation of the ETL output, star schema, data integrity,
relationships, and key business totals.

TABLES
------
fact_sales
dim_date
dim_customer
dim_product

EXPECTED FINAL FACT TABLE
-------------------------
Rows              : 131,706
Transactions      : 64,682
Customers         : 22,625
Quantity          : 195,624.429
Revenue           : 1,578,038.62

EXPECTED DATA QUALITY
---------------------
NULL quantities     : 0
Zero quantities     : 0
Negative quantities : 0
NULL sales amounts  : 0
Zero sales amounts  : 0
Negative sales      : 0

EXPECTED DIMENSIONS
-------------------
SKU categories : 187
SKUs           : 5,242

====================================================================
*/


-- ================================================================
-- CHECK 1: FACT TABLE ROW COUNT
-- ================================================================

SELECT
    COUNT(*) AS fact_sales_rows
FROM fact_sales;


/*
EXPECTED RESULT

fact_sales_rows
---------------
131706
*/


-- ================================================================
-- CHECK 2: MISSING VALUES IN FACT TABLE
-- ================================================================

SELECT
    SUM(transaction_id IS NULL) AS missing_transaction_id,
    SUM(date_key IS NULL) AS missing_date_key,
    SUM(customer_key IS NULL) AS missing_customer_key,
    SUM(product_key IS NULL) AS missing_product_key,
    SUM(quantity IS NULL) AS missing_quantity,
    SUM(sales_amount IS NULL) AS missing_sales_amount
FROM fact_sales;


/*
EXPECTED RESULT

All columns should return 0.
*/


-- ================================================================
-- CHECK 3: EXACT DUPLICATE FACT ROWS
-- ================================================================

SELECT
    COUNT(*) -
    COUNT(
        DISTINCT
        transaction_id,
        date_key,
        customer_key,
        product_key,
        quantity,
        sales_amount
    ) AS duplicate_rows
FROM fact_sales;


/*
EXPECTED RESULT

duplicate_rows
--------------
0
*/


-- ================================================================
-- CHECK 4: QUANTITY QUALITY
-- ================================================================
-- Confirms:
-- 1. No NULL quantities
-- 2. No zero quantities
-- 3. No negative quantities
-- 4. Fractional quantities are preserved correctly
-- ================================================================

SELECT
    SUM(quantity = 0) AS zero_quantity_rows,
    SUM(quantity < 0) AS negative_quantity_rows,
    SUM(quantity IS NULL) AS null_quantity_rows,
    SUM(quantity > 0 AND quantity % 1 = 0)
        AS positive_integer_rows,
    SUM(quantity > 0 AND quantity % 1 <> 0)
        AS fractional_quantity_rows,
    ROUND(SUM(quantity), 3) AS total_quantity
FROM fact_sales;


/*
EXPECTED RESULT

zero_quantity_rows       = 0
negative_quantity_rows   = 0
null_quantity_rows       = 0
positive_integer_rows    = 131331
fractional_quantity_rows = 375
total_quantity           = 195624.429

131331 + 375 = 131706
*/


-- ================================================================
-- CHECK 5: SALES AMOUNT QUALITY
-- ================================================================

SELECT
    SUM(sales_amount = 0) AS zero_sales_rows,
    SUM(sales_amount < 0) AS negative_sales_rows,
    SUM(sales_amount IS NULL) AS null_sales_rows
FROM fact_sales;


/*
EXPECTED RESULT

zero_sales_rows       = 0
negative_sales_rows   = 0
null_sales_rows       = 0
*/


-- ================================================================
-- CHECK 6: TRANSACTION COUNT
-- ================================================================

SELECT
    COUNT(DISTINCT transaction_id) AS total_transactions
FROM fact_sales;


/*
EXPECTED RESULT

total_transactions
------------------
64682
*/


-- ================================================================
-- CHECK 7: UNIQUE CUSTOMER COUNT
-- ================================================================

SELECT
    COUNT(DISTINCT customer_key) AS total_customers
FROM fact_sales;


/*
EXPECTED RESULT

total_customers
---------------
22625
*/


-- ================================================================
-- CHECK 8: TOTAL QUANTITY
-- ================================================================

SELECT
    ROUND(SUM(quantity), 3) AS total_quantity
FROM fact_sales;


/*
EXPECTED RESULT

total_quantity
--------------
195624.429
*/


-- ================================================================
-- CHECK 9: TOTAL REVENUE
-- ================================================================

SELECT
    ROUND(SUM(sales_amount), 2) AS total_revenue
FROM fact_sales;


/*
EXPECTED RESULT

total_revenue
-------------
1578038.62
*/


-- ================================================================
-- CHECK 10: DATE DIMENSION KEY UNIQUENESS
-- ================================================================

SELECT
    date_key,
    COUNT(*) AS row_count
FROM dim_date
GROUP BY date_key
HAVING COUNT(*) > 1;


/*
EXPECTED RESULT

0 rows
*/


-- ================================================================
-- CHECK 11: PRODUCT DIMENSION KEY UNIQUENESS
-- ================================================================

SELECT
    product_key,
    COUNT(*) AS row_count
FROM dim_product
GROUP BY product_key
HAVING COUNT(*) > 1;


/*
EXPECTED RESULT

0 rows
*/


-- ================================================================
-- CHECK 12: CUSTOMER DIMENSION KEY UNIQUENESS
-- ================================================================

SELECT
    customer_key,
    COUNT(*) AS row_count
FROM dim_customer
GROUP BY customer_key
HAVING COUNT(*) > 1;


/*
EXPECTED RESULT

0 rows
*/


-- ================================================================
-- CHECK 13: FACT → DATE REFERENTIAL INTEGRITY
-- ================================================================

SELECT
    COUNT(*) AS unmatched_date_rows
FROM fact_sales f
LEFT JOIN dim_date d
    ON f.date_key = d.date_key
WHERE d.date_key IS NULL;


/*
EXPECTED RESULT

unmatched_date_rows
-------------------
0
*/


-- ================================================================
-- CHECK 14: FACT → PRODUCT REFERENTIAL INTEGRITY
-- ================================================================

SELECT
    COUNT(*) AS unmatched_product_rows
FROM fact_sales f
LEFT JOIN dim_product p
    ON f.product_key = p.product_key
WHERE p.product_key IS NULL;


/*
EXPECTED RESULT

unmatched_product_rows
----------------------
0
*/


-- ================================================================
-- CHECK 15: FACT → CUSTOMER REFERENTIAL INTEGRITY
-- ================================================================

SELECT
    COUNT(*) AS unmatched_customer_rows
FROM fact_sales f
LEFT JOIN dim_customer c
    ON f.customer_key = c.customer_key
WHERE c.customer_key IS NULL;


/*
EXPECTED RESULT

unmatched_customer_rows
-----------------------
0
*/


-- ================================================================
-- CHECK 16: COMPLETE STAR-SCHEMA JOIN
-- ================================================================

SELECT
    COUNT(*) AS unmatched_fact_rows
FROM fact_sales f

LEFT JOIN dim_date d
    ON f.date_key = d.date_key

LEFT JOIN dim_product p
    ON f.product_key = p.product_key

LEFT JOIN dim_customer c
    ON f.customer_key = c.customer_key

WHERE d.date_key IS NULL
   OR p.product_key IS NULL
   OR c.customer_key IS NULL;


/*
EXPECTED RESULT

unmatched_fact_rows
-------------------
0
*/


-- ================================================================
-- CHECK 17: DATE COVERAGE
-- ================================================================

SELECT
    MIN(d.date) AS first_sales_date,
    MAX(d.date) AS last_sales_date
FROM fact_sales f
JOIN dim_date d
    ON f.date_key = d.date_key;


/*
EXPECTED RESULT

first_sales_date = 2016-01-02
last_sales_date  = 2016-12-31
*/


-- ================================================================
-- CHECK 18: NUMBER OF SKU CATEGORIES
-- ================================================================

SELECT
    COUNT(DISTINCT sku_category) AS total_categories
FROM dim_product;


/*
EXPECTED RESULT

total_categories
----------------
187
*/


-- ================================================================
-- CHECK 19: NUMBER OF SKUs
-- ================================================================

SELECT
    COUNT(*) AS total_skus
FROM dim_product;


/*
EXPECTED RESULT

total_skus
----------
5242
*/


-- ================================================================
-- CHECK 20: MONTHLY REVENUE RECONCILIATION
-- ================================================================

WITH monthly_revenue AS (

    SELECT
        d.year,
        d.month,
        SUM(f.sales_amount) AS monthly_revenue

    FROM fact_sales f

    JOIN dim_date d
        ON f.date_key = d.date_key

    GROUP BY
        d.year,
        d.month
)

SELECT
    ROUND(SUM(monthly_revenue), 2) AS reconciled_revenue
FROM monthly_revenue;


/*
EXPECTED RESULT

reconciled_revenue
------------------
1578038.62
*/


-- ================================================================
-- CHECK 21: MONTHLY TRANSACTION RECONCILIATION
-- ================================================================

WITH monthly_transactions AS (

    SELECT
        d.year,
        d.month,
        COUNT(DISTINCT f.transaction_id) AS monthly_transactions

    FROM fact_sales f

    JOIN dim_date d
        ON f.date_key = d.date_key

    GROUP BY
        d.year,
        d.month
)

SELECT
    SUM(monthly_transactions) AS reconciled_transactions
FROM monthly_transactions;


/*
EXPECTED RESULT

reconciled_transactions
-----------------------
64682
*/


-- ================================================================
-- CHECK 22: MONTHLY QUANTITY RECONCILIATION
-- ================================================================

WITH monthly_quantity AS (

    SELECT
        d.year,
        d.month,
        SUM(f.quantity) AS monthly_quantity

    FROM fact_sales f

    JOIN dim_date d
        ON f.date_key = d.date_key

    GROUP BY
        d.year,
        d.month
)

SELECT
    ROUND(SUM(monthly_quantity), 3) AS reconciled_quantity
FROM monthly_quantity;


/*
EXPECTED RESULT

reconciled_quantity
-------------------
195624.429
*/


-- ================================================================
-- CHECK 23: PRODUCT JOIN CONSISTENCY
-- ================================================================

SELECT
    product_key,
    COUNT(DISTINCT sku) AS sku_count,
    COUNT(DISTINCT sku_category) AS category_count

FROM dim_product

GROUP BY product_key

HAVING COUNT(DISTINCT sku) > 1
    OR COUNT(DISTINCT sku_category) > 1;


/*
EXPECTED RESULT

0 rows
*/


-- ================================================================
-- CHECK 24: CUSTOMER JOIN CONSISTENCY
-- ================================================================

SELECT
    customer_key,
    COUNT(DISTINCT customer_id) AS customer_id_count

FROM dim_customer

GROUP BY customer_key

HAVING COUNT(DISTINCT customer_id) > 1;


/*
EXPECTED RESULT

0 rows
*/


-- ================================================================
-- CHECK 25: DATE JOIN CONSISTENCY
-- ================================================================

SELECT
    date_key,
    COUNT(DISTINCT date) AS date_count

FROM dim_date

GROUP BY date_key

HAVING COUNT(DISTINCT date) > 1;


/*
EXPECTED RESULT

0 rows
*/


-- ================================================================
-- CHECK 26: FINAL RECONCILIATION SUMMARY
-- ================================================================

SELECT

    COUNT(*) AS fact_rows,

    COUNT(DISTINCT transaction_id) AS transactions,

    COUNT(DISTINCT customer_key) AS customers,

    ROUND(SUM(quantity), 3) AS total_quantity,

    ROUND(SUM(sales_amount), 2) AS total_revenue,

    SUM(quantity IS NULL) AS null_quantity_rows,

    SUM(quantity = 0) AS zero_quantity_rows,

    SUM(quantity < 0) AS negative_quantity_rows,

    SUM(sales_amount IS NULL) AS null_sales_rows,

    SUM(sales_amount = 0) AS zero_sales_rows,

    SUM(sales_amount < 0) AS negative_sales_rows

FROM fact_sales;


/*
EXPECTED RESULT

fact_rows              = 131706
transactions           = 64682
customers              = 22625
total_quantity         = 195624.429
total_revenue          = 1578038.62

null_quantity_rows     = 0
zero_quantity_rows     = 0
negative_quantity_rows = 0

null_sales_rows        = 0
zero_sales_rows        = 0
negative_sales_rows    = 0


====================================================================
FINAL STATUS
====================================================================

If all checks produce the expected results:

DATA INTEGRITY        : PASS
DATA QUALITY          : PASS
ETL RECONCILIATION    : PASS
STAR SCHEMA           : PASS
REFERENTIAL INTEGRITY : PASS
BUSINESS TOTALS       : PASS

SQL ANALYSIS          : COMPLETE

====================================================================
*/