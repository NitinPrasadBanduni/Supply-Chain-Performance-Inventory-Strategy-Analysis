-- ==========================================
-- XYZ Analysis
-- ==========================================

# 1. Creating a view of monthly product demand for XYZ Analysis
create view vw_monthly_product_demand as(
select p.product_id, p.product_name, year(so.order_date) as year,
month(so.order_date) as month, sum(so.order_qty) as monthly_quantity
from products p join sales_orders so
on p.product_id = so.product_id
group by p.product_id, p.product_name, year(so.order_date), month(so.order_date));

select * from vw_monthly_product_demand 
order by product_id, year, month;


# 2. Monthly Demand Statistics by Product
with monthly_demand as(
select product_id, product_name, monthly_quantity
from vw_monthly_product_demand)

select product_id, product_name, 
round(avg(monthly_quantity),2) as avg_monthly_demand,
min(monthly_quantity) as min_monthly_demand,
max(monthly_quantity) as max_monthly_demand,
count(monthly_quantity) as months_with_demand
from monthly_demand
group by product_id, product_name
order by avg_monthly_demand desc;


# 3. Monthly Demand Variability for each product
with demand_stats as(
select product_id, product_name,
avg(monthly_quantity) as avg_monthly_demand,
stddev_samp(monthly_quantity) as standard_deviation
from vw_monthly_product_demand
group by product_id, product_name)

select product_id, product_name, 
round(avg_monthly_demand,2) as avg_monthly_demand,
round(standard_deviation,2) as standard_deviation,
round(standard_deviation/avg_monthly_demand,4) as cofficient_of_variation
from demand_stats order by cofficient_of_variation desc;


# 4. Ranking Products by Demand Stability
with demand_stats as(
select product_id, product_name,
avg(monthly_quantity) as avg_monthly_demand,
stddev_samp(monthly_quantity) as standard_deviation
from vw_monthly_product_demand
group by product_id, product_name),

cv_calculation as(
select product_id, product_name,
avg_monthly_demand, standard_deviation,
standard_deviation/avg_monthly_demand as cv
from demand_stats)

select product_id, product_name, round(avg_monthly_demand,2), 
round(standard_deviation,2), round(cv,4), 
rank() over(order by cv asc) as stability_rank
from cv_calculation 
order by stability_rank;


# 5. Classifying Products into XYZ Category
/*X: cofficient of variation ≤ 0.50
Y: cofficient of variation  > 0.50 and ≤ 1.00
Z: cofficient of variation > 1.00*/
with demand_stats as(
select product_id, product_name,
avg(monthly_quantity) as avg_monthly_demand,
stddev_samp(monthly_quantity) as standard_deviation
from vw_monthly_product_demand
group by product_id, product_name),

cv_calculation as(
select product_id, product_name,
avg_monthly_demand, standard_deviation,
standard_deviation/avg_monthly_demand as cv
from demand_stats)

select product_id, product_name, round(avg_monthly_demand,2), 
round(standard_deviation,2), round(cv,4),
case when cv<=0.50 then 'X'
when cv<=1.00 then 'Y'
else 'Z' end as XYZ_Classification
from cv_calculation order by cv;


# 6. XYZ Category Performance Summary. Analyzing demand stability within each XYZ Category
with demand_stats as(
select product_id, product_name,
avg(monthly_quantity) as avg_monthly_demand,
stddev_samp(monthly_quantity) as standard_deviation
from vw_monthly_product_demand
group by product_id, product_name),

cv_calculation as(
select product_id, product_name,
avg_monthly_demand, standard_deviation,
standard_deviation/avg_monthly_demand as cv
from demand_stats),

xyz_classification as(
select product_id, product_name,
avg_monthly_demand, cv,
case when cv<=0.50 then 'X'
when cv<=1.00 then 'Y'
else 'Z' end as XYZ_class
from cv_calculation)

select XYZ_class, count(*) as number_of_products,
round(sum(avg_monthly_demand),2) as total_demand,
round(avg(avg_monthly_demand),2) as avg_demand,
round(avg(cv),4) as average_cv,
round(min(cv),4) as min_cv,
round(max(cv),4) as max_cv,
round(count(*)/(select count(*) from xyz_classification)*100,2) as percentage_of_total_products
from xyz_classification
group by XYZ_class order by XYZ_class;