-- SQL Retail Sales Analysis - P1
CREATE DATABASE sql_project_p2;


-- Create TABLE
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales
            (
                transaction_id INT PRIMARY KEY,	
                sale_date DATE,	 
                sale_time TIME,	
                customer_id	INT,
                gender	VARCHAR(15),
                age	INT,
                category VARCHAR(15),	
                quantity	INT,
                price_per_unit FLOAT,	
                cogs	FLOAT,
                total_sale FLOAT
            );

SELECT * FROM retail_sales
LIMIT 10


    

SELECT 
    COUNT(*) 
FROM retail_sales

-- Data Cleaning
SELECT * FROM retail_sales
WHERE transactions_id IS NULL

SELECT * FROM retail_sales
WHERE sale_date IS NULL

SELECT * FROM retail_sales
WHERE sale_time IS NULL

SELECT * FROM retail_sales
WHERE 
    transaction_id IS NULL
    OR
    sale_date IS NULL
    OR 
    sale_time IS NULL
    OR
    gender IS NULL
    OR
    category IS NULL
    OR
    quantity IS NULL
    OR
    cogs IS NULL
    OR
    total_sale IS NULL;
    
-- 
DELETE FROM retail_sales
WHERE 
    transaction_id IS NULL
    OR
    sale_date IS NULL
    OR 
    sale_time IS NULL
    OR
    gender IS NULL
    OR
    category IS NULL
    OR
    quantity IS NULL
    OR
    cogs IS NULL
    OR
    total_sale IS NULL;
    
-- Data Exploration

-- How many sales we have?

SELECT COUNT(*) as total_sale FROM retail_sales

-- How many uniuque customers we have ?

SELECT COUNT(DISTINCT customer_id) as total_sale FROM retail_sales



SELECT DISTINCT category FROM retail_sales


-- Data Analysis & Business Key Problems & Answers

-- My Analysis & Findings
-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 10 in the month of Nov-2022
-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)
-- Q.11 Who are the customers with above-average sales
-- Q.12 Which category sells the most quantity vs revenue?
-- Q.13 What is the average price per unit per category?
-- Q.14 Find the top-selling product category per day
-- Q.15 Find the running total of sales over time
-- Q.16 What is the peak sales hour per day
-- Q.17 What is the Peak days in each month



 -- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05

SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';


-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022

SELECT 
  *
FROM retail_sales
WHERE 
    category = 'Clothing'
    AND 
    TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
    AND
    quantity >= 4


-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.

SELECT 
    category,
    SUM(total_sale) as net_sale,
    COUNT(*) as total_orders
FROM retail_sales
GROUP BY 1

-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.

SELECT
    ROUND(AVG(age), 2) as avg_age
FROM retail_sales
WHERE category = 'Beauty'


-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.

SELECT * FROM retail_sales
WHERE total_sale > 1000


-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.

SELECT 
    category,
    gender,
    COUNT(*) as total_trans
FROM retail_sales
GROUP 
    BY 
    category,
    gender
ORDER BY 1


-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year

-- Using subquery from derived table
SELECT 
       year,
       month,
    avg_sale
FROM 
(    
SELECT 
    EXTRACT(YEAR FROM sale_date) as year,
    EXTRACT(MONTH FROM sale_date) as month,
    ROUND(AVG(total_sale),2) as avg_sale,
    RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) as rank
FROM retail_sales
GROUP BY 1, 2
) as t1
WHERE rank = 1
    
-- ORDER BY 1, 3 DESC


-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 

SELECT 
	customer_id,
	SUM(total_sale)
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;


-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.

SELECT
	category,
	COUNT(DISTINCT(customer_id)) as total_categoryId
FROM retail_sales
WHERE category in ('Beauty','Clothing','Electronics')
GROUP BY 1
ORDER BY total_categoryId;


--- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)

WITH hourly_sale 
AS
(
SELECT 
	*,
	CASE
		WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM sale_time) < 17 THEN 'Afternoon'
		ELSE 'Evening'
	END AS shift
FROM retail_sales
) 

SELECT 
	shift,
	COUNT(transactions_id)
FROM hourly_sale
GROUP BY shift;

-- Q.11 Who are the customers with above-average sales

SELECT
	customer_id,
	total_sale
FROM retail_sales
WHERE total_sale >
(
SELECT AVG(total_sale) FROM retail_sales
)

-- Subquery in SELECT (scalar subquery)
SELECT 
	customer_id,
	total_sale,
	(SELECT AVG(total_sale) FROM retail_sales) as avg_sales
FROM retail_sales;


-- Q.12 Which category sells the most quantity vs revenue?

SELECT
	category,
	sum(quantity),
	sum(total_sale)
FROM retail_sales
GROUP BY category

-- Q.13 What is the average price per unit per category?

SELECT
	category,
	avg(price_per_unit)
FROM retail_sales
GROUP BY category;


-- Q.14 Find the top-selling product category per day

WITH top_selling
AS
(
SELECT
	sale_date,
	category,
	SUM(total_sale) as total_sales,
	RANK() OVER (PARTITION BY sale_date ORDER BY SUM(total_sale) DESC) as rnk
FROM retail_sales
GROUP BY 1,2
)

SELECT 
	sale_date,
	category,
	total_sales
FROM top_selling
WHERE rnk = 1;


-- Q.15 Find the running total of sales over time

WITH daily_sales
AS
(
SELECT
	sale_date,
	SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY 1
)

SELECT *,
	SUM(total_sales) OVER (ORDER BY sale_date) as cumulative_sales
FROM daily_sales

-- Q.16 What is the peak sales hour per day

WITH sales_hour 
AS
(
SELECT 
	sale_date,
	EXTRACT(HOUR FROM sale_time) as hour,
	SUM(total_sale) AS total_sales,
	RANK() OVER (PARTITION BY sale_date ORDER BY SUM(total_sale) DESC) AS rnk
FROM retail_sales
GROUP BY 1,2
ORDER BY total_sales DESC
)

SELECT
	sale_date,
	hour,
	total_sales
FROM sales_hour
WHERE rnk =1
ORDER BY sale_date ASC;


-- Q.17 What is the Peak days in each month

WITH peak_days
AS
(
SELECT
	EXTRACT(YEAR FROM sale_date) as year,
	EXTRACT(MONTH FROM sale_date) as month,
	EXTRACT(DAY FROM sale_date) as day,
	SUM(total_sale) as total_sales
FROM retail_sales
GROUP BY 1,2,3
),
SELECT 
	*,
	RANK() OVER (PARTITION BY year,month ORDER BY total_sales DESC)
FROM peak_days

order by 1,2,3

