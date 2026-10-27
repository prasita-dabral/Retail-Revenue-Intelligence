# DAX Measures & Calculated Columns

Reference for the Power BI model in `analytics.pbix`. Every calculated column and measure used by the five dashboard pages is listed here, with a one-line explanation.

**Model:** star schema. `dim_date`, `dim_customer` and `dim_product` each filter `fact_sales` one-to-many, single direction. See [`docs/data_model.md`](../docs/data_model.md).

**Conventions**
- Measures live in an empty table named `_Measures`.
- Month filters use the month **number** (`dim_date[month]`), not time-intelligence functions, because the date table has 363 days (Jan 1, Mar 27 and Dec 25 are missing) and cannot be marked as a date table.
- Customer types: **New** = first purchase in the dataset in that month; **Continuing** = active in the previous month; **Reactivated** = seen before, but not active in the previous month.

---

## 1. Calculated columns

Create these with **Table tools → New column** (not New measure), with the table selected, **in this order**.

```dax
// fact_sales: month number of each sale, looked up from dim_date
Sales Month = RELATED ( dim_date[month] )
```

```dax
// dim_customer: the customer's first purchase month (their cohort)
First Month = CALCULATE ( MIN ( fact_sales[Sales Month] ) )
```

```dax
// dim_customer: short label for charts. Sort by column -> First Month
First Month Name = FORMAT ( DATE ( 2016, dim_customer[First Month], 1 ), "mmm" )
```

```dax
// fact_sales: 1 if the line falls in the customer's first purchase month
Is First Month Row =
IF ( fact_sales[Sales Month] = RELATED ( dim_customer[First Month] ), 1, 0 )
```

```dax
// fact_sales: months since the customer's first purchase (0 = first month)
Cohort Age = fact_sales[Sales Month] - RELATED ( dim_customer[First Month] )
```

```dax
// dim_customer: each customer's September status, blank if not active in September
Sept Status =
VAR ActiveSep = CALCULATE ( COUNT ( fact_sales[transaction_id] ), fact_sales[Sales Month] = 9 )
VAR ActiveAug = CALCULATE ( COUNT ( fact_sales[transaction_id] ), fact_sales[Sales Month] = 8 )
RETURN
    SWITCH (
        TRUE (),
        ActiveSep = 0, BLANK (),
        dim_customer[First Month] = 9, "New",
        ActiveAug > 0, "Continuing",
        "Reactivated"
    )
```

**Sort-by-column settings (Table view → select column → Column tools → Sort by column):**
`dim_date[month_name]` by `month`, and `dim_customer[First Month Name]` by `First Month`.

---

## 2. Base measures

```dax
// Total sales amount
Revenue = SUM ( fact_sales[sales_amount] )

// Distinct transactions (a transaction spans several rows)
Transactions = DISTINCTCOUNT ( fact_sales[transaction_id] )

// Total quantity sold (fractional for some SKUs)
Units = SUM ( fact_sales[quantity] )

// Distinct customers with at least one purchase in the current filter context
Active Customers = DISTINCTCOUNT ( fact_sales[customer_key] )

// Revenue per transaction
Avg Order Value = DIVIDE ( [Revenue], [Transactions] )

// Orders per active customer
Transactions per Customer = DIVIDE ( [Transactions], [Active Customers] )

// Revenue per active customer
Revenue per Customer = DIVIDE ( [Revenue], [Active Customers] )

// Revenue per calendar day present in the date table
Revenue per Day = DIVIDE ( [Revenue], COUNTROWS ( dim_date ) )
```

---

## 3. Page 1: The Problem

```dax
// Revenue for a fixed month, ignoring any month selection
May Revenue       = CALCULATE ( [Revenue], dim_date[month] = 5 )
August Revenue    = CALCULATE ( [Revenue], dim_date[month] = 8 )
September Revenue = CALCULATE ( [Revenue], dim_date[month] = 9 )

// Percentage change, May to August (expected -18.1%)
Change May to Aug % = DIVIDE ( [August Revenue] - [May Revenue], [May Revenue] )

// Percentage change, August to September (expected +20.8%)
Change Aug to Sep % = DIVIDE ( [September Revenue] - [August Revenue], [August Revenue] )
```

The first card, "Full-Year Revenue", uses `[Revenue]` with no filter.

---

## 4. Page 2: Customers, Not Spending

### Customer-flow measures (also used on Pages 4 and 5)

```dax
// Returns the month number when exactly one month is in context, otherwise blank.
// Guards the flow measures so totals do not show misleading numbers.
Selected Month = IF ( HASONEVALUE ( dim_date[month] ), VALUES ( dim_date[month] ) )
```

