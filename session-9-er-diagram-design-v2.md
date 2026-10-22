# Session Guide: ER Diagram Design & Relationship Mapping (v2)

This reference and lecture guide covers the core principles of **Entity-Relationship (ER) Diagram Design**, focusing on relationship cardinalities (**1:1, 1:N, M:N**), visual diagramming notations (Chen Notation & Crow's Foot), relational table transformation rules, and practical hands-on modeling exercises including a complete **University Database ER Diagram Case Study**.

---

## 1. Fundamental ER Components Quick Review

An **Entity-Relationship Diagram (ERD)** models the logical structure of a database using three primary building blocks:

```
+-------------------+       +-------------------+       +-------------------+
|      ENTITY       |       |    RELATIONSHIP   |       |     ATTRIBUTE     |
+-------------------+       +-------------------+       +-------------------+
| Real-world object |       | Association among |       | Property/detail   |
| e.g., CUSTOMER    |       | entities (e.g.,   |       | e.g., email,      |
|                   |       | PLACES)           |       | customer_id       |
+-------------------+       +-------------------+       +-------------------+
```

---

## 2. Relationship Cardinalities with Visual Diagrams

### A. One-to-One Relationship (1:1)

#### Definition & Dynamics
In a **One-to-One (1:1)** relationship, an entity instance in Entity Set A is associated with **at most one** entity instance in Entity Set B, and vice versa.

#### Visual Diagram (Chen Notation)
```
+--------------+               1              +-----------+              1               +--------------+
|   EMPLOYEE   |------------------------------<  MANAGES  >------------------------------|  DEPARTMENT  |
+--------------+                              +-----------+                              +--------------+
| emp_id (PK)  |                                                                         | dept_id (PK) |
| emp_name     |                                                                         | dept_name    |
+--------------+                                                                         +--------------+
```

#### Visual Diagram (Crow's Foot Notation & Relational Schema)
```
+--------------------+                       +--------------------+
|      EMPLOYEE      |                       |     DEPARTMENT     |
+--------------------+                       +--------------------+
| PK | emp_id        |-------(1:1)-----------| PK | dept_id       |
|    | emp_name      |                       |    | dept_name     |
|    | salary        |                       | FK | manager_id(UQ)|
+--------------------+                       +--------------------+
```

#### SQL Transformation Rule (1:1)
Place the Foreign Key in **either** table (preferably the table with **Total Participation** to prevent `NULL` values) and add a **`UNIQUE` constraint** on the Foreign Key.

```sql
CREATE TABLE Employee (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,
    emp_name VARCHAR(100) NOT NULL
);

CREATE TABLE Department (
    dept_id INT PRIMARY KEY AUTO_INCREMENT,
    dept_name VARCHAR(100) NOT NULL,
    manager_id INT UNIQUE, -- Ensures 1:1 relationship
    FOREIGN KEY (manager_id) REFERENCES Employee(emp_id) ON DELETE SET NULL
);
```

---

### B. One-to-Many Relationship (1:N)

#### Definition & Dynamics
In a **One-to-Many (1:N)** relationship, an entity instance in Entity Set A can be associated with **zero, one, or many** entity instances in Entity Set B. However, an entity instance in Entity Set B is associated with **at most one** entity instance in Entity Set A.

#### Visual Diagram (Chen Notation)
```
+--------------+               1              +-----------+              N               +--------------+
|   CUSTOMER   |------------------------------<   PLACES  >------------------------------|    ORDERS    |
+--------------+                              +-----------+                              +--------------+
| customer_id  |                                                                         | order_id     |
| name         |                                                                         | order_date   |
+--------------+                                                                         +--------------+
```

#### Visual Diagram (Crow's Foot Notation)
```
+--------------------+                       +--------------------+
|      CUSTOMER      |                       |       ORDERS       |
+--------------------+                       +--------------------+
| PK | customer_id   |1                     N| PK | order_id      |
|    | first_name    ||--------------------|<|    | order_date    |
|    | email         |                       |    | total_amount  |
+--------------------+                       | FK | customer_id   |
                                             +--------------------+
```

#### SQL Transformation Rule (1:N)
Always place the Foreign Key on the **"Many" side (Entity B)** referencing the Primary Key of the "One" side (Entity A).

```sql
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) NOT NULL,
    customer_id INT NOT NULL, -- Foreign Key placed on the 'N' side
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE RESTRICT
);
```

---

### C. Many-to-Many Relationship (M:N)

#### Definition & Dynamics
In a **Many-to-Many (M:N)** relationship, an entity instance in Entity Set A can be associated with **many** entity instances in Entity Set B, and an entity instance in Entity Set B can be associated with **many** entity instances in Entity Set A.

#### Visual Diagram (Decomposition via Associative / Junction Table in Crow's Foot)
```
+------------------+             +----------------------+             +------------------+
|     STUDENT      |             |     ENROLLMENTS      |             |      COURSE      |
+------------------+             +----------------------+             +------------------+
| PK | student_id  |1           N| PK,FK1 | student_id  |N           1| PK | course_id   |
|    | name        ||-----------|<| PK,FK2 | course_id   |>-----------||    | title        |
|    | email       |             |        | grade        |            |    | credits      |
+------------------+             +----------------------+             +------------------+
```

#### SQL Transformation Rule (M:N)
Create a **third associative table (Junction Table)** containing Foreign Keys referencing both entities and a **Composite Primary Key** `(FK1, FK2)`.

```sql
CREATE TABLE Enrollments (
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    enrollment_date DATE DEFAULT (CURRENT_DATE),
    grade VARCHAR(2),
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES Courses(course_id) ON DELETE CASCADE
);
```

---

## 3. Comprehensive Feature Case Study: University Database System ER Diagram

### A. Business Rules & Requirements
1. **Departments:** Identified by `dept_id`. Has `dept_name`, `building`, and `budget`.
   - A Department is **headed/chaired** by exactly 1 Professor (**1:1**).
   - A Department **employs** many Professors (**1:N**).
   - A Department **offers** many Courses (**1:N**).
   - A Department **has primary majors** of many Students (**1:N**).
2. **Professors (Faculty):** Identified by `prof_id`. Has `first_name`, `last_name`, `email`, `salary`, and `hire_date`. Belongs to 1 Department.
   - A Professor **teaches** multiple Class Sections (**1:N**).
3. **Students:** Identified by `student_id`. Has `first_name`, `last_name`, `email`, `dob`, and `gpa`. Belongs to 1 major Department.
   - A Student **enrolls in** multiple Course Sections (**M:N**).
4. **Courses:** Identified by `course_id`. Has `course_code` (e.g., `'CS101'`), `title`, and `credits`.
   - A Course can have multiple scheduled **Sections** (**1:N**).
5. **Class Sections:** Identified by `section_id`. Represents a specific offering of a course in a given `semester` and `year` (e.g., Fall 2026).
   - Held in 1 Classroom (**N:1**).
   - Taught by 1 Professor (**N:1**).
6. **Classrooms:** Identified by `classroom_id`. Has `building_name`, `room_number`, and `capacity`. Hosts multiple Sections (**1:N**).

---

### B. Visual ER Diagram (Chen Notation Summary)

```
                       +-------------------+
                       |    DEPARTMENT     |
                       +-------------------+
                         /   |        \   \
                  1/    /1   |1        \1  \1
                  /    /     |          \   \
         < HEADS >   <EMPLOYS> <OFFERS> <MAJORS_IN>
             \        /      |            \   \
             1\      /N     N|           N \   \N
            +-----------+  +---------+   +---------+
            | PROFESSOR |  | COURSE  |   | STUDENT |
            +-----------+  +---------+   +---------+
                  |             |             |
                 1|            1|            M|
            < TEACHES >   < HAS_SEC >   < ENROLLS >
                  |             |             |
                 N\            /N            /N
                 +---------------+           |
                 | CLASS_SECTION |-----------+
                 +---------------+
                         |N
                    < HELD_IN >
                         |1
                   +-----------+
                   | CLASSROOM |
                   +-----------+
```

---

### C. Visual ER Diagram (Crow's Foot Relational Architecture)

```
+--------------------+                  +--------------------+
|    DEPARTMENTS     |                  |     PROFESSORS     |
+--------------------+                  +--------------------+
| PK | dept_id       |1----------------N| PK | prof_id       |
|    | dept_name     |  (Employs)       |    | first_name    |
|    | building      |                  |    | last_name     |
| FK | head_prof_id  |1---[1:1 Head]---1| FK | dept_id       |
+--------------------+                  +--------------------+
  1|               1|                     1|
   | (Offers)       | (Majors In)          | (Teaches)
  N|               N|                     N|
+--------------------+                  +--------------------+
|      COURSES       |                  |   CLASS_SECTIONS   |
+--------------------+                  +--------------------+
| PK | course_id     |1----------------N| PK | section_id    |
|    | course_code   |   (Has Sec)      | FK | course_id     |
|    | title         |                  | FK | prof_id       |
|    | credits       |                  | FK | classroom_id  |
| FK | dept_id       |                  |    | semester, year|
+--------------------+                  +--------------------+
                                          1|              N|
+--------------------+                     | (Hosts)       | (Enrolled)
|      STUDENTS      |                     |               |
+--------------------+                  +--+-----------------+
| PK | student_id    |                  |    CLASSROOMS      |
|    | first_name    |                  +--------------------+
|    | last_name     |                  | PK | classroom_id  |
| FK | dept_id       |                  |    | building_name |
+--------------------+                  |    | room_number   |
  1|                                    +--------------------+
   | (Enrolls)
  N|
+--------------------+
|    ENROLLMENTS     |
+--------------------+
| PK,FK1 | student_id|
| PK,FK2 | section_id|
|        | grade     |
+--------------------+
```

---

### D. Complete Production-Ready MySQL Schema Script (University DDL)

```sql
-- 1. Create Departments Table (Base table)
CREATE TABLE Departments (
    dept_id INT PRIMARY KEY AUTO_INCREMENT,
    dept_name VARCHAR(100) NOT NULL UNIQUE,
    building VARCHAR(50) NOT NULL,
    budget DECIMAL(12,2) DEFAULT 0.00,
    head_prof_id INT UNIQUE -- Circular reference handled via ALTER TABLE
);

-- 2. Create Professors Table
CREATE TABLE Professors (
    prof_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    salary DECIMAL(10,2) NOT NULL,
    hire_date DATE NOT NULL,
    dept_id INT NOT NULL,
    FOREIGN KEY (dept_id) REFERENCES Departments(dept_id) ON DELETE RESTRICT
);

-- Add 1:1 Foreign Key constraint for Department Head after Professors table exists
ALTER TABLE Departments 
ADD CONSTRAINT fk_dept_head 
FOREIGN KEY (head_prof_id) REFERENCES Professors(prof_id) ON DELETE SET NULL;

-- 3. Create Students Table
CREATE TABLE Students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    dob DATE NOT NULL,
    gpa DECIMAL(3,2) DEFAULT 0.00,
    dept_id INT NOT NULL, -- Major Department
    FOREIGN KEY (dept_id) REFERENCES Departments(dept_id) ON DELETE RESTRICT
);

-- 4. Create Courses Table
CREATE TABLE Courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_code VARCHAR(10) NOT NULL UNIQUE, -- e.g., 'CS101'
    title VARCHAR(100) NOT NULL,
    credits INT NOT NULL CHECK (credits > 0),
    dept_id INT NOT NULL,
    FOREIGN KEY (dept_id) REFERENCES Departments(dept_id) ON DELETE CASCADE
);

-- 5. Create Classrooms Table
CREATE TABLE Classrooms (
    classroom_id INT PRIMARY KEY AUTO_INCREMENT,
    building_name VARCHAR(50) NOT NULL,
    room_number VARCHAR(10) NOT NULL,
    capacity INT NOT NULL CHECK (capacity > 0),
    CONSTRAINT uq_building_room UNIQUE (building_name, room_number)
);

-- 6. Create Class_Sections Table
CREATE TABLE Class_Sections (
    section_id INT PRIMARY KEY AUTO_INCREMENT,
    course_id INT NOT NULL,
    prof_id INT NOT NULL,
    classroom_id INT NOT NULL,
    semester VARCHAR(10) NOT NULL, -- e.g., 'Fall', 'Spring'
    year INT NOT NULL, -- e.g., 2026
    FOREIGN KEY (course_id) REFERENCES Courses(course_id) ON DELETE CASCADE,
    FOREIGN KEY (prof_id) REFERENCES Professors(prof_id) ON DELETE RESTRICT,
    FOREIGN KEY (classroom_id) REFERENCES Classrooms(classroom_id) ON DELETE RESTRICT
);

-- 7. Create Enrollments Table (Associative Junction Table for M:N Student <-> Section)
CREATE TABLE Enrollments (
    student_id INT NOT NULL,
    section_id INT NOT NULL,
    enrollment_date DATE DEFAULT (CURRENT_DATE),
    grade VARCHAR(2), -- 'A', 'B+', etc.
    PRIMARY KEY (student_id, section_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (section_id) REFERENCES Class_Sections(section_id) ON DELETE CASCADE
);
```

---

## 4. Practical ER Diagram Practice Scenarios

### Practice Scenario 1: Library Management System
- **Entities:** `Book`, `Author`, `Member`
- **Relationships:** `Book` <-> `Author` (M:N via `Book_Authors`), `Member` <-> `Book` (M:N via `Book_Loans`).

### Practice Scenario 2: Hospital System
- **Entities:** `Patient`, `Doctor`, `Medical_History`
- **Relationships:** `Patient` <-> `Medical_History` (1:1), `Doctor` <-> `Patient` (M:N via `Appointments`).

---

## 5. Summary & Best Practice Checklist

1. **Identify Entities First:** Focus on noun objects before attributes or queries.
2. **Normalize Attributes:** Break down composite attributes and isolate multi-valued attributes into child tables.
3. **Verify Constraints:** Always check both Max Cardinality (1:1, 1:N, M:N) and Min Cardinality (Total vs. Partial participation).
4. **Decompose M:N Relationships:** Always convert M:N relationships into junction tables with composite primary keys during relational schema mapping.
