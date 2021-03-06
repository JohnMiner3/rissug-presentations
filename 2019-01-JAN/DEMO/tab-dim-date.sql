--
-- Remove unwanted fields
-- 

CREATE VIEW [tab].[vDimDate] AS
SELECT 
       [DateKey]
      ,[FullDateAlternateKey]
      ,[DayNumberOfWeek]
      ,[EnglishDayNameOfWeek]
      --,[SpanishDayNameOfWeek]
      --,[FrenchDayNameOfWeek]
      ,[DayNumberOfMonth]
      ,[DayNumberOfYear]
      ,[WeekNumberOfYear]
      ,[EnglishMonthName]
      --,[SpanishMonthName]
      --,[FrenchMonthName]
      ,[MonthNumberOfYear]
      ,[CalendarQuarter]
      ,[CalendarYear]
      ,[CalendarSemester]
      ,[FiscalQuarter]
      ,[FiscalYear]
      ,[FiscalSemester]
FROM 
    [AdventureWorksDW2016].[dbo].[DimDate]
GO