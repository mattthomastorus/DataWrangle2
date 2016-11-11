# Foundations of Data Science - Data Wrangling Exercise 2
# 2016-11-11, Matt Thomas

library(dplyr)

# 0.0: Load the data in RStudio
titanicdata= read.csv("titanic_original.csv")

# 0.1: convert data to tbl
# appears to be a 'null row' on the bottom (possible Excel->csv problem?) - remove it by using fact that 'survived' is otherwise fully populated
titanicdata_tbl <- dplyr::tbl_df(titanicdata[-which(with(titanicdata,is.na(titanicdata$survived))),])

#1 Port of embarkation - fill gaps with S for Southampton
titanicdata_tbl[titanicdata_tbl$embarked=="", "embarked"] <- "S"

#2 Age - lots of gaps in the age column, fill this with the mean of the rest of the values
# Alternatives to mean or median:
#   If the data was particularly gappy (more blanks than not maybe?) then taking a mean or median might be inappropriate
#   It might be more accurate to use a mean or median having clustered the observations according to other available variables?
#   Random sampling with the existing data might be a good method to introduce values. 
titanicdata_tbl[is.na(titanicdata_tbl$age), "age"] <- titanicdata_tbl %>% summarise(avg = mean(age, na.rm = TRUE))

#3 Lifeboat - fill empty boat observation variables with NA
titanicdata_tbl[titanicdata_tbl$boat=="", "boat"] <- NA

#4 Cabin - It wouldn't make sense to fill in missing cabin values as it would almost certainly be meaningless
#   and would in fact skew any analysis that attempted to use it. One possible reasonable way of filling in this data
#   was if a person had relatives on board who could be identified (same surname perhaps?) and who did have a non-blank 
#   cabin variable.
# Why would a cabin variable be blank in the first place? Some possibilities:
#    - some tickets maybe cabinless (or cabin wasn't recorded), although it might be expected that these cases would be associated with 2nd or 3rd class
#        tickets, whereas there are a number of 1st class tickets that match this situation as well. That said, the vast
#        majority of missing cabin values appear to be for non-1st class passengers, so this theory looks to be reasonable
#    - cabin is associated with the 'party leader' not with every person on the booking/ticket.
#    - it might be a simple corruption of data - perhaps cabin data has been mistyped, overwritten, associated with another person

# Create a new column to indicate presence of a cabin number.
titanicdata_tbl <- titanicdata_tbl %>% dplyr::mutate(has_cabin_number = ifelse(cabin =="",0,1))

#5 write the clean data
titanicdata_tbl %>% write.csv(file="titanic_clean.csv")