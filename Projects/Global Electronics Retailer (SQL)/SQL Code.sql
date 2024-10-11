---- Viewing the tables ----
SELECT TOP(10) *
FROM Customers;

SELECT TOP(10) *
FROM Products;

SELECT TOP(10) *
FROM Sales;

SELECT TOP(10) *
FROM Stores;


---- Standardizing table variable names ----
-- Customer
EXEC sp_rename 'Customers.[State Code]', 'StateCode', 'COLUMN';
EXEC sp_rename 'Customers.[Zip Code]', 'ZipCode', 'COLUMN';
-- Products
EXEC sp_rename 'Products.[Product Name]', 'ProductName', 'COLUMN';
EXEC sp_rename 'Products.[Unit Cost USD]', 'UnitCostUSD', 'COLUMN';
EXEC sp_rename 'Products.[Unit Price USD]', 'UnitPriceUSD', 'COLUMN';
-- Sales
EXEC sp_rename 'sales.[Order Number]', 'OrderNumber', 'COLUMN';
EXEC sp_rename 'sales.[Line Item]', 'LineItem', 'COLUMN';
EXEC sp_rename 'sales.[Currency Code]', 'CurrencyCode', 'COLUMN';
EXEC sp_rename 'sales.[Order Date]', 'OrderDate', 'COLUMN';
-- Stores
EXEC sp_rename 'stores.[Square Meters]', 'SquareMeters', 'COLUMN';
EXEC sp_rename 'stores.[Open Date]', 'OpenDate', 'COLUMN';


---- Defining data types and keys (Customers table) ----
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Customers';
-- CustomerKey
ALTER TABLE Customers
ALTER COLUMN CustomerKey INT;
-- Birthday
ALTER TABLE Customers
ALTER COLUMN Birthday DATE;


---- Defining data types and keys (Products) ----
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Products';
-- ProductKey
ALTER TABLE Products
ALTER COLUMN ProductKey INT;
-- SubcategoryKey
ALTER TABLE Products
ALTER COLUMN SubcategoryKey INT;
-- CategoryKey
ALTER TABLE Products
ALTER COLUMN CategoryKey INT;


---- Defining data types and keys (Sales) ----
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Sales';
-- OrderNumber
ALTER TABLE Sales
ALTER COLUMN OrderNumber INT;
-- LineItem
ALTER TABLE Sales
ALTER COLUMN LineItem INT;
-- OrderDate
ALTER TABLE Sales
ALTER COLUMN OrderDate DATE;
-- CustomerKey
ALTER TABLE Sales
ALTER COLUMN CustomerKey INT;
-- StoreKey
ALTER TABLE Sales
ALTER COLUMN StoreKey INT;
-- ProductKey
ALTER TABLE Sales
ALTER COLUMN ProductKey INT;
-- Quantity
ALTER TABLE Sales
ALTER COLUMN Quantity INT;


---- Defining data types and keys (Stores) ----
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Stores';
-- StoreKey
ALTER TABLE Stores
ALTER COLUMN StoreKey INT;
-- SquareMeters
ALTER TABLE Stores
ALTER COLUMN SquareMeters INT;
-- OpenDate
ALTER TABLE Stores
ALTER COLUMN OpenDate DATE;

---- Identifying the products with highest Sales in North America ----
SELECT 
	DISTINCT Continent
FROM
	Customers

SELECT 
    p.ProductName,
	p.UnitCostUSD,
	p.UnitPriceUSD,
    st.Country,
    SUM(s.Quantity * p.UnitPriceUSD) AS TotalSales,
	(p.UnitPriceUSD - p.UnitCostUSD) AS ProfitPerUnit
FROM 
    Sales s
JOIN 
    Products p ON s.ProductKey = p.ProductKey
JOIN 
    Stores st ON s.StoreKey = st.StoreKey
JOIN
	Customers c ON c.CustomerKey = s.CustomerKey
WHERE 
    c.Continent = 'North America'
GROUP BY 
    p.ProductName, p.UnitCostUSD, p.UnitPriceUSD, st.Country
ORDER BY 
    TotalSales DESC	


---- Identifying the products with highest Sales in North America CUBE ----
SELECT 
    p.ProductName,
	p.UnitCostUSD,
	p.UnitPriceUSD,
    st.Country,
    SUM(s.Quantity * p.UnitPriceUSD) AS TotalSales,
	(p.UnitPriceUSD - p.UnitCostUSD) AS ProfitPerUnit
FROM 
    Sales s
JOIN 
    Products p ON s.ProductKey = p.ProductKey
JOIN 
    Stores st ON s.StoreKey = st.StoreKey
JOIN
	Customers c ON c.CustomerKey = s.CustomerKey
WHERE 
    c.Continent = 'North America'
GROUP BY 
    CUBE(p.ProductName, 
		 p.UnitCostUSD, 
		 p.UnitPriceUSD, 
		 st.Country)
ORDER BY 
    GROUPING (p.ProductName),
	GROUPING (p.UnitCostUSD),
	GROUPING (p.UnitPriceUSD),
	GROUPING (st.Country),
	TotalSales DESC


---- Identifying the products with highest Profit in North America ----
SELECT 
    p.ProductName,
	p.UnitCostUSD,
	p.UnitPriceUSD,
    st.Country,
    SUM(s.Quantity * p.UnitPriceUSD) AS TotalSales,
	(p.UnitPriceUSD - p.UnitCostUSD) AS ProfitPerUnit
FROM 
    Sales s
JOIN 
    Products p ON s.ProductKey = p.ProductKey
JOIN 
    Stores st ON s.StoreKey = st.StoreKey
JOIN
	Customers c ON c.CustomerKey = s.CustomerKey
WHERE 
    c.Continent = 'North America'
GROUP BY 
    p.ProductName, p.UnitCostUSD, p.UnitPriceUSD, st.Country
ORDER BY 
	[Profit per Unit] DESC,
    TotalSales DESC	


---- Identifying the products with highest Profit in North America CUBE ----
SELECT 
    p.ProductName,
	p.UnitCostUSD,
	p.UnitPriceUSD,
    st.Country,
    SUM(s.Quantity * p.UnitPriceUSD) AS TotalSales,
	(p.UnitPriceUSD - p.UnitCostUSD) AS ProfitPerUnit
FROM 
    Sales s
JOIN 
    Products p ON s.ProductKey = p.ProductKey
JOIN 
    Stores st ON s.StoreKey = st.StoreKey
JOIN
	Customers c ON c.CustomerKey = s.CustomerKey
WHERE 
    c.Continent = 'North America'
GROUP BY 
    CUBE(p.ProductName, 
		 p.UnitCostUSD, 
		 p.UnitPriceUSD, 
		 st.Country)
ORDER BY 
    GROUPING (p.ProductName),
	GROUPING (p.UnitCostUSD),
	GROUPING (p.UnitPriceUSD),
	GROUPING (st.Country),
	[Profit per Unit] DESC,
    TotalSales DESC