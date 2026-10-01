# Database Design Fundamentals: Study Notes

---

## 1. Introduction to Database Design

**Database Design** is the process of producing a detailed data model of a database. A well-designed database ensures data integrity, minimizes storage inefficiency, supports rapid querying, and easily scales as application requirements evolve.

### The Two Phases of Database Design
1. **Logical Database Design:** Focuses on identifying entities, attributes, and relationships independent of any specific Database Management System (DBMS).
2. **Physical Database Design:** Translates the logical model into concrete DDL statements (tables, data types, indexes, and engine choices) optimized for a target DBMS like MySQL.

---

## 2. Core Database Design Principles

To ensure data remains accurate, reachable, and structured, database designers rely on four fundamental integrity principles:

```
+-----------------------------------------------------------------------+
|                       DATABASE INTEGRITY PILLARS                      |
+-------------------+-------------------+-------------------------------+
|  Entity           |  Referential      |  Domain                       |
|  Integrity        |  Integrity        |  Integrity                    |
| (Primary Keys)    | (Foreign Keys)    | (Data Types & Constraints)    |
+-------------------+-------------------+-------------------------------+
```

### A. Entity Integrity
- **Rule:** Every table must have a **Primary Key (`PRIMARY KEY`)**, and its column values must be unique and non-null.
- **Purpose:** Guarantees that every row in a table represents a uniquely identifiable real-world entity.
- **Implementation:**
  ```sql
  CREATE TABLE users (
      user_id INT AUTO_INCREMENT PRIMARY KEY,
      email VARCHAR(100) NOT NULL UNIQUE
  );
  ```

### B. Referential Integrity
- **Rule:** A Foreign Key (`FOREIGN KEY`) in a child table must either match a valid Primary Key in the parent table or be `NULL`.
- **Purpose:** Prevents "orphan records" (e.g., an order referencing a customer ID that does not exist).
- **Enforcement Rules (`ON DELETE` / `ON UPDATE`):**
  - `CASCADE`: Deleting/updating the parent automatically deletes/updates matching child records.
  - `RESTRICT` / `NO ACTION`: Rejects the delete/update operation on the parent if child records exist.
  - `SET NULL`: Sets the foreign key column in child records to `NULL` when the parent is deleted.

### C. Domain Integrity
- **Rule:** All values in a column must conform to the defined data type, length, format, and allowable values.
- **Implementation:** Managed through explicit SQL data types (`INT`, `VARCHAR`, `DECIMAL`, `DATE`), `NOT NULL` directives, and `DEFAULT` values.

### D. User-Defined Integrity (Business Rules)
- **Rule:** Custom business logic enforced at the schema level rather than relying solely on application code.
- **Example:** Ensuring product price is always positive (`CHECK (price > 0)`).

---

## 3. Data Redundancy

**Data Redundancy** occurs when the same piece of data is stored redundantly in multiple places within a database.

```
UNCONTROLLED REDUNDANCY (Bad)
+----------+---------------+-------------------+-------------------+
| order_id | customer_name | customer_address  | customer_address  |
+----------+---------------+-------------------+-------------------+
| 101      | Alice Smith   | 123 Maple Street  | 123 Maple Street  |  <-- Duplicate Data!
| 102      | Alice Smith   | 123 Maple Street  | 123 Maple Street  |  <-- Duplicate Data!
+----------+---------------+-------------------+-------------------+
```

### Anomalies Caused by Uncontrolled Redundancy

1. **Insertion Anomaly:** Unable to record information about a new entity without creating dummy data for an unrelated entity (e.g., unable to add a new customer until they place an order).
2. **Update Anomaly:** Updating a value in one location leaves inconsistent duplicate copies elsewhere if not updated everywhere simultaneously (e.g., updating a customer address in one order row but missing another).
3. **Deletion Anomaly:** Deleting a record unintentionally destroys critical secondary information (e.g., deleting a customer's only order accidentally deletes the customer's account history).

### Controlled Redundancy (Denormalization)
While normalization eliminates redundancy to protect data integrity, controlled redundancy (**denormalization**) is intentionally used in high-volume, read-heavy reporting databases to reduce expensive `JOIN` operations.

| Metric | Normalized Database (OLTP) | Denormalized Database (OLAP) |
| :--- | :--- | :--- |
| **Primary Goal** | Data Integrity & Fast Writes | Fast Read Queries & Analytics |
| **Data Redundancy** | Zero / Minimal | High (Controlled) |
| **Query Complexity** | Requires Multiple `JOIN`s | Simplified Single-Table Queries |
| **Update Overhead** | Low (Update in 1 place) | High (Update in multiple places) |

---

## 4. Data Consistency

