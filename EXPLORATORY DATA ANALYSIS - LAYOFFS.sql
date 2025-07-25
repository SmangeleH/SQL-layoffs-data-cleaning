-- EXPLORATORY DATA ANALYSIS (2)

 -- 1. Total layoffs by country

SELECT country, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY country
ORDER BY total_layoffs DESC;
-- Visualization: Bar chart or map chart
-- Insight: Identify countries most affected by layoffs.

-- 2. Layoffs over time (monthly trend)

SELECT DATE_FORMAT(date, '%Y-%m') AS layoff_month, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY layoff_month
ORDER BY layoff_month;
-- Visualization: Line chart
-- Insight: Understand if layoffs are increasing or decreasing over time.

-- 3. Top industries by number of layoffs

SELECT industry, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY industry
ORDER BY total_layoffs DESC;
-- Visualization: Horizontal bar chart
-- Insight: See which industries are experiencing the most layoffs.

-- 4. Top 10 companies by number of layoffs

SELECT company, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY company
ORDER BY total_layoffs DESC
LIMIT 10;
-- Visualization: Bar chart
-- Insight: Spotlight companies with the most layoffs (TOP 10).

-- 5. Average percentage laid off by industry

SELECT industry, AVG(percentage_laid_off) AS AVG_percentag_laid_off
FROM layoffs_staging2
WHERE percentage_laid_off IS NOT NULL
GROUP BY industry
ORDER BY AVG_percentag_laid_off DESC;
-- Visualization: Column chart
-- Insight: Understand which industries lay off the largest share of their workforce.

-- 6. Layoffs by stage of company

SELECT stage, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY stage
ORDER BY total_layoffs DESC;
-- Visualization: Donut or bar chart
-- Insight: Explore if earlier- or later-stage companies are laying off more.

--  7. Layoffs by funding raised brackets

SELECT 
  CASE 
    WHEN funds_raised_millions < 50 THEN 'Under $50M'
    WHEN funds_raised_millions BETWEEN 50 AND 200 THEN '$50M–$200M'
    WHEN funds_raised_millions BETWEEN 201 AND 500 THEN '$201M–$500M'
    ELSE 'Over $500M'
  END AS funding_bracket,
  SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY funding_bracket
ORDER BY total_layoffs DESC;
-- Visualization: Stacked column chart
-- Insight: Evaluate how layoffs relate to company funding levels.

-- 8. % Laid off vs. Funding raised (scatter plot data)

SELECT company, percentage_laid_off, funds_raised_millions
FROM layoffs_staging2
WHERE percentage_laid_off IS NOT NULL AND funds_raised_millions IS NOT NULL;
-- Visualization: Scatter plot
-- Insight: Detect correlation between funding and percentage layoffs.

-- 9. Companies with high % layoffs but low total

SELECT company, total_laid_off, percentage_laid_off
FROM layoffs_staging2
WHERE percentage_laid_off > 0.2
ORDER BY total_laid_off ASC;
-- Visualization: Bubble chart
-- Insight: Small companies laying off a high portion of their staff.

-- 10. Missing or NULL data audit

SELECT 
  COUNT(*) AS total_rows,
  SUM(CASE WHEN percentage_laid_off IS NULL THEN 1 ELSE 0 END) AS missing_percentage,
  SUM(CASE WHEN industry IS NULL OR industry = '' THEN 1 ELSE 0 END) AS missing_industry
FROM layoffs_staging2;
-- Insight: Clean up data or flag missing values before deeper analysis.