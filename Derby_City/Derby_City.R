

# Derby_City

## TO CHANGE ##
Council_name <- "Derby_City" # String
WD <- "U:/Councils/Derby_City" # String
URL <- "http://www.derby.gov.uk/council-and-democracy/open-data-and-freedom-of-information/supplier-payments/" # String
To_Add <- "http://www.derby.gov.uk" # String

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

## Webscrape
Data <- getURL(URL)

Data <- htmlTreeParse(Data, useInternalNodes = TRUE)

Data <- unlist(xpathApply(Data, '//a[@href]', xmlGetAttr, "href"))


# Subset by "csv"
Data <- Data[grepl("csv", Data, ignore.case = TRUE)]

# Add start of URL
Data <- unlist(lapply(Data, function(x){paste(To_Add, x, sep = "")}))


## Subset by month_V2 ##

# Get previous 18 months from now & subset
Last_18_Mo <- seq.Date(as.Date(now()), as.Date(now() -months(18)), length.out = 18)
Last_18_Mo <- as.character(as.yearmon(Last_18_Mo))
Last_18_Mo <- c(as.character(format(as.yearmon(Last_18_Mo), format = "%b%Y")),
                as.character(format(as.yearmon(Last_18_Mo), format = "%b %Y")),
                as.character(format(as.yearmon(Last_18_Mo), format = "%b-%Y")),
                as.character(format(as.yearmon(Last_18_Mo), format = "%b%y")),
                as.character(format(as.yearmon(Last_18_Mo), format = "%b %y")),
                as.character(format(as.yearmon(Last_18_Mo), format = "%b-%y")),
                as.character(format(as.yearmon(Last_18_Mo), format = "%B%Y")),
                as.character(format(as.yearmon(Last_18_Mo), format = "%B %Y")),
                as.character(format(as.yearmon(Last_18_Mo), format = "%B-%Y")),
                as.character(format(as.yearmon(Last_18_Mo), format = "%B%y")),
                as.character(format(as.yearmon(Last_18_Mo), format = "%B %y")),
                as.character(format(as.yearmon(Last_18_Mo), format = "%B-%y")),
                "sept15", "sept 15", "sept2015", "sept 2015", "sept-2015",
                "sept14", "sept 16", "sept2016", "sept 2016", "sept-2016"
)
Last_18_Mo <- paste(Last_18_Mo, collapse = "|")

# Subset data according to month and year
Data <- unlist(lapply(Data, function(x){
  x[grepl(Last_18_Mo, x, ignore.case = TRUE)]
}))

## END ## Subset by month_V2 ##

######

# Read data into list of data frames
# Skip first line?
Skip <- 0 # 1 = yes, skip the first x number of lines - CHANGE
Skip_Number_of_Lines <-  1 # One Number - CHANGE
if (Skip == 1){
  Data <- lapply(Data, function(x) data.frame(read.csv(x, stringsAsFactors = FALSE, skip = Skip_Number_of_Lines)))
} else {
  Data <- lapply(Data, function(x) data.frame(read.csv(x, stringsAsFactors = FALSE, 
                                                       header = TRUE)))
}

# List of lines to eliminate
# Element number, lines to eliminate
# 1, 1
# 2, 2
# 3, 1
# 4, 1 
# 5, 1
# 6, 3
# 7, 2
# 8, 2
# 9, 3
# 10, 1
# 11, 3
# 12, 3
# 13, 5
# 14, 3
Headers <- c(1, 2, 1, 1, 1, 3, 2, 2, 3, 1, 3, 3, 5, 3)

for (i in 1:length(Data)){
  Data[[i]] <- Data[[i]][-c(1:Headers[i]),]
}

# Replace column names with first row
Replace_Colnames <- function(x){
  colnames(x) <- x[1,]
  x <- x[-1, ]     
}
Data <- lapply(Data, Replace_Colnames)

Test <- Data

Names_List <- lapply(Data, function(x) names(x))

# Subset by Columns needed
# Enter column names needed - CHANGE
Cols <- c("PAYMENT_DATE", "Effective_Date", "Amount", "vendor_name", "directorate", 
          "SUBJECTIVE_DESCRIPTION", "purpose of spend")
Cols <- paste(Cols, collapse = "|")
Data <- lapply(Data, function(x){
  
  x[, grepl(Cols, colnames(x), ignore.case = TRUE)]
  
})

Data <- lapply(Data, function(x){
  filter(x, rowSums(mutate_each(x, funs(grepl(Rivals, .)))) >= 1L)
})

# Clear empty list elements
Data <- Data[lapply(Data, length) > 0]
Data <- Data[lapply(Data, nrow) > 0]

# Re-order columns function
Re_Order_Cols <- function (x, Numbers) {
  Out <- x[, Numbers]
  Out
  #Fun
}

# Which members of list to reorder? Which order?
List_members_reorder <- c(4) # Numbers - CHANGE
Cols_reorder <- c(3, 4, 1, 2, 5) # Numbers - new order of columns - CHANGE
Data[List_members_reorder] <- lapply(Data[List_members_reorder], function (x){
  Re_Order_Cols(x, Cols_reorder)
})


Take_Out_Col <- function(x, Col_Num){
  x[,-Col_Num]
}

Data[c(1, 2)] <- lapply(Data[c(1, 2)], function(x){Take_Out_Col(x, 4)})

Data <- rbindlist(Data)

# Save as CSV
Data <- write.csv(Data, file = paste0(Council_name, '.csv'))


