
# Halton_Borough

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

## TO CHANGE ##
Council_name <- "Halton_Borough" # String
WD <- "U:/Councils/Halton_Borough" # String
URL <- "http://www4.halton.gov.uk/Pages/councildemocracy/opendata/Payments-over-500.aspx" # String
To_Add <- "http://www4.halton.gov.uk" # String
setwd(WD)

## Webscrape
Data <- getURL(URL)

Data <- htmlTreeParse(Data, useInternalNodes = TRUE)

Data <- unlist(xpathApply(Data, '//a[@href]', xmlGetAttr, "href"))

# Subset by...
Subset_By <- "csv"
Data <- Data[grepl(Subset_By, Data, ignore.case = TRUE)]

# Subset by...
Subset_By <- "500"
Data <- Data[grepl(Subset_By, Data, ignore.case = TRUE)]

# Add start of URL
Data <- unlist(lapply(Data, function(x){paste(To_Add, x, sep = "")}))

## Subset by month_V2 ##

# Get previous 18 months from now & subset
Last_18_Mo <- seq.Date(as.Date(now()), as.Date(now() -months(18)), length.out = 18)
Last_18_Mo <- as.character(as.yearmon(Last_18_Mo))
Last_18_Mo <- c(as.character(format(as.yearmon(Last_18_Mo), format = "%b%Y")),
                as.character(format(as.yearmon(Last_18_Mo), format = "%b %Y")),
                as.character(format(as.yearmon(Last_18_Mo), format = "%b%y")),
                as.character(format(as.yearmon(Last_18_Mo), format = "%b %y")),
                as.character(format(as.yearmon(Last_18_Mo), format = "%B%Y")),
                as.character(format(as.yearmon(Last_18_Mo), format = "%B %Y")),
                as.character(format(as.yearmon(Last_18_Mo), format = "%B%y")),
                as.character(format(as.yearmon(Last_18_Mo), format = "%B %y")), 
                "sept15", "sept 15", "sept2015", "sept 2015",
                "sept14", "sept 16", "sept2016", "sept 2016"
)
Last_18_Mo <- paste(Last_18_Mo, collapse = "|")

# Subset data according to month and year
Data <- unlist(lapply(Data, function(x){
  x[grepl(Last_18_Mo, x, ignore.case = TRUE)]
}))



# Repair URL
Pattern <- "£"
Replacement <- "%C2%A3"
Data[10] <- gsub(Pattern, Replacement, Data[10]) 



## END ## Subset by month_V2 ##

# Read data into list of data frames
# Skip first line?
Skip <- 0 # 1 = yes, skip the first x number of lines - CHANGE
Skip_Number_of_Lines <-  1 # One Number - CHANGE
if (Skip == 1){
  Data <- lapply(Data, function(x) data.frame(read.csv(x, stringsAsFactors = FALSE, skip = Skip_Number_of_Lines)))
} else {
  Data <- lapply(Data, function(x) data.frame(read.csv(x, stringsAsFactors = FALSE)))
}

# Filter by list of rivals
Data <- lapply(Data, function(x){
  filter(x, rowSums(mutate_each(x, funs(grepl(Rivals, .)))) >= 1L)
})

# Clear empty list elements
Data <- Data[lapply(Data, length) > 0]
Data <- Data[lapply(Data, nrow) > 0]

# Check names
Names_List <- lapply(Data, function(x) names(x))

# Coerce to data frame - not sure why... 
Data <- lapply(Data, function (x) {
  as.data.frame(x)
})

# Subset by Columns needed
# Enter column names NOT needed - CHANGE
Cols <- c("Transaction.number", "Purpose.of.Expenditure", "Trans.No", "")
Cols <- paste(Cols, collapse = "|")
Data <- lapply(Data, function(x){
  x[, !grepl(Cols, colnames(x), ignore.case = TRUE)]
})

# Re-order columns function
Re_Order_Cols <- function (x, Numbers) {
  Out <- x[, Numbers]
  Out
  #Fun
}


# Give all elements same number of cols - 
# **Add col of NAs at front, assuming the missing data is something like the 'service area', 
# which is usually missing**
Add_Col <- function (x){
  cbind(X = NA, x)
  #Fun
}

# Apply Add_Col function to selected Data list members (the ones with fewest cols)
List_members_add_col <- c(3) # Numbers - which list members to add col of NAs - CHANGE
Data[List_members_add_col] <- lapply(Data[List_members_add_col], Add_Col)
# REPEAT
# Apply Add_Col function to selected Data list members (the ones with fewest cols)
List_members_add_col <- c(3) # Numbers - which list members to add col of NAs - CHANGE
Data[List_members_add_col] <- lapply(Data[List_members_add_col], Add_Col)


# Which members of list to reorder? Which order?
List_members_reorder <- c(3) # Numbers - CHANGE
Cols_reorder <- c(1, 3, 2, 4, 5) # Numbers - new order of columns - CHANGE
Data[List_members_reorder] <- lapply(Data[List_members_reorder], function (x){
  Re_Order_Cols(x, Cols_reorder)
})


# Put together
Data <- rbindlist(Data)

# Save as CSV
Data <- write.csv(Data, file = paste0(Council_name, '.csv'))



