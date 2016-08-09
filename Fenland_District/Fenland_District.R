
# Fenland_District

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
Council_name <- "Fenland_District" # String
WD <- "U:/Councils/Fenland_District" # String
URL_1 <- "http://www.fenland.gov.uk/article/10206/All-payments-greater-than--500---CSV-files-2015" # String
URL_2 <- "http://www.fenland.gov.uk/article/8286/All-payments-greater-than--500---CSV-files-2014"
URLs <- c(URL_1, URL_2)
To_Add <- "http://www.fenland.gov.uk/" # String
setwd(WD)

# Webscrape for multiple URLs:
Data <- lapply(URLs, getURL)

Data <- lapply(Data, function(x) {htmlTreeParse(x, useInternalNodes = TRUE)})

Data <- lapply(Data, function(x) {unlist(xpathApply(x, '//a[@href]', xmlGetAttr, "href"))})

Data <- unlist(Data)

# Subset by...
Subset_By <- "CHttpHandler"
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
# Enter column names NOT needed - CHANGE
Cols <- c("^X$")
Cols <- paste(Cols, collapse = "|")
Data <- lapply(Data, function(x){
  x[, !grepl(Cols, colnames(x), ignore.case = TRUE)]
})

# Put together
Data <- rbindlist(Data)

# Save as CSV
Data <- write.csv(Data, file = paste0(Council_name, '.csv'))


