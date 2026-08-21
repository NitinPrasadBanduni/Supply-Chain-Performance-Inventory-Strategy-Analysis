# Supply Chain Performance & Inventory Strategy Analysis

## 📌 Project Overview

This project presents an end-to-end **Supply Chain Performance & Inventory Strategy Analysis** designed to analyze operational performance across sales, customers, procurement, suppliers, inventory, and warehouses.

The project combines a relational **MySQL database** for data preparation and analysis with an interactive **Power BI dashboard** for visualization and business insights.

A key component of the project is **ABC-XYZ analysis**, which classifies products based on their sales value and demand variability. The resulting product segments are then translated into **inventory strategies and recommendations**, helping identify which products require tighter inventory control, stable replenishment, or more flexible inventory planning.

---

## 🎯 Project Objectives

The primary objectives of this project are to:

* Analyze overall supply chain performance.
* Evaluate sales and customer behavior.
* Analyze supplier and procurement performance.
* Monitor inventory levels and warehouse utilization.
* Identify products with high, medium, and low business value using **ABC analysis**.
* Measure product demand stability using **XYZ analysis**.
* Combine ABC and XYZ classifications to create strategic product segments.
* Provide actionable inventory recommendations for different product segments.
* Build an interactive dashboard for exploring supply chain performance.

---

## 🗂️ Dataset Overview

The project uses a relational supply chain dataset containing **99,470 records across 7 tables**.

| Table             |    Records | Description                                                    |
| ----------------- | ---------: | -------------------------------------------------------------- |
| `customers`       |        800 | Customer information and registration details                  |
| `suppliers`       |        120 | Supplier information, ratings, and contact details             |
| `products`        |        500 | Product, category, brand, pricing, and dimensional information |
| `warehouse`       |         50 | Warehouse information and storage capacities                   |
| `inventory`       |      5,000 | Product stock levels across warehouses                         |
| `purchase_orders` |     35,000 | Procurement transactions and supplier delivery information     |
| `sales_orders`    |     58,000 | Customer sales transactions and delivery information           |
| **Total**         | **99,470** |                                                                |

### Database Structure

The project uses `supply_chain` as the MySQL database.

The database contains master tables such as customers, suppliers, products, and warehouses, along with transactional and operational tables for inventory, purchasing, and sales.

### Key Relationships

* Customers → Sales Orders
* Suppliers → Purchase Orders
* Products → Inventory
* Products → Purchase Orders
* Products → Sales Orders
* Warehouses → Inventory
* Warehouses → Purchase Orders
* Warehouses → Sales Orders

Primary and foreign keys were established to maintain relational integrity between the tables.

---

## 🔄 Project Workflow

```text
Raw Dataset
     │
     ▼
Database & Table Creation
     │
     ▼
Data Ingestion
     │
     ▼
Data Cleaning & Preprocessing
     │
     ├── Standardization
     ├── NULL Handling
     ├── Duplicate Treatment
     └── Outlier Treatment
     │
     ▼
Table Relationships
     │
     ▼
General Supply Chain Analysis
     │
     ├── Sales Analysis
     ├── Customer Analysis
     ├── Supplier Analysis
     ├── Procurement Analysis
     ├── Inventory Analysis
     └── Warehouse Analysis
     │
     ▼
ABC Analysis
     │
     ▼
XYZ Analysis
     │
     ▼
ABC-XYZ Classification
     │
     ▼
Power BI Data Modeling
     │
     ▼
Interactive Dashboard
     │
     ▼
Inventory Strategies & Recommendations
```

---

# 🛠️ Technologies Used

### Database & Analysis

* **MySQL**
* SQL
* Relational Database Design

### SQL Concepts

The project makes use of:

* JOINs
* Subqueries
* Common Table Expressions (CTEs)
* Window Functions
* CASE Statements
* GROUP BY
* Aggregate Functions
* Date Functions
* Views
* Primary Keys
* Foreign Keys
* Data Cleaning & Preprocessing

### Visualization & Business Intelligence

