# Session Guide: Introduction to SQL Joins & INNER JOIN

---

## Part 1: Introduction to Joins

### 1. The Need for Joins
In relational database management systems (RDBMS), data is normalized into separate, focused tables rather than stored in one massive flat file. 

* **Eliminating Data Redundancy:** Storing customer names and addresses next to every single order item leads to massive duplication and potential anomalies (update, insertion, deletion anomalies).
* **Data Integrity:** Separate entities (e.g., `customers`, `orders`, `products`) maintain their own life cycle.
* **Recombining Normalized Data:** **JOINs** are the mechanism used in SQL to stitch these normalized tables back together during query execution to produce meaningful business reports.

---

### 2. Primary Key (PK) & Foreign Key (FK) Review

Relational joins rely on logical linkages between tables established by Primary and Foreign keys:

* **Primary Key (PK):** A column (or set of columns) that uniquely identifies each row in a table. Must be `UNIQUE` and `NOT NULL` (e.g., `customer_id` in `customers`).
* **Foreign Key (FK):** A column in a child table that points to the Primary Key of a parent table (e.g., `customer_id` in `orders`).
* **Referential Integrity:** Ensures that an `orders` record cannot reference a `customer_id` that does not exist in the `customers` table.

```
+------------------+         1 : N         +------------------+
|    customers     | --------------------> |      orders      |
+------------------+                       +------------------+
| customer_id (PK) |                       | order_id    (PK) |
| name             |                       | customer_id (FK) |
| email            |                       | order_date       |
+------------------+                       | amount           |
                                           +------------------+
```

---

### 3. Overview of Join Types

| Join Type | Description | Result Set Behavior |
| :--- | :--- | :--- |
| **`INNER JOIN`** | Returns rows when there is a match in **both** tables. | Unmatched rows from either table are excluded. |
| **`LEFT JOIN`** (Outer) | Returns **all** rows from the left table, and matched rows from the right table. | Missing matches on the right result in `NULL` values. |
| **`RIGHT JOIN`** (Outer) | Returns **all** rows from the right table, and matched rows from the left table. | Missing matches on the left result in `NULL` values. |
| **`CROSS JOIN`** | Produces a Cartesian product of both tables. | Returns every combination ($M \times N$ rows). |

---

### 4. Real-World Industry Examples

1. **E-Commerce:** Linking `customers` to `orders` to generate invoice receipts and customer purchase histories.
2. **Banking:** Connecting `account_holders` with `transactions` to compute ledger statements.
3. **Healthcare:** Linking `patients` with `appointments` and `doctors` to schedule medical visits.

---

## Environment Setup Script (MySQL Workbench)

Run this SQL script in MySQL Workbench to set up the dataset for live class demonstrations:

```sql
-- Create and switch database
CREATE DATABASE IF NOT EXISTS retail_db;
USE retail_db;

-- Drop existing tables if re-running
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;

-- 1. Create Customers Table (Parent Table)
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    city VARCHAR(50) NOT NULL
);

-- 2. Create Orders Table (Child Table with FK)
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATE NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'Pending',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);

-- Insert Sample Customers
INSERT INTO customers (first_name, last_name, email, city) VALUES
('Alice', 'Smith', 'alice@example.com', 'New York'),
('Bob', 'Jones', 'bob@example.com', 'Los Angeles'),
('Charlie', 'Brown', 'charlie@example.com', 'Chicago'),
('Diana', 'Prince', 'diana@example.com', 'Miami'),
('Evan', 'Wright', 'evan@example.com', 'Seattle'); -- Note: Evan has no orders

-- Insert Sample Orders
INSERT INTO orders (customer_id, order_date, total_amount, status) VALUES
(1, '2026-08-01', 150.00, 'Completed'),
(1, '2026-08-10', 200.50, 'Completed'),
(2, '2026-08-12', 85.25, 'Pending'),
(3, '2026-08-15', 430.00, 'Completed'),
(NULL, '2026-08-18', 99.99, 'Processing'); -- Guest order with no linked customer_id
```

---

## Part 2: Inner Join Deep Dive

### 1. INNER JOIN Syntax & Mechanics

