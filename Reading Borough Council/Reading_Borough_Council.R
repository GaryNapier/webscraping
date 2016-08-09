

# Reading_Borough_Council

## TO CHANGE ##
Council_name <- "Reading_Borough_Council" # String
WD <- "U:/Councils/Reading Borough Council" # String
URL <- "http://beta.reading.gov.uk/spendingover500" # String
To_Add <- "http://beta.reading.gov.uk/" # String

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

### Get XLSX files & convert to csv ###

# Read in converted csv files
Data <- list.files(pattern = "*.csv")

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

# Coerce to data frame - not sure why... 
Data <- lapply(Data, function (x) {
  as.data.frame(x)
})

# Subset by Columns needed
# Enter column names needed - CHANGE
Cols <- c("Supplier.Name", "Amount", "supplier.name", "Directorate", "service.area", "payment.date")
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
List_members_reorder <- c(1) # Numbers - CHANGE
Cols_reorder <- c(1, 5, 2, 3, 4) # Numbers - new order of columns - CHANGE
Data[List_members_reorder] <- lapply(Data[List_members_reorder], function (x){
  Re_Order_Cols(x, Cols_reorder)
})

# Put together
Data <- rbindlist(Data)

# Save as CSV
Data <- write.csv(Data, file = paste0(Council_name, '.csv'))


