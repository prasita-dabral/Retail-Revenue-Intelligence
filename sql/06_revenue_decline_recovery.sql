-- ============================================================
-- KPI 6A - Query 1: Category Revenue Decline
-- Period: May → August 2016
-- Focus: Top 5 declining categories
-- ============================================================

WITH category_revenue AS (

    SELECT
        p.sku_category,

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
        ) AS august_revenue

    FROM fact_sales f

    JOIN dim_date d
        ON f.date_key = d.date_key

    JOIN dim_product p
        ON f.product_key = p.product_key

    WHERE d.month IN (5, 8)

    GROUP BY
        p.sku_category
)

SELECT
    sku_category,

    ROUND(may_revenue, 2) AS may_revenue,

    ROUND(august_revenue, 2) AS august_revenue,

    ROUND(
        august_revenue - may_revenue,
        2
    ) AS revenue_change

FROM category_revenue

WHERE may_revenue > august_revenue

ORDER BY
    revenue_change ASC

LIMIT 5;

-- ============================================================
-- KPI 6A - Query 2: Key Product Contributors to Category Decline
-- Period: May → August 2016
-- Focus: Top 5 declining products within each top category
-- ============================================================

WITH category_revenue AS (

    SELECT
        p.sku_category,

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
        ) AS august_revenue

    FROM fact_sales f

    JOIN dim_date d
        ON f.date_key = d.date_key

    JOIN dim_product p
        ON f.product_key = p.product_key

    WHERE d.month IN (5, 8)

    GROUP BY
        p.sku_category
),

top_declining_categories AS (

    SELECT
        sku_category

    FROM category_revenue

    WHERE may_revenue > august_revenue

    ORDER BY
        august_revenue - may_revenue ASC

    LIMIT 5
),

product_revenue AS (

    SELECT
        p.sku_category,
        p.product_key,
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
        ) AS august_revenue

    FROM fact_sales f

    JOIN dim_date d
        ON f.date_key = d.date_key

    JOIN dim_product p
        ON f.product_key = p.product_key

    JOIN top_declining_categories t
        ON p.sku_category = t.sku_category

    WHERE d.month IN (5, 8)

    GROUP BY
        p.sku_category,
        p.product_key,
        p.sku
),

ranked_products AS (

    SELECT
        *,

        august_revenue - may_revenue AS revenue_change,

        ROW_NUMBER() OVER (
            PARTITION BY sku_category
            ORDER BY
                august_revenue - may_revenue ASC
        ) AS product_rank

    FROM product_revenue

    WHERE may_revenue > august_revenue
)

SELECT
    sku_category,
    product_key,
    sku,

    ROUND(may_revenue, 2) AS may_revenue,

    ROUND(august_revenue, 2) AS august_revenue,

    ROUND(revenue_change, 2) AS revenue_change,

    product_rank

FROM ranked_products

WHERE product_rank <= 5

ORDER BY
    sku_category,
    product_rank;


-- ============================================================
-- KPI 6A - Query 3: Decline Driver - Volume vs Monetization
-- Period: May → August 2016
-- Focus: Products identified in Query 2
-- ============================================================

WITH category_revenue AS (

    SELECT
        p.sku_category,

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
        ) AS august_revenue

    FROM fact_sales f

    JOIN dim_date d
        ON f.date_key = d.date_key

    JOIN dim_product p
        ON f.product_key = p.product_key

    WHERE d.month IN (5, 8)

    GROUP BY
        p.sku_category
),

top_declining_categories AS (

    SELECT
        sku_category

    FROM category_revenue

    WHERE may_revenue > august_revenue

    ORDER BY
        august_revenue - may_revenue ASC

    LIMIT 5
),

product_revenue AS (

    SELECT
        p.sku_category,
        p.product_key,
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
        ) AS august_revenue

    FROM fact_sales f

    JOIN dim_date d
        ON f.date_key = d.date_key

    JOIN dim_product p
        ON f.product_key = p.product_key

    JOIN top_declining_categories t
        ON p.sku_category = t.sku_category

    WHERE d.month IN (5, 8)

    GROUP BY
        p.sku_category,
        p.product_key,
        p.sku
),

