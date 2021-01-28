/* Instructions
Get number of monthly active customers.
Active users in the previous month.
Percentage change in the number of active customers.
Retained customers every month. */

-- 1
 with active_customers as (
  select customer_id, convert(rental_date, date) as Activity_date,
  date_format(convert(rental_date,date), '%M') as Activity_Month,
  date_format(convert(rental_date,date), '%Y') as Activity_year
  from rental
)
select Activity_year, Activity_Month, count(distinct customer_id) as Active_Customers
from Active_customers
group by Activity_year, Activity_Month
order by Activity_year, Activity_Month DESC; 

/* 2 */

with active_customers as (
  select customer_id, convert(rental_date, date) as Activity_date,
  date_format(convert(rental_date,date), '%M') as Activity_Month,
  date_format(convert(rental_date,date), '%Y') as Activity_year
  from rental
),
active_customers_monthly as 
(select Activity_year, Activity_Month, count(distinct customer_id) as Active_Customers
from active_customers
group by Activity_year, Activity_Month
order by Activity_year, Activity_Month DESC
),

active_previous_month as (
  select Active_customers, Activity_month, lag(Active_customers,1) over (partition by Activity_year) as Active_last_month, 
  Activity_year
  from active_customers_monthly
)
select * from active_previous_month
where Active_last_month is not null
Limit 2;

/*3*/

with active_customers as (
  select customer_id, convert(rental_date, date) as Activity_date,
  date_format(convert(rental_date,date), '%M') as Activity_Month,
  date_format(convert(rental_date,date), '%Y') as Activity_year
  from rental
),
active_customers_monthly as 
(select Activity_year, Activity_Month, count(distinct customer_id) as Active_Customers
from active_customers
group by Activity_year, Activity_Month
order by Activity_year, Activity_Month DESC
),
active_previous_month as (
  select Active_customers, lag(Active_customers,1) over (partition by Activity_year) as Active_last_month, Activity_month,
  Activity_year
  from active_customers_monthly
)
select Active_customers AS This_Month, activity_month, Active_last_month, round((Active_customers-Active_last_month)/Active_customers* 100, 2) as change_in_percent, activity_year
from active_previous_month
where Active_last_month is not null;


/* -- Compute the change in retained customers from month to month
-