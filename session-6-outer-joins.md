# Session 6 Lecture & Quick Reference Guide: Outer Joins

---

## 1. Introduction to Outer Joins

In relational databases, **INNER JOIN** only returns rows where matching keys exist in **both** tables. However, real-world business requirements often demand that we retain records even when there is no matching record in the related table.

**Outer Joins** allow us to preserve non-matching rows from one or both tables by filling missing attributes from the non-matching side with `NULL`.

### Why Outer Joins Matter:
- **Identifying Inactive Records:** Finding customers who haven't placed any orders, or products that have never been sold.
- **Complete Business Reporting:** Showing all departments alongside their assigned employees, including newly created departments with zero staff.
- **Data Audit & Quality Checks:** Detecting orphaned records or missing relationships across systems.

---

## 2. LEFT JOIN (LEFT OUTER JOIN)

### Concept & Mechanics
A **LEFT JOIN** returns **all records from the left table**, and the matching records from the right table. If no match is found in the right table, MySQL returns `NULL` for all columns of the right table.

```
Left Table (Preserved)  ───────▶  [ All Rows Returned ]
                                        ▲
                                        │ (Matching rows merged; NULLs for non-matches)
Right Table             ───────▶  [ Matched Rows Only ]
```

### Basic Syntax
```sql
SELECT 
    t1.column_name, 
    t2.column_name
FROM table1 t1
LEFT JOIN table2 t2
    ON t1.primary_key = t2.foreign_key;
```

### Finding Unmatched Rows ("Anti-Join" Pattern)
To filter exclusively for rows in the left table that have **no match** in the right table, add a `WHERE` condition checking for `NULL` in the right table's primary key:

```sql
SELECT 
    c.customer_id, 
    c.customer_name
FROM customers c
LEFT JOIN orders o 
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;
```

---

## 3. RIGHT JOIN (RIGHT OUTER JOIN)

### Concept & Mechanics
A **RIGHT JOIN** returns **all records from the right table**, and the matching records from the left table. If there is no match in the left table, MySQL returns `NULL` for all columns of the left table.

```sql
SELECT 
    c.customer_name, 
    o.order_id, 
    o.order_amount
FROM customers c
RIGHT JOIN orders o
    ON c.customer_id = o.customer_id;
```

### Industry Standard Note
Any `RIGHT JOIN` can be rewritten as a `LEFT JOIN` simply by swapping the order of the tables in the `FROM` clause:
- `TableA RIGHT JOIN TableB` is logically identical to `TableB LEFT JOIN TableA`.
- **Best Practice:** Prefer `LEFT JOIN` in professional codebases. Reading queries from left-to-right (top-to-bottom) makes SQL scripts cleaner and easier to maintain.

---

## 4. FULL OUTER JOIN Concept & MySQL Emulation

### What is a FULL OUTER JOIN?
A **FULL OUTER JOIN** returns all records when there is a match in either the left or right table. It combines the result sets of both `LEFT JOIN` and `RIGHT JOIN`.

### The MySQL Limitation
> ⚠️ **Note:** MySQL does **NOT** natively support the `FULL OUTER JOIN` keyword syntax (`FULL JOIN`).

### Emulating FULL OUTER JOIN in MySQL using `UNION`
To achieve a Full Outer Join in MySQL, combine a `LEFT JOIN` and a `RIGHT JOIN` using the `UNION` operator (which automatically removes duplicate rows):

```sql
-- Emulating FULL OUTER JOIN in MySQL
SELECT 
    c.customer_id, 
    c.customer_name, 
    o.order_id, 
    o.order_amount
FROM customers c
LEFT JOIN orders o 
    ON c.customer_id = o.customer_id

UNION

SELECT 
    c.customer_id, 
    c.customer_name, 
    o.order_id, 
    o.order_amount
FROM customers c
RIGHT JOIN orders o 
    ON c.customer_id = o.customer_id;
```

---

## 5. Summary Matrix of Join Types

