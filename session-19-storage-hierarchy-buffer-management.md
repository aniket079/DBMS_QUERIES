# Session 19 Guide: Storage Hierarchy, Buffer Management & Disk Access Optimization

This reference and lecture guide covers the fundamental hardware and software mechanisms governing database storage, including the **Storage Hierarchy**, **Main Memory vs. Secondary Storage**, **Buffer Manager Architecture**, **Buffer Replacement Policies**, and **Disk Access Optimization Techniques**.

---

## 1. Storage Hierarchy Overview

Database Management Systems (DBMS) rely on a multi-tiered storage hierarchy to balance access speed, storage capacity, volatility, and unit cost.

```
+-------------------------------------------------------------------------+
| Level 0: CPU Registers & Cache (L1, L2, L3)                             |
| Access Time: < 1 - 10 ns  | Volatile | Highest Cost / Smallest Capacity   |
+-------------------------------------------------------------------------+
                                    |
+-------------------------------------------------------------------------+
| Level 1: Main Memory / RAM (Primary Storage)                            |
| Access Time: 10 - 100 ns  | Volatile | Byte-Addressable                 |
+-------------------------------------------------------------------------+
                                    |
+-------------------------------------------------------------------------+
| Level 2: Flash Memory / SSD & Magnetic Disks (Secondary Storage)       |
| Access Time: 50 us (SSD) - 10 ms (HDD) | Non-Volatile | Block-Addressable |
+-------------------------------------------------------------------------+
                                    |
+-------------------------------------------------------------------------+
| Level 3: Optical Disks, Tapes & Cloud Archives (Tertiary Storage)       |
| Access Time: Seconds to Minutes | Non-Volatile | Backup / Archival      |
+-------------------------------------------------------------------------+
```

### Comparative Storage Spectrum Matrix

| Storage Layer | Memory Type | Access Mode | Latency / Speed | Volatility | Cost per GB |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Primary** | RAM / DRAM | Byte-Addressable | ~10 - 100 ns | Volatile (Erased on power loss) | High |
| **Secondary** | SSD (NVM) / HDD | Block-Addressable | ~50 us (SSD) / 10 ms (HDD) | Non-Volatile (Persistent) | Medium / Low |
| **Tertiary** | Magnetic Tape / Tape Arrays | Sequential Stream | Seconds to Minutes | Non-Volatile | Lowest |

---

## 2. Main Memory (RAM) vs. Secondary Storage

### A. Main Memory (Primary Storage)
- **Fast & Volatile:** Direct access by CPU via memory bus (~100ns). All data is lost when system power fails.
- **Byte-Addressable:** Individual memory addresses (bytes) can be read or updated directly.
- **Role in DBMS:** Serves as the active working area holding execution stacks, query plans, locks, and the **Buffer Pool** (cached database pages).

### B. Secondary Storage (Disks & SSDs)
- **Slow & Non-Volatile:** Persistent storage preserving data across system restarts. Access is dramatically slower than RAM (10,000x to 100,000x slower on HDDs).
- **Block-Addressable:** Data cannot be read/written byte-by-byte; it must be transferred in fixed-size **Blocks or Pages** (typically 4KB, 8KB, or 16KB in MySQL InnoDB).

### C. Magnetic Hard Disk Drive (HDD) Mechanics
Magnetic disk access time is determined by three physical factors:
1. **Seek Time:** Time required to move the physical read/write arm to the target track (3 - 9 ms). *Largest bottleneck.*
2. **Rotational Latency:** Time spent waiting for the target disk sector to rotate under the head (~2 - 4 ms at 7200/10000 RPM).
3. **Transfer Time:** Time required to physically read/write the data block off the spinning platter.

$$\text{Total Disk Access Time} = \text{Seek Time} + \text{Rotational Latency} + \text{Transfer Time}$$

---

## 3. Buffer Manager Architecture

Because accessing disk is thousands of times slower than accessing RAM, a DBMS uses a **Buffer Manager** to cache disk pages in main memory.

```
+-------------------------------------------------------------------------+
|                           DBMS BUFFER MANAGER                           |
|                                                                         |
|  +-------------------------------------------------------------------+  |
|  |                 BUFFER POOL (RAM Array of Frames)                 |  |
|  | [ Frame 0 ]   [ Frame 1 ]   [ Frame 2 ]  ...  [ Frame N-1 ]       |  |
|  +-------------------------------------------------------------------+  |
|                                  ^                                      |
|                                  | Page Table (Hash Map)                |
|                                  v                                      |
|  +-------------------------------------------------------------------+  |
|  | Page ID -> Frame ID | Pin Count | Dirty Bit | Lock / Latch State   |  |
|  +-------------------------------------------------------------------+  |
+-------------------------------------------------------------------------+
```

