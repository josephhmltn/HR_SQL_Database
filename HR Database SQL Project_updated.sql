--Create database after dropping an already existing database with the same name; This drop was for testing purposes.
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

--Create tables for later data import/bulk insert from CSV files
--Drop existing tables within the created database if bulk insert failed and have to start over
--DROP TABLE IF EXISTS salaries;
--DROP TABLE IF EXISTS dept_emp;
--DROP TABLE IF EXISTS dept_manager;
--DROP TABLE IF EXISTS customers;
--DROP TABLE IF EXISTS salaries;
--DROP TABLE IF EXISTS sales;
--DROP TABLE IF EXISTS employees;
--DROP TABLE IF EXISTS departments;

IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'customers' AND type = 'U')
	BEGIN
		CREATE TABLE customers (
			customer_id CHAR(8)				NOT NULL,
			bracket_cust_id CHAR(10)		NOT NULL,
			customer_name VARCHAR(255)		NOT NULL,
			segment VARCHAR(255)			NOT NULL,
			age INT							NOT NULL,
			country VARCHAR(255)			NOT NULL,
			city VARCHAR(255)				NOT NULL,
			state VARCHAR(255)				NOT NULL,
			postal_code INT					NOT NULL,
			region VARCHAR(255)				NOT NULL,
			PRIMARY KEY (customer_id)
		)
	END;

IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'sales' AND type = 'U')
	BEGIN
		CREATE TABLE sales (
			order_line INT				NOT NULL,
			order_id VARCHAR(255)		NOT NULL,
			order_date DATE				NOT NULL,
			ship_date DATE				NOT NULL,
			ship_mode VARCHAR(255)		NOT NULL,
			customer_id CHAR(8)			NOT NULL,
			product_id VARCHAR(255)		NOT NULL,
			category VARCHAR(255)		NOT NULL,
			sub_category VARCHAR(255)	NOT NULL,
			sales DECIMAL(10,5)			NOT NULL,
			quantity INT				NOT NULL,
			discount DECIMAL(4,2)		NOT NULL,
			profit DECIMAL(10,5)		NOT NULL
		)
	END;

IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'employees' AND type = 'U')
	BEGIN
		CREATE TABLE employees (
			emp_no      INT             NOT NULL,
			birth_date  DATE            NOT NULL,
			first_name  VARCHAR(14)     NOT NULL,
			last_name   VARCHAR(16)     NOT NULL,
			gender      CHAR(1) 		NOT NULL,    
			hire_date   DATE            NOT NULL,
			PRIMARY KEY (emp_no)
		)
	END;

IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'departments' AND type = 'U')
	BEGIN
		CREATE TABLE departments (
			dept_no     CHAR(4)				NOT NULL,
			dept_name   VARCHAR(40) UNIQUE	NOT NULL,
			PRIMARY KEY (dept_no)
		)
	END;

IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'dept_manager' AND type = 'U')
	BEGIN
		CREATE TABLE dept_manager (
		   emp_no       INT             NOT NULL,
		   dept_no      CHAR(4)         NOT NULL,
		   from_date    DATE            NOT NULL,
		   to_date      DATE            NOT NULL,
		   FOREIGN KEY (emp_no)  REFERENCES employees (emp_no)    ON DELETE CASCADE,
		   FOREIGN KEY (dept_no) REFERENCES departments (dept_no) ON DELETE CASCADE,
		   PRIMARY KEY (emp_no,dept_no)
		)
	END; 

IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'dept_emp' AND type = 'U')
	BEGIN
		CREATE TABLE dept_emp (
			emp_no      INT             NOT NULL,
			dept_no     CHAR(4)         NOT NULL,
			from_date   DATE            NOT NULL,
			to_date     DATE            NOT NULL,
			FOREIGN KEY (emp_no)  REFERENCES employees   (emp_no)  ON DELETE CASCADE,
			FOREIGN KEY (dept_no) REFERENCES departments (dept_no) ON DELETE CASCADE,
			PRIMARY KEY (emp_no,dept_no)
		)
	END;

IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'salaries' AND type = 'U')
	BEGIN
		CREATE TABLE salaries (
			emp_no      INT             NOT NULL,
			salary      INT             NOT NULL,
			from_date   DATE            NOT NULL,
			to_date     DATE            NOT NULL,
			FOREIGN KEY (emp_no) REFERENCES employees (emp_no) ON DELETE CASCADE,
			PRIMARY KEY (emp_no, from_date)
		)
	END; 

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

SELECT *
FROM customers;

BULK INSERT sales
FROM "C:\Employees Data\Sales.csv"
WITH
(
	FORMAT = 'CSV',
	FIELDQUOTE = '"',
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	TABLOCK
);

SELECT *
FROM sales;

BULK INSERT employees
FROM "C:\Employees Data\Employees.csv"
WITH
(
	FORMAT = 'CSV',
	FIELDQUOTE = '"',
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	TABLOCK
);

SELECT *
FROM employees;

BULK INSERT departments
FROM "C:\Employees Data\Departments.csv"
WITH
(
	FORMAT = 'CSV',
	FIELDQUOTE = '"',
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	TABLOCK
);

