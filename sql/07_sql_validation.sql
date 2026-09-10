============================================================
PHASE 6 — FINAL SQL VALIDATION
============================================================

OBJECTIVE
---------
Validate that all KPI results are:
1. Correct
2. Internally consistent
3. Based on the intended data grain
4. Fully reconciled to the fact table
5. Suitable for downstream Root-Cause Analysis and Dashboarding

IMPORTANT:
Phase 6 does NOT introduce new business analysis.
It validates the SQL analysis already completed in Phase 5.


============================================================
KPI 1 — OVERALL SALES PERFORMANCE
============================================================

PURPOSE
-------
Validate the overall baseline metrics against the fact table.

KPI RESULTS
-----------
Total Line Items       = 131,706
Total Transactions     = 64,682
Total Customers       = 22,625
Total Units Sold      = 195,611
Total Revenue          = 1,578,038.62
Avg Line-Item Sales    = 11.98


VALIDATION 1 — CORE FACT TABLE METRICS
--------------------------------------

SELECT
    COUNT(*) AS total_line_items,
    COUNT(DISTINCT transaction_key) AS total_transactions,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_units_sold,
    SUM(sales_amount) AS total_revenue
FROM fact_sales;


EXPECTED RESULT
---------------
total_line_items      = 131706
total_transactions    = 64682
total_customers       = 22625
total_units_sold      = 195611
total_revenue         = 1578038.62


VALIDATION 2 — AVERAGE LINE-ITEM SALES
---------------------------------------

Definition:

Average Line-Item Sales
= Total Revenue / Total Line Items


SELECT
    ROUND(
        SUM(sales_amount) / COUNT(*),
        2
    ) AS avg_line_item_sales
FROM fact_sales;


EXPECTED RESULT
---------------
11.98


VALIDATION STATUS
-----------------
KPI 1 = PASS

The overall KPI baseline reconciles directly to fact_sales.


============================================================
KPI 2 — TIME SERIES ANALYSIS
============================================================

PURPOSE
-------
Validate monthly revenue aggregation and confirm that
monthly revenue reconciles to annual revenue.

MONTHLY REVENUE RESULTS
-----------------------

January     = 111,200.28
February    = 122,114.61
March       = 127,924.54
April       = 138,172.11
May         = 142,719.86
June        = 131,305.35
July        = 120,591.97
August      = 116,908.98
September   = 141,239.89
October     = 140,853.51
November    = 132,883.33
December    = 152,124.19


KEY TREND
---------

May
    ↓
June
    ↓
July
    ↓
August

Revenue declined continuously from May to August.

August → September produced a sharp recovery.


VALIDATION 1 — MONTHLY REVENUE → ANNUAL REVENUE
------------------------------------------------

SELECT
    ROUND(SUM(monthly_revenue), 2) AS annual_revenue
FROM (
    SELECT
        d.month,
        SUM(f.sales_amount) AS monthly_revenue
    FROM fact_sales f
    JOIN dim_date d
        ON f.date_key = d.date_key
    GROUP BY d.month
) x;


EXPECTED RESULT
---------------
1,578,038.62


VALIDATION 2 — AUGUST → SEPTEMBER RECOVERY
-------------------------------------------

August Revenue      = 116,908.98
September Revenue   = 141,239.89

Revenue Change
= 141,239.89 - 116,908.98
= +24,330.91

MoM Growth
= +20.81%


VALIDATION STATUS
-----------------
KPI 2 = PASS

Monthly revenue reconciles to the annual fact-table revenue.


============================================================
KPI 3 — PRODUCT PERFORMANCE
============================================================

PURPOSE
-------
Validate that product-level aggregation does not lose or
duplicate revenue or units.

FACT TABLE BASELINE
-------------------

Revenue = 1,578,038.62
Units   = 195,611


VALIDATION 1 — FACT TABLE
-------------------------

SELECT
    ROUND(SUM(sales_amount), 2) AS revenue,
    SUM(quantity) AS units
FROM fact_sales;


EXPECTED RESULT
---------------
revenue = 1578038.62
units   = 195611


VALIDATION 2 — PRODUCT AGGREGATION
-----------------------------------

SELECT
    ROUND(SUM(product_revenue), 2) AS revenue,
    SUM(product_units) AS units
