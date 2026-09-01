# Lab 7, Task 2 --- Report reproducible observations from the cleaned data.
#
# Only dplyr is used: the file is CSV in and text out, so readxl and xlsx
# (which also drags in Java) are not needed.
#
# Every percentage below prints its DENOMINATOR as well as the rate. A bare
# "76% survived" is unusable evidence unless the reader knows 76% of what.
#
# ---------------------------------------------------------------------
# READ THIS BEFORE QUOTING ANY NUMBER BELOW.
#
# This file descends from the Kaggle Titanic TEST set. In that file the
# Survived column is not a historical record --- it is a placeholder in
# which every female is marked 1 and every male 0. The check at the top of
# the script proves it on the data in front of you.
#
# So "100% of women survived" is not a finding about 1912; it is the
# labelling rule of the file, read back out. The lab exercises the WORKFLOW
# (import, clean, filter, cross-tabulate, export). Treat the survival
# numbers as mechanics, and use the real training set (train.csv, which has
# genuine outcomes) before writing any claim about who actually survived.
# ---------------------------------------------------------------------

library(dplyr)

titanic <- read.csv("titanic_sortbyfare.csv")

titanic_cleaned <- na.omit(titanic)

cat("\n--- TITANIC DATASET REPORT ---\n")

total_titanic <- nrow(titanic_cleaned)
cat("Rows analysed:", total_titanic, "\n\n")

# Provenance check, run on the data itself rather than taken on trust.
# If Survived is identical to (Sex == "female"), the column carries no
# independent information and no survival claim can rest on it.
label_is_synthetic <- all((titanic_cleaned$Sex == "female") ==
                          (titanic_cleaned$Survived == 1))
if (label_is_synthetic) {
  cat("WARNING: in this file Survived is exactly (Sex == \"female\").\n")
  cat("It is a placeholder label, not a historical outcome. The rates\n")
  cat("below therefore describe the FILE, not the 1912 disaster.\n\n")
}

# Insight 1: Survival by Embarkation (Cherbourg Example)
cherbourg_total <- titanic_cleaned %>% filter(Embarked == 'C') %>% nrow()
cherbourg_survived <- titanic_cleaned %>% filter(Embarked == 'C' & Survived == 1) %>% nrow()
cherbourg_pct <- round((cherbourg_survived / cherbourg_total) * 100, 1)

cat(sprintf("1. Cherbourg: %d of %d embarked passengers survived (%.1f%%).\n",
            cherbourg_survived, cherbourg_total, cherbourg_pct))

# Insight 2: Third Class Passenger Percentage
third_class_total <- titanic_cleaned %>% filter(Pclass == 3) %>% nrow()
third_class_pct <- round((third_class_total / total_titanic) * 100, 1)

cat(sprintf("2. Third class: %d of %d passengers (%.1f%%).\n",
            third_class_total, total_titanic, third_class_pct))

# Insight 3: Female Survival Rate
female_total <- titanic_cleaned %>% filter(Sex == 'female') %>% nrow()
female_survived <- titanic_cleaned %>% filter(Sex == 'female' & Survived == 1) %>% nrow()
female_pct <- round((female_survived / female_total) * 100, 1)

cat(sprintf("3. Female passengers: %d of %d survived (%.1f%%).\n",
            female_survived, female_total, female_pct))

# Insight 4: High Fare Demographics
high_fare_total <- titanic_cleaned %>% filter(Fare > 100) %>% nrow()
high_fare_first_class <- titanic_cleaned %>% filter(Fare > 100 & Pclass == 1) %>% nrow()
high_fare_pct <- round((high_fare_first_class / high_fare_total) * 100, 1)

cat(sprintf("4. Fare over 100: %d of %d were first class (%.1f%%).\n",
            high_fare_first_class, high_fare_total, high_fare_pct))

cat("\nNote: these rates describe the CLEANED subset (rows with any NA\n")
cat("removed), not the full passenger list. Report the denominator with\n")
cat("every percentage, and state the provenance warning above if it fired.\n")
