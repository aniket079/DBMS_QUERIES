# Session Guide: Introduction to SQL Subqueries

This lecture and study guide provides a comprehensive, crisp overview of **SQL Subqueries (Nested Queries)**, exploring single-row subqueries, multi-row subqueries, operational operators (`IN`, `ANY`, `ALL`), and practical industry examples.

---

## 1. What is a Subquery?

### A. Core Definition
A **Subquery** (also referred to as an **Inner Query** or **Nested Query**) is an SQL query nested inside another SQL statement (the **Outer Query** or **Main Query**).
- **Execution Flow:** The inner subquery evaluates **first**, and its result is passed as an input operand to the outer query.
- **Enclosing Statements:** Subqueries can be used inside `SELECT`, `INSERT`, `UPDATE`, `DELETE` statements, as well as `WHERE`, `HAVING`, and `FROM` clauses.

### B. Syntax & Fundamental Rules
1. **Parentheses Requirement:** A subquery must always be enclosed within parentheses `()`.
2. **Placement:** A subquery is conventionally placed on the right-hand side of comparison operators (e.g., `WHERE column = (SELECT ...)`).
3. **ORDER BY Limitation:** An `ORDER BY` clause cannot be used inside a subquery unless accompanied by a `LIMIT` clause or evaluated within a top-level FROM derived table.
4. **Column Matching:** Single-row operators require a single scalar return value (1 row, 1 column), whereas multi-row operators expect a single column containing multiple rows.

---

## 2. Single-Row Subqueries

### A. Definition & Behavior
A **Single-Row Subquery** returns **exactly one row and one column** (a single scalar value) to the outer query.

### B. Comparison Operators
Single-row subqueries strictly utilize single-row comparison operators:
- `=` (Equal to)
- `>` (Greater than)
- `>=` (Greater than or equal to)
- `<` (Less than)
- `<=` (Less than or equal to)
- `<>` or `!=` (Not equal to)

### C. Single-Row Subquery Examples

#### Example 1: Filtering Above Class Average
Find all employees whose salary is strictly greater than the average company salary:

```sql
SELECT employee_id, first_name, last_name, salary
FROM Employees
WHERE salary > (
    SELECT AVG(salary)
    FROM Employees
);
```

#### Example 2: Comparing against a Specific Record
Find all employees working in the same department as employee `101`:

```sql
SELECT employee_id, first_name, department_id
FROM Employees
WHERE department_id = (
    SELECT department_id
    FROM Employees
    WHERE employee_id = 101
);
```

> **Warning (Common Runtime Error):** If the inner subquery evaluates to multiple rows (e.g., `SELECT department_id FROM Employees WHERE first_name = 'John'`) while using a single-row operator (`=`), MySQL will raise a runtime error:  
> `ERROR 1242 (21000): Subquery returns more than 1 row`.

---

## 3. Multi-Row Subqueries

### A. Definition & Behavior
A **Multi-Row Subquery** returns **multiple rows** (a dataset column containing zero, one, or many values) to the outer statement.

### B. Multi-Row Operators

| Operator | Operational Meaning | Usage Condition |
| :--- | :--- | :--- |
| **`IN`** | Equal to **any** member in the returned set. | Matches if value is in the subquery list. |
| **`NOT IN`** | Not equal to **any** member in the returned set. | Matches if value is absent from subquery list. |
| **`ANY` / `SOME`** | Compares value to **each** value in the list; true if **at least one** comparison holds. | Combined with `>`, `<`, `=`, etc. (e.g., `> ANY`). |
| **`ALL`** | Compares value to **every** value in the list; true only if **all** comparisons hold. | Combined with `>`, `<`, `=`, etc. (e.g., `> ALL`). |

---

### C. Multi-Row Subquery Examples

#### Example 1: `IN` Operator
Find all employees who work in departments located in `'Chicago'`:

```sql
SELECT employee_id, first_name, last_name, department_id
FROM Employees
WHERE department_id IN (
    SELECT department_id
    FROM Departments
    WHERE location = 'Chicago'
);
```

#### Example 2: `ANY` Operator
Find employees whose salary is greater than the salary of **at least one** IT department employee:

```sql
SELECT employee_id, first_name, salary
FROM Employees
WHERE salary > ANY (
    SELECT salary
    FROM Employees
    WHERE department_id = 3
);
```
*(Equivalent to: `salary > (SELECT MIN(salary) FROM Employees WHERE department_id = 3)`)*

#### Example 3: `ALL` Operator
Find employees whose salary is greater than the salary of **every** employee in the Sales department (`department_id = 5`):

```sql
SELECT employee_id, first_name, salary
FROM Employees
WHERE salary > ALL (
    SELECT salary
    FROM Employees
    WHERE department_id = 5
);
```
*(Equivalent to: `salary > (SELECT MAX(salary) FROM Employees WHERE department_id = 5)`)*

---

## 4. Summary Matrix: Single-Row vs Multi-Row Subqueries

| Feature / Aspect | Single-Row Subqueries | Multi-Row Subqueries |
| :--- | :--- | :--- |
| **Result Set Structure** | Exactly 1 Row, 1 Column (Scalar) | Multiple Rows, 1 Column (List) |
| **Valid Operators** | `=`, `>`, `>=`, `<`, `<=`, `<>` | `IN`, `NOT IN`, `ANY`, `ALL` |
| **Aggregate Functions** | Common in subquery (e.g., `AVG()`, `MAX()`, `MIN()`) | Common when returning grouped records |
| **Error Potential** | Returns error if inner query produces >1 row | Handles 0, 1, or many rows gracefully |
| **Primary Use Case** | Baseline scalar threshold comparison | Membership check & set comparison |
