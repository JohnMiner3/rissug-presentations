create or alter view MachineLearning.Customer
/**************************************************************************
*        Copyright (C) John Flannery
*        All rights reserved.
*
*        Name:        MachineLearning.Customer
*        Description: Returns a denormalized view of customer to be used 
*                     in Machine Learning predictions.
*        Returns:     Result Set
*        Author:      John Flannery
*        Created:     01/06/2019
***************************************************************************
*        Modification History
*        Who        Date        Modification
*        -------------------------------------------------------------------
*******************************************************************************/
/*
select * from MachineLearning.Customer order by Revenue asc;
*/
as


    with SalesHistory as 
    (
        select 
            CustomerKey,
            count(*) as Transactions,
            sum(TotalProductCost) as Revenue, 
            count(distinct(OrderDateKey / 1000)) as YearsParticipating,
            sum(TotalProductCost) / count(distinct(OrderDateKey / 1000)) as RevenuePerYear,
            count(*) / count(distinct(OrderDateKey / 1000)) as TransactionsPerYear,
            'ST' + convert(varchar, min(SalesTerritoryKey)) as SalesTerritory  -- I want this to be categorical
        from dbo.FactInternetSales
        group by CustomerKey
    ),
    PurchasedBike as 
    (
        select
            s.CustomerKey,
            count(*) as BikesPurchased
        from 
                dbo.FactInternetSales s
            inner join 
 		        dbo.DimProduct p 
                    on s.ProductKey = p.ProductKey 
        inner join 
            dbo.DimProductSubcategory ps 
                on p.ProductSubcategoryKey = ps.ProductSubcategoryKey 
        where ps.ProductCategoryKey = 1
        group by s.CustomerKey
    )
    select 
        c.CustomerKey,
        datediff(year, c.BirthDate, GetDate()) as Age, 
		c.MaritalStatus, 
		c.Gender,
		c.YearlyIncome,
		c.TotalChildren,
		c.NumberChildrenAtHome,
		c.EnglishEducation as 'Education',
		c.EnglishOccupation as 'Occupation',
		case c.HouseOwnerFlag when 1 then 'Yes' else 'No' end as HouseOwnerFlag,
		c.NumberCarsOwned,
		c.DateFirstPurchase,
		c.CommuteDistance,
		g.City,
        g.StateProvinceCode as 'StateProvince',
		g.PostalCode,
		sh.SalesTerritory, 
        sh.Transactions,
        sh.Revenue,
        sh.TransactionsPerYear,
        sh.RevenuePerYear,
        sh.YearsParticipating,
        case when b.BikesPurchased is not null then 'Yes' else 'No' end as PurchasedBike
    from 
		    dbo.DimCustomer c 
        inner join 
		    dbo.DimGeography g 
                on c.GeographyKey = g.GeographyKey 
        inner join 
            SalesHistory sh 
                on c.CustomerKey = sh.CustomerKey
        left outer join 
            PurchasedBike b
                on c.CustomerKey = b.CustomerKey
go 

