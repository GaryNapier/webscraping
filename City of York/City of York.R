

## City of York ##

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

setwd("U:/Councils/City of York")

URL <- "https://www.york.gov.uk/downloads/download/1340/payments_to_suppliers_-_csv_files"

York <- getURL(URL)

York <- htmlTreeParse(York, useInternalNodes = TRUE)

York <- unlist(xpathApply(York, '//a[@href]', xmlGetAttr, "href"))

York <- York[21:32]

Data <- vector()
for (i in 1:length(York)) {
  
  Data[i] <- paste0(York[i], ".csv")
  
}
# 
# Data <- lapply(Data, function (x) {
#   
#   getURL(x, .opts=curlOptions(followlocation = TRUE))
# })


for (i in 1:length(Data)) {
  
  Data[i] <- getURL(Data[i], .opts=curlOptions(followlocation = TRUE))
}

Data <- as.list(Data)

# Data <- lapply(Data, function(x) {
#   
#   htmlTreeParse(Data, useInternalNodes = TRUE)
# })

for (i in 1:length(Data)){
  
  Data[[i]] <- htmlTreeParse(Data[[i]], useInternalNodes = TRUE)
}


# Data <- lapply(Data, function(x){
#   
#   unlist(xpathApply(x, '//a[@href]', xmlGetAttr, "href"))
# })

for (i in 1:length(Data)) {
  
  Data[[i]] <-  unlist(xpathApply(Data[[i]], '//a[@href]', xmlGetAttr, "href"))
}

Data <- lapply(Data, function(x) {x[12]})

### BREAK: Data -> Data2

Data2 <- lapply(Data, function(x) data.frame(read.csv(x, skip = 1)))

Names_List <- lapply(Data2, function(x) names(x))

Data2 <- lapply(Data2, function (x) {
  as.data.frame(x)
  })

############

# BREAK: Data2 -> City_of_York

City_of_York <- lapply(Data2, function(x){
  
  # 
  filter(x, rowSums(mutate_each(x, funs(grepl(Rivals, .)))) >= 1L)
})


#############

# Subset by Column

Cols <- c("Body.Name", "Body.Ref", "Transaction.Number", "Purchase.Card", "Organisation.name", 
          "Directorate", "Transaction.reference", "Transaction.Number", "Card.transaction")
Cols <- paste(Cols, collapse = "|")

City_of_York <- lapply(City_of_York, function(x){
  
  x[, !grepl(Cols, colnames(x))]
  
})

# Clear empty

City_of_York <- City_of_York[lapply(City_of_York, nrow) > 0]

############

# Re-order columns in 3 & 4

Re_Order_Cols <- function (x, Numbers) {
  
  Out <- x[, Numbers]
  Out
  #Fun
}


City_of_York[c(3, 4)] <- lapply(City_of_York[c(3, 4)], function (x){
  Re_Order_Cols(x, 4:1)
})

City_of_York[c(3, 4)] <- lapply(City_of_York[c(3, 4)], function (x){
  Re_Order_Cols(x, c(1, 2, 4, 3))
})

# Give all elements same number of cols

# Test <- City_of_York[[3]]

Add_Col <- function (x){

  cbind(X = NA, x)
  #Fun
}

City_of_York[c(3:7)] <- lapply(City_of_York[c(3:7)], Add_Col)


City_of_York <- rbindlist(City_of_York)



#############

# Write

City_of_York <- write.csv(City_of_York, file = 'City_of_York.csv')


















