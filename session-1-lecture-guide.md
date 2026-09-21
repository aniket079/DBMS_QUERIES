# Session 1 Instructor Lecture Guide: Advanced Data Filtering in MySQL
**Target Lecture Duration:** 100 Minutes  
**Software Environment:** MySQL Workbench (Local/Standard connection)  

---

## ⏱️ Minute-by-Minute Instructor Timeline

| Time (Mins) | Focus Area | Key Concepts Covered | Pedagogical Strategy |
| :--- | :--- | :--- | :--- |
| **00 - 15** | **Introduction & The WHERE Clause** | Row filtration concepts, logical query execution order, query optimization. | Board work: Compare scanning an entire spreadsheet vs. using a filter. |
| **15 - 30** | **Comparison Operators** | `=`, `<>`, `!=`, `>`, `<`, `>=`, `<=`. Truth evaluation (1, 0, NULL). | Live Demo: Running basic filters on the `students` schema. |
| **30 - 50** | **Logical Operators & Compound Filters** | `AND`, `OR`, `NOT`, operator precedence, short-circuiting, handling NULL. | Interaction: Challenge students with compound boolean expressions. |
| **50 - 65** | **Value Memberships & Ranges** | `BETWEEN ... AND` (inclusive bounds), `IN (...)`, `NOT IN (...)`. | Syntax cleanup: Rewrite nested `OR` conditions as clean `IN` conditions. |
| **65 - 85** | **Pattern Matching (LIKE & Wildcards)** | `%` and `_` wildcards, case-sensitivity, `ESCAPE` clause, index performance. | Performance warning: Contrast fast index searches vs. slow leading wildcards. |
| **85 - 100** | **Hands-On Classroom Lab & Wrap-Up** | Live challenge, problem-solving, debugging student syntax in MySQL Workbench. | Active learning: Complete a production SQL-cleaning scenario. |

---

## 🛠️ Complete MySQL Workbench Setup Script
*Copy, paste, and run this entire script in MySQL Workbench to prepare the classroom database before beginning the lecture.*

```sql
-- Create the training database
CREATE DATABASE IF NOT EXISTS university_db;
USE university_db;

-- 1. Create the Students Table
DROP TABLE IF EXISTS students;
CREATE TABLE students (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50),
    age INT,
    grade CHAR(1)
);

-- Ingest sample students dataset
INSERT INTO students (name, age, grade) VALUES
('John', 20, 'A'),
('Emily', 22, 'B'),
('Michael', 21, 'A'),
('Sophia', 19, 'C'),
('William', 23, 'B');

-- 2. Create the Customers Table
DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    company_name VARCHAR(100)
);

-- Ingest sample customers dataset
INSERT INTO customers (name, email, company_name) VALUES
('Alice Anderson', 'alice@reintech.io', 'FinTech Solutions'),
('Bob Smith', 'bob@reintech.io', 'TechCorp'),
('Charlie Brown', 'charlie@reintech.io', 'Biotech Labs'),
('Morgan Freeman', 'morgan@reintech.io', 'Biotech Labs'),
('Nora Jones', 'nora@reintech.io', 'FinTech Solutions'),
('Boris Johnson', 'boris@reintech.io', 'Global Logistics'),
('John Doe', 'john.doe@gmail.com', NULL);

-- 3. Create the Products Table
DROP TABLE IF EXISTS products;
CREATE TABLE products (
    product_code VARCHAR(50) PRIMARY KEY,
    product_name VARCHAR(100),
    discount VARCHAR(10)
);

-- Ingest sample products dataset
INSERT INTO products (product_code, product_name, discount) VALUES
('AB1-2024', 'Screwdriver', '15%'),
('ABX-TECH', 'Hammer', '10%'),
('CD2-3021', 'Wrench', '15%'),
('EF3-4044', 'Pliers', '5%'),
('XX_-9999', 'Special Drill Bit', '20%');
```

---

## 📖 Detailed Lecture Notes & Live Demo Queries

### 1. Introduction & The WHERE Clause (00 - 15 Mins)

