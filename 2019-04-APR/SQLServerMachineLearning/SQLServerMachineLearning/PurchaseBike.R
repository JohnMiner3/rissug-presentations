# Copyright(C) John Flannery
# All rights reserved.

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




#    Deturmine which columns to use in the Classification model


plot_bars = function(df, catcols)
{
	options(repr.plot.width = 6, repr.plot.height = 5) # Set the initial plot area dimensions
	temp0 = df[df$PurchasedBike == "No",]
	temp1 = df[df$PurchasedBike == "Yes",]
    for (col in cat_cols)
    {
		p1 = ggplot(temp0, aes_string(col)) +
			geom_bar() +
			ggtitle(paste("Bar plot of \n", col, "\n for PurchasedBike = No")) +
			theme(axis.text.x = element_text(angle = 90, hjust = 1))

		p2 = ggplot(temp1, aes_string(col)) +
			geom_bar() +
			ggtitle(paste("Bar plot of \n", col, "\n for PurchasedBike = Yes")) +
			theme(axis.text.x = element_text(angle = 90, hjust = 1))

		grid.arrange(p1, p2, nrow = 1)
	}
}


plot_bars(CustomerBike, cat_cols)

plot_box = function(df, cols, col_x = "PurchasedBike") {
    options(repr.plot.width = 4, repr.plot.height = 3.5) # Set the initial plot area dimensions
    for (col in cols) {
        p = ggplot(df, aes_string(col_x, col)) +
            geom_boxplot() +
            ggtitle(paste("Box plot of", col, "\n vs.", col_x))

        print(p)
    }
}



plot_box(CustomerBike, num_cols)



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
                              family = binomial(logit), data = TrainingPartition
                        )



#  MAGIC MAGIC ... This is how the model gets externalized so it can be saved to the table.
#  In Visual Studio - the below does nothing except define a variable that is not used.  But 
#  when we port this code to SQL Server - the variable will be used to output the model.

TrainedModel = as.raw(serialize(PurchasedBikeModel, connection = NULL))



## Run the model on the test partition

TestPartition$Prediction = rxPredict(PurchasedBikeModel, data = TestPartition, type = "response")
TestPartition$Probability = 1.0 - TestPartition$Prediction$PurchasedBike_Pred
TestPartition$Prediction = NULL

TestPartition$Score = ifelse(TestPartition$Probability >= 0.5, "Yes", "No")    #  Remember this line when we predict
TestPartition$Score = factor(TestPartition$Score, levels = c("Yes", "No"))


confusionMatrix(TestPartition$Score, TestPartition$PurchasedBike)


