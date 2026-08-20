-- ====================================================
-- Understanding Table Schema
-- ====================================================

use supply_chain;

/*
1. customers -> (customer_id(pk), customer_name, customer_type, age, gender, state, email, contact, registration_date)
2. suppliers -> (supplier_id(pk), supplier_name, state, contact_person, email, contact, rating, registration_date)
3. products -> (product_id(pk), product_name, category, sub_category, brand, unit, length_cm, width_cm, height_cm, 
			unit_weight, selling_price, reorder_level, prod_status)
4. warehouse -> (warehouse_id(pk), warehouse_name, state, capacity_vol_m3, capacity_kg, contact)
5. inventory -> (inventory_id(pk), warehouse_id(fk_inventory_warehouse), product_id(fk_inventory_product), 
				current_stock, reserved_stock, safety_stock, last_restock_date)
6. purchase_orders ->  (purchase_order_id(pk), order_date, supplier_id(fk_po_supplier), product_id(fk_po_product),
						warehouse_id(fk_po_warehouse), order_qty, unit_cost, exp_del_date, act_del_date, def_qty,
						trans_mode, freight_cost, payment_terms, payment_method)
7. sales_orders -> (sales_order_id(pk), order_date, customer_id(fk_so_customer), product_id(fk_so_product),
				warehouse_id(fk_so_warehouse), order_qty, unit_price, discount, shipping_cost, shipping_method,
				payment_method, exp_del_date, act_del_date)
*/



-- ========================================================
-- General Supply Chain Analysis
-- ========================================================

# 1. Top Performing Products by Sales Revenue.
select dt1.* from
(select dt.*, dense_rank() over(order by dt.total_sales desc) d_rank from
(select p.product_id, p.product_name, p.category, p.sub_category, p.brand, 
sum(s.order_qty*s.unit_price*(1-(s.discount/100))) total_sales
from sales_orders s join products p on s.product_id = p.product_id
group by p.product_id order by total_sales desc)dt)dt1
where dt1.d_rank<=10;
select discount from sales_orders;


# 2. Monthly sales revenue and order quantity trend.
select monthname(order_date) order_month, count(sale_order_id) total_sales, 
sum(order_qty) quantity_sold, sum(order_qty*unit_price*(1-(discount/100))) total_revenue 
from sales_orders group by order_month order by total_revenue desc;


# 3. Sales performance by product category and sub-category.
select p.category, p.sub_category, count(s.sale_order_id) total_orders,
sum(s.order_qty*s.unit_price*(1-(discount/100))) total_sales, sum(s.order_qty) quantity_sold, 
avg(s.unit_price) avg_selling_price 
from products p join sales_orders s on p.product_id = s.product_id
group by p.category, p.sub_category order by total_sales desc;


# 4. Top customers by total spending.
select dt1.* from
(select dt.*, dense_rank() over(order by total_spend desc) d_rank from
(select c.customer_id, c.customer_name, c.customer_type, c.state,
count(s.sale_order_id) total_orders, sum(s.order_qty) total_qty_purchased,
sum(s.order_qty*s.unit_price*(1-(discount/100))) total_spend
from customers c join sales_orders s on c.customer_id = s.customer_id
group by c.customer_id, c.customer_name, c.customer_type, c.state)dt)dt1
where dt1.d_rank<=10;


# 5. Customer segmentation based on spending.
with customer_spending as(
select c.customer_id, c.customer_name, 
sum(s.order_qty*s.unit_price*(1-(discount/100))) total_spend
from customers c join sales_orders s 
on c.customer_id = s.customer_id
group by c.customer_id, c.customer_name
),
customer_segment as (
select *,
ntile(3) over(order by total_spend desc) spending_group
from customer_spending
)
select customer_id, customer_name, total_spend,
case when spending_group = 1 then 'high value'
when spending_group = 2 then 'medium value'
when spending_group = 3 then 'low value'
end as customer_segment
from customer_segment order by total_spend desc;


# 6. Supplier performance analysis.
select dt.supplier_id, dt.supplier_name, dt.rating, 
dt.total_purchase_orders, dt.total_procurement_cost, dt.avg_del_delay, 
(dt.accepted_qty/dt.qty_del)*100 quality_score from
(select s.supplier_id, s.supplier_name, s.rating,
count(p.purchase_order_id) as total_purchase_orders,
sum((p.order_qty*p.unit_cost)+p.freight_cost) as total_procurement_cost,
avg(datediff(p.act_del_date, p.exp_del_date)) as avg_del_delay,
sum(p.order_qty) qty_del, sum(p.order_qty-p.def_qty) accepted_qty
from suppliers s join purchase_orders p on s.supplier_id = p.supplier_id
group by s.supplier_id, s.supplier_name, s.rating)dt;


