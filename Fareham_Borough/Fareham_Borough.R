
# Fareham_Borough

## TO CHANGE ##
Council_name <- "Fareham_Borough" # String
WD <- "U:/Councils/Fareham_Borough" # String
URL <- "http://www.fareham.gov.uk/about_the_council/financial_information/expenditurover500.aspx" # String
To_Add <- "http://www.fareham.gov.uk/" # String

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


## Subset by month 
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
This_Last_Year <- unique(as.character(year(seq(Now, by = "-1 month", length.out = 18))))
This_Last_Year <- paste(This_Last_Year, collapse = "|")

# Subset data according to month and year
Data <- lapply(Data, function(x){
  
  x[grepl(Months_All, x, ignore.case = TRUE) & grepl(This_Last_Year, x, ignore.case = TRUE)]
})

# Clear empty
Data <- Data[lapply(Data, nrow) > 0]
Data <- Data[lapply(Data, length) > 0]#

# unlist
Data <- unlist(Data)

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

# Put together
Data <- rbindlist(Data)

# Coerce to data frame - not sure why... 
Data <- as.data.frame(Data)

# Subset by Columns needed
# Enter column names needed - CHANGE
Cols <- c("^Service\\.Division$", "^Organisational\\.Unit$", "Date", "Amount", "^Supplier\\.name$")
Cols <- paste(Cols, collapse = "|")

Data <- Data[grepl(Cols, colnames(Data), ignore.case = TRUE)]

# Save as CSV
Data <- write.csv(Data, file = paste0(Council_name, '.csv'))


