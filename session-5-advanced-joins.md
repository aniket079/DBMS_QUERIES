# Session Guide: Advanced Joins, Multi-Table Queries & Join Mechanics

## 1. Complete Database Setup Script
Copy and execute this script in **MySQL Workbench** to set up tables for Self Joins, Cross Joins, and Multi-Table Joins.

```sql
CREATE DATABASE IF NOT EXISTS advanced_joins_db;
USE advanced_joins_db;

-- Drop tables if they exist
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS variants;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS customers;

-- 1. Employees Table (Self-referential hierarchy)
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    job_title VARCHAR(50) NOT NULL,
    manager_id INT,
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
);

INSERT INTO employees VALUES
(1, 'Eleanor', 'Vance', 'Chief Executive Officer', NULL),
(2, 'Marcus', 'Brody', 'VP of Sales', 1),
(3, 'Sophia', 'Chen', 'VP of Engineering', 1),
(4, 'David', 'Miller', 'Sales Manager', 2),
(5, 'Sarah', 'Connor', 'Senior Software Engineer', 3),
(6, 'James', 'Wilson', 'Sales Associate', 4);

-- 2. Customers Table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

INSERT INTO customers (full_name, email) VALUES
('Alice Johnson', 'alice@example.com'),
('Bob Smith', 'bob@example.com'),
('Charlie Brown', 'charlie@example.com');

-- 3. Products Table
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    base_price DECIMAL(10,2) NOT NULL
);

INSERT INTO products (product_name, base_price) VALUES
('Custom T-Shirt', 25.00),
('Coffee Mug', 15.00);

-- 4. Variants Table (For Cross Join matrix)
CREATE TABLE variants (
    size_name VARCHAR(10),
    color_name VARCHAR(20)
);

INSERT INTO variants VALUES
('S', 'Red'), ('M', 'Red'), ('L', 'Red'),
('S', 'Blue'), ('M', 'Blue'), ('L', 'Blue');

-- 5. Orders Table
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

INSERT INTO orders (customer_id, order_date) VALUES
(1, '2026-09-01'),
(1, '2026-09-05'),
(2, '2026-09-06');

-- 6. Order Items Table (Junction Table)
CREATE TABLE order_items (
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO order_items VALUES
(1, 1, 2, 25.00),
(1, 2, 1, 15.00),
(2, 2, 3, 15.00),
(3, 1, 1, 25.00);
```

---

## 2. SELF JOIN
A **Self Join** is a standard join in which a table is joined with **itself**. It is used to query hierarchical data stored within a single table (e.g., organizational charts, category trees, product recommendations).

### Key Concept
- Requires distinct **table aliases** (e.g., `e` for employee, `m` for manager) to differentiate the two roles of the same table in memory.

### Syntax & Example
Querying employees alongside their direct managers:

```sql
SELECT 
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    e.job_title AS employee_title,
    COALESCE(CONCAT(m.first_name, ' ', m.last_name), 'Top Executive') AS manager_name
FROM employees e
LEFT JOIN employees m 
    ON e.manager_id = m.employee_id;
```

**Output Explanation:**
- `e` acts as the primary record (subordinate).
- `m` acts as the referenced record (manager).
- Using `LEFT JOIN` ensures the CEO (`manager_id IS NULL`) is included in the output.

---

## 3. CROSS JOIN
A **Cross Join** produces a **Cartesian product** of two tables. Every row from the first table is paired with every row from the second table.

### Key Concept
- Resulting row count = `(Rows in Table A) × (Rows in Table B)`.
- Does **not** require an `ON` clause condition.
- **Use Cases:** Generating matrix combinations (e.g., T-Shirt sizes × colors), test data generation, scheduling matrices.

### Syntax & Example
Combining base products with all size/color variants to build an inventory SKU catalog:

```sql
SELECT 
    p.product_name,
    v.size_name,
    v.color_name,
    p.base_price
FROM products p
CROSS JOIN variants v
ORDER BY p.product_name, v.size_name;
```

---

## 4. Multi-Table Joins
In real-world applications, data spans across normalized relational tables. Multi-table joins chain multiple `JOIN` clauses sequentially.

