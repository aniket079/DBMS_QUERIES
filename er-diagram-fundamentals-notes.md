# Entity-Relationship (ER) Model: Detailed Study Guide

## 1. Introduction to the Entity-Relationship (ER) Model
The **Entity-Relationship (ER) Model** is a high-level conceptual data model used to design database schemas before implementation in a Relational Database Management System (RDBMS). Introduced by Peter Chen in 1976, it provides a visual representation of real-world objects, their characteristics, and how they interact.

### Why Use the ER Model?
- **Abstraction:** Hides physical storage and technical implementation details, focusing purely on data structure and business logic.
- **Communication Bridge:** Serves as a clear blueprint between non-technical business stakeholders, database designers, and software engineers.
- **Schema Blueprint:** Directly translates into physical relational tables (`CREATE TABLE` statements), Primary Keys, and Foreign Keys.

---

## 2. Entities & Entity Sets

### A. Entity
An **Entity** is a real-world object, concept, person, or event that is distinguishable from other objects and about which data is stored in the database.
- *Examples:* A specific employee (`Alice`), a product (`Laptop`), a department (`Human Resources`).

### B. Entity Set
An **Entity Set** is a collection or set of similar entities that share the same attributes or properties.
- *Examples:* The `EMPLOYEE` entity set containing all employees, the `COURSE` entity set containing all offered courses.

### C. Types of Entities

| Entity Type | Definition | Key Characteristic | Example |
| :--- | :--- | :--- | :--- |
| **Strong Entity** | An entity that exists independently of any other entity in the database and possesses a **Primary Key** (a unique identifier). | Represented by a single rectangle. | `CUSTOMER` (identified by `customer_id`), `STUDENT` (identified by `student_id`). |
| **Weak Entity** | An entity that **cannot exist independently** and lacks a primary key of its own. It depends on a **Strong Entity (Owner Entity)** for its existence. | Identified by a **Partial Key (Discriminator)** in combination with the Owner Entity's Primary Key. Represented by a **double rectangle**. | `DEPENDENT` (child/spouse of an employee), `ORDER_ITEM` (line item belonging to a specific order). |

---

## 3. Attributes

An **Attribute** is a property or characteristic that describes an entity or a relationship.

### Classification of Attributes

1. **Simple (Atomic) Attribute:**
   - Cannot be divided into smaller sub-components.
   - *Examples:* `age`, `salary`, `tax_id`.

2. **Composite Attribute:**
   - Can be divided into smaller sub-attributes with independent meanings.
   - *Examples:* `full_name` (divided into `first_name`, `last_name`), `address` (divided into `street`, `city`, `state`, `zip_code`).

3. **Single-Valued Attribute:**
   - Holds exactly one value for a given entity instance.
   - *Examples:* `date_of_birth`, `ssn`.

4. **Multi-Valued Attribute:**
   - Can hold **multiple values** for a single entity instance.
   - *Representation:* Represented by a **double ellipse**.
   - *Examples:* `phone_number` (a person can have multiple phone numbers), `skills` (an employee can have multiple technical skills).

5. **Derived Attribute:**
   - Is not stored physically in the database but is computed dynamically from other stored attributes or system values.
   - *Representation:* Represented by a **dashed ellipse**.
   - *Examples:* `age` (derived from `date_of_birth` and `CURRENT_DATE`), `total_experience` (derived from `hire_date`).

6. **Key Attribute:**
   - Uniquely identifies an entity within an entity set.
   - *Representation:* Represented by an ellipse with **underlined text**.
   - *Examples:* <u>`student_id`</u> in `STUDENT`, <u>`isbn`</u> in `BOOK`.

---

## 4. Relationships & Cardinality Constraints

A **Relationship** represents an association or connection between two or more entities. A **Relationship Set** is a collection of similar relationships.

### A. Degree of a Relationship
The number of entity sets participating in a relationship:
- **Unary (Recursive) Relationship (Degree 1):** Relationship within a single entity set (e.g., an `EMPLOYEE` *manages* another `EMPLOYEE`).
- **Binary Relationship (Degree 2):** Relationship between two entity sets (e.g., `STUDENT` *enrolls in* `COURSE`). Most common in database design.
- **Ternary Relationship (Degree 3):** Relationship simultaneously involving three entity sets (e.g., `DOCTOR` *prescribes* `DRUG` to `PATIENT`).

### B. Structural Constraints

#### 1. Cardinality Ratios (Mapping Constraints)
Defines the maximum number of entity instances in one set that can be associated with entity instances in another set.

- **One-to-One (1:1):**
  - An entity in A is associated with at most one entity in B, and vice versa.
  - *Example:* A `DEPARTMENT` is managed by exactly one `EMPLOYEE` (Manager), and an `EMPLOYEE` manages at most one `DEPARTMENT`.
- **One-to-Many (1:N):**
  - An entity in A is associated with any number (0 or more) of entities in B, but an entity in B is associated with at most one entity in A.
  - *Example:* A `CUSTOMER` can place many `ORDERS`, but an `ORDER` belongs to only one `CUSTOMER`.
