## What is this function all about??  CustomerBike has 18,484 observations and 8 catagorical features.  When used as input to a prediction,
## a dataset MUST conform to the definition of the dataset used in training.  My end goal is online realtime prediction.  So the data set 
## I use there will have 1 observation.  In that case, Gender will be a categorical with 1 level.
##
## Further - the principle of "get a lot of data."  Well - AdventureWorks is not that big.  When you split the dataset - it is possible 
## (in fact - probable - I discovered this because I tripped over it) that a zip code will be represented in the testing data, but not the 
## training data.  That will cause the call to the prediction to throw an exception.  (The categorical definitions do NOT come with the data
## when you do a split.) 
##
## So this function is going to be used alot. 


CustomerCategoricals = function(df) {

    df$MaritalStatus = factor(df$MaritalStatus, levels = c("M", "S"))

    df$Gender = factor(df$Gender, levels = c("F", "M"))

    df$Education = factor(
                                    df$Education,
                                    levels = c(
                                                   "Partial High School", "High School", "Partial College",
                                                   "Bachelors", "Graduate Degree"
                                              ), ordered = TRUE
                               )

    df$Occupation = factor(
                                   df$Occupation,
                                   levels = c(
                                                  "Clerical", "Management", "Manual", "Professional", "Skilled Manual"
                                             )
                              )



    df$HouseOwnerFlag = factor(df$HouseOwnerFlag, levels = c("No", "Yes"))

    df$CommuteDistance = factor(
                                            df$CommuteDistance,
                                            levels = c(
                                                           "0-1 Miles", "1-2 Miles", "2-5 Miles",
                                                           "5-10 Miles", "10+ Miles"

                                                      ), ordered = TRUE
                                       )


    df$StateProvince = factor(
                                            df$StateProvince,
                                            levels = c(
                                                           "17", "31", "41", "45", "57", "59", "62", "75", "77", "78",
                                                           "80", "91", "92", "93", "94", "95", "AB", "AL", "AZ",
                                                           "BB", "BC", "BY", "CA", "ENG", "FL", "GA", "HE", "HH",
                                                           "IL", "KY", "MA", "MD", "MN", "MO", "MS", "MT", "NC",
                                                           "NSW", "NW", "NY", "OH", "ON", "OR", "QLD", "SA", "SC",
                                                           "SL", "TAS", "TX", "UT", "VA", "VIC", "WA", "WY"
                                                      )
                                       )

    df$SalesTerritory = factor(
                                            df$SalesTerritory,
                                            levels = c(
                                                           "ST1", "ST10", "ST2", "ST3", "ST4", "ST5", "ST6", "ST7", "ST8", "ST9"
                                                      )
                                       )

    return(df)
}




