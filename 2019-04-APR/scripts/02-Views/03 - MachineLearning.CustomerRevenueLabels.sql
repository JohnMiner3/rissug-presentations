create or alter view MachineLearning.CustomerRevenueLabels
/**************************************************************************
*        Copyright (C) John Flannery
*        All rights reserved.
*
*        Name:        MachineLearning.CustomerRevenueLabels
*        Description: Returns Customer RevenueLabels
*        Returns:     Result Set
*        Author:      John Flannery
*        Created:     01/06/2019
***************************************************************************
*        Modification History
*        Who        Date        Modification
*        -------------------------------------------------------------------
*******************************************************************************/
/*
select * from MachineLearning.CustomerRevenueLabels;
*/
as

    select
        CustomerKey,
        RevenuePerYear 
   from MachineLearning.Customer;
 

