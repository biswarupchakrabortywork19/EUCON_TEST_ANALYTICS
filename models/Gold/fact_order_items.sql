-- Grain: one row per order item. Revenue is gross quantity * unit price.
select
    i.OrderItemID,
    i.OrderID,
    i.ProductID,
    o.CustomerID,
    o.EmployeeID,
    o.StoreID,
    cast(o.OrderDate as date) as OrderDate,
    o.StatusCD,
    o.StatusDesc,
    o.ORDER_CHANNEL,
    i.Quantity,
    i.UnitPrice,
    i.TotalPrice as Revenue,
    i.Updated_at
from {{ ref('orderitems_stg') }} i
join {{ ref('orders_stg') }} o on i.OrderID = o.OrderID
