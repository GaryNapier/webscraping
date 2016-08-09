

# Medway_Council

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

## TO CHANGE ##
Council_name <- "Medway_Council" # String
WD <- "U:/Councils/Medway_Council" # String
URL <- "http://www.medway.gov.uk/?page=3594" # String
To_Add <- "http://www.medway.gov.uk" # String
setwd(WD)

# GET XLS from WEBSITE & CONVERT

# Read in data
Files <- list.files(WD, pattern = "*.csv")
Data <- lapply(Files, function(x) {data.frame(read.csv(x, stringsAsFactors = FALSE))})

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
Cols <- c("Clearance.Date", "Supplier.or.Redacted.Statement", "Directorate.Balance.Sheet.Heading", 
          "Area.of.Spend", "Value")
Cols <- paste(Cols, collapse = "|")
Data <- lapply(Data, function(x){
  
  x[, grepl(Cols, colnames(x), ignore.case = TRUE)]
  
})

# Put together
Data <- do.call("rbind", Data)

# Save as CSV
Data <- write.csv(Data, file = paste0(Council_name, '.csv'))


