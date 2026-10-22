# Session Guide: Functional Dependencies, Attribute Closure & Key Discovery (ASCII Edition)

This guide covers the core principles of **Functional Dependencies (FDs)**, **Attribute Set Closure (X+)**, **Super Keys**, and **Candidate Key Discovery Algorithms** using clean, universal ASCII notation that renders on all platforms.

---

## 1. Introduction to Functional Dependencies (FDs)

### A. What is a Functional Dependency?
A **Functional Dependency (FD)** is a constraint between two sets of attributes in a relational database table. It describes how the value of one attribute (or group of attributes) uniquely determines the value of another attribute in the same row.

#### Formal Definition
Given a relation schema R, a functional dependency **X -> Y** (read as *"X uniquely determines Y"* or *"Y is functionally dependent on X"*) holds if for any two rows t1 and t2 in any valid instance of R:

```
If t1[X] == t2[X], then t1[Y] == t2[Y]
```

- **X (Left Side / Determinant):** The attribute or set of attributes that determines the value.
- **Y (Right Side / Dependent):** The attribute or set of attributes whose value is uniquely determined by X.

#### Real-World Examples
- **student_id -> student_name**: If two records have the same `student_id`, they MUST have the exact same `student_name`.
- **isbn -> book_title, author**: Every book with a given ISBN has the same title and author.
- **zip_code -> city, state**: A zip code strictly determines the city and state.

---

### B. Classification of Functional Dependencies

Functional dependencies are classified based on the relationship between the left-hand side (X) and right-hand side (Y) attributes:

| FD Type | Definition / Condition | Real-World Example |
| :--- | :--- | :--- |
| **Trivial FD** | The right-hand side is a subset of the left-hand side (Y is subset of X). Holds universally in any relation without checking data. | {student_id, student_name} -> student_id |
| **Non-Trivial FD** | The right-hand side is NOT a subset of the left-hand side. Contains at least one new attribute on the right. | student_id -> student_name |
| **Completely Non-Trivial FD** | The left and right attribute sets share NO attributes in common (Intersection of X and Y is EMPTY). | {emp_id, dept_id} -> salary |

---

### C. Practical Example & Table Verification

Consider the following **EMPLOYEES** dataset:

| emp_id | emp_name | dept_id | dept_name | zip_code | city |
| :---: | :--- | :---: | :--- | :---: | :--- |
| 101 | Alice | D1 | Engineering | 452001 | Indore |
| 102 | Bob | D2 | Marketing | 452001 | Indore |
| 103 | Charlie | D1 | Engineering | 400001 | Mumbai |
| 104 | Alice | D3 | Finance | 400001 | Mumbai |

#### Evaluating Functional Dependencies on Data:
1. **Does emp_id -> emp_name hold?**  
   - **YES.** Every unique `emp_id` maps to exactly one `emp_name`. (Notice `emp_id = 101` is Alice, `104` is also Alice, but they have distinct IDs, which is valid).
2. **Does emp_name -> emp_id hold?**  
   - **NO.** `Alice` maps to `101` in row 1 and `104` in row 4. Since equal X values lead to unequal Y values, `emp_name -> emp_id` **does NOT hold**.
3. **Does dept_id -> dept_name hold?**  
   - **YES.** `D1` always maps to `Engineering`, `D2` to `Marketing`, and `D3` to `Finance`.
4. **Does zip_code -> city hold?**  
   - **YES.** `452001` consistently maps to `Indore`, and `400001` consistently maps to `Mumbai`.

---

## 2. Fundamental Rules: Armstrong's Axioms

To infer new functional dependencies from a given set of dependencies (F), we use **Armstrong's Axioms**:

### Primary Axioms (Sound and Complete)
1. **Reflexivity Rule:** If Y is a subset of X, then **X -> Y** (Trivial dependency).
   - *Example:* {emp_id, email} -> email.
2. **Augmentation Rule:** If X -> Y, then **XZ -> YZ** for any attribute set Z.
   - *Example:* If emp_id -> emp_name, then {emp_id, dept_id} -> {emp_name, dept_id}.
