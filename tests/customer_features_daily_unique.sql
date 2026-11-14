-- The incremental merge requires one row per customer and feature date.
select CustomerID, FeatureDate
from {{ ref('customer_features_daily') }}
group by CustomerID, FeatureDate
having count(*) > 1
