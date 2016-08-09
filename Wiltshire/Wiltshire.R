

# Wiltshire

## TO CHANGE ##
Council_name <- "Wiltshire" # String
WD <- "U:/Councils/Wiltshire" # String
URL <- "http://www.wiltshire.gov.uk/council/howthecouncilworks/budgetsandspending/paymentssalariesandexpenses.htm" # String
To_Add <- "http://www.wiltshire.gov.uk/" # String

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

# Subset by "payments"
Data <- Data[grepl("payments", Data, ignore.case = TRUE)]

## Subset by last 12 months
Data <- Data[1:12]

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

# Coerce to date frame
Data <- as.data.frame(Data)

# Subset by Columns needed
Data <- Data[, grepl(Cols, colnames(Data), ignore.case = TRUE)]


# Save as CSV
Data <- write.csv(Data, file = paste0(Council_name, '.csv'))


