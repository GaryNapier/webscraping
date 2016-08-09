

# Luton_Borough

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

WD <- "U:/Councils/Luton_Borough" # String
setwd(WD)

# GET XLS FILES & CONVERT
# Read in data:
Files <- list.files(WD, pattern = "*.csv")
Data <- lapply(Files, function(x) data.frame(read.csv(x, stringsAsFactors = FALSE)))

# Filter by list of rivals
Data <- lapply(Data, function(x){
  filter(x, rowSums(mutate_each(x, funs(grepl(Rivals, .)))) >= 1L)
})

# Clear empty list elements
Data <- Data[lapply(Data, length) > 0]
Data <- Data[lapply(Data, nrow) > 0]

# Subset by Columns needed
# Enter column names needed - CHANGE
Cols <- c("^Creditor\\.Name$", "^Goods\\.Amount\\.Exclunding\\.VAT$", "Amount",
          "^Cost\\.Centre\\.Description$", "Date", "Line_Date", "^Department\\.Description$",
          "^Department$")
Cols <- paste(Cols, collapse = "|")
Data <- lapply(Data, function(x){
  x[, grepl(Cols, colnames(x), ignore.case = TRUE)]
})



# Give all elements same number of cols - 
# Add col of NAs at front
Add_Col <- function (x){
  cbind(X = NA, x)
  #Fun
}

# Apply Add_Col function to selected Data list members (the ones with fewest cols)
List_members_add_col <- c(1, 2, 4, 5) # Numbers - which list members to add col of NAs - CHANGE
Data[List_members_add_col] <- lapply(Data[List_members_add_col], Add_Col)

# Re-order columns function
Re_Order_Cols <- function (x, Numbers) {
  Out <- x[, Numbers]
  Out
  #Fun
}

# Which members of list to reorder? Which order?
List_members_reorder <- c(1, 2, 4, 5) # Numbers - CHANGE
Cols_reorder <- c(2, 3, 4, 5, 1) # Numbers - new order of columns - CHANGE
Data[List_members_reorder] <- lapply(Data[List_members_reorder], function (x){
  Re_Order_Cols(x, Cols_reorder)
})
# Which members of list to reorder? Which order?
List_members_reorder <- c(6) # Numbers - CHANGE
Cols_reorder <- c(5, 4, 2, 1, 3) # Numbers - new order of columns - CHANGE
Data[List_members_reorder] <- lapply(Data[List_members_reorder], function (x){
  Re_Order_Cols(x, Cols_reorder)
})
# Which members of list to reorder? Which order?
List_members_reorder <- c(3) # Numbers - CHANGE
Cols_reorder <- c(1, 5, 2, 3, 4) # Numbers - new order of columns - CHANGE
Data[List_members_reorder] <- lapply(Data[List_members_reorder], function (x){
  Re_Order_Cols(x, Cols_reorder)
})

# Put together
Data <- rbindlist(Data)

# Save as CSV
Data <- write.csv(Data, file = paste0(Council_name, '.csv'))


