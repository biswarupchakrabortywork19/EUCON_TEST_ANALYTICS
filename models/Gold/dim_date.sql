-- Continuous calendar covering observed order dates and at least the current year.
with bounds as (
    select
        date_trunc('year', least(coalesce(min(OrderDate), current_date()), current_date()))::date as start_date,
        dateadd(year, 1, date_trunc('year', greatest(coalesce(max(OrderDate), current_date()), current_date())))::date as end_date
    from {{ ref('fact_orders') }}
), offsets as (
    select row_number() over (order by seq4()) - 1 as day_offset
    from table(generator(rowcount => 100000))
), calendar as (
    select dateadd(day, offsets.day_offset, bounds.start_date)::date as Date
    from bounds cross join offsets
    where dateadd(day, offsets.day_offset, bounds.start_date) < bounds.end_date
)
select
    Date,
    year(Date) * 10000 + month(Date) * 100 + day(Date) as DateKey,
    year(Date) as Year,
    quarter(Date) as Quarter,
    month(Date) as MonthNumber,
    monthname(Date) as MonthName,
    to_char(Date, 'YYYY-MM') as YearMonth,
    day(Date) as DayOfMonth,
    dayofweekiso(Date) as DayOfWeekNumber,
    dayname(Date) as DayName,
    dayofweekiso(Date) in (6, 7) as IsWeekend
from calendar
