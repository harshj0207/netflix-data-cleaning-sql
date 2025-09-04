CREATE DATABASE IF NOT EXISTS netflix_db;
USE netflix_db;

-- Handle missing directors
UPDATE raw_netflix
SET director = 'Unknown'
WHERE director IS NULL OR director = '';

-- Handle missing cast
UPDATE raw_netflix
SET cast = 'Not Specified'
WHERE cast IS NULL OR cast = '';

-- Remove duplicates based on title and type
DELETE t1 FROM raw_netflix t1
INNER JOIN raw_netflix t2
WHERE
    t1.show_id > t2.show_id
    AND t1.title = t2.title
    AND t1.type = t2.type;

-- Trim whitespace and convert date_added
UPDATE raw_netflix
SET date_added = STR_TO_DATE(TRIM(date_added), '%M %d, %Y')
WHERE date_added IS NOT NULL 
  AND STR_TO_DATE(TRIM(date_added), '%M %d, %Y') IS NOT NULL;

-- Converting the 'date_added' column from text (VARCHAR/TEXT) to DATE type
ALTER TABLE raw_netflix
MODIFY COLUMN date_added DATE;

-- ========================
-- Creating normalized tables
-- ========================

-- 1. Shows table
CREATE TABLE shows (
    show_id VARCHAR(20) PRIMARY KEY,
    title TEXT,
    type TEXT,
    director TEXT,
    release_year INT,
    rating TEXT,
    duration TEXT,
    country TEXT,
    date_added DATE,
    description TEXT
);

INSERT INTO shows (show_id, title, type, director, release_year, rating, duration, country, date_added, description)
SELECT show_id, title, type, director, release_year, rating, duration, country, date_added, description
FROM raw_netflix;

-- 2. Genres table
CREATE TABLE genres (
    genre_id INT AUTO_INCREMENT PRIMARY KEY,
    genre_name VARCHAR(100) UNIQUE
);

-- Temporary table to hold split genres
CREATE TABLE temp_genres (
    show_id VARCHAR(20),
    genre_name VARCHAR(100)
);

-- Populate temp_genres by splitting listed_in
INSERT INTO temp_genres (show_id, genre_name)
SELECT show_id, TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', n.n), ',', -1)) AS genre_name
FROM raw_netflix
JOIN (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5) n
WHERE listed_in IS NOT NULL AND listed_in <> '';

-- Insert unique genres into genres table
INSERT IGNORE INTO genres (genre_name)
SELECT DISTINCT genre_name FROM temp_genres;

-- 3. Show_Genre table (many-to-many)
CREATE TABLE show_genre (
    show_id VARCHAR(20),
    genre_id INT,
    FOREIGN KEY (show_id) REFERENCES shows(show_id),
    FOREIGN KEY (genre_id) REFERENCES genres(genre_id)
);

-- Populate show_genre by linking shows with genre IDs
INSERT INTO show_genre (show_id, genre_id)
SELECT t.show_id, g.genre_id
FROM temp_genres t
JOIN genres g ON t.genre_name = g.genre_name;

-- ========================
-- Views
-- ========================

-- Total shows per type
CREATE OR REPLACE VIEW total_shows_by_type AS
SELECT type, COUNT(*) AS total
FROM shows
GROUP BY type;

-- Shows added per year
CREATE OR REPLACE VIEW shows_added_per_year AS
SELECT YEAR(date_added) AS year, COUNT(*) AS total
FROM shows
WHERE date_added IS NOT NULL
GROUP BY YEAR(date_added);

-- Top genres with most shows
CREATE OR REPLACE VIEW top_genres AS
SELECT g.genre_name, COUNT(sg.show_id) AS total
FROM genres g
JOIN show_genre sg ON g.genre_id = sg.genre_id
GROUP BY g.genre_name
ORDER BY total DESC;
