# Session 21 Guide: Correlated Subqueries in SQL

This reference and lecture guide covers the core concepts, execution mechanics, practical query patterns, and performance optimization strategies for **Correlated Subqueries** in Relational Database Management Systems (RDBMS).

---

## 1. Correlated Subquery Concept

### A. What is a Correlated Subquery?
A **Correlated Subquery** is an inner SQL query that references one or more columns from the outer query table (`outer_table.column_name`). Unlike an uncorrelated subquery, a correlated subquery cannot be executed independently of the main query because its evaluation depends directly on the current candidate row being processed by the outer query.

#### Uncorrelated vs. Correlated Subquery Comparison:

| Feature / Metric | Uncorrelated Subquery | Correlated Subquery |
| :--- | :--- | :--- |
| **Outer Table Reference** | None. Completely self-contained. | References columns from the outer query table (`e.dept_id`). |
| **Execution Frequency** | Executes **once** before the outer query runs. | Executes **once per candidate row** evaluated by outer query. |
| **Independent Execution** | Can be executed standalone in SQL client. | Raises `ERROR: Unknown column` if executed standalone. |
| **Typical Operators** | `=`, `IN`, `NOT IN`, `ANY`, `ALL` | `EXISTS`, `NOT EXISTS`, `=`, `>`, `<` with correlated key |

---

## 2. Execution Flow & Evaluation Mechanics

### A. Step-by-Step Execution Pipeline
When a database engine processes a correlated subquery, it follows a nested loop execution model:

```
+-----------------------------------------------------------------------+
|  1. Outer Query fetches Candidate Row 1 from Outer Table              |
|  2. Outer Column Values from Row 1 are bound to Inner Subquery        |
|  3. Inner Subquery executes using Row 1 parameters                     |
|  4. Inner Result is returned to Outer Query predicate                 |
|  5. IF predicate == TRUE: Keep Row 1 in final output                  |
|     ELSE: Discard Row 1                                              |
|  6. Repeat Steps 1-5 for Candidate Row 2, Row 3, ..., Row N           |
+-----------------------------------------------------------------------+
```

### B. Procedural Code Analogy
In procedural programming terms, a correlated subquery functions identically to a nested `for` loop:

```python
output_rows = []
for outer_row in outer_table:
    # Inner query receives current outer_row attributes as parameters
    subquery_result = execute_inner_query(outer_row.dept_id)
    if outer_row.salary > subquery_result:
        output_rows.append(outer_row)
```

---

## 3. Practical SQL Examples & Real-World Use Cases

### Example 1: Finding Employees Earning Above Their Department Average
To find employees whose salary exceeds the average salary of **their specific department**:

```sql
SELECT e.emp_id, e.first_name, e.dept_id, e.salary
FROM Employees e
WHERE e.salary > (
    SELECT AVG(emp.salary)
    FROM Employees emp
    WHERE emp.dept_id = e.dept_id -- Correlated join condition
);
```
* **How it Works:** For every employee `e`, the inner query calculates `AVG(salary)` specifically for `e.dept_id`. If employee `e.salary` is higher than that calculated average, the record is included.

---

### Example 2: Finding the Most Recent Order Per Customer
To retrieve the complete record of the latest order placed by each customer:

```sql
SELECT o1.order_id, o1.customer_id, o1.order_date, o1.total_amount
FROM Orders o1
WHERE o1.order_date = (
    SELECT MAX(o2.order_date)
    FROM Orders o2
    WHERE o2.customer_id = o1.customer_id -- Correlated condition
);
```

---

### Example 3: Existence Checking with `EXISTS` and `NOT EXISTS`
Correlated subqueries paired with `EXISTS` evaluate boolean presence without transferring data:

```sql
-- Customers who have placed at least one order
SELECT c.customer_id, c.name
FROM Customers c
WHERE EXISTS (
    SELECT 1 
    FROM Orders o 
    WHERE o.customer_id = c.customer_id
);

-- Customers who have NEVER placed an order
SELECT c.customer_id, c.name
FROM Customers c
WHERE NOT EXISTS (
    SELECT 1 
    FROM Orders o 
    WHERE o.customer_id = c.customer_id
);
```

---

## 4. Performance Discussion & Query Optimization

### A. The N+1 Query Problem & Computational Complexity
If the outer table contains **N rows** and the inner table contains **M rows**, an unoptimized correlated subquery performs **N separate inner evaluations**. Without index support, this results in an **O(N x M)** full table scan workload, leading to severe CPU and disk I/O bottlenecks on large datasets.

### B. Optimization Strategies

#### 1. Indexing Correlated Join Columns
Adding a composite index on the inner table's correlated column and filter target transforms the inner evaluation from an **O(M) full table scan** to an **O(log M) B-Tree index lookup**, reducing total complexity to **O(N log M)**.

```sql
-- Create composite index to optimize correlated lookup
CREATE INDEX idx_emp_dept_salary ON Employees(dept_id, salary);
```

#### 2. Query Rewriting using `INNER JOIN` + `GROUP BY`
Rewriting a correlated subquery into an explicit `JOIN` against a pre-aggregated derived table allows the database query optimizer to execute a single-pass scan:

```sql
-- Optimized Alternative: Derived Table Join
SELECT e.emp_id, e.first_name, e.dept_id, e.salary
FROM Employees e
INNER JOIN (
    SELECT dept_id, AVG(salary) AS avg_sal
    FROM Employees
    GROUP BY dept_id
) d ON e.dept_id = d.dept_id
WHERE e.salary > d.avg_sal;
```

#### 3. Replacing Correlated Subqueries with Window Functions
In modern SQL (MySQL 8.0+), **Window Functions** compute partition aggregates in a single pass without subqueries or nested loops:

```sql
-- Modern Optimized Alternative: Window Function
WITH RankedEmployees AS (
    SELECT emp_id, first_name, dept_id, salary,
           AVG(salary) OVER (PARTITION BY dept_id) AS avg_sal
    FROM Employees
)
SELECT emp_id, first_name, dept_id, salary
FROM RankedEmployees
WHERE salary > avg_sal;
```

---

## 5. Summary & Key Takeaways

1. **Correlation Dependency:** Correlated subqueries reference outer query columns (`outer.col`), executing once per candidate outer row.
2. **Short-Circuit Efficiency with `EXISTS`:** `EXISTS` stops scanning the inner table as soon as the first matching row is found.
3. **Avoid N+1 Traps:** Always ensure correlated columns are indexed, or consider rewriting into `JOIN` / Window Functions for large tables.
