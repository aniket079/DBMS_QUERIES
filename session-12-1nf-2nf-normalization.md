# Session Guide: First Normal Form (1NF) & Second Normal Form (2NF)

This comprehensive reference and lecture guide covers the core principles, mathematical mechanics, and step-by-step transformation techniques for **First Normal Form (1NF)** and **Second Normal Form (2NF)** in database design, formatted using universal ASCII notation.

---

## 1. First Normal Form (1NF)

### A. Atomic Values & 1NF Definition
A relation R is in **First Normal Form (1NF)** if and only if:
1. Every attribute value in every row is **atomic** (a single, indivisible value from its domain).
2. There are **no repeating groups** or multi-valued attributes stored in a single cell.
3. Every row is uniquely identifiable (there exists a designated Primary Key).
4. The order of rows and columns does not affect data retrieval.

#### What is an "Atomic Value"?
An attribute value is **atomic** if it cannot or should not be logically decomposed into smaller meaningful sub-components within the relational domain.
- **Atomic:** salary = 75000.00, status = 'ACTIVE', student_id = 101
- **Non-Atomic (Multi-Valued):** skills = 'Java, Python, SQL' (multiple values in one cell)
- **Non-Atomic (Composite):** full_name = 'Dr. Jane Smith' (contains prefix, first name, last name if individually queried)

---

### B. Common 1NF Violations & Anti-Patterns

| Anti-Pattern / Violation | Problem Description | Example |
| :--- | :--- | :--- |
| **Multi-Valued Cells** | Storing comma-separated or delimited lists inside a single attribute cell. | phone_numbers = '555-0100, 555-0199' |
| **Repeating Columns** | Creating numbered columns to store variable amounts of the same attribute type. | phone1, phone2, phone3 |
| **Lack of Primary Key** | Tables containing identical duplicate rows with no unique record identifier. | Duplicate rows in an unconstrained log table |

#### Why Repeating Columns (phone1, phone2, phone3) Violate 1NF Principles:
1. **Arbitrary Limits:** Imposes an artificial limit (e.g., max 3 phones per customer).
2. **Wasted Storage:** Unused columns contain NULL values for customers with only 1 phone number.
3. **Complex Queries:** Searching for a specific phone number requires searching across multiple columns with compound OR conditions:
   ```sql
   WHERE phone1 = '555-0100' OR phone2 = '555-0100' OR phone3 = '555-0100'
   ```

---

### C. Converting an Unnormalized Relation (UNF) to 1NF

There are **two main strategies** to convert an unnormalized table containing multi-valued attributes into 1NF:

#### Strategy 1: Row Expansion (Flattening)
Duplicate the single-valued key attributes across multiple rows so each multi-valued item gets its own distinct row.

##### Unnormalized Table (UNF):
| emp_id | emp_name | department | projects |
| :--- | :--- | :--- | :--- |
| 101 | Alice | IT | Alpha, Beta |
| 102 | Bob | HR | Gamma |

##### Transformed to 1NF (Row Expansion):
| emp_id | emp_name | department | project_name |
| :--- | :--- | :--- | :--- |
| 101 | Alice | IT | Alpha |
| 101 | Alice | IT | Beta |
| 102 | Bob | HR | Gamma |

> **Note:** The Primary Key for the expanded 1NF table becomes a composite key: (emp_id, project_name).

#### Strategy 2: Table Decomposition (Recommended)
Separate the multi-valued attribute into a child table linked to the parent entity via a Foreign Key.

```sql
-- Parent Table (Strong Entity)
CREATE TABLE Employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100) NOT NULL,
    department VARCHAR(50) NOT NULL
);

-- Child Table for Multi-Valued Attribute
CREATE TABLE Employee_Projects (
    emp_id INT NOT NULL,
    project_name VARCHAR(50) NOT NULL,
    PRIMARY KEY (emp_id, project_name),
    FOREIGN KEY (emp_id) REFERENCES Employees(emp_id) ON DELETE CASCADE
);
```

