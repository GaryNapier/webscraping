
# Peterborough_City

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
Council_name <- "Peterborough_City" # String
WD <- "U:/Councils/Peterborough_City" # String
URL <- "http://data.peterborough.gov.uk/View/commercial-activities/transparency-code-payments-over-500" # String
To_Add <- "http://data.peterborough.gov.uk" # String
setwd(WD)

# Read in
Files <- list.files(WD, pattern = ".csv")
Data <- data.frame(read.csv(Files, stringsAsFactors = FALSE))

# Filter by list of rivals
Data <- filter(Data, rowSums(mutate_each(Data, funs(grepl(Rivals, .)))) >= 1L)

# Check names
Names_List <- lapply(Data, function(x) names(x))

# Subset by Columns needed
# Enter column names needed - CHANGE
Cols <- c("amount", "supplier.name", "date", "Service.Area.Categorisation", "Service.Division.Categorisation")
Cols <- paste(Cols, collapse = "|")
Data <- Data[, grepl(Cols, colnames(Data), ignore.case = TRUE)]

# Save as CSV
Data <- write.csv(Data, file = paste0(Council_name, '.csv'))


