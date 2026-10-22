# Session Guide: Normalization Fundamentals & Database Anomalies

This reference and lecture guide covers the core principles of **Database Normalization**, focusing on **Data Redundancy** and the three classic modification anomalies: **Insert Anomalies**, **Update Anomalies**, and **Delete Anomalies**. It includes tabular examples, real-world case studies, and step-by-step table decomposition mechanics.

---

## 1. Introduction to Database Normalization

### What is Normalization?
**Normalization** is a systematic database design technique used to organize tables and attributes in a relational database management system (RDBMS). Its primary goal is to **minimize data redundancy** and **prevent modification anomalies** without losing information.

```
+-----------------------------------------------------------------------+
|                       GOALS OF NORMALIZATION                          |
+-----------------------------------------------------------------------+
| 1. Eliminate Duplicate Data (Reduce Data Redundancy)                  |
| 2. Enforce Data Integrity & Consistency across all transactions        |
| 3. Prevent Modification Anomalies (Insert, Update, Delete)            |
| 4. Simplify Maintenance & Database Schema Scalability                 |
| 5. Reduce Storage Overhead and Index Maintenance Costs                |
+-----------------------------------------------------------------------+
```

---

## 2. Understanding Data Redundancy

### A. What is Data Redundancy?
**Data Redundancy** occurs when the same piece of data or attribute relationship is stored redundantly in multiple places within a database table.

### B. Causes of Data Redundancy
Data redundancy typically stems from attempting to store multiple independent entity types (e.g., *Student Details*, *Department Details*, and *Course Details*) within a single unnormalized table flat-file.

### C. Consequences of Uncontrolled Redundancy
1. **Wasted Disk & Memory Storage:** Storing repetitive text strings (e.g., repeating department names, building addresses, or head-of-department titles millions of times).
2. **Performance Degradation:** Larger tables require more I/O operations, heavier buffer pool usage, and slower full table scans.
3. **Data Inconsistency:** When duplicate copies of the same fact conflict due to partial updates or human entry errors.
4. **Modification Anomalies:** The inability to insert, update, or delete records cleanly without side effects.

---

## 3. The Three Database Modification Anomalies

When a database schema suffers from uncontrolled redundancy, executing standard Data Manipulation Language (DML) commands (`INSERT`, `UPDATE`, `DELETE`) leads to severe structural problems known as **Modification Anomalies**.

---

### Case Study Schema: Unnormalized Employee-Department Table (`Emp_Dept`)

Consider the following poorly designed unnormalized table storing employee, department, and project details in a single relation:

#### Table: `Emp_Dept`
| `emp_id` | `emp_name` | `emp_email` | `dept_id` | `dept_name` | `dept_head` | `project_id` | `project_name` |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 101 | Alice | alice@univ.edu | D01 | Computer Science | Dr. Smith | P100 | Portal Redesign |
| 102 | Bob | bob@univ.edu | D01 | Computer Science | Dr. Smith | P200 | Cloud Migration |
| 103 | Charlie | charlie@univ.edu | D02 | Electrical Eng. | Dr. Jones | P100 | Portal Redesign |
| 104 | David | david@univ.edu | D03 | Mechanical Eng. | Dr. Taylor | NULL | NULL |

---

### A. Insert Anomalies

#### Definition
An **Insert Anomaly** occurs when a valid piece of information **cannot be inserted** into the database without simultaneously inserting unrelated or unavailable facts into other attributes.

#### Real-World Example on `Emp_Dept`
* **Scenario:** The university creates a brand-new department called **"Cyber Security"** (`dept_id = 'D04'`, `dept_head = 'Dr. Davis'`).
* **The Anomaly:** We **cannot insert** this new department into the `Emp_Dept` table unless we assign at least one employee to it! 
* **Why?** Primary Key constraint rules on `emp_id` forbid `NULL` values. Inserting a department with `emp_id = NULL` violates entity integrity, whereas inventing dummy employee records pollutes database accuracy.

```
[ Attempt to Insert New Dept: D04 ]
                 │
                 ▼
+-------------------------------------------------------------+
| CANNOT INSERT! Requires a valid 'emp_id' Primary Key value. |
| Result: Department information cannot exist independently.   |
+-------------------------------------------------------------+
```

---

### B. Update Anomalies

#### Definition
An **Update Anomaly** occurs when updating a single real-world fact requires **multiple row updates** across duplicate records. If any row is missed during the update, the database enters an **inconsistent state**.

#### Real-World Example on `Emp_Dept`
* **Scenario:** The Computer Science department (`D01`) appoints a new department head, **"Dr. Miller"**, replacing Dr. Smith.
* **The Anomaly:** Because `D01` details are duplicated across multiple rows (Alice's row and Bob's row), we must update `dept_head` across **every single row** containing `D01`.
* **Inconsistency Risk:** If the application updates Alice's row to `"Dr. Miller"` but fails or crashes before updating Bob's row, the database holds two conflicting heads for the exact same department!

