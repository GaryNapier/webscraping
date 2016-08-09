

# Stockton_On_Tees_Borough

# General script - Get council data

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
Council_name <- "Stockton_On_Tees_Borough" # String
WD <- "U:/Councils/Stockton_On_Tees_Borough" # String
setwd(WD)

# GET FILES


# Read data into list of data frames
# Skip first line?
Skip <- 0 # 1 = yes, skip the first x number of lines - CHANGE
Skip_Number_of_Lines <-  1 # One Number - CHANGE
if (Skip == 1){
  Data <- lapply(Data, function(x) data.frame(read.csv(x, stringsAsFactors = FALSE, skip = Skip_Number_of_Lines)))
} else {
  Data <- lapply(Data, function(x) data.frame(read.csv(x, stringsAsFactors = FALSE)))
}

## OPTIONAL ##
# Set ColNames as first row 
Data <- lapply(Data, function(x){
  x[which(!x[,1] == ""),]
})

Data <- lapply(Data, function(x){
  colnames(x) <- x[1, ]
  x <- x[-1, ]
})
#######

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
Cols <- c("")
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
List_members_reorder <- c() # Numbers - CHANGE
Cols_reorder <- c() # Numbers - new order of columns - CHANGE
Data[List_members_reorder] <- lapply(Data[List_members_reorder], function (x){
  Re_Order_Cols(x, Cols_reorder)
})

# Give all elements same number of cols - 
# **Add col of NAs at front, assuming the missing data is something like the 'service area', 
# which is usually missing**
Add_Col <- function (x){
  
  cbind(X = NA, x)
  #Fun
}

# Apply Add_Col function to selected Data list members (the ones with fewest cols)
List_members_add_col <- c() # Numbers - which list members to add col of NAs - CHANGE
Data[List_members_add_col] <- lapply(Data[List_members_add_col], Add_Col)

# Put together
Data <- rbindlist(Data)

# Save as CSV
Data <- write.csv(Data, file = paste0(Council_name, '.csv'))



