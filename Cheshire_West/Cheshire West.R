
## Cheshire West ##

install.packages("rlist")
library(rlist)

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

setwd("U:/Councils/Cheshire_West")

Files <- list.files(pattern = "*.csv")

Data <- lapply(Files, function(x) read.csv(x))

Names_List <- lapply(Data, function(x) names(x))

Data_1 <- list.subset(Data, c(1, 2))
Data_1 <- lapply(Data_1, function(x) x[c(3, 5, 8, 10, 11)])

Names_List <- lapply(Data_1, function(x) names(x))


Data_2 <- list.subset(Data, 3)
Data_2 <- lapply(Data_2, function(x) x[c(1, 3, 6, 8, 9)])


# Join Data_1 and Data_2 as list
Data <- append(Data_1, Data_2)

# Names_List <- lapply(Data, function(x) names(x))

Data <- rbindlist(Data)

Data <- as.data.frame(Data)

Cheshire_West <- filter(Data, rowSums(mutate_each(Data, funs(. %in% Rivals))) >= 1L)

Cheshire_West <- write.csv(Cheshire_West, file = 'Cheshire_West.csv')









