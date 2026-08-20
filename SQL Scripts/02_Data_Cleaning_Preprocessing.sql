-- ===============================================
-- Data Cleaning and Preprocessing
-- ===============================================

-- =======================
-- 1. Customers Table
-- =======================

select * from customers;
select count(*) from customers;
describe customers;

# Standardizing Text Columns
update customers 
set customer_name = lower(trim(customer_name)),
    customer_type = lower(trim(customer_type)),
    gender = lower(trim(gender)),
    state = lower(trim(state)),
    email = lower(trim(email)),
    contact = lower(trim(contact)),
    registration_date = lower(trim(registration_date));
    
# Checking for Missing Values
select * from customers
where customer_id is null or customer_id = '';

select * from customers
where customer_name is null or customer_name = '';

select * from customers
where customer_type is null or customer_type = '';

select * from customers
where age is null or age = '';

select * from customers
where gender is null or gender = '';

select * from customers
where state is null or state = '';

select * from customers
where email is null or email = '';

select * from customers
where contact is null or contact = '';

select * from customers
where registration_date is null or registration_date = '';

# Handling Missing Values in Email and Contact
update customers set contact = 'not provided'
where contact = '' or contact is null;

update customers set email = 'not provided'
where email = '' or email is null;

# Checking for Duplicates
select customer_id, count(*) AS duplicate_count
from customers
group by customer_id
having count(*) > 1;

select customer_name, customer_type, age, gender, state, email, 
contact, registration_date, count(*) as duplicate_count
from customers
group by customer_name, customer_type, age, gender, state, email, 
contact, registration_date having count(*) > 1;

select * from customers;

# Converting Registration Date to Datetime
alter table customers
modify column registration_date date;

# Checking Outliers in Age
select min(age) as min_age,
max(age) as max_age,
avg(age) as avg_age from customers;

select age, count(*) as frequency
from customers
group by age order by age;


-- =======================
-- 2. Suppliers Table
-- =======================
select * from suppliers;
select count(*) from suppliers;
describe suppliers;

# Standardizing Text Columns
update suppliers 
set supplier_name = lower(trim(supplier_name)),
    state = lower(trim(state)),
    contact_person = lower(trim(contact_person)),
    email = lower(trim(email)),
    contact = lower(trim(contact)),
    rating = lower(trim(rating)),
    registration_date = lower(trim(registration_date));
    
# Checking for Missing Values
select * from suppliers
where supplier_id is null or supplier_id = '';

select * from suppliers
where supplier_name is null or supplier_name = '';

select * from suppliers
where state is null or state = '';

select * from suppliers
where contact is null or contact = '';

select * from suppliers
where email is null or email = '';

select * from suppliers
where rating is null or rating = '';

select * from suppliers
where registration_date is null or registration_date = '';

# Handling Missing Values in Email and Contact
update suppliers set contact = 'not provided'
where contact = '' or contact is null;

update suppliers set email = 'not provided'
where email = '' or email is null;

# Handling Missing values of rating
update suppliers
set rating = NULL
where rating = '';

alter table suppliers
modify column rating float;

update suppliers
set rating = (
		select round(avg(rating), 1)
		from (select rating
        from suppliers
        where rating is not null) as dt)
where rating is null;

# Checking for Duplicates
select supplier_id, count(*) AS duplicate_count
from suppliers
group by supplier_id
having count(*) > 1;

select supplier_name, state, contact_person, email, contact, 
rating, registration_date, count(*) as duplicate_count
from suppliers
group by supplier_name, state, contact_person, email, contact, 
rating, registration_date having count(*) > 1;

# Converting Registration Date to Datetime
alter table suppliers
modify column registration_date date;

# Checking Outliers in Rating
select min(rating) as min_rating,
max(rating) as max_rating,
avg(rating) as avg_rating from suppliers;

select rating, count(*) as frequency
from suppliers
group by rating order by rating;


-- =======================
-- 3. Products Table
-- =======================
select * from products;
select count(*) from products;
describe products;

# Standardizing Text Columns
update products 
set product_name = lower(trim(product_name)),
    category = lower(trim(category)),
    sub_category = lower(trim(sub_category)),
    brand = lower(trim(brand)),
    unit = lower(trim(unit)),
    prod_status = lower(trim(prod_status));
    
# Checking for Missing Values
select * from products
where product_id is null or product_id = '';

select * from products
where product_name is null or product_name = '';

select * from products
where category is null or category = '';

select * from products
where sub_category is null or sub_category = '';

select * from products
where brand is null or brand = '';

select * from products
where unit is null or unit = '';