#### 💡 Core Theory
In relational databases, querying tables without filters returns every single row. In production systems with millions of records, this causes massive network latency and resource exhaustion [13, 14]. **Filtering** is the process of selecting specific subsets of data based on precise conditions [14].

The **`WHERE` clause** is the fundamental tool for row-level filtering in SQL [16]. It evaluates expressions for each row in the table: if the condition evaluates to `TRUE` (or `1`), the row is included in the output; if it evaluates to `FALSE` (or `0`) or `NULL` (unknown), the row is immediately discarded [16, 29].

#### 🔍 Execution Order Insight (Explain on Board)
In a standard SELECT query, the clause execution order is different from the writing order:
1. **`FROM`** (Locate and lock the source table)
2. **`WHERE`** (Scan each row and apply the filtering condition to build the result set)
3. **`SELECT`** (Extract and display the requested columns from the filtered rows)

Because `WHERE` executes *before* `SELECT`, you cannot use column aliases created in the `SELECT` list inside the `WHERE` clause.

#### 💻 Live Demo Query
Let's locate all students who are older than 20 years old [16].

```sql
SELECT id, name, age, grade 
FROM students 
WHERE age > 20;
```

**Expected Workbench Output:**
```text
+----+---------+-----+-------+
| id | name    | age | grade |
+----+---------+-----+-------+
|  2 | Emily   |  22 | B     |
|  3 | Michael |  21 | A     |
|  5 | William |  23 | B     |
+----+---------+-----+-------+
```
*Note: Sophia (19) and John (20) are discarded because they fail the predicate check.*

---

### 2. Comparison Operators (15 - 30 Mins)

#### 💡 Core Theory
Comparison operators evaluate the mathematical relationship between two expressions [29]. MySQL evaluates these and returns a boolean value [29]:
*   **`1` (TRUE)**
*   **`0` (FALSE)**
*   **`NULL` (Unknown)**

#### 🛠️ Available Comparison Operators in MySQL [17]
*   `=` : Equal to
*   `<>` or `!=` : Not equal to
*   `>` : Greater than
*   `<` : Less than
*   `>=` : Greater than or equal to
*   `<=` : Less than or equal to

#### ⚠️ The Critical NULL Warning
In SQL, `NULL` represents a missing or unknown value [29]. Normal comparison operators will **never** match `NULL`. For example, `company_name = NULL` or `company_name != NULL` will evaluate to `NULL` (unknown), discarding the record [29, 62]. To check for empty values, SQL provides specific NULL-handling operators:
*   `IS NULL` (Evaluates to true if value is missing)
*   `IS NOT NULL` (Evaluates to true if value exists)

#### 💻 Live Demo Queries

**A. String Matching (Grade is 'B') [18]**
```sql
SELECT * 
FROM students 
WHERE grade = 'B';
```
**Expected Output:** Emily and William are returned.

**B. Handling NULL Fields**
Let's find customers who do not have a company assigned (where the company is NULL) [62].
```sql
-- WRONG QUERY (Will return nothing!)
SELECT * FROM customers WHERE company_name = NULL;

-- CORRECT QUERY
SELECT * FROM customers WHERE company_name IS NULL;
```
**Expected Output:** John Doe is returned.

---

### 3. Logical Operators & Compound Conditions (30 - 50 Mins)

#### 💡 Core Theory
Logical operators let us combine multiple comparison predicates within a single `WHERE` clause [18, 29].

| Operator | SQL Syntax | Logical Behavior |
| :--- | :--- | :--- |
| **Logical AND** | `AND` or `&&` | Returns row **only** if both conditions evaluate to TRUE [29]. |
| **Logical OR** | `OR` or `\|\|` | Returns row if **at least one** condition is TRUE [18, 29]. |
| **Logical NOT** | `NOT` or `!` | Negates/reverses the truth value of the underlying condition [29]. |

#### 🚦 Operator Precedence Rules
When mixing multiple logical operators, SQL evaluates them in the following strict order of precedence:
1.  **`NOT`** (highest priority)
2.  **`AND`**
3.  **`OR`** (lowest priority)

