

# West_Berkshire

## TO CHANGE ##
Council_name <- "West_Berkshire" # String
WD <- "U:/Councils/West_Berkshire" # String
URL <- "http://info.westberks.gov.uk/index.aspx?articleid=28367" # String
To_Add <- "http://info.westberks.gov.uk/" # String

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
Data <- Data[grepl("CHttpHandler", Data, ignore.case = TRUE)]
Data <- Data[1:18]

# Add start of URL
Data <- unlist(lapply(Data, function(x){paste(To_Add, x, sep = "")}))

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

# Function removing NA
Rem_NA_Cols <- function(x){
 x <- x[, colSums(is.na(x)) != nrow(x)]
 x
}

# Get rid of NA cols
Data <- lapply(Data, Rem_NA_Cols)


#########################

Test <- Data

# Subset by Columns NOT needed
# Enter column names needed - CHANGE
Cols <- c("Service.Code", "Expenditure..Category", "Expenditure.code", 
          "Transaction.number", "Capital.and.revenue", "Narrative", "Voucher.Type", 
          "Cost.Centre", "Sequence.Number", "Client", "Accrel1", "CFR", "CFR\\.T\\.", "Period", 
          "^X14$", "^X16$", "^X12$", "^X\\.1$", "^X\\.3$",
          "^X\\.2$", "^X9$", "^X8$",  "^X4$", "^X\\.4$", "^X\\.5$", "^X$", "^service$")
Cols <- paste(Cols, collapse = "|")
Data <- lapply(Data, function(x){
  x[, !grepl(Cols, colnames(x), ignore.case = TRUE)]
})


# Put together
Data <- rbindlist(Data)

# Save as CSV
Data <- write.csv(Data, file = paste0(Council_name, '.csv'))



