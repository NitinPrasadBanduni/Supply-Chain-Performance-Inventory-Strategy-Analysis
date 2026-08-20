-- ===========================
-- ABC Analysis
-- ===========================

# 1. Creating a view of Product Sales Summary for ABC Analysis
create view vw_product_sales_summary as (
select p.product_id, p.product_name, p.category, p.sub_category, p.brand,
sum(so.order_qty) as total_quantity_sold,
sum(so.order_qty*so.unit_price*(1-(so.discount/100))) as total_sales_value
from products p join sales_orders so on p.product_id = so.product_id
group by p.product_id, p.product_name, p.category, p.sub_category, p.brand);

select * from vw_product_sales_summary order by total_sales_value desc;


# 2. Calculate total annual sales value for each product
select year(so.order_date) as sales_year,
p.product_id, p.product_name,
sum(so.order_qty*so.unit_price*(1-(discount/100))) as annual_sales_value
from products p join sales_orders so on p.product_id = so.product_id
group by year(so.order_date), p.product_id, p.product_name
order by sales_year, annual_sales_value desc;


# 3. Calculate Each Products Percentage Contribution to Total Sales
with product_sales as(
select product_id, product_name, total_sales_value
from vw_product_sales_summary)
select product_id, product_name, total_sales_value,
round(total_sales_value/(select sum(total_sales_value) from product_sales)*100,2) as sales_percentage
from product_sales order by sales_percentage desc;


# 4. Calculate Cummulative Sales Contribution
select product_id, product_name, total_sales_value,
round(sum(total_sales_value) over(order by total_sales_value desc)/
sum(total_sales_value) over()*100,2) as cummulative_sales_percentage
from vw_product_sales_summary
order by total_sales_value desc;

select * from vw_product_sales_summary;

# 5. ABC Product Classification
/*A: cumulative contribution ≤ 80%
B: cumulative contribution > 80% and ≤ 95%
C: cumulative contribution > 95%*/

with product_sales as(
select product_id, product_name, category, sub_category, brand,
total_sales_value from vw_product_sales_summary),

cummulative_sales as(
select *, round(sum(total_sales_value) over(order by total_sales_value desc)/
sum(total_sales_value) over()*100,2) as cummulative_sales_percentage
from product_sales)
select *, 
case when cummulative_sales_percentage<=80 then 'A'
when cummulative_sales_percentage<=95 then 'B'
else 'C'
end as abc_category
from cummulative_sales
order by total_sales_value desc;


# 6. ABC Category Comparison
with cummulative_sales as(
select product_id, product_name, total_quantity_sold, total_sales_value,
round(sum(total_sales_value) over(order by total_sales_value desc)/
sum(total_sales_value) over()*100,2) as cummulative_sales_percentage
from vw_product_sales_summary),

abc_classification as(
select product_id, product_name, total_quantity_sold, total_sales_value,
case when cummulative_sales_percentage<=80 then 'A'
when cummulative_sales_percentage<=95 then 'B'
else 'C'
end as abc_category
from cummulative_sales)

select abc_category, count(*) as number_of_products,
sum(total_sales_value) as total_sales_value,
round(sum(total_sales_value)/(select sum(total_sales_value) from abc_classification)*100,2)
as percentage_of_total_sales,
sum(total_quantity_sold) as quantity_sold
from abc_classification 
group by abc_category order by abc_category;