```
Row 1 (Alice): dept_id = D01 ---> dept_head = "Dr. Miller"  [UPDATED]
Row 2 (Bob):   dept_id = D01 ---> dept_head = "Dr. Smith"   [MISSED / OLD]

===> INCONSISTENCY ERROR: Who is the actual head of Department D01?
```

---

### C. Delete Anomalies

#### Definition
A **Delete Anomaly** occurs when deleting a record to remove one piece of information unintentionally causes the **permanent loss of unrelated, critical data**.

#### Real-World Example on `Emp_Dept`
* **Scenario:** Employee **David** (`emp_id = 104`) decides to resign from the university, so his record must be removed.
* **The Anomaly:** Deleting the row containing `emp_id = 104` completely removes David's record. However, David was the **only employee** working in the **Mechanical Eng.** department (`D03`).
* **Consequence:** Deleting David's row **permanently erases all evidence** that the Mechanical Engineering department (`D03`, `Dr. Taylor`) ever existed in the university!

```
[ DELETE FROM Emp_Dept WHERE emp_id = 104; ]
                 │
                 ▼
+-------------------------------------------------------------+
| UNINTENDED LOSS: Department D03 (Mechanical Eng., Dr. Taylor)|
| is permanently wiped out from the database!                 |
+-------------------------------------------------------------+
```

---

## 4. Solving Anomalies through Table Decomposition

To eliminate data redundancy and prevent modification anomalies, we perform **Normalization by Table Decomposition**. We split the bloated `Emp_Dept` table into smaller, focused entities linked by Foreign Keys.

### Normalized Relational Schema Blueprint

#### 1. Table: `Departments`
| `dept_id` (PK) | `dept_name` | `dept_head` |
| :---: | :---: | :---: |
| D01 | Computer Science | Dr. Smith |
| D02 | Electrical Eng. | Dr. Jones |
| D03 | Mechanical Eng. | Dr. Taylor |
| D04 | Cyber Security | Dr. Davis |

*✔ Solution to Insert Anomaly:* Department `D04` can be added immediately without assigning employees.  
*✔ Solution to Update Anomaly:* Updating `dept_head` for `D01` requires changing exactly **one single value** in one place.

#### 2. Table: `Employees`
| `emp_id` (PK) | `emp_name` | `emp_email` | `dept_id` (FK) |
| :---: | :---: | :---: | :---: |
| 101 | Alice | alice@univ.edu | D01 |
| 102 | Bob | bob@univ.edu | D01 |
| 103 | Charlie | charlie@univ.edu | D02 |
| 104 | David | david@univ.edu | D03 |

*✔ Solution to Delete Anomaly:* Deleting David (`104`) removes David's employee record, but Department `D03` remains safely intact in the `Departments` table!

#### 3. Table: `Projects`
| `project_id` (PK) | `project_name` |
| :---: | :---: |
| P100 | Portal Redesign |
| P200 | Cloud Migration |

#### 4. Table: `Employee_Projects` (Junction Table)
| `emp_id` (PK, FK) | `project_id` (PK, FK) |
| :---: | :---: |
| 101 | P100 |
| 102 | P200 |
| 103 | P100 |

---

## 5. Summary & Anomaly Comparison Matrix

| Anomaly Type | Triggering DML Action | Core Cause | Real-World Impact | Solution |
| :--- | :--- | :--- | :--- | :--- |
| **Insert Anomaly** | `INSERT` | Mixing independent entity facts into one table | Unable to store new entity facts without dummy or null keys | Decompose entity into its own standalone relation |
| **Update Anomaly** | `UPDATE` | Duplicate copies of identical facts across rows | Data inconsistency / conflicting records if updates are partial | Store each fact in exactly one place (1NF/2NF/3NF) |
| **Delete Anomaly** | `DELETE` | Combining primary entities with dependent entities | Unintended loss of valid surrounding facts upon row removal | Isolate independent entities with foreign key links |

---

## 6. In-Class Quiz & Self-Assessment Exercises

### Question 1
**What is the primary technical objective of database normalization?**  
- **a)** To increase data redundancy for query performance  
- **b)** To eliminate duplicate data and prevent modification anomalies  
- **c)** To automatically generate SQL queries  
- **d)** To encrypt sensitive table columns  
* **Answer:** **b)** To eliminate duplicate data and prevent modification anomalies

### Question 2
**A database administrator attempts to change a customer's address, but finds that the old address still appears on past order records in the same flat table. Which anomaly is this?**  
- **a)** Insert Anomaly  
- **b)** Delete Anomaly  
- **c)** Update Anomaly  
- **d)** Select Anomaly  
* **Answer:** **c)** Update Anomaly

### Question 3
**How does table decomposition eliminate the Delete Anomaly?**  
- *Answer:* By splitting independent entities into separate tables linked by Foreign Keys, deleting a record from one table (e.g., removing an employee) does not delete the master record of the associated entity (e.g., the department) in another table.
