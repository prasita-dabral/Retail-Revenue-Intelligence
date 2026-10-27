# Deep-Dive Analysis

## Retail Revenue Decline & Recovery Analysis — 2016

**Objective:** Identify the observed drivers of the May to August revenue decline, explain the September recovery, and assess whether the recovery was sustainable.

**Data:** 131,706 line items, 64,682 transactions, 22,625 customers, January 2 to December 31, 2016. Metrics reconcile exactly: changes by customer type, category and cohort each sum to the total revenue change.

### Definitions
| Term | Meaning |
|---|---|
| **New** | Customer's first recorded purchase in the dataset, in that month |
| **Continuing** | Active in the immediately preceding month |
| **Reactivated** | Seen before, but not active in the preceding month |
| **Lost** | Active in the preceding month, not active in the current month |
| **Cohort** | Customers grouped by first-purchase month |
| **Month-1 retention** | Share of a cohort active again in the month after its first |

---

# 1. Business Question

Revenue peaked in May, declined for three consecutive months, then recovered sharply in September. The deep dive asks:

1. What drove the May to August decline?
2. Was the problem volume, transaction value, or both?
3. Which customer movements contributed?
4. Which categories and products contributed, and did they also drive the recovery?
5. Was the September recovery likely to last?

The analysis deliberately focuses on the largest movement in the year rather than spreading across unrelated topics.

---

# 2. Revenue Decline: What Changed?

| Month | Revenue | Change | Transactions | ATV | Active customers |
|---|---:|---:|---:|---:|---:|
| May | $142,719.86 | — | 6,134 | $23.27 | 4,418 |
| June | $131,305.35 | −8.00% | 5,213 | $25.19 | 3,720 |
| July | $120,591.97 | −8.16% | 4,673 | $25.81 | 3,353 |
| August | $116,908.98 | −3.05% | 4,648 | $25.15 | 3,303 |
| September | $141,239.89 | +20.81% | 5,732 | $24.64 | 4,089 |

From May to August revenue fell **$25,810.88 (−18.1%)**. Over the same period transactions fell 24.2% (6,134 to 4,648), active customers fell 25.2% (4,418 to 3,303) and units fell 24.0% (18,295 to 13,902), while ATV rose 8.1%.

> **Finding 1:** The decline was associated with lower customer and transaction volume, not a deterioration in transaction value.

Per day, September ($4,708) was higher than May ($4,604), so the dip was sharp but short.

---

# 3. Revenue Decomposition: Volume vs. Value

Each month's change is split into a transaction-count effect and an ATV effect.

| Period | Revenue change | Transaction-count effect | ATV effect |
|---|---:|---:|---:|
| May to June | −$11.4K | −$22.3K | +$10.9K |
| June to July | −$10.7K | −$13.8K | +$3.1K |
| July to August | −$3.7K | −$0.6K | −$3.0K |
| **May to August** | **−$25.8K** | **−$36.7K** | **+$10.9K** |

The first two months were overwhelmingly volume-driven. In August transaction volume was roughly stable while ATV eased slightly. Splitting by units and revenue per unit gives the same picture: a −$35.8K units effect against a +$10.0K revenue-per-unit effect.

**Why ATV rose.** Part of the increase is a mix effect. New customers spend less per order ($20.70 in May) than returning customers ($26.11), so as new customers disappeared the average rose, even though no customer group changed its behavior much.

---

# 4. Customer Movement: Where Did the Volume Go?

| Month | New | Continuing | Reactivated | Lost |
|---|---:|---:|---:|---:|
| May | 2,626 | 1,327 | 465 | — |
| June | 1,569 | 1,482 | 669 | 2,936 |
| July | 1,213 | 1,267 | 873 | 2,453 |
| August | 1,060 | 1,192 | 1,051 | 2,161 |
| September | 1,625 | 1,246 | 1,218 | 2,057 |

From May to August, the fall of 1,115 active customers is entirely new customers (−1,566). Continuing customers fell by only 135 and reactivated customers rose by 586.

### Revenue by customer type

