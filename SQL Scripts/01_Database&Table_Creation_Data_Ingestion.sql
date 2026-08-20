-- ====================================================
-- Database Creation
-- ====================================================

create database supply_chain;
use supply_chain;

-- ====================================================
-- Table Creation and Data Ingestion
-- ====================================================

-- ===================
-- 1. Customers Table
-- ===================
create table customers(
	customer_id varchar(30),
    customer_name varchar(30),
    customer_type varchar(30),
    age int,
    gender varchar(20),
    state varchar(30),
    email varchar(30),
    contact varchar(20),
    registration_date varchar(20));

select * from customers;


-- =====================
-- 2. Suppliers Table
-- =====================
create table suppliers(
	supplier_id varchar(30),
    supplier_name varchar(50),
    state varchar(30),
    contact_person varchar(30),
    email varchar(50),
    contact varchar(20),
    rating varchar(10),
    registration_date varchar(20));

select * from suppliers;


-- =====================
-- 3. Products Table
-- =====================
create table products(
	product_id varchar(30),
    product_name varchar(50),
    category varchar(50),
    sub_category varchar(50),
    brand varchar(50),
    unit varchar(20),
    length_cm float,
    width_cm float,
    height_cm float,
    unit_weight float,
    selling_price float,
    reorder_level int,
    prod_status varchar(20));
    
select * from products;


-- =====================
-- 4. Warehouse Table
-- =====================
create table warehouse(
	warehouse_id varchar(30),
    warehouse_name varchar(50),
    state varchar(30),
    capacity_vol_m3 int,
    capacity_kg int,
    contact varchar(20));
    
select * from warehouse;


-- =====================
-- 5. Inventory Table
-- =====================
create table inventory(
	inventory_id varchar(30),
    warehouse_id varchar(30),
    product_id varchar(30),
    current_stock int,
    reserved_stock int,
    safety_stock int,
    last_restock_date varchar(20));
    
select * from inventory;


-- =====================
-- 6. Purchase Orders Table
-- =====================
create table purchase_orders(
	purchase_order_id varchar(30),
    order_date varchar(20),
    supplier_id varchar(30),
    product_id varchar(30),
    warehouse_id varchar(30),
    order_qty int,
    unit_cost float,
    exp_del_date varchar(20),
    act_del_date varchar(20),
    def_qty int,
    trans_mode varchar(30),
    freight_cost varchar(30),
    payment_terms varchar(20),
    payment_method varchar(20));
    
select * from purchase_orders;


-- ======================
-- 7. Sales Orders Table
-- ======================
create table sales_orders(
	sale_order_id varchar(30),
    order_date varchar(20),
    customer_id varchar(30),
    product_id varchar(30),
    warehouse_id varchar(30),
    order_qty int,
    unit_price float,
    discount varchar(10),
    shipping_cost varchar(10),
    shipping_method varchar(20),
    payment_method varchar(20),
    exp_del_date varchar(20),
    act_del_date varchar(20));

select * from sales_orders;
