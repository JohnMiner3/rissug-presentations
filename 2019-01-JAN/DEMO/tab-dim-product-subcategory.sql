--
-- Remove unwanted fields
-- 

CREATE VIEW [tab].[vDimProductSubcategory] AS
SELECT 
       [ProductSubcategoryKey]
      ,[ProductSubcategoryAlternateKey]
      ,[EnglishProductSubcategoryName]
      --,[SpanishProductSubcategoryName]
      --,[FrenchProductSubcategoryName]
      ,[ProductCategoryKey]
FROM 
    [AdventureWorksDW2016].[dbo].[DimProductSubcategory]
GO