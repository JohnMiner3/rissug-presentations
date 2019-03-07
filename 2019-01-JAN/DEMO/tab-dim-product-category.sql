--
-- Remove unwanted fields
-- 

CREATE VIEW [tab].[vDimProductCategory] AS
SELECT 
       [ProductCategoryKey]
      ,[ProductCategoryAlternateKey]
      ,[EnglishProductCategoryName]
      --,[SpanishProductCategoryName]
      --,[FrenchProductCategoryName]
FROM 
    [AdventureWorksDW2016].[dbo].[DimProductCategory]
GO