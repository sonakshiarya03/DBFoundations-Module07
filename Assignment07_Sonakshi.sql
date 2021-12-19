--*************************************************************************--
-- Title: Assignment07
-- Author: Sonakshi
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2021-12-17,Sonakshi,Created File
-- 2021-12-17,Sonakshi,Changed DB Name
-- 2021-12-17,Sonakshi,Added SQL code for Question 1
-- 2021-12-17,Sonakshi,Added SQL code for Question 2
-- 2021-12-17,Sonakshi,Added SQL code for Question 3
-- 2021-12-17,Sonakshi,Corrected Order By Clause for Question 3 to use date value sort order.
-- 2021-12-17,Sonakshi,Created view vProductInventories
-- 2021-12-17,Sonakshi,Tested the view using SELECT statement. Kept order by outside the view, since it is not a good practice.
-- 2021-12-17,Sonakshi,Modified vProductInventories view to keep Date as Date data type in one column to allow ordering results
-- 2021-12-17,Sonakshi,Added CategoryID to the output column of vProductInventories
-- 2021-12-17,Sonakshi,Created view vCategoryInventories
-- 2021-12-17,Sonakshi,Created view vProductInventoriesWithPreviouMonthCounts by leveraging vCategoryInventories and LAG function.
-- 2021-12-17,Sonakshi,updated view vProductInventoriesWithPreviouMonthCounts to use IIF instead of IsNull.
-- 2021-12-17,Sonakshi,Created view vProductInventoriesWithPreviousMonthCountsWithKPIs by leveraging vProductInventoriesWithPreviouMonthCounts 
-- 2021-12-17,Sonakshi,Created function fProductInventoriesWithPreviousMonthCountsWithKPIs leveraging view vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- 2021-12-17,Sonakshi,Added statement to drop the database at the end of script.
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_Sonakshi')
	 Begin 
	  Alter Database [Assignment07DB_Sonakshi] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_Sonakshi;
	 End
	Create Database Assignment07DB_Sonakshi;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_Sonakshi;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count], [ReorderLevel]) -- New column added this week
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock, ReorderLevel
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10, ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, abs(UnitsInStock - 10), ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go


-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
Print
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) Remember that Inventory Counts are Randomly Generated. So, your counts may not match mine
 3) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.
SELECT
	ProductName,
	UnitPrice = Format(UnitPrice, 'C', 'en-US')
FROM vProducts
ORDER BY ProductName;
GO

-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.

SELECT 
	c.CategoryName,
	p.ProductName,
	UnitPrice = Format(p.UnitPrice, 'C', 'en-US')
FROM vCategories AS c
	INNER JOIN vProducts AS p
	ON c.CategoryID = p.CategoryID
ORDER BY CategoryName, ProductName;
GO

-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

SELECT 
	p.ProductName,
	InventoryDate = FORMAT(i.InventoryDate, 'MMMM, yyyy'),
	i.[Count] AS InventoryCount
FROM vProducts AS p
	INNER JOIN vInventories AS i
	ON p.ProductID = i.ProductID
ORDER BY ProductName, i.InventoryDate;
GO

-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.
CREATE 
VIEW vProductInventories
AS
	SELECT 
		p.ProductName,
		p.CategoryID,
		InventoryDateStr = FORMAT(i.InventoryDate, 'MMMM, yyyy'),
		i.InventoryDate,
		i.[Count] AS InventoryCount
	FROM vProducts AS p
		INNER JOIN vInventories AS i
		ON p.ProductID = i.ProductID;
GO

SELECT 
	ProductName, 
	InventoryDateStr, 
	InventoryCount
FROM vProductInventories
ORDER BY ProductName, InventoryDate;
GO

-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.
CREATE 
VIEW vCategoryInventories
AS
	SELECT 
		c.CategoryName,
		p.InventoryDateStr,
		p.InventoryDate,
		InventoryCountByCategory = SUM(InventoryCount)
	FROM vCategories AS c
		INNER JOIN vProductInventories AS p
		ON c.CategoryID = p.CategoryID
	GROUP BY CategoryName, InventoryDate, InventoryDateStr;
GO

SELECT
	CategoryName,
	InventoryDateStr,
	InventoryCountByCategory
FROM vCategoryInventories
ORDER BY CategoryName, InventoryDate
GO

-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.

CREATE 
VIEW vProductInventoriesWithPreviouMonthCounts
AS
	SELECT 
		ProductName,
		InventoryDateStr,
		InventoryCount,
		InventoryDate,
		PreviousMonthCount = IIF(MONTH(InventoryDate) = 1, 0, LAG(InventoryCount) OVER(PARTITION BY ProductName ORDER BY MONTH(
			InventoryDate)))
	FROM vProductInventories;
GO

SELECT
	ProductName,
	InventoryDateStr,
	InventoryCount,
	PreviousMonthCount
FROM vProductInventoriesWithPreviouMonthCounts
ORDER BY ProductName, InventoryDate
GO

-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.

CREATE 
VIEW vProductInventoriesWithPreviousMonthCountsWithKPIs
AS
	SELECT 
		ProductName,
		InventoryDateStr,
		InventoryCount,
		InventoryDate,
		PreviousMonthCount,
		CountVsPreviousCountKPI = Case 
			When InventoryCount > PreviousMonthCount Then 1
			When InventoryCount = PreviousMonthCount Then 0
			When InventoryCount < PreviousMonthCount Then -1
			End
	FROM vProductInventoriesWithPreviouMonthCounts;
GO

SELECT
	ProductName,
	InventoryDateStr,
	InventoryCount,
	PreviousMonthCount,
	CountVsPreviousCountKPI
FROM vProductInventoriesWithPreviousMonthCountsWithKPIs
ORDER BY ProductName, InventoryDate
GO

-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Varify that the results are ordered by the Product and Date.

CREATE FUNCTION dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs(@kpiFilter int)
RETURNS TABLE
AS
	RETURN(
		SELECT *
		FROM vProductInventoriesWithPreviousMonthCountsWithKPIs
		WHERE CountVsPreviousCountKPI = @kpiFilter
	);
GO

-- Check that it works:
SELECT
	ProductName,
	InventoryDateStr,
	InventoryCount,
	PreviousMonthCount,
	CountVsPreviousCountKPI
FROM fProductInventoriesWithPreviousMonthCountsWithKPIs(1)
ORDER BY ProductName, InventoryDate;

SELECT
	ProductName,
	InventoryDateStr,
	InventoryCount,
	PreviousMonthCount,
	CountVsPreviousCountKPI
FROM fProductInventoriesWithPreviousMonthCountsWithKPIs(0)
ORDER BY ProductName, InventoryDate;

SELECT
	ProductName,
	InventoryDateStr,
	InventoryCount,
	PreviousMonthCount,
	CountVsPreviousCountKPI
FROM fProductInventoriesWithPreviousMonthCountsWithKPIs(-1)
ORDER BY ProductName, InventoryDate;
GO

/***************************************************************************************/

-- Drop the database
Use master
Go
Drop Database Assignment06DB_Sonakshi;
Go