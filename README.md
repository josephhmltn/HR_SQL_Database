# SQL Data Exploration

## Employees Database

This SQL file outlines the creation and manipulation of an "employees" database, specifically designed for MS SQL Server. The script includes steps for database creation, table creation, data manipulation, and complex queries showcasing various SQL commands such as subqueries, joins, aggregate functions, and CASE statements.

## Database and Table Setup

~~~~sql
USE master
GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = 'employees')
	BEGIN
		DROP DATABASE employees;
	END;
	BEGIN 
		CREATE DATABASE employees;
	END;
GO
	USE employees;
GO
~~~~

The script starts by checking if the "employees" database exists; if it does, the database is dropped and then recreated. This ensures a fresh start.

~~~~sql
IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'customers' AND type = 'U')
	BEGIN
		CREATE TABLE customers (
			customer_id CHAR(8)				NOT NULL,
			bracket_cust_id CHAR(10)			NOT NULL,
			customer_name VARCHAR(255)			NOT NULL,
			segment VARCHAR(255)				NOT NULL,
			age INT						NOT NULL,
			country VARCHAR(255)				NOT NULL,
			city VARCHAR(255)				NOT NULL,
			state VARCHAR(255)				NOT NULL,
			postal_code INT					NOT NULL,
			region VARCHAR(255)				NOT NULL,
			PRIMARY KEY (customer_id)
		)
	END;

~~~~

~~~~sql
BULK INSERT customers
FROM "C:\Employees Data\Customers.csv"
WITH
(
	FORMAT = 'CSV',
	FIELDQUOTE = '"',
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	TABLOCK
);
~~~~

Creates each table after checking if it already exists and then does a bulk insert from a CSV file.

### Data Exploration

~~~~sql
--Get a list of employee first and last name, and their average salary
SELECT em.first_name, em.last_name, a.avg_salary
FROM employees em,
	(SELECT emp_no, AVG(salary) as avg_salary
	FROM salaries
	GROUP BY emp_no) a
WHERE em.emp_no = a.emp_no;
~~~~

~~~~sql
--Get a list of the highest-earning employee in each department
SELECT d.dept_name, e.emp_no, e.first_name, e.last_name, max_salary
FROM (
    SELECT de.dept_no, s.emp_no, MAX(s.salary) as max_salary
    FROM salaries s
    JOIN dept_emp de ON s.emp_no = de.emp_no
    GROUP BY de.dept_no, s.emp_no
) AS max_salaries
JOIN departments d ON max_salaries.dept_no = d.dept_no
JOIN employees e ON max_salaries.emp_no = e.emp_no
ORDER BY d.dept_name, max_salary DESC;
~~~~

~~~~sql
--Categories salaries into ranges
SELECT 
  CASE 
    WHEN salary <= 50000 THEN 'Low'
    WHEN salary > 50000 AND salary <= 100000 THEN 'Medium'
    ELSE 'High'
  END AS SalaryRange,
  COUNT(*) AS NumberOfEmployees
FROM salaries
GROUP BY SalaryRange;
~~~~
