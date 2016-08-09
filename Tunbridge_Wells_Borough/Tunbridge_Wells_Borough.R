

# Tunbridge_Wells_Borough

## TO CHANGE ##
Council_name <- "Tunbridge_Wells_Borough" # String
WD <- "U:/Councils/Tunbridge_Wells_Borough" # String
URL_1 <- "http://www.tunbridgewells.gov.uk/council/performance-and-spending/transparency-on-spend/payments-over-250?queries_fy_query_posted=1&queries_fy_query=Financial+Year+2015+-+2016"
URL_2 <- "http://www.tunbridgewells.gov.uk/council/performance-and-spending/transparency-on-spend/payments-over-250?queries_fy_query_posted=1&queries_fy_query=Financial+Year+2014+-+2015"# String
URLs <- c(URL_1, URL_2)
To_Add <- "http://www.tunbridgewells.gov.uk" # String

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
Cols <- c("Division.Description", "Organisational.Unit", "Date.Paid", "Net.Amount.in.Sterling",
          "Customer.Supplier.Description")
Cols <- paste(Cols, collapse = "|")
Data <- lapply(Data, function(x){
  x[, grepl(Cols, colnames(x), ignore.case = TRUE)]
})

Data <- do.call("rbind", Data)

# Save as CSV
Data <- write.csv(Data, file = paste0(Council_name, '.csv'))



