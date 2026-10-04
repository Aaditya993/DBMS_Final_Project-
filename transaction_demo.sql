BEGIN;

-- Step 1: Log a new catch operation for Animal #1
INSERT INTO catch_operations (animal_id, catch_ward_id, catch_date) 
VALUES (1, 3, CURRENT_DATE)
RETURNING catch_id;
-- (Assume this returns catch_id 61)

-- Set a Savepoint here so we don't lose the catch record if we make a mistake next
SAVEPOINT catch_logged;

-- Step 2: Make a mistake! Log a treatment with a date from 10 years ago by accident
INSERT INTO treatments (catch_id, vaccination_given, sterilisation_done, treatment_date) 
VALUES (61, TRUE, TRUE, '2014-01-01');

-- Whoops! We noticed the error. Roll back ONLY the treatment, keeping the catch operation intact
ROLLBACK TO SAVEPOINT catch_logged;

-- Step 3: Insert the correct treatment with today's date
INSERT INTO treatments (catch_id, vaccination_given, sterilisation_done, treatment_date) 
VALUES (61, TRUE, TRUE, CURRENT_DATE);

-- Save all the correct work to the database permanently
COMMIT;



BEGIN
 catch_id 
----------
       61
(1 row)

INSERT 0 1
SAVEPOINT
INSERT 0 1
ROLLBACK
INSERT 0 1
COMMIT