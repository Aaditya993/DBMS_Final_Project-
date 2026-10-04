DROP TABLE IF EXISTS releases CASCADE;
DROP TABLE IF EXISTS treatments CASCADE;
DROP TABLE IF EXISTS catch_operations CASCADE;
DROP TABLE IF EXISTS animals CASCADE;
DROP TABLE IF EXISTS wards CASCADE;

CREATE TABLE wards (
    ward_id SERIAL PRIMARY KEY,
    ward_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE animals (
    animal_id SERIAL PRIMARY KEY,
    species VARCHAR(50) NOT NULL,
    gender VARCHAR(10),
    identification_tag VARCHAR(100) UNIQUE,
    description TEXT
);

CREATE TABLE catch_operations (
    catch_id SERIAL PRIMARY KEY,
    animal_id INT NOT NULL REFERENCES animals(animal_id),
    catch_ward_id INT NOT NULL REFERENCES wards(ward_id),
    catch_date DATE NOT NULL
);

CREATE TABLE treatments (
    treatment_id SERIAL PRIMARY KEY,
    catch_id INT NOT NULL REFERENCES catch_operations(catch_id),
    vaccination_given BOOLEAN DEFAULT FALSE,
    sterilisation_done BOOLEAN DEFAULT FALSE,
    treatment_date DATE NOT NULL
);

CREATE TABLE releases (
    release_id SERIAL PRIMARY KEY,
    catch_id INT UNIQUE NOT NULL REFERENCES catch_operations(catch_id),
    release_ward_id INT NOT NULL REFERENCES wards(ward_id),
    release_date DATE NOT NULL
);