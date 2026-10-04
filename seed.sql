-- 1. Insert Wards (Locations)
INSERT INTO wards (ward_name) VALUES 
('North Ward'), ('South Ward'), ('East Ward'), ('West Ward'), ('Central Ward');

-- 2. Generate 50 Unique Animals
INSERT INTO animals (species, gender, identification_tag, description)
SELECT 
    CASE WHEN random() > 0.5 THEN 'Dog' ELSE 'Cat' END,
    CASE WHEN random() > 0.5 THEN 'Male' ELSE 'Female' END,
    'TAG-' || generate_series(1, 50),
    'Stray animal record ' || generate_series(1, 50);

-- 3. Generate 60 Catch Operations over the last 2 weeks
-- (60 catches for 50 animals ensures some animals are "re-caught" to satisfy the query requirement)
INSERT INTO catch_operations (animal_id, catch_ward_id, catch_date)
SELECT 
    (floor(random() * 50) + 1)::INT, 
    (floor(random() * 5) + 1)::INT,
    CURRENT_DATE - (floor(random() * 14))::INT
FROM generate_series(1, 60);

-- 4. Generate 50 Treatments
-- (Leaving 10 catches without treatment yet to simulate newly caught animals)
INSERT INTO treatments (catch_id, vaccination_given, sterilisation_done, treatment_date)
SELECT 
    catch_id,
    random() > 0.2, 
    random() > 0.3, 
    catch_date + 1 
FROM catch_operations
WHERE catch_id <= 50; 

-- 5. Generate 40 Releases
-- (Leaving 10 animals with a treatment but no release, meaning they are "still in recovery")
INSERT INTO releases (catch_id, release_ward_id, release_date)
SELECT 
    catch_id,
    (floor(random() * 5) + 1)::INT, 
    treatment_date + (floor(random() * 3) + 1)::INT 
FROM treatments
WHERE catch_id <= 40;