```dax
// Customers whose first purchase falls in the current month
New Customers =
CALCULATE ( DISTINCTCOUNT ( fact_sales[customer_key] ), fact_sales[Is First Month Row] = 1 )
```

```dax
// Customers active this month who were also active last month.
// Builds last month's customer list (ignoring date and product filters)
// and intersects it with this month's customers.
Continuing Customers =
VAR M = [Selected Month]
VAR PrevCust =
    CALCULATETABLE (
        VALUES ( fact_sales[customer_key] ),
        ALL ( dim_date ),
        ALL ( dim_product ),
        fact_sales[Sales Month] = M - 1
    )
RETURN
    IF (
        NOT ISBLANK ( M ),
        COUNTROWS ( INTERSECT ( VALUES ( fact_sales[customer_key] ), PrevCust ) )
    )
```

```dax
// Everyone else active this month: seen before, but not last month
Reactivated Customers =
IF (
    NOT ISBLANK ( [Selected Month] ),
    [Active Customers] - [New Customers] - [Continuing Customers]
)
```

```dax
// Revenue from each customer type; the three always sum to [Revenue]
New Revenue = CALCULATE ( [Revenue], fact_sales[Is First Month Row] = 1 )

Continuing Revenue =
VAR M = [Selected Month]
VAR PrevCust =
    CALCULATETABLE (
        VALUES ( fact_sales[customer_key] ),
        ALL ( dim_date ),
        ALL ( dim_product ),
        fact_sales[Sales Month] = M - 1
    )
RETURN
    IF ( NOT ISBLANK ( M ), CALCULATE ( [Revenue], fact_sales[customer_key] IN PrevCust ) )

Reactivated Revenue =
IF (
    NOT ISBLANK ( [Selected Month] ),
    [Revenue] - [New Revenue] - [Continuing Revenue]
)
```

### May to August change by customer type (the three cards)

```dax
// Expected: -38,907.80
New Rev Change May-Aug =
CALCULATE ( [New Revenue], dim_date[month] = 8 ) - CALCULATE ( [New Revenue], dim_date[month] = 5 )

// Expected: -8,377.62
Continuing Rev Change May-Aug =
CALCULATE ( [Continuing Revenue], dim_date[month] = 8 ) - CALCULATE ( [Continuing Revenue], dim_date[month] = 5 )

// Expected: +21,474.54
Reactivated Rev Change May-Aug =
CALCULATE ( [Reactivated Revenue], dim_date[month] = 8 ) - CALCULATE ( [Reactivated Revenue], dim_date[month] = 5 )
```

### Orders versus basket (check against your own versions)

```dax
// Expected about -24.2% (6,134 to 4,648)
Orders Change May to Aug % =
DIVIDE (
    CALCULATE ( [Transactions], dim_date[month] = 8 ) - CALCULATE ( [Transactions], dim_date[month] = 5 ),
    CALCULATE ( [Transactions], dim_date[month] = 5 )
)

// Expected about +8.1% ($23.27 to $25.15)
Order Value Change May to Aug % =
DIVIDE (
    CALCULATE ( [Avg Order Value], dim_date[month] = 8 ) - CALCULATE ( [Avg Order Value], dim_date[month] = 5 ),
    CALCULATE ( [Avg Order Value], dim_date[month] = 5 )
)
```

---

## 5. Page 3: The Broken Pipeline

```dax
// New customers in May (2,626) and August (1,060)
New Customers May = CALCULATE ( [New Customers], dim_date[month] = 5 )
New Customers Aug = CALCULATE ( [New Customers], dim_date[month] = 8 )

// Change in new customers, May to August (expected -59.6%)
New Customer Change % =
DIVIDE ( [New Customers Aug] - [New Customers May], [New Customers May] )
```

```dax
// Size of a cohort: customers active in their first month (age 0)
Cohort Size =
CALCULATE ( DISTINCTCOUNT ( fact_sales[customer_key] ), fact_sales[Cohort Age] = 0 )

// Share of the cohort active at each age (used in the heatmap, ages 1 to 6)
Cohort Retention % = DIVIDE ( [Active Customers], [Cohort Size] )

// Share of the cohort active in the month after their first (March cohort 28.2%)
Month 1 Retention % =
DIVIDE (
    CALCULATE ( DISTINCTCOUNT ( fact_sales[customer_key] ), fact_sales[Cohort Age] = 1 ),
    [Cohort Size]
)
```

**Visual filters:** cohort charts and the matrix use `First Month` between 2 and 9 (January is excluded because it is not a true cohort); the matrix also filters `Cohort Age` to 1 to 6. The "New customers per month" chart excludes January through `month_name` and has no cohort filter, so it shows February to December.

