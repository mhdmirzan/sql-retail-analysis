# Retail Sales Analysis SQL Project

## Project Overview

**Project Title:** Retail Sales Analysis using SQL
**Level:** Beginner to Intermediate
**Database:** `sql_project_p2`

This project demonstrates practical SQL skills used in real-world retail analytics. It covers database creation, data cleaning, exploratory data analysis (EDA), and advanced business intelligence queries to uncover sales trends, customer behavior, category performance, and revenue insights.

The project is designed to strengthen SQL concepts such as:

* Data Cleaning
* Aggregations
* Grouping & Filtering
* Subqueries
* Common Table Expressions (CTEs)
* Window Functions
* Ranking Functions
* Business Analytics

---

# Objectives

### 1. Database Setup

Create a retail sales database and store transaction-level sales records.

### 2. Data Cleaning

Identify and remove incomplete records containing null values.

### 3. Exploratory Data Analysis (EDA)

Understand customer demographics, product categories, and sales distribution.

### 4. Business Analysis

Answer real-world business questions using SQL queries and derive actionable insights.

---

# Database Setup

## Create Database

```sql
CREATE DATABASE sql_project_p2;
```

## Create Table

```sql
CREATE TABLE retail_sales
(
    transaction_id INT PRIMARY KEY,
    sale_date DATE,
    sale_time TIME,
    customer_id INT,
    gender VARCHAR(15),
    age INT,
    category VARCHAR(15),
    quantity INT,
    price_per_unit FLOAT,
    cogs FLOAT,
    total_sale FLOAT
);
```

---

# Data Exploration & Cleaning

## Total Records

```sql
SELECT COUNT(*)
FROM retail_sales;
```

## Unique Customers

```sql
SELECT COUNT(DISTINCT customer_id)
FROM retail_sales;
```

## Product Categories

```sql
SELECT DISTINCT category
FROM retail_sales;
```

## Find Missing Values

```sql
SELECT *
FROM retail_sales
WHERE transaction_id IS NULL
   OR sale_date IS NULL
   OR sale_time IS NULL
   OR gender IS NULL
   OR category IS NULL
   OR quantity IS NULL
   OR cogs IS NULL
   OR total_sale IS NULL;
```

## Remove Incomplete Records

```sql
DELETE FROM retail_sales
WHERE transaction_id IS NULL
   OR sale_date IS NULL
   OR sale_time IS NULL
   OR gender IS NULL
   OR category IS NULL
   OR quantity IS NULL
   OR cogs IS NULL
   OR total_sale IS NULL;
```

---

# Business Analysis Queries

## Q1. Sales on a Specific Date

Retrieve all sales made on **2022-11-05**.

```sql
SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';
```

---

## Q2. Clothing Sales with Quantity Greater than 4 in November 2022

```sql
SELECT *
FROM retail_sales
WHERE category = 'Clothing'
AND TO_CHAR(sale_date,'YYYY-MM')='2022-11'
AND quantity >= 4;
```

---

## Q3. Total Sales by Category

```sql
SELECT
    category,
    SUM(total_sale) AS net_sale,
    COUNT(*) AS total_orders
FROM retail_sales
GROUP BY category;
```

---

## Q4. Average Age of Beauty Category Customers

```sql
SELECT
    ROUND(AVG(age),2) AS avg_age
FROM retail_sales
WHERE category='Beauty';
```

---

## Q5. High-Value Transactions

Find transactions where sales exceeded 1000.

```sql
SELECT *
FROM retail_sales
WHERE total_sale > 1000;
```

---

## Q6. Transactions by Gender and Category

```sql
SELECT
    category,
    gender,
    COUNT(*) AS total_transactions
FROM retail_sales
GROUP BY category, gender
ORDER BY category;
```

---

## Q7. Best Selling Month in Each Year

```sql
SELECT
    year,
    month,
    avg_sale
FROM
(
    SELECT
        EXTRACT(YEAR FROM sale_date) AS year,
        EXTRACT(MONTH FROM sale_date) AS month,
        ROUND(AVG(total_sale),2) AS avg_sale,
        RANK() OVER(
            PARTITION BY EXTRACT(YEAR FROM sale_date)
            ORDER BY AVG(total_sale) DESC
        ) AS rank
    FROM retail_sales
    GROUP BY 1,2
) t1
WHERE rank = 1;
```

---

## Q8. Top 5 Customers by Total Sales

```sql
SELECT
    customer_id,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;
```

---

## Q9. Unique Customers per Category

```sql
SELECT
    category,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales
GROUP BY category;
```

---

## Q10. Sales by Shift

Morning < 12

Afternoon 12–17

Evening > 17

