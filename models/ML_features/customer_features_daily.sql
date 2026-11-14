{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key=['CUSTOMERID', 'FEATUREDATE'],
    on_schema_change='fail'
) }}

-- Grain: customer / execution date. Re-running today updates today's features.
-- Prior dates persist through incremental builds; no historical backfill is inferred.
with feature_orders as (
    select *
    from {{ ref('fact_orders') }}
    where OrderDate < current_date()
      and StatusCD = '02'
)
select
    c.CustomerID,
    current_date() as FeatureDate,
    max(o.OrderDate) as LastCompletedOrderDate,
    datediff(day, max(o.OrderDate), current_date()) as DaysSinceLastOrder,
    count(o.OrderID) as CompletedOrdersToDate,
    count(case when o.OrderDate >= dateadd(day, -90, current_date()) then o.OrderID end) as OrdersLast90Days,
    coalesce(sum(case when o.OrderDate >= dateadd(day, -90, current_date()) then o.Revenue else 0 end), 0) as SpendLast90Days,
    avg(case when o.OrderDate >= dateadd(day, -90, current_date()) then o.Revenue end) as AverageOrderValueLast90Days,
    current_timestamp() as FeatureComputedAt
from {{ ref('dim_customer') }} c
left join feature_orders o on c.CustomerID = o.CustomerID
group by c.CustomerID
