

## Plymouth City Council

## TO CHANGE ##
Council_name <- "Plymouth_City" # String
WD <- "U:/Councils/Plymouth City" # String
URL <- "http://www.plymouth.gov.uk/spendover500" # String
To_Add <- "http://www.plymouth.gov.uk/" # String

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

## Subset by getting ".csv"
Data <- Data[grepl(".csv", Data)]

# Last 12 months
Data <- Data[1:12]

# Add URL:
for (i in c(1:8, 11, 12)) {
  
  Data[i] <- paste(To_Add, Data[i], sep = "")
}

# Read data into list of data frames
# Skip first line?
Skip <- 0 # 1 = yes, skip the first x number of lines - CHANGE
Skip_Number_of_Lines <-  1 # One Number - CHANGE
if (Skip == 1){
  Data <- lapply(Data, function(x) data.frame(read.csv(x, skip = Skip_Number_of_Lines)))
} else {
  Data <- lapply(Data, function(x) data.frame(read.csv(x)))
}

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

# Clear empty
Data <- Data[lapply(Data, nrow) > 0]

# Subset by Columns needed
# Enter column names needed - CHANGE
Cols <- c("Expenditure.category", "Detailed.Expenses.type", "Date", "Amount", "Supplier.Name")
Cols <- paste(Cols, collapse = "|")
Data <- lapply(Data, function(x){
  
  x[, grepl(Cols, colnames(x), ignore.case = TRUE)]
  
})

# Put together
Data <- rbindlist(Data)

# Save as CSV
Data <- write.csv(Data, file = paste0(Council_name, '.csv'))


