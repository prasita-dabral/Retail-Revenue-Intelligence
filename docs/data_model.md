# Data Model Documentation

## Overview

The cleaned retail transaction data was transformed into a dimensional data model to support analytical queries, KPI analysis, and Power BI reporting.

The model follows a **star schema**, consisting of one central fact table surrounded by three dimension tables.

## Dataset Grain

The original dataset represents individual SKU-level line items within customer transactions.

Therefore, the analytical grain of the fact table is:

> **One SKU line item within one transaction on one date.**

This means that a single transaction can contain multiple rows when multiple SKUs are purchased.

## Star Schema

The analytical model consists of:

- `fact_sales` — central transactional fact table
- `dim_date` — date and calendar attributes
- `dim_customer` — customer attributes
- `dim_product` — product and category attributes

The dimensions provide descriptive context for the measures stored in the fact table.

## Tables

### fact_sales

The fact table stores the measurable sales activity.

| Column | Description |
|---|---|
| `transaction_id` | Identifies the transaction |
| `date_key` | Foreign key to `dim_date` |
| `customer_key` | Foreign key to `dim_customer` |
| `product_key` | Foreign key to `dim_product` |
| `quantity` | Quantity sold for the line item |
| `sales_amount` | Sales amount for the line item |

### dim_date

The date dimension provides calendar attributes used for time-based analysis.

| Column | Description |
|---|---|
| `date_key` | Surrogate date key |
| `date` | Calendar date |
| `year` | Year |
| `quarter` | Quarter |
| `month` | Month number |
| `month_name` | Month name |
| `day` | Day of month |
| `day_name` | Day name |
| `week` | Week number |
| `is_weekend` | Weekend indicator |

### dim_customer

The customer dimension provides a unique analytical reference for customers.

| Column | Description |
|---|---|
| `customer_key` | Surrogate customer key |
| `customer_id` | Original customer identifier |

### dim_product

The product dimension provides product and category information.

| Column | Description |
|---|---|
| `product_key` | Surrogate product key |
| `sku` | Stock keeping unit |
| `sku_category` | Product category |

## Relationships

The model uses one-to-many relationships from each dimension to the fact table:

- `dim_date[date_key]` → `fact_sales[date_key]`
- `dim_customer[customer_key]` → `fact_sales[customer_key]`
- `dim_product[product_key]` → `fact_sales[product_key]`

Each dimension record can therefore relate to multiple sales line items.

## Why a Star Schema?

A star schema was selected because it provides a simple and efficient structure for analytical workloads.

It allows:

- sales to be analyzed across different dates,
- customer-level performance to be evaluated,
- products and categories to be compared,
- time-based KPIs to be calculated consistently, and
- the same model to support both SQL analysis and Power BI reporting.

## Analytical Use

The model supports the project's downstream analysis, including:

- overall revenue performance,
- monthly revenue trends,
- product performance,
- customer intelligence,
- category intelligence,
- revenue decline and recovery analysis, and
- Power BI dashboard reporting.