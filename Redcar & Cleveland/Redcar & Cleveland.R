
# Redcar & Cleveland

## TO CHANGE ##
Council_name <- "Redcar&Cleveland" # String
WD <- "U:/Councils/Redcar & Cleveland" # String
URL <- "http://www.redcar-cleveland.gov.uk/rcbcweb.nsf/Web+Full+List/BDA34873F225499880257A0600543F90?OpenDocument" # String
URL1 <- "/rcbcweb\\.nsf/Web\\+Full\\+List/08C5A364791B3E2E80257E5700462B79\\?OpenDocument"
URL2 <- "/rcbcweb\\.nsf/Web\\+Full\\+List/5435582957789AA780257D1C00516A53\\?OpenDocument"
Second_URLs <- c(URL1, URL2)
To_Add <- "http://www.redcar-cleveland.gov.uk"

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

Data <- subset(Data, grepl(paste(Second_URLs, collapse = "|"), Data))

# Add URL:

for (i in 1:length(Data)) {
  
  Data[i] <- paste0(To_Add, Data[i]) 
}


# Parse XML second time (data are WITHIN the individual pages)
  
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
  
  
## Subset by getting ".csv" and "Spend"
  
Data <- lapply(Data, function(x) {
  
  x[grepl(".csv", x) & grepl("Spend",  x)]
  
})

# Attach beginning of URL

Data <- lapply(Data, function(x){
  
  paste(To_Add, x, sep = "")
})

Data <- c(Data[[1]], Data[[2]])

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

# Subset by Columns needed
# Enter column names needed - CHANGE
Cols <- c("Supplier", "Expenditure.Category", "Paid.in.Period", "Serv",
          "Paid.in.Period", "Posted.amount", "Cost.Centre.Description")
Cols <- paste(Cols, collapse = "|")
Data <- lapply(Data, function(x){
  
  x[, grepl(Cols, colnames(x), ignore.case = TRUE)]
  
})

# Clear empty
Data <- Data[lapply(Data, nrow) > 0]

# Put together
Data <- rbindlist(Data)

# Save as CSV
Data <- write.csv(Data, file = paste0(Council_name, '.csv'))


