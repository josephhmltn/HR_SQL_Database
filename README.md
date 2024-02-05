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
