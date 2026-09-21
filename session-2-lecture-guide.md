# MySQL Built-in Functions Lecture Guide

This guide is designed for quick in-class scanning. It contains direct, ready-to-run SQL examples and brief bullet points explaining exactly how each function works in MySQL Workbench.

---

## 🛠️ Step 1: Database Setup Script
Run this script in MySQL Workbench to create a demo table with messy whitespace, mixed casing, decimal salaries, and various dates to play with.

```sql
-- Create and switch to the database
CREATE DATABASE IF NOT EXISTS company_db;
USE company_db;

-- Drop table if it already exists to start fresh
DROP TABLE IF EXISTS class_employees;

-- Create the demo employees table
CREATE TABLE class_employees (
    emp_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    salary DECIMAL(10,2),
    hire_date DATE,
    birth_date DATE
);

-- Insert demo records (containing leading/trailing spaces and mixed letter casing)
INSERT INTO class_employees (first_name, last_name, salary, hire_date, birth_date) VALUES
('  Alice ', 'Johnson', 75000.55, '2020-05-10', '1990-12-15'),
('Bob', '  Smith ', 48000.00, '2021-03-15', '1985-06-22'),
('charlie', 'brown', 62000.40, '2022-07-20', '1995-02-05'),
('Diana', 'Lee', 95000.99, '2018-11-01', '1988-09-30'),
(' Ethan', 'Miller  ', 54000.12, '2023-01-12', '1992-04-18');
```

---

## 🔤 Section 1: String Functions
Used to clean, parse, and transform text fields on the fly without changing the underlying database data.

### 1. `CONCAT(str1, str2, ...)`
* **What it does:** Merges multiple strings into a single text output.
* **Class Demo Query:**
  ```sql
  SELECT first_name, last_name, 
         CONCAT(first_name, ' ', last_name) AS full_name 
  FROM class_employees;
  ```

### 2. `LOWER(str)` / `LCASE(str)` & `UPPER(str)` / `UCASE(str)`
* **What it does:** Standardizes letter case to all-lowercase or all-uppercase. Perfect for searching or standardizing display outputs.
* **Class Demo Query:**
  ```sql
  SELECT last_name, 
         LOWER(last_name) AS lower_last, 
         UPPER(last_name) AS upper_last 
  FROM class_employees;
  ```

### 3. `TRIM(str)`
* **What it does:** Strips accidental leading and trailing whitespace characters from strings.
* **Class Demo Query:**
  ```sql
  -- Compare the column with the cleaned version
  SELECT first_name AS raw_name, 
         TRIM(first_name) AS cleaned_name 
  FROM class_employees;
  ```

### 4. `LENGTH(str)`
* **What it does:** Returns the length of a string in bytes. Excellent for validation or testing text field lengths.
* **Class Demo Query:**
  ```sql
  -- Note: Whitespace characters are counted in length!
  SELECT first_name, 
         LENGTH(first_name) AS raw_length, 
         LENGTH(TRIM(first_name)) AS trimmed_length 
  FROM class_employees;
  ```

### 5. `SUBSTRING(str, position, length)` / `SUBSTR()`
* **What it does:** Extracts a portion of a string. Positions are **1-indexed** (starting at 1). Negative positions count backward from the end.
* **Class Demo Query:**
  ```sql
  -- Extract 3 characters starting from the 1st character of the last name
  -- Extract 4 characters starting from the 3rd position from the end (-3)
  SELECT last_name, 
         SUBSTRING(last_name, 1, 3) AS first_three,
         SUBSTRING(last_name, -3, 3) AS last_three
  FROM class_employees;
  ```

---

## 🔢 Section 2: Numeric Functions
Used to perform math calculations, rounding, and value checking.

### 1. `ROUND(number, decimals)`
* **What it does:** Rounds a value to a specified number of decimal places using standard mathematical rules (5 rounds up).
* **Class Demo Query:**
  ```sql
  SELECT salary, 
         ROUND(salary, 1) AS rounded_to_one, 
         ROUND(salary, 0) AS rounded_to_int 
  FROM class_employees;
  ```

### 2. `TRUNCATE(number, decimals)`
* **What it does:** Cuts off a number at the specified decimal place without rounding up or down.
* **Class Demo Query:**
  ```sql
  -- Observe how 95000.99 truncates to 95000.9, whereas ROUND makes it 95001.0
  SELECT salary, 
         TRUNCATE(salary, 1) AS truncated_to_one,
         TRUNCATE(salary, 0) AS truncated_to_int
  FROM class_employees;
  ```

### 3. `MOD(N, M)`
* **What it does:** Returns the remainder of a division operation (modulo).
* **Class Demo Query:**
  ```sql
  -- Identify even and odd Employee IDs using modulo
  SELECT emp_id, 
         MOD(emp_id, 2) AS remainder,
         IF(MOD(emp_id, 2) = 0, 'Even ID', 'Odd ID') AS id_type
  FROM class_employees;
  ```

### 4. `POWER(base, exponent)` / `POW()`
* **What it does:** Raises a base number to a specified power.
* **Class Demo Query:**
  ```sql
  SELECT emp_id, 
         POWER(emp_id, 2) AS id_squared, 
         POWER(3, 2) AS static_power_demo;
  ```

### 5. `SQRT(number)`
* **What it does:** Computes the non-negative square root of a numeric value.
* **Class Demo Query:**
  ```sql
  SELECT emp_id, 
         SQRT(emp_id) AS sqrt_id 
  FROM class_employees;
  ```