The `INNER JOIN` evaluates each row of Table A against Table B based on the join predicate specified in the `ON` clause. Only matching pairs are included in the output.

```sql
SELECT 
    tableA.column1, 
    tableB.column2
FROM tableA
INNER JOIN tableB 
    ON tableA.common_field = tableB.common_field;
```

* **Table Aliases:** Using aliases (e.g., `FROM customers c INNER JOIN orders o`) improves readability and prevents column name ambiguity.
* **Column Ambiguity:** When columns exist in both tables (like `customer_id`), prefixing them with the table name or alias is mandatory (`c.customer_id`).

---

### 2. Two-Table Join Practical Walkthrough

#### Query: Fetch Customer Names along with their Order Details
```sql
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.city,
    o.order_id,
    o.order_date,
    o.total_amount,
    o.status
FROM customers c
INNER JOIN orders o 
    ON c.customer_id = o.customer_id;
```

#### Key Observation for Students:
* **Evan Wright (customer_id = 5)** does **NOT** appear in the output because he has 0 orders.
* **Order #5 (customer_id = NULL)** does **NOT** appear because `NULL = NULL` evaluates to `UNKNOWN`/`FALSE` in SQL join predicates.
* **Alice Smith (customer_id = 1)** appears **twice** because she placed two separate orders.

---

### 3. Filtering with Multiple Conditions

You can filter joined datasets in two ways: by adding conditions inside the `ON` clause or by combining `INNER JOIN` with a `WHERE` clause.

#### Pattern A: Filtering in the `WHERE` Clause
Use the `WHERE` clause to filter rows *after* the tables have been linked based on business logic.

```sql
-- Find Completed orders placed by customers living in 'New York'
SELECT 
    c.first_name,
    c.last_name,
    c.city,
    o.order_id,
    o.total_amount,
    o.status
FROM customers c
INNER JOIN orders o 
    ON c.customer_id = o.customer_id
WHERE c.city = 'New York' 
  AND o.status = 'Completed';
```

#### Pattern B: Multiple Join Conditions in the `ON` Clause
You can combine multiple criteria directly within the `ON` clause using logical operators (`AND`).

```sql
-- Link orders only where customer_id matches AND total_amount is greater than $100
SELECT 
    c.first_name,
    c.last_name,
    o.order_id,
    o.total_amount
FROM customers c
INNER JOIN orders o 
    ON c.customer_id = o.customer_id 
   AND o.total_amount > 100.00;
```

---

## Part 3: In-Class Query Practice & Hands-On Exercises

### Exercise 1: Customer Order Summary
**Task:** Write a query to display the customer's full name, email, order ID, and order amount for all pending orders. Order the results by `total_amount` in descending order.

```sql
-- Solution:
SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    c.email,
    o.order_id,
    o.total_amount
FROM customers c
INNER JOIN orders o 
    ON c.customer_id = o.customer_id
WHERE o.status = 'Pending'
ORDER BY o.total_amount DESC;
```

---

### Exercise 2: Date-Restricted Sales Query
**Task:** Fetch all completed orders made between `2026-08-01` and `2026-08-11`. Display the customer ID, full name, order date, and total amount.

```sql
-- Solution:
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    o.order_date,
    o.total_amount
FROM customers c
INNER JOIN orders o 
    ON c.customer_id = o.customer_id
WHERE o.status = 'Completed'
  AND o.order_date BETWEEN '2026-08-01' AND '2026-08-11';
```

---

### Exercise 3: Advanced High-Value Customer Target
**Task:** Retrieve distinct customer names and cities for customers who have placed an individual order exceeding $200.00.

```sql
-- Solution:
SELECT DISTINCT 
    c.first_name,
    c.last_name,
    c.city
FROM customers c
INNER JOIN orders o 
    ON c.customer_id = o.customer_id
WHERE o.total_amount > 200.00;
```

---

### Quick Review Checklist for Instructors
* [ ] Did students understand why Evan (no orders) was dropped in `INNER JOIN`?
* [ ] Can students explain why `c.customer_id` needs table alias prefixing?
* [ ] Are students clear on the difference between joining on Foreign Keys vs. filtering in `WHERE` clauses?
