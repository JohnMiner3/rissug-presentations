create or alter view MachineLearning.CustomerFeatures
/**************************************************************************
*        Copyright (C) John Flannery
*        All rights reserved.
*
*        Name:        MachineLearning.CustomerFeatures
*        Description: Returns Customer Features
*        Returns:     Result Set
*        Author:      John Flannery
*        Created:     01/06/2019
***************************************************************************
*        Modification History
*        Who        Date        Modification
*        -------------------------------------------------------------------
*******************************************************************************/
/*
select * from MachineLearning.CustomerFeatures;
*/
as

    select
        CustomerKey,
        Age, 
		MaritalStatus, 
		Gender,
		YearlyIncome,
		TotalChildren,
		NumberChildrenAtHome,
		Education,
		Occupation,
		HouseOwnerFlag,
		NumberCarsOwned,
		CommuteDistance,
        StateProvince,
		-- PostalCode,     RAT HOLE.  There are 323 of these - to many.  I'll explain.
		SalesTerritory 
   from MachineLearning.Customer;
 

