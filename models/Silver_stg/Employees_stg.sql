{{ config(materialized='view') }}  --we can create staging queries as views

SELECT
EmployeeID,
FirstName,
LastName,
Email,
JobTitle,
HireDate,
ManagerID,
Address,
City,
State,
ZipCode,
CONCAT(FirstName, ' ', LastName) AS EmployeeName,
Updated_at
FROM
{{ source('BRONZE', 'EMPLOYEES') }}