| Month | New | Continuing | Reactivated | Total |
|---|---:|---:|---:|---:|
| May | $66,673.75 | $60,192.01 | $15,854.10 | $142,719.86 |
| June | $38,869.99 | $68,977.48 | $23,457.88 | $131,305.35 |
| July | $30,057.46 | $60,588.14 | $29,946.37 | $120,591.97 |
| August | $27,765.95 | $51,814.39 | $37,328.64 | $116,908.98 |
| September | $40,269.86 | $60,658.11 | $40,311.92 | $141,239.89 |

| Period | New | Continuing | Reactivated | Net |
|---|---:|---:|---:|---:|
| May to June | −$27.8K | +$8.8K | +$7.6K | −$11.4K |
| June to July | −$8.8K | −$8.4K | +$6.5K | −$10.7K |
| July to August | −$2.3K | −$8.8K | +$7.4K | −$3.7K |
| **May to August** | **−$38.9K** | **−$8.4K** | **+$21.5K** | **−$25.8K** |

Two things stand out:

- **A lagged effect.** Continuing revenue rose in June, carried by May's large cohort, then fell in July and August as the thinner June and July cohorts flowed through.
- **Reactivation as a cushion.** Reactivated revenue more than doubled and offset more than half of the new-customer loss. Part of that growth is mechanical, because the pool of lapsed customers only builds up over the year.

> **Finding 2:** The business lost new customers, and part of the loss was masked by returning ones.

---

# 5. New-Customer Acquisition & Quality

| Month | New customers | Transactions | Txns / customer | Units / customer | Revenue | Revenue / customer | ATV |
|---|---:|---:|---:|---:|---:|---:|---:|
| May | 2,626 | 3,221 | 1.23 | 3.23 | $66,673.75 | $25.39 | $20.70 |
| June | 1,569 | 1,854 | 1.18 | 3.11 | $38,869.99 | $24.77 | $20.97 |
| July | 1,213 | 1,389 | 1.15 | 3.02 | $30,057.46 | $24.78 | $21.64 |
| August | 1,060 | 1,183 | 1.12 | 2.82 | $27,765.95 | $26.19 | $23.47 |
| September | 1,625 | 1,861 | 1.15 | 3.23 | $40,269.86 | $24.78 | $21.64 |

Splitting the −$38.9K fall in new-customer revenue: fewer customers explains about −$40.4K, while slightly higher revenue per customer added back +$1.5K. The fall was almost entirely headcount.

The step was abrupt. New customers ran at roughly 2,200 to 2,650 a month from February to May, then dropped to 1,569 in June alone.

Early engagement also weakened in the trough, with transactions per customer falling from 1.23 to 1.12 and units from 3.23 to 2.82. Units per customer returned to 3.23 in September.

First-month revenue per new customer drifted down over the year, from about $28.5 to $28.8 (February to April) to $22.4 to $23.7 in the fourth quarter.

> **Finding 3:** The major deterioration was the number of customers acquired, not what each acquired customer spent in their first month.

---

# 6. Cohort Health: Were New Customers Also Retaining Poorly?

| Cohort | Customers | Revenue / customer | Month 1 | Month 2 | Month 3 |
|---|---:|---:|---:|---:|---:|
| Jan | 3,396 | $32.74 | 38.46% | 30.18% | 17.58% |
| Feb | 2,221 | $28.52 | 21.52% | 13.10% | 6.62% |
| Mar | 2,642 | $28.71 | 28.24% | 24.64% | 22.71% |
| Apr | 2,527 | $28.76 | 28.81% | 25.05% | 21.88% |
| May | 2,626 | $25.39 | 23.84% | 21.29% | 19.23% |
| Jun | 1,569 | $24.77 | 17.72% | 17.46% | 17.85% |
| Jul | 1,213 | $24.78 | 14.18% | 15.09% | 15.58% |
| Aug | 1,060 | $26.19 | 15.38% | 13.02% | 13.49% |
| Sep | 1,625 | $24.78 | 19.02% | 16.18% | 18.28% |

