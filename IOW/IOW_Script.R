# Get council data (IOW council)

install.packages("XML")
library(XML)

install.packages("dplyr")
library(dplyr)

install.packages("RCurl")
library(RCurl)

setwd("U:/Councils")
# Get IOW CSV URLs

URL <- "https://www.iwight.com/Council/transparency/Transparency-Our-Finances/Spending-and-Finance2"

IOW_Data <- getURL(URL)

IOW_Data <- htmlTreeParse(IOW_Data, useInternalNodes = TRUE)

IOW_Data <- unlist(xpathApply(IOW_Data, '//a[@href]', xmlGetAttr, "href"))

IOW_Data <- IOW_Data[- grep("pdf", IOW_Data)]

IOW_Data <- IOW_Data[grep("data", IOW_Data)]

for (i in 1:length(IOW_Data)) {
  
  IOW_Data[i] <- gsub("view", "download", IOW_Data[i])
}

Data <- lapply(IOW_Data, function(x) data.frame(read.csv(x)))

Data_Excluded <- Data[c(16, 18)]

Data <- Data[-c(16, 18)]

New_Data <- lapply(Data, function(x) select(x, Date:Supplier.Name))

New_Data <- do.call("rbind", New_Data)

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

IOW_Data_Final <- filter(New_Data, rowSums(mutate_each(New_Data, funs(. %in% Rivals))) >= 1L)

IOW_Data_Final <- write.csv(IOW_Data_Final, file = 'IOW_Data_Final.csv')


# Deal with excluded data

# March, june X2



