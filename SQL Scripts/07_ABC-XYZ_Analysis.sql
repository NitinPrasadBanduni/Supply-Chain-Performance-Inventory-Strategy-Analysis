-- ==============================================
-- ABC-XYZ Classification
-- ==============================================
 
# 1. Creating a view of ABC-XYZ Classification Matrix
create view vw_abc_xyz_classification as(
with abc_sales as(
select product_id, product_name, total_sales_value, total_quantity_sold,
sum(total_sales_value) over(order by total_sales_value desc)/
sum(total_sales_value) over()*100 as cummulative_sales_percentage
from vw_product_sales_summary),

abc_classification as(
select product_id, product_name, total_sales_value, total_quantity_sold,
case when cummulative_sales_percentage<=80 then 'A'
when cummulative_sales_percentage<=95 then 'B'
else 'C' end as abc_class
from abc_sales),

xyz_stats as(
select product_id, product_name, 
avg(monthly_quantity) as avg_monthly_demand,
stddev_samp(monthly_quantity) as standard_deviation
from vw_monthly_product_demand
group by product_id, product_name),

xyz_classification as(
select product_id, product_name, avg_monthly_demand,
standard_deviation/avg_monthly_demand as cv
from xyz_stats),

xyz_final as(
select product_id, product_name, avg_monthly_demand, cv,
case when cv<=0.50 then 'X'
when cv<=1.00 then 'Y'
else 'Z' end as xyz_class
from xyz_classification)

select a.product_id, a.product_name,
round(a.total_sales_value,2) as total_sales_value, a.total_quantity_sold, a.abc_class, 
round(x.avg_monthly_demand,2) as avg_monthly_demand, round(x.cv,4) as cv,
x.xyz_class, concat(a.abc_class, x.xyz_class) as abc_xyz_segment
from abc_classification a join xyz_final x
on a.product_id = x.product_id);


select * from vw_abc_xyz_classification 
order by abc_xyz_segment, total_sales_value desc;


# 2. ABC-XYZ Segement Business Analysis
select abc_xyz_segment, count(*) as number_of_products,
round(sum(total_sales_value),2) as total_sales_value,
round(sum(total_sales_value)/sum(sum(total_sales_value)) over()*100,2) as percentage_of_total_sales,
sum(total_quantity_sold) as total_quantity_sold,
round(avg(cv),4) as average_cv,
round(avg(avg_monthly_demand),2) as average_monthly_demand
from vw_abc_xyz_classification
group by abc_xyz_segment
order by abc_xyz_segment;


# 3. Indentifying High Value product with Inventory Risk
with inventory_summary as(
select product_id, sum(current_stock) as current_stock,
sum(reserved_stock) as reserved_stock,
sum(safety_stock) as safety_stock
from inventory group by product_id),

inventory_analysis as(
select product_id, current_stock, reserved_stock,
safety_stock, current_stock-reserved_stock as available_stock
from inventory_summary)

select p.product_id, p.product_name, p.category,
a.abc_class, a.xyz_class, round(a.total_sales_value,2) as sales_value,
round(a.avg_monthly_demand,2) as avg_monthly_demand,
round(a.cv,4) as cv, i.current_stock, i.reserved_stock,
i.safety_stock, i.available_stock,
round(i.available_stock/avg_monthly_demand,2) as inventory_coverage_months,
case when i.available_stock/avg_monthly_demand < 1 then 'Inventory Risk'
else 'Healthy' end as inventory_status
from vw_abc_xyz_classification a
join products p on p.product_id = a.product_id
join inventory_analysis i on i.product_id = p.product_id
where a.abc_class = 'A'
order by inventory_coverage_months asc, 
a.total_sales_value desc;


# 4. Inventory Strategy by ABC-XYZ Segment
select product_id, product_name, total_sales_value,
total_quantity_sold, abc_class, xyz_class, abc_xyz_segment,
case when abc_xyz_segment = 'AX' then 'High priority, tight inventory monitoring'
when abc_xyz_segment = 'AY' then 'High priority, regular forecasting'
when abc_xyz_segment = 'AZ' then 'High priority, maintain safety stock carefully'
when abc_xyz_segment = 'BX' then 'Moderate priority, predictable replenishment'
when abc_xyz_segment = 'BY' then 'Moderate monitoring'
when abc_xyz_segment = 'BZ' then 'Monitor demand variability'
when abc_xyz_segment = 'CX' then 'Simple replenishment'
when abc_xyz_segment = 'CY' then 'Periodic monitoring'
when abc_xyz_segment = 'CZ' then 'Low priority, minimize excess inventory'
end as Inventory_Strategy
from vw_abc_xyz_classification
order by abc_xyz_segment,
total_sales_value desc;