# 7. Identify the most reliable suppliers.
with supplier_performance as(
select s.supplier_id, s.supplier_name, 
count(p.purchase_order_id) as total_orders,
sum(case when 
datediff(p.act_del_date, p.exp_del_date)<=0 
then 1 else 0 end) as on_time_orders,
sum(case when 
datediff(p.act_del_date, p.exp_del_date)>0
then 1 else 0 end) as delayed_orders,
avg(case when
datediff(p.act_del_date, p.exp_del_date)>0
then datediff(p.act_del_date, p.exp_del_date) end) as avg_delay_days,
sum(p.def_qty) as defective_quantity
from suppliers s join purchase_orders p on p.supplier_id = s.supplier_id
group by s.supplier_id, s.supplier_name),

supplier_ranking as(
select *, rank() over(order by (on_time_orders/total_orders) desc,
avg_delay_days asc, defective_quantity asc) as supplier_rank
from supplier_performance)

select supplier_id, supplier_name, total_orders,
on_time_orders, delayed_orders, 
round(on_time_orders*100/total_orders,2) as on_time_rate,
round(avg_delay_days,2) as avg_delay_days,
defective_quantity, supplier_rank,
case when supplier_rank<=10 then 'most reliable'
else 'other'
end as reliability_category
from supplier_ranking order by supplier_rank;


# 8. Warehouse inventory health analysis
select w.warehouse_id, w.warehouse_name, sum(i.current_stock) total_current_stock, 
sum(i.reserved_stock) total_reserved_stocks, sum(i.safety_stock) total_safety_stocks,
count(distinct i.product_id) as number_of_products,
sum(case when i.current_stock<i.safety_stock then 1 else 0 end) as products_below_safety_stock,
case when sum(case when i.current_stock<i.safety_stock then 1 else 0 end)>0 then 'potential stock shortage'
else 'healthy' end as inventory_health
from inventory i join warehouse w on i.warehouse_id=w.warehouse_id
group by w.warehouse_id, w.warehouse_name
order by products_below_safety_stock desc;


# 9. Identify products that need replenishment
select w.warehouse_id, w.warehouse_name, p.product_id, p.product_name, 
i.current_stock, i.reserved_stock, i.safety_stock, p.reorder_level,
case when (i.current_stock - i.reserved_stock)<i.safety_stock and
(i.current_stock - i.reserved_stock)<=p.reorder_level then 'breached safety and reorder levels'
when (i.current_stock - i.reserved_stock)<i.safety_stock then 'below safety stocks'
when (i.current_stock - i.reserved_stock)<=p.reorder_level then 'below reorder level'
end as replishment_reason
from inventory i join products p on i.product_id = p.product_id
join warehouse w on i.warehouse_id = w.warehouse_id
where (i.current_stock - i.reserved_stock)<i.safety_stock
or (i.current_stock - i.reserved_stock)<=p.reorder_level;


# 10. Procurement Cost vs Sales Revenue
with procurement as(
select product_id, sum(order_qty) as quantity_purchased,
sum(order_qty*unit_cost) as procurement_value,
avg(unit_cost) as avg_procurement_unit_cost
from purchase_orders group by product_id),

sales as(
select product_id, sum(order_qty) as quantity_sold,
sum(order_qty*unit_price*(1-(discount/100))) as sales_revenue,
avg(unit_price*(1-(discount/100))) as avg_selling_price
from sales_orders group by product_id)

select p.product_id, p.product_name,
coalesce(pr.quantity_purchased,0) as quantity_purchased,
coalesce(pr.procurement_value,0) as procurement_value,
round(pr.avg_procurement_unit_cost,2) as procurement_unit_cost,
coalesce(s.quantity_sold,0) as quantity_sold,
coalesce(s.sales_revenue,0) as sales_revenue,
round(s.avg_selling_price,2) as selling_price,
round(s.avg_selling_price-pr.avg_procurement_unit_cost,2) as margin_per_unit,
round(s.quantity_sold*(s.avg_selling_price-pr.avg_procurement_unit_cost),2) as estimated_gross_margin
from products p left join procurement pr on p.product_id=pr.product_id
left join sales s on p.product_id = s.product_id
order by estimated_gross_margin desc;