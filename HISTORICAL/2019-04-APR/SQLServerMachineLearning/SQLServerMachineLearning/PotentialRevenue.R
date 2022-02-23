# Copyright(C) John Flannery
# All rights reserved.

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

qplot(CustomerSpend$RevenuePerYear, geom = "histogram")

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


RMSE(TestPartition$RevenuePerYear, TestPartition$Score)




