use AdventureWorksDW2017;
go


-- select PurchasedBike, count(*) from MachineLearning.Customer group by PurchasedBike

-- select  * from MachineLearning.CustomerBikeLabels


insert into dbo.DimPromotion
(
    PromotionAlternateKey,
    EnglishPromotionName,
    SpanishPromotionName,
    FrenchPromotionName,
    DiscountPct,
    EnglishPromotionType,
    SpanishPromotionType,
    FrenchPromotionType,
    EnglishPromotionCategory,
    SpanishPromotionCategory,
    FrenchPromotionCategory,
    StartDate,
    EndDate,
    MinQty,
    MaxQty
)
values
(
    69,
    'Suckah',
    'el Suckah',
    'la Suckah',
    2.0,
    'Suckah',
    'el Suckah',
    'la Suckah',
    'Suckah',
    'el Suckah',
    'la Suckah',
    '2014-01-15',
    '2014-02-15',
    1,
    99
);



with Sale as 
( 
    select 
        310 as ProductKey, 
        20140201 as OrderDateKey,
        20140207 as DueDateKey, 
        20140206 as ShipDateKey, 
        c.CustomerKey as CustomerKey,
        17 as PromotionKey,
        100 as CurrencyKey, 
        10 as SalesTerritoryKey,
        'SUKAH' + convert(varchar, c.CustomerKey) as SalesOrderNumber,
        1 as SalesOrderLineNumber, 
        1 as RevisionNumber,
        1 as OrderQuantity, 
        7156.54 as UnitPrice, 
        7156.54 as ExtendedAmount,
        0 as UnitPriceDiscount, 
        0 as DiscountAmount,
        2171.2942 as ProductStandardCost,
        2171.2942 as TotalProductCost,
        7156.54 as SalesAmount, 
        500.00 as TaxAmount,
        89.4568 as Freight, 
        NULL as CarrierTrackingNumber, 
        NULL as CustomerPONumber, 
        '2014-02-01' as OrderDate,
        '2014-02-07' as DueDate,
        '2014-02-06' as ShipDate
    from DimCustomer c
)
insert into FactInternetSales
    select top(75) percent * from Sale;
