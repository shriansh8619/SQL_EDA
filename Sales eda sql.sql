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

-- 05_magnitude_analysis

-- Find total customers by countries
select country,count(customer_id) as Total_customer
from dim_customers
group by country ;

-- Find total customers by gender
select gender,count(customer_id) as Total_customer
from dim_customers
group by gender ;

-- Find total products by category
select category,count(product_id) as Total_customer
from dim_products
group by category ;

-- What is the average costs in each category?
select category,avg(cost) as Avg_cost
from dim_products
group by category;
 
-- What is the total revenue generated for each category?
select category,sum(sales_amount)
from fact_sales s
left join dim_products p
on p.product_key=s.product_key
group by category;

-- What is the total revenue generated by each customer?
select c.customer_key,first_name,sum(sales_amount) as Total_revenue
from dim_customers c
left join fact_sales s
on c.customer_key=s.customer_key
group by s.customer_key
order by Total_revenue desc;

-- What is the distribution of sold items across countries?
select c.country,sum(s.quantity) as Total_items_sold
from fact_sales s
join dim_customers c
on c.customer_key=s.customer_key
group by c.country
order by total_items_sold desc; 

-- 06_ranking_analysis

-- Which 5 products subcategory Generating the Highest Revenue?
-- Simple Ranking
select p.subcategory,sum(s.sales_amount) as revenue
from fact_sales s
left join dim_products p
on s.product_key=p.product_key
group by p.subcategory
order by revenue desc
limit 5; 

-- Complex but Flexibly Ranking Using Window Functions
with ranked_products as (
	select p.product_name,
		sum(s.sales_amount) as revenue,
		rank() over (order by sum(s.sales_amount) desc) as rank_products
    from fact_sales s
    left join dim_products p
		on s.product_key=p.product_key
    group by p.product_name
)
select *
from ranked_products
where rank_products<=5;

-- What are the 5 worst-performing products in terms of sales?
select p.product_name,sum(s.sales_amount) as revenue
from fact_sales s
left join dim_products p
on s.product_key=p.product_key
group by p.product_key
order by revenue
limit 5;

-- Find the top 10 customers who have generated the highest revenue
select c.first_name,sum(s.sales_amount) as revenue
from fact_sales s
left join dim_customers c
on c.customer_key=s.customer_key
group by c.customer_key
order by revenue desc
limit 10;

-- The 3 customers with the fewest orders placed
select c.first_name,count(s.customer_key) as no_of_orders
from fact_sales s
left join dim_customers c
	on s.customer_key=c.customer_key
group by c.customer_key
order by count(s.customer_key)
limit 3;


