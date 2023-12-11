-- A query to identify the subcategories of products with consistently higher sales from 1998 to 2001 compared to the previous year
-- The YearlySubcategorySales specifically filters sales data for the years between 1998 and 2001
-- using WHERE EXTRACT(YEAR FROM s.time_id) BETWEEN 1998 AND 2001. 
-- This ensures that only sales data for these years are considered.
-- The SalesComparison calculates the total sales for each subcategory for each year
-- and uses the LAG function to obtain the total sales of the previous year. 
-- This is done within the partition of each subcategory, ordered by year.
-- The ConsistentlyGrowingSubcategories selects subcategories that had higher sales than the previous year (total_sales > COALESCE(previous_year_sales, 0))
-- and uses a GROUP BY clause combined with a HAVING COUNT(*) = 4. 
-- This ensures that only subcategories which showed growth in sales in all four years (1998 to 2001) are included.
-- The final SELECT statement extracts just the prod_subcategory from the ConsistentlyGrowingSubcategories ,
-- resulting in a dataset with a single column listing the identified subcategories.

WITH YearlySubcategorySales AS (
SELECT
	p.prod_subcategory,
	EXTRACT(YEAR
FROM
	s.time_id) AS sale_year,
	SUM(s.amount_sold) AS total_sales
FROM
	sh.sales s
JOIN
        sh.products p ON
	s.prod_id = p.prod_id
WHERE
	EXTRACT(YEAR
FROM
	s.time_id) BETWEEN 1998 AND 2001
GROUP BY
	p.prod_subcategory,
	sale_year
),
SalesComparison AS (
SELECT
	prod_subcategory,
	sale_year,
	total_sales,
	LAG(total_sales,
	1) OVER (PARTITION BY prod_subcategory
ORDER BY
	sale_year) AS previous_year_sales
FROM
	YearlySubcategorySales
),
ConsistentlyGrowingSubcategories AS (
SELECT
	prod_subcategory,
	COUNT(*) AS years_with_growth
FROM
	SalesComparison
WHERE
	total_sales > COALESCE(previous_year_sales,
	0)
GROUP BY
	prod_subcategory
HAVING
	COUNT(*) = 4
	 -- This ensures the subcategory had growth in all 4 years (1998 to 2001)
)
SELECT
	prod_subcategory
FROM
	ConsistentlyGrowingSubcategories
ORDER BY
	prod_subcategory;
