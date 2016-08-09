

# Telford_&_Wrekin

## TO CHANGE ##
Council_name <- "Telford_&_Wrekin" # String
WD <- "U:/Councils/Telford_&_Wrekin" # String
URL <- "http://www.telford.gov.uk/info/20110/budgets_and_spending/55/expenditure_over_100" # String
To_Add <- "http://www.telford.gov.uk" # String

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

# Subset by previous years
Data <- Data[grepl(as.character(year(now())-1), Data) | grepl(as.character(year(now())-2), Data)]

Data <- Data[c(1,2)]

# Append URL
for (i in 1:length(Data)){
  
  Data[i] <- paste(To_Add, Data[i], sep = "")
}

# Double parse
  
  for (i in 1:length(Data)) {
    
    Data[i] <- getURL(Data[i], .opts=curlOptions(followlocation = TRUE))
  }
  
  Data <- as.list(Data)
  
  for (i in 1:length(Data)){
    
    Data[[i]] <- htmlTreeParse(Data[[i]], useInternalNodes = TRUE)
  }
  
  for (i in 1:length(Data)) {
    
    Data[[i]] <-  unlist(xpathApply(Data[[i]], '//a[@href]', xmlGetAttr, "href"))
  }
  
# END Double parse
  ##
  
# Subset by month
Month_List <- c(month.abb, month.name)
Month_List <- paste(Month_List, collapse = "|")
Data <- lapply(Data, function(x){
    
    x[grepl(Month_List, x, ignore.case = TRUE)]
  })

# Get previous 12 months from now
Now <- as.Date(now())
Months_full <- months(seq(Now, by = "-1 month", length.out = 12))
Months_abb <- month.abb[month(seq(Now, by = "-1 month", length.out = 12))]
Months_All <- c(Months_full, Months_abb)
Months_All <- paste(Months_All, collapse = "|")

# Get the year & last year based on the last 12 months
This_Last_Year <- unique(as.character(year(seq(Now, by = "-1 month", length.out = 12))))
This_Last_Year <- paste(This_Last_Year, collapse = "|")

# Subset data according to month and year
Data <- lapply(Data, function(x){
  
  x[grepl(Months_All, x, ignore.case = TRUE) & grepl(This_Last_Year, x, ignore.case = TRUE)]
})

# Clear empty list elements
Data <- Data[lapply(Data, length) > 0]

# Convert to vector for looping in triple parse
Data <- as.vector(Data[[1]])

# Triple parse
for (i in 1:length(Data)) {
  
  Data[i] <- getURL(Data[i], .opts=curlOptions(followlocation = TRUE))
}

Data <- as.list(Data)

for (i in 1:length(Data)){
  
  Data[[i]] <- htmlTreeParse(Data[[i]], useInternalNodes = TRUE)
}

for (i in 1:length(Data)) {
  
  Data[[i]] <-  unlist(xpathApply(Data[[i]], '//a[@href]', xmlGetAttr, "href"))
}

# END triple parse

# Get data based on ".csv" or ".xlsx"
File_Type <- paste(c(".csv", ".xlsx"), collapse = "|")
Data <- lapply(Data, function(x){
  x[grepl(File_Type, x)]
})


# Get data - apply 2 functions read.csv & read.xlsx
Data <- lapply(Data, function(x) {
  
  try(data.frame(read.csv(x)))
  data.frame(read.xlsx(x))
  
  # lapply
  })

# Check names
Names_List <- lapply(Data, function(x) names(x))

# Coerce to data frame - not sure why... 
Data <- lapply(Data, function (x) {
  as.data.frame(x)
})

# Filter by list of rivals
Data <- lapply(Data, function(x){
  filter(x, rowSums(mutate_each(x, funs(grepl(Rivals, .)))) >= 1L)
})

# Subset by Columns needed
# Enter column names needed - CHANGE
Cols <- c("")
Cols <- paste(Cols, collapse = "|")
Data <- lapply(Data, function(x){
  
  x[, grepl(Cols, colnames(x), ignore.case = TRUE)]
  
})

# Clear empty
Data <- Data[lapply(Data, nrow) > 0]

# Re-order columns function
Re_Order_Cols <- function (x, Numbers) {
  
  Out <- x[, Numbers]
  Out
  #Fun
}

# Which members of list to reorder? Which order?
List_members_reorder <- c() # Numbers - CHANGE
Cols_reorder <- c() # Numbers - new order of columns - CHANGE
Data[List_members_reorder] <- lapply(Data[List_members_reorder], function (x){
  Re_Order_Cols(x, Cols_reorder)
})

# Give all elements same number of cols - 
# **Add col of NAs at front, assuming the missing data is something like the 'service area', 
# which is usually missing**
Add_Col <- function (x){
  
  cbind(X = NA, x)
  #Fun
}

# Apply Add_Col function to selected Data list members (the ones with fewest cols)
List_members_add_col <- c() # Numbers - which list members to add col of NAs - CHANGE
Data[List_members_add_col] <- lapply(Data[List_members_add_col], Add_Col)

# Put together
Data <- rbindlist(Data)

# Save as CSV
Data <- write.csv(Data, file = paste0(Council_name, '.csv'))


