# Session 23 Lecture Guide: SQL GROUP BY Syntax, Group Aggregation & Business Reporting

This comprehensive lecture and reference guide covers the core principles, execution mechanics, and real-world business applications of the SQL **`GROUP BY`** clause and **Group Aggregations**.

---

## 1. SQL GROUP BY Syntax & Execution Mechanics

### A. What is `GROUP BY`?
The **`GROUP BY`** clause collapses multiple rows sharing identical values in specified columns into a single summary row per unique group. It transforms raw individual records into aggregated metrics suitable for reporting and analytics.

### B. Logical Query Execution Pipeline
Understanding the exact sequence in which the database engine processes an SQL query is critical to writing correct grouping queries:

```
1. FROM / JOIN     --> Identify and combine source tables
2. WHERE           --> Filter raw individual rows BEFORE grouping
3. GROUP BY        --> Group remaining rows by unique column values
4. HAVING          --> Filter summary groups AFTER aggregation
5. SELECT          --> Evaluate expressions, column projections, & aggregates
6. DISTINCT        --> Eliminate duplicate summary rows (if specified)
7. ORDER BY        --> Sort final aggregated result set
8. LIMIT / OFFSET   --> Restrict the number of output rows
```

### C. Standard Syntax & The "ONLY_FULL_GROUP_BY" Rule
In standard ANSI SQL (and MySQL `ONLY_FULL_GROUP_BY` SQL mode), every non-aggregated column in the `SELECT` list **MUST** be explicitly listed in the `GROUP BY` clause.

```sql
-- VALID: All non-aggregated columns (dept_id, job_title) appear in GROUP BY
SELECT dept_id, job_title, COUNT(*) AS emp_count, AVG(salary) AS avg_sal
FROM Employees
WHERE status = 'ACTIVE'
GROUP BY dept_id, job_title
HAVING COUNT(*) >= 2
ORDER BY avg_sal DESC;
```

> **Syntax Violation Rule:** Querying `SELECT dept_id, first_name, AVG(salary)` with `GROUP BY dept_id` is invalid because `first_name` is neither aggregated nor listed in `GROUP BY`. MySQL cannot deterministically choose which `first_name` to display for a department with 50 employees.

---

## 2. Group Aggregation Dynamics & NULL Handling

### A. Single-Column vs. Multi-Column Grouping
- **Single-Column Grouping:** Groups rows based on distinct values of a single column (e.g., `GROUP BY department_id`).
- **Multi-Column Grouping:** Creates a unique group for every unique **combination** of values across multiple columns (e.g., `GROUP BY department_id, job_title`).

### B. Handling `NULL` Values in Grouping Columns
- In `GROUP BY` operations, all `NULL` values in a grouping column are treated as **equal** and grouped together into a **single summary row**.
- Aggregate functions (e.g., `SUM()`, `AVG()`) within each group ignore `NULL` values in their calculation operands, but `COUNT(*)` counts all rows in the group regardless of `NULL`s.

---

## 3. Real-World Business Reporting Queries

### Scenario 1: Department-Wise Financial & Workforce Metrics
Compute the total head count, average salary, minimum salary, and total payroll cost per department:

```sql
SELECT 
    d.department_name,
    COUNT(e.emp_id) AS total_employees,
    MIN(e.salary) AS min_salary,
    MAX(e.salary) AS max_salary,
    ROUND(AVG(e.salary), 2) AS avg_salary,
    SUM(e.salary) AS total_payroll
FROM Departments d
JOIN Employees e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
ORDER BY total_payroll DESC;
```

### Scenario 2: Monthly Sales Revenue & Order Performance
Analyze monthly sales revenue, total orders placed, and average order value for 2026:

```sql
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
    COUNT(order_id) AS total_orders,
    SUM(total_amount) AS gross_revenue,
    ROUND(AVG(total_amount), 2) AS avg_order_value
FROM Orders
WHERE order_date >= '2026-01-01' AND order_date < '2027-01-01'
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY sales_month ASC;
```

### Scenario 3: High-Value Customer Identification (`HAVING` Clause)
Identify premium VIP customers who have placed more than 5 orders and spent over $2,500 total:

```sql
SELECT 
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS order_count,
    SUM(o.total_amount) AS total_spent
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(o.order_id) > 5 AND SUM(o.total_amount) > 2500.00
ORDER BY total_spent DESC;
```

---

## 4. Practice Problems & Solutions

### Practice Problem 1: Department Workforce Thresholds
**Question:** Write an SQL query to find all departments that employ more than 3 active employees. Display the department ID, total active employees, and average salary, ordered by average salary descending.

```sql
-- Solution:
SELECT department_id, COUNT(*) AS active_emp_count, ROUND(AVG(salary), 2) AS avg_salary
FROM Employees
WHERE status = 'ACTIVE'
GROUP BY department_id
HAVING COUNT(*) > 3
ORDER BY avg_salary DESC;
```

### Practice Problem 2: Detecting Duplicate Email Registrations
**Question:** Write an SQL query to identify duplicate email addresses in a `Users` table and display how many times each duplicate appears.

```sql
-- Solution:
SELECT email, COUNT(*) AS occurrence_count
FROM Users
GROUP BY email
HAVING COUNT(*) > 1
ORDER BY occurrence_count DESC;
```

### Practice Problem 3: Regional Product Category Sales
**Question:** Calculate the total quantity sold and revenue generated per product category within each sales region, displaying only category/region pairs generating over $10,000.

```sql
-- Solution:
SELECT 
    region,
    category_name,
    SUM(quantity) AS total_units_sold,
    SUM(quantity * unit_price) AS total_revenue
FROM Sales
GROUP BY region, category_name
HAVING SUM(quantity * unit_price) > 10000.00
ORDER BY region ASC, total_revenue DESC;
```

---

## 5. Summary Matrix: WHERE vs. HAVING with GROUP BY

| Feature / Metric | `WHERE` Clause | `HAVING` Clause |
| :--- | :--- | :--- |
| **Execution Timing** | Executes **BEFORE** `GROUP BY` row aggregation. | Executes **AFTER** `GROUP BY` row aggregation. |
| **Filtering Target** | Filters individual raw table rows. | Filters summary groups. |
| **Aggregate Functions** | **CANNOT** contain aggregate functions (`WHERE SUM(col) > 10` is invalid). | **CAN** contain aggregate functions (`HAVING SUM(col) > 10`). |
| **Index Usage** | Can utilize standard table B-Tree indexes. | Evaluates on temporary grouped result sets. |
| **Primary Purpose** | Restricts input data prior to grouping. | Eliminates unwanted summary rows post-grouping. |
