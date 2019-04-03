create or alter procedure MachineLearning.uspPredictCustomerBike
/**************************************************************************
*        Copyright (C) John Flannery
*        All rights reserved.
*
*        Name:        MachineLearning.uspPredictCustomerBike
*        Description: Returns a prediction as to potential of a new
*                     customer to purchase a bicycle.
*        Returns:     float  (the probability)
*        Author:      John Flannery
*        Created:     01/14/2019
***************************************************************************
*        Modification History
*        Who        Date        Modification
*        -------------------------------------------------------------------
*******************************************************************************/
/*


MachineLearning.uspPredictCustomerBike
    @BirthDate = '1978-01-01',
    @MaritalStatus = 'M',
    @Gender = 'M',
    @YearlyIncome = 120000,
    @TotalChildren = 1,
    @NumberChildrenAtHome = 1, 
    @Education = 'Graduate Degree',
    @Occupation = 'Professional',
    @HouseOwnerFlag = 'No',
    @NumberCarsOwned = 2,
    @CommuteDistance = '5-10 Miles',
    @StateProvince = 'CA',
    @SalesTerritory = 'ST1';


*/
@BirthDate date, 
@MaritalStatus char(1),
-- MaritalStatus Factor w/ 2 levels:  M, S
@Gender char(1),
-- Gender Factor w/ 2 levels:  F, M
@YearlyIncome money,
@TotalChildren int, 
@NumberChildrenAtHome int, 
@Education varchar(50),
-- Education Factor w/ 5 levels: Partial High School, High School, Partial College, 
--                               Bachelors, Graduate Degree
@Occupation varchar(50),
-- Occupation Factor w/ 5 levels: "Clerical" "Management" "Manual" "Professional" "Skilled Manual"
@HouseOwnerFlag varchar(3), 
-- HomeOwnerFlag Factor w/ 2 levels: No, Yes
@NumberCarsOwned int, 
@CommuteDistance varchar(50),
-- CommuteDistance Factor w/ 5 levels" "0-1 Miles" "1-2 Miles" "2-5 Miles" "5-10 Miles" "10+ Miles"
@StateProvince varchar(3),
@SalesTerritory varchar(20)
-- SalesTerritory factor w/ 10 levels: "ST1" "ST10" "ST2" "ST3" "ST4" "ST5" "ST6" "ST7" "ST8" "ST9"
as
begin

    declare @Age int;
    declare @Model varbinary(max);
    declare @RCode nvarchar(max);
    declare @Prediction float;
    
    select @Model = Model 
    from MachineLearning.Model
    where ModelName = 'CustomerBike';

    set @Age = datediff(year, @BirthDate, GetDate());

    declare @Query nvarchar(max);

    set @Query = 'select ';
    set @Query = @Query + convert(varchar, @Age) + ' as Age, ';
    set @Query = @Query + '''' + @MaritalStatus + '''  as MaritalStatus, ';
    set @Query = @Query + '''' + @Gender + '''  as Gender, ';
    set @Query = @Query + convert (varchar, @YearlyIncome) + '  as YearlyIncome, ';
    set @Query = @Query + convert (varchar, @TotalChildren) + '  as TotalChildren, ';
    set @Query = @Query + convert (varchar, @NumberChildrenAtHome) + '  as NumberChildrenAtHome, ';
    set @Query = @Query + '''' + @Education + '''  as Education, ';
    set @Query = @Query + '''' + @Occupation + '''  as Occupation, ';
    set @Query = @Query + '''' + @HouseOwnerFlag + '''  as HouseOwnerFlag, ';
    set @Query = @Query + convert (varchar, @NumberCarsOwned) + '  as NumberCarsOwned, ';
    set @Query = @Query + '''' + @CommuteDistance + '''  as CommuteDistance, ';
    set @Query = @Query + '''' + @StateProvince + '''  as StateProvince, ';
    set @Query = @Query + '''' + @SalesTerritory + '''  as SalesTerritory ';

     
    set @Rcode = '

        library(AdventureWorks)

        InputDataSet = CustomerCategoricals(InputDataSet)
       
        Model = unserialize(Model)

	    Prediction = rxPredict (
            Model, 
            data = InputDataSet, 
            type = "response"
        )

        Prediction = 1.0 - as.numeric(Prediction)

	'
    -- It is very important to do real time predictions in try catch blocks.  There are lots of reasons this might fail 
    -- including a catagorical feature issue.  (Say the person calling in is the first customer from Connecticut.) 

    begin try

        exec sp_execute_external_script
		     @language = N'R',
		     @script = @RCode, 
		     @input_data_1 =  @Query,
		     @params = N'@Model varbinary(max), @Prediction float output',
		     @Model = @Model,
             @Prediction = @Prediction out
    end try

    begin catch 

        set @Prediction = 0;

    end catch


    select @Prediction;

end
