

# Slough_borough_council

## TO CHANGE ##
Council_name <- "Slough_borough_council" # String
WD <- "U:/Councils/Slough_borough_council" # String
URL_1 <- "http://www.slough.gov.uk/council/performance-and-spending/payment-reports-april-2015-to-march-2016.aspx" # String
URL_2 <- "http://www.slough.gov.uk/council/performance-and-spending/payment-reports-april-2014-to-march-2015.aspx"
To_Add <- "http://www.slough.gov.uk" # String

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
URLs <- c(URL_1, URL_2)

Data <- lapply(URLs, function(x) getURL(x))

Data <- lapply(Data, function(x) htmlTreeParse(x, useInternalNodes = TRUE))

Data <- lapply(Data, function(x) unlist(xpathApply(x, '//a[@href]', xmlGetAttr, "href")))

# Subset by ".csv"
Data <- unlist(lapply(Data, function(x) {
  x[grepl(".csv", x, ignore.case = TRUE)]
}))

# Subset by month:
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

# Clear empty
Data <- Data[lapply(Data, length) > 0]

# Append URL
Data <- unlist(lapply(Data, function (x) paste0(To_Add, x)))

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

# Subset by Columns needed
# Enter column names needed - CHANGE
Cols <- c("Cost.Centre.Code", "Vendor.Number", "Transaction.Number", "Body.Name")
Cols <- paste(Cols, collapse = "|")
Data <- lapply(Data, function(x){
  x[, !grepl(Cols, colnames(x), ignore.case = TRUE)]
})

# Clear empty list elements
Data <- Data[lapply(Data, nrow) > 0]

# Put together
Data <- rbindlist(Data)

# Save as CSV
Data <- write.csv(Data, file = paste0(Council_name, '.csv'))


