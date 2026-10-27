# Initial Findings & Focus Selection

**Retail Revenue Intelligence Project**
Analysis period: full year 2016

---

## 1. Purpose of the Initial Analysis

Before any deep investigation, five foundational analyses were run (SQL files `01` to `05` in `sql/`):

1. Overall KPI analysis
2. Time-series analysis
3. Product analysis
4. Customer intelligence
5. Category intelligence

The goal was to:

- establish a baseline of business performance,
- identify the most important patterns and anomalies,
- decide which issues deserved deeper investigation, and
- avoid spreading effort across every possible dimension.

This document summarizes the findings and explains why one issue was selected for the deep dive.

---

## 2. Summary of Initial Findings

### 2.1 Overall Business Baseline (KPI Analysis)

| Metric | Value |
|---|---:|
| Total revenue | $1,578,039 |
| Total transactions | 64,682 |
| Unique customers | 22,625 |
| Total units sold | 195,624 |
| Average transaction value | $24.40 |
| Units per transaction | 3.02 |
| Revenue per unit | $8.07 |

The business shows solid full-year performance, with a healthy average transaction value and units per transaction. Note that quantity is fractional for some SKUs, so "units" are not always item counts.

---

### 2.2 Time-Series Analysis: the Dominant Pattern

| Month | Revenue | | Month | Revenue |
|---|---:|---|---|---:|
| January | $111,200 | | July | $120,592 |
| February | $122,115 | | August | $116,909 |
| March | $127,925 | | September | $141,240 |
| April | $138,172 | | October | $140,854 |
| May | $142,720 | | November | $132,883 |
| June | $131,305 | | December | $152,124 |

- Revenue rose steadily from January to May (peak of **$142,720**).
- It declined for three consecutive months from June to August (trough of **$116,909**).
- It recovered sharply in September (**$141,240**, +20.8%).

**May to August decline:** −$25,811 (−18.1%)
**August to September recovery:** +$24,331 (+20.8%)

This was the most significant and actionable pattern in the data. December is the highest month of the year ($152,124), and November dips, but neither is a break from trend of the same size, so they were left as context.

---

### 2.3 Customer Intelligence

- Average revenue per customer: $69.75
- Median revenue per customer: $23.85
- 51% of customers made only one transaction
- The top 10% of customers generated 56.6% of revenue
- The top 20% of customers generated 72.9% of revenue

**Interpretation:** the customer base is polarized. A large number of one-time or low-value buyers sit alongside a smaller group of high-value customers who drive most of the revenue.

---

### 2.4 Category Intelligence

- 187 categories in total
- Top 5 categories: 24.6% of revenue
- Top 10 categories: 36.5% of revenue
- Top 20 categories: 55.0% of revenue

**Interpretation:** concentration is moderate, not extreme. The business is not dependent on one or two categories, but a limited group still carries meaningful weight.

---

### 2.5 Product Analysis

- Revenue follows a typical long-tail distribution.
- A relatively small number of products generate a large share of revenue.
- Many products contribute very small amounts.
- High-unit products do not always generate high revenue (low revenue-per-unit items exist).

---

## 3. Decision: What to Investigate Further

### Selected for deep investigation

**Primary focus: the May to August revenue decline and the September recovery.**

Reasons:

- It is the largest and most visible swing in the year.
- The decline is material (−18.1%), and the recovery almost as large (+20.8%).
- Understanding both sides has high business value.
- It offers a clear hypothesis path: volume versus value, then customer composition, then category concentration, then the recovery mechanism.

### Acknowledged but not selected

| Finding | Why it was not prioritized | How it is used |
|---|---|---|
| Polarized customer base | Important context, but not the main performance swing | Supporting context; the 51% one-time share reappears in the recommendations |
| Moderate category concentration | Useful background with low incremental decision value | Supporting context |
| Long-tail product distribution | Expected in retail; limited new insight | Background only |
| High-value customer concentration | Relevant, but secondary to the temporal decline | Light contextual mention |
| December peak and November dip | Smaller deviations than May to September, and outside the focus window | Not analyzed; a candidate for follow-up |

---

## 4. Rationale for the Chosen Focus

The project follows a principle of **analytical focus**. The May to August decline and September recovery stood out because of:

1. **Magnitude:** the largest performance deviation of the year.
2. **Clarity:** three consecutive months of decline followed by a sharp recovery.
3. **Actionability:** understanding the drivers can inform acquisition, category management and monitoring decisions.
4. **Diagnostic potential:** it allows a structured investigation across volume, customers and categories.

**A limit on this choice.** Only one year of data is available, so a seasonal pattern cannot be ruled out. The deep dive therefore describes where the shortfall came from and treats "why" as an open question.

---

## 5. Link to Subsequent Analysis

The deep dive that followed ([deep_dive_analysis.md](../reports/deep_dive_analysis.md)) was structured as:

1. Quantify the decline and decompose volume versus value.
2. Examine the customer composition of the decline.
3. Identify category and product drivers.
4. Analyze the September recovery.
5. Map customer flow (new, continuing, reactivated).
6. Test the sustainability of the recovery.

The results are summarized in the [executive memo](../reports/executive_memo.md) and the [key insights](../reports/key_insights_and_recommendations.md).

---

## 6. Summary

The five initial analyses established the baseline and surfaced the key performance issue. The decision to focus on the May to August decline and September recovery was deliberate. Other findings, customer polarization and category concentration, were kept as context rather than expanded into separate workstreams.

This focus let the project move from broad description to a clear diagnosis with actionable recommendations.