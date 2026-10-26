# Session Guide: Aggregate Queries, Financial Reporting & Practice Dataset

This comprehensive reference and lecture guide covers **Aggregate SQL Queries**, **Sales Analysis**, **Revenue Reporting**, **Customer Analytics**, and a **Complete Practice Dataset** with schema DDL, sample data, and hands-on queries.

---

## 1. Sales Analysis Queries

Sales analysis involves transforming raw transactional records into actionable business metrics such as total volume, average basket size, and product performance.

### A. Core Sales Metrics
* **Total Sales Volume:** `COUNT(order_id)`
* **Gross Revenue:** `SUM(quantity * unit_price)`
* **Average Order Value (AOV):** `SUM(total_amount) / COUNT(DISTINCT order_id)`
* **Units Sold Per Category:** `SUM(quantity)` grouped by product category.

### B. Product Category Sales Breakdown
```sql
SELECT 
    p.category,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.quantity * oi.unit_price) AS category_revenue,
    ROUND(AVG(oi.unit_price), 2) AS avg_item_price
FROM Products p
JOIN Order_Items oi ON p.product_id = oi.product_id
JOIN Orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'COMPLETED'
GROUP BY p.category
ORDER BY category_revenue DESC;
```

---

## 2. Revenue Reports

Financial revenue reports synthesize order history across chronological dimensions (daily, monthly, quarterly, yearly) and payment methods.

### A. Monthly Revenue & Growth Query
```sql
SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_amount) AS gross_revenue,
    ROUND(AVG(o.total_amount), 2) AS avg_order_value,
    MIN(o.total_amount) AS min_order_value,
    MAX(o.total_amount) AS max_order_value
FROM Orders o
WHERE o.order_status = 'COMPLETED'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY sales_month ASC;
```

### B. Revenue by Payment Method & Region
```sql
SELECT 
    c.region,
    o.payment_method,
    COUNT(o.order_id) AS transaction_count,
    SUM(o.total_amount) AS total_revenue
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'COMPLETED'
GROUP BY c.region, o.payment_method
ORDER BY c.region ASC, total_revenue DESC;
```

---

## 3. Customer Reports & RFM Analysis

Customer analytics identify high-value accounts, purchasing frequency, and regional distribution.

### A. Customer Lifetime Value (CLV) & VIP Segmentation
```sql
SELECT 
    c.customer_id,
    c.customer_name,
    c.city,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_amount) AS lifetime_value,
    MAX(o.order_date) AS last_order_date
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'COMPLETED'
GROUP BY c.customer_id, c.customer_name, c.city
HAVING COUNT(o.order_id) >= 2 AND SUM(o.total_amount) >= 1000.00
ORDER BY lifetime_value DESC;
```

### B. Customer Recency & Inactive Account Detection
```sql
SELECT 
    c.customer_id,
    c.customer_name,
    c.email,
    MAX(o.order_date) AS last_order_date,
    DATEDIFF(CURRENT_DATE, MAX(o.order_date)) AS days_since_last_order
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name, c.email
HAVING MAX(o.order_date) IS NULL OR DATEDIFF(CURRENT_DATE, MAX(o.order_date)) > 90
ORDER BY days_since_last_order DESC;
```

---

## 4. Practice Dataset & Hands-On Exercises

To run these reports locally, use the following MySQL DDL and DML scripts.

### A. Database Schema DDL
```sql
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    city VARCHAR(50) NOT NULL,
    region VARCHAR(50) NOT NULL
);

CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price DECIMAL(10,2) NOT NULL
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(30) NOT NULL,
    order_status VARCHAR(20) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

CREATE TABLE Order_Items (
    item_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);
```

### B. Sample Data DML Inserts
```sql
INSERT INTO Customers VALUES 
(1, 'Alice Smith', 'alice@example.com', 'New York', 'East'),
(2, 'Bob Jones', 'bob@example.com', 'Chicago', 'Midwest'),
(3, 'Charlie Brown', 'charlie@example.com', 'Los Angeles', 'West'),
(4, 'Diana Prince', 'diana@example.com', 'Houston', 'South');

INSERT INTO Products VALUES 
(101, 'Laptop Pro 15', 'Electronics', 1200.00),
(102, 'Wireless Mouse', 'Electronics', 25.00),
(103, 'Ergonomic Chair', 'Furniture', 350.00),
(104, 'Coffee Maker', 'Appliances', 80.00);

INSERT INTO Orders VALUES 
(1001, 1, '2026-01-15', 1225.00, 'Credit Card', 'COMPLETED'),
(1002, 2, '2026-01-20', 350.00, 'PayPal', 'COMPLETED'),
(1003, 1, '2026-02-10', 80.00, 'Credit Card', 'COMPLETED'),
(1004, 3, '2026-02-14', 1200.00, 'Debit Card', 'COMPLETED'),
(1005, 4, '2026-03-01', 25.00, 'Credit Card', 'CANCELLED');

INSERT INTO Order_Items VALUES 
(1, 1001, 101, 1, 1200.00),
(2, 1001, 102, 1, 25.00),
(3, 1002, 103, 1, 350.00),
(4, 1003, 104, 1, 80.00),
(5, 1004, 101, 1, 1200.00);
```

### C. Practice Challenge Exercises
1. **Exercise 1:** Write a query to find the top revenue-generating region.
2. **Exercise 2:** Find all products that have never been purchased.
3. **Exercise 3:** Compute the total revenue for each payment method across completed orders only.

---

## 5. Summary Matrix: Reporting Query Patterns

| Report Type | Primary Table | Key Grouping Columns | Essential Aggregate Functions | Key Filter / Having Conditions |
| :--- | :--- | :--- | :--- | :--- |
| **Category Sales** | `Products` | `p.category` | `SUM(quantity)`, `SUM(revenue)` | `o.order_status = 'COMPLETED'` |
| **Monthly Revenue** | `Orders` | `DATE_FORMAT(order_date, '%Y-%m')` | `SUM(total_amount)`, `AVG(total_amount)` | Chronological ordering |
| **Customer CLV** | `Customers` | `c.customer_id`, `c.customer_name` | `COUNT(order_id)`, `SUM(total_amount)` | `HAVING SUM(total_amount) >= 1000` |
