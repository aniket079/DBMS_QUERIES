# Session Guide: Third Normal Form (3NF) & Boyce-Codd Normal Form (BCNF)

This comprehensive reference and lecture guide covers the core principles, mathematical mechanics, and step-by-step transformation techniques for **Third Normal Form (3NF)** and **Boyce-Codd Normal Form (BCNF)** in relational database design.

---

## 1. Third Normal Form (3NF)

### A. Transitive Dependency Definition & 3NF Prerequisite
A relation R is in **Third Normal Form (3NF)** if and only if:
1. R is already in **Second Normal Form (2NF)**.
2. There are **no transitive dependencies** for non-prime attributes.

#### What is a Transitive Dependency?
A transitive dependency occurs when a non-prime attribute depends on another non-prime attribute rather than directly on a Candidate Key.
Formally, if:
- `X -> Y`
- `Y -> Z`
Then transitively, `X -> Z`.
If `X` is a Candidate Key, `Y` is a non-prime attribute, and `Z` is a non-prime attribute, then `Y -> Z` is a **Transitive Dependency**.

#### Formal 3NF Rule (For Every Non-Trivial FD `X -> Y`):
At least ONE of the following conditions must hold for every non-trivial functional dependency `X -> Y`:
1. `X` is a **Super Key** of relation R, OR
2. `Y` is a **Prime Attribute** (a member of at least one candidate key of R).

---

### B. Detecting & Eliminating Transitive Dependencies

```
                    CANDIDATE KEY (X)
                           |
                           v
                 NON-PRIME ATTRIBUTE (Y)
                           |
                           v  [TRANSITIVE DEPENDENCY]
                 NON-PRIME ATTRIBUTE (Z)
```

#### Steps to Convert a 2NF Relation to 3NF:
1. Identify all Candidate Keys of relation R.
2. Classify all attributes as Prime or Non-Prime.
3. Examine all functional dependencies `X -> Y`.
4. Check if `X` is a Super Key or if `Y` is a Prime Attribute.
5. If neither condition holds, `X -> Y` is a **Transitive Dependency**.
6. **Decompose:** Remove the transitively dependent attribute `Y` and its determinant `X` into a new relation `R2(X, Y)` with `X` as its Primary Key. Retain `X` in the original relation as a Foreign Key.

---

### C. Case Study: Employee Department Location Schema

#### Initial 2NF Relation: `Emp_Dept`
Consider a relation tracking employees, their departments, and department physical locations:

`Emp_Dept(emp_id, emp_name, dept_id, dept_name, dept_location)`

#### Functional Dependency Set F:
1. `emp_id -> emp_name, dept_id`
2. `dept_id -> dept_name, dept_location`

#### Step 1: Candidate Key Discovery
- Attribute Closure: `(emp_id)+ = {emp_id, emp_name, dept_id, dept_name, dept_location}`
- **Candidate Key:** `emp_id` (Single attribute key -> automatically satisfies 2NF)

#### Step 2: Classify Attributes
- **Prime Attribute:** `emp_id`
- **Non-Prime Attributes:** `emp_name`, `dept_id`, `dept_name`, `dept_location`

#### Step 3: Identify Transitive Dependencies
- `emp_id -> emp_name, dept_id`: `emp_id` is a Super Key. **(VALID 3NF ✅)**
- `dept_id -> dept_name, dept_location`: `dept_id` is NOT a Super Key, and `dept_name`/`dept_location` are NOT prime attributes. **(TRANSITIVE DEPENDENCY VIOLATION ❌)**

#### Step 4: Decompose into 3NF Relations
We decompose `Emp_Dept` into **two 3NF relations**:

1. **`Departments` Table:**
   `Departments(dept_id, dept_name, dept_location)`
   *Primary Key:* `dept_id`

2. **`Employees` Table:**
   `Employees(emp_id, emp_name, dept_id)`
   *Primary Key:* `emp_id`
   *Foreign Key:* `dept_id` referencing `Departments(dept_id)`

#### SQL DDL Implementation (3NF Compliant):
```sql
CREATE TABLE Departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(100) NOT NULL,
    dept_location VARCHAR(100) NOT NULL
);

CREATE TABLE Employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100) NOT NULL,
    dept_id INT NOT NULL,
    FOREIGN KEY (dept_id) REFERENCES Departments(dept_id) ON DELETE RESTRICT
);
```

