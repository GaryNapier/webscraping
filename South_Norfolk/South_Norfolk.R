

# South_Norfolk 


# General script - Get council data

## TO CHANGE ##
Council_name <- "South_Norfolk" # String
WD <- "U:/Councils/South_Norfolk" # String
URL <- "http://www.south-norfolk.gov.uk/democracy/4704.asp" # String
To_Add <- "http://www.south-norfolk.gov.uk" # String

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

# Subset by year

Data <- Data[grepl(paste(c(year(now() -years(1)), year(now())), collapse = "|"), Data)]

# Get zip files
temp <- tempfile()
download.file(Data, temp)
Data <- unzip(temp)
Data <- lapply(Data, function(x) data.frame(read.csv(x)))

# Check names
Names_List <- lapply(Data, function(x) names(x))

# Filter by list of rivals
Data <- lapply(Data, function(x){
  filter(x, rowSums(mutate_each(x, funs(grepl(Rivals, .)))) >= 1L)
})

# Clear empty list elements
Data <- Data[lapply(Data, nrow) > 0]

# Subset by Columns needed
# Enter column names needed - CHANGE
Cols <- c("date", "beneficiary", "amount", "expense.type", "description", "department",
          "merchant.category", "supplier.name", "amount....")
Cols <- paste(Cols, collapse = "|")
Data <- lapply(Data, function(x){
  x[, grepl(Cols, colnames(x), ignore.case = TRUE)]
})

# Re-order columns function
Re_Order_Cols <- function (x, Numbers) {
  Out <- x[, Numbers]
  Out
  #Fun
}

# Which members of list to reorder? Which order?
List_members_reorder <- c(2) # Numbers - CHANGE
Cols_reorder <- c(1, 4, 3, 2, 5) # Numbers - new order of columns - CHANGE
Data[List_members_reorder] <- lapply(Data[List_members_reorder], function (x){
  Re_Order_Cols(x, Cols_reorder)
})

# Put together
Data <- rbindlist(Data)

# Save as CSV
Data <- write.csv(Data, file = paste0(Council_name, '.csv'))


