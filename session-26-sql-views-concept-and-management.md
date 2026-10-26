# Session 26 Study Guide: Views in SQL

This reference guide covers the fundamental concepts, creation syntax, update mechanics, and real-world enterprise applications of **SQL Views** (`VIEW`).

---

## 1. View Concept & Architecture

### What is an SQL View?
A **View** is a **virtual table** whose contents are defined by an underlying `SELECT` query. To the end-user or application, a view looks, behaves, and is queried exactly like a standard database table.

* **Virtual Nature:** A standard view does **not** store data rows physically on disk. It stores only the **SQL query definition** inside the database data dictionary.
* **Dynamic Execution:** Whenever a view is queried (`SELECT * FROM view_name`), the RDBMS dynamically merges the view's definition with the outer query and executes it against the underlying base tables (Query Rewriting).

```
+-----------------------------------------------------------------------+
|                             USER / APPLICATION                        |
|                        SELECT * FROM active_employees                 |
+-----------------------------------------------------------------------+
                                   |
                                   v
+-----------------------------------------------------------------------+
|                             DATABASE VIEW                             |
|    CREATE VIEW active_employees AS                                    |
|    SELECT emp_id, first_name, email FROM Employees WHERE status='ACTIVE' |
+-----------------------------------------------------------------------+
                                   |
                                   v (Dynamic Query Rewriting)
+-----------------------------------------------------------------------+
|                          PHYSICAL BASE TABLE                          |
|                             `Employees`                               |
+-----------------------------------------------------------------------+
```

### Core Advantages of Views
1. **Data Security & Row/Column Access Control:** Restricts user access to specific columns or rows without granting direct table permissions (e.g., hiding `salary` or `ssn`).
2. **Query Simplification:** Wraps complex multi-table `JOIN`s, subqueries, and aggregations into a clean, reusable 1-line query.
3. **Data Consistency:** Ensures business rules (e.g., active customer definition) are codified once in the database schema rather than duplicated across multiple application codebases.
4. **Backward Compatibility / Schema Refactoring:** Allows database administrators to refactor or split physical underlying tables without breaking legacy application queries.

---

## 2. Creating & Managing Views

### A. Basic Syntax
```sql
-- Syntax Template
CREATE VIEW view_name AS
SELECT column1, column2, ...
FROM table_name
WHERE condition;
```

### B. Creating or Replacing Views
To modify an existing view definition without dropping permissions, use `CREATE OR REPLACE VIEW`:

```sql
CREATE OR REPLACE VIEW active_employees_view AS
SELECT 
    emp_id,
    first_name,
    last_name,
    email,
    department_id
FROM Employees
WHERE status = 'ACTIVE';
```

### C. Complex Multi-Table Join Views
Views can encapsulate multi-table joins and calculated fields for reporting:

```sql
CREATE VIEW department_salary_summary AS
SELECT 
    d.department_name,
    COUNT(e.emp_id) AS total_employees,
    SUM(e.salary) AS total_payroll,
    ROUND(AVG(e.salary), 2) AS avg_salary
FROM Departments d
JOIN Employees e ON d.department_id = e.department_id
WHERE e.status = 'ACTIVE'
GROUP BY d.department_id, d.department_name;
```

### D. Dropping Views
```sql
DROP VIEW IF EXISTS department_salary_summary;
```

---

## 3. Updating Views (`DML` Through Views)

### A. Conditions for Updatable Views
A view is **updatable** (supports `INSERT`, `UPDATE`, and `DELETE` operations) only if the RDBMS can unambiguously map every view row back to a single unique row in a single base table.

#### A View is NOT Updatable if it Contains:
1. Aggregate functions (`SUM()`, `AVG()`, `COUNT()`, `MIN()`, `MAX()`).
2. `GROUP BY` or `HAVING` clauses.
3. `DISTINCT` keyword.
4. `UNION` or `UNION ALL`.
5. Joins across multiple base tables (some databases allow updating a single base table in a join under strict constraints).
6. Subqueries or derived tables in the `SELECT` list.

### B. Updating Data Through a View
```sql
-- Updating a row via an updatable view
UPDATE active_employees_view
SET email = 'john.doe_updated@company.com'
WHERE emp_id = 101;
```

### C. The `WITH CHECK OPTION` Clause
When inserting or updating rows through a view with a `WHERE` clause, an update might cause the row to **disappear** from the view. The `WITH CHECK OPTION` clause prevents modifications that violate the view's `WHERE` predicate.

```sql
CREATE VIEW high_salary_employees AS
SELECT emp_id, first_name, salary, department_id
FROM Employees
WHERE salary >= 100000.00
WITH CHECK OPTION;

-- FAILED OPERATION:
-- The following UPDATE will fail because the new salary (< 100000) 
-- violates the view's `salary >= 100000` condition!
UPDATE high_salary_employees
SET salary = 85000.00
WHERE emp_id = 105;
-- Result: ERROR 1369 (HY000): CHECK OPTION failed 'db.high_salary_employees'
```

---

## 4. Industry Use Cases

### 1. Role-Based Access Control (RBAC) & PII Protection
* **Scenario:** HR staff require access to employee contact details, but executive compensation data (`salary`, `bonus`) must remain confidential.
* **Solution:** Create `hr_employee_directory` view containing only public columns and grant `SELECT` permissions on the view to HR users, while denying access to the physical `Employees` base table.

### 2. Standardized KPI Analytics Layer
* **Scenario:** Business Intelligence (BI) tools (e.g., Tableau, PowerBI) need consistent metric definitions across all company dashboards.
* **Solution:** Deploy centralized views (`v_monthly_recurring_revenue`, `v_customer_churn`) containing vetted join logic and business rules.

### 3. Schema Refactoring & Legacy Abstraction
* **Scenario:** A database redesign splits a monolithic `Orders` table into `Orders` and `Order_Payments`.
* **Solution:** Create a view named `Orders` joining the two new tables together, preserving zero-downtime backward compatibility for legacy microservices.

---

## 5. Summary Matrix: Table vs. View

| Feature / Metric | Physical Base Table | Database View (`VIEW`) |
| :--- | :--- | :--- |
| **Data Storage** | Stores actual raw data records on disk. | Virtual; stores only query SQL definition. |
| **Storage Overhead** | Requires disk space proportional to row count. | Negligible; requires bytes for definition. |
| **Updatability** | Always updatable via `DML`. | Updatable only under 1-to-1 simple conditions. |
| **Performance** | Direct index scans and table reads. | Re-executes underlying query on access. |
| **Security Layer** | Grants broad table-level access. | Fine-grained row/column-level security. |