3. **Transitivity Rule:** If X -> Y and Y -> Z, then **X -> Z**.
   - *Example:* If emp_id -> zip_code and zip_code -> city, then emp_id -> city.

### Secondary Derived Rules
- **Union Rule:** If X -> Y and X -> Z, then **X -> YZ**.
- **Decomposition Rule:** If X -> YZ, then **X -> Y** and **X -> Z**.
- **Pseudo-Transitivity Rule:** If X -> Y and WY -> Z, then **WX -> Z**.

---

## 3. Attribute Closure (X+) and Key Discovery

### A. What is Attribute Closure (X+)?
The **Attribute Closure** of a set of attributes X under a set of functional dependencies F, denoted as **X+** (or **X^+**), is the set of ALL attributes that can be functionally determined directly or indirectly by X.

#### Algorithm to Calculate Attribute Closure (X+):
1. **Initialize:** Set X+ = X.
2. **Iterate:** For each functional dependency A -> B in F:
   - If A is a subset of X+, then add B to X+ (X+ = X+ union B).
3. **Repeat:** Continue step 2 until X+ stops expanding (no new attributes can be added).

---

### B. Super Keys vs. Candidate Keys

```
+-----------------------------------------------------------------+
|                          SUPER KEYS                             |
|  Any set of attributes X whose closure contains ALL attributes  |
|  in the relation schema R  (X+ = R).                            |
|                                                                 |
|     +-----------------------------------------------------+     |
|     |                   CANDIDATE KEYS                    |     |
|     |  A Minimal Super Key (No proper subset is a        |     |
|     |  Super Key).                                        |     |
|     |                                                     |     |
|     |     +-----------------------------------------+     |     |
|     |     |              PRIMARY KEY                |     |     |
|     |     |  The Candidate Key chosen by the DB     |     |     |
|     |     |  designer to uniquely identify rows.    |     |     |
|     |     +-----------------------------------------+     |     |
|     +-----------------------------------------------------+     |
+-----------------------------------------------------------------+
```

- **Super Key:** Any set of attributes X such that **X+ = R** (closure contains all attributes of relation R).
- **Candidate Key:** A **minimal** Super Key. That is, X is a Candidate Key if:
  1. X+ = R (X is a Super Key).
  2. For any proper subset Y of X, Y+ != R (no smaller subset can determine all attributes).
- **Prime Attribute:** An attribute that is a member of **at least one Candidate Key**.
- **Non-Prime Attribute:** An attribute that is **not part of any Candidate Key**.

---

### C. Systematic Candidate Key Discovery Algorithm (L-R-M-N Method)

Given Relation R and FD Set F, divide all attributes of R into 4 distinct sets based on their positions in the FDs of F:

1. **L (Left Only):** Attributes present ONLY on the left side of FDs.  
   --> **MUST be present** in every Candidate Key!
2. **R (Right Only):** Attributes present ONLY on the right side of FDs.  
   --> Can **NEVER be present** in any Candidate Key!
3. **M (Middle / Both):** Attributes present on BOTH left and right sides.  
   --> May or may not be part of Candidate Keys (requires testing combinations).
4. **N (Neither):** Attributes NOT present in any FD.  
   --> **MUST be present** in every Candidate Key!

#### Core Discovery Steps:
- **Step 1:** Calculate the Core Set = **L union N**.
- **Step 2:** Find the closure **(L union N)+**.
  - If **(L union N)+ = R**, then **L union N** is the **ONLY Candidate Key**!
  - If **(L union N)+ != R**, combine **(L union N)** with attributes from **M** one by one (or in pairs) until finding all minimal attribute sets whose closure equals R.

---

## 4. Solved Step-by-Step Practice Problems

### Problem 1: Single Candidate Key Discovery
**Given:** Relation R(A, B, C, D, E) with FD Set F:
1. A -> B
2. B -> C
3. C -> D
4. D -> E

**Find:** All Candidate Keys of R.

#### Solution Walkthrough:
1. **Classify Attributes into L, R, M, N:**
   - **Left side attributes:** {A, B, C, D}
   - **Right side attributes:** {B, C, D, E}
   - **L (Left only):** {A} (present in A -> B, never on right)
   - **R (Right only):** {E} (present on right of D -> E, never on left)
   - **M (Both sides):** {B, C, D}
   - **N (Neither):** Empty {}
