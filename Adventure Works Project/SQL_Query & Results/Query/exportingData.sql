-- Export Sales Summary
COPY (SELECT * FROM vw_SalesSummary) 
TO 'C:/Program Files/PostgreSQL/17/data/AdventureWorks_Exports/sales_summary.csv' 
WITH CSV HEADER;

-- Export Product Performance
COPY (SELECT * FROM vw_ProductPerformance) 
TO 'C:/Program Files/PostgreSQL/17/data/AdventureWorks_Exports/product_performance.csv' 
WITH CSV HEADER;

-- Export Salesperson Performance
COPY (SELECT * FROM vw_SalespersonPerformance) 
TO 'C:/Program Files/PostgreSQL/17/data/AdventureWorks_Exports/salesperson_performance.csv' 
WITH CSV HEADER;


-- Export Monthly Sales Trend
COPY (
    SELECT 
        TO_CHAR(OrderDate, 'YYYY-MM') AS YearMonth,
        ROUND(SUM(Sales)::numeric, 2) AS Revenue
    FROM Sales
    GROUP BY TO_CHAR(OrderDate, 'YYYY-MM')
    ORDER BY YearMonth
) TO 'C:/Program Files/PostgreSQL/17/data/AdventureWorks_Exports/monthly_sales.csv' 
WITH CSV HEADER;