# Data Quality Summary

## Dataset Overview

The project uses one year of retail point-of-sale data covering 2016.

| Item | Value |
|---|---|
| Source file | `scanner_data.csv` |
| Line items (rows) | 131,706 |
| Transactions | 64,682 |
| Customers | 22,625 |
| SKUs / categories | 5,242 / 187 |
| Date coverage | January 2, 2016 to December 31, 2016 |
| Fields | date, customer ID, transaction ID, SKU category, SKU, quantity, sales amount |

The data holds individual SKU line items within transactions, not one row per transaction. This matters when assessing duplicates, defining the analytical grain and designing the data model.

## Data Quality Assessment

| Check | Finding | Decision |
|---|---|---|
| Missing values | None across the dataset | No action |
| Exact duplicate rows | 0 | No action |
| Transaction IDs | `Transaction_ID` repeats across rows (2.04 line items per transaction on average, 21 at most) because it is a transaction identifier, not a row key. Within a transaction there is exactly one customer and one date, and no product repeats | Retain; count with `COUNT(DISTINCT transaction_id)` |
| Date validity | No invalid dates; January 2 to December 31, 2016 | Retain |
| Calendar completeness | 363 distinct dates. January 1, March 27 (Easter Sunday) and December 25 have no sales, likely closures | Retain; document (see below) |
| Quantity | No zero or negative values; range 0.01 to 400; 375 rows are fractional | Retain; document (see below) |
| Sales amount | No zero or negative values | Retain |
| Quantity outliers | The IQR method flags 21.99%, but Q1 = Q3 = 1, so IQR = 0 and the method is unsuitable for business outlier detection | Retain |
| Sales amount outliers | The IQR method flags 9.65% (Q1 = $4.23, Q3 = $12.33). A review found no obvious data-entry errors | Retain |
| Referential integrity (after modeling) | No orphan keys: every `date_key`, `customer_key` and `product_key` in the fact table matches a dimension row | No action |

## Key Observations

### 1. Transaction ID repetition is expected
`Transaction_ID` identifies a transaction, not a row. The repeated IDs were retained rather than treated as duplicates. Transaction counts, average transaction value and customer frequency all depend on counting distinct IDs, never rows.

### 2. Quantity is fractional for some SKUs
Quantity is fractional on 375 rows, which suggests items sold by weight or volume. "Units sold" is therefore not always an item count, and revenue per unit mixes different kinds of unit. It is still useful as a trend, but not as a like-for-like price.

### 3. Quantity outliers are not meaningful under IQR
Because the quartiles are identical (Q1 = Q3 = 1), the IQR rule flags every value that is not 1. Observations were retained.

### 4. Sales amount outliers look legitimate
The 9.65% flagged as statistically unusual were reviewed and did not look like entry errors. They are plausible high-value baskets or lines and were retained.

### 5. The calendar has gaps
The date table holds only the 363 dates that appear in the data. January 1, March 27 and December 25 are missing, probably store closures. This does not affect the May to September analysis, but it means:

- Days with no sales are not represented as zero-revenue days.
- The table is not a full calendar, so Power BI time-intelligence functions are not used.

## Analytical Caveats Carried Forward

These are not errors, but they affect interpretation.

| Caveat | Effect |
|---|---|
| **One year of data** | A seasonal pattern cannot be separated from a real change |
| **Left-censoring of "new" customers** | "New" means first *observed* purchase. The data starts January 2, so January customers may have bought before, and early months overstate new customers |
| **Reactivation is partly mechanical** | The pool of lapsed customers only grows during the year, so reactivated counts rise even without a change in behavior |
| **Unexplained cohort break** | January and February cohorts fade to about 1% retention, while every cohort from March on plateaus at 12–24%. This may reflect a data or business change and should be validated before treating early cohorts as benchmarks |
| **One-time buyers** | 51% of customers purchase once, so late-year cohorts, which have had less time to repeat, look weaker on frequency than early ones |
| **No customer attributes** | The customer table holds only an ID, so analysis is behavioral rather than demographic |

## Final Data Quality Decision

No confirmed data-quality errors requiring row-level deletion were found, and no rows were removed on the basis of statistical outlier detection alone. The original observations were retained, and structural cleaning and transformation were done in the ETL stage.

The dataset is suitable for the downstream analysis, subject to the caveats above, which are repeated in the limitations sections of the deep dive and the executive memo.