2. **Core Set = L union N = {A}**
3. **Calculate Attribute Closure (A+):**
   - Start: A+ = {A}
   - Apply A -> B: A+ = {A, B}
   - Apply B -> C: A+ = {A, B, C}
   - Apply C -> D: A+ = {A, B, C, D}
   - Apply D -> E: A+ = {A, B, C, D, E} = R
4. **Conclusion:** Since A+ = R and {A} has no smaller subset, **{A} is the UNIQUE Candidate Key**.

---

### Problem 2: Multiple Candidate Keys
**Given:** Relation R(A, B, C, D) with FD Set F:
1. A -> B
2. B -> C
3. C -> A

**Find:** All Candidate Keys and Total Number of Super Keys.

#### Solution Walkthrough:
1. **Classify Attributes:**
   - Attributes in FDs: {A, B, C}
   - **L (Left only):** None
   - **R (Right only):** None
   - **M (Both sides):** {A, B, C}
   - **N (Neither):** {D} (D is absent from all FDs)
2. **Core Set = L union N = {D}**
3. **Calculate Closure (D+):**
   - D+ = {D} != R (Cannot determine A, B, C). D alone is not a candidate key.
4. **Combine Core Set {D} with Middle Attributes {A, B, C}:**
   - **Test {A, D}:**
     - {A, D}+ = {A, D} --(A -> B)--> {A, B, D} --(B -> C)--> {A, B, C, D} = R.  
     --> **{A, D} is a Candidate Key!**
   - **Test {B, D}:**
     - {B, D}+ = {B, D} --(B -> C)--> {B, C, D} --(C -> A)--> {A, B, C, D} = R.  
     --> **{B, D} is a Candidate Key!**
   - **Test {C, D}:**
     - {C, D}+ = {C, D} --(C -> A)--> {A, C, D} --(A -> B)--> {A, B, C, D} = R.  
     --> **{C, D} is a Candidate Key!**
5. **Summary of Keys:**
   - **Candidate Keys:** {A, D}, {B, D}, {C, D}
   - **Prime Attributes:** {A, B, C, D} (All attributes are prime!)
   - **Non-Prime Attributes:** None

---

### Problem 3: Composite Determinant Key
**Given:** Relation R(A, B, C, D, E) with FD Set F:
1. AB -> C
2. C -> D
3. D -> E

**Find:** All Candidate Keys.

#### Solution Walkthrough:
1. **Classify Attributes:**
   - **L (Left only):** {A, B}
   - **R (Right only):** {E}
   - **M (Both sides):** {C, D}
   - **N (Neither):** None
2. **Core Set = L union N = {A, B}**
3. **Calculate Closure ({A, B}+):**
   - Start: {A, B}+ = {A, B}
   - Apply AB -> C: {A, B}+ = {A, B, C}
   - Apply C -> D: {A, B}+ = {A, B, C, D}
   - Apply D -> E: {A, B}+ = {A, B, C, D, E} = R
4. **Conclusion:** **{A, B} is the UNIQUE Candidate Key**.

---

## 5. In-Class Review Quiz & Self-Assessment

1. **Question:** What is the difference between a Trivial and Non-Trivial Functional Dependency?
   - *Answer:* In a Trivial FD (X -> Y), Y is a subset of X (e.g., {A, B} -> A). In a Non-Trivial FD, Y contains at least one attribute not in X (e.g., A -> B).

2. **Question:** If an attribute X does NOT appear anywhere in the set of functional dependencies F for relation R, can X be omitted from a Candidate Key?
   - *Answer:* NO. Attributes in set N (Neither) never appear in FDs, so they can never be determined by any other attribute. Therefore, X MUST be present in every Candidate Key.

3. **Question:** If A+ = {A, B, C} for relation R(A, B, C, D), is {A} a Super Key?
   - *Answer:* NO. Because A+ does not contain attribute D (A+ != R), {A} cannot determine all rows and is not a Super Key.