* **Microsoft Power BI**
* DAX
* Data Modeling
* Interactive Slicers
* KPI Cards
* Charts and Tables
* Top-N Analysis
* Cross-filtering
* Interactive Dashboard Navigation

---

# 🧹 Data Cleaning & Preprocessing

Before performing the analysis, the raw data was cleaned and prepared using SQL.

The preprocessing stage included:

### Text Standardization

Standardized text values and cases across relevant columns to maintain consistency.

### Missing Value Treatment

Identified and handled NULL/missing values in appropriate fields.

### Duplicate Treatment

Identified duplicate records and removed or handled them to improve data quality.

### Outlier Treatment

Analyzed numerical fields for abnormal values and performed appropriate outlier treatment before analysis.

### Data Validation

Validated relationships and consistency between related entities before establishing the final relational structure.

---

# 🔗 Database Relationships

After cleaning and preprocessing, primary and foreign key relationships were established across the database.

The main transactional relationships include:

```text
Customers ──────────────── Sales Orders
                              │
Products ────────────────────┤
                              │
Warehouses ──────────────────┘


Suppliers ─────────────── Purchase Orders
                              │
Products ────────────────────┤
                              │
Warehouses ──────────────────┘


Products ───────────────── Inventory
                              │
Warehouses ──────────────────┘
```

This relational structure allows sales, procurement, inventory, supplier, customer, and warehouse information to be analyzed together.

---

# 📊 SQL Analysis

The SQL analysis was divided into seven structured scripts.

| Script                                          | Analysis Stage                                                  |
| ----------------------------------------------- | --------------------------------------------------------------- |
| `01_Database&Table_Creation_Data_Ingestion.sql` | Database creation, table creation, and data ingestion           |
| `02_Data_Cleaning_Preprocessing.sql`            | Data cleaning, standardization, NULLs, duplicates, and outliers |
| `03_Creating_Table_Relationships.sql`           | Primary and foreign key relationships                           |
| `04_General_Supply_Chain_Analysis.sql`          | General supply chain business analysis                          |
| `05_ABC_Analysis.sql`                           | ABC product classification                                      |
| `06_XYZ_Analysis.sql`                           | XYZ demand variability classification                           |
| `07_ABC-XYZ_Analysis.sql`                       | Combined ABC-XYZ analysis                                       |

---

# 📈 General Supply Chain Analysis

The general SQL analysis examines different areas of supply chain operations, including:

### Sales & Customers

* Sales performance
* Sales order trends
* Product sales
* Customer purchasing behavior
* Customer segmentation
* Geographic sales distribution

### Suppliers & Procurement

* Procurement spending
* Supplier performance
* Supplier ratings
* Delivery delays
* Defective quantities
* Transportation and freight costs

### Inventory

* Current stock levels
* Reserved stock
* Safety stock
* Product availability
* Reorder-level monitoring

### Warehouses

* Inventory distribution
* Warehouse capacity
* Warehouse-level stock analysis
* Product distribution across warehouses

---

# 📦 ABC Analysis

ABC analysis classifies products according to their contribution to overall sales value.

The classification divides products into:

* **A Class** – highest-value products with the greatest contribution
* **B Class** – medium-value products
* **C Class** – lower-value products

The analysis helps identify products that require different levels of management attention and inventory control.

A SQL view was created to support product-level sales analysis:

### `vw_product_sales_summary`

```text
product_id
product_name
category
sub_category
brand
total_quantity_sold
total_sales_value
```

This view provides the product-level sales information required for ABC classification.

---

# 📉 XYZ Analysis

XYZ analysis evaluates products based on **demand variability and predictability**.

Monthly product demand was first calculated and then used to determine demand variability through the **coefficient of variation (CV)**.

The classification consists of:

* **X Class** – relatively stable and predictable demand
* **Y Class** – moderate demand variability
* **Z Class** – highly variable and less predictable demand

A dedicated SQL view was created for monthly demand:

### `vw_monthly_product_demand`

```text
product_id
product_name
year
month
monthly_demand
```

