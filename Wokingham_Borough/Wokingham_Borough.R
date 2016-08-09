

# Wokingham_Borough

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
Council_name <- "Wokingham_Borough" # String
WD <- "U:/Councils/Wokingham_Borough" # String
URL <- "http://www.wokingham.gov.uk/council-and-meetings/open-data/datasets-and-open-data/?categoryesctl7900027=7776" # String
To_Add <- "http://www.wokingham.gov.uk" # String
setwd(WD)

## Webscrape
Data <- getURL(URL)

Data <- htmlTreeParse(Data, useInternalNodes = TRUE)

Data <- unlist(xpathApply(Data, '//a[@href]', xmlGetAttr, "href"))

# Subset by...
Subset_By <- "Attachment"
Data <- Data[grepl(Subset_By, Data, ignore.case = TRUE)]

# Add start of URL
Data <- unlist(lapply(Data, function(x){paste(To_Add, x, sep = "")}))

# Subset further - see website
Data <- Data[c(2, 5, 6)]

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
Cols <- c("Pay.Date", "Payment.Amount", "Service.Area", "service", "Supplier", 
          "^Payment\\.Total\\.\\.Gross\\.$", "^Account\\.Payable\\.\\.\\.Account\\.Receivable\\.ID$", 
          "^Payment\\.Date$", "Sub.Desc", "Description")
Cols <- paste(Cols, collapse = "|")
Data <- lapply(Data, function(x){
  x[, grepl(Cols, colnames(x), ignore.case = TRUE)]
})

# Put together
names(Data[[3]]) <- names(Data[[1]])
Data <- do.call("rbind", Data)

# Save as CSV
Data <- write.csv(Data, file = paste0(Council_name, '.csv'))


