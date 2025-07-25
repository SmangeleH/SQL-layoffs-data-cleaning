-- Layoffs Data Cleaning (SQL - MySQL Workbench)
-- Purpose: Prepare the raw layoffs data for analysis by removing duplicates, standardizing text, handling null/blank values, and converting data types.

-- STEP 1: CREATING A STAGING TABLE 

-- Create a staging table to work on the data safely
CREATE TABLE layoffs_staging LIKE layoffs;

-- Insert the raw data into the staging table
INSERT INTO layoffs_staging
SELECT *
FROM layoffs;

--  Step 2: Add Row Numbers for Duplicate Identification

-- Use ROW_NUMBER to uniquely identify duplicates (no unique ID exists in the original table)
SELECT *, ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- Step 3: Create Second Staging Table for Deletion
-- Create a second staging table with an extra column for row numbers
CREATE TABLE layoffs_staging2 (
  company TEXT,
  location TEXT,
  industry TEXT,
  total_laid_off INT,
  percentage_laid_off TEXT,
  `date` TEXT,
  stage TEXT,
  country TEXT,
  funds_raised_millions INT,
  row_num INT
);

INSERT INTO layoffs_staging2 (
  company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, row_num
)
SELECT 
  company,
  location,
  industry,
  total_laid_off,
  percentage_laid_off,
  `date`,
  stage,
  country,
  funds_raised_millions,
  ROW_NUMBER() OVER (
  PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, funds_raised_millions
) AS row_num
FROM layoffs_staging;


-- SPET 4: REMOVE DUPLICATE RECORDS 
-- Check for duplicate rows
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

-- Delete duplicates (keep only row_num = 1)
DELETE FROM layoffs_staging2
WHERE row_num > 1;

-- Step 5: Standardize Company Names
-- Remove leading/trailing spaces from company names
UPDATE layoffs_staging2
SET company = TRIM(company);

-- Step 6: Standardize Industry Names
-- Example: Replace variations like 'Crypto Currency' with 'Crypto'
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Step 7: Clean Country Column
-- Remove trailing periods from country names (e.g., 'United States.')
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';


-- Step 8: Convert date Column from TEXT to DATE
-- Convert string to date format (MM/DD/YYYY)
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Change the column data type to DATE
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Step 9: Handle NULLs and Blank Values
-- Convert blank strings to NULLs
UPDATE layoffs_staging2 SET company = NULL WHERE company = '';
UPDATE layoffs_staging2 SET location = NULL WHERE location = '';
UPDATE layoffs_staging2 SET industry = NULL WHERE industry = '';
UPDATE layoffs_staging2 SET total_laid_off = NULL WHERE total_laid_off = '';
UPDATE layoffs_staging2 SET percentage_laid_off = NULL WHERE percentage_laid_off = '';
UPDATE layoffs_staging2 SET `date` = NULL WHERE `date` = '';
UPDATE layoffs_staging2 SET stage = NULL WHERE stage = '';
UPDATE layoffs_staging2 SET country = NULL WHERE country = '';
UPDATE layoffs_staging2 SET funds_raised_millions = NULL WHERE funds_raised_millions = '';

--  Step 10: Impute Missing Industry Data Using JOIN
-- Update NULL industry values using matching company entries that have valid industries
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2 ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

-- Step 11: Final Cleanup – Remove Rows with Insufficient Data
-- Delete rows where both total_laid_off and percentage_laid_off are missing
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

--  Step 12: Drop Helper Column
-- Remove the row_num column used for duplicate tracking
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;



