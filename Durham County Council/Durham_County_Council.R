
# Durham_County_Council

## TO CHANGE ##
Council_name <- "Durham_County_Council" # String
WD <- "U:/Councils/Durham County Council" # String
URL_1 <- "http://www.durham.gov.uk/article/2437/Payments-to-suppliers-over-500"
URL_2 <- "http://www.durham.gov.uk/article/6252/Payments-to-suppliers-over-500-201415"# String
URLs <- c(URL_1, URL_2)
To_Add <- "http://www.durham.gov.uk/" # String

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

# Subset by "csv"
Data <- Data[grepl("csv", Data, ignore.case = TRUE)]

####

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

# Subset by Columns needed
# Enter column names needed - CHANGE
Cols <- c("^X$")
Cols <- paste(Cols, collapse = "|")
Data <- lapply(Data, function(x){
  x[, !grepl(Cols, colnames(x), ignore.case = TRUE)]
})

#####

Data <- do.call("rbind", Data)

# Coerce to data frame - not sure why... 
Test <- lapply(Data, function (x) {
  as.data.frame(x)
})

# Subset by Columns needed
# Enter column names needed - CHANGE
Cols <- c("Service.Division", "Payment.Date", "Amount.Exc.Vat", "Supplier.Name", "Service.Area")
Cols <- paste(Cols, collapse = "|")
Data <- Data[, grepl(Cols, colnames(Data), ignore.case = TRUE)]

# Save as CSV
Data <- write.csv(Data, file = paste0(Council_name, '.csv'))


