# Sales mart and daily customer features

Build: `dbt build --select +fact_orders +fact_order_items +dim_customer +dim_date +customer_features_daily`

Before the first build, refresh the existing orders staging model with
`dbt run --select orders_stg --full-refresh` if its incremental table may be incomplete.
Its existing timestamp watermark compares source Updated_at to execution time and can miss late arrivals.

The new models do not replace orders_fact or Customerrevenue. Those remain legacy models.

## Power BI

Use GOLD.FACT_ORDERS (one order) and GOLD.FACT_ORDER_ITEMS (one order item).
Connect DIM_CUSTOMER.CustomerID and DIM_DATE.Date to both facts using one-to-many,
single-direction relationships. Do not relate the facts directly.
Mark DIM_DATE as the date table using Date; sort MonthName by MonthNumber.

Revenue is gross quantity * unit price, not net revenue or profit.
Filter StatusCD = '02' for completed revenue. All statuses remain for cancellation analysis.
Order facts retain orders with no items and assign them zero revenue.
Item facts exclude orphan items without a matching order; the Silver relationship test should detect these.
Customer attributes are Type 1 (latest values). No historical attribute tracking is implied.
The date calendar has capacity for 100,000 days from the earliest included year.

## ML features

ML_FEATURES.CUSTOMER_FEATURES_DAILY stores one row per current customer per execution date.
Schedule a daily build to accumulate history; reruns merge into that date's row.
FeatureDate uses the Snowflake session's current date. The 90-day window is
[FeatureDate - 90 days, FeatureDate); only currently completed orders are counted.
Customers without completed orders have zero counts/spend and NULL recency/average value.
This model has no labels and does not train an ML model.

Current source status and customer records are mutable. These features are daily observed
values, not guaranteed historical event-time truth. Do not backfill older prediction dates
from current source states. Reliable historical training requires source change history,
availability timestamps, and future-outcome labels with a completed observation window.
A full refresh deletes accumulated daily feature history and produces today's rows only.
