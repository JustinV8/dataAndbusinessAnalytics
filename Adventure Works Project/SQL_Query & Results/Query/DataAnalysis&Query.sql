--Total Sales Overview
SELECT 
    COUNT(DISTINCT SalesOrderNumber) AS TotalOrders,
    SUM(Quantity) AS TotalQuantity,
    ROUND(SUM(Sales)::numeric, 2) AS TotalRevenue,
    ROUND(AVG(Sales)::numeric, 2) AS AvgOrderValue
FROM Sales;


-- Sales by Year and Quarter
SELECT 
    EXTRACT(YEAR FROM OrderDate) AS Year,
    EXTRACT(QUARTER FROM OrderDate) AS Quarter,
    COUNT(DISTINCT SalesOrderNumber) AS Orders,
    SUM(Quantity) AS Quantity,
    ROUND(SUM(Sales)::numeric, 2) AS Revenue
FROM Sales
GROUP BY EXTRACT(YEAR FROM OrderDate), EXTRACT(QUARTER FROM OrderDate)
ORDER BY Year, Quarter;


-- Monthly Sales Trend
SELECT 
    TO_CHAR(OrderDate, 'YYYY-MM') AS YearMonth,
    COUNT(DISTINCT SalesOrderNumber) AS Orders,
    ROUND(SUM(Sales)::numeric, 2) AS Revenue
FROM Sales
GROUP BY TO_CHAR(OrderDate, 'YYYY-MM')
ORDER BY YearMonth;


-- Year-over-Year Growth Analysis
WITH YearlySales AS (
    SELECT 
        EXTRACT(YEAR FROM OrderDate) AS Year,
        SUM(Sales) AS YearlyRevenue
    FROM Sales
    GROUP BY EXTRACT(YEAR FROM OrderDate)
)
SELECT 
    Year,
    ROUND(YearlyRevenue::numeric, 2) AS Revenue,
    ROUND(LAG(YearlyRevenue) OVER (ORDER BY Year)::numeric, 2) AS PreviousYearRevenue,
    ROUND(((YearlyRevenue - LAG(YearlyRevenue) OVER (ORDER BY Year)) / 
           LAG(YearlyRevenue) OVER (ORDER BY Year) * 100)::numeric, 2) AS GrowthPercentage
FROM YearlySales
ORDER BY Year;


-- Top 10 Products by Revenue
SELECT 
    p.Product,
    p.Category,
    p.Subcategory,
    SUM(s.Quantity) AS TotalQuantity,
    ROUND(SUM(s.Sales)::numeric, 2) AS TotalRevenue
FROM Sales s
JOIN Product p ON s.ProductKey = p.ProductKey
GROUP BY p.Product, p.Category, p.Subcategory
ORDER BY TotalRevenue DESC
LIMIT 10;


-- Product Profitability Analysis 
SELECT 
    p.Product,
    p.Category,
    SUM(s.Quantity) AS TotalQuantity,
    ROUND(SUM(s.Sales)::numeric, 2) AS TotalRevenue,
    ROUND(SUM(s.Cost)::numeric, 2) AS TotalCost,
    ROUND((SUM(s.Sales) - SUM(s.Cost))::numeric, 2) AS TotalProfit,
    ROUND((((SUM(s.Sales) - SUM(s.Cost)) / SUM(s.Sales)) * 100)::numeric, 2) AS ProfitMarginPct
FROM Sales s
JOIN Product p ON s.ProductKey = p.ProductKey
GROUP BY p.Product, p.Category
ORDER BY TotalProfit DESC
LIMIT 10;


-- Sales by Product Category
SELECT 
    p.Category,
    COUNT(DISTINCT s.SalesOrderNumber) AS Orders,
    SUM(s.Quantity) AS TotalQuantity,
    ROUND(SUM(s.Sales)::numeric, 2) AS TotalRevenue,
    ROUND(AVG(s.Sales)::numeric, 2) AS AvgOrderValue
FROM Sales s
JOIN Product p ON s.ProductKey = p.ProductKey
GROUP BY p.Category
ORDER BY TotalRevenue DESC;


-- Sales by Product Subcategory
SELECT 
    p.Category,
    p.Subcategory,
    COUNT(DISTINCT s.SalesOrderNumber) AS Orders,
    ROUND(SUM(s.Sales)::numeric, 2) AS TotalRevenue
FROM Sales s
JOIN Product p ON s.ProductKey = p.ProductKey
GROUP BY p.Category, p.Subcategory
ORDER BY p.Category, TotalRevenue DESC;



--Product Performance by Color
SELECT 
    p.Color,
    COUNT(DISTINCT p.ProductKey) AS ProductCount,
    SUM(s.Quantity) AS TotalQuantity,
    ROUND(SUM(s.Sales)::numeric, 2) AS TotalRevenue