- Cohorts from March to May settle at roughly 19–24% active each month, while June to August cohorts settle lower, at roughly 12–19%.
- **Revenue tails compound the loss.** By December, the March to May cohorts each contributed about $19K to $32K a month, against about $4K to $10K for the June to August cohorts.
- **Caution on January and February.** January is not a true cohort, because customers first seen in January may have bought before. January and February also fade to about 1%, while every cohort from March onward plateaus. This break is unexplained and should be validated before early cohorts are used as benchmarks.

> **Finding 4:** The business acquired fewer customers during the decline, and later cohorts retained worse than the March to May cohorts.

---

# 7. Customer Segment Behavior

Customers are segmented by transaction history before May: no pre-May history (0), occasional (1 to 2), regular (3 to 5) and frequent (6 or more).

### May
| Segment | Active customers | Txns / customer | Revenue / customer | ATV |
|---|---:|---:|---:|---:|
| No pre-May history | 2,626 | 1.23 | $25.39 | $20.70 |
| Occasional | 1,157 | 1.41 | $35.79 | $25.40 |
| Regular | 505 | 1.76 | $47.59 | $27.06 |
| Frequent | 130 | 3.04 | $81.61 | $26.86 |

### August
| Segment | Active customers | Txns / customer | Revenue / customer | ATV |
|---|---:|---:|---:|---:|
| No pre-May history | 2,011 | 1.26 | $29.43 | $23.44 |
| Occasional | 844 | 1.44 | $36.81 | $25.57 |
| Regular | 354 | 1.84 | $53.75 | $29.27 |
| Frequent | 94 | 2.74 | $81.17 | $29.57 |

*Note:* in August, "no pre-May history" includes every customer first seen from May to August, not only August's new customers.

- **Value gradient.** Customers with more history generate far more per head: frequent customers about three times the revenue per customer of customers with no history.
- **Counts fell across every tier.** Active customers with pre-May history fell 27–30% (frequent 130 to 94, regular 505 to 354, occasional 1,157 to 844). A fixed group of customers lapses naturally, and in this period the intake that would have replaced them also fell.
- **Behavior held.** Transactions per customer and revenue per customer were stable or higher within each tier, so the decline in these segments was fewer active customers, not weaker behavior.
- **Revenue by segment, May to August:** occasional −$10.3K, no pre-May −$7.5K, regular −$5.0K, frequent −$3.0K.

---

# 8. Category & Product Drivers

**The decline was broad-based but moderately concentrated.** Of 173 categories with May or August sales, 119 declined (gross −$31.7K), 53 rose (+$5.9K) and one was flat.

| Group | Share of gross category decline |
|---|---:|
| Top 3 (LPF, 1EO, J4R) | 14.6% |
| Top 7 (adding 0H2, R6E, Q4N, P42) | 27.4% |
| Top 10 | 36.0% |
| Top 20 | 57.3% |

| Category | May to Aug change | New | Continuing | Reactivated |
|---|---:|---:|---:|---:|
| LPF | −$1,618 | −$2,423 | −$562 | +$1,367 |
| 1EO | −$1,578 | −$1,270 | −$984 | +$676 |
| J4R | −$1,423 | −$1,303 | −$358 | +$238 |

- **Customers explain the categories.** In all three, the loss from new customers was the largest single component, partly offset by reactivated customers. In LPF it was larger than the entire net decline. Overall, new customers fell in 144 of 173 categories, while reactivated customers rose in 142 of 164. The largest category, 6BZ, grew by $1.6K net, but that hides a −$1.7K drop among new customers.
- **Product-level swings are noisy.** In 1EO, 28 products with no August sales explain −$1.5K of its −$1.6K decline. In the four categories examined at product level (LPF, 1EO, J4R and SJS), 105 of 190 declining products sold more again in September. Long-tail products are bought intermittently.

> **Finding 5:** The category declines largely follow who stopped arriving, not what customers were buying. A category review is worth doing, but after acquisition.


---

# 9. September Recovery

| Metric | August | September | Change |
|---|---:|---:|---:|
| Revenue | $116,908.98 | $141,239.89 | **+$24,330.91 (+20.8%)** |
| Transactions | 4,648 | 5,732 | +1,084 (+23.3%) |
| Active customers | 3,303 | 4,089 | +786 (+23.8%) |
| New customers | 1,060 | 1,625 | +565 |
| Continuing customers | 1,192 | 1,246 | +54 |
| Reactivated customers | 1,051 | 1,218 | +167 |
| ATV | $25.15 | $24.64 | −$0.51 |