select * from products
where length_cm is null or length_cm = '';

select * from products
where width_cm is null or width_cm = '';

select * from products
where height_cm is null or height_cm = '';

select * from products
where unit_weight is null or unit_weight = '';

select * from products
where selling_price is null or selling_price = '';

select * from products
where reorder_level is null or reorder_level = '';

select * from products
where prod_status is null or prod_status = '';

# Checking for Duplicates
select product_id, count(*) AS duplicate_count
from products
group by product_id
having count(*) > 1;

select product_name, category, sub_category, brand, unit, 
length_cm, width_cm, height_cm,unit_weight, selling_price,
reorder_level, prod_status, count(*) as duplicate_count
from products
group by product_name, category, sub_category, brand, unit, 
length_cm, width_cm, height_cm,unit_weight, selling_price,
reorder_level, prod_status having count(*) > 1;

## Handling Outliers

-- selling_price
select min(selling_price) as min_selling_price,
max(selling_price) as max_selling_price,
avg(selling_price) as avg_selling_price from products;

with quartiles as (select selling_price, ntile(4) over (order by selling_price) as q from products),
bounds as (select 
        max(case when q = 1 then selling_price end) - 1.5 * (max(case when q = 3 then selling_price end) - max(case when q = 1 then selling_price end)) as low,
        max(case when q = 3 then selling_price end) + 1.5 * (max(case when q = 3 then  selling_price end) - MAX(case when q = 1 then selling_price end)) as high
    from quartiles)
select dt.*, b.low, b.high
from products dt
cross join bounds b
where dt.selling_price < b.low OR dt.selling_price > b.high;

with quartiles as (
	select selling_price, ntile(4) over (order by selling_price) as quartile from products),
iqr_values as (select 
		min(case when quartile = 2 then selling_price end) as q1,
		min(case when quartile = 4 then selling_price end) as q3
    from quartiles)
    
update products p
cross join iqr_values i
set selling_price = case
            when selling_price < (i.q1 - 1.5 * (i.q3 - i.q1)) then round(i.q1 - 1.5 * (i.q3 - i.q1),2)
            when selling_price > (i.q3 + 1.5 * (i.q3 - i.q1)) then round(i.q3 + 1.5 * (i.q3 - i.q1),2)
            else selling_price end;
       
       
-- =======================
-- 4. Warehouse Table
-- =======================
select * from warehouse;
select count(*) from warehouse;
describe warehouse;

# Standardizing Text Columns
update warehouse 
set warehouse_name = lower(trim(warehouse_name)),
    state = lower(trim(state)),
    contact = lower(trim(contact));

# Checking for Missing Values
select * from warehouse
where warehouse_id is null or warehouse_id = '';

select * from warehouse
where warehouse_name is null or warehouse_name = '';

select * from warehouse
where state is null or state = '';

select * from warehouse
where capacity_vol_m3 is null or capacity_vol_m3 = '';

select * from warehouse
where capacity_kg is null or capacity_kg = '';

select * from warehouse
where contact is null or contact = '';

# Checking for Duplicates
select warehouse_id, count(*) AS duplicate_count
from warehouse
group by warehouse_id
having count(*) > 1;

select warehouse_name, state, capacity_vol_m3, capacity_kg, 
contact, count(*) as duplicate_count
from warehouse
group by warehouse_name, state, capacity_vol_m3, capacity_kg, 
contact having count(*) > 1;

# Checking Outliers in Capacity
select min(capacity_vol_m3) as min_capacity_vol_m3,
max(capacity_vol_m3) as max_capacity_vol_m3,
avg(capacity_vol_m3) as avg_capacity_vol_m3 from warehouse;

select capacity_vol_m3, count(*) as frequency
from warehouse
group by capacity_vol_m3 order by capacity_vol_m3;

select min(capacity_kg) as min_capacity_kg,
max(capacity_kg) as max_capacity_kg,
avg(capacity_kg) as avg_capacity_kg from warehouse;

select capacity_kg, count(*) as frequency
from warehouse
group by capacity_kg order by capacity_kg;


-- =======================
-- 5. Inventory Table
-- =======================
select * from inventory;
select count(*) from inventory;
describe inventory;

# Checking for Missing Values
select * from inventory
where inventory_id is null or inventory_id = '';

select * from inventory
where warehouse_id is null or warehouse_id = '';

select * from inventory
where product_id is null or product_id = '';

select * from inventory
where current_stock is null or current_stock = '';

select * from inventory
where reserved_stock is null or reserved_stock = '';

select * from inventory
where safety_stock is null or safety_stock = '';

