create or alter view MachineLearning.CustomerBikeLabels
/**************************************************************************
*        Copyright (C) John Flannery
*        All rights reserved.
*
*        Name:        MachineLearning.CustomerBikeLabels
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
select * from MachineLearning.CustomerBikeLabels;

select PurchasedBike, count(*) from MachineLearning.CustomerBikeLabels group by PurchasedBike;
*/
as

    select
        CustomerKey,
        PurchasedBike
   from MachineLearning.Customer;
 

