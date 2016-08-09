
# Stoke_On_Trent_City

## TO CHANGE ##
Council_name <- "Stoke_On_Trent_City" # String
WD <- "U:/Councils/Stoke_On_Trent_City" # String
URL_1 <- "http://www.stoke.gov.uk/ccm/navigation/council-and-democracy/finance/transparency-2015/" # String
URL_2 <- "http://www.stoke.gov.uk/ccm/navigation/council-and-democracy/finance/transparency-2014/"
URLs <- c(URL_1, URL_2)
To_Add <- "http://www.stoke.gov.uk" # String

Rivals <- c("JORDAN PUBLISHING",
            "KLEWLER",
            "PRACTICAL LAW",
            "SWEET & MAXWELL",
            "THOMSON REUTER",
            "LAWTEL",
            "LEGALEASE",
            "THOMSON REUTERS",
            "WEST PUBLISHING",
            "jordan publishing",
            "klewler",
            "practical law",
            "sweet & maxwell",
            "thomson reuter",
            "lawtel",
            "legalease",
            "thomson reuters",
            "west publishing",
            "Jordan Publishing",
            "Klewler",
            "Practical Law",
            "Sweet & Maxwell",
            "Thomson Reuter",
            "Lawtel",
            "Legalease",
            "Thomson Reuters",
            "West Publishing")
Rivals <- paste(Rivals, collapse = "|")

setwd(WD)

####

Files <- list.files(WD, pattern = "*.csv")

Data <- lapply(Files, function(x){read.csv(x, skip = 1)})

# Filter by list of rivals
Data <- lapply(Data, function(x){
  filter(x, rowSums(mutate_each(x, funs(grepl(Rivals, .)))) >= 1L)
})

# Clear empty list elements
Data <- Data[lapply(Data, length) > 0]
Data <- Data[lapply(Data, nrow) > 0]

# Check names
Names_List <- lapply(Data, function(x) names(x))

# Subset by Columns needed
# Enter column names needed - CHANGE
Cols <- c("supplier\\.name", "amount", "Date", "Expenditure\\.Category\\.Lvl\\.6", 
          "Service\\.Label", "Total")
Cols <- paste(Cols, collapse = "|")
Data <- lapply(Data, function(x){
  x[, grepl(Cols, colnames(x), ignore.case = TRUE)]
})

# Re-order columns function
Re_Order_Cols <- function (x, Numbers) {
  Out <- x[, Numbers]
  Out
  #Fun
}

# Which members of list to reorder? Which order?
List_members_reorder <- c(2) # Numbers - CHANGE
Cols_reorder <- c(1, 2, 3, 5, 4) # Numbers - new order of columns - CHANGE
Data[List_members_reorder] <- lapply(Data[List_members_reorder], function (x){
  Re_Order_Cols(x, Cols_reorder)
})

# Put together
Data <- rbindlist(Data)

# Save as CSV
Data <- write.csv(Data, file = paste0(Council_name, '.csv'))



  