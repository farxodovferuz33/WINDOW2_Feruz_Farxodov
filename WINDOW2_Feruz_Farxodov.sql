WITH SubcategorySales AS (
  SELECT
    prod_subcategory,
    EXTRACT(YEAR FROM order_date) AS order_year,
    SUM(sales) AS total_sales
  FROM
    sales 
  WHERE
    EXTRACT(YEAR FROM order_date) BETWEEN 1998 AND 2001
  GROUP BY
    prod_subcategory, order_year
),
PreviousYearSales AS (
  SELECT
    prod_subcategory,
    EXTRACT(YEAR FROM order_date) AS order_year,
    SUM(sales) AS prev_year_sales
  FROM
    sales
  WHERE
    EXTRACT(YEAR FROM order_date) BETWEEN 1997 AND 2000
  GROUP BY
    prod_subcategory, order_year
)
SELECT DISTINCT
  s.prod_subcategory
FROM
  SubcategorySales s
JOIN
  PreviousYearSales p ON s.prod_subcategory = p.prod_subcategory
                      AND s.order_year = p.order_year + 1
WHERE
  s.total_sales > p.prev_year_sales;
