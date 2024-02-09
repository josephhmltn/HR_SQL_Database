# HR Database Project Summary

This project involves creating a comprehensive HR database using MS SQL Server, designed for a test environment. It showcases the process of setting up a database from scratch, including the creation of tables for customers, sales, employees, departments, department managers, and salaries. The project employs both basic and advanced SQL techniques, demonstrating the progression in query complexity and efficiency.

## Key Features

- **Database Setup**: Initial steps include dropping an existing database if present, and creating a new one named `employees`.
- **Table Creation**: Tables are created for various entities like customers, sales, employees, departments, dept_manager, dept_emp, and salaries, with appropriate data types and constraints.
- **Data Import**: Bulk data import from CSV files into the respective tables, preparing the database for querying.
- **Query Optimization**: Re-wrote all queries necessary queries with Common Table Expressions (CTEs) for better readability and performance. Original query and Updated queries are presented to show difference.

### Database and Table Creation

- The script starts by checking if the "employees" database exists; if it does, the database is dropped and then recreated. This ensures a fresh start.
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

- Next, each table then get created based on the parameters set and a bulk insert is applied to import the CSV files into each table.

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

## Highlighted Queries

### Query 1: Identifying Non-Manager Employees
Shows all employees who are not in a managerial position using a subquery in the original version and a CTE in the updated version for improved readability.
~~~~sql
--Original
SELECT *
FROM employees
WHERE employees.emp_no NOT IN (SELECT emp_no FROM dept_manager);

--Updated
WITH NonManagers AS (
SELECT *
FROM employees
WHERE emp_no NOT IN (SELECT emp_no FROM dept_manager)
)

SELECT * FROM NonManagers;
~~~~
### Query 2: Finding Elderly Customers
Lists all customers over the age of 60 by joining the `sales` and `customers` tables, highlighting the use of a subquery and a CTE for refining the selection process.
~~~~sql
--Original
SELECT *
FROM sales
WHERE sales.customer_id IN (SELECT customer_id FROM customers WHERE Age > 60);

--Updated
WITH ElderlyCustomers AS (
    SELECT customer_id
    FROM customers
    WHERE Age > 60
)

SELECT s.*
FROM sales s
JOIN ElderlyCustomers ec ON s.customer_id = ec.customer_id;
~~~~

### Query 3: Managers and Their Departments
Shows all managers along with their first and last names, and the names of their respective departments, utilizing joins across multiple tables to gather comprehensive information.
~~~~sql
--Original
SELECT em.first_name, em.last_name, de.dept_name
FROM dept_manager dm, employees em, (SELECT dept_no, dept_name FROM departments) de
WHERE dm.dept_no = de.dept_no AND em.emp_no = dm.emp_no;

--Updated
SELECT em.first_name, em.last_name, d.dept_name
FROM dept_manager dm
JOIN employees em ON dm.emp_no = em.emp_no
JOIN departments d ON dm.dept_no = d.dept_no;
~~~~

### Query 4: Finance or HR Department Managers with promotion date after 1 January 1985.
Lists employee number along with their first and last name, department number, and promoted date from the `department`, `department manager`, `employees` and `department name` tables.

~~~~sql
--Original
SELECT em.emp_no, em.first_name, em.last_name, dm.dept_no, dm.from_date
FROM employees em, (
SELECT *
FROM dept_manager
WHERE from_date > '1985-01-01'
AND dept_no IN (SELECT dept_no 
                FROM departments 
                WHERE dept_name IN ('Finance','Human Resources'))) as dm
WHERE em.emp_no = dm.emp_no;

--Updated
WITH FinanceHRDepts AS (
    SELECT dept_no
    FROM departments
    WHERE dept_name IN ('Finance', 'Human Resources')
), 
    PromotedManagers AS (
    SELECT dm.emp_no, dm.dept_no, dm.from_date
    FROM dept_manager dm
    JOIN FinanceHRDepts fhd ON dm.dept_no = fhd.dept_no
    WHERE dm.from_date > '1985-01-01'
)

SELECT em.emp_no, em.first_name, em.last_name, pm.dept_no, pm.from_date
FROM employees em
JOIN PromotedManagers pm ON em.emp_no = pm.emp_no;
~~~~

### Query 5:
Lists the highest-earning employee in each department from the `salary`, `departments`, and `employees` tables.

~~~~sql
--Original
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

--Updated
WITH RankedSalaries AS (
    SELECT de.dept_no, s.emp_no, s.salary,
           RANK() OVER (PARTITION BY de.dept_no ORDER BY s.salary DESC) as salary_rank
    FROM salaries s
    JOIN dept_emp de ON s.emp_no = de.emp_no
)

SELECT d.dept_name, e.emp_no, e.first_name, e.last_name, rs.salary
FROM RankedSalaries rs
JOIN departments d ON rs.dept_no = d.dept_no
JOIN employees e ON rs.emp_no = e.emp_no
WHERE rs.salary_rank = 1
ORDER BY d.dept_name, rs.salary DESC;
~~~~