---

## 2. Boyce-Codd Normal Form (BCNF / 3.5NF)

### A. Motivation & BCNF Definition
Boyce-Codd Normal Form (BCNF) was introduced by Raymond F. Boyce and Edgar F. Codd in 1974. It is a stricter version of 3NF designed to handle scenarios involving **overlapping candidate keys**.

While 3NF allows `X -> Y` if `Y` is a prime attribute (even if `X` is not a super key), this exception can still allow data redundancy. BCNF removes this exception entirely.

#### Formal BCNF Rule:
A relation R is in **Boyce-Codd Normal Form (BCNF)** if and only if for EVERY non-trivial functional dependency `X -> Y`:
- `X` MUST be a **Super Key** of relation R.

> 💡 **Rule of Thumb:** In BCNF, "Every determinant MUST be a Candidate Key!"

---

### B. Comparison: 3NF vs. BCNF

| Metric / Feature | Third Normal Form (3NF) | Boyce-Codd Normal Form (BCNF) |
| :--- | :--- | :--- |
| **FD Requirement (`X -> Y`)** | `X` is Super Key OR `Y` is Prime Attribute | `X` MUST be a Super Key (No exceptions) |
| **Strictness** | Slightly relaxed to guarantee dependency preservation | Stricter; eliminates all determinant redundancy |
| **Dependency Preservation** | ALWAYS guaranteed | Not always guaranteed (may require tradeoff) |
| **Lossless Join Decomposition** | ALWAYS guaranteed | ALWAYS guaranteed |
| **Overlapping Keys Anomaly** | Can still exist | Completely eliminated |

---

### C. Classic BCNF Case Study: Student Advisor Schema

#### Initial Relation: `Advisor_Student`
Consider an academic advising table tracking students, course subjects, and assigned advisors:

`Advisor_Student(student_id, course_code, advisor_id)`

#### Business Rules:
1. Each student can take multiple courses and have multiple advisors, but only ONE advisor per course.
2. Each advisor specializes in and advises for exactly ONE course code.
3. An advisor can advise many students.

#### Functional Dependencies:
1. `(student_id, course_code) -> advisor_id`
2. `advisor_id -> course_code`

#### Step 1: Candidate Key Discovery
- Closure `(student_id, course_code)+ = {student_id, course_code, advisor_id}` -> Candidate Key 1: `(student_id, course_code)`
- Since `advisor_id -> course_code`, Closure `(student_id, advisor_id)+ = {student_id, advisor_id, course_code}` -> Candidate Key 2: `(student_id, advisor_id)`

#### Step 2: Attribute Classification
- **Prime Attributes:** `student_id`, `course_code`, `advisor_id` (All attributes are prime!)
- **Non-Prime Attributes:** None.

#### Step 3: Evaluate for 3NF
- `(student_id, course_code) -> advisor_id`: Left side `(student_id, course_code)` is a Super Key. **(Passes 3NF ✅)**
- `advisor_id -> course_code`: Left side `advisor_id` is NOT a super key, BUT right side `course_code` IS a prime attribute. **(Passes 3NF ✅)**
- **Conclusion:** The table is in 3NF!

#### Step 4: Evaluate for BCNF (The Problem)
- `advisor_id -> course_code`: Left side `advisor_id` is NOT a Super Key. **(BCNF VIOLATION ❌)**

#### Redundancy Anomaly in 3NF:
If advisor 'Dr. Smith' advises for 'CS101', every student assigned to Dr. Smith repeats the fact that Dr. Smith advises 'CS101'. If no students are assigned to Dr. Smith, we cannot record that Dr. Smith advises 'CS101' without dummy student data.

#### Step 5: BCNF Decomposition
For violating FD `X -> Y` where `X` is not a super key:
1. Decompose R into `R1(X, Y)` and `R2(R - Y)`.
2. For violating FD `advisor_id -> course_code`:
   - `R1(advisor_id, course_code)` with Primary Key `advisor_id`
   - `R2(student_id, advisor_id)` with Primary Key `(student_id, advisor_id)` and Foreign Key `advisor_id` referencing `R1`.

