# Assignment: E-Commerce CRUD Operations & Advanced Querying in MySQL

**Course:** Relational Database Management Systems (RDBMS)  
**Topic:** CRUD Lifecycle, Table Constraints, Filtering, and Built-In Functions  
**Database Tool:** MySQL Workbench  

---

## 🎯 Assignment Overview
In this practical assignment, you will step into the shoes of a Database Engineer at a rapidly growing e-commerce company, **"ElectroShop."** Your objective is to design a robust database schema to track products, execute critical Create, Read, Update, and Delete (CRUD) workflows, and use MySQL's built-in filtering and data transformation functions to generate reports for the inventory and management teams.

---

## 🛠️ Phase 1: Database Design & Schema Creation (DDL)
In this phase, you will write the Data Definition Language (DDL) to establish the database structure, implementing standard integrity constraints to protect your data.

### Task 1.1: Schema Design with Constraints
Create a table named `products` that enforces the following requirements:
1. **`id`**: An integer that uniquely identifies each product, auto-increments automatically, and serves as the primary key.
2. **`product_name`**: A variable character string up to 100 characters that cannot be empty.
3. **`sku`**: A string representing the unique stock-keeping unit, up to 50 characters, which must be unique across all products.
4. **`category`**: A variable character string up to 50 characters, representing the product family.
5. **`price`**: A decimal value (up to 10 digits total, with 2 decimal places) that cannot be null.
6. **`stock_quantity`**: An integer representing the quantity in warehouse stock, defaulting to `0` if not specified.
7. **`date_added`**: A date column recording when the product was introduced, defaulting to the current system date.

```sql
-- Write your CREATE TABLE statement here.
-- Ensure you incorporate: PRIMARY KEY, AUTO_INCREMENT, NOT NULL, UNIQUE, and DEFAULT.
```

---

## 📝 Phase 2: CRUD Operations Flow (DML)
With the structure created, you will practice managing data through its full lifecycle.

### Task 2.1: Data Ingestion (Create)
Write a single SQL statement to insert the following five products into your `products` table. Use the explicit list of target columns in your `INSERT` statement to let constraints handle the auto-increment and default values.

| Name | SKU | Category | Price | Stock | Date Added |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Neo-Pro Laptop | LTOP-NEO-01 | Electronics | 1299.99 | 15 | 2026-01-15 |
| AeroBuds Wireless | AU-AERO-55 | Audio | 89.95 | 120 | 2026-05-20 |
| SoundWave Soundbar | AU-SNDW-09 | Audio | 199.99 | 45 | 2026-07-10 |
| SmartSync Watch | WEAR-SYNC-02 | Wearables | 249.50 | 0 | 2026-08-01 |
| MaxCharge Powerbank | ACC-MAX-12 | Electronics | 39.99 | 250 | 2026-09-01 |

```sql
-- Write your INSERT INTO statement here.
```

### Task 2.2: Price Adjustment (Update)
Due to rising shipping costs, ElectroShop must implement a **5% price increase** on all items under the `'Electronics'` category. Write the query to update the pricing records accordingly.

```sql
-- Write your UPDATE statement here.
```

### Task 2.3: Inventory Purge (Delete)
Management wants to clear the database catalog of old, discontinued items. Write a statement to delete any product where the warehouse stock is currently `0`.

```sql
-- Write your DELETE statement here.
```

---

## 🔍 Phase 3: Query Filtering & Built-In Functions (DQL)
Your manager has requested specific operational data. Use the filtering operators and built-in functions you studied in Sessions 1 and 2 to solve these queries.

### Task 3.1: Inventory & Category Filters (Comparison, IN, & BETWEEN)
Write queries to solve the following business requests:
1. Retrieve all columns for products where the `price` is **between $50.00 and $300.00** (inclusive). Use the `BETWEEN` operator.
2. Retrieve all products that belong to either the `'Audio'` or `'Wearables'` categories. Use the `IN` operator.
3. Retrieve all products with a stock quantity greater than or equal to `50` units, ordered by `stock_quantity` in descending order.

```sql
-- Query 1: Between pricing filter
-- Query 2: Category membership filter
-- Query 3: Stock threshold filter with sorting
```

### Task 3.2: Pattern Matching & Search (LIKE & Wildcards)
1. Write a query to find all products where the `product_name` starts with the letters **'Aero'** (case-insensitive search).
2. Write a query to retrieve products where the `sku` contains the exact pattern **'-MAX-'** in any position.
3. Write a query to find product listings where the `sku` has exactly **two characters** followed by a hyphen (e.g., matching a pattern like `'AU-SNDW-09'`). Use the single-character wildcard (`_`).

```sql
-- Query 1: Starts with 'Aero'
-- Query 2: Contains substring '-MAX-'
-- Query 3: Match precise positional SKU patterns
```

### Task 3.3: Data Transformation (String & Numeric Functions)
1. Use **`CONCAT()`** and **`UPPER()`** to return a formatted column called `Catalog_Display` showing the product name and SKU in the format: `"[UPPERCASE NAME] - (SKU)"`.
2. Generate a discount pricing sheet. Return the `product_name`, the original `price`, and a `Discounted_Price` column which represents **15% off the original price**. Use **`ROUND()`** to limit the discounted prices to exactly **1 decimal place**.
3. Use the **`MOD()`** function to find products that have an **odd** stock quantity. (Hint: Dividing an odd number by 2 leaves a remainder of 1).

```sql
-- Query 1: String concatenation & casing report
-- Query 2: Discount calculations rounded to 1 decimal place
-- Query 3: Modulo operation to identify odd-numbered stocks
```

### Task 3.4: Time-Travel Analysis (Date & Time Functions)
1. Write a query to return the current date in the default system format, alongside a column showing the exact date **6 months and 2 weeks in the future**. Use the **`ADDDATE()`** function.
2. Calculate the "listing age" of your inventory. Return the `product_name`, `date_added`, and a calculated column named `Days_Active` that counts how many days have passed between `date_added` and the current date. Use **`DATEDIFF()`** and **`CURDATE()`**.
3. Write a query that extracts only the **Year** and the **Month** as separate columns from the `date_added` column for all products.

```sql
-- Query 1: ADDDATE future projection
-- Query 2: DATEDIFF age tracker
-- Query 3: Extraction of YEAR and MONTH components
```

---

## 🏢 Phase 4: Industry Discussion & Analytical Thinking
*Please write a short-answer response (2-4 sentences per question) explaining the database engineering concepts behind these real-world scenarios.*

### Scenario A: Search Performance Bottlenecks
A developer on your team writes the following two search queries for a global catalog table containing millions of rows:
*   **Query A:** `SELECT * FROM global_catalog WHERE item_sku LIKE 'PROD-99%';`
*   **Query B:** `SELECT * FROM global_catalog WHERE item_sku LIKE '%PROD-99';`

**Question:** From a database performance standpoint, explain why one of these queries executes instantly, while the other might take several seconds and stall the database server. Refer to indexes and search mechanics in your answer.

### Scenario B: Hard Deletes vs. Soft Deletes
In high-volume e-commerce databases, executing a literal `DELETE FROM table_name WHERE id = X;` (a "hard delete") is often discouraged for key transactional tables like `customers`, `products`, or `orders`.

**Question:** What are the risks of hard-deleting records in production, and how do database engineers implement a "soft delete" strategy to retain analytical integrity while hiding records from end users?