---

### D. Practical 1NF Conversion Example

#### Scenario: Student Course Registration (UNF)
A university maintains an unnormalized spreadsheet tracking student course enrollments:

| student_id | student_name | phone_numbers | registered_courses |
| :--- | :--- | :--- | :--- |
| S101 | Rahul Sharma | 9876543210, 9123456789 | CS101, CS202 |
| S102 | Priya Patel | 8899001122 | CS101 |

#### Step-by-Step 1NF Decomposition:

1. **Step 1:** Extract phone_numbers into a separate child table Student_Phones.
2. **Step 2:** Extract registered_courses into a separate junction table Student_Courses.

```sql
-- 1. Main Student Entity Table (1NF)
CREATE TABLE Students (
    student_id VARCHAR(10) PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL
);

-- 2. Multi-Valued Phone Numbers Table (1NF)
CREATE TABLE Student_Phones (
    student_id VARCHAR(10) NOT NULL,
    phone_number VARCHAR(15) NOT NULL,
    PRIMARY KEY (student_id, phone_number),
    FOREIGN KEY (student_id) REFERENCES Students(student_id) ON DELETE CASCADE
);

-- 3. Multi-Valued Course Registration Table (1NF)
CREATE TABLE Student_Courses (
    student_id VARCHAR(10) NOT NULL,
    course_code VARCHAR(10) NOT NULL,
    PRIMARY KEY (student_id, course_code),
    FOREIGN KEY (student_id) REFERENCES Students(student_id) ON DELETE CASCADE
);
```

---

## 2. Second Normal Form (2NF)

### A. Partial Dependency Definition & Prerequisite
A relation R is in **Second Normal Form (2NF)** if and only if:
1. R is already in **First Normal Form (1NF)**.
2. Every **non-prime attribute** is **fully functionally dependent** on every candidate key of R.
3. There are **no partial dependencies**.

#### Key Definitions:
- **Prime Attribute:** An attribute that is a member of at least one candidate key of relation R.
- **Non-Prime Attribute:** An attribute that is not part of any candidate key of R.
- **Partial Dependency:** Occurs when a non-prime attribute A is functionally dependent on a proper subset of a composite candidate key K.
  `If K = (X, Y) is a candidate key and X -> A holds (where A is non-prime), then X -> A is a Partial Dependency.`

> **Important Rule:** If a relation's Candidate Key consists of a **single attribute** (not composite), the relation is **automatically in 2NF** (provided it is in 1NF), because no proper subset of a single attribute key exists!

---

### B. Detecting & Eliminating Partial Dependencies

```
                          COMPOSITE CANDIDATE KEY (A, B)
                                /              \
                               /                \
                     PROPER SUBSET (A)      PROPER SUBSET (B)
                            |                      |
                            v                      v
                    NON-PRIME ATTR (C)     NON-PRIME ATTR (D)
                    [PARTIAL DEPENDENCY]   [PARTIAL DEPENDENCY]
```

#### Steps to Convert a 1NF Relation to 2NF:
1. Identify all Candidate Keys of relation R.
2. Identify all Prime and Non-Prime attributes.
3. Examine all functional dependencies X -> Y where Y is a non-prime attribute.
4. If X is a proper subset of any Candidate Key, flag X -> Y as a **Partial Dependency**.
5. **Decompose:** Remove the partially dependent attributes Y and the determinant X into a new relation R2(X, Y) with X as its Primary Key. Retain X in the original relation as a Foreign Key.

---

### C. Comprehensive Case Study: E-Commerce Order Processing

#### Initial 1NF Relation: OrderDetails
Consider a relation tracking customer purchase orders and product inventory details:

`R(order_id, product_id, customer_name, product_name, unit_price, quantity)`

