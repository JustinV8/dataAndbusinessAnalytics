-- View 1: Sales Summary View (UPDATED)
CREATE OR REPLACE VIEW vw_SalesSummary AS
SELECT 
    s.SalesOrderNumber,
    s.OrderDate,
    EXTRACT(YEAR FROM s.OrderDate) AS Year,
    EXTRACT(QUARTER FROM s.OrderDate) AS Quarter,
    EXTRACT(MONTH FROM s.OrderDate) AS Month,
    p.Product,
    p.Category,
    p.Subcategory,
    p.Color,
    r.Region,
    r.Country,
    res.Reseller,
    res.BusinessType,
    sp.Salesperson,
    s.Quantity,
    s.UnitPrice,
    s.Sales,
    s.Cost,
    (s.Sales - s.Cost) AS Profit  -- UPDATED
FROM Sales s
JOIN Product p ON s.ProductKey = p.ProductKey
JOIN Region r ON s.SalesTerritoryKey = r.SalesTerritoryKey
JOIN Reseller res ON s.ResellerKey = res.ResellerKey
JOIN Salesperson sp ON s.EmployeeKey = sp.EmployeeKey;


-- View 2: Product Performance View
CREATE OR REPLACE VIEW vw_ProductPerformance AS
SELECT 
    p.ProductKey,
    p.Product,
    p.Category,
    p.Subcategory,
    p.Color,
    p.StandardCost,
    COUNT(DISTINCT s.SalesOrderNumber) AS TotalOrders,
    SUM(s.Quantity) AS TotalQuantity,
    ROUND(SUM(s.Sales)::numeric, 2) AS TotalRevenue,
    ROUND(SUM(s.Quantity * p.StandardCost)::numeric, 2) AS TotalCost,
    ROUND((SUM(s.Sales) - SUM(s.Quantity * p.StandardCost))::numeric, 2) AS TotalProfit,
    ROUND((((SUM(s.Sales) - SUM(s.Quantity * p.StandardCost)) / SUM(s.Sales)) * 100)::numeric, 2) AS ProfitMarginPct
FROM Sales s
JOIN Product p ON s.ProductKey = p.ProductKey
GROUP BY p.ProductKey, p.Product, p.Category, p.Subcategory, p.Color, p.StandardCost;



-- View 3: Salesperson Performance View
CREATE OR REPLACE VIEW vw_SalespersonPerformance AS
SELECT 
    sp.EmployeeKey,
    sp.EmployeeID,
    sp.Salesperson,
    sp.Title,
    COUNT(DISTINCT s.SalesOrderNumber) AS TotalOrders,
    SUM(s.Quantity) AS TotalQuantity,
    ROUND(SUM(s.Sales)::numeric, 2) AS TotalRevenue,
    ROUND(AVG(s.Sales)::numeric, 2) AS AvgOrderValue
FROM Sales s
JOIN Salesperson sp ON s.EmployeeKey = sp.EmployeeKey
GROUP BY sp.EmployeeKey, sp.EmployeeID, sp.Salesperson, sp.Title;

-- Test views
SELECT * FROM vw_SalesSummary LIMIT 10;
SELECT * FROM vw_ProductPerformance LIMIT 10;
SELECT * FROM vw_SalespersonPerformance LIMIT 10;
