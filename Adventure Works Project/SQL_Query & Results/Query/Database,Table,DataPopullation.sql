--Createing DataBase:
CREATE DATABASE adventureworks_2022;

--Creating Required Tables:

-- 1. Create Product Table
CREATE TABLE Product (
    ProductKey INT PRIMARY KEY,
    Product VARCHAR(255),
    StandardCost DECIMAL(10,2),
    Color VARCHAR(50),
    Subcategory VARCHAR(100),
    Category VARCHAR(100),
    BackgroundColorFormat VARCHAR(50),
    FontColorFormat VARCHAR(50)
);


-- 2. Create Region Table
CREATE TABLE Region (
    SalesTerritoryKey INT PRIMARY KEY,
    Region VARCHAR(100),
    Country VARCHAR(100),
    GroupName VARCHAR(100)
);


-- 3. Create Reseller Table
CREATE TABLE Reseller (
    ResellerKey INT PRIMARY KEY,
    BusinessType VARCHAR(100),
    Reseller VARCHAR(255),
    City VARCHAR(100),
    StateProvince VARCHAR(100),
    CountryRegion VARCHAR(100)
);


-- 4. Create Salesperson Table
CREATE TABLE Salesperson (
    EmployeeKey INT PRIMARY KEY,
    EmployeeID INT,
    Salesperson VARCHAR(255),
    Title VARCHAR(100),
    UPN VARCHAR(255)
);


-- 5. Create Sales Table (Main Fact Table)
CREATE TABLE Sales (
    SalesOrderNumber VARCHAR(50),
    OrderDate DATE,
    ProductKey INT,
    ResellerKey INT,
    EmployeeKey INT,
    SalesTerritoryKey INT,
    Quantity INT,
    UnitPrice DECIMAL(10,2),
    Sales DECIMAL(12,2),
    FOREIGN KEY (ProductKey) REFERENCES Product(ProductKey),
    FOREIGN KEY (ResellerKey) REFERENCES Reseller(ResellerKey),
    FOREIGN KEY (EmployeeKey) REFERENCES Salesperson(EmployeeKey),
    FOREIGN KEY (SalesTerritoryKey) REFERENCES Region(SalesTerritoryKey)
);


-- 6. Create SalespersonRegion Table (Bridge Table)
CREATE TABLE SalespersonRegion (
    EmployeeKey INT,
    SalesTerritoryKey INT,
    PRIMARY KEY (EmployeeKey, SalesTerritoryKey),
    FOREIGN KEY (EmployeeKey) REFERENCES Salesperson(EmployeeKey),
    FOREIGN KEY (SalesTerritoryKey) REFERENCES Region(SalesTerritoryKey)
);


-- 7. Create Targets Table
CREATE TABLE Targets (
    EmployeeID INT,
    Target DECIMAL(12,2),
    TargetMonth DATE
);


-- Verify tables created
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public'
ORDER BY table_name;


-- Import data (adjust file paths as needed)

-- Load Product data
COPY Product FROM 'C:/Program Files/PostgreSQL/17/data/Product.csv' 
DELIMITER E'\t' CSV HEADER;

--The orginal tables we have values and signs that is not allowing to import data. So we need to drop the tables & recreate them
--Step1:
-- Drop and recreate Product table with text type first
DROP TABLE IF EXISTS Sales CASCADE;
DROP TABLE IF EXISTS Product CASCADE;

CREATE TABLE Product (
    ProductKey INT PRIMARY KEY,
    Product VARCHAR(255),
    StandardCost VARCHAR(50),  -- Changed to VARCHAR temporarily
    Color VARCHAR(50),
    Subcategory VARCHAR(100),
    Category VARCHAR(100),
    BackgroundColorFormat VARCHAR(50),
    FontColorFormat VARCHAR(50)
);

-- Load data
COPY Product FROM 'C:/Program Files/PostgreSQL/17/data/Product.csv' 
DELIMITER E'\t' CSV HEADER;

-- Clean and convert to numeric
UPDATE Product 
SET StandardCost = REPLACE(REPLACE(StandardCost, '$', ''), ',', '');

-- Change column type to numeric
ALTER TABLE Product 
ALTER COLUMN StandardCost TYPE DECIMAL(10,2) USING StandardCost::DECIMAL(10,2);

-- Now We can proceed with other tables


--Copying data for Region Table
COPY Region FROM 'C:/Program Files/PostgreSQL/17/data/Region.csv' 
DELIMITER E'\t' CSV HEADER;


--Copying data for Reseller Table
COPY Reseller FROM 'C:/Program Files/PostgreSQL/17/data/Reseller.csv' 
DELIMITER E'\t' CSV HEADER;

--Copying data for Salesperson Table
COPY Salesperson FROM 'C:/Program Files/PostgreSQL/17/data/Salesperson.csv' 
DELIMITER E'\t' CSV HEADER;

--Copying data for SalespersonRegion Table
COPY SalespersonRegion FROM 'C:/Program Files/PostgreSQL/17/data/SalespersonRegion.csv' 
DELIMITER E'\t' CSV HEADER;

--Since Sales table (has UnitPrice and Sales with $ and commas) we will have to alter the table and then copy the data:
CREATE TABLE Sales (
    SalesOrderNumber VARCHAR(50),
    OrderDate DATE,
    ProductKey INT,
    ResellerKey INT,
    EmployeeKey INT,
    SalesTerritoryKey INT,
    Quantity INT,
    UnitPrice VARCHAR(50),
    Sales VARCHAR(50)
);

DROP TABLE IF EXISTS Sales CASCADE;

CREATE TABLE Sales (
    SalesOrderNumber VARCHAR(50),
    OrderDate DATE,
    ProductKey INT,
    ResellerKey INT,
    EmployeeKey INT,
    SalesTerritoryKey INT,
    Quantity INT,
    UnitPrice VARCHAR(50),
    Sales VARCHAR(50),
    Cost VARCHAR(50)
);

-- Load data
COPY Sales FROM 'C:/Program Files/PostgreSQL/17/data/Sales.csv' 
DELIMITER E'\t' CSV HEADER;


-- Clean currency columns
UPDATE Sales 
SET UnitPrice = REPLACE(REPLACE(UnitPrice, '$', ''), ',', ''),
    Sales = REPLACE(REPLACE(Sales, '$', ''), ',', ''),
    Cost = REPLACE(REPLACE(Cost, '$', ''), ',', '');

-- Convert to numeric
ALTER TABLE Sales ALTER COLUMN UnitPrice TYPE DECIMAL(10,2) USING UnitPrice::DECIMAL(10,2);
ALTER TABLE Sales ALTER COLUMN Sales TYPE DECIMAL(12,2) USING Sales::DECIMAL(12,2);
ALTER TABLE Sales ALTER COLUMN Cost TYPE DECIMAL(12,2) USING Cost::DECIMAL(12,2);

-- Add foreign keys
ALTER TABLE Sales ADD FOREIGN KEY (ProductKey) REFERENCES Product(ProductKey);
ALTER TABLE Sales ADD FOREIGN KEY (ResellerKey) REFERENCES Reseller(ResellerKey);
ALTER TABLE Sales ADD FOREIGN KEY (EmployeeKey) REFERENCES Salesperson(EmployeeKey);
ALTER TABLE Sales ADD FOREIGN KEY (SalesTerritoryKey) REFERENCES Region(SalesTerritoryKey);