#### Functional Dependency Set F:
1. (order_id, product_id) -> quantity
2. order_id -> customer_name
3. product_id -> product_name, unit_price

#### Step 1: Candidate Key Discovery
- Attribute Closure of (order_id, product_id)+ = {order_id, product_id, quantity, customer_name, product_name, unit_price}
- **Candidate Key:** (order_id, product_id) (Composite Key)

#### Step 2: Classify Attributes
- **Prime Attributes:** order_id, product_id
- **Non-Prime Attributes:** customer_name, product_name, unit_price, quantity

#### Step 3: Identify Partial Dependencies
- order_id -> customer_name : order_id is a proper subset of key (order_id, product_id). **(PARTIAL DEPENDENCY - INVALID FOR 2NF)**
- product_id -> product_name, unit_price : product_id is a proper subset of key (order_id, product_id). **(PARTIAL DEPENDENCY - INVALID FOR 2NF)**
- (order_id, product_id) -> quantity : Full functional dependency on entire candidate key. **(VALID 2NF)**

#### Step 4: Decompose into 2NF Relations

We decompose R into **three 2NF relations**:

1. **Orders Table:**
   `R1(order_id, customer_name)`
   *Primary Key:* order_id

2. **Products Table:**
   `R2(product_id, product_name, unit_price)`
   *Primary Key:* product_id

3. **Order_Items Table:**
   `R3(order_id, product_id, quantity)`
   *Primary Key:* (order_id, product_id)
   *Foreign Keys:* order_id references R1, product_id references R2

#### SQL DDL Implementation (2NF Compliant):
```sql
CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL
);

CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL
);

CREATE TABLE Order_Items (
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE RESTRICT
);
```

---

## 3. Solved Practice Questions & Self-Assessment

### Practice Problem 1: Partial Dependency Analysis
Given relation R(A, B, C, D, E) with functional dependency set F:
`F = { (A, B) -> C,  A -> D,  B -> E }`

1. Find the Candidate Key of relation R.
2. Identify all partial dependencies.
3. Decompose relation R into 2NF relations.

#### Solution:
1. **Candidate Key:**
   (A, B)+ = {A, B, C, D, E}. Candidate Key is (A, B).
2. **Prime Attributes:** A, B
   **Non-Prime Attributes:** C, D, E
3. **Partial Dependency Check:**
   - (A, B) -> C : Full Dependency on key (A, B). Valid 2NF.
   - A -> D : A is a proper subset of key (A, B), D is non-prime. **Partial Dependency!**
   - B -> E : B is a proper subset of key (A, B), E is non-prime. **Partial Dependency!**
4. **2NF Decomposition:**
   - R1(A, D) with Primary Key = A
   - R2(B, E) with Primary Key = B
   - R3(A, B, C) with Primary Key = (A, B) and Foreign Keys = A, B

---

### Practice Problem 2: Single-Attribute Key Evaluation
Given relation R(Student_ID, Major, Advisor) where Student_ID -> Major and Student_ID -> Advisor.
Is this relation in 2NF?

#### Solution:
- **Candidate Key:** Student_ID
- Since the Candidate Key consists of a single attribute, no proper subset of the key exists.
- Therefore, no partial dependencies can exist.
- **Conclusion:** Relation R is **automatically in 2NF** (provided it is in 1NF, though it may contain transitive dependencies requiring 3NF).

---

## 4. Summary Matrix: 1NF vs 2NF

| Normal Form | Primary Rule / Objective | Eliminates | Solution Strategy |
| :--- | :--- | :--- | :--- |
| **First Normal Form (1NF)** | All cell values must be atomic. | Multi-valued attributes, repeating groups, non-unique rows. | Row expansion or table decomposition into parent-child tables. |
| **Second Normal Form (2NF)** | Must be in 1NF AND have no partial dependencies. | Partial dependencies (non-prime attributes depending on part of a key). | Decompose into separate entity tables with single/composite PKs and FKs. |
