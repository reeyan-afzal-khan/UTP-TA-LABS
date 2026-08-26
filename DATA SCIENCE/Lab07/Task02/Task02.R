library(readxl) 
library(dplyr)  
library(xlsx)   

titanic <- read.csv("titanic_sortbyfare.csv") 

titanic_cleaned <- na.omit(titanic)

cat("\n--- TITANIC DATASET REPORT ---\n")

total_titanic <- nrow(titanic_cleaned)

# Insight 1: Survival by Embarkation (Cherbourg Example)
cherbourg_total <- titanic_cleaned %>% filter(Embarked == 'C') %>% nrow()
cherbourg_survived <- titanic_cleaned %>% filter(Embarked == 'C' & Survived == 1) %>% nrow()
cherbourg_pct <- round((cherbourg_survived / cherbourg_total) * 100, 1)

cat(sprintf("1. Out of the passengers who embarked from Cherbourg, %.1f%% survived.\n", cherbourg_pct))

# Insight 2: Third Class Passenger Percentage
third_class_total <- titanic_cleaned %>% filter(Pclass == 3) %>% nrow()
third_class_pct <- round((third_class_total / total_titanic) * 100, 1)

cat(sprintf("2. Approximately %.1f%% of the passengers in this dataset traveled in Third Class.\n", third_class_pct))

# Insight 3: Female Survival Rate
female_total <- titanic_cleaned %>% filter(Sex == 'female') %>% nrow()
female_survived <- titanic_cleaned %>% filter(Sex == 'female' & Survived == 1) %>% nrow()
female_pct <- round((female_survived / female_total) * 100, 1)

cat(sprintf("3. The survival rate for female passengers was remarkably high at %.1f%%.\n", female_pct))

# Insight 4: High Fare Demographics
high_fare_total <- titanic_cleaned %>% filter(Fare > 100) %>% nrow()
high_fare_first_class <- titanic_cleaned %>% filter(Fare > 100 & Pclass == 1) %>% nrow()
high_fare_pct <- round((high_fare_first_class / high_fare_total) * 100, 1)

cat(sprintf("4. Interestingly, %.1f%% of all passengers who paid a fare over 100 were in First Class.\n", high_fare_pct))
