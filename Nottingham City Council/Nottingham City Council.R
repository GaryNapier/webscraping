
# Nottingham City Council 


## TO CHANGE ##
Council_name <- "Nott_City" # String
WD <- "U:/Councils/Nottingham City Council" # String
URL <- "http://www.opendatanottingham.org.uk/dataset.aspx?id=21"

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

Subset_CSV_URLs <- c(28:46) # Numbers - CHANGE
Data <- Data[Subset_CSV_URLs]

## Append .csv?
Append_.CSV <- 0 # 1 = yes, append '.csv', 0 = no, skip to next step - CHANGE
if (Append_.CSV == 1){
  
  for (i in 1:length(Data)) {
    Data[i] <- paste0(Data[i], ".csv")
  }
}

# Parse XML second time (data are WITHIN the individual pages)?
Double_XML_Parse <- 0  # 1 = yes, apply XML parse to list of URLs to 
# get secondary URLs for CSV files; 0 = no, skip to next step
if (Double_XML_Parse == 1){
  
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
  
  Subset_Secondary_List <-   # One Number - CHANGE
  Data <- lapply(Data, function(x) {x[Subset_Secondary_List]})
}

# Read data into list of data frames
# Skip first line?
Skip <- 0 # 1 = yes, skip the first x number of lines - CHANGE
Skip_Number_of_Lines <-  0 # One Number
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
Cols <- c("Payment.Date", "Department", "Supplier.Name", "Expenditure.Category", "Net.Amount")
Cols <- paste(Cols, collapse = "|")
Data <- lapply(Data, function(x){
  
  x[, grepl(Cols, colnames(x), ignore.case = TRUE)]
  
})

# Clear empty
Data <- Data[lapply(Data, nrow) > 0]

# Re-order columns function
Re_Order_Cols <- function (x, Numbers) {
  
  Out <- x[, Numbers]
  Out
  #Fun
}

# Which members of list to reorder? Which order?
List_members_reorder <- # Numbers - CHANGE
Cols_reorder <-   # Numbers - new order of columns - CHANGE
Data[List_members_reorder] <- lapply(Data[List_members_reorder], function (x){
  Re_Order_Cols(x, Cols_reorder)
})q

# Give all elements same number of cols - 
# **Add col of NAs at front, assuming the missing data is something like the 'service area', 
# which is usually missing**
Add_Col <- function (x){
  
  cbind(X = NA, x)
  #Fun
}

# Apply Add_Col function to selected Data list members (the ones with fewest cols)
List_members_add_col <- # Numbers - which list members to add col of NAs - CHANGE
Data[List_members_add_col] <- lapply(Data[List_members_add_col], Add_Col)

# Put together
Data <- rbindlist(Data)

# Save as CSV
Data <- write.csv(Data, file = paste0(Council_name, '.csv'))

####