Transactions per customer stayed flat (about 1.4), and ATV slipped slightly. Customers and orders came back, rather than existing orders becoming more valuable.

> **Finding 6:** The September recovery was a volume recovery.

---

# 10. Who Drove the Recovery?

### By customer type

| Customer type | August | September | Change |
|---|---:|---:|---:|
| New | $27,765.95 | $40,269.86 | +$12.5K |
| Continuing | $51,814.39 | $60,658.11 | +$8.8K |
| Reactivated | $37,328.64 | $40,311.92 | +$3.0K |
| **Total** | **$116,908.98** | **$141,239.89** | **+$24.3K** |

- **New customers** contributed about half of the gain.
- **Continuing customers** added $8.8K with only 54 more customers: revenue per continuing customer rose 12% ($43.47 to $48.68).
- Of September's 2,464 returning customers, 1,218 had bought earlier in the year but skipped August.

### By cohort
The September cohort added $40.3K, but August's cohort fell from $27.8K in its first month to $5.0K in its second, a normal first-month drop-off of −$22.7K. Net, the two newest cohorts added $17.5K, and cohorts from earlier months added $6.8K.

### By category
112 of 176 categories rose (gross +$30.6K), while 62 fell (−$6.3K). The two biggest decliners rebounded: 1EO was the top gainer (+$1.9K) and LPF the third (+$1.5K). This is further evidence that category swings largely track customer inflow.

The recovery cannot be attributed to one customer group. A customer can contribute revenue in September without becoming a durable customer, which is why the sustainability test matters.

---

# 11. Recovery Sustainability

September's customers were tracked through October to December.

### Customers still active

| September group | Customers | October | November | December |
|---|---:|---:|---:|---:|
| New | 1,625 | 19.02% | 16.18% | 18.28% |
| Continuing | 1,246 | 60.75% | 58.51% | 58.91% |
| Reactivated | 1,218 | 35.96% | 33.74% | 34.89% |

### Revenue still generated by the same customers

| September group | September revenue | October | November | December |
|---|---:|---:|---:|---:|
| New | $40,270 | $8,940 (22.2%) | $8,716 (21.6%) | $10,879 (27.0%) |
| Continuing | $60,658 | $43,713 (72.1%) | $41,347 (68.2%) | $46,369 (76.4%) |
| Reactivated | $40,312 | $19,613 (48.7%) | $17,610 (43.7%) | $17,135 (42.5%) |

Continuing customers who stayed also spent more than the group average, so revenue persistence (68–76%) is higher than customer retention (59–61%). In October, September's three groups produced $72.3K, about 51% of September's revenue.

### How the base was replenished

| Month | New | Continuing | Reactivated | Revenue | Reactivated share of revenue |
|---|---:|---:|---:|---:|---:|
| May | 2,626 | 1,327 | 465 | $142,720 | 11.1% |
| September | 1,625 | 1,246 | 1,218 | $141,240 | 28.5% |
| October | 1,359 | 1,504 | 1,117 | $140,854 | 25.8% |
| November | 1,185 | 1,458 | 1,258 | $132,883 | 29.1% |
| December | 1,202 | 1,503 | 1,481 | $152,124 | 34.3% |

> **Finding 7:** Revenue held through the fourth quarter, but new-customer arrivals fell back to 1.2–1.4K a month, well below the 2,200–2,600 of February to May. The base increasingly depends on continuing and reactivated customers. **September restored revenue without restoring acquisition.**

---

# 12. Overall Diagnosis

