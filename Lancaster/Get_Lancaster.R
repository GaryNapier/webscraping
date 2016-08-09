# Lancaster_City

## TO CHANGE ##
Council_name <- "Lancaster_City" # String
WD <- "U:/Councils/Lancaster" # String
URL <- "http://www.lancaster.gov.uk/council-and-democracy/budgets-and-spending/council-payments/" # String
To_Add <- "http://www.lancaster.gov.uk" # String

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

## Webscrape - first parse
Data <- getURL(URL)

Data <- htmlTreeParse(Data, useInternalNodes = TRUE)

Data <- unlist(xpathApply(Data, '//a[@href]', xmlGetAttr, "href"))

# Subset by most recent year & "spend"
# Get the year & last year based on the last 12 months
This_Last_Year <- unique(as.character(year(seq(Now, by = "-1 month", length.out = 12))))
This_Last_Year <- paste(This_Last_Year, collapse = "|")

Data <- lapply(Data, function(x){
  x[grepl(This_Last_Year, x) & grepl("spend", x, ignore.case = TRUE)]
})

# Unlist
Data <- unlist(Data)

# Add URL
for (i in 1:length(Data)){
  
  Data[i] <- paste(To_Add, Data[i], sep = "")
}
  
# Double parse
  for (i in 1:length(Data)) {
    
    Data[i] <- getURL(Data[i], .opts=curlOptions(followlocation = TRUE))
  }
  
  Data <- as.list(Data)
  
  for (i in 1:length(Data)){
    
    Data[[i]] <- htmlTreeParse(Data[[i]], useInternalNodes = TRUE)
  }
  
  for (i in 1:length(Data)) {
    
    Data[[i]] <-  unlist(xpathApply(Data[[i]], '//a[@href]', xmlGetAttr, "href"))
  }
  
# END Double parse
  
# Subset by 'getasset'
Data <- lapply(Data, function(x){
  
  x[grepl('getasset', x, ignore.case = TRUE)]
})
  
# Subset by alternating rows
Data <- lapply(Data, function(x){
  x[seq(2, length(x), 2)]
})

# Unlist
Data <- unlist(Data)

# Add URL
for (i in 1:length(Data)){
  Data[i] <- paste(To_Add, Data[i], sep = "")
}

# Read data into list of data frames
# Skip first line?
Skip <- 0 # 1 = yes, skip the first x number of lines - CHANGE
Skip_Number_of_Lines <-  1 # One Number - CHANGE
if (Skip == 1){
  Data <- lapply(Data, function(x) data.frame(read.csv(x, skip = Skip_Number_of_Lines)))
} else {
  Data <- lapply(Data, function(x) data.frame(read.csv(x)))
}

# Check names
Names_List <- lapply(Data, function(x) names(x))

# Coerce to data frame - not sure why... 
Data <- lapply(Data, function (x) {
  as.data.frame(x)
})

# Filter by list of rivals
Data <- lapply(Data, function(x){
  filter(x, rowSums(mutate_each(x, funs(grepl(Rivals, .)))) >= 1L)
})

# Clear empty
Data <- Data[lapply(Data, nrow) > 0]

# Subset by Columns needed
# Enter column names needed - CHANGE
Cols <- c("Supplier.Name", "Spending.Service", "Nature.of.Spend", 
          "Net.Amount..excluding.VAT.", "Ledger.Date")
Cols <- paste(Cols, collapse = "|")
Data <- lapply(Data, function(x){
  
  x[, grepl(Cols, colnames(x), ignore.case = TRUE)]
  
})


# Put together
Data <- rbindlist(Data)

# Save as CSV
Data <- write.csv(Data, file = paste0(Council_name, '.csv'))

