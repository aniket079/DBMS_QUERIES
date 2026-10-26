# Session Guide: SQL Aggregate Functions (COUNT, SUM, AVG, MIN, MAX)

This comprehensive reference guide covers the core principles, mathematical mechanics, NULL-handling rules, and optimization strategies for **SQL Aggregate Functions**.

---

## 1. Introduction to Aggregate Functions

### A. What is an Aggregate Function?
An **Aggregate Function** processes multiple values across a column or group of rows and returns a **single scalar value** summarizing that set of data.

```
  Multi-Row Input Domain                    Aggregate Operation                     Single Scalar Output
+------------------------+                                                       +--------------------+
|  Salary Column Values  |                                                       |    Result Value    |
|  [5000, 6000, 7000]    |  =================>  SUM(salary)  =================>  |      18000.00      |
+------------------------+                                                       +--------------------+
```

### B. Core Operational Characteristics
1. **Multi-Row Input to Single-Row Output:** Reduces row sets into summary statistics.
2. **Implicit NULL Elimination:** All standard aggregate functions (except `COUNT(*)`) automatically ignore `NULL` values during calculation.
3. **Combination with Grouping:** Frequently paired with the `GROUP BY` clause to calculate per-category summary statistics.
4. **Keyword Support (`DISTINCT` vs `ALL`):**
   - `ALL` (Default): Evaluates all non-NULL values in the column.
   - `DISTINCT`: Evaluates only unique, non-duplicate non-NULL values.

---

## 2. The COUNT() Function

### A. Mechanics & Variants
`COUNT()` calculates the number of rows or non-NULL column entries in a result set.

| Syntax Variant | Evaluation Behavior | NULL Handling | Performance / Indexing |
| :--- | :--- | :--- | :--- |
| `COUNT(*)` | Counts all rows in the table matching query predicates. | **Includes NULLs** | Optimized via Primary Key / metadata count in storage engines. |
| `COUNT(column)` | Counts rows where `column` contains a non-NULL value. | **Ignores NULLs** | Requires scanning the specified column. |
| `COUNT(DISTINCT col)` | Counts unique, distinct non-NULL values in `col`. | **Ignores NULLs** | Requires sorting/hash table to eliminate duplicates. |

### B. Code Example & Data Walkthrough
Consider table `Employees(emp_id, bonus)`:

| emp_id | bonus |
| :---: | :---: |
| 101 | 500.00 |
| 102 | 500.00 |
| 103 | NULL |
| 104 | 1000.00 |

```sql
-- 1. Count all rows in table
SELECT COUNT(*) AS total_employees FROM Employees;
-- Result: 4

-- 2. Count non-NULL bonus records
SELECT COUNT(bonus) AS employees_with_bonus FROM Employees;
-- Result: 3 (Row 103 is ignored)

-- 3. Count unique bonus amounts
SELECT COUNT(DISTINCT bonus) AS unique_bonuses FROM Employees;
-- Result: 2 (500.00 and 1000.00)
```

---

## 3. The SUM() Function

### A. Mechanics & Evaluation
`SUM()` calculates the total mathematical addition of all non-NULL numeric values in a column.

- **Data Type Compatibility:** Operates on numeric domains (`INT`, `DECIMAL`, `FLOAT`).
- **NULL Handling:**
  - Ignores `NULL` values during addition.
  - **Edge Case:** If all evaluated rows contain `NULL` or the input row set is empty, `SUM()` returns `NULL` (not `0`).

### B. Code Example & Zero-Coalescing Pattern

```sql
-- Standard SUM calculation
SELECT SUM(salary) AS total_payroll 
FROM Employees 
WHERE department_id = 10;

-- Best Practice: Handling empty row sets or ALL-NULL columns using COALESCE
SELECT COALESCE(SUM(salary), 0.00) AS safe_total_payroll 
FROM Employees 
WHERE department_id = 999;
-- Returns 0.00 instead of NULL
```

---

## 4. The AVG() Function

### A. Mathematical Mechanics
`AVG()` computes the arithmetic mean of a numeric column.

$$\text{AVG(column)} = \frac{\text{SUM(column)}}{\text{COUNT(column)}}$$

> **Critical Caveat:** Because `AVG()` ignores `NULL`s in both the numerator AND denominator, rows containing `NULL` are completely omitted from the average calculation.

### B. The NULL Skew Pitfall & Solution
Consider 4 employees with scores: `[100, 100, NULL, 100]`.

1. **Standard `AVG(score)`:**
   $$\text{AVG(score)} = \frac{100 + 100 + 100}{3} = 100.00$$
2. **Coalesced `AVG(COALESCE(score, 0))` (Treating NULL as 0):**
   $$\text{AVG} = \frac{100 + 100 + 0 + 100}{4} = 75.00$$

```sql
-- Omits NULL rows from denominator
SELECT AVG(score) AS average_score FROM Assessment;

-- Includes NULL rows in denominator by converting NULL -> 0
SELECT AVG(COALESCE(score, 0)) AS adjusted_average_score FROM Assessment;
```

---

## 5. The MIN() and MAX() Functions

### A. Operational Characteristics
- `MIN()` returns the lowest value in a set.
- `MAX()` returns the highest value in a set.
- **Universal Data Type Support:**
  - **Numeric:** Compares mathematical magnitude (`MIN(10, 20) -> 10`).
  - **String / Text:** Compares lexicographical collation order (`MIN('Alice', 'Bob') -> 'Alice'`).
  - **Date / Time:** Compares chronological sequence (`MIN('2026-01-01', '2026-10-25') -> '2026-01-01'`).

### B. B-Tree Index Optimization
When `MIN()` or `MAX()` is executed on an indexed column, the database engine avoids scanning the table. It performs an $O(1)$ or $O(\log N)$ lookup directly at the leftmost or rightmost leaf page of the B-Tree index.

```sql
-- Optimal B-Tree lookup (Executes in O(1) time if hire_date is indexed)
SELECT MIN(hire_date) AS earliest_hire, MAX(hire_date) AS latest_hire 
FROM Employees;
```

---

## 6. Comprehensive Summary Matrix

| Function | Output Type | NULL Handling | Behavior on Empty Table / All NULLs | Key Example |
| :--- | :--- | :--- | :--- | :--- |
| `COUNT(*)` | Integer | **Includes NULLs** | Returns `0` | `SELECT COUNT(*) FROM Orders;` |
| `COUNT(col)` | Integer | **Ignores NULLs** | Returns `0` | `SELECT COUNT(email) FROM Users;` |
| `SUM(col)` | Numeric | **Ignores NULLs** | Returns `NULL` | `SELECT SUM(amount) FROM Sales;` |
| `AVG(col)` | Numeric / Float | **Ignores NULLs** | Returns `NULL` | `SELECT AVG(price) FROM Products;` |
| `MIN(col)` | Same as column | **Ignores NULLs** | Returns `NULL` | `SELECT MIN(birth_date) FROM Patients;` |
| `MAX(col)` | Same as column | **Ignores NULLs** | Returns `NULL` | `SELECT MAX(score) FROM ExamResults;` |
