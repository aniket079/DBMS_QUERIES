# Session Guide: Transactions, ACID Properties & Transaction Control Language (TCL)

A crisp, high-density theoretical guide covering the core architecture of **Database Transactions**, **ACID Guarantees**, **Transaction Control Language (TCL)** commands (`COMMIT`, `ROLLBACK`, `SAVEPOINT`), and real-world industry implementations.

---

## 1. Transaction Concept

### What is a Database Transaction?
A **Transaction** is a logical, atomic unit of database execution that consists of one or more SQL statements (`SELECT`, `INSERT`, `UPDATE`, `DELETE`). It transitions a database from one consistent state to another.

### Transaction State Transition Lifecycle
```
                 +-------------------+
                 |      ACTIVE       |
                 +-------------------+
                   /               \
                  /                 \
                 v                   v
     +-------------------+   +-------------------+
     |  PARTIALLY COMMITTED | |      FAILED       |
     +-------------------+   +-------------------+
               |                       |
               v                       v
     +-------------------+   +-------------------+
     |     COMMITTED     |   |     ABORTED       |
     | (Changes Permanent)|   | (Changes Undone)  |
     +-------------------+   +-------------------+
```

- **ACTIVE:** Initial execution state where read/write operations occur.
- **PARTIALLY COMMITTED:** Final statement executes, but changes reside in volatile memory (Buffer Pool / Undo Logs).
- **COMMITTED:** Changes written to Redo Log (WAL) and disk. Transaction completes successfully.
- **FAILED:** Errors detected or system crash occurs during execution.
- **ABORTED:** `ROLLBACK` executed; database restored to state prior to transaction start.

---

## 2. ACID Properties (With Money-Transfer Walkthrough)

To maintain database integrity during concurrent access and hardware failures, transactions must satisfy the **ACID** properties.

### Scenario Baseline: $500 Transfer from Account A ($1000) to Account B ($200)

```sql
-- Step 1: Check Balance
SELECT balance FROM Accounts WHERE account_id = 'A'; -- Result: $1000

-- Step 2: Debit Account A
UPDATE Accounts SET balance = balance - 500 WHERE account_id = 'A';

-- Step 3: Credit Account B
UPDATE Accounts SET balance = balance + 500 WHERE account_id = 'B';
```

### Detailed Breakdown of ACID Guarantees

| Property | Core Definition | Enforcement Mechanism | Failure Risk Without Guarantee |
| :--- | :--- | :--- | :--- |
| **Atomicity** | "All-or-Nothing". Every statement succeeds or the entire transaction is reverted. | **Undo Logs** (Rollback Segment) | System crashes after Step 2. Account A loses $500, but Account B never receives it. |
| **Consistency** | Database moves from one valid state to another, maintaining all schema constraints. | **Schema Integrity Constraints** (`CHECK`, `FK`, `NOT NULL`) | Account A balance drops below $0 when $1000 transfer is attempted with $500 balance, violating `CHECK (balance >= 0)`. |
| **Isolation** | Concurrent transactions execute independently without mutual interference. | **Locks (2PL)** & **MVCC** (Multi-Version Concurrency Control) | Concurrent read between Step 2 and Step 3 sees Account A at $500 and Account B at $200 (total $700 instead of $1200). |
| **Durability** | Once committed, changes survive all subsequent hardware failures or power losses. | **Redo Logs** (Write-Ahead Logging / WAL) | Power failure immediately after `COMMIT`. Modifications are recovered from Redo Log on reboot. |

---

## 3. Transaction Control Language (TCL) Commands

TCL commands manage transaction boundaries and savepoints within relational database management systems.

### TCL Command Definitions
- **`START TRANSACTION` / `BEGIN`:** Explicitly marks the opening boundary of a transaction block.
- **`COMMIT`:** Finalizes all modifications made within the transaction, writing them permanently to disk and releasing locks.
- **`ROLLBACK`:** Reverts all uncommitted changes made since the transaction started or since a specific `SAVEPOINT`.
- **`SAVEPOINT <name>`:** Establishes a temporary named marker within a transaction to enable partial rollbacks.

### Bank Account Transfer Script with Error Handling & Savepoints

```sql
-- Start Explicit Transaction
START TRANSACTION;

-- Step 1: Deduct $500 from Account A
UPDATE Accounts 
SET balance = balance - 500 
WHERE account_id = 'ACC_A' AND balance >= 500;

-- Establish Savepoint after successful debit
SAVEPOINT debit_completed;

-- Step 2: Attempt Credit to Account B
UPDATE Accounts 
SET balance = balance + 500 
WHERE account_id = 'ACC_B';

-- Conditional Check: If Account B is invalid/frozen, partial rollback to savepoint
-- ROLLBACK TO SAVEPOINT debit_completed;

-- Step 3: Deduct Processing Fee ($5)
UPDATE Accounts 
SET balance = balance - 5 
WHERE account_id = 'ACC_A';

-- Finalize and persist all changes permanently
COMMIT;
```

---

## 4. Real-World Industry Examples

### 1. Banking & Payment Gateways (ATM / UPI / SWIFT)
- **Problem:** Ensuring money is never created or destroyed during network drops.
- **Solution:** Strict **Atomicity** and **Isolation (SERIALIZABLE / REPEATABLE READ)** using strict two-phase locking (2PL) so balance updates are thread-safe.

### 2. E-Commerce Inventory & Checkout (Amazon / Flipkart)
- **Problem:** Avoiding overselling limited product stock during flash sales.
- **Solution:** Explicit row-level locks (`SELECT ... FOR UPDATE`) during checkout. If payment fails or times out, a `ROLLBACK` restores stock quantity automatically.

### 3. Airline / Cinema Ticket Reservation System
- **Problem:** Preventing two users from booking the exact same seat simultaneously.
- **Solution:** Short-lived transactions with strict **Isolation**. A temporary `SAVEPOINT` holds the seat for 10 minutes during payment processing before issuing a final `COMMIT`.