select * from inventory
where last_restock_date is null or last_restock_date = '';

# Checking for Duplicates
select inventory_id, count(*) AS duplicate_count
from inventory
group by inventory_id
having count(*) > 1;

select warehouse_id, product_id, current_stock, reserved_stock, 
safety_stock, last_restock_date, count(*) as duplicate_count
from inventory
group by warehouse_id, product_id, current_stock, reserved_stock, 
safety_stock, last_restock_date having count(*) > 1;

# Converting Last Restock Date to Datetime
alter table inventory
modify column last_restock_date date;

# Checking for Outliers

-- current_stock
select min(current_stock) as min_current_stock,
max(current_stock) as max_current_stock,
avg(current_stock) as avg_current_stock from inventory;

-- reserved_stock
select min(reserved_stock) as min_reserved_stock,
max(reserved_stock) as max_reserved_stock,
avg(reserved_stock) as avg_reserved_stock from inventory;

-- safety_stock
select min(safety_stock) as min_safety_stock,
max(safety_stock) as max_safety_stock,
avg(safety_stock) as avg_safety_stock from inventory;


-- =======================
-- 6. Purchase Orders Table
-- =======================
select * from purchase_orders;
select count(*) from purchase_orders;
describe purchase_orders;

# Checking for Missing Values
select * from purchase_orders
where purchase_order_id is null or purchase_order_id = '';

select * from purchase_orders
where order_date is null or order_date = '';

select * from purchase_orders
where supplier_id is null or supplier_id = '';

select * from purchase_orders
where product_id is null or product_id = '';

select * from purchase_orders
where warehouse_id is null or warehouse_id = '';

select * from purchase_orders
where order_qty is null or order_qty = '';

select * from purchase_orders
where unit_cost is null or unit_cost = '';

select * from purchase_orders
where exp_del_date is null or exp_del_date = '';

select * from purchase_orders
where act_del_date is null or act_del_date = '';

select * from purchase_orders
where def_qty is null or def_qty = '';

select * from purchase_orders
where trans_mode is null or trans_mode = '';

select * from purchase_orders
where freight_cost is null or freight_cost = '';

select * from purchase_orders
where payment_terms is null or payment_terms = '';

select * from purchase_orders
where payment_method is null or payment_method = '';

# Standardizing Text Columns
update purchase_orders 
set order_date = lower(trim(order_date)),
    exp_del_date = lower(trim(exp_del_date)),
    act_del_date = lower(trim(act_del_date)),
    trans_mode = lower(trim(trans_mode)),
    freight_cost = lower(trim(freight_cost)),
    payment_terms = lower(trim(payment_terms)),
    payment_method = lower(trim(payment_method));
    
# Converting Datatype of Date columns(order_date, exp_del_date, act_del_date)
update purchase_orders 
set order_date = NULLIF(order_date, ''),
	exp_del_date = NULLIF(exp_del_date, ''),
    act_del_date = NULLIF(act_del_date, '');
    
alter table purchase_orders 
  modify column order_date date,
  modify column exp_del_date date,
  modify column act_del_date date;
  
# Handling Missing Values of Actual Delivery Date
update purchase_orders
set act_del_date = order_date + interval(select avg_days from(
        select round(avg(datediff(act_del_date, order_date))) as avg_days
        from purchase_orders
        where act_del_date is not null and order_date is not null) AS temp_table) DAY
where act_del_date is null;

# Handling Freight Cost
update purchase_orders 
set freight_cost = nullif(trim(freight_cost), '');

alter table purchase_orders 
modify column freight_cost float;

# Computing missing freight cost with average of freight cost of same trans_mode
update purchase_orders as po
set po.freight_cost = (select avg_cost from (
        select trans_mode, avg(freight_cost) as avg_cost
        from purchase_orders
        where freight_cost is not null and trans_mode is not null
        group by trans_mode) as dt
    where dt.trans_mode = po.trans_mode)
where po.freight_cost is null;

# Checking for Duplicates
select purchase_order_id,order_date, supplier_id, product_id,warehouse_id,order_qty,unit_cost,
exp_del_date,act_del_date,def_qty,trans_mode,freight_cost,payment_terms,
payment_method, count(*) as duplicate_count
from purchase_orders
group by purchase_order_id,order_date, supplier_id, product_id,warehouse_id,order_qty,unit_cost,
exp_del_date,act_del_date,def_qty,trans_mode,freight_cost,payment_terms,
payment_method having count(*) > 1;

# Handling Duplicates by Transfering distincts records to another table
create table temp_table like purchase_orders;

