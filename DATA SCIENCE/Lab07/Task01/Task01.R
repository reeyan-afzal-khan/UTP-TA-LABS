# Lab 7, Task 1 --- Import, clean, sort, and export the Titanic data.
#
# Only dplyr is needed here: the input and the output are both CSV, so
# readxl (Excel input) and xlsx (Excel output, and a Java install) would be
# dependencies this script never uses. Load what you use, and no more ---
# an unused library() is a failure waiting to happen on someone else's
# machine.

library(dplyr)

titanic <- read.csv("tested.csv")

# View() only exists in RStudio, so a script that calls it cannot be run
# with Rscript or on a marker's machine. head()/str() show the same thing
# and work everywhere.
print(head(titanic))
str(titanic)

cat("\nRows before cleaning:", nrow(titanic), "\n")

# na.omit() drops any row with a missing value in ANY column, so always
# report how many rows that removed rather than cleaning silently.
titanic_cleaned <- na.omit(titanic)
cat("Rows after  cleaning:", nrow(titanic_cleaned),
    " (removed", nrow(titanic) - nrow(titanic_cleaned), ")\n\n")

cat("Columns:", paste(colnames(titanic_cleaned), collapse = ", "), "\n\n")

# Sort by fare, highest first. (Sorting ascending first and then overwriting
# the result was wasted work --- only the final ordering survives.)
titanic_sortbyfare <- arrange(titanic_cleaned, desc(Fare))

print(head(titanic_sortbyfare[, c("Name", "Pclass", "Fare")]))

write.csv(titanic_sortbyfare, "titanic_sortbyfare.csv", row.names = FALSE)
cat("\nWrote titanic_sortbyfare.csv\n")
