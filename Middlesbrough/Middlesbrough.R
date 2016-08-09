

# Middlesbrough

## TO CHANGE ##
Council_name <- "Middlesbrough" # String
WD <- "U:/Councils/Middlesbrough" # String
URL <- "http://www.middlesbrough.gov.uk/index.aspx?articleid=2059" # String
To_Add <- "http://www.middlesbrough.gov.uk/" # String

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

# Subset by "CHttpHandler"

Data <- Data[grepl("CHttpHandler", Data)]

# Add start of URL
Data <- unlist(lapply(Data, function(x){paste(To_Add, x, sep = "")}))

# Subset by alternating
Data <- Data[seq(2, length(Data), 2)]

# Get last 12 months 
Data <- Data[1:12]

Data <- lapply(Data, function(x) data.frame(read.csv(x)))

# Import xls files
temp <- list.files(pattern="*.csv")
files <- lapply(temp, read.csv)

# Attach imported files to Data list
Data <- list.append(Data, files[[1]], files[[2]])

# Filter by list of rivals
Data <- lapply(Data, function(x){
  filter(x, rowSums(mutate_each(x, funs(grepl(Rivals, .)))) >= 1L)
})

# Clear empty list elements
Data <- Data[lapply(Data, nrow) > 0]

# Check names
Names_List <- lapply(Data, function(x) names(x))

# Subset by Columns needed
# Enter column names needed - CHANGE
Cols <- c("Expenditure.Type", "Supplier.Name", "payment.date", "Net.Amount", 
          "Service.Division", "Service.Label")
Cols <- paste(Cols, collapse = "|")
Data <- lapply(Data, function(x){
  x[, grepl(Cols, colnames(x), ignore.case = TRUE)]
})

# Put together
Data <- rbindlist(Data)

# Save as CSV
Data <- write.csv(Data, file = paste0(Council_name, '.csv'))