ranked_products AS (

    SELECT
        *,

        august_revenue - may_revenue AS revenue_change,

        ROW_NUMBER() OVER (
            PARTITION BY sku_category
            ORDER BY
                august_revenue - may_revenue ASC
        ) AS product_rank

    FROM product_revenue

    WHERE may_revenue > august_revenue
),

top_products AS (

    SELECT
        *
    FROM ranked_products
    WHERE product_rank <= 5
),

product_metrics AS (

    SELECT
        t.sku_category,
        t.product_key,
        t.sku,
        t.product_rank,

        t.may_revenue,
        t.august_revenue,

        SUM(
            CASE
                WHEN d.month = 5
                THEN f.quantity
                ELSE 0
            END
        ) AS may_units,

        SUM(
            CASE
                WHEN d.month = 8
                THEN f.quantity
                ELSE 0
            END
        ) AS august_units

    FROM top_products t

    JOIN fact_sales f
        ON f.product_key = t.product_key

    JOIN dim_date d
        ON f.date_key = d.date_key

    WHERE d.month IN (5, 8)

    GROUP BY
        t.sku_category,
        t.product_key,
        t.sku,
        t.product_rank,
        t.may_revenue,
        t.august_revenue
),

calculated_metrics AS (

    SELECT
        *,

        may_revenue / NULLIF(may_units, 0)
            AS may_revenue_per_unit,

        august_revenue / NULLIF(august_units, 0)
            AS august_revenue_per_unit

    FROM product_metrics
)

SELECT

    sku_category,
    product_key,
    sku,

    may_units,
    august_units,

    ROUND(
        may_revenue_per_unit,
        2
    ) AS may_revenue_per_unit,

    ROUND(
        august_revenue_per_unit,
        2
    ) AS august_revenue_per_unit,

    ROUND(
        august_revenue - may_revenue,
        2
    ) AS revenue_change,

    CASE

        WHEN august_units = 0
             AND may_units > 0
            THEN 'No August Sales'

        WHEN august_units < may_units
             AND august_revenue_per_unit < may_revenue_per_unit
            THEN 'Both Volume and Monetization'

        WHEN august_units < may_units
            THEN 'Volume Driven'

        WHEN august_units >= may_units
             AND august_revenue_per_unit < may_revenue_per_unit
            THEN 'Monetization Driven'

        ELSE 'Other'

    END AS decline_driver

FROM calculated_metrics

ORDER BY
    sku_category,
    product_rank;


-- KPI 6B - Q1
-- Which categories recovered from August to September?

WITH category_recovery AS (

    SELECT
        p.sku_category,

        SUM(
            CASE
                WHEN d.month = 8 THEN f.sales_amount
                ELSE 0
            END
        ) AS august_revenue,

        SUM(
            CASE
                WHEN d.month = 9 THEN f.sales_amount
                ELSE 0
            END
        ) AS september_revenue

    FROM fact_sales f

    JOIN dim_date d
        ON f.date_key = d.date_key

    JOIN dim_product p
        ON f.sku = p.sku

    WHERE d.year = 2016
      AND d.month IN (8, 9)

    GROUP BY p.sku_category
)

SELECT
    sku_category,
    august_revenue,
    september_revenue,
    september_revenue - august_revenue AS recovery_amount

FROM category_recovery

WHERE september_revenue > august_revenue

ORDER BY recovery_amount DESC;


-- KPI 6B - Q2
-- Which products were the biggest recovery drivers
-- within each recovering category?

WITH product_recovery AS (

    SELECT
        p.sku_category,
        f.customer_id,
        f.sku,

        SUM(
            CASE
                WHEN d.month = 8 THEN f.sales_amount
                ELSE 0
            END
        ) AS august_revenue,

        SUM(
            CASE
                WHEN d.month = 9 THEN f.sales_amount
                ELSE 0
            END
        ) AS september_revenue

    FROM fact_sales f

    JOIN dim_date d
        ON f.date_key = d.date_key

    JOIN dim_product p
        ON f.sku = p.sku

    WHERE d.year = 2016
      AND d.month IN (8, 9)

    GROUP BY
        p.sku_category,
        f.customer_id,
        f.sku
),

ranked_products AS (

    SELECT
        sku_category,
        customer_id,
        sku_id,
        august_revenue,
        september_revenue,

        september_revenue - august_revenue AS recovery_amount,

        ROW_NUMBER() OVER (
            PARTITION BY sku_category
            ORDER BY
                september_revenue - august_revenue DESC
        ) AS recovery_rank

    FROM product_recovery

    WHERE september_revenue > august_revenue
)

SELECT
    sku_category,
    customer_id,
    sku_id,
    august_revenue,
    september_revenue,
    recovery_amount,
    recovery_rank

FROM ranked_products

WHERE recovery_rank <= 5

ORDER BY
    sku_category,
    recovery_rank;


-- KPI 6B - Q3
-- What drove product recovery?
-- Volume, monetization, both, or new/reactivated sales?

WITH product_metrics AS (

    SELECT
        p.sku_category,
        f.customer_id,
        f.sku_id,

        SUM(
            CASE
                WHEN d.month = 8 THEN f.quantity
                ELSE 0
            END
        ) AS august_units,

        SUM(
            CASE
                WHEN d.month = 9 THEN f.quantity
                ELSE 0
            END
        ) AS september_units,

        SUM(
            CASE
                WHEN d.month = 8 THEN f.sales_amount
                ELSE 0
            END
        ) AS august_revenue,

        SUM(
            CASE
                WHEN d.month = 9 THEN f.sales_amount
                ELSE 0
            END
        ) AS september_revenue

    FROM fact_sales f

    JOIN dim_date d
        ON f.date_key = d.date_key

    JOIN dim_product p
        ON f.sku_id = p.sku_id

    WHERE d.year = 2016
      AND d.month IN (8, 9)

    GROUP BY
        p.sku_category,
        f.customer_id,
        f.sku_id
),

metrics AS (

    SELECT
        sku_category,
        customer_id,
        sku_id,

        august_units,
        september_units,

        august_revenue,
        september_revenue,

        september_revenue - august_revenue AS recovery_amount,

        CASE
            WHEN august_units > 0
                THEN august_revenue / august_units
            ELSE NULL
        END AS august_revenue_per_unit,

        CASE
            WHEN september_units > 0
                THEN september_revenue / september_units
            ELSE NULL
        END AS september_revenue_per_unit

    FROM product_metrics

    WHERE september_revenue > august_revenue
),

classified AS (

    SELECT
        *,
        
        CASE

            -- Product had no August sales
            WHEN august_units = 0
                 AND september_units > 0
                THEN 'New / Reactivated'

            -- Quantity increased while revenue per unit
            -- remained approximately stable
            WHEN september_units > august_units
                 AND ABS(
                     september_revenue_per_unit
                     - august_revenue_per_unit
                 ) / NULLIF(august_revenue_per_unit, 0) < 0.05
                THEN 'Volume Driven'

            -- Quantity stayed approximately stable,
            -- while revenue per unit increased
            WHEN ABS(september_units - august_units) <= 1
                 AND september_revenue_per_unit
                     > august_revenue_per_unit * 1.05
                THEN 'Monetization Driven'

            -- Both quantity and revenue per unit increased
            WHEN september_units > august_units
                 AND september_revenue_per_unit
                     > august_revenue_per_unit * 1.05
                THEN 'Both Volume and Monetization'

            ELSE 'Minor / Mixed'

        END AS recovery_driver

    FROM metrics
)
SELECT
    sku_category,
    customer_id,
    sku_id,
    august_units,
    september_units,
    august_revenue_per_unit,
    september_revenue_per_unit,
    recovery_amount,
    recovery_driver

FROM classified

ORDER BY
    sku_category,
    recovery_amount DESC;