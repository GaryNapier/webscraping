

# Brighton_&_Hove_City

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
Council_name <- "Brighton_&_Hove_City" # String
WD <- "U:/Councils/Brighton_&_Hove_City" # String
URL_1 <- "http://www.brighton-hove.gov.uk/content/council-and-democracy/council-finance/payments-over-%C2%A3250" # String
URL_2 <- "https://www.brighton-hove.gov.uk/content/council-and-democracy/council-finance/payments-over-250-made-previous-years" 
URLs <- c(URL_1, URL_2)
To_Add <- "https://www.brighton-hove.gov.uk/" # String
setwd(WD)

# Webscrape for multiple URLs:
Data <- lapply(URLs, getURL)

Data <- lapply(Data, function(x) {htmlTreeParse(x, useInternalNodes = TRUE)})

Data <- lapply(Data, function(x) {unlist(xpathApply(x, '//a[@href]', xmlGetAttr, "href"))})

Data <- unlist(Data)

# Subset by...
Subset_By <- "\\.csv"
Data <- Data[grepl(Subset_By, Data, ignore.case = TRUE)]

## Subset by month
Data <- Data[1:18]

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


# Subset by Columns needed
# Enter column names needed - CHANGE
Cols <- c("^Service\\.Label$", "^CCN\\.43\\.TBM\\.Section$", "Date", "^Net\\.amount$",
          "^Creditor\\.Name$", "Creditor")
Cols <- paste(Cols, collapse = "|")
Data <- lapply(Data, function(x){
  x[, grepl(Cols, colnames(x), ignore.case = TRUE)]
})

# Put together
Data <- rbindlist(Data)

# Save as CSV
Data <- write.csv(Data, file = paste0(Council_name, '.csv'))


