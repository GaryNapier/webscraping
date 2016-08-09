

# Northumberland_County

## TO CHANGE ##
Council_name <- "Northumberland_County" # String
WD <- "U:/Councils/Northumberland_County" # String
URL <- "http://www.northumberland.gov.uk/About/Transparency.aspx?nccredirect=1" # String
To_Add <- "http://www.northumberland.gov.uk" # String

Rivals <- c("JORDAN PUBLISHING",
            "KLEWLER",
            "PRACTICAL LAW",
            "SWEET & MAXWELL",
            "THOMSON REUTER",
            "LAWTEL",
            "LEGALEASE",
            "THOMSON REUTERS",
            "WEST PUBLISHING",
            "CCH", 
            "Wolters Kluwer",
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

# Subset by ".csv" or "version"
Subset_Key <- paste(c(".csv", "version"), collapse = "|")
Data <- unlist(lapply(Data, function(x){x[grepl(Subset_Key, x)]}))

# Add URL conditionally
    for (i in 1:length(Data)){
      if (grepl(To_Add, Data[i]) == FALSE){
      Data[i] <- paste(To_Add, Data[i], sep = "")
      } else {
        Data[i] <- Data[i]
      }
    }

# Read data into list of data frames
# Skip first line?
Skip <- 0 # 1 = yes, skip the first x number of lines - CHANGE
Skip_Number_of_Lines <- 4 # One Number - CHANGE
if (Skip == 1){
  Data <- lapply(Data, function(x) data.frame(read.csv(x, skip = Skip_Number_of_Lines, stringsAsFactors = FALSE)))
} else {
  Data <- lapply(Data, function(x) data.frame(read.csv(x), stringsAsFactors = FALSE))
}

# eliminate Pdfs with column number
Data <- Data[lapply(Data, length) > 1]

# Clear empty list elements
Data <- Data[lapply(Data, length) > 0]
Data <- Data[lapply(Data, nrow) > 0]

###

# Checks
lapply(Data, function(x) names(x))
lapply(Data, ncol)
lapply(Data, head)

# Coerce to data frame - not sure why... 
# Data <- lapply(Data, function (x) {as.data.frame(x)})

# Filter by list of rivals
Data <- lapply(Data, function(x){
  filter(x, rowSums(mutate_each(x, funs(grepl(Rivals, .)))) >= 1L)})

# Clear empty
Data <- Data[lapply(Data, length) > 0]
Data <- Data[lapply(Data, nrow) > 0]

#####

## BREAK
Data2 <- Data
## BREAK

# Subset by date

ChangeDate <- function(x){
as.Date(dmy(as.character(x)))
}

# Generate months 
Month_List <- c(month.abb, month.name)
Month_List <- paste(Month_List, collapse = "|")

# Parse date and measure if within 12 months. If not, do not include in subset:
Data_New <- list()
for (j in 1:length(Data2)){
  
  for (i in 1:length(Data2[[j]])){
    
    # If statement getting cols with dates:
    if ((any(grepl(Month_List, Data2[[j]][,i], ignore.case = TRUE))) 
        && (any(ChangeDate(Data2[[j]][,i]) >= as.Date(now() -months(12))))) {
      
      Data_New[[j]] <- Data2[[j]]
    }
    }
  }

# Subset by Columns needed
# Enter column names not needed - CHANGE
Cols <- c("^X$", "^X.2$", "^X.5$", "^X.6$", "^X.7$", "^X.10$", "^X8$", "^Supplier.Payments..where.a.specific.charge.is..250.or.greater.$")
Cols <- paste(Cols, collapse = "|")
Data_New <- lapply(Data_New, function(x){
  x[, !grepl(Cols, colnames(x), ignore.case = TRUE)]
  })

# Put together
Data <- rbindlist(Data_New)

# Save as CSV
Data <- write.csv(Data, file = paste0(Council_name, '.csv'))


