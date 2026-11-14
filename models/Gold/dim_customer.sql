-- Type 1 dimension: latest available customer attributes, not historical versions.
select
    CustomerID,
    CustomerName,
    FirstName,
    LastName,
    Email,
    Phone,
    Address,
    City,
    State,
    ZipCode,
    Updated_at
from {{ ref('Customer_stg') }}
