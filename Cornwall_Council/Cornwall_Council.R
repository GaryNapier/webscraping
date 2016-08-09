

# Cornwall_Council

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
Council_name <- "Cornwall_Council" # String
WD <- "U:/Councils/Cornwall_Council" # String
URL <- "http://www.cornwall.gov.uk/council-and-democracy/council-spending-and-budgets/payments-to-suppliers-where-the-invoiced-payments-are-greater-than-or-equal-to-500/" # String
To_Add <- "http://www.cornwall.gov.uk" # String
setwd(WD)

## Webscrape
Data <- getURL(URL)

Data <- htmlTreeParse(Data, useInternalNodes = TRUE)

Data <- unlist(xpathApply(Data, '//a[@href]', xmlGetAttr, "href"))

# Subset by...
Subset_By <- "csv"
Data <- Data[grepl(Subset_By, Data, ignore.case = TRUE)]

# Add start of URL
Data <- unlist(lapply(Data, function(x){paste(To_Add, x, sep = "")}))

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
Cols <- c("Directorate.Name", "Service.Line.Name", "Supplier.Name", "Payment.Date",
          "Invoiced.Line.Amount..n.", "Invoiced.Line.Amount")
Cols <- paste(Cols, collapse = "|")
Data <- lapply(Data, function(x){
  x[, grepl(Cols, colnames(x), ignore.case = TRUE)]
})

# Put together
Data <- rbindlist(Data)

# Save as CSV
Data <- write.csv(Data, file = paste0(Council_name, '.csv'))


