
## South Gloucestershire Council ##

setwd("U:/Councils/South Gloucestershire")

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

So_Glo <- "http://www.southglos.gov.uk/business/tenders-and-contracts/council-payments-over-500/"

So_Glo <- htmlTreeParse(So_Glo, useInternalNodes = TRUE)

So_Glo <- unlist(xpathApply(So_Glo, '//a[@href]', xmlGetAttr, "href"))

So_Glo <- So_Glo[76:87]

Data <- lapply(So_Glo, function(x) data.frame(read.csv(x)))

Names_List <- lapply(Data, function(x) names(x))

Data <- lapply(Data, function(x) x[c(3, 5:8)])

Data <- rbindlist(Data)

Data <- as.data.frame(Data)

So_Glo <- filter(Data, rowSums(mutate_each(Data, funs(. %in% Rivals))) >= 1L)

So_Glo <- write.csv(So_Glo, file = 'So_Glo.csv')





