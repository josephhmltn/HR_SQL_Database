--Create database for project
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

--Getting tables ready data import/bulk insert from csv files

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
FROM "C:\Users\josep\OneDrive\Desktop\SQL Projects\Employees Data\Customers.csv"
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
FROM employees..customers;

BULK INSERT sales
FROM "C:\Users\josep\OneDrive\Desktop\SQL Projects\Employees Data\Sales.csv"
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
FROM employees..sales;

BULK INSERT employees
FROM "C:\Users\josep\OneDrive\Desktop\SQL Projects\Employees Data\Employees.csv"
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
FROM employees..employees;

BULK INSERT departments
FROM "C:\Users\josep\OneDrive\Desktop\SQL Projects\Employees Data\Departments.csv"
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
FROM employees..departments;

BULK INSERT dept_manager
FROM "C:\Users\josep\OneDrive\Desktop\SQL Projects\Employees Data\Department manager.csv"
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
FROM employees..dept_manager;

BULK INSERT dept_emp
FROM "C:\Users\josep\OneDrive\Desktop\SQL Projects\Employees Data\Department employees.csv"
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
FROM employees..dept_emp;

BULK INSERT salaries
FROM "C:\Users\josep\OneDrive\Desktop\SQL Projects\Employees Data\Salaries.csv"
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
FROM employees..salaries;

--List of all employees that are not managers.

SELECT *
FROM employees..employees
WHERE employees.emp_no NOT IN (SELECT emp_no 
							   FROM employees..dept_manager);

--List of all customers that are above 60 years old.

SELECT *
FROM employees..sales
WHERE sales.customer_id IN (SELECT customer_id 
							FROM employees..customers
							WHERE Age > 60);

--List of all managers with employee number, first, and last names.

SELECT emp_no, first_name, last_name
FROM employees..employees
WHERE employees.emp_no IN (SELECT emp_no
						   FROM employees..dept_manager);

--Get a list of all managers first and last name, and their respective department names.

SELECT em.first_name, em.last_name, de.dept_name
FROM employees..dept_manager dm, employees..employees em, (SELECT dept_no, dept_name
														   FROM employees..departments) de
WHERE dm.dept_no = de.dept_no AND em.emp_no = dm.emp_no;

--Get a list of customer IDS, product IDs, order lines, and name of the customer.

SELECT customer_id, product_id, order_line, (SELECT customer_name 
											 FROM employees..customers c
											 WHERE s.customer_id = c.customer_id) AS customer_name
FROM employees..sales s
ORDER BY customer_id;

--Get a list of employee first and last name, and their average salary

SELECT em.first_name, em.last_name, a.avg_salary
FROM employees..employees em, (SELECT emp_no, AVG(salary) as avg_salary
							   FROM employees..salaries
							   GROUP BY emp_no) a
WHERE em.emp_no = a.emp_no;

--Get a list of all employees in the Customer Service department, along with their employee number, first, and last name.

SELECT em.emp_no, de.dept_no, em.first_name, em.last_name
FROM employees..employees em
JOIN (SELECT *
	  FROM employees..dept_emp
	  WHERE dept_no IN (SELECT dept_no 
						FROM employees..departments
						WHERE dept_name IN ('Customer Service'))) AS de
ON em.emp_no = de.emp_no
ORDER BY emp_no;

--Get a list of all managers in the finance or HR departments that got promoted to manager after, but not including, 1 January 1985.
--Retrieve their employee number, first and last name, department number, and promoted date (from date).

SELECT em.emp_no, em.first_name, em.last_name, dm.dept_no, dm.from_date
FROM employees..employees em, (
SELECT *
FROM employees..dept_manager
WHERE from_date > '1985-01-01'
AND dept_no IN (SELECT dept_no 
				FROM employees..departments
				WHERE dept_name IN ('Finance','Human Resources'))) as dm
WHERE em.emp_no = dm.emp_no;

--Get a list of all employees that currently earn a salary above 120,000 in the Marketing or Development departments,
--including their employee number, first, and last names

SELECT em.emp_no, em.first_name, em.last_name, MAX(s.salary) as recent_salary																										  
FROM employees..employees em
JOIN (SELECT *
	  FROM employees..salaries
	  WHERE salary > 120000
	  AND emp_no IN (SELECT emp_no
					 FROM employees..dept_emp
					 WHERE dept_no IN (SELECT dept_no
									   FROM employees..departments
									   WHERE dept_name IN ('Marketing','Development')))) as s
ON s.emp_no = em.emp_no
GROUP BY em.emp_no, em.first_name, em.last_name;

--Get a list of all employees including their employee number, first and last names, their respective average salary, 
--the average salary of all employees, and the difference between those two averages.

SELECT *, emp_avg_salary - all_emp_avg_salary as diff_in_salary
FROM (SELECT em.emp_no, em.first_name, em.last_name, a.emp_avg_salary,
	 (SELECT ROUND(AVG(CAST(salary as bigint)), 2) FROM employees..salaries) as all_emp_avg_salary
	  FROM employees..employees em
	  JOIN (SELECT sal.emp_no, ROUND(AVG(sal.salary), 2) as emp_avg_salary
			FROM employees..salaries sal
			GROUP BY sal.emp_no) as a
	  ON em.emp_no = a.emp_no) as b
ORDER BY emp_no