### A. Core Control Metadata
For every frame in the Buffer Pool, the Buffer Manager maintains two crucial flags:
- **Pin Count (Fix Count):** Tracks the number of concurrent query threads currently reading or modifying the page. A page with `Pin Count > 0` is pinned and **cannot be evicted**.
- **Dirty Bit:** Set to `1` (True) if a query thread modified the page in RAM. A dirty page **must be written back to disk** before its frame can be reused for another page.

### B. Page Request Flow
1. **Query Engine Requests Page P:** The execution engine requests Page P from the Buffer Manager.
2. **Buffer Table Lookup:** The Buffer Manager checks if Page P is already present in RAM via the Page Table.
3. **Hit (In Buffer Pool):** Increment `Pin Count` of Page P, return pointer to query thread.
4. **Miss (Not in Buffer Pool):**
   - Locate an unpinned frame (`Pin Count == 0`).
   - If chosen frame contains a **Dirty Page**, write it to disk first.
   - Read Page P from disk into the frame.
   - Update Page Table (`Page P -> Frame ID`), set `Pin Count = 1`, set `Dirty Bit = 0`.
   - Return frame pointer to query thread.
5. **Unpin Phase:** Upon query completion, the query thread unpins Page P (`Pin Count` decremented by 1).

---

## 4. Buffer Replacement Policies

When the Buffer Pool is full and a page miss occurs, the Buffer Manager uses a **Replacement Policy** to select an unpinned frame to evict.

### A. Least Recently Used (LRU)
- **Mechanism:** Maintains a queue of unpinned frames ordered by time of last access. Evicts the page that has not been accessed for the longest time.
- **Flaw (Sequential Scan Pollution):** A large query performing a table scan reads many pages once, purging frequently accessed index/master pages from the buffer pool.

### B. Clock Replacement Algorithm (Second Chance)
- **Mechanism:** Approximates LRU with low overhead using a circular array of frames and a "Clock Hand" pointer.
- **Reference Bit:** Each frame has a 1-bit flag (`Ref Bit`).
  - When accessed, `Ref Bit = 1`.
  - On eviction search: If `Ref Bit == 1`, set `Ref Bit = 0` and advance hand. If `Ref Bit == 0` and `Pin Count == 0`, evict this frame!

### C. MySQL InnoDB Midpoint Insertion Strategy
- **Mechanism:** Solves LRU scan pollution by splitting the LRU list into two sublists: **Young Sublist** (58%) and **Old Sublist** (42%).
- Newly read pages are inserted at the **Midpoint** (head of Old Sublist) instead of the top of the queue. They are promoted to the Young Sublist only if accessed again after a time threshold (`innodb_old_blocks_time`).

---

## 5. Disk Access Optimization Techniques

DBMS engines implement specialized I/O strategies to minimize mechanical disk delays and optimize block transfers:

1. **Sequential Prefetching (Read-Ahead):** Anticipates future page reads based on sequential access patterns and speculatively loads adjacent blocks into RAM before requested.
2. **Clustering & Contiguous Allocation:** Stores related table records and index nodes on contiguous disk pages to convert costly random seek I/O into fast sequential read I/O.
3. **Write-Ahead Logging (WAL) & Asynchronous Flushing:** Instead of writing dirty pages to disk immediately during transactions, modifications are appended sequentially to a **Redo Log** on disk. Dirty buffer pool pages are flushed asynchronously in batches.
4. **Doublewrite Buffer (MySQL InnoDB):** Protects against partial page writes (torn pages) caused by power failure mid-write. InnoDB writes dirty pages to a contiguous disk region (`Doublewrite Buffer`) before writing to data files.
5. **Elevator Algorithm (SCAN Disk Scheduling):** Reorders pending I/O disk requests in cylinder order so the physical arm sweeps back and forth smoothly, eliminating erratic seeking.

---

## 6. Summary Comparison Table

| Optimization Technique | Primary Problem Solved | Mechanism / Strategy | Real-World DBMS Feature |
| :--- | :--- | :--- | :--- |
| **Buffer Pool** | Slow disk latency | Caches hot pages in RAM | MySQL InnoDB Buffer Pool |
| **Midpoint LRU** | Buffer pool scanning pollution | Splitting queue into Young/Old sublists | `innodb_old_blocks_pct` |
| **WAL / Redo Log** | Random write performance bottleneck | Sequential appending of transaction changes | InnoDB `ib_logfile` |
| **Doublewrite Buffer** | Partial/Torn page corruption on crash | Sequential two-phase page flushing | InnoDB Doublewrite Buffer |
| **Read-Ahead Prefetch** | Read latency during table scans | Asynchronous pre-loading of sequential pages | Linear/Random Read-Ahead |
