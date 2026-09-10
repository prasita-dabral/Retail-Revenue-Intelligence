# Data Quality Summary

## Dataset Overview

The project uses one year of retail point-of-sale transaction data covering 2016.

The raw dataset contains 131,706 transaction line items and includes information on:

- transaction date,
- customer,
- transaction,
- SKU category,
- SKU,
- quantity, and
- sales amount.

The dataset represents individual SKU-level line items within transactions rather than one row per transaction. This distinction is important when assessing duplicates, defining the analytical grain, and designing the downstream data model.

## Data Quality Assessment

| Check | Finding | Decision |
|---|---|---|
| Missing Values | No missing values identified across the dataset | No action required |
| Duplicate Rows | 0 exact duplicate rows | No action required |
| Transaction IDs | `Transaction_ID` is repeated across multiple rows, indicating transaction-level line items rather than duplicate records | Retain |
| Date Validity | No invalid dates; coverage from January 2, 2016 to December 31, 2016 | Retain |
| Quantity | No zero or negative quantities; all values are positive | Retain |
| Sales Amount | No zero or negative sales amounts; all values are positive | Retain |
| Quantity Outliers | IQR method flagged 21.99%; however, Q1 = Q3 = 1, resulting in IQR = 0 and making the method unsuitable for meaningful business outlier detection | Retain |
| Sales Amount Outliers | IQR method flagged 9.65% as statistically unusual; review did not indicate obvious data-entry errors | Retain |

## Key Data Quality Observations

### Transaction ID Repetition

`Transaction_ID` is not unique at the row level.

This is expected because the dataset represents individual SKU line items within transactions. Therefore, multiple rows can belong to the same transaction.

These repeated transaction IDs were retained rather than incorrectly treating them as duplicate records.

### Quantity Outliers

The IQR method identified a large proportion of quantity values as statistical outliers.

However, the underlying quartiles were:

- Q1 = 1
- Q3 = 1
- IQR = 0

Because the IQR is zero, the standard IQR outlier rule does not provide a meaningful business-level distinction for quantity in this dataset.

The observations were therefore retained.

### Sales Amount Outliers

The IQR method identified 9.65% of sales amounts as statistically unusual.

These observations were reviewed and did not indicate obvious data-entry errors. They were therefore retained as potentially legitimate transaction behavior.

## Final Data Quality Decision

No confirmed data-quality errors requiring row-level deletion were identified.

The dataset was considered suitable for downstream analysis.

No rows were removed based solely on statistical outlier detection. Instead, the original observations were retained, with structural cleaning and transformations performed during the ETL stage.

This approach preserves legitimate transaction behavior while avoiding unnecessary data loss.