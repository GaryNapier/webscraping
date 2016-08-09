

# Bath_and_North_East_Somerset

## TO CHANGE ##
Council_name <- "Bath_and_North_East_Somerset" # String
WD <- "U:/Councils/Bath_and_North_East_Somerset" # String
URL <- "http://www.bathnes.gov.uk/services/your-council-and-democracy/data-protection-and-freedom-information/transparency/expenditure" # String
To_Add <- "http://www.bathnes.gov.uk" # String

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

## Subset by month 
# Get previous 18 months from now & subset
Last_18_Mo <- seq.Date(as.Date(now()), as.Date(now() -months(18)), length.out = 18)
Last_18_Mo <- as.character(as.yearmon(Last_18_Mo))
Last_18_Mo <- c(as.character(format(as.yearmon(Last_18_Mo), format = "%b%Y")),
                as.character(format(as.yearmon(Last_18_Mo), format = "%b%y")), 
                as.character(format(as.yearmon(Last_18_Mo), format = "%B%Y")), 
                as.character(format(as.yearmon(Last_18_Mo), format = "%B%y")), "sept15"
)
Last_18_Mo <- paste(Last_18_Mo, collapse = "|")

# Subset data according to month and year
Data <- unlist(lapply(Data, function(x){
  x[grepl(Last_18_Mo, x, ignore.case = TRUE)]
}))

# Read data into list of data frames
# Skip first line?
Skip <- 0 # 1 = yes, skip the first x number of lines - CHANGE
Skip_Number_of_Lines <-  1 # One Number - CHANGE
if (Skip == 1){
  Data <- lapply(Data, function(x) data.frame(read.csv(x, skip = Skip_Number_of_Lines)))
} else {
  Data <- lapply(Data, function(x) data.frame(read.csv(x)))
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

# Put together
Data <- rbindlist(Data)

# Coerce to data frame
Data <- as.data.frame(Data)

# Subset by Columns needed
# Enter column names needed - CHANGE
Cols <- c("Supplier.Name", "Date", "Amount", "Service.Area.Categorisation", "Expenses.Type")
Cols <- paste(Cols, collapse = "|")
Data <- Data[grepl(Cols, colnames(Data), ignore.case = TRUE)]

# Save as CSV
Data <- write.csv(Data, file = paste0(Council_name, '.csv'))