SELECT *
FROM departments;

BULK INSERT dept_manager
FROM "C:\Employees Data\Department manager.csv"
WITH
(
	FORMAT = 'CSV',
	FIELDQUOTE = '"',
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	TABLOCK
);

SELECT *
FROM dept_manager;

BULK INSERT dept_emp
FROM "C:\Employees Data\Department employees.csv"
WITH
(
	FORMAT = 'CSV',
	FIELDQUOTE = '"',
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	TABLOCK
);

SELECT *
FROM dept_emp;

BULK INSERT salaries
FROM "C:\Employees Data\Salaries.csv"
WITH
(
	FORMAT = 'CSV',
	FIELDQUOTE = '"',
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	TABLOCK
);

--This is an old project that I did while learning SQL. I wanted to update it to use more advanced syntax, such as CTEs, since at the time I focused on improving my basic query syntax.
--The updated queries are for better readability and response time when executing the query. It might matter on my demo database but with millions of rows in each table it will matter.
--The original queries will be labeled with the *Original* tag and then the updated query with be labeled with *Updated* tag.

--Query 1: Get a list of all employees that are not managers.

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

--Query 2: Get a list of all customers that are above 60 years old.

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

--Query 3: Get a list of all managers with employee number, first, and last names.

--Original
SELECT emp_no, first_name, last_name
FROM employees
WHERE employees.emp_no IN (SELECT emp_no FROM dept_manager);

--Updated
WITH Managers AS (
    SELECT emp_no
    FROM dept_manager
)

SELECT e.emp_no, e.first_name, e.last_name
FROM employees e
JOIN Managers m ON e.emp_no = m.emp_no;

--Query 4: Get a list of all managers first and last name, and their respective department names.

--Original
SELECT em.first_name, em.last_name, de.dept_name
FROM dept_manager dm, employees em, (SELECT dept_no, dept_name FROM departments) de
WHERE dm.dept_no = de.dept_no AND em.emp_no = dm.emp_no;

--Updated
SELECT em.first_name, em.last_name, d.dept_name
FROM dept_manager dm
JOIN employees em ON dm.emp_no = em.emp_no
JOIN departments d ON dm.dept_no = d.dept_no;

--Query 5: Get a list of customer IDS, product IDs, order lines, and name of the customer.

--Original
SELECT customer_id, 
	product_id, 
	order_line, 
	(SELECT customer_name 
	FROM customers c
	WHERE s.customer_id = c.customer_id) AS customer_name
FROM sales s
ORDER BY customer_id;

--Updated
SELECT s.customer_id, s.product_id, s.order_line, c.customer_name
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
ORDER BY s.customer_id;

--Query 6: Get a list of employee first and last name, and their average salary

--Original
SELECT em.first_name, em.last_name, a.avg_salary
FROM employees em, (SELECT emp_no, AVG(salary) as avg_salary
					FROM salaries
					GROUP BY emp_no) a
WHERE em.emp_no = a.emp_no;

--Updated
WITH AvgSalaries AS (
    SELECT emp_no, AVG(salary) AS avg_salary
    FROM salaries
    GROUP BY emp_no
)

SELECT em.first_name, em.last_name, asa.avg_salary
FROM employees em
JOIN AvgSalaries asa ON em.emp_no = asa.emp_no;

--Query 7: Get a list of all employees in the Customer Service department, along with their employee number, first, and last name.

--Original
SELECT em.emp_no, de.dept_no, em.first_name, em.last_name
FROM employees em
JOIN (SELECT *
	  FROM dept_emp
	  WHERE dept_no IN (SELECT dept_no 
						FROM departments
						WHERE dept_name IN ('Customer Service'))) AS de
ON em.emp_no = de.emp_no
ORDER BY emp_no;

--Updated
WITH CustomerServiceEmp AS (
    SELECT de.emp_no, de.dept_no
    FROM dept_emp de
    JOIN departments d ON de.dept_no = d.dept_no
    WHERE d.dept_name = 'Customer Service'
)

SELECT e.emp_no, cse.dept_no, e.first_name, e.last_name
FROM employees e
JOIN CustomerServiceEmp cse ON e.emp_no = cse.emp_no
ORDER BY e.emp_no;

--Query 8: Get a list of all managers in the finance or HR departments that got promoted to manager after, but not including, 1 January 1985. Retrieve their employee number, first and last name, department number, and promoted date (from date).

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

--Query 9: Get a list of all employees that currently earn a salary above 120,000 in the Marketing or Development departments, including their employee number, first, and last names.

--Original
SELECT em.emp_no, em.first_name, em.last_name, MAX(s.salary) as recent_salary																										  
FROM employees em
JOIN (SELECT *
	  FROM salaries
	  WHERE salary > 120000
	  AND emp_no IN (SELECT emp_no
					 FROM dept_emp
					 WHERE dept_no IN (SELECT dept_no
									   FROM departments
									   WHERE dept_name IN ('Marketing','Development')))) as s
