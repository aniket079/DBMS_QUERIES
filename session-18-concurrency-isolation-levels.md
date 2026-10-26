# Session 18: Database Isolation Levels, Read Anomalies & MySQL InnoDB Implementation

This reference and lecture guide covers **Concurrency Isolation Levels**, **Read Anomalies** (Dirty Read, Non-Repeatable Read, Phantom Read), the **ANSI SQL Matrix**, and **MySQL InnoDB Engine** implementation mechanics.

---

## 1. Concurrency Control & The Need for Isolation

When multiple database transactions execute concurrently, performance improves through parallel I/O and CPU utilization. However, without strict concurrency control, concurrent reads and writes on overlapping data records introduce **data integrity anomalies**.

The **Isolation** property of ACID ensures that the execution of a transaction is isolated from other concurrently executing transactions.

```
+-----------------------------------------------------------------------+
|                       THE 3 CONCURRENCY READ ANOMALIES                |
+-----------------------------------------------------------------------+
|  1. DIRTY READ          : Reading UNCOMMITTED data that gets rolled   |
|                           back.                                       |
|  2. NON-REPEATABLE READ : Reading COMMITTED modifications/deletions of|
|                           existing rows.                              |
|  3. PHANTOM READ        : Reading COMMITTED insertions of NEW rows   |
|                           in a range query.                           |
+-----------------------------------------------------------------------+
```

---

## 2. Detailed Breakdown of Read Anomalies

### A. Dirty Read

#### Definition
A **Dirty Read** occurs when Transaction T1 modifies a row, and Transaction T2 reads this modified row **before** T1 commits. If T1 subsequently issues a `ROLLBACK`, T2 has processed data that **never officially existed** in the database.

#### Step-by-Step Sequence Trace

```
Time   Transaction T1 (Transfer/Update)     Transaction T2 (Auditor)
----------------------------------------------------------------------------
t1     START TRANSACTION;                   
t2     UPDATE Accounts SET bal = 500        
       WHERE acc_id = 'A101'; 
       -- (Old bal = 1000, Uncommitted = 500)
t3                                          START TRANSACTION;
t4                                          SELECT bal FROM Accounts 
                                            WHERE acc_id = 'A101';
                                            -- Returns bal = 500 (DIRTY READ!)
t5     ROLLBACK; 
       -- (bal reverts to 1000 on disk)
t6                                          T2 computes reports based on 500!
                                            -- INVALID / CORRUPTED LOGIC
```

---

### B. Non-Repeatable Read (Fuzzy Read)

#### Definition
A **Non-Repeatable Read** occurs when Transaction T1 reads a row, and Transaction T2 subsequently **modifies (`UPDATE`) or deletes (`DELETE`)** that row and commits. When T1 re-reads the exact same row within the same transaction, it observes altered column values or finds the row deleted.

#### Step-by-Step Sequence Trace

```
Time   Transaction T1 (Reporting)           Transaction T2 (Customer Update)
----------------------------------------------------------------------------
t1     START TRANSACTION;                   
t2     SELECT bal FROM Accounts             
       WHERE acc_id = 'A101'; 
       -- Returns bal = 1000
t3                                          START TRANSACTION;
t4                                          UPDATE Accounts SET bal = 1500 
                                            WHERE acc_id = 'A101';
t5                                          COMMIT;
t6     SELECT bal FROM Accounts             
       WHERE acc_id = 'A101'; 
       -- Returns bal = 1500 (NON-REPEATABLE READ!)
       -- (Same row, different value within same T1)
```

---

### C. Phantom Read

#### Definition
A **Phantom Read** occurs when Transaction T1 executes a **range search query** (e.g., `WHERE balance > 500`), and Transaction T2 **inserts (`INSERT`)** new rows that satisfy T1's search predicate and commits. When T1 re-executes the range query, new "phantom" rows appear that were absent during the initial read.

#### Key Difference: Non-Repeatable Read vs. Phantom Read
- **Non-Repeatable Read:** Focuses on **existing rows** being modified (`UPDATE`) or removed (`DELETE`).
- **Phantom Read:** Focuses on **new rows** being added (`INSERT`) into a matching range.

#### Step-by-Step Sequence Trace

```
Time   Transaction T1 (High-Balance Audit)   Transaction T2 (New Account)
----------------------------------------------------------------------------
t1     START TRANSACTION;                   
t2     SELECT COUNT(*) FROM Accounts        
       WHERE balance > 5000; 
       -- Returns COUNT = 2 rows
t3                                          START TRANSACTION;
t4                                          INSERT INTO Accounts (acc_id, balance) 
                                            VALUES ('A103', 7000);
t5                                          COMMIT;
t6     SELECT COUNT(*) FROM Accounts        
       WHERE balance > 5000; 
       -- Returns COUNT = 3 rows (PHANTOM READ!)
       -- (New row inserted into matching range)
```