**Instructor TIP:** Teach students to **always use parentheses `()`** to override default precedence and make queries safe, clear, and readable.

#### 💻 Live Demo Queries

**A. Using OR to combine conditions**
Let's find students who are younger than 20 years old OR have achieved an 'A' grade [19].
```sql
SELECT * 
FROM students 
WHERE age < 20 OR grade = 'A';
```
**Expected Output:** John (Grade A), Michael (Grade A), and Sophia (Age 19) are returned [19].

**B. The Danger of Operator Precedence**
Suppose we want to find customers who are:
*   At "Biotech Labs" **OR** "FinTech Solutions"
*   **AND** have an email address ending in `@reintech.io`.

```sql
-- WRONG QUERY (Due to precedence, AND takes priority over OR)
SELECT * FROM customers 
WHERE company_name = 'Biotech Labs' 
   OR company_name = 'FinTech Solutions' 
  AND email LIKE '%@reintech.io';
-- Evaluates as: "Biotech Labs" (any email) OR ("Fintech Solutions" with @reintech.io email).

-- CORRECT QUERY (Forced precedence via parentheses)
SELECT * FROM customers 
WHERE (company_name = 'Biotech Labs' OR company_name = 'FinTech Solutions') 
  AND email LIKE '%@reintech.io';
```

---

### 4. Value Memberships & Ranges (50 - 65 Mins)

#### 💡 Core Theory
As filter requirements grow, SQL queries can become bloated with repetitive `OR` conditions. SQL provides `BETWEEN` and `IN` as powerful "syntactic sugar" to keep queries clean, efficient, and readable [29].

#### 📅 Range Matching with `BETWEEN ... AND`
The `BETWEEN` operator matches values within an **inclusive** range (meaning the start and end boundary values are included in the results) [29, 49, 64].
*   *Syntax:* `column BETWEEN value1 AND value2`
*   *Equivalence:* `column >= value1 AND column <= value2`

#### 📦 Set Membership with `IN`
The `IN` operator checks if a column value matches any element in a specified list of values [29, 64].
*   *Syntax:* `column IN (value1, value2, ...)`
*   *Equivalence:* `(column = value1 OR column = value2 OR ...)`

Using `NOT IN` excludes all records that match values in the list [64].

#### 💻 Live Demo Queries

**A. Student Age Range Check**
```sql
-- Find students aged between 20 and 22 (inclusive)
SELECT * 
FROM students 
WHERE age BETWEEN 20 AND 22;
```
**Expected Output:** John (20), Emily (22), and Michael (21) are returned.

**B. Replacing Repeated OR conditions with IN**
```sql
-- Bloated and hard to read:
SELECT * FROM customers 
WHERE company_name = 'FinTech Solutions' 
   OR company_name = 'TechCorp' 
   OR company_name = 'Biotech Labs';

-- Clean, elegant solution:
SELECT * FROM customers 
WHERE company_name IN ('FinTech Solutions', 'TechCorp', 'Biotech Labs');
```

---

### 5. Pattern Matching: LIKE & Wildcards (65 - 85 Mins)

#### 💡 Core Theory
In production databases, searching for exact strings is often too restrictive [51]. We need to search for partial matches or identify formatting trends in text fields [51]. The **`LIKE` operator** enables flexible string pattern-matching [49, 52].

#### 🃏 MySQL Wildcard Symbols [53]
*   **`%` (Percent Sign):** Matches **zero, one, or multiple characters** [53].
    *   `'A%'` -> Matches names starting with 'A' ("Alice", "Anderson", "A") [53, 54].
    *   `'%@reintech.io'` -> Matches email suffixes [55].
    *   `'%tech%'` -> Matches substrings anywhere in the string ("FinTech", "TechCorp", "Biotech") [55].
*   **`_` (Underscore):** Matches **exactly one single character** [53].
    *   `'AB_-%'` -> Matches "AB1-", "ABX-", but not "AB12-" (as the 3rd position must be a single character) [56].