ON s.emp_no = em.emp_no
GROUP BY em.emp_no, em.first_name, em.last_name;

--Updated
WITH DeptEmps AS (
    SELECT emp_no, dept_no
    FROM dept_emp
    WHERE dept_no IN (
        SELECT dept_no
        FROM departments
        WHERE dept_name IN ('Marketing', 'Development'))
), 
    HighEarners AS (
    SELECT emp_no, salary
    FROM salaries
    WHERE salary > 120000
)

SELECT em.emp_no, em.first_name, em.last_name, MAX(he.salary) as recent_salary
FROM employees em
JOIN DeptEmps de ON em.emp_no = de.emp_no
JOIN HighEarners he ON em.emp_no = he.emp_no
GROUP BY em.emp_no, em.first_name, em.last_name;

--Query 10: Get a list of all employees who earn more than the average salary in their respective department

--Original
SELECT e.emp_no, e.first_name, e.last_name, s.salary, de.dept_no
FROM employees e
JOIN salaries s ON e.emp_no = s.emp_no
JOIN dept_emp de ON e.emp_no = de.emp_no
WHERE s.salary > (
    SELECT AVG(salary)
    FROM salaries
    WHERE emp_no = e.emp_no);

--Updated
WITH DeptAvgSalary AS (
    SELECT de.dept_no, AVG(s.salary) AS avg_salary
    FROM dept_emp de
    JOIN salaries s ON de.emp_no = s.emp_no
    GROUP BY de.dept_no
)

SELECT e.emp_no, e.first_name, e.last_name, s.salary, de.dept_no
FROM employees e
JOIN salaries s ON e.emp_no = s.emp_no
JOIN dept_emp de ON e.emp_no = de.emp_no
JOIN DeptAvgSalary das ON de.dept_no = das.dept_no
WHERE s.salary > das.avg_salary;

--Query 11: Get a list of the highest-earning employee in each department

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

--Query 12: Get a list of all employees including their employee number, first and last names, their respective average salary, the average salary of all employees, and the difference between those two averages.

--Original
SELECT *, emp_avg_salary - all_emp_avg_salary as diff_in_salary
FROM (SELECT em.emp_no, em.first_name, em.last_name, a.emp_avg_salary,
	 (SELECT ROUND(AVG(CAST(salary as bigint)), 2) FROM salaries) as all_emp_avg_salary
	  FROM employees em
	  JOIN (SELECT sal.emp_no, ROUND(AVG(sal.salary), 2) as emp_avg_salary
			FROM salaries sal
			GROUP BY sal.emp_no) as a
	  ON em.emp_no = a.emp_no) as b
ORDER BY emp_no

--Updated
WITH EmployeeAvgSalary AS (
    SELECT emp_no, ROUND(AVG(salary), 2) AS emp_avg_salary
    FROM salaries
    GROUP BY emp_no
), 
    OverallAvgSalary AS (
    SELECT ROUND(AVG(CAST(salary AS bigint)), 2) AS all_emp_avg_salary
    FROM salaries
)

SELECT em.emp_no, em.first_name, em.last_name, eas.emp_avg_salary, oas.all_emp_avg_salary,
       eas.emp_avg_salary - oas.all_emp_avg_salary AS diff_in_salary
FROM employees em
JOIN EmployeeAvgSalary eas ON em.emp_no = eas.emp_no,
     OverallAvgSalary oas
ORDER BY em.emp_no;

--Query 13: Categories salaries into ranges

--Original
SELECT 
  CASE 
    WHEN salary <= 50000 THEN 'Low'
    WHEN salary > 50000 AND salary <= 100000 THEN 'Medium'
    ELSE 'High'
  END AS SalaryRange,
  COUNT(*) AS NumberOfEmployees
FROM salaries
GROUP BY SalaryRange;

--Updated
WITH SalaryCategories AS (
    SELECT 
      CASE 
        WHEN salary <= 50000 THEN 'Low'
        WHEN salary > 50000 AND salary <= 100000 THEN 'Medium'
        ELSE 'High'
      END AS SalaryRange
    FROM salaries
)

SELECT SalaryRange, COUNT(*) AS NumberOfEmployees
FROM SalaryCategories
GROUP BY SalaryRange;

--Query 14: Categorize sales into ranges

--Original
SELECT 
  CASE 
    WHEN SUM(Sales) <= 100 THEN 'Low'
    WHEN SUM(Sales) > 100 AND SUM(Sales) <= 500 THEN 'Medium'
    ELSE 'High'
  END AS SalesRange,
  COUNT(*) AS NumberOfSales
FROM sales
GROUP BY SalesRange;

--Updated

WITH SalesCategories AS (
    SELECT 
      CASE 
        WHEN SUM(Sales) <= 100 THEN 'Low'
        WHEN SUM(Sales) > 100 AND SUM(Sales) <= 500 THEN 'Medium'
        ELSE 'High'
      END AS SalesRange
    FROM sales
)

SELECT SalesRange, COUNT(*) AS NumberOfSales
FROM SalesCategories
GROUP BY SalesRange;