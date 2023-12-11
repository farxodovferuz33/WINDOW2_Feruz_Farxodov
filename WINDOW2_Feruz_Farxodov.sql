

WITH YearSubCatSalers AS (
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
	YearSubCatSalers
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
)
SELECT
	prod_subcategory
FROM
	ConsistentlyGrowingSubcategories
ORDER BY
	prod_subcategory;