### Key Concept
- Queries execute join logic step-by-step from left to right (or based on the MySQL optimizer's execution plan).
- Always ensure each joined table has an explicit `ON` key relationship.

### Syntax & Example (4-Table Join)
Retrieving customer names, order dates, purchased items, unit prices, and line item totals:

```sql
SELECT 
    c.full_name AS customer_name,
    o.order_id,
    o.order_date,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price) AS line_total
FROM customers c
INNER JOIN orders o 
    ON c.customer_id = o.customer_id
INNER JOIN order_items oi 
    ON o.order_id = oi.order_id
INNER JOIN products p 
    ON oi.product_id = p.product_id
ORDER BY o.order_id ASC;
```

---

## 5. Join Execution Flow & Query Analysis

### Logical Execution Order
When MySQL processes a query containing joins, it evaluates clauses in this specific sequence:

1. **`FROM` & `JOIN`**: Identify source tables and build intermediate virtual tables (working datasets).
2. **`ON`**: Apply join predicates to filter row combinations for each join step.
3. **`WHERE`**: Filter the resulting intermediate dataset.
4. **`GROUP BY`**: Aggregate rows (if applicable).
5. **`HAVING`**: Filter aggregated groups.
6. **`SELECT`**: Project requested columns and compute expressions.
7. **`ORDER BY`**: Sort final result set.
8. **`LIMIT`**: Restrict row output count.

### Query Analysis with `EXPLAIN`
To analyze how MySQL executes a join query and verify index usage:

```sql
EXPLAIN SELECT 
    c.full_name, o.order_date
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id;
```

**Key Column Indicators in `EXPLAIN` Output:**
- **`type`**: `ALL` means full table scan (slow); `eq_ref` or `ref` means efficient index search.
- **`possible_keys`**: Indexes MySQL could use for the join.
- **`key`**: The index MySQL actually selected.
- **`rows`**: Estimated rows inspected per table.

---

## 6. Common Join Mistakes & How to Avoid Them

| Common Mistake | Root Cause | Impact / Symptom | Solution |
| :--- | :--- | :--- | :--- |
| **Missing `ON` Clause** | Writing `FROM A, B` or omitting join conditions | Massive row inflation (accidental Cartesian product) | Always specify `JOIN ... ON key_a = key_b` |
| **Ambiguous Column Error** | Column exists in multiple joined tables (e.g., `id`) | `Error 1052: Column 'id' in field list is ambiguous` | Prefix every column with its table alias (`c.customer_id`) |
| **`WHERE` Nullifying `LEFT JOIN`** | Placing a filter on the right table in `WHERE` (e.g., `WHERE b.status = 'ACTIVE'`) | Converts `LEFT JOIN` into an implicit `INNER JOIN` | Move right-table filter into the `ON` clause or test `OR b.col IS NULL` |
| **Data Type Mismatch** | Joining `VARCHAR` key to `INT` key | Silent type conversion, disabling index usage | Ensure Primary Key and Foreign Key columns share identical data types |

---

## 7. Hands-on In-Class Practice Exercise

### Problem Statement
An e-commerce business analyst needs a report listing:
1. Every employee's name along with their manager's name.
2. The total revenue generated by each customer across all orders (using multi-table joins).

### Student Task
Write the SQL queries in MySQL Workbench for both requirements.

### Solution Key

#### Query 1: Employee Management Hierarchy
```sql
SELECT 
    e.first_name AS employee_first_name,
    e.last_name AS employee_last_name,
    e.job_title,
    COALESCE(m.first_name, 'N/A') AS manager_first_name,
    COALESCE(m.last_name, '') AS manager_last_name
FROM employees e
LEFT JOIN employees m 
    ON e.manager_id = m.employee_id;
```

#### Query 2: Customer Total Spend Summary
```sql
SELECT 
    c.customer_id,
    c.full_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0.00) AS total_spent
FROM customers c
LEFT JOIN orders o 
    ON c.customer_id = o.customer_id
LEFT JOIN order_items oi 
    ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.full_name
ORDER BY total_spent DESC;
```
