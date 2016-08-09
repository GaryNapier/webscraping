
## Borough_of_Poole ##


## TO CHANGE ##
Council_name <- "Borough_of_Poole" # String
WD <- "U:/Councils/Borough_of_Poole" # String
URL <- "http://www.poole.gov.uk/your-council/council-budgets-and-spending/transparency/payments-to-suppliers/" # String
To_Add <- "http://www.poole.gov.uk" # String
  
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

  # Subset by "GatewayLink"
  Data <- lapply(Data, function(x){x[grepl("GatewayLink", x)]})
  Data <- unlist(Data)
  # Append URL
  for (i in 1:length(Data)){
    Data[i] <- paste(To_Add, Data[i], sep = "")
  }
  
  # Subset according to website structure
  Data <- Data[c(1, seq(2, 24, 2))]
  
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
  
  # Clear empty list elements
Data <- Data[lapply(Data, nrow) > 0]
  
  # Subset by Columns needed
  # Enter column names needed - CHANGE
  Cols <- c("Supplier.Name", "Amount", "Date", "Responsible.Unit", "Expenses.Type")
  Cols <- paste(Cols, collapse = "|")
  Data <- lapply(Data, function(x){
    x[, grepl(Cols, colnames(x), ignore.case = TRUE)]
  })
  
  Data <- select(Data, -Detailed.Expenses.Type)
  
  # Put together
  Data <- rbindlist(Data)
  
  # Save as CSV
  Data <- write.csv(Data, file = paste0(Council_name, '.csv'))
  
  
  