**Data Consistency** ensures that the database transitions from one valid state to another, strictly adhering to all defined rules, constraints, and invariants.

```
       [Valid State A]  ---( Transaction )--->  [Valid State B]
              |                                        |
              +----> All Constraints Validated <-------+
```

### The ACID Model & Consistency
In relational database management systems, consistency is a core pillar of **ACID**:

- **Atomicity:** All operations within a transaction complete successfully, or all changes are completely rolled back.
- **Consistency:** Ensures the database never violates schema rules (foreign keys, unique keys, check constraints) before or after a transaction.
- **Isolation:** Prevents concurrent transactions from seeing partial, uncommitted state updates from each other.
- **Durability:** Committed data is permanently saved even in the event of a system crash.

### Maintaining Consistency in Production
1. **Use Foreign Keys with Cascade Guards:** Explicitly define foreign keys so parent-child dependencies are maintained automatically by MySQL.
2. **Use Transactions for Multi-Step Operations:** Wrap multi-query workflows (e.g., deducting inventory and creating an invoice) inside `START TRANSACTION; ... COMMIT;`.
3. **Prefer Soft Deletes over Hard Deletes:** Instead of executing `DELETE FROM users WHERE id = 5`, set `is_active = FALSE` or `deleted_at = NOW()`. This preserves foreign key historical audit trails.

---

## 5. Schema Planning & Design Workflow

A structured schema planning workflow prevents expensive database refactoring down the line.

```
+---------------------+     +---------------------+     +---------------------+
| 1. Requirement      | --> | 2. Conceptual       | --> | 3. Logical          |
|    Gathering        |     |    Design (ERD)     |     |    Schema Mapping   |
+---------------------+     +---------------------+     +---------------------+
                                                                   |
                                                                   v
                                                        +---------------------+
                                                        | 4. Physical DDL     |
                                                        |    Implementation   |
                                                        +---------------------+
```

### Step-by-Step Schema Planning Checklist

1. **Identify Core Entities:** List real-world objects involved in the system (e.g., `Customers`, `Products`, `Orders`).
2. **Define Primary & Foreign Keys:** Ensure each entity has a unique identifier and establish explicit linkages between tables.
3. **Select Precise Data Types:**
   - Use `INT` / `BIGINT` for surrogate keys.
   - Use `DECIMAL(M, D)` for currency values (never use `FLOAT` or `DOUBLE` due to rounding errors).
   - Use `VARCHAR` for variable-length strings and `CHAR` for fixed-length codes.
   - Use `DATETIME` or `TIMESTAMP` for chronological records.
4. **Define Mandatory Constraints:** Apply `NOT NULL` to mandatory fields, `UNIQUE` to candidate keys (e.g., emails), and `DEFAULT` for fallback values.

---

## 6. Complete Practical Schema Example (E-Commerce System)

Below is a complete, production-ready MySQL Workbench DDL script demonstrating proper database design principles, foreign key relationships, and data consistency controls:

```sql
-- 1. Create Database
CREATE DATABASE IF NOT EXISTS ecommerce_store;
USE ecommerce_store;

-- 2. Users Table (Entity Integrity & Unique Constraints)
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB;

-- 3. Categories Table
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- 4. Products Table (Domain Constraints & Foreign Keys)
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0.00),
    stock_quantity INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    CONSTRAINT fk_products_category
        FOREIGN KEY (category_id) 
        REFERENCES categories(category_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 5. Orders Table (Referential Integrity with Users)
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    status ENUM('Pending', 'Shipped', 'Delivered', 'Cancelled') DEFAULT 'Pending',
    CONSTRAINT fk_orders_user
        FOREIGN KEY (user_id) 
        REFERENCES users(user_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 6. Order_Items Junction Table (Composite Integrity)
CREATE TABLE order_items (
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (order_id, product_id),
    CONSTRAINT fk_items_order
        FOREIGN KEY (order_id) 
        REFERENCES orders(order_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_items_product
        FOREIGN KEY (product_id) 
        REFERENCES products(product_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;
```

---

## 7. Common Schema Planning Mistakes to Avoid

1. **Using Bad Data Types for Currency:** Storing monetary amounts as `FLOAT` or `DOUBLE` leads to floating-point rounding errors. Always use `DECIMAL`.
2. **Missing Foreign Key Indexes:** Failing to create indexes on Foreign Key columns can slow down `JOIN` queries significantly.
3. **Storing Delimited Lists in a Single Column:** Storing `1,2,5` inside a `VARCHAR` column violates First Normal Form (1NF) and breaks indexing and referential integrity.
4. **Omitting `NOT NULL` Directives:** Allowing `NULL` values in non-optional columns creates ambiguity in application logic and conditional queries.
