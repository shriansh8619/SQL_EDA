-- 01 Database Exploration
-- This query retrieves all tables present in the currently selected database.
-- INFORMATION_SCHEMA.TABLES contains metadata about all tables across all databases.
-- We filter by TABLE_SCHEMA = DATABASE() to only see tables in the current database.
SELECT 
    TABLE_SCHEMA,    -- Name of the database (schema)
    TABLE_NAME,      -- Name of the table
    TABLE_TYPE       -- Type of object (BASE TABLE, VIEW, etc.)
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = DATABASE();   -- Filter to show only tables in the active database

-- This query retrieves metadata about each column in the dim_customers table.
SELECT 
    COLUMN_NAME,                 -- Name of the column
    DATA_TYPE,                    -- Data type 
    IS_NULLABLE,                   -- NULL values (YES/NO)
    CHARACTER_MAXIMUM_LENGTH      -- Max length for character-based columns (null for non-char types)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()    -- Only look at tables in the active database
AND TABLE_NAME = 'dim_customers';  -- Specifically focus on the 'dim_customers' table

-- 02 Dimensions Exploration
-- Retrieve a list of unique countries from which customers originate
select distinct country
from dim_customers order by country;

-- Retrieve a list of unique categories, subcategories, and products
select distinct category,subcategory,product_name
from dim_products
order by category,subcategory,product_name;

-- 03 Date_range_Exploration
-- Determine the first and last order date and the total duration in months
select min(order_date) as First_Order, max(order_date) as Last_Order, 
timestampdiff(month,min(order_date),max(order_date)) as Duration_months
from fact_sales;

-- Find the youngest and oldest customer based on birthdate
select min(birthdate) as Oldest,
timestampdiff(year,min(birthdate),current_date()) as Oldest_age,
max(birthdate) as Youngest,
timestampdiff(year,max(birthdate),current_date()) as Young_age
from dim_customers;

-- 04 Measures_exploration

-- Find the Total Sales
select sum(sales_amount) as Total_sales
from fact_sales;

-- Find how many items are sold
select sum(quantity) as Total_items
from fact_sales;

-- Find the average selling price
select avg(price) as Avg_Price
from fact_sales;

-- Find the Total number of Orders
select count(distinct order_number) as Total_orders
from fact_sales;

-- Find the total number of products
select count(distinct product_key) as Total_products
from fact_sales;

-- Find the total number of customers
select count(customer_id) as Total_cutomers
from dim_customers;

-- Find the total number of customers that has placed an order
select count(distinct customer_key) as Total_cutomers
from dim_customers;

-- Generate a Report that shows all key metrics of the business
SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM fact_sales
UNION 
SELECT 'Total Quantity', SUM(quantity) FROM fact_sales
UNION 
SELECT 'Average Price', AVG(price) FROM fact_sales
UNION 
SELECT 'Total Orders', COUNT(DISTINCT order_number) FROM fact_sales
UNION 
SELECT 'Total Products', COUNT(DISTINCT product_name) FROM dim_products
UNION 
SELECT 'Total Customers', COUNT(customer_key) FROM dim_customers;