```sql
WITH hourly_sale AS
(
    SELECT *,
    CASE
        WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM sale_time) < 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift
    FROM retail_sales
)

SELECT
    shift,
    COUNT(*) AS total_orders
FROM hourly_sale
GROUP BY shift;
```

---

# Advanced Business Analysis

## Q11. Customers with Above-Average Sales

```sql
SELECT
    customer_id,
    total_sale
FROM retail_sales
WHERE total_sale >
(
    SELECT AVG(total_sale)
    FROM retail_sales
);
```

### Insight

Identifies premium customers generating higher-than-average revenue.

---

## Q12. Category Performance by Quantity and Revenue

```sql
SELECT
    category,
    SUM(quantity) AS total_quantity,
    SUM(total_sale) AS total_revenue
FROM retail_sales
GROUP BY category;
```

### Insight

Shows whether a category sells more units or generates more revenue.

---

## Q13. Average Price per Unit by Category

```sql
SELECT
    category,
    AVG(price_per_unit) AS avg_price
FROM retail_sales
GROUP BY category;
```

### Insight

Helps compare pricing strategies across categories.

---

## Q14. Top-Selling Category per Day

```sql
WITH top_selling AS
(
    SELECT
        sale_date,
        category,
        SUM(total_sale) AS total_sales,
        RANK() OVER
        (
            PARTITION BY sale_date
            ORDER BY SUM(total_sale) DESC
        ) AS rnk
    FROM retail_sales
    GROUP BY sale_date, category
)

SELECT
    sale_date,
    category,
    total_sales
FROM top_selling
WHERE rnk = 1;
```

### Insight

Identifies which category dominated sales each day.

---

## Q15. Running Total of Sales Over Time

```sql
WITH daily_sales AS
(
    SELECT
        sale_date,
        SUM(total_sale) AS total_sales
    FROM retail_sales
    GROUP BY sale_date
)

SELECT *,
       SUM(total_sales)
       OVER(ORDER BY sale_date) AS cumulative_sales
FROM daily_sales;
```

### Insight

Tracks business growth over time using cumulative revenue.

---

## Q16. Peak Sales Hour per Day

```sql
WITH sales_hour AS
(
    SELECT
        sale_date,
        EXTRACT(HOUR FROM sale_time) AS hour,
        SUM(total_sale) AS total_sales,
        RANK() OVER
        (
            PARTITION BY sale_date
            ORDER BY SUM(total_sale) DESC
        ) AS rnk
    FROM retail_sales
    GROUP BY sale_date, hour
)

SELECT
    sale_date,
    hour,
    total_sales
FROM sales_hour
WHERE rnk = 1;
```

### Insight

Determines the busiest sales hour for each day.

---

## Q17. Peak Sales Day in Each Month

```sql
WITH peak_days AS
(
    SELECT
        EXTRACT(YEAR FROM sale_date) AS year,
        EXTRACT(MONTH FROM sale_date) AS month,
        EXTRACT(DAY FROM sale_date) AS day,
        SUM(total_sale) AS total_sales
    FROM retail_sales
    GROUP BY 1,2,3
)

SELECT *,
       RANK() OVER
       (
           PARTITION BY year, month
           ORDER BY total_sales DESC
       ) AS rank
FROM peak_days;
```

### Insight

Identifies the highest revenue-generating day in each month.

---

# Key Findings

### Customer Insights

* Several customers spend significantly above the average transaction value.
* Top customers contribute a large percentage of overall revenue.

### Category Insights

* Certain categories drive high sales volume while others generate higher profit.
* Product pricing varies considerably between categories.

### Sales Trends

* Revenue fluctuates across months and seasons.
* Specific days and hours consistently generate peak sales.

### Operational Insights

* Shift analysis reveals when staffing requirements should be highest.
* Daily and monthly peak periods can support inventory planning.

---

# Skills Demonstrated

* SQL Data Cleaning
* Aggregate Functions
* GROUP BY Analysis
* Date & Time Functions
* Common Table Expressions (CTEs)
* Subqueries
* Window Functions
* Ranking Functions
* Business Intelligence Analytics

---

# Tools Used

* PostgreSQL
* SQL
* GitHub

---

# How to Use

1. Clone the repository.
2. Create the database using the provided SQL script.
3. Import the retail sales dataset.
4. Execute each query to perform analysis.
5. Modify queries to explore additional business questions.

---

# Conclusion

This project demonstrates the complete SQL analytics workflow, from database setup and cleaning to advanced business intelligence reporting. Through the use of aggregations, window functions, ranking, and CTEs, meaningful insights can be extracted from retail sales data to support strategic business decisions.

---

# Author

**Muhammadu Fawas Mohammed Mirzan**

Data Analytics | Data Science | Business Intelligence

If you found this project useful, feel free to star the repository and connect with me for collaboration and feedback.
