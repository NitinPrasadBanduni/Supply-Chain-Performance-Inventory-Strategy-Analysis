-- ===================================================
-- Establish Table Relations (Primary & Foreign Keys)
-- ===================================================
# Customers Table
alter table customers
add primary key (customer_id);

# Suppliers Table
alter table suppliers
add primary key (supplier_id);

# Warehouse Table
alter table warehouse
add primary key (warehouse_id);

# Products Table
alter table products
add primary key (product_id);

# Inventory Table
alter table inventory
add primary key (inventory_id);

alter table inventory
	add constraint fk_inventory_warehouse
    foreign key (warehouse_id)
    references warehouse(warehouse_id),
    
    add constraint fk_inventory_product
    foreign key (product_id)
    references products(product_id);
    
# Purchase_Orders Table
alter table purchase_orders
add primary key (purchase_order_id);

alter table purchase_orders
	add constraint fk_po_supplier
    foreign key (supplier_id)
    references suppliers(supplier_id),
    
    add constraint fk_po_product
    foreign key (product_id)
    references products(product_id),
    
    add constraint fk_po_warehouse
    foreign key (warehouse_id)
    references warehouse(warehouse_id);
    
# Sales_Orders Table
alter table sales_orders
add primary key (sale_order_id);

alter table sales_orders
	add constraint fk_so_customers
    foreign key (customer_id)
    references customers(customer_id),
    
    add constraint fk_so_products
    foreign key (product_id)
    references products(product_id),
    
    add constraint fk_so_warehouse
    foreign key (warehouse_id)
    references warehouse(warehouse_id);
            