### 6. `SIGN(number)`
* **What it does:** Evaluates the sign of a number. Returns `1` for positive values, `-1` for negative values, and `0` for zero.
* **Class Demo Query:**
  ```sql
  SELECT salary, 
         SIGN(salary) AS sign_salary,
         SIGN(-150) AS negative_test;
  ```

---

## 📅 Section 3: Date & Time Functions
Essential for operating on temporal values. Remember: MySQL dates default to `'YYYY-MM-DD'` format.

### 1. `CURDATE()` / `CURRENT_DATE()`
* **What it does:** Obtains today's system date without any time components.
* **Class Demo Query:**
  ```sql
  SELECT CURDATE() AS todays_date;
  ```

### 2. `NOW()` vs. `SYSDATE()`
* **What it does:** Both return the current date and time. However, `NOW()` captures the time the query *started* execution, while `SYSDATE()` captures the exact time that *specific function call* executed (visible when using a delay like `SLEEP`).
* **Class Demo Query:**
  ```sql
  SELECT NOW() AS now_time, SYSDATE() AS sys_time;
  ```

### 3. `DATE()`, `MONTH()`, & `YEAR()`
* **What it does:** Extract individual date components from datetime or standard date expressions.
* **Class Demo Query:**
  ```sql
  SELECT hire_date, 
         YEAR(hire_date) AS hire_year, 
         MONTH(hire_date) AS hire_month, 
         DATE('2020-12-31 01:02:03') AS date_part_extracted
  FROM class_employees;
  ```

### 4. `ADDDATE(date, INTERVAL value unit)`
* **What it does:** Adds or subtracts specified time intervals (days, weeks, months, years) to/from a date value.
* **Class Demo Query:**
  ```sql
  -- Find the date 45 days in the future, and 7 months & 3 weeks in the past
  SELECT CURDATE() AS base_date,
         ADDDATE(CURDATE(), INTERVAL 45 DAY) AS future_45_days,
         ADDDATE(ADDDATE(CURDATE(), INTERVAL -7 MONTH), INTERVAL -3 WEEK) AS nested_past_date;
  ```

### 5. `DATEDIFF(date1, date2)`
* **What it does:** Computes the subtraction `date1 - date2` and returns the difference in **number of days**. (Returns negative if `date1` is older than `date2`).
* **Class Demo Query:**
  ```sql
  -- Find tenure in days and convert to age using ABS to ensure a positive value
  SELECT first_name, 
         DATEDIFF(CURDATE(), hire_date) AS tenure_days,
         ABS(DATEDIFF(birth_date, CURDATE())) AS age_in_days
  FROM class_employees;
  ```

### 6. `DATE_FORMAT(date, format_string)`
* **What it does:** Formats a date using a template string. Characters prefixed with `%` are dynamic date placeholders.
* **Common format placeholders:**
  * `%a`: Abbreviated weekday (e.g., Fri)
  * `%D`: Day of the month with English suffix (e.g., 10th)
  * `%M`: Full month name (e.g., March)
  * `%Y`: 4-digit year (e.g., 2026)
* **Class Demo Query:**
  ```sql
  SELECT hire_date, 
         DATE_FORMAT(hire_date, '%a %D %M, %Y') AS pretty_hire_date,
         DATE_FORMAT(hire_date, 'Hired in %M of %Y') AS custom_label
  FROM class_employees;
  ```

---

## 🧩 Section 4: Nesting Functions & Filtering
Demonstrates combining functions together in queries and using functions inside `WHERE` clauses to perform complex row filtering.

### Demo 1: Clean and Merge Messy Text (Nesting)
Combining `UPPER()`, `TRIM()`, and `CONCAT()` to clean whitespace and capitalize names cleanly.
```sql
SELECT first_name, last_name,
       CONCAT(
           UPPER(TRIM(first_name)), 
           ' ', 
           UPPER(TRIM(last_name))
       ) AS super_clean_name
FROM class_employees;
```

### Demo 2: Filter by Calculated Date Ranges
Finding employees who have been with the company for more than 4 years (using `ADDDATE` or `DATEDIFF`).
```sql
-- Method A: Using DATEDIFF (365 days * 4 = 1460 days)
SELECT first_name, last_name, hire_date 
FROM class_employees
WHERE DATEDIFF(CURDATE(), hire_date) > 1460;

-- Method B: Using ADDDATE (Hired before 4 years ago)
SELECT first_name, last_name, hire_date 
FROM class_employees
WHERE hire_date < ADDDATE(CURDATE(), INTERVAL -4 YEAR);
```

---

## 📝 Section 5: Hands-on Class Challenge
Instruct your students to write a single SQL query in MySQL Workbench that accomplishes the following:

1. Clean any leading/trailing whitespace from employees' first and last names.
2. Join their names together as: `LastName, FirstName` (all in uppercase).
3. Compute how many years old the employee was when they were officially hired (hint: use `DATEDIFF` on `hire_date` and `birth_date`, then divide by `365.25` and round to `1` decimal place).
4. Display their official hire date formatted exactly like: `"Sunday 10th May, 2020"` (hint: you may use `%W` for weekday name, `%D` for day suffix, `%M` for month, and `%Y` for year).

### 🏆 Challenge Solution Script
*(Keep this hidden or show it on the projector as the answer key)*
```sql
SELECT 
    -- 1 & 2: Clean and Join
    UPPER(CONCAT(TRIM(last_name), ', ', TRIM(first_name))) AS clean_formal_name,
    
    -- 3: Compute Age at Hire Date
    ROUND(DATEDIFF(hire_date, birth_date) / 365.25, 1) AS age_at_hire,
    
    -- 4: Custom Date Formatting
    DATE_FORMAT(hire_date, '%W %D %M, %Y') AS formatted_hire_date
FROM class_employees;
```
