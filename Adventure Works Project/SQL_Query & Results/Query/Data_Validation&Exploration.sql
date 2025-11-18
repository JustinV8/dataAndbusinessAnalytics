-- Data Validation Queries

SELECT 'Product' AS TableName, COUNT(*) AS RowCount FROM Product
UNION ALL
SELECT 'Region', COUNT(*) FROM Region
UNION ALL
SELECT 'Reseller', COUNT(*) FROM Reseller
UNION ALL
SELECT 'Sales', COUNT(*) FROM Sales
UNION ALL
SELECT 'Salesperson', COUNT(*) FROM Salesperson
UNION ALL
SELECT 'SalespersonRegion', COUNT(*) FROM SalespersonRegion
UNION ALL
SELECT 'Targets', COUNT(*) FROM Targets;


-- 2. Check date range in Sales table
SELECT 
    MIN(OrderDate) AS FirstOrderDate,
    MAX(OrderDate) AS LastOrderDate,
    MAX(OrderDate) - MIN(OrderDate) AS DateRange_Days
FROM Sales;


-- 3. Check for NULL values in critical columns
SELECT 
    COUNT(*) AS TotalRows,
    COUNT(ProductKey) AS ProductKey_Count,
    COUNT(Sales) AS Sales_Count,
    COUNT(OrderDate) AS OrderDate_Count,
    COUNT(*) - COUNT(ProductKey) AS ProductKey_Nulls,
    COUNT(*) - COUNT(Sales) AS Sales_Nulls
FROM Sales;


-- 4. Preview data from each table
SELECT * FROM Product LIMIT 5;
SELECT * FROM Region LIMIT 5;
SELECT * FROM Reseller LIMIT 5;
SELECT * FROM Sales LIMIT 5;
SELECT * FROM Salesperson LIMIT 5;
SELECT * FROM SalespersonRegion LIMIT 5;
SELECT * FROM Targets LIMIT 5;


-- 5. Check for duplicate Sales Orders
SELECT 
    SalesOrderNumber, 
    COUNT(*) AS Occurrences
FROM Sales
GROUP BY SalesOrderNumber
HAVING COUNT(*) > 1
LIMIT 10;


-- 6. Verify foreign key relationships
SELECT 
    COUNT(DISTINCT s.ProductKey) AS Products_In_Sales,
    (SELECT COUNT(*) FROM Product) AS Total_Products
FROM Sales s;

SELECT 
    COUNT(DISTINCT s.ResellerKey) AS Resellers_In_Sales,
    (SELECT COUNT(*) FROM Reseller) AS Total_Resellers
FROM Sales s;