---

## 3. Standard ANSI SQL Isolation Levels Matrix

The ANSI SQL standard defines four transaction isolation levels based on which read anomalies they permit or prevent.

| Isolation Level | Dirty Read Permitted? | Non-Repeatable Read Permitted? | Phantom Read Permitted? | Primary Locking / Concurrency Mechanism |
| :--- | :---: | :---: | :---: | :--- |
| **READ UNCOMMITTED** | **YES** | **YES** | **YES** | Dirty reads allowed; no shared locks applied. |
| **READ COMMITTED** | **NO** | **YES** | **YES** | Reads only committed data. Fresh MVCC snapshot per query. |
| **REPEATABLE READ** | **NO** | **NO** | **YES*** *(ANSI)* | Consistent MVCC snapshot per transaction. *(MySQL prevents Phantoms too)* |
| **SERIALIZABLE** | **NO** | **NO** | **NO** | Strict 2-Phase Locking (2PL) or Range Locking. |

---

## 4. Isolation Levels in MySQL InnoDB Engine

### A. InnoDB Default Level & Architectural Design
- **MySQL InnoDB Default:** `REPEATABLE READ`.
- **Special InnoDB Guarantee:** Unlike standard ANSI SQL where `REPEATABLE READ` allows Phantom Reads, **MySQL InnoDB eliminates Phantom Reads in REPEATABLE READ mode** without sacrificing performance through two distinct mechanisms:

1. **For Non-Locking Consistent Reads (`SELECT ...`):**
   - Uses **Multi-Version Concurrency Control (MVCC)**.
   - The first `SELECT` statement in a transaction creates a **Read View (Snapshot)**. All subsequent `SELECT` queries read from this identical snapshot, regardless of concurrent commits.

2. **For Locking Reads (`SELECT ... FOR UPDATE`, `SELECT ... FOR SHARE`, `UPDATE`, `DELETE`):**
   - Uses **Next-Key Locking** (Record Lock + Gap Lock).
   - Locks the index records AND the "gaps" between index records, preventing other transactions from inserting new rows into the locked range.

---

### B. Summary of InnoDB Isolation Level Behaviors

#### 1. READ UNCOMMITTED
- Queries read the latest uncommitted row versions directly from buffer pool / undo logs.
- Fastest execution, zero lock overhead, but prone to Dirty Reads.

#### 2. READ COMMITTED
- Each individual `SELECT` statement generates its own **new MVCC Read View**.
- If Transaction T2 updates a row and commits between T1's first and second `SELECT`, T1 sees the update (prevents Dirty Reads, allows Non-Repeatable Reads).
- Widely used in high-throughput OLTP setups (e.g., Oracle/PostgreSQL default).

#### 3. REPEATABLE READ (MySQL Default)
- The **first `SELECT`** creates an MVCC Read View that persists for the **entire duration** of the transaction.
- Locking reads (`FOR UPDATE`) employ **Next-Key Gap Locks** to prevent phantom insertions.

#### 4. SERIALIZABLE
- Implicitly converts all plain `SELECT` statements into `SELECT ... FOR SHARE`.
- Transaction execution behaves as if strictly ordered sequentially. High lock contention, lowest throughput.

---

### C. Checking & Managing Isolation Levels in MySQL

#### Check Current Isolation Level:
```sql
-- Check session isolation level
SELECT @@transaction_isolation;

-- Check global isolation level
SELECT @@global.transaction_isolation;
```

#### Change Isolation Level:
```sql
-- Set isolation level for current session
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- Set isolation level globally for future connections
SET GLOBAL TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- Set isolation level for next transaction only
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
```

---

## 5. Comparative Summary Matrix

| Metric / Aspect | READ UNCOMMITTED | READ COMMITTED | REPEATABLE READ (MySQL) | SERIALIZABLE |
| :--- | :--- | :--- | :--- | :--- |
| **Dirty Read** | Allowed | Prevented | Prevented | Prevented |
| **Non-Repeatable Read** | Allowed | Allowed | Prevented | Prevented |
| **Phantom Read** | Allowed | Allowed | **Prevented** (via MVCC/Gap Lock) | Prevented |
| **MVCC Read View Scope** | None (reads raw memory) | Per Statement | Per Transaction | None (uses Shared Locks) |
| **Lock Type Used** | None | Short-term Shared Locks | Next-Key Gap Locks | Strict 2PL Shared/Exclusive |
| **Throughput & Speed** | Highest | Very High | High (Optimal Balance) | Lowest |
| **Primary Use Case** | Reporting on dirty data | High-concurrency web apps | General RDBMS / Default | Financial Ledgers |