FROM (
    SELECT
        product_key,
        SUM(sales_amount) AS product_revenue,
        SUM(quantity) AS product_units
    FROM fact_sales
    GROUP BY product_key
) x;


EXPECTED RESULT
---------------
revenue = 1578038.62
units   = 195611


VALIDATION STATUS
-----------------
KPI 3 = PASS

Product-level aggregation reconciles to the fact table.


============================================================
KPI 4 — CUSTOMER INTELLIGENCE
============================================================

PURPOSE
-------
Validate customer-level revenue aggregation.

TOP CUSTOMER RESULTS
--------------------

Customer 17471
Transactions = 62
Units        = 815
Revenue      = 3,985.94

Customer 17104
Transactions = 55
Units        = 408
Revenue      = 3,844.97

Customer 17294
Transactions = 39
Units        = 247
Revenue      = 3,798.39

Customer 15540
Transactions = 38
Units        = 165
Revenue      = 2,900.61


VALIDATION — CUSTOMER REVENUE
-----------------------------

SELECT
    ROUND(SUM(customer_revenue), 2) AS revenue
FROM (
    SELECT
        customer_key,
        SUM(sales_amount) AS customer_revenue
    FROM fact_sales
    GROUP BY customer_key
) x;


EXPECTED RESULT
---------------
1,578,038.62


ADDITIONAL CHECK
----------------

COUNT(DISTINCT customer_key)
= 22,625


VALIDATION STATUS
-----------------
KPI 4 = PASS

Customer-level revenue reconciles to total revenue.


============================================================
KPI 5 — CATEGORY INTELLIGENCE
============================================================

PURPOSE
-------
Validate Average Transaction Value (ATV).

DEFINITION
----------

Average Transaction Value
= Total Revenue / Total Transactions


CALCULATION
-----------

1,578,038.62 / 64,682
= 24.40


VALIDATION QUERY
----------------

SELECT
    ROUND(
        SUM(sales_amount)
        / COUNT(DISTINCT transaction_key),
        2
    ) AS avg_transaction_value
FROM fact_sales;


EXPECTED RESULT
---------------
24.40


IMPORTANT
---------

ATV is NOT:

AVG(sales_amount)

because sales_amount is stored at line-item level.

ATV measures:

Total Revenue
-------------
Distinct Transactions


VALIDATION STATUS
-----------------
KPI 5 = PASS


============================================================
KPI 6 — REVENUE DECLINE → RECOVERY
============================================================

PURPOSE
-------
Validate the major business movement identified in KPI 2
and the category/product decomposition used for root-cause
analysis.


------------------------------------------------------------
KPI 6A — MAY → AUGUST DECLINE
------------------------------------------------------------

May Revenue       = 142,719.86
August Revenue     = 116,908.98

Revenue Change
= 116,908.98 - 142,719.86
= -25,810.88


Percentage Change
-----------------

(-25,810.88 / 142,719.86) × 100

= -18.09%


CONCLUSION
----------

Revenue declined approximately 18.09% from May to August.


------------------------------------------------------------
KPI 6B — AUGUST → SEPTEMBER RECOVERY
------------------------------------------------------------

August Revenue       = 116,908.98
September Revenue    = 141,239.89

Revenue Change
= +24,330.91


Percentage Change
-----------------

(24,330.91 / 116,908.98) × 100

= +20.81%


CONCLUSION
----------

Revenue recovered approximately 20.81% from August to
September.


============================================================
KPI 6B — CATEGORY DECOMPOSITION VALIDATION
============================================================

PURPOSE
-------
Check whether the sum of all category-level revenue changes
equals the total company-level recovery.


VALIDATION QUERY
----------------

SELECT
    ROUND(
        SUM(september_revenue - august_revenue),
        2
    ) AS total_category_change
FROM (
    SELECT
        p.sku_category,

        SUM(
            CASE
                WHEN d.month = 8
                THEN f.sales_amount
                ELSE 0
            END
        ) AS august_revenue,

        SUM(
            CASE
                WHEN d.month = 9
                THEN f.sales_amount
                ELSE 0
            END
        ) AS september_revenue

    FROM fact_sales f

    JOIN dim_date d
        ON f.date_key = d.date_key

    JOIN dim_product p
        ON f.product_key = p.product_key

    WHERE d.month IN (8, 9)

    GROUP BY p.sku_category
) x;