FROM Sales s
JOIN Product p ON s.ProductKey = p.ProductKey
WHERE p.Color IS NOT NULL
GROUP BY p.Color
ORDER BY TotalRevenue DESC;


--Sales by Region
SELECT 
    r.Region,
    r.Country,
    r.GroupName,
    COUNT(DISTINCT s.SalesOrderNumber) AS Orders,
    ROUND(SUM(s.Sales)::numeric, 2) AS TotalRevenue
FROM Sales s
JOIN Region r ON s.SalesTerritoryKey = r.SalesTerritoryKey
GROUP BY r.Region, r.Country, r.GroupName
ORDER BY TotalRevenue DESC;


-- Top Countries by Revenue
SELECT 
    r.Country,
    COUNT(DISTINCT s.SalesOrderNumber) AS Orders,
    SUM(s.Quantity) AS TotalQuantity,
    ROUND(SUM(s.Sales)::numeric, 2) AS TotalRevenue
FROM Sales s
JOIN Region r ON s.SalesTerritoryKey = r.SalesTerritoryKey
GROUP BY r.Country
ORDER BY TotalRevenue DESC;


-- Regional Performance by Product Category
SELECT 
    r.Region,
    p.Category,
    ROUND(SUM(s.Sales)::numeric, 2) AS TotalRevenue
FROM Sales s
JOIN Region r ON s.SalesTerritoryKey = r.SalesTerritoryKey
JOIN Product p ON s.ProductKey = p.ProductKey
GROUP BY r.Region, p.Category
ORDER BY r.Region, TotalRevenue DESC;


--Top 10 Resellers by Revenue
SELECT 
    res.Reseller,
    res.BusinessType,
    res.City,
    res.CountryRegion,
    COUNT(DISTINCT s.SalesOrderNumber) AS Orders,
    ROUND(SUM(s.Sales)::numeric, 2) AS TotalRevenue
FROM Sales s
JOIN Reseller res ON s.ResellerKey = res.ResellerKey
GROUP BY res.Reseller, res.BusinessType, res.City, res.CountryRegion
ORDER BY TotalRevenue DESC
LIMIT 10;


--Sales by Business Type
SELECT 
    res.BusinessType,
    COUNT(DISTINCT res.ResellerKey) AS ResellerCount,
    COUNT(DISTINCT s.SalesOrderNumber) AS Orders,
    ROUND(SUM(s.Sales)::numeric, 2) AS TotalRevenue,
    ROUND(AVG(s.Sales)::numeric, 2) AS AvgOrderValue
FROM Sales s
JOIN Reseller res ON s.ResellerKey = res.ResellerKey
GROUP BY res.BusinessType
ORDER BY TotalRevenue DESC;


--Reseller Distribution by Country
SELECT 
    res.CountryRegion,
    COUNT(DISTINCT res.ResellerKey) AS ResellerCount,
    ROUND(SUM(s.Sales)::numeric, 2) AS TotalRevenue
FROM Sales s
JOIN Reseller res ON s.ResellerKey = res.ResellerKey
GROUP BY res.CountryRegion
ORDER BY TotalRevenue DESC;



-- Top 10 Salespeople by Revenue
SELECT 
    sp.Salesperson,
    sp.Title,
    COUNT(DISTINCT s.SalesOrderNumber) AS Orders,
    SUM(s.Quantity) AS TotalQuantity,
    ROUND(SUM(s.Sales)::numeric, 2) AS TotalRevenue,
    ROUND(AVG(s.Sales)::numeric, 2) AS AvgOrderValue
FROM Sales s
JOIN Salesperson sp ON s.EmployeeKey = sp.EmployeeKey
GROUP BY sp.Salesperson, sp.Title
ORDER BY TotalRevenue DESC
LIMIT 10;



-- Salesperson Target Achievement Analysis
WITH SalesPerformance AS (
    SELECT 
        sp.EmployeeID,
        sp.Salesperson,
        EXTRACT(YEAR FROM s.OrderDate) AS Year,
        EXTRACT(MONTH FROM s.OrderDate) AS Month,
        SUM(s.Sales) AS ActualSales
    FROM Sales s
    JOIN Salesperson sp ON s.EmployeeKey = sp.EmployeeKey
    GROUP BY sp.EmployeeID, sp.Salesperson, EXTRACT(YEAR FROM s.OrderDate), EXTRACT(MONTH FROM s.OrderDate)
)
SELECT 
    sp.Salesperson,
    EXTRACT(YEAR FROM t.TargetMonth) AS Year,
    EXTRACT(MONTH FROM t.TargetMonth) AS Month,
    ROUND(COALESCE(sp.ActualSales, 0)::numeric, 2) AS ActualSales,
    ROUND(t.Target::numeric, 2) AS Target,
    ROUND((COALESCE(sp.ActualSales, 0) - t.Target)::numeric, 2) AS Variance,
    ROUND(((COALESCE(sp.ActualSales, 0) / t.Target) * 100)::numeric, 2) AS AchievementPct
