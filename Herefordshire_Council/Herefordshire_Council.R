
# Herefordshire Council


## TO CHANGE ##
Council_name <- "Herefordshire_Council" # String
WD <- "U:/Councils/Herefordshire_Council" # String
URL <- "https://www.herefordshire.gov.uk/government-citizens-and-rights/democracy/transparency-contracts-and-expenditure/" # String

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

Subset_CSV_URLs <- c(seq(35, 57, 2)) # Numbers - CHANGE
Data <- Data[Subset_CSV_URLs]

# Attach start of URL
URL_Start <- "https://www.herefordshire.gov.uk"
for (i in 1:length(Data)){
  
  Data[i] <- paste0(URL_Start, Data[i])
}

# Take out weird Â symbol
for (i in 1:length(Data)){
  
  Data[i] <- gsub("Â", "%C2%A3", Data[i])
}

# Take out £ sign
for (i in 1:length(Data)){
  
  Data[i] <- gsub("£", "", Data[i])
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

# Subset by Columns needed
# Enter column names needed - CHANGE
Cols <- c("Date.Paid", "Amount", "Supplier.Name", "Expense.Area", "Cipfa.T.")
Cols <- paste(Cols, collapse = "|")
Data <- lapply(Data, function(x){
  
  x[, grepl(Cols, colnames(x), ignore.case = TRUE)]
  
})

# Clear empty
Data <- Data[lapply(Data, nrow) > 0]

# Put together
Data <- rbindlist(Data)

# Save as CSV
Data <- write.csv(Data, file = paste0(Council_name, '.csv'))


