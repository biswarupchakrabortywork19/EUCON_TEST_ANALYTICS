-- Grain: one row per order, including orders with no items.
with item_totals as (
    select
        OrderID,
        count(*) as OrderItemCount,
        sum(Quantity) as UnitsOrdered,
        sum(TotalPrice) as Revenue
    from {{ ref('orderitems_stg') }}
    group by OrderID
)
select
    o.OrderID,
    cast(o.OrderDate as date) as OrderDate,
    o.CustomerID,
    o.EmployeeID,
    o.StoreID,
    o.StatusCD,
    o.StatusDesc,
    o.ORDER_CHANNEL,
    1 as OrderCount,
    coalesce(i.OrderItemCount, 0) as OrderItemCount,
    coalesce(i.UnitsOrdered, 0) as UnitsOrdered,
    coalesce(i.Revenue, 0) as Revenue,
    o.Updated_at
from {{ ref('orders_stg') }} o
left join item_totals i on o.OrderID = i.OrderID