#### SQL DDL Implementation (BCNF Compliant):
```sql
CREATE TABLE Advisors (
    advisor_id INT PRIMARY KEY,
    course_code VARCHAR(10) NOT NULL
);

CREATE TABLE Student_Advisors (
    student_id INT NOT NULL,
    advisor_id INT NOT NULL,
    PRIMARY KEY (student_id, advisor_id),
    FOREIGN KEY (advisor_id) REFERENCES Advisors(advisor_id) ON DELETE CASCADE
);
```

---

## 3. Solved Practice Problems & Self-Assessment

### Practice Problem 1: 3NF Evaluation & Decomposition
Given relation `R(A, B, C, D, E)` with functional dependency set F:
`F = { A -> B, B -> C, C -> D, DE -> A }`

1. Find all Candidate Keys.
2. Test for 3NF and decompose if necessary.

#### Solution:
1. **Candidate Keys:**
   - Attribute `E` never appears on the right side of any FD, so `E` must be in every candidate key.
   - `(A, E)+ = {A, B, C, D, E}` -> Candidate Key: `(A, E)`
   - `(B, E)+ = {B, C, D, A, E}` -> Candidate Key: `(B, E)`
   - `(C, E)+ = {C, D, A, B, E}` -> Candidate Key: `(C, E)`
   - `(D, E)+ = {D, A, B, C, E}` (from `DE -> A`) -> Candidate Key: `(D, E)`
2. **Attribute Classification:**
   - All attributes `{A, B, C, D, E}` are Prime Attributes!
3. **3NF Check:**
   - `A -> B`: `A` is not super key, but `B` is prime -> **(Valid 3NF ✅)**
   - `B -> C`: `B` is not super key, but `C` is prime -> **(Valid 3NF ✅)**
   - `C -> D`: `C` is not super key, but `D` is prime -> **(Valid 3NF ✅)**
   - `DE -> A`: `DE` is a candidate key -> **(Valid 3NF ✅)**
4. **Conclusion:** Relation R is **already in 3NF**!

---

### Practice Problem 2: BCNF Decomposition
Given relation `R(A, B, C, D)` with functional dependency set F:
`F = { A -> B, B -> C, C -> D }`

1. Find the Candidate Key.
2. Test for BCNF and decompose into BCNF relations.

#### Solution:
1. **Candidate Key:** `(A)+ = {A, B, C, D}` -> Candidate Key is `A`.
2. **BCNF Check:**
   - `A -> B`: `A` is a Super Key -> **(Valid BCNF ✅)**
   - `B -> C`: `B` is NOT a Super Key -> **(BCNF VIOLATION ❌)**
   - `C -> D`: `C` is NOT a Super Key -> **(BCNF VIOLATION ❌)**
3. **Decomposition Steps:**
   - Decompose using violating FD `B -> C`:
     - `R1(B, C)` with PK `B` (FD: `B -> C`) -> In BCNF!
     - `R_rest(A, B, D)` with FDs `{ A -> B, B -> D }`
   - Decompose `R_rest(A, B, D)` using violating FD `B -> D`:
     - `R2(B, D)` with PK `B` (FD: `B -> D`) -> In BCNF!
     - `R3(A, B)` with PK `A` (FD: `A -> B`) -> In BCNF!
4. **Final BCNF Relations:** `R1(B, C)`, `R2(B, D)`, `R3(A, B)`.

---

## 4. Normalization Summary Matrix (1NF through BCNF)

| Normal Form | Primary Rule / Objective | Anomaly Removed | Key Condition for `X -> Y` |
| :--- | :--- | :--- | :--- |
| **1NF** | All cell values must be atomic | Multi-valued attributes & repeating groups | Single atomic value per cell |
| **2NF** | In 1NF + No partial dependencies | Partial dependencies (non-prime on part of key) | `X` cannot be a proper subset of Candidate Key |
| **3NF** | In 2NF + No transitive dependencies | Transitive dependencies (non-prime on non-prime) | `X` is Super Key OR `Y` is Prime Attribute |
| **BCNF** | In 3NF + Every determinant is super key | Overlapping candidate key anomalies | `X` MUST be a Super Key (No exceptions) |