This provides the monthly demand data required to calculate demand variability.

---

# 🔬 ABC-XYZ Analysis

The ABC and XYZ classifications were combined to create a more comprehensive product segmentation framework.

This results in segments such as:

```text
AX   AY   AZ
BX   BY   BZ
CX   CY   CZ
```

The classification considers both:

**Product Value**
→ How important is the product financially?

**Demand Stability**
→ How predictable is the product's demand?

The final classification is stored in:

### `abc_xyz_classification`

```text
product_id
product_name
total_sales_value
total_quantity_sold
abc_class
avg_monthly_demand
cv
xyz_class
abc_xyz_segment
```

This classification provides the foundation for the strategic inventory analysis implemented in Power BI.

---

# 💡 Inventory Strategy & Recommendations

The ABC-XYZ framework was used not only to classify products but also to provide **inventory strategy recommendations**.

The general strategic approach is based on the combination of product value and demand predictability.

For example:

| Segment Type | General Strategy                                                          |
| ------------ | ------------------------------------------------------------------------- |
| **AX**       | Tight inventory monitoring with reliable replenishment                    |
| **AY**       | Close monitoring with flexible replenishment planning                     |
| **AZ**       | Careful inventory control due to high value and unpredictable demand      |
| **BX / BY**  | Balanced inventory levels with regular monitoring                         |
| **BZ**       | Flexible replenishment based on changing demand                           |
| **CX / CY**  | Simplified inventory management with lower monitoring intensity           |
| **CZ**       | Minimize excess inventory and review replenishment requirements carefully |

The Power BI dashboard extends this analysis by providing **product/category-level strategic recommendations** based on the ABC-XYZ classification.

---

# 📊 Power BI Dashboard

The final Power BI solution contains **five interactive report pages**.

## 1. Overview

Provides an executive-level summary of supply chain performance.

### KPIs

* Total Products
* Total Inventory Stocks
* Total Purchase Orders
* Total Sales Orders
* Total Sales Value
* Average Supplier Rating

### Analysis

* Monthly Sales Trend
* Inventory Stocks by Warehouse
* Procurement Cost by Supplier
* Sales Orders by Category
* On-Time Delivery Rate
* ABC-XYZ Matrix

### Filters

* Year
* Customer Type
* Warehouse State

---

## 2. Sales & Customers

Focuses on sales performance and customer behavior.

### KPIs

* Total Sales Orders
* Total Sales Value
* Total Quantity Sold
* Average Order Value
* Active Customers
* Average Discount
* Average Order Quantity

### Analysis

* Sales Trend
* Sales Orders by Product
* Lifetime Spend by Customer
* Sales Orders by State
* Sales by Customer Type

### Filters

* Year
* Gender
* Payment Method
* Top N

---

## 3. Supplier & Procurement

Analyzes procurement spending and supplier performance.

### KPIs

* Total Purchase Value
* Total Purchase Orders
* Total Quantity Purchased
* Average Purchase Value
* Average Supplier Rating
* Average Delay Days

### Analysis

* Procurement Spend Trend
* Purchase Orders by Supplier
* Freight Cost by Transportation Mode
* Supplier Defect Rate
* Purchase Value by State
* Supplier Delivery Delays

### Filters

* Year
* Month
* Payment Terms
* Top N

---

## 4. Inventory & Warehouse

Focuses on stock levels and warehouse operations.

### KPIs

* Total Inventory Stocks
* Available Stocks
* Reserved Stocks
* Safety Stocks
* Products Below Reorder Level
* Inventory Value

### Analysis

* Warehouse Capacity Utilization
* Available Stocks by Product
* Inventory Availability
* Total Stocks by Warehouse
* Top Warehouses by Stock
* Inventory by Category

### Filters

* Warehouse State
* Product Status
* Top N

---

## 5. ABC-XYZ Analysis

The final page provides strategic product segmentation and inventory recommendations.

### KPIs

* Total Products
* A Class Products
* B Class Products
* C Class Products
* X Class Products
* Y Class Products
* Z Class Products
* AX Products

