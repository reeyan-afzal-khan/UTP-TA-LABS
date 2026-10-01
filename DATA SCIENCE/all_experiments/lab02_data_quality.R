# Lab 2 - Data-quality audit using Iris and Titanic
course_root <- if (dir.exists("all_datasets")) "." else ".."
iris_path <- file.path(course_root, "all_datasets", "iris_dataset.csv")
titanic_path <- file.path(course_root, "all_datasets", "titanic_dataset.csv")

iris <- read.csv(iris_path, stringsAsFactors = FALSE)
titanic <- read.csv(titanic_path, stringsAsFactors = FALSE)

missing_table <- function(d) {
  out <- data.frame(
    variable = names(d),
    missing_n = colSums(is.na(d)),
    missing_pct = round(100 * colMeans(is.na(d)), 2),
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

# Standardise category labels without modifying the raw input file.
iris$Species_clean <- trimws(tolower(iris$Species))
iris$Species_clean <- gsub("[-_]", " ", iris$Species_clean)
iris$Species_clean <- sub("^iris\\s+", "", iris$Species_clean)
cat("IRIS: cleaned species labels\n")
print(sort(table(iris$Species_clean, useNA = "ifany")))

numeric_cols <- c("SepalLengthCm", "SepalWidthCm", "PetalLengthCm", "PetalWidthCm")
invalid_nonpositive <- sapply(iris[numeric_cols], function(x) sum(!is.na(x) & x <= 0))
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
# Median imputation is shown as a teaching example, not claimed as universally correct.
titanic$Age_imputed <- titanic$Age
for (pc in sort(unique(titanic$Pclass))) {
  for (sx in sort(unique(titanic$Sex))) {
    idx <- titanic$Pclass == pc & titanic$Sex == sx
    med <- median(titanic$Age[idx], na.rm = TRUE)
    titanic$Age_imputed[idx & is.na(titanic$Age_imputed)] <- med
  }
}
cat("TITANIC: Age missing before =", sum(is.na(titanic$Age)),
    "; after derived imputation =", sum(is.na(titanic$Age_imputed)), "\n")

# Extension A - Ames Housing: structural missingness
ames_path <- file.path(course_root, "all_datasets", "ames_housing_dataset.csv")
ames <- read.csv(ames_path, check.names = FALSE, stringsAsFactors = FALSE)
ames_missing <- sort(colMeans(is.na(ames)), decreasing = TRUE)
cat("\nAMES: variables with the most missing values\n")
print(round(100 * head(ames_missing, 12), 1))
cat("Interpret these fields using their semantics before choosing an imputation rule.\n")

# Extension B - Red Wine Quality: duplicate semantics
wine_path <- file.path(course_root, "all_datasets", "red_wine_quality_dataset.csv")
red_wine <- read.csv(wine_path, check.names = TRUE)
cat("\nRED WINE: supplied rows =", nrow(red_wine),
    "; unique rows =", nrow(unique(red_wine)),
    "; exact duplicate rows =", sum(duplicated(red_wine)), "\n")
cat("Do not remove duplicates until the intended observational unit/key is defined.\n")
