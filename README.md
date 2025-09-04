# Netflix Data Cleaning & Preparation (SQL Project)

## Overview
This project demonstrates **data cleaning, normalization, and preparation for analysis** using SQL on the Netflix dataset.  
The dataset was imported into MySQL, cleaned, normalized into relational tables, and views were created for analysis.

## Tools Used
- MySQL
- SQL (Data Cleaning, Normalization, Views)

## Dataset
- Source: [Netflix Movies and TV Shows dataset on Kaggle](https://www.kaggle.com/shivamb/netflix-shows)
- Schema:
  - `show_id`, `type`, `title`, `director`, `cast`, `country`,  
    `date_added`, `release_year`, `rating`, `duration`, `listed_in`, `description`

## Key Steps
1. **Cleaning**
   - Removed duplicates
   - Handled missing values
   - Standardized dates
2. **Normalization**
   - Split dataset into `shows`, `genres`, `show_genre`
3. **Views**
   - Total shows by type
   - Shows added per year
   - Top genres

## Example Queries
- Find top 5 genres:
  ```sql
  SELECT * FROM top_genres LIMIT 5;
