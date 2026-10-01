# Lab 1 - Workflow and reproducibility with daily bike-sharing data
# Run from the DATA SCIENCE project root or from all_experiments/.
course_root <- if (dir.exists("all_datasets")) "." else ".."
path <- file.path(course_root, "all_datasets", "bike_sharing_dataset_day.csv")

bike <- read.csv(path, stringsAsFactors = FALSE)
bike$dteday <- as.Date(bike$dteday)

cat("Dataset:", normalizePath(path), "\n")
cat("Rows:", nrow(bike), " Columns:", ncol(bike), "\n\n")
print(head(bike, 6))
str(bike)

# Question 1 (descriptive): how variable is daily demand?
cat("\nDaily rental count summary:\n")
print(summary(bike$cnt))

# Question 2 (comparative): does average demand differ by working-day status?
working_summary <- aggregate(cnt ~ workingday, data = bike,
                             FUN = function(x) c(mean = mean(x), median = median(x), n = length(x)))
print(working_summary)

# Question 3 (relational): how strongly is normalized temperature related to demand?
cat("\nCorrelation(temp, cnt):", round(cor(bike$temp, bike$cnt), 3), "\n")

# A quick visual check. The figure is intentionally simple: pattern first, styling later.
plot(bike$dteday, bike$cnt, type = "l",
     xlab = "Date", ylab = "Daily rentals",
     main = "Bike-sharing demand over time")
lines(bike$dteday, stats::filter(bike$cnt, rep(1/30, 30), sides = 2), lwd = 2)

cat("\nReproducibility record:\n")
print(sessionInfo())
