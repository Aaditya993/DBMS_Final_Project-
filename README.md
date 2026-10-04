# Municipal Animal Birth Control Drive Database

## 1. Design Decisions & Rejected Alternatives
**Separation of Animals and Catch Operations**
*   **Decision:** Created a distinct `animals` table containing physical descriptions and a unique `identification_tag`, linked one-to-many with `catch_operations`.
*   **Alternative Rejected:** Storing physical descriptions and tags directly inside a single `catches` table.
*   **Reasoning:** If an animal is re-caught months later, a single-table design would record it as a completely new animal[cite: 32]. By separating them, we can link multiple distinct catch operations to a single unique `animal_id`, satisfying the reporting requirement to identify re-caught animals[cite: 32].

**Linking Treatments and Releases to Catch ID**
*   **Decision:** `treatments` and `releases` reference `catch_id` rather than `animal_id`.
*   **Alternative Rejected:** Linking treatments and releases directly to the `animal_id`.
*   **Reasoning:** Because animals have multiple lifecycles in the system (caught, treated, released, re-caught later)[cite: 32], linking a release to the animal makes it impossible to know *which* catch event that release belongs to. Chaining them sequentially maintains the timeline.

**Deriving "Recovery" Status**
*   **Decision:** No dedicated "recovery" table or boolean column was created.
*   **Alternative Rejected:** Building a `recovery_status` table or a `is_recovering` boolean on the animal record.
*   **Reasoning:** Storing a derived state creates update anomalies. Instead, recovery is accurately derived dynamically: if an animal has a record in `treatments` but no corresponding record in `releases`, they are currently in recovery[cite: 32].

---

## 2. ACID Properties Demonstrated in Context
Instead of textbook definitions, here is how the database enforces ACID properties[cite: 32]:
*   **Atomicity:** Demonstrated using the `BEGIN`, `SAVEPOINT`, and `ROLLBACK` transaction[cite: 32]. When an incorrect treatment date was entered, we rolled back to the savepoint. The database ensured that partial, incorrect states were never saved; the transaction was treated as an all-or-nothing unit.
*   **Consistency:** Enforced via Foreign Keys (e.g., `catch_ward_id REFERENCES wards(ward_id)`). The database physically prevents a coordinator from releasing an animal into a ward ID that does not exist in the geographic system.
*   **Isolation:** Demonstrated during our concurrency test[cite: 32]. By using `SELECT ... FOR UPDATE`, Session 1 locked the row, completely isolating its read/write process. Session 2 was forced to wait, preventing interference. 
*   **Durability:** Once the `COMMIT` command was issued at the end of the correct treatment logging, the record was saved to disk. Even if the server crashed a millisecond later, that treatment record is permanent.

---

## 3. Concurrency Anomaly & Fix
*   **The Anomaly:** We reproduced a Non-Repeatable Read / Lost Update scenario[cite: 32]. Session 1 read a treatment record to check vaccination status. Before Session 1 could act, Session 2 updated that exact record. When Session 1 looked again, the data had changed underneath them.
*   **The Fix:** We applied **Row-Level Locking** using `SELECT ... FOR UPDATE`[cite: 32]. 
*   **Justification:** While increasing the database's global isolation level to `SERIALIZABLE` would fix this, it creates severe performance bottlenecks for a busy day-to-day municipal system[cite: 32]. Staying on `Read Committed` but applying explicit pessimistic row-level locks on the exact record being updated prevents the anomaly while keeping the rest of the database highly concurrent and fast[cite: 32].

---

## 4. Query Explanations & Cost Analysis
*   **Query 1 & 4 (Aggregations):** Used standard `GROUP BY` to count daily vaccinations and weekly catches[cite: 32]. *Alternative:* Using correlated subqueries in the SELECT clause. *Cost:* Subqueries execute row-by-row, drastically increasing processing cost compared to a single hash aggregate pass.
*   **Query 2 (Re-caught Animals):** Used `GROUP BY` paired with `HAVING COUNT > 1`[cite: 32]. *Reasoning:* `WHERE` filters rows before aggregation, but `HAVING` filters the aggregated groups, which is required to find counts greater than 1.
*   **Query 3 (Recovery Status):** Used a `LEFT JOIN` on releases and filtered for `release_id IS NULL`[cite: 32]. *Alternative:* Using `NOT IN (SELECT catch_id FROM releases)`. *Cost:* `NOT IN` with subqueries performs poorly on large datasets compared to the optimized hash-join execution plan of a `LEFT JOIN` with a null check.