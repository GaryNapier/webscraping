

### Warrington_BC

## TO CHANGE ##
Council_name <- "Warrington_BC" # String
WD <- "U:/Councils/Warrington_BC" # String
URL <- "https://www.warrington.gov.uk/info/201122/open_data/1075/spending" # String
To_Add <- "https://www.warrington.gov.uk"

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

## Subset by getting ".csv"

Data <- Data[grepl(".csv", Data)]

# Attach URL

for (i in 2:length(Data)) {
  
  Data[i] <- paste(To_Add, Data[i], sep = "")
}

Data <- Data[1:12]

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

# Clear empty
Data <- Data[lapply(Data, nrow) > 0]

# Check names
Names_List <- lapply(Data, function(x) names(x))

# Coerce to data frame - not sure why... 
Data <- lapply(Data, function (x) {
  as.data.frame(x)
})

# Subset by Columns needed
# Enter column names needed - CHANGE
Cols <- c("SUPPLIER.NAME", "AMOUNT", "DATE..POSTING.DATE.", "EXPENDITURE.CATEGORY", 
          "ORGANISATIONAL.UNIT")
Cols <- paste(Cols, collapse = "|")
Data <- lapply(Data, function(x){
  
  x[, grepl(Cols, colnames(x), ignore.case = TRUE)]
  
})

# Put together
Data <- rbindlist(Data)

Data <- select(Data, -ORGANISATIONAL.UNIT.CODE)

# Save as CSV
Data <- write.csv(Data, file = paste0(Council_name, '.csv'))


