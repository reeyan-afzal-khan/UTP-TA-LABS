# Lab 2 - Data-quality audit using Iris, Titanic, Ames Housing, and Red Wine
course_root <- if (dir.exists("all_datasets")) "." else ".."
iris_path <- file.path(course_root, "all_datasets", "iris_dataset.csv")
titanic_path <- file.path(course_root, "all_datasets", "titanic_dataset.csv")

iris <- read.csv(iris_path, stringsAsFactors = FALSE, na.strings = c("", "NA"))
titanic <- read.csv(titanic_path, stringsAsFactors = FALSE, na.strings = c("", "NA"))

missing_table <- function(d) {
  out <- data.frame(
    variable = names(d),
    missing_n = vapply(d, function(x) sum(is.na(x)), integer(1)),
    missing_pct = round(100 * vapply(d, function(x) mean(is.na(x)), numeric(1)), 2),
    row.names = NULL
  )
  out[order(out$missing_pct, decreasing = TRUE), ]
}

cat("IRIS: dimensions\n")
print(dim(iris))
cat("IRIS: missingness\n")
print(missing_table(iris))
cat("IRIS: raw species labels\n")
print(sort(table(iris$Species, useNA = "ifany")))
cat("IRIS: duplicated IDs =", sum(duplicated(iris$Id)), "\n")

# Standardise category labels without modifying the raw field.
iris$Species_clean <- trimws(tolower(iris$Species))
iris$Species_clean <- gsub("[-_]", " ", iris$Species_clean)
iris$Species_clean <- sub("^iris\\s+", "", iris$Species_clean)
cat("IRIS: cleaned species labels\n")
print(sort(table(iris$Species_clean, useNA = "ifany")))

numeric_cols <- c("SepalLengthCm", "SepalWidthCm", "PetalLengthCm", "PetalWidthCm")
invalid_nonpositive <- vapply(iris[numeric_cols],
                              function(x) sum(!is.na(x) & x <= 0), integer(1))
cat("IRIS: non-positive measurement counts\n")
print(invalid_nonpositive)

cat("\nTITANIC: dimensions\n")
print(dim(titanic))
cat("TITANIC: missingness\n")
print(missing_table(titanic))
cat("TITANIC: duplicated PassengerId =", sum(duplicated(titanic$PassengerId)), "\n")
cat("TITANIC: invalid Pclass =", sum(!titanic$Pclass %in% 1:3), "\n")
cat("TITANIC: invalid Survived =", sum(!titanic$Survived %in% c(0, 1)), "\n")
cat("TITANIC: negative Fare =", sum(!is.na(titanic$Fare) & titanic$Fare < 0), "\n")

# Demonstrate a documented derived field rather than overwriting Age.
titanic$Age_imputed <- titanic$Age
imputed_n <- 0L
for (pc in sort(unique(titanic$Pclass))) {
  for (sx in sort(unique(titanic$Sex))) {
    idx <- titanic$Pclass == pc & titanic$Sex == sx
    med <- median(titanic$Age[idx], na.rm = TRUE)
    replace_idx <- idx & is.na(titanic$Age_imputed)
    imputed_n <- imputed_n + sum(replace_idx)
    titanic$Age_imputed[replace_idx] <- med
  }
}
cat("TITANIC: Age missing before =", sum(is.na(titanic$Age)),
    "; imputed =", imputed_n,
    "; missing after =", sum(is.na(titanic$Age_imputed)), "\n")
cat("TITANIC: original observed Age summary\n")
print(summary(titanic$Age))
cat("TITANIC: derived Age_imputed summary\n")
print(summary(titanic$Age_imputed))

# Extension A - Ames Housing: inspect high-missingness fields before assigning meaning.
ames_path <- file.path(course_root, "all_datasets", "ames_housing_dataset.csv")
ames <- read.csv(ames_path, check.names = FALSE, stringsAsFactors = FALSE,
                 na.strings = c("", "NA"))
ames_missing <- sort(colMeans(is.na(ames)), decreasing = TRUE)
cat("\nAMES: variables with the most missing values (%)\n")
print(round(100 * head(ames_missing, 15), 1))
cat("Interpret fields such as Pool QC, Alley, Fence, or Fireplace Qu semantically\n",
    "before deciding whether NA means absence, unknown, or an error.\n", sep = "")

# Extension B - Red Wine Quality: identical feature rows are not automatically bad records.
wine_path <- file.path(course_root, "all_datasets", "red_wine_quality_dataset.csv")
red_wine <- read.csv(wine_path, check.names = TRUE)
cat("\nRED WINE: supplied rows =", nrow(red_wine),
    "; unique rows =", nrow(unique(red_wine)),
    "; exact duplicate rows =", sum(duplicated(red_wine)), "\n")
cat("Define the observational unit/key before removing any duplicate-looking row.\n")