insert into temp_table 
select distinct * from purchase_orders;

drop table purchase_orders;

rename table temp_table to purchase_orders;
select * from purchase_orders;

## Handling Outliers

-- order quantity
select min(order_qty) as min_order_qty,
max(order_qty) as max_order_qty,
avg(order_qty) as avg_order_qty from purchase_orders;

select order_qty, count(*) as frequency
from purchase_orders
group by order_qty order by order_qty;

-- defected quantity
select min(def_qty) as min_def_qty,
max(def_qty) as max_def_qty,
avg(def_qty) as avg_def_qty from purchase_orders;

select def_qty, count(*) as frequency
from purchase_orders
group by def_qty order by def_qty;

--  unit cost
select min(unit_cost) as min_unit_cost,
max(unit_cost) as max_unit_cost,
avg(unit_cost) as avg_unit_cost from purchase_orders;

with quartiles as (select unit_cost, ntile(4) over (order by unit_cost) as q from purchase_orders),
bounds as (select 
        max(case when q = 1 then unit_cost end) - 1.5 * (max(case when q = 3 then unit_cost end) - max(case when q = 1 then unit_cost end)) as low,
        max(case when q = 3 then unit_cost end) + 1.5 * (max(case when q = 3 then  unit_cost end) - MAX(case when q = 1 then unit_cost end)) as high
    from quartiles)
select dt.*, b.low, b.high
from purchase_orders dt
cross join bounds b
where dt.unit_cost < b.low OR dt.unit_cost > b.high;

--  freight cost
select min(freight_cost) as min_freight_cost,
max(freight_cost) as max_freight_cost,
avg(freight_cost) as avg_freight_cost from purchase_orders;

with quartiles as (select freight_cost, ntile(4) over (order by freight_cost) as q from purchase_orders),
bounds as (select 
        max(case when q = 1 then freight_cost end) - 1.5 * (max(case when q = 3 then freight_cost end) - max(case when q = 1 then freight_cost end)) as low,
        max(case when q = 3 then freight_cost end) + 1.5 * (max(case when q = 3 then  freight_cost end) - MAX(case when q = 1 then freight_cost end)) as high
    from quartiles)
select dt.*, b.low, b.high
from purchase_orders dt
cross join bounds b
where dt.freight_cost < b.low OR dt.freight_cost > b.high;

with quartiles as (
	select freight_cost, ntile(4) over (order by freight_cost) as quartile from purchase_orders),
iqr_values as (select 
		min(case when quartile = 2 then freight_cost end) as q1,
		min(case when quartile = 4 then freight_cost end) as q3
    from quartiles)
    
update purchase_orders p
cross join iqr_values i
set freight_cost = case
            when freight_cost < (i.q1 - 1.5 * (i.q3 - i.q1)) then round(i.q1 - 1.5 * (i.q3 - i.q1),2)
            when freight_cost > (i.q3 + 1.5 * (i.q3 - i.q1)) then round(i.q3 + 1.5 * (i.q3 - i.q1),2)
            else freight_cost end;
            
            
-- =======================
-- 7. Sales Orders Table
-- =======================
select * from sales_orders;
select count(*) from sales_orders;
describe sales_orders;

# Standardizing Text Columns
update sales_orders 
set order_date = lower(trim(order_date)),
    discount = lower(trim(discount)),
    shipping_method = lower(trim(shipping_method)),
    payment_method = lower(trim(payment_method)),
    exp_del_date = lower(trim(exp_del_date)),
    act_del_date = lower(trim(act_del_date));
    
# Checking for Missing Values
select * from sales_orders
where sale_order_id is null or sale_order_id = '';

select * from sales_orders
where order_date is null or order_date = '';

select * from sales_orders
where customer_id is null or customer_id = '';

select * from sales_orders
where product_id is null or product_id = '';

select * from sales_orders
where warehouse_id is null or warehouse_id = '';

select * from sales_orders
where order_qty is null or order_qty = '';

select * from sales_orders
where unit_price is null or unit_price = '';

select * from sales_orders
where discount is null or discount = '';

select * from sales_orders
where shipping_cost is null or shipping_cost = '';

select * from sales_orders
where shipping_method is null or shipping_method = '';

select * from sales_orders
where payment_method is null or payment_method = '';

select * from sales_orders
where act_del_date is null;

# Converting Datatype of Date columns(order_date, exp_del_date, act_del_date)
update sales_orders 
set order_date = NULLIF(order_date, ''),
	exp_del_date = NULLIF(exp_del_date, ''),
    act_del_date = NULLIF(act_del_date, '');
    
