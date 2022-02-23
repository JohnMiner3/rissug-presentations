create or alter procedure MachineLearning.uspPublishCustomerBike
/**************************************************************************
*        Copyright (C) John Flannery
*        All rights reserved.
*
*        Name:        MachineLearning.uspPublishCustomerBike
*        Description: Trains and Publishes the Customer Bike model.
*        Returns:     int.  (0 is good)
*        Author:      John Flannery
*        Created:     1/14/2019
***************************************************************************
*        Modification History
*        Who        Date        Modification
*        ------------------------------------------------------------------
***************************************************************************/
/*
select * from MachineLearning.Model;

MachineLearning.uspPublishCustomerBike;
*/
as
begin

    declare @RCode nvarchar(max);
    declare @TrainedModel varbinary(max);
    declare @i int;

    /*
        The R code below is cut/paste from the Visual Studio project.  I took out the Confusion Matrix 
        and replaced it with an output of the Traning dataset after it is scored. I also removed all 
        of the plotting etc.

    */

    set @RCode = '

        # rm(list=ls())

        # version

        #  Goal:  PurchaseBike


        library(ggplot2)
        library(repr)
        library(caret)
        library(ROCR)
        library(pROC)
        library(gridExtra)
        library(RODBC)
        library(AdventureWorks)


        dbhandle = odbcDriverConnect("driver={SQL Server};server=.\\jwf;database=AdventureWorksDW2017;trusted_connection=true")

        Customers = sqlQuery(dbhandle, "select * from MachineLearning.CustomerFeatures")
        PurchasedBike = sqlQuery(dbhandle, "select * from MachineLearning.CustomerBikeLabels")




        cat_cols = c("MaritalStatus", "Gender", "Education", "Occupation", "HouseOwnerFlag", "CommuteDistance", "StateProvince", "SalesTerritory" )
        num_cols = c("Age", "YearlyIncome", "TotalChildren", "NumberChildrenAtHome", "NumberCarsOwned")



        # Our data coming from a disciplined warehouse and good join strategy, we do not need to be concerned
        # with duplicates or missing values.



        # Combine the Datasets
        CustomerBike = merge(x = Customers, y = PurchasedBike, by = "CustomerKey", all = TRUE)


        # Redefine the catagoricals
        CustomerBike = CustomerCategoricals(CustomerBike)
        CustomerBike$PurchasedBike = factor(CustomerBike$PurchasedBike, levels = c("Yes", "No"))

        #    Partition the data into Training and Test

        set.seed(1958)

        ## Randomly sample cases to create independent training and test data
        partition = createDataPartition(CustomerBike$CustomerKey, times = 1, p = 0.7, list = FALSE)
        TrainingPartition = CustomerBike[partition,] # Create the training sample
        TestPartition = CustomerBike[-partition,] # Create the test sample

        TrainingPartition = CustomerCategoricals(TrainingPartition)
        TestPartition = CustomerCategoricals(TestPartition)
        TrainingPartition$PurchasedBike = factor(TrainingPartition$PurchasedBike, levels = c("Yes", "No"))
        TestPartition$PurchasedBike = factor(TestPartition$PurchasedBike, levels = c("Yes", "No"))


        #    Construct the classification model 

        PurchasedBikeModel = rxGlm(
							         PurchasedBike ~
                                          Age + MaritalStatus + Gender + YearlyIncome + TotalChildren +
                                          NumberChildrenAtHome + Education + Occupation + HouseOwnerFlag +
                                          NumberCarsOwned + CommuteDistance + SalesTerritory,
							          family = binomial, data = TrainingPartition
						        )




        #  MAGIC MAGIC ... This is how the model gets externalized so it can be saved to the table.
        #  In Visual Studio - the below does nothing except define a variable that is not used.  But 
        #  when we port this code to SQL Server - the variable will be used to output the model.

        TrainedModel = as.raw(serialize(PurchasedBikeModel, connection = NULL))



        ## Run the model on the test partition

        TestPartition$Prediction = rxPredict(PurchasedBikeModel, data = TestPartition, type = "response")
        TestPartition$Probability = 1.0 - TestPartition$Prediction$PurchasedBike_Pred
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
                PurchasedBike          varchar(3),
                Probability            float
            )
        );



    select @i = count(*) from MachineLearning.Model where ModelName = 'CustomerBike';

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
            1,
            'CustomerBike',
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
        where ModelName = 'CustomerBike';


end
