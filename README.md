# SQL_EDA
Explored relational databases using SQL to perform comprehensive Exploratory Data Analysis (EDA), covering database exploration, segmentation, trend analysis, and performance ranking. Developed reusable SQL scripts to analyze dimensions, measures, and time-based metrics, helping uncover key business insights.

### Key Contributions:

* Conducted EDA to understand data structure, identify outliers, and uncover trends.
* Designed SQL queries to calculate key metrics (total sales, customer count, average order value).
* Performed segmentation analysis (sales by product category, revenue by country).
* Developed ranking queries to identify top-performing products and underperforming categories.
* Applied best practices in SQL query writing for efficient data retrieval and analysis.
## Database Exploration
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
## Dimension Exploration
```sql
-- Retrieve a list of unique countries from which customers originate
select distinct country
from dim_customers
order by country;
```

![image](https://github.com/user-attachments/assets/482e9d4b-9cc1-4370-8d3d-921c3cc08e3a)