alter table sales_orders 
  modify column order_date date,
  modify column exp_del_date date,
  modify column act_del_date date;
  
# Computing missing values of Actual_delivery_date
update sales_orders
set act_del_date = exp_del_date 
where shipping_method in ('express', 'overnight', 'same day') 
and act_del_date is null;

# Handling discount column
update sales_orders
set discount = '0'
where discount is null or discount = '';

alter table sales_orders 
modify column discount decimal(10, 2) default 0.00;

# Handling Shipping Cost
update sales_orders 
set shipping_cost = nullif(trim(shipping_cost), '');

alter table sales_orders 
modify column shipping_cost float;

# Computing missing freight cost with average of freight cost of same trans_mode
update sales_orders as so
set so.shipping_cost = (select avg_cost from (
        select shipping_method, avg(shipping_cost) as avg_cost
        from sales_orders
        where shipping_cost is not null and shipping_method is not null
        group by shipping_method) as dt
    where dt.shipping_method = so.shipping_method)
where so.shipping_cost is null;

# Checking for Duplicates
select sale_order_id, count(*) AS duplicate_count
from sales_orders
group by sale_order_id
having count(*) > 1;

# Handling Duplicates by Transfering distincts records to another table
create table temp_table like sales_orders;

insert into temp_table 
select distinct * from sales_orders;

drop table sales_orders;

rename table temp_table to sales_orders;
select * from sales_orders;

## Handling Outliers

-- order quantity
select min(order_qty) as min_order_qty,
max(order_qty) as max_order_qty,
avg(order_qty) as avg_order_qty from sales_orders;

select order_qty, count(*) as frequency
from sales_orders
group by order_qty order by order_qty;

with quartiles as (select order_qty, ntile(4) over (order by order_qty) as q from sales_orders),
bounds as (select 
        max(case when q = 1 then order_qty end) - 1.5 * (max(case when q = 3 then order_qty end) - max(case when q = 1 then order_qty end)) as low,
        max(case when q = 3 then order_qty end) + 1.5 * (max(case when q = 3 then  order_qty end) - MAX(case when q = 1 then order_qty end)) as high
    from quartiles)
select dt.*, b.low, b.high
from sales_orders dt
cross join bounds b
where dt.order_qty < b.low OR dt.order_qty > b.high;

with quartiles as (
	select order_qty, ntile(4) over (order by order_qty) as quartile from sales_orders),
iqr_values as (select 
		min(case when quartile = 2 then order_qty end) as q1,
		min(case when quartile = 4 then order_qty end) as q3
    from quartiles)
    
update sales_orders s
cross join iqr_values i
set order_qty = case
            when order_qty < (i.q1 - 1.5 * (i.q3 - i.q1)) then floor(i.q1 - 1.5 * (i.q3 - i.q1))
            when order_qty > (i.q3 + 1.5 * (i.q3 - i.q1)) then floor(i.q3 + 1.5 * (i.q3 - i.q1))
            else order_qty end;
            
# shipping_cost
select min(shipping_cost) as min_shipping_cost,
max(shipping_cost) as max_shipping_cost,
avg(shipping_cost) as avg_shipping_cost from sales_orders;

with quartiles as (select shipping_cost, ntile(4) over (order by shipping_cost) as q from sales_orders),
bounds as (select 
        max(case when q = 1 then shipping_cost end) - 1.5 * (max(case when q = 3 then shipping_cost end) - max(case when q = 1 then shipping_cost end)) as low,
        max(case when q = 3 then shipping_cost end) + 1.5 * (max(case when q = 3 then  shipping_cost end) - MAX(case when q = 1 then shipping_cost end)) as high
    from quartiles)
select dt.*, b.low, b.high
from sales_orders dt
cross join bounds b
where dt.shipping_cost < b.low OR dt.shipping_cost > b.high;

with quartiles as (
	select shipping_cost, ntile(4) over (order by shipping_cost) as quartile from sales_orders),
iqr_values as (select 
		min(case when quartile = 2 then shipping_cost end) as q1,
		min(case when quartile = 4 then shipping_cost end) as q3
    from quartiles)
    
update sales_orders s
cross join iqr_values i
set shipping_cost = case
            when shipping_cost < (i.q1 - 1.5 * (i.q3 - i.q1)) then round(i.q1 - 1.5 * (i.q3 - i.q1),2)
            when shipping_cost > (i.q3 + 1.5 * (i.q3 - i.q1)) then round(i.q3 + 1.5 * (i.q3 - i.q1),2)
            else shipping_cost end;
