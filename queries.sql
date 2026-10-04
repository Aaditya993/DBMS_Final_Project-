



-- 1. How many animals were caught in each ward this week?
-- Uses standard JOIN and GROUP BY to aggregate counts.
SELECT 
    w.ward_name, 
    COUNT(c.catch_id) AS animals_caught 
FROM catch_operations c
JOIN wards w ON c.catch_ward_id = w.ward_id
WHERE c.catch_date >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY w.ward_name
ORDER BY animals_caught DESC;

-- 2. Which animals have been caught more than once?
-- Uses GROUP BY and HAVING to filter aggregated data.
SELECT 
    a.identification_tag, 
    a.species, 
    COUNT(c.catch_id) AS times_caught 
FROM catch_operations c
JOIN animals a ON c.animal_id = a.animal_id
GROUP BY a.animal_id, a.identification_tag, a.species
HAVING COUNT(c.catch_id) > 1;

-- 3. Which animals are still in recovery?
-- A "recovery" state means they have a treatment record, but NO release record.
-- We use a LEFT JOIN and check for NULL to find these specific records.
SELECT 
    a.identification_tag, 
    a.species,
    t.treatment_date
FROM treatments t
JOIN catch_operations c ON t.catch_id = c.catch_id
JOIN animals a ON c.animal_id = a.animal_id
LEFT JOIN releases r ON t.catch_id = r.catch_id
WHERE r.release_id IS NULL;

-- 4. How many vaccinations were given each day?
-- Filters for true booleans and groups by date.
SELECT 
    treatment_date, 
    COUNT(*) AS vaccinations_given 
FROM treatments
WHERE vaccination_given = TRUE
GROUP BY treatment_date
ORDER BY treatment_date;

-- 5. Which animals were released somewhere other than where they were caught?
-- Compares the catch_ward_id to the release_ward_id using multiple JOINs.
SELECT 
    a.identification_tag, 
    cw.ward_name AS caught_in, 
    rw.ward_name AS released_in
FROM releases r
JOIN catch_operations c ON r.catch_id = c.catch_id
JOIN animals a ON c.animal_id = a.animal_id
JOIN wards cw ON c.catch_ward_id = cw.ward_id
JOIN wards rw ON r.release_ward_id = rw.ward_id
WHERE c.catch_ward_id != r.release_ward_id;