- **Many-to-One (N:1):**
  - Inverse of One-to-Many. Multiple entities in A map to a single entity in B.
  - *Example:* Many `EMPLOYEES` work in one `DEPARTMENT`.
- **Many-to-Many (M:N):**
  - An entity in A can be associated with any number of entities in B, and vice versa.
  - *Example:* A `STUDENT` can enroll in multiple `COURSES`, and a `COURSE` can have multiple enrolled `STUDENTS`.

#### 2. Participation Constraints (Min Cardinality)
Defines whether the existence of an entity depends on its being related to another entity.

- **Total Participation (Mandatory):**
  - Every entity in the entity set **must** participate in at least one relationship instance.
  - *Representation:* Represented by a **double line** connecting the entity set to the relationship.
  - *Example:* Every `ORDER` **must** be placed by a `CUSTOMER` (Total participation of `ORDER` in `PLACES`).
- **Partial Participation (Optional):**
  - Some entities in the entity set may not participate in the relationship.
  - *Representation:* Represented by a **single line**.
  - *Example:* Not every `EMPLOYEE` manages a `DEPARTMENT` (Partial participation of `EMPLOYEE` in `MANAGES`).

### C. Relationship Attributes
Relationships can also have descriptive attributes that belong directly to the association rather than either individual entity.
- *Example:* In a `STUDENT` *enrolls in* `COURSE` relationship, `grade` or `enrollment_date` belongs to the `ENROLLS_IN` relationship.

---

## 5. ER Diagram Notation & Symbols (Chen vs. Crow's Foot)

### Chen Notation vs. Crow's Foot Notation Comparison

| ER Component | Chen Notation Symbol | Crow's Foot Notation Symbol |
| :--- | :--- | :--- |
| **Entity Set** | Rectangle | Box / Table header |
| **Weak Entity Set** | Double Rectangle | Box with rounded corners / dependent frame |
| **Relationship** | Diamond | Line connecting tables with cardinal endings |
| **Identifying Relationship** | Double Diamond | Solid line (Identifying relationship line) |
| **Attribute** | Ellipse connected by line | Text listed inside the Entity Box |
| **Key Attribute** | Ellipse with Underlined Text | Listed at top of box with `PK` tag |
| **Multi-Valued Attribute** | Double Ellipse | Separate entity table or multi-value annotation |
| **Derived Attribute** | Dashed Ellipse | Formatted or calculated property annotation |
| **Total Participation** | Double Line | Mandatory ring/bar (`\|\|` or `\|<`) |
| **1:N Cardinality** | `1` and `N` labels on lines | Single bar (`\|`) to Crow's Foot (`>\|`) |

---

## 6. Complete End-to-End Case Study: E-Commerce System Design

### A. Business Requirements
1. **Customers:** Identified by `customer_id`. Attributes include `first_name`, `last_name` (composite `name`), `email`, and multiple `phone_numbers`.
2. **Orders:** Identified by `order_id`. Has attributes `order_date`, `total_amount`, and a derived attribute `item_count`. Every order must belong to exactly one customer (1:N, Total participation on Order).
3. **Products:** Identified by `product_id`. Has attributes `product_name`, `unit_price`, and `stock_quantity`.
4. **Order Line Items:** Products and Orders share an M:N relationship (`ORDER_LINE`). Each line item records `quantity` and `subtotal_price`.

### B. Mapping ER Diagrams to Relational Tables (SQL Schema Blueprint)

#### Rule 1: Strong Entities become Tables
```sql
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE Products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    stock_quantity INT DEFAULT 0
);
```

#### Rule 2: 1:N Relationships place Foreign Key on the "Many" Side
```sql
CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) NOT NULL,
    customer_id INT NOT NULL, -- Foreign Key from Customers (Total Participation)
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
        ON DELETE RESTRICT
);
```

#### Rule 3: M:N Relationships become Junction / Associative Tables
```sql
CREATE TABLE Order_Items (
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (order_id, product_id), -- Composite Primary Key
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE RESTRICT
);
```

#### Rule 4: Multi-Valued Attributes become Separate Tables
```sql
CREATE TABLE Customer_Phones (
    customer_id INT NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    PRIMARY KEY (customer_id, phone_number),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE CASCADE
);
```

---

## 7. Summary & Best Practice Checklist

1. **Identify Entities First:** Focus on noun objects (`Customer`, `Product`) before worrying about attributes or queries.
2. **Normalize Attributes:** Ensure composite attributes are broken down and multi-valued attributes are separated into child tables.
3. **Verify Constraints:** Always verify both **Max Cardinality** (1:1, 1:N, M:N) and **Min Cardinality** (Partial vs. Total participation).
4. **Eliminate M:N Relationships in Relational Design:** Always convert M:N relationships into associative junction tables with composite primary keys during logical schema design.
