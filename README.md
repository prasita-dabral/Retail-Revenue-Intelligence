# Retail Revenue Decline & Recovery Analysis (2016)

**Diagnosing an 18% revenue dip and testing whether the recovery lasted** — an end-to-end analytics project using Python, SQL (MySQL) and Power BI.

> **Short on time?** Read the [executive memo](reports/executive_memo.md) (3 minutes) and look at the dashboard screenshots below.

---

## The Question

A retailer's revenue peaked in May 2016, fell for three straight months, then jumped back in September. What drove the decline, why did revenue recover, and was the recovery sustainable?

## The Answer in Brief

Revenue fell **18.1%** from May to August (**$142,720 to $116,909**) and recovered **20.8%** in September to **$141,240**.

- **The decline was volume, not value.** Transactions fell 24% while average order value rose 8%.
- **The clearest driver was new-customer acquisition,** which fell **59.6%** (2,626 in May to 1,060 in August). The new customers who did arrive also retained worse.
- **The category decline was broad-based:** 119 of 173 categories fell, and the ten largest decliners account for about 36% of the loss. It largely followed who stopped arriving.
- **September restored revenue but not acquisition.** New-customer arrivals fell back to about 1.2–1.4K a month in Q4 (against 2,200–2,600 in February to May), and revenue now leans more on returning customers.

---

## Dashboard Preview

| | |
|---|---|
| ![Page 1](powerbi/screenshots/page1_the_problem.png) **1. Revenue fell 18%, then recovered** | ![Page 2](powerbi/screenshots/page2_customers_not_spending.png) **2. Fewer customers bought, but behavior held** |
| ![Page 3](powerbi/screenshots/page3_the_broken_pipeline.png) **3. New-customer acquisition fell 60%** | ![Page 4](powerbi/screenshots/page4_not_a_product_problem.png) **4. Not caused by one category** |
| ![Page 5](powerbi/screenshots/page5_recovery.png) **5. Recovery held, but leans on returning customers** | |

Page-by-page explanation: [`docs/dashboard_story.md`](docs/dashboard_story.md)

---

## Key Insights

1. **A volume problem, not a value problem.** Transactions 6,134 to 4,648; active customers 4,418 to 3,303; average transaction value $23.27 to $25.15 (partly a mix effect, since new customers spend less per order).
2. **New-customer acquisition collapsed.** The drop was a step change in June, and nearly all of it was headcount rather than spend per customer.
3. **Newer cohorts retained worse.** Month-1 retention was 28–29% for March and April, against 14–18% for the June to August cohorts.
4. **Reactivated customers cushioned the fall.** May to August revenue change: new −$38.9K, continuing −$8.4K, reactivated +$21.5K.
5. **The recovery was volume-led but uneven.** Of September's customers, 60.8% of continuing, 36.0% of reactivated and 19.0% of new customers were active again in October.

### Recommendations
1. Diagnose the fall in new-customer acquisition (channels, traffic, conversion, promotions, assortment).
2. Improve early-life retention, especially first-to-second purchase conversion.
3. Protect continuing customers and build reactivation programs.
4. Review the highest-impact declining categories, after testing whether they simply reflect lost new customers.
5. Track leading indicators: new customers per month, month-1 retention, reactivated customers, revenue share by customer type.

Full detail: [`reports/key_insights_and_recommendations.md`](reports/key_insights_and_recommendations.md) · [`reports/deep_dive_analysis.md`](reports/deep_dive_analysis.md)

---

## Project Workflow

| Step | What was done | Where |
|---|---|---|
| 1. Understand the data | Business context, fields, grain | `notebooks/01_data_understanding.ipynb` |
| 2. Assess quality | Missing values, duplicates, outliers, validity | `notebooks/02_data_quality_assessment.ipynb` · [`docs/data_quality_summary.md`](docs/data_quality_summary.md) |
| 3. ETL | Clean, transform, prepare for modeling | `notebooks/03_etl_workflow.ipynb` |
| 4. Model | Star schema: one fact table, three dimensions | `notebooks/04_dimensional_data_modeling.ipynb` · [`docs/data_model.md`](docs/data_model.md) |
| 5. Baseline analysis | KPIs, time series, products, customers, categories | `notebooks/05_sql_analysis.ipynb` · `sql/01` to `05` · [`docs/initial_findings_and_focus_selection.md`](docs/initial_findings_and_focus_selection.md) |
| 6. Deep dive | Six-query diagnosis of the decline and recovery | `sql/Diagnosing Revenue Decline and Evaluating Recovery Sustainability.sql` · [`reports/deep_dive_analysis.md`](reports/deep_dive_analysis.md) |
| 7. Dashboard | Five-page Power BI story | `powerbi/analytics.pbix` |

## Data Model

```
dim_date ──┐
dim_customer ──┼──< fact_sales (one row = one SKU line item in one transaction)
dim_product ──┘
```

- **131,706** line items · **64,682** transactions · **22,625** customers · **5,242** SKUs in **187** categories
- January 2 to December 31, 2016

---

## Tech Stack

| Area | Tools |
|---|---|
| Data prep and EDA | Python (pandas, NumPy, Matplotlib), Jupyter |
| Analysis | SQL (MySQL): CTEs, window functions, cohort and customer-flow queries |
| Visualization | Power BI, DAX (customer-flow, cohort and retention measures) |
| Methods | Volume/value decomposition, customer-flow classification, cohort retention, segmentation |

---

## Repository Structure

```

Retail-Revenue-Intelligence/

│
├── data/
│   ├── raw/
│   │   └── scanner_data.csv
│   │
│   └── processed/
│       ├── dim_customer.csv
│       ├── dim_date.csv
│       ├── dim_product.csv
│       ├── fact_sales.csv
│       └── scanner_data_clean.csv
│
├── notebooks/
│   ├── 01_Data_Understanding.ipynb
│   ├── 02_Data_Quality_Assessment.ipynb
│   ├── 03_etl_workflow.ipynb
│   ├── 04_dimensional_data_modeling.ipynb
│   ├── 05_sql_analysis.ipynb
│
├── sql/
│   ├── 01_kpi_analysis.sql
│   ├── 02_time_series_analysis.sql
│   ├── 03_product_analysis.sql
│   ├── 04_customer_intelligence.sql
│   ├── 05_category_intelligence.sql
│   └── Diagnosing Revenue Decline and Evaluating Recovery Sustainability
│
├── powerbi/                                   
│   ├── analytics.pbix
│   ├── dax_measures.md
│   └── screenshots/
│       ├── BI_report1.png
│       ├── BI_report2.png
│       ├── BI_report3.png
│       ├── BI_report4.png
│       └── BI_report5.png
│
├── reports/                  
│   ├── executive_memo.md
│   ├── key_insights_and_recommendations.md
│   └── deep_dive_analysis.md
│   ├── initial_findings_and_focus_selection.md
|
├── docs/                     
│   ├── data_model.md
│   ├── data_quality_summary.md
│   └── dashboard_story.md
│
├── .gitignore
├── README.md
└── requirements.txt


---

## How to Reproduce

1. **Set up Python:** `pip install -r requirements.txt`
2. **Run the notebooks in order** (`01` to `05`). Notebooks `03` and `04` produce the cleaned data and the star-schema tables in `data/processed/`.
3. **Load the tables into MySQL.** Notebook `05` loads and creates them; update the connection settings (host, user, database) to match your setup.
4. **Run the SQL files in order** (`sql/01` to `sql/06`). Query results are saved in `outputs/query_results/`.
5. **Open `powerbi/analytics.pbix`.** If the data source path breaks, go to *Home → Transform data → Data source settings* and point it at `data/processed/`.

---

## Limitations

- **One year of data.** A seasonal summer dip cannot be separated from a real acquisition problem.
- **"New" means first observed purchase.** The data starts on January 2, so January customers may have bought before.
- **No cause data.** There is no marketing, traffic, inventory, pricing or promotion data, so the analysis shows *where* the shortfall came from, not *why*.
- **An unexplained cohort break.** January and February cohorts fade to about 1% retention, while every cohort from March on plateaus at 12–24%.

---

## Data

Source: `[add dataset name and link]`. Check the dataset's license before publishing the raw file; the customer field is an anonymous ID. See [`docs/data_quality_summary.md`](docs/data_quality_summary.md) for the quality checks and caveats.

## Author

**Prasita Dabral** · `[www.linkedin.com/in/prasita-dabral / prasitadabral@gmail.com]`