FROM Targets t
LEFT JOIN SalesPerformance sp ON t.EmployeeID = sp.EmployeeID 
    AND EXTRACT(YEAR FROM t.TargetMonth) = sp.Year 
    AND EXTRACT(MONTH FROM t.TargetMonth) = sp.Month
ORDER BY Year, Month, Salesperson;


-- Salesperson Performance by Region
SELECT 
    sp.Salesperson,
    r.Region,
    r.Country,
    COUNT(DISTINCT s.SalesOrderNumber) AS Orders,
    ROUND(SUM(s.Sales)::numeric, 2) AS TotalRevenue
FROM Sales s
JOIN Salesperson sp ON s.EmployeeKey = sp.EmployeeKey
JOIN Region r ON s.SalesTerritoryKey = r.SalesTerritoryKey
GROUP BY sp.Salesperson, r.Region, r.Country
ORDER BY TotalRevenue DESC;



-- Product Sales Ranking by Category 
SELECT 
    p.Category,
    p.Product,
    ROUND(SUM(s.Sales)::numeric, 2) AS TotalRevenue,
    RANK() OVER (PARTITION BY p.Category ORDER BY SUM(s.Sales) DESC) AS RankInCategory
FROM Sales s
JOIN Product p ON s.ProductKey = p.ProductKey
GROUP BY p.Category, p.Product
ORDER BY p.Category, RankInCategory
LIMIT 30;


-- Running Total of Sales Over Time
SELECT 
    OrderDate,
    ROUND(SUM(Sales)::numeric, 2) AS DailySales,
    ROUND(SUM(SUM(Sales)) OVER (ORDER BY OrderDate)::numeric, 2) AS RunningTotal
FROM Sales
GROUP BY OrderDate
ORDER BY OrderDate;


-- 3-Month Rolling Average Sales
WITH MonthlySales AS (
    SELECT 
        DATE_TRUNC('month', OrderDate) AS Month,
        SUM(Sales) AS MonthlySales
    FROM Sales
    GROUP BY DATE_TRUNC('month', OrderDate)
)
SELECT 
    Month,
    ROUND(MonthlySales::numeric, 2) AS MonthlySales,
    ROUND(AVG(MonthlySales) OVER (
        ORDER BY Month 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    )::numeric, 2) AS RollingAvg3Months
FROM MonthlySales
ORDER BY Month;



--Customer Cohort Analysis
WITH FirstPurchase AS (
    SELECT 
        ResellerKey,
        MIN(OrderDate) AS FirstOrderDate
    FROM Sales
    GROUP BY ResellerKey
)
SELECT 
    DATE_TRUNC('month', fp.FirstOrderDate) AS CohortMonth,
    COUNT(DISTINCT fp.ResellerKey) AS NewResellers,
    ROUND(SUM(s.Sales)::numeric, 2) AS TotalRevenue
FROM FirstPurchase fp
JOIN Sales s ON fp.ResellerKey = s.ResellerKey
WHERE s.OrderDate = fp.FirstOrderDate
GROUP BY DATE_TRUNC('month', fp.FirstOrderDate)
ORDER BY CohortMonth;



-- ABC Analysis - Product Classification by Revenue
WITH ProductRevenue AS (
    SELECT 
        p.Product,
        SUM(s.Sales) AS TotalRevenue
    FROM Sales s
    JOIN Product p ON s.ProductKey = p.ProductKey
    GROUP BY p.Product
),
ProductWithPercentage AS (
    SELECT 
        Product,
        TotalRevenue,
        (TotalRevenue / SUM(TotalRevenue) OVER ()) * 100 AS RevenuePct,
        SUM((TotalRevenue / SUM(TotalRevenue) OVER ()) * 100) OVER (ORDER BY TotalRevenue DESC) AS CumulativePct
    FROM ProductRevenue
)
SELECT 
    Product,
    ROUND(TotalRevenue::numeric, 2) AS TotalRevenue,
    ROUND(RevenuePct::numeric, 2) AS RevenuePct,
    ROUND(CumulativePct::numeric, 2) AS CumulativePct,
    CASE 
        WHEN CumulativePct <= 70 THEN 'A - High Value'
        WHEN CumulativePct <= 90 THEN 'B - Medium Value'
        ELSE 'C - Low Value'
    END AS ABC_Classification
FROM ProductWithPercentage
ORDER BY TotalRevenue DESC;