---

## 6. Page 4: Not a Product Problem

```dax
// Change in revenue by category, May to August
Revenue Change May to Aug = [August Revenue] - [May Revenue]
Revenue Change Aug to Sep = [September Revenue] - [August Revenue]

// Number of categories whose revenue fell (expected 119)
Categories Declining =
COUNTROWS ( FILTER ( VALUES ( dim_product[sku_category] ), [Revenue Change May to Aug] < 0 ) )

// Categories with sales in May or August (expected 173)
Categories Active May or Aug =
COUNTROWS (
    FILTER ( VALUES ( dim_product[sku_category] ), [May Revenue] > 0 || [August Revenue] > 0 )
)
```

The two bar charts use **Top N filters** on `sku_category` by `[Revenue Change May to Aug]` (Bottom 10 for decliners, Top 10 for gainers). The matrix uses a Bottom 3 filter and shows the three `Rev Change May-Aug` measures from Section 4.

---

## 7. Page 5: Recovery and What to Do

```dax
// Customers active in September, ignoring any month selection
Sept Group Size =
CALCULATE ( DISTINCTCOUNT ( fact_sales[customer_key] ), fact_sales[Sales Month] = 9, ALL ( dim_date ) )

// Share of a September group still active in the selected month
Sept Group Retention % = DIVIDE ( [Active Customers], [Sept Group Size] )

// Revenue the group generates in the selected month, as a share of its September revenue
Sept Group Revenue Persistence % =
DIVIDE ( [Revenue], CALCULATE ( [Revenue], fact_sales[Sales Month] = 9, ALL ( dim_date ) ) )
```

```dax
// Share of each month's revenue by customer type (100% stacked chart)
New Revenue Share         = DIVIDE ( [New Revenue], [Revenue] )
Continuing Revenue Share  = DIVIDE ( [Continuing Revenue], [Revenue] )
Reactivated Revenue Share = DIVIDE ( [Reactivated Revenue], [Revenue] )
```

**Visual filters:** both matrices use `Sept Status` is not blank and months September to December; the share chart uses `month` between 5 and 12.

---

## 8. Validation values

If a value on screen differs, the measure or a filter is wrong.

| Measure | Expected |
|---|---|
| `[May Revenue]` / `[August Revenue]` / `[September Revenue]` | 142,719.86 / 116,908.98 / 141,239.89 |
| `[Change May to Aug %]` / `[Change Aug to Sep %]` | −18.1% / +20.8% |
| `[Active Customers]` May / Aug / Sep | 4,418 / 3,303 / 4,089 |
| `[Transactions]` May / Aug / Sep | 6,134 / 4,648 / 5,732 |
| `[New Customers]` May / Aug / Sep | 2,626 / 1,060 / 1,625 |
| `[Continuing Customers]` May / Aug / Sep | 1,327 / 1,192 / 1,246 |
| `[Reactivated Customers]` May / Aug / Sep | 465 / 1,051 / 1,218 |
| `[New Revenue]` Aug / Sep | 27,765.95 / 40,269.86 |
| `[Continuing Revenue]` Aug / Sep | 51,814.39 / 60,658.11 |
| `[Reactivated Revenue]` Aug / Sep | 37,328.64 / 40,311.92 |
| `[Categories Declining]` / `[Categories Active May or Aug]` | 119 / 173 |
| `[Month 1 Retention %]` March / August cohorts | 28.2% / 15.4% |
| `[Sept Group Retention %]` October, new / continuing / reactivated | 19.0% / 60.8% / 36.0% |
| `[Sept Group Revenue Persistence %]` October, new / continuing / reactivated | 22.2% / 72.1% / 48.7% |

---

## 9. Troubleshooting

| Error or symptom | Cause | Fix |
|---|---|---|
| "A single value for column 'First Month' ... cannot be determined" | A column formula was created as a **measure** | Delete it, select the table, use **New column** |
| Flow measures blank in a total row | By design: `[Selected Month]` is blank when several months are in context | Put `month_name` on the axis or in rows |
| Months in the wrong order | Missing sort-by-column | Set `month_name` to sort by `month` |
| Q4 missing from "New customers per month" | A page-level filter on `First Month` | Remove it; keep cohort filters on the cohort visuals only |
| Cohort matrix shows a 100% column | No filter on `Cohort Age` | Add a visual filter, `Cohort Age` between 1 and 6 |
| "(Blank)" row in the Page 5 matrices | `Sept Status` not filtered | Add a visual filter excluding blank |
| Circular dependency error | Columns created out of order | Create columns in the order in Section 1 |