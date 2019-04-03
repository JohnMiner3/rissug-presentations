create or alter procedure MachineLearning.uspPublishCustomerRevenue
/**************************************************************************
*        Copyright (C) John Flannery
*        All rights reserved.
*
*        Name:        MachineLearning.uspPublishCustomerRevenue
*        Description: Trains and Publishes the Customer Revenue model.
*        Returns:     int.  (0 is good)
*        Author:      John Flannery
*        Created:     01/06/2019
***************************************************************************
*        Modification History
*        Who        Date        Modification
*        ------------------------------------------------------------------
***************************************************************************/
/*
select * from MachineLearning.Model;

MachineLearning.uspPublishCustomerRevenue;
*/
as
begin

    declare @RCode nvarchar(max);
    declare @TrainedModel varbinary(max);
    declare @i int;

    set @RCode = '

        # rm(list=ls())

        # version


        #  Goal:  RevenuePerYear


        library(ggplot2)
        library(repr)
        library(caret)
        options(repr.plot.width = 4, repr.plot.height = 4) # Set the initial plot area dimensions
        library(RODBC)
        library(AdventureWorks)


        dbhandle = odbcDriverConnect("driver={SQL Server};server=.\\jwf;database=AdventureWorksDW2017;trusted_connection=true")

        Customers = sqlQuery(dbhandle, "select * from MachineLearning.CustomerFeatures")
        MonthlySpend = sqlQuery(dbhandle, "select * from MachineLearning.CustomerRevenueLabels")




        ## Combining datasets

        CustomerSpend = merge(x = Customers, y = MonthlySpend, by = "CustomerKey", all = TRUE)
        CustomerSpend = CustomerCategoricals(CustomerSpend)

        ##  Data Preperation

        cat_cols = c("MaritalStatus", "Gender", "Education", "Occupation", "HouseOwnerFlag", "CommuteDistance", "StateProvince", "SalesTerritory")
        num_cols = c("Age", "YearlyIncome", "TotalChildren", "NumberChildrenAtHome", "NumberCarsOwned")



        ## Randomly sample cases to create independent training and test data

        set.seed(1958)
        partition = createDataPartition(CustomerSpend$CustomerKey, times = 1, p = 0.7, list = FALSE)
        TrainingPartition = CustomerSpend[partition,] # Create the training sample
        TestPartition = CustomerSpend[-partition,] # Create the test sample

        TrainingPartition = CustomerCategoricals(TrainingPartition)
        TestPartition = CustomerCategoricals(TestPartition)


        CustomerSpendModel = rxDForest(formula = RevenuePerYear ~
                                          Age + MaritalStatus + Gender + YearlyIncome + TotalChildren +
                                          NumberChildrenAtHome + Education + Occupation + HouseOwnerFlag +
                                          NumberCarsOwned + CommuteDistance + SalesTerritory,
                                    data = TrainingPartition
						        )


        #  MAGIC MAGIC ... This is how the model gets externalized so it can be saved to the table.
        TrainedModel = as.raw(serialize(CustomerSpendModel, connection = NULL))


        summary(CustomerSpendModel)


        TestPartition$Prediction = rxPredict(CustomerSpendModel, data = TestPartition, type = "response")
        TestPartition$Score = TestPartition$Prediction$RevenuePerYear_Pred
        TestPartition$Prediction = NULL



        OutputDataSet = data.frame(TestPartition)

    ';


    exec sp_execute_external_script 
        @language = N'R', 
        @script = @RCode,
        @params = N'@TrainedModel varbinary(max) output',
        @TrainedModel = @TrainedModel output
        with result sets 
        (
            (
                CustomerKey            int, 
                Age                    int,
                MaritalStatus          char(1),
                Gender                 char(1),
                YearlyIncome           money,
                TotalChildren          int, 
                NumberChildrenAtHome   int,
                Education              varchar(50),
                Occupation             varchar(50),
                HouseOwnerFlag         varchar(3),
                NumberCarsOwned        int,
                CommuteDistance        varchar(50), 
                StateProvince          varchar(10),
                SalesTerritory         varchar(10),
                RevenuePerYear         numeric,
                Prediction             numeric
            )
        );



    select @i = count(*) from MachineLearning.Model where ModelName = 'CustomerRevenue';

    if @i = 0 
        insert into MachineLearning.Model
        (
            ModelId,
            ModelName, 
            Version,
            CreatedDate,
            LastprocessedDate, 
            RCode, 
            Model
        )
        values 
        (
            2,
            'CustomerRevenue',
            1,
            GetDate(),
            GetDate(),
            @RCode,
            @TrainedModel
        )
    else
        update MachineLearning.Model
            set LastProcessedDate = GetDate(),
                Model = @TrainedModel
        where ModelName = 'CustomerRevenue';


end