### Analysis

* ABC-XYZ Matrix
* Sales Quantity by ABC-XYZ Segment
* Demand Variability by XYZ Class
* Product Distribution by ABC-XYZ Segment
* Inventory Strategy by ABC-XYZ Segment
* Sales Value by ABC Class

### Filters

* Product Category
* Product Status
* ABC Class
* XYZ Class

---

# 📅 Power BI Data Modeling

A dedicated **Dates table** was created using the DAX `CALENDAR()` function.

The Dates table was connected to:

```text
Dates[Date]
     │
     ├──────── sales_orders[order_date]
     │
     └──────── purchase_orders[order_date]
```

This provides a centralized date dimension for consistent filtering and trend analysis across sales and procurement.

The `vw_abc_xyz_classification` view was also imported into Power BI alongside the core database tables to support the ABC-XYZ analysis.

---

# 🧮 DAX

Multiple DAX measures were developed for KPI calculations, analytical metrics, rankings, and dashboard visualizations.

Key DAX functions used include:

* `SUMX`
* `DIVIDE`
* `CALCULATE`
* `FILTER`
* `DISTINCTCOUNT`
* `COUNT`
* Other aggregation and filtering functions

The measures were used to create dynamic KPIs and analytical calculations throughout the five dashboard pages.

---

# 📌 Key Analytical Areas

The project provides insights across five major areas:

### Sales

Understanding sales trends, product performance, customer behavior, and geographic sales distribution.

### Customers

Analyzing customer activity, customer types, purchasing behavior, and lifetime spending.

### Procurement

Evaluating procurement spending, supplier performance, delivery delays, defects, and transportation costs.

### Inventory & Warehouses

Monitoring stock availability, safety stock, reorder levels, inventory value, and warehouse utilization.

### Product Strategy

Using ABC-XYZ classification to understand product importance and demand stability and translate these findings into inventory management strategies.

---

# 📁 Repository Structure

```text
Supply-Chain-Performance-Inventory-Strategy-Analysis/
│
├── SQL Scripts/
│   ├── 01_Database&Table_Creation_Data_Ingestion.sql
│   ├── 02_Data_Cleaning_Preprocessing.sql
│   ├── 03_Creating_Table_Relationships.sql
│   ├── 04_General_Supply_Chain_Analysis.sql
│   ├── 05_ABC_Analysis.sql
│   ├── 06_XYZ_Analysis.sql
│   └── 07_ABC-XYZ_Analysis.sql
│
├── Dashboard/
│   └── Supply_Chain_Analysis.pbix
│
├── Dashboard_Screenshots/
│   ├── Report_01_Overview.png
│   ├── Report_02_Sales&Customers.png
│   ├── Report_03_Supplier&Procurement.png
│   ├── Report_04_Inventory&Warehouse.png
│   └── Report_05_ABC-XYZ_Analysis.png
│
└── README.md
```

---

# 🚀 Project Outcomes

This project demonstrates an end-to-end analytical workflow starting from raw supply chain data and progressing through database development, data preparation, SQL analysis, advanced product classification, and interactive business intelligence reporting.

The final solution provides a consolidated view of:

* Supply chain performance
* Sales and customer activity
* Procurement and supplier performance
* Inventory and warehouse operations
* Product value and demand variability
* ABC-XYZ product segmentation
* Inventory strategy recommendations

The combination of **SQL-based analysis and Power BI visualization** transforms raw operational data into structured insights that can support supply chain and inventory-related decision-making.

---

# 🔮 Future Scope

Potential extensions to the project include:

* Demand forecasting for individual products
* Supplier performance prediction
* Inventory stockout prediction
* Automated reorder recommendations
* Supplier risk scoring
* Delivery delay prediction
* What-if inventory analysis
* Automated dashboard refresh and reporting

---

# 👤 Author

**Nitin Prasad**

**Skills demonstrated:**
SQL • MySQL • Power BI • DAX • Data Cleaning • Data Analysis • Data Visualization • Supply Chain Analytics • Inventory Analysis

---
---