#### ⚙️ MySQL Case Sensitivity Defaults
In standard MySQL installations, the `LIKE` operator is **case-insensitive** by default [57]. For example, `LIKE 'a%'` will match names starting with both 'a' and 'A' [57].
*   To force a case-sensitive match, prepend the **`BINARY`** keyword: `WHERE name LIKE BINARY 'A%'` [58].

#### 🚀 Performance Alert: Leading Wildcards and Full Table Scans [58]
Explain this critical engineering trade-off on the board:
*   `LIKE 'prefix%'` is **FAST** because MySQL can use indexes to jump straight to matching records [59].
*   `LIKE '%suffix'` or `LIKE '%substring%'` is **SLOW** because the database cannot predict the starting characters [59]. MySQL is forced to perform a **full table scan**, looking at every single row in the database, which slows down queries on large tables [58, 62].

#### 🚪 Escaping Literal Wildcards
If you need to search for a literal `%` or `_` character, you must escape it so MySQL does not read it as a wildcard [60]. SQL uses the **`ESCAPE`** clause to define a temporary escape character [60].

#### 💻 Live Demo Queries

**A. Using Single Character Wildcard (`_`)**
Find names where 'or' is located exactly in the second and third character positions [56, 57].
```sql
SELECT * 
FROM customers 
WHERE name LIKE '_or%';
```
**Expected Output:** Morgan Freeman and Boris Johnson (both have 'or' as characters 2 and 3). Nora Jones is excluded because her 'or' starts at the second position but doesn't fit the layout of `_or%` (hers matches `%or%` instead).

**B. Escaping Literal Percent Characters**
Let's find products offering exactly a '15%' discount [60].
```sql
-- WRONG: Matches any product starting with "15" (e.g., "150", "159", "15%")
SELECT * FROM products WHERE discount LIKE '15%';

-- CORRECT: Defines '!' as our temporary escape character
SELECT * FROM products 
WHERE discount LIKE '15!%' ESCAPE '!';
```
**Expected Output:** Screwdriver and Wrench (both are exactly '15%').

---

## 💻 Classroom Lab: Real-World Data Investigation (85 - 100 Mins)

### 📋 The Scenario
You are a database engineer at an e-commerce shipping facility. A customer support ticket has arrived flagging data anomalies. You must query the `university_db` database using SQL Workbench to isolate the suspicious records.

### 🏋️ Task Checklist (Deliver to Students)

1.  **Prefix Search:** Locate all customers whose names start with the letter **'B'** [54].
2.  **Null & List Exclusions:** Find all customers who have a known company (not null) AND whose company is **NOT** 'TechCorp' or 'Global Logistics' [62, 64].
3.  **Pattern Combination:** Identify any products where the `product_code` starts with the letters **'AB'**, followed by **any single character**, followed by a **hyphen (`-`)**, and ending in a string containing the text **'TECH'** or numbers [56].
4.  **Literal Escape Challenge:** Locate the database record for the "Special Drill Bit" by pattern matching its `product_code` (which contains a literal underscore) [60].

---

### 🔑 Classroom Lab Solution Key (For Instructor Reference)

**Query 1:**
```sql
SELECT * FROM customers 
WHERE name LIKE 'B%';
```

**Query 2:**
```sql
SELECT * FROM customers 
WHERE company_name IS NOT NULL 
  AND company_name NOT IN ('TechCorp', 'Global Logistics');
```

**Query 3:**
```sql
SELECT * FROM products 
WHERE product_code LIKE 'AB_-%';
```

**Query 4 (The Escape Test):**
```sql
SELECT * FROM products 
WHERE product_code LIKE '%!_9999' ESCAPE '!';
```

---

## 📝 Lecture Summary Checklist for Students
Before letting class out, ensure students can answer:
1.  Why does `WHERE` execute before `SELECT`?
2.  Why does a search like `LIKE '%corp%'` hurt production database performance [58, 62]?
3.  What happens when you try to compare values to `NULL` using `=` or `!=` [29, 62]?
4.  What is the purpose of the `ESCAPE` keyword in pattern matching [60]?