EXPECTED RESULT
---------------
24,330.91


WHY THIS MATTERS
----------------

Company Recovery
       ↓
Category Revenue Changes
       ↓
Sum of Category Changes
       ↓
Should equal Company Recovery


This validates that category decomposition explains the
overall recovery without losing or duplicating revenue.


============================================================
KPI 6B — PRODUCT DECOMPOSITION VALIDATION
============================================================

PURPOSE
-------
Validate the drill-down from category → product.

Business hierarchy:

Company
   ↓
Category
   ↓
Product


For each selected recovering category:

Sum of Product Revenue Changes
                =
Category Revenue Change


EXAMPLE — CATEGORY 1EO
----------------------

Category Recovery = +1,893.16


Major Product Contributions:

PTA6G     = +306.22
DAIME     = +290.95
4891R     = +249.56
7RU0K     = +242.61
7C9N2     = +165.99
...


The sum of product-level changes should reconcile to:

+1,893.16


The same validation should be performed for:

1EO
1L6
LPF
OXH
SJS


VALIDATION STATUS
-----------------
Needs final execution/verification in MySQL.


============================================================
KPI 6B — VOLUME VS MONETIZATION VALIDATION
============================================================

The product-level recovery was further classified into:

1. Volume Driven
2. Monetization Driven
3. Both Volume and Monetization
4. Other


DEFINITIONS
-----------

Volume Driven:

September Units > August Units

AND

September Revenue per Unit
<=
August Revenue per Unit


Monetization Driven:

September Units
<=
August Units

AND

September Revenue per Unit
>
August Revenue per Unit


Both Volume and Monetization:

September Units > August Units

AND

September Revenue per Unit
>
August Revenue per Unit


OTHER:

Remaining cases.


IMPORTANT OBSERVATION
---------------------

Products with:

August Units = 0
September Units > 0

are currently classified as:

Other


These should be reviewed because they may represent:

NEW / REACTIVATED PRODUCTS


RECOMMENDED IMPROVEMENT
----------------------

Add a separate classification such as:

WHEN august_units = 0
     AND september_units > 0
THEN 'New / Reactivated Product'


This should be considered before the final dashboard and
business interpretation.


============================================================
PHASE 6 — FINAL VALIDATION SUMMARY
============================================================

KPI 1 — Overall Sales Performance
STATUS: PASS

KPI 2 — Time Series Analysis
STATUS: PASS

KPI 3 — Product Performance
STATUS: PASS

KPI 4 — Customer Intelligence
STATUS: PASS

KPI 5 — Category Intelligence
STATUS: PASS

KPI 6A — May → August Decline
STATUS: PASS

KPI 6B — August → September Recovery
STATUS: PASS

KPI 6B — Category → Company Reconciliation
STATUS: VERIFY IN MYSQL

KPI 6B — Product → Category Reconciliation
STATUS: VERIFY IN MYSQL

KPI 6B — Recovery Driver Classification
STATUS: REVIEW / IMPROVE


============================================================
FINAL PHASE 6 OUTPUT
============================================================

The SQL analysis is considered technically validated once:

1. Monthly revenue reconciles to annual revenue.
2. Product revenue reconciles to total revenue.
3. Customer revenue reconciles to total revenue.
4. Category revenue changes reconcile to total recovery.
5. Product revenue changes reconcile to category recovery.
6. Recovery-driver classification has been reviewed.
7. No unexplained revenue differences remain.


============================================================
NEXT PHASE
============================================================

PHASE 7 — BUSINESS INSIGHTS & ROOT-CAUSE ANALYSIS


The objective now changes from:

"What does the SQL result show?"

to:

"WHY did this happen?"


PHASE 7 will investigate:

1. Why revenue declined from May → August.
2. Which categories caused the decline.
3. Which products caused the decline.
4. Whether the decline was volume-driven or
   monetization-driven.
5. Which categories drove the September recovery.
6. Which products drove the recovery.
7. Whether recovery came from existing products,
   new/reactivated products, higher volume, or
   higher revenue per unit.
8. What business actions can be recommended based
   on the evidence.


IMPORTANT:

PHASE 7 is the ROOT-CAUSE / BUSINESS INTERPRETATION layer.

It should remain separate from KPI 6.

KPI 6 = SQL analysis.

PHASE 7 = Business conclusions from all KPI evidence.
============================================================