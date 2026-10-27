-- ============================================================
-- QUERY 1 — REVENUE, CUSTOMER MOVEMENT & BUSINESS DIAGNOSIS
-- ============================================================
-- Business Question:
-- What happened to revenue, transactions and customer activity
-- from May through September 2016, and how did customer
-- movement contribute to the decline and recovery?
--
-- Customer Flow:
--   New          = first recorded purchase in that month
--   Continuing   = active in the immediately previous month
--   Reactivated  = previously observed, but not active in the
--                  immediately previous month
-- ============================================================

WITH monthly_metrics AS (

    SELECT
        d.month,
        MAX(d.month_name) AS month_name,

        SUM(f.sales_amount) AS revenue,

        COUNT(DISTINCT f.transaction_id)
            AS transactions,

        COUNT(DISTINCT f.customer_key)
            AS active_customers,

        SUM(f.quantity)
            AS units,

        SUM(f.sales_amount)
            / NULLIF(COUNT(DISTINCT f.transaction_id), 0)
            AS atv,

        SUM(f.sales_amount)
            / NULLIF(SUM(f.quantity), 0)
            AS revenue_per_unit

    FROM fact_sales f

    JOIN dim_date d
        ON f.date_key = d.date_key

    WHERE d.year = 2016
      AND d.month BETWEEN 5 AND 9

    GROUP BY d.month
),

customer_months AS (

    SELECT DISTINCT

        f.customer_key,

        DATE_FORMAT(
            d.date,
            '%Y-%m-01'
        ) AS month_start

    FROM fact_sales f

    JOIN dim_date d
        ON f.date_key = d.date_key
),

first_purchase AS (

    SELECT
        customer_key,

        MIN(month_start)
            AS first_month

    FROM customer_months

    GROUP BY customer_key
),

customer_flow AS (

    SELECT

        cm.customer_key,
        cm.month_start,
        fp.first_month,

        LAG(cm.month_start)
            OVER (
                PARTITION BY cm.customer_key
                ORDER BY cm.month_start
            ) AS previous_active_month

    FROM customer_months cm

    JOIN first_purchase fp
        ON cm.customer_key = fp.customer_key
),

flow_summary AS (

    SELECT

        MONTH(month_start) AS month,

        SUM(
            CASE
                WHEN month_start = first_month
                    THEN 1
                ELSE 0
            END
        ) AS new_customers,

        SUM(
            CASE
                WHEN month_start <> first_month
                 AND previous_active_month =
                     DATE_SUB(
                         month_start,
                         INTERVAL 1 MONTH
                     )
                    THEN 1
                ELSE 0
            END
        ) AS continuing_customers,

        SUM(
            CASE
                WHEN month_start <> first_month
                 AND (
                        previous_active_month IS NULL
                        OR previous_active_month <>
                           DATE_SUB(
                               month_start,
                               INTERVAL 1 MONTH
                           )
                     )
                    THEN 1
                ELSE 0
            END
        ) AS reactivated_customers

    FROM customer_flow

    WHERE month_start BETWEEN
          '2016-05-01'
          AND '2016-09-01'

    GROUP BY MONTH(month_start)
),

lost_customers AS (

    SELECT

        MONTH(previous_month.month_start) + 1
            AS month,

        COUNT(*) AS lost_customers

    FROM customer_months previous_month

    LEFT JOIN customer_months current_month

        ON current_month.customer_key =
           previous_month.customer_key

       AND current_month.month_start =
           DATE_ADD(
               previous_month.month_start,
               INTERVAL 1 MONTH
           )

    WHERE previous_month.month_start BETWEEN
          '2016-04-01'
          AND '2016-08-01'

      AND current_month.customer_key IS NULL

    GROUP BY
        MONTH(previous_month.month_start) + 1
)

SELECT

    mm.month,
    mm.month_name,

    ROUND(mm.revenue, 2)
        AS revenue,

    ROUND(
        mm.revenue
        - LAG(mm.revenue)
          OVER (ORDER BY mm.month),
        2
    ) AS revenue_change,

    ROUND(
        100.0 *
        (
            mm.revenue
            - LAG(mm.revenue)
              OVER (ORDER BY mm.month)
        )
        / NULLIF(
            LAG(mm.revenue)
            OVER (ORDER BY mm.month),
            0
        ),
        2
    ) AS revenue_change_pct,

    mm.transactions,

    ROUND(mm.atv, 2)
        AS atv,

    mm.active_customers,

    ROUND(
        mm.transactions
        / NULLIF(mm.active_customers, 0),
        2
    ) AS transactions_per_customer,

    ROUND(
        mm.revenue
        / NULLIF(mm.active_customers, 0),
        2
    ) AS revenue_per_customer,

    mm.units,

    ROUND(
        mm.revenue_per_unit,
        2
    ) AS revenue_per_unit,

    fs.new_customers,

    fs.continuing_customers,

    fs.reactivated_customers,

    COALESCE(
        lc.lost_customers,
        0
    ) AS lost_customers

FROM monthly_metrics mm

JOIN flow_summary fs
    ON mm.month = fs.month

LEFT JOIN lost_customers lc
    ON mm.month = lc.month

ORDER BY mm.month;


-- ============================================================
-- QUERY 2 — CATEGORY & PRODUCT DRIVERS
-- ============================================================
-- Business Question:
-- Which categories and products explain the May-August
-- decline and the August-September recovery?
-- ============================================================


WITH category_month AS (

    SELECT

        COALESCE(
            p.sku_category,
            'Unknown/Unmapped'
        ) AS category,

        SUM(
            CASE
                WHEN d.month = 5
                    THEN f.sales_amount
                ELSE 0
            END
        ) AS may_revenue,

        SUM(
            CASE
                WHEN d.month = 6
                    THEN f.sales_amount
                ELSE 0
            END
        ) AS june_revenue,

        SUM(
            CASE
                WHEN d.month = 7
                    THEN f.sales_amount
                ELSE 0
            END
        ) AS july_revenue,

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

    LEFT JOIN dim_product p
        ON f.product_key = p.product_key

    WHERE d.year = 2016
      AND d.month BETWEEN 5 AND 9

    GROUP BY
        COALESCE(
            p.sku_category,
            'Unknown/Unmapped'
        )
),

category_changes AS (

    SELECT

        category,

        may_revenue,
        june_revenue,
        july_revenue,
        august_revenue,
        september_revenue,

        june_revenue
            - may_revenue
            AS may_june_change,

        july_revenue
            - june_revenue
            AS june_july_change,

        august_revenue
            - july_revenue
            AS july_august_change,

        august_revenue
            - may_revenue
            AS may_august_change,

        september_revenue
            - august_revenue
            AS august_september_change

    FROM category_month
)

SELECT

    category,

    ROUND(may_revenue, 2)
        AS may_revenue,

    ROUND(june_revenue, 2)
        AS june_revenue,

    ROUND(july_revenue, 2)
        AS july_revenue,

    ROUND(august_revenue, 2)
        AS august_revenue,

    ROUND(september_revenue, 2)
        AS september_revenue,

    ROUND(may_august_change, 2)
        AS may_august_change,

    ROUND(august_september_change, 2)
        AS august_september_change,

    RANK() OVER (
        ORDER BY may_august_change ASC
    ) AS decline_rank,

    RANK() OVER (
        ORDER BY august_september_change DESC
    ) AS recovery_rank

FROM category_changes

ORDER BY
    may_august_change ASC;



-- ============================================================
-- QUERY 2 — RESULT SET 2
-- FOCUSED PRODUCT DRIVERS
-- ============================================================
-- The output is intentionally limited to the most material
-- products so the analysis remains readable.
-- ============================================================

WITH category_month AS (

    SELECT

        COALESCE(
            p.sku_category,
            'Unknown/Unmapped'
        ) AS category,

        SUM(
            CASE
                WHEN d.month = 5
                    THEN f.sales_amount
                ELSE 0
            END
        ) AS may_revenue,

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

    LEFT JOIN dim_product p
        ON f.product_key = p.product_key

    WHERE d.year = 2016
      AND d.month BETWEEN 5 AND 9

    GROUP BY
        COALESCE(
            p.sku_category,
            'Unknown/Unmapped'
        )
),

decline_categories AS (

    SELECT
        category

    FROM category_month

    WHERE august_revenue < may_revenue

    ORDER BY
        august_revenue - may_revenue

    LIMIT 3
),

recovery_categories AS (

    SELECT
        category

    FROM category_month

    WHERE september_revenue > august_revenue

    ORDER BY
        september_revenue - august_revenue DESC

    LIMIT 3
),

product_month AS (

    SELECT

        COALESCE(
            p.sku_category,
            'Unknown/Unmapped'
        ) AS category,

        f.product_key,

        p.sku,

        SUM(
            CASE
                WHEN d.month = 5
                    THEN f.sales_amount
                ELSE 0
            END
        ) AS may_revenue,

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

    LEFT JOIN dim_product p
        ON f.product_key = p.product_key

    WHERE d.year = 2016
      AND d.month BETWEEN 5 AND 9

    GROUP BY

        COALESCE(
            p.sku_category,
            'Unknown/Unmapped'
        ),

        f.product_key,

        p.sku
),

product_changes AS (

    SELECT

        pm.*,

        august_revenue
            - may_revenue
            AS may_august_change,

        september_revenue
            - august_revenue
            AS august_september_change

    FROM product_month pm
),

decline_products AS (

    SELECT

        pc.*,

        ROW_NUMBER() OVER (
            PARTITION BY pc.category
            ORDER BY pc.may_august_change
        ) AS decline_product_rank

    FROM product_changes pc

    JOIN decline_categories dc
        ON pc.category = dc.category

    WHERE pc.may_august_change < 0
),

recovery_products AS (

    SELECT

        pc.*,

        ROW_NUMBER() OVER (
            PARTITION BY pc.category
            ORDER BY pc.august_september_change DESC
        ) AS recovery_product_rank

    FROM product_changes pc

    JOIN recovery_categories rc
        ON pc.category = rc.category

    WHERE pc.august_september_change > 0
)

SELECT

    category,

    product_key,

    sku,

    ROUND(may_revenue, 2)
        AS may_revenue,

    ROUND(august_revenue, 2)
        AS august_revenue,

    ROUND(september_revenue, 2)
        AS september_revenue,

    ROUND(may_august_change, 2)
        AS may_august_change,

    ROUND(august_september_change, 2)
        AS august_september_change,

    'Decline driver'
        AS driver_type

FROM decline_products

WHERE decline_product_rank <= 5

UNION ALL

SELECT

    category,

    product_key,

    sku,

    ROUND(may_revenue, 2)
        AS may_revenue,

    ROUND(august_revenue, 2)
        AS august_revenue,

    ROUND(september_revenue, 2)
        AS september_revenue,

    ROUND(may_august_change, 2)
        AS may_august_change,

    ROUND(august_september_change, 2)
        AS august_september_change,

    'Recovery driver'
        AS driver_type

FROM recovery_products

WHERE recovery_product_rank <= 5

ORDER BY
    driver_type,
    category,
    may_august_change;



-- ============================================================
-- QUERY 3 — NEW-CUSTOMER ACQUISITION & FIRST-MONTH VALUE
-- ============================================================
-- Business Question:
-- Did the business acquire fewer new customers from May through
-- September, and did the first-month value of those customers
-- also deteriorate?
--
-- New customer:
-- The customer's first recorded purchase in the available
-- dataset occurred in that month.
-- ============================================================

WITH first_purchase AS (

    SELECT

        f.customer_key,

        MIN(d.date)
            AS first_purchase_date

    FROM fact_sales f

    JOIN dim_date d
        ON f.date_key = d.date_key

    GROUP BY
        f.customer_key
),

