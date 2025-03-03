# SQL_EDA
Explored relational databases using SQL to perform comprehensive Exploratory Data Analysis (EDA), covering database exploration, segmentation, trend analysis, and performance ranking. Developed reusable SQL scripts to analyze dimensions, measures, and time-based metrics, helping uncover key business insights.

### Key Contributions:

* Conducted EDA to understand data structure, identify outliers, and uncover trends.
* Designed SQL queries to calculate key metrics (total sales, customer count, average order value).
* Performed segmentation analysis (sales by product category, revenue by country).
* Developed ranking queries to identify top-performing products and underperforming categories.
* Applied best practices in SQL query writing for efficient data retrieval and analysis.
## 01 Database Exploration
```sql
-- This query retrieves all tables present in the currently selected database.
-- INFORMATION_SCHEMA.TABLES contains metadata about all tables across all databases.
-- We filter by TABLE_SCHEMA = DATABASE() to only see tables in the current database.
SELECT 
    TABLE_SCHEMA,    -- Name of the database (schema)
    TABLE_NAME,      -- Name of the table
    TABLE_TYPE       -- Type of object (BASE TABLE, VIEW, etc.)
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = DATABASE();   -- Filter to show only tables in the active database
```

![image](https://github.com/user-attachments/assets/943c1523-1f62-4427-8b0c-1b4ee91c49c9)

```sql
-- This query retrieves metadata about each column in the dim_customers table.
SELECT 
    COLUMN_NAME,                 -- Name of the column
    DATA_TYPE,                    -- Data type 
    IS_NULLABLE,                   -- NULL values (YES/NO)
    CHARACTER_MAXIMUM_LENGTH      -- Max length for character-based columns (null for non-char types)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()    -- Only look at tables in the active database
AND TABLE_NAME = 'dim_customers';  -- Specifically focus on the 'dim_customers' table
```

![image](https://github.com/user-attachments/assets/d4eda316-6ba9-4686-bec5-44eeb635b56f)
## 02 Dimension Exploration
```sql
-- Retrieve a list of unique countries from which customers originate
select distinct country
from dim_customers
order by country;
```

![image](https://github.com/user-attachments/assets/482e9d4b-9cc1-4370-8d3d-921c3cc08e3a)
## 03 Date_range Exploration
```sql
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
```
![image](https://github.com/user-attachments/assets/190aaed3-6ae3-4861-9420-6509dfe4fc9d) ![image](https://github.com/user-attachments/assets/954a5d16-6ea8-4038-a590-dbb5aba7166b)

## 04 Measures_exploration
```sql
-- Generate a Report that shows all key metrics of the business

-- Find the Total Sales
SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM fact_sales
UNION

-- Find how many items are sold
SELECT 'Total Quantity', SUM(quantity) FROM fact_sales
UNION

-- Find the average selling price
SELECT 'Average Price', AVG(price) FROM fact_sales
UNION

-- Find the Total number of Orders
SELECT 'Total Orders', COUNT(DISTINCT order_number) FROM fact_sales
UNION

-- Find the total number of products
SELECT 'Total Products', COUNT(DISTINCT product_name) FROM dim_products
UNION

-- Find the total number of customers that has placed an order
SELECT 'Total Customers', COUNT(customer_key) FROM dim_customers;
```
![image](https://github.com/user-attachments/assets/0e3d11a3-9fa0-4fe4-ab7e-0fcaf82de7e0)

## 05 Magnitude Analysis
```sql
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
```
![image](https://github.com/user-attachments/assets/1e33b57a-4e4a-496e-9329-f9fd21c54721) ![image](https://github.com/user-attachments/assets/b12b51a9-9f5b-49eb-8556-5b19cfbe0577) ![image](https://github.com/user-attachments/assets/70e20594-516b-4a90-ae84-67fc76fa2f73)



```sql
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
```
![image](https://github.com/user-attachments/assets/a47221d3-019e-4875-ac38-9265cc35a16d) ![image](https://github.com/user-attachments/assets/2a339c47-5062-4776-b681-ee00b18921c2)


```sql
-- What is the total revenue generated by each customer?
select c.customer_key,first_name,sum(sales_amount) as Total_revenue
from dim_customers c
left join fact_sales s
on c.customer_key=s.customer_key
group by s.customer_key
order by Total_revenue desc;
```
![image](https://github.com/user-attachments/assets/b64c8bf9-89de-4ea3-9fc8-d6551bbe13d5)

```sql
-- What is the distribution of sold items across countries?
select c.country,sum(s.quantity) as Total_items_sold
from fact_sales s
join dim_customers c
on c.customer_key=s.customer_key
group by c.country
order by total_items_sold desc;
```
![image](https://github.com/user-attachments/assets/59648352-c7c6-41d2-a02c-8e77f0673627)

## 06 Ranking Analysis
```sql
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
```
![image](https://github.com/user-attachments/assets/bdce5e21-8063-49fb-a3e7-d00cdcd09845) ![image](https://github.com/user-attachments/assets/0a99d0fd-e330-48f2-a2c8-97c42c4a5183)

```sql
-- What are the 5 worst-performing products in terms of sales?
select p.product_name,sum(s.sales_amount) as revenue
from fact_sales s
left join dim_products p
on s.product_key=p.product_key
group by p.product_key
order by revenue
limit 5;
```
![image](https://github.com/user-attachments/assets/63911b3f-5d66-4379-8a5f-a84eb3445e20)

```sql
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
```
![image](https://github.com/user-attachments/assets/202fbcb7-42bc-4d99-b226-954b79a40062) ![image](https://github.com/user-attachments/assets/b431a4ea-6b44-47a6-8125-8492bdfa4ae7)

## 07 Change Over Time Analysis
```sql
-- Analyse sales performance over time
-- Quick Date Functions
-- 1. Quick Date Functions - Grouping by Year and Month
SELECT
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);
```
![image](https://github.com/user-attachments/assets/e9ed030e-8357-4c6e-817a-ab832fa224c7)

```sql

-- 2. DATE_FORMAT() to group by month (first day of each month)
SELECT
    DATE_FORMAT(order_date, '%Y-%m-01') AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM fact_sales
WHERE order_date IS NOT NULL
GROUP BY order_month
ORDER BY order_month;


-- 3. Formatting date into 'YYYY-MMM' format (like '2024-Mar')
SELECT
    DATE_FORMAT(order_date, '%Y-%b') AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM fact_sales
WHERE order_date IS NOT NULL
GROUP BY order_month
ORDER BY order_month;
```

![image](https://github.com/user-attachments/assets/18eac7d8-c3dc-440f-9fb2-7ad08eaf65cb) ![image](https://github.com/user-attachments/assets/1e16bcc2-28f5-4d34-ab73-61ca16162086)



