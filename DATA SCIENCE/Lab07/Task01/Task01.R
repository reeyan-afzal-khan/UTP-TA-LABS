library(readxl)
library(dplyr)
library(xlsx)

titanic <- read.csv("tested.csv")
View(titanic)

dim(titanic)
titanic_cleaned = na.omit(titanic)
dim(titanic_cleaned)

colnames(titanic_cleaned)

titanic_sortbyfare = arrange(titanic_cleaned, Fare)
titanic_sortbyfare = arrange(titanic_cleaned, desc(Fare))

write.csv(titanic_sortbyfare, "titanic_sortbyfare.csv")