new_customer_sales AS (

    SELECT

        f.customer_key,

        f.transaction_id,

        d.month,

        f.quantity,

        f.sales_amount

    FROM fact_sales f

    JOIN dim_date d
        ON f.date_key = d.date_key

    JOIN first_purchase fp
        ON f.customer_key =
           fp.customer_key

       AND d.date =
           fp.first_purchase_date

    WHERE d.year = 2016
      AND d.month BETWEEN 5 AND 9
),

monthly_new_customer_metrics AS (

    SELECT

        month,

        COUNT(DISTINCT customer_key)
            AS new_customers,

        COUNT(DISTINCT transaction_id)
            AS transactions,

        SUM(quantity)
            AS units,

        SUM(sales_amount)
            AS revenue

    FROM new_customer_sales

    GROUP BY month
)

SELECT

    month,

    new_customers,

    ROUND(
        revenue,
        2
    ) AS revenue,

    ROUND(
        revenue
        / NULLIF(
            new_customers,
            0
        ),
        2
    ) AS revenue_per_customer,

    ROUND(
        transactions
        / NULLIF(
            new_customers,
            0
        ),
        2
    ) AS transactions_per_customer,

    ROUND(
        units
        / NULLIF(
            new_customers,
            0
        ),
        2
    ) AS units_per_customer,

    ROUND(
        revenue
        / NULLIF(
            transactions,
            0
        ),
        2
    ) AS avg_transaction_value

FROM monthly_new_customer_metrics

ORDER BY month;

-- ============================================================
-- QUERY 4 — CUSTOMER COHORT & RETENTION HEALTH
-- ============================================================
-- Business Question:
-- Were the May-August customer cohorts smaller and/or weaker
-- at retaining customers than earlier cohorts?
--
-- Retention:
--   Month 1 = active one month after acquisition
--   Month 2 = active two months after acquisition
--   Month 3 = active three months after acquisition
--
-- Only cohorts with a complete observation window are used
-- for each retention age.
-- ============================================================

WITH customer_first_purchase AS (

    SELECT

        f.customer_key,

        MIN(d.date)
            AS first_purchase_date

    FROM fact_sales f

    JOIN dim_date d
        ON f.date_key = d.date_key

    GROUP BY
        f.customer_key
),

customer_cohorts AS (

    SELECT

        customer_key,

        DATE_FORMAT(
            first_purchase_date,
            '%Y-%m-01'
        ) AS cohort_month

    FROM customer_first_purchase
),

first_month_revenue AS (

    SELECT

        cc.cohort_month,

        cc.customer_key,

        SUM(f.sales_amount)
            AS first_month_revenue

    FROM customer_cohorts cc

    JOIN fact_sales f
        ON cc.customer_key =
           f.customer_key

    JOIN dim_date d
        ON f.date_key =
           d.date_key

    WHERE DATE_FORMAT(
              d.date,
              '%Y-%m-01'
          ) = cc.cohort_month

    GROUP BY

        cc.cohort_month,

        cc.customer_key
),

cohort_summary AS (

    SELECT

        cohort_month,

        COUNT(DISTINCT customer_key)
            AS cohort_customers,

        SUM(first_month_revenue)
            AS first_month_revenue

    FROM first_month_revenue

    GROUP BY cohort_month
),

customer_month_activity AS (

    SELECT DISTINCT

        f.customer_key,

        DATE_FORMAT(
            d.date,
            '%Y-%m-01'
        ) AS active_month

    FROM fact_sales f

    JOIN dim_date d
        ON f.date_key = d.date_key
),

cohort_retention AS (

    SELECT

        cc.cohort_month,

        cc.customer_key,

        MAX(
            CASE
                WHEN cma.active_month =
                     DATE_ADD(
                         cc.cohort_month,
                         INTERVAL 1 MONTH
                     )
                    THEN 1
                ELSE 0
            END
        ) AS month_1_active,

        MAX(
            CASE
                WHEN cma.active_month =
                     DATE_ADD(
                         cc.cohort_month,
                         INTERVAL 2 MONTH
                     )
                    THEN 1
                ELSE 0
            END
        ) AS month_2_active,

        MAX(
            CASE
                WHEN cma.active_month =
                     DATE_ADD(
                         cc.cohort_month,
                         INTERVAL 3 MONTH
                     )
                    THEN 1
                ELSE 0
            END
        ) AS month_3_active

    FROM customer_cohorts cc

    LEFT JOIN customer_month_activity cma

        ON cc.customer_key =
           cma.customer_key

    GROUP BY

        cc.cohort_month,

        cc.customer_key
),

retention_summary AS (

    SELECT

        cohort_month,

        SUM(month_1_active)
            AS month_1_customers,

        SUM(month_2_active)
            AS month_2_customers,

        SUM(month_3_active)
            AS month_3_customers

    FROM cohort_retention

    GROUP BY cohort_month
)

SELECT

    cs.cohort_month,

    cs.cohort_customers,

    ROUND(
        cs.first_month_revenue,
        2
    ) AS first_month_revenue,

    ROUND(
        cs.first_month_revenue
        / NULLIF(
            cs.cohort_customers,
            0
        ),
        2
    ) AS revenue_per_customer,

    CASE
        WHEN cs.cohort_month <= '2016-08-01'
            THEN ROUND(
                100.0 *
                rs.month_1_customers
                / NULLIF(
                    cs.cohort_customers,
                    0
                ),
                2
            )
    END AS month_1_retention_pct,

    CASE
        WHEN cs.cohort_month <= '2016-07-01'
            THEN ROUND(
                100.0 *
                rs.month_2_customers
                / NULLIF(
                    cs.cohort_customers,
                    0
                ),
                2
            )
    END AS month_2_retention_pct,

    CASE
        WHEN cs.cohort_month <= '2016-06-01'
            THEN ROUND(
                100.0 *
                rs.month_3_customers
                / NULLIF(
                    cs.cohort_customers,
                    0
                ),
                2
            )
    END AS month_3_retention_pct

FROM cohort_summary cs

JOIN retention_summary rs
    ON cs.cohort_month =
       rs.cohort_month

WHERE cs.cohort_month <= '2016-09-01'

ORDER BY
    cs.cohort_month;


-- ============================================================
-- QUERY 5 — CUSTOMER SEGMENT BEHAVIOR
-- ============================================================
-- Business Question:
-- Did customers with different levels of pre-May purchase
-- history behave differently during the decline and recovery?
--
-- Fixed segment definition:
--
--   No pre-May history : 0 prior transactions
--   Occasional         : 1-2 prior transactions
--   Regular            : 3-5 prior transactions
--   Frequent           : 6+ prior transactions
--
-- The segment is fixed using transactions BEFORE May 1, 2016.
-- ============================================================

WITH customer_universe AS (

    SELECT DISTINCT
        customer_key

    FROM fact_sales
),

pre_may_activity AS (

    SELECT

        f.customer_key,

        COUNT(
            DISTINCT f.transaction_id
        ) AS prior_transactions

    FROM fact_sales f

    JOIN dim_date d
        ON f.date_key = d.date_key

    WHERE d.date < '2016-05-01'

    GROUP BY
        f.customer_key
),

customer_segments AS (

    SELECT

        u.customer_key,

        CASE

            WHEN COALESCE(
                p.prior_transactions,
                0
            ) = 0
                THEN 'No pre-May history'

            WHEN p.prior_transactions BETWEEN 1 AND 2
                THEN 'Occasional'

            WHEN p.prior_transactions BETWEEN 3 AND 5
                THEN 'Regular'

            ELSE 'Frequent'

        END AS customer_segment

    FROM customer_universe u

    LEFT JOIN pre_may_activity p
        ON u.customer_key =
           p.customer_key
),

customer_month AS (

    SELECT

        d.month,

        f.customer_key,

        SUM(f.sales_amount)
            AS revenue

    FROM fact_sales f

    JOIN dim_date d
        ON f.date_key = d.date_key

    WHERE d.year = 2016
      AND d.month BETWEEN 5 AND 9

    GROUP BY

        d.month,

        f.customer_key
)

SELECT

    cm.month,

    cs.customer_segment,

    COUNT(*) AS active_customers,

    ROUND(
        SUM(cm.revenue),
        2
    ) AS revenue,

    ROUND(
        SUM(cm.revenue)
        / NULLIF(
            COUNT(*),
            0
        ),
        2
    ) AS revenue_per_active_customer

FROM customer_month cm

JOIN customer_segments cs
    ON cm.customer_key =
       cs.customer_key

GROUP BY

    cm.month,

    cs.customer_segment

ORDER BY

    cm.month,

    CASE cs.customer_segment

        WHEN 'No pre-May history'
            THEN 1

        WHEN 'Occasional'
            THEN 2

        WHEN 'Regular'
            THEN 3

        WHEN 'Frequent'
            THEN 4

    END;



-- ============================================================
-- QUERY 6 — SEPTEMBER RECOVERY SUSTAINABILITY
-- ============================================================
-- Business Question:
-- Which customer groups drove the September recovery, and
-- did those customers continue purchasing in October,
-- November and December?
--
-- Customer groups:
--   New
--   Continuing
--   Reactivated
--
-- Retention here means:
-- Percentage of September customers who were active again
-- in the specified subsequent month.
-- ============================================================

WITH customer_months AS (

    SELECT DISTINCT

        f.customer_key,

        DATE_FORMAT(
            d.date,
            '%Y-%m-01'
        ) AS month_start

    FROM fact_sales f

    JOIN dim_date d
        ON f.date_key = d.date_key
),

first_purchase AS (

    SELECT

        customer_key,

        MIN(month_start)
            AS first_month

    FROM customer_months

    GROUP BY customer_key
),

september_customers AS (

    SELECT

        cm.customer_key,

        CASE

            WHEN cm.month_start =
                 fp.first_month
                THEN 'New'

            WHEN EXISTS (

                SELECT 1

                FROM customer_months previous_month

                WHERE previous_month.customer_key =
                      cm.customer_key

                  AND previous_month.month_start =
                      DATE_SUB(
                          cm.month_start,
                          INTERVAL 1 MONTH
                      )
            )
                THEN 'Continuing'

            ELSE 'Reactivated'

        END AS customer_type

    FROM customer_months cm

    JOIN first_purchase fp
        ON cm.customer_key =
           fp.customer_key

    WHERE cm.month_start =
          '2016-09-01'
),

customer_retention AS (

    SELECT

        sc.customer_key,

        sc.customer_type,

        MAX(
            CASE
                WHEN cm.month_start =
                     '2016-10-01'
                    THEN 1
                ELSE 0
            END
        ) AS october_active,

        MAX(
            CASE
                WHEN cm.month_start =
                     '2016-11-01'
                    THEN 1
                ELSE 0
            END
        ) AS november_active,

        MAX(
            CASE
                WHEN cm.month_start =
                     '2016-12-01'
                    THEN 1
                ELSE 0
            END
        ) AS december_active

    FROM september_customers sc

    LEFT JOIN customer_months cm

        ON sc.customer_key =
           cm.customer_key

       AND cm.month_start BETWEEN
           '2016-10-01'
           AND '2016-12-01'

    GROUP BY

        sc.customer_key,

        sc.customer_type
)

SELECT

    customer_type,

    COUNT(*) AS september_customers,

    SUM(october_active)
        AS october_active,

    ROUND(
        100.0 *
        SUM(october_active)
        / NULLIF(
            COUNT(*),
            0
        ),
        2
    ) AS october_active_pct,

    SUM(november_active)
        AS november_active,

    ROUND(
        100.0 *
        SUM(november_active)
        / NULLIF(
            COUNT(*),
            0
        ),
        2
    ) AS november_active_pct,

    SUM(december_active)
        AS december_active,

    ROUND(
        100.0 *
        SUM(december_active)
        / NULLIF(
            COUNT(*),
            0
        ),
        2
    ) AS december_active_pct

FROM customer_retention

GROUP BY
    customer_type

ORDER BY

    CASE customer_type

        WHEN 'New'
            THEN 1

        WHEN 'Continuing'
            THEN 2

        WHEN 'Reactivated'
            THEN 3

    END;