1. **Revenue fell.** −18.1% from May to August.
2. **The decline was volume-driven.** Transactions fell 24% and active customers 25%, while ATV rose 8%, partly through mix.
3. **New-customer acquisition collapsed.** New customers fell about 60%, taking $38.9K of revenue with them. Reactivated customers (+$21.5K) cushioned the loss.
4. **Newer cohorts retained worse.** Month-1 retention fell to 14–18% from 28–29%.
5. **The category decline was broad-based and followed customer inflow.** 119 of 173 categories declined, and the top ten account for about 36% of the gross decline.
6. **September reversed most of the damage.** Customers and orders rebounded 24% and 23%.
7. **Recovery quality differed by customer type.** Continuing customers were most durable, reactivated customers meaningfully persistent, and new customers weakest.
8. **Acquisition never recovered.** New-customer arrivals stayed at 1.2–1.4K a month in Q4.

---

# 13. Business Interpretation

The evidence points to a **contraction in customer volume rather than a collapse in customer spending**. Revenue recovered within a month, but the weakness behind it, a shrinking and weaker new-customer intake, persisted through the rest of the year.

Three connected issues emerged:

- **Acquisition volume.** Far fewer new customers entered the business.
- **Early retention.** Later cohorts retained worse in their first months.
- **Mix shift.** Revenue came to depend more on continuing and reactivated customers.

Category and product weakness largely followed from those, rather than acting as a separate cause. The September rebound shows that demand responds quickly when customers return, but it does not show that the underlying acquisition problem was solved.

---

# 14. Business Implications

### 1. Diagnose the acquisition decline
Examine acquisition channels, conversion rates, marketing activity, customer acquisition mix, promotions and assortment availability for May to August, and for why Q4 acquisition did not return to earlier levels.

### 2. Improve early-life customer retention
Restoring acquisition volume may not be enough, since later cohorts also retained worse. Examine first-to-second purchase conversion, onboarding, repeat-purchase incentives and first-purchase product mix.

### 3. Protect continuing customers and build reactivation
Continuing customers showed the strongest persistence, and reactivated customers now supply about a third of revenue. Prioritize customers with established purchase behavior, and test reactivation offers for lapsed customers.

### 4. Review the highest-impact categories, after the above
The largest declining categories (LPF, 1EO, J4R) should be reviewed for inventory, assortment, pricing and promotion changes. Because category declines largely followed lost new customers, and product-level swings are noisy, start by testing whether the declines are simply a result of lost new customers.

### 5. Track leading indicators
New customers per month, month-1 retention, reactivated customers per month and revenue share by customer type moved before and alongside revenue. See the [dashboard story](../docs/dashboard_story.md) for how these are presented.

---

# 15. Limitations

- **One year of data.** A seasonal summer dip cannot be separated from a real acquisition problem.
- **"New" means first observed purchase.** The data starts on January 2, 2016, so the January cohort is not truly new and early months overstate new customers. Reactivation is also partly mechanical, because the pool of lapsed customers only grows during the year.
- **An unexplained break in cohort behavior.** January and February cohorts fade to about 1%, while every cohort from March on plateaus at 12–24%. This should be validated before using early cohorts as benchmarks.
- **No cause data.** The analysis can establish what changed and where, but not why. A decline in product sales could reflect demand, stock-outs, marketing exposure, pricing, promotions or assortment decisions, and the dataset cannot tell these apart. Likewise, it cannot explain why acquisition deteriorated. Marketing, traffic, inventory, pricing and promotion data would be needed.
- **Calendar gaps.** The date table has 363 days. January 1, March 27 (Easter Sunday) and December 25 have no sales, likely closures.

---

# 16. Final Takeaway

The 2016 revenue decline was **material**, and revenue **recovered**. The strongest evidence points to a **volume-led contraction in customers and transactions**, with a collapse in new-customer acquisition as the clearest driver, reinforced by weaker retention among later cohorts. Category declines followed those customer movements and were broad-based, with moderate concentration.

September showed that revenue can return quickly, within about 1% of the May peak. But the sustainability analysis shows the recovery was uneven: **continuing customers were the most durable, reactivated customers meaningfully persistent, and new customers the weakest.** New-customer arrivals never returned to their earlier level, and revenue now leans more on returning customers.

The priority is not to reproduce September's revenue. It is to:

> **restore acquisition, improve early-life retention, protect established customers, reactivate lapsed customers, and review the category and product declines that remain after those causes are addressed.**