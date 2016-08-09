
# North_Lincolnshire_Council

## TO CHANGE ##
Council_name <- "North_Lincolnshire_Council" # String
WD <- "U:/Councils/North_Lincolnshire_Council" # String
URL_1 <- "http://www.northlincs.gov.uk/your-council/about-your-council/policy-and-budgets/supplier-payments/?p=1" # String
URL_2 <- "http://www.northlincs.gov.uk/your-council/about-your-council/policy-and-budgets/supplier-payments/?p=2"
URLs <- c(URL_1, URL_2)
To_Add <- "http://www.northlincs.gov.uk/your-council/about-your-council/policy-and-budgets/supplier-payments/" # String

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
Data <- lapply(URLs, getURL)

Data <- lapply(Data, function(x) {htmlTreeParse(x, useInternalNodes = TRUE)})

Data <- lapply(Data, function(x) {unlist(xpathApply(x, '//a[@href]', xmlGetAttr, "href"))})

Data <- unlist(Data)

# Subset by "entryid"
Data <- Data[grepl("entryid", Data, ignore.case = TRUE)]

# Add start of URL
Data <- unlist(lapply(Data, function(x){paste(To_Add, x, sep = "")}))

####

# Parse again:
Data <- lapply(Data, getURL)

Data <- lapply(Data, function(x) {htmlTreeParse(x, useInternalNodes = TRUE)})

Data <- lapply(Data, function(x) {unlist(xpathApply(x, '//a[@href]', xmlGetAttr, "href"))})

Data <- unlist(Data)

# Subset by "csv"
Data <- unique(Data[grepl("csv", Data, ignore.case = TRUE)])

# Add start of URL
To_Add <- "http://www.northlincs.gov.uk"
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

## OPTIONAL ##
# Set ColNames as first row 
Data <- lapply(Data, function(x){
  x[which(!x[,1] == ""),]
})

Data <- lapply(Data, function(x){
  colnames(x) <- x[1, ]
  x <- x[-1, ]
})
#######

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

# Save as CSV
Data <- write.csv(Data, file = paste0(Council_name, '.csv'))