| Join Type | Preserves Left Rows? | Preserves Right Rows? | Unmatched Values Filled With | Typical Use Case |
| :--- | :---: | :---: | :---: | :--- |
| **INNER JOIN** | ❌ No | ❌ No | N/A (Excluded) | Match exact relationships |
| **LEFT JOIN** | ✅ Yes | ❌ No | `NULL` on Right | All primary entities + optional details |
| **RIGHT JOIN** | ❌ No | ✅ Yes | `NULL` on Left | All secondary entities + optional details |
| **FULL JOIN (UNION)** | ✅ Yes | ✅ Yes | `NULL` on Both | Comprehensive data reconciliation |

---

## 6. Complete Practical MySQL Workbench Script

```sql
-- =====================================================
-- SESSION 6: OUTER JOINS PRACTICE SCHEMA
-- =====================================================

CREATE DATABASE IF NOT EXISTS outer_joins_demo;
USE outer_joins_demo;

-- Drop existing tables
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;

-- Create Customers Table
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL
);

-- Create Orders Table
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATE NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Insert Sample Customers (Some with orders, some without)
INSERT INTO customers (customer_name, city) VALUES
('Alice Smith', 'New York'),      -- Customer ID 1
('Bob Jones', 'Chicago'),        -- Customer ID 2
('Charlie Brown', 'Houston'),    -- Customer ID 3
('Diana Prince', 'Seattle');      -- Customer ID 4 (No orders placed)

-- Insert Sample Orders (Including one orphan order with NULL customer_id)
INSERT INTO orders (customer_id, order_date, total_amount) VALUES
(1, '2026-09-01', 250.00),
(1, '2026-09-05', 120.50),
(2, '2026-09-10', 450.00),
(NULL, '2026-09-12', 99.00);    -- Order without assigned customer

-- -----------------------------------------------------
-- 1. LEFT JOIN: All Customers and their Orders
-- -----------------------------------------------------
SELECT 
    c.customer_id,
    c.customer_name,
    c.city,
    o.order_id,
    o.order_date,
    o.total_amount
FROM customers c
LEFT JOIN orders o 
    ON c.customer_id = o.customer_id
ORDER BY c.customer_id;

-- -----------------------------------------------------
-- 2. ANTI-JOIN: Customers Who Have NEVER Placed an Order
-- -----------------------------------------------------
SELECT 
    c.customer_id,
    c.customer_name,
    c.city
FROM customers c
LEFT JOIN orders o 
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- -----------------------------------------------------
-- 3. RIGHT JOIN: All Orders and their Customers
-- -----------------------------------------------------
SELECT 
    c.customer_name,
    o.order_id,
    o.order_date,
    o.total_amount
FROM customers c
RIGHT JOIN orders o 
    ON c.customer_id = o.customer_id;

-- -----------------------------------------------------
-- 4. FULL OUTER JOIN Simulation in MySQL
-- -----------------------------------------------------
SELECT 
    c.customer_id,
    c.customer_name,
    o.order_id,
    o.total_amount
FROM customers c
LEFT JOIN orders o 
    ON c.customer_id = o.customer_id

UNION

SELECT 
    c.customer_id,
    c.customer_name,
    o.order_id,
    o.total_amount
FROM customers c
RIGHT JOIN orders o 
    ON c.customer_id = o.customer_id;
```

---

## 7. Quick In-Class Discussion Questions

1. **Question:** What happens if you run a `WHERE` clause like `WHERE o.total_amount > 200` on a `LEFT JOIN` query?
   - **Answer:** It converts the `LEFT JOIN` into an `INNER JOIN` because rows with `NULL` in `total_amount` (unmatched customers) will be filtered out by `> 200`. To preserve unmatched rows while filtering matched rows, put the condition in the `ON` clause: `ON c.customer_id = o.customer_id AND o.total_amount > 200`.
2. **Question:** Why does MySQL use `UNION` instead of `UNION ALL` when emulating `FULL OUTER JOIN`?
   - **Answer:** `UNION` automatically eliminates duplicate rows produced by both the `LEFT JOIN` and `RIGHT JOIN` result sets for matching records.
