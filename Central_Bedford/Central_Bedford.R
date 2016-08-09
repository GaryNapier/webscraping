

# Central_Bedford

## TO CHANGE ##
Council_name <- "Central_Bedford" # String
WD <- "U:/Councils/Central_Bedford" # String
URL <- "http://www.centralbedfordshire.gov.uk/council-and-democracy/spending/transparency/default.aspx" # String
To_Add <- "http://www.centralbedfordshire.gov.uk" # String

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
This_Last_Year <- unique(as.character(year(seq(Now, by = "-1 month", length.out = 12))))
This_Last_Year <- paste(This_Last_Year, collapse = "|")

Data <- lapply(Data, function(x){
  x[grepl(This_Last_Year, x) & grepl("spend", x, ignore.case = TRUE)]
})

# Unlist - also clears empty
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

# Subset by ".csv"
Data <- lapply(Data, function(x){
  x[grepl(".csv", x, ignore.case = TRUE)]
})

# Unlist
Data <- unlist(Data)

# Add URL
for (i in 1:length(Data)){
  Data[i] <- paste(To_Add, Data[i], sep = "")
}

# Subset by previous 12 months
# Get previous 12 months from now
Now <- as.Date(now())
Months_full <- months(seq(Now, by = "-1 month", length.out = 12))
Months_abb <- month.abb[month(seq(Now, by = "-1 month", length.out = 12))]
Months_All <- c(Months_full, Months_abb)
Months_All <- paste(Months_All, collapse = "|")

# Get the year & last year based on the last 12 months
This_Last_Year <- unique(as.character(year(seq(Now, by = "-1 month", length.out = 12))))
This_Last_Year <- paste(This_Last_Year, collapse = "|")

# Subset data according to month and year and "Transparency"
Data <- lapply(Data, function(x){
  
  x[grepl(Months_All, x, ignore.case = TRUE) & grepl(This_Last_Year, x, ignore.case = TRUE) &
      grepl("Transparency", x, ignore.case = TRUE)]
})

# Unlist & clear
Data <- unlist(Data)

# Take out "#False"
for (i in 1:length(Data)){
  Data[i] <- gsub("#False", "", Data[i])
}

# Read data into list of data frames
# Skip first line?
Skip <- 1 # 1 = yes, skip the first x number of lines - CHANGE
Skip_Number_of_Lines <-  2 # One Number - CHANGE
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
  filter(x, rowSums(mutate_each(x, funs(grepl(Rivals, ., ignore.case = TRUE)))) >= 1L)
})

# Clear empty
Data <- Data[lapply(Data, nrow) > 0]

# Subset by Columns needed
# Enter column names needed - CHANGE
Cols <- c("Service.division", "Organisational.unit", "Net.Amount", "Date", "Supplier.name")
Cols <- paste(Cols, collapse = "|")
Data <- lapply(Data, function(x){
  
  x[, grepl(Cols, colnames(x), ignore.case = TRUE)]
  
})

# Put together
Data <- rbindlist(Data)

Data <- select(Data, -Service.division.code)

# Save as CSV
Data <- write.csv(Data, file = paste0(Council_name, '.csv'))


