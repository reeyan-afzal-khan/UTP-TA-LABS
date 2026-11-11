# Lab 1 - Question-to-evidence workflow with daily bike-sharing data
# Run from the DATA SCIENCE project root or from all_experiments/.
course_root <- if (dir.exists("all_datasets")) "." else ".."
path <- file.path(course_root, "all_datasets", "bike_sharing_dataset_day.csv")

bike <- read.csv(path, stringsAsFactors = FALSE)
bike$dteday <- as.Date(bike$dteday)

cat("Dataset:", normalizePath(path), "\n")
cat("Rows:", nrow(bike), " Columns:", ncol(bike), "\n")
cat("Date range:", format(min(bike$dteday)), "to", format(max(bike$dteday)), "\n")
cat("Total missing values:", sum(is.na(bike)), "\n")
cat("Duplicate instant IDs:", sum(duplicated(bike$instant)), "\n")
cat("Rows where cnt != casual + registered:",
    sum(bike$cnt != bike$casual + bike$registered, na.rm = TRUE), "\n\n")

# Compact variable profile: storage type, missingness, and number of distinct values.
profile <- data.frame(
  variable = names(bike),
  class = vapply(bike, function(x) class(x)[1], character(1)),
  missing_n = vapply(bike, function(x) sum(is.na(x)), integer(1)),
  unique_n = vapply(bike, function(x) length(unique(x)), integer(1)),
  row.names = NULL
)
print(profile)

# Question 1 (descriptive): what is the typical level and variability of daily demand?
cat("\nDaily rental count summary:\n")
print(summary(bike$cnt))
cat("SD:", round(sd(bike$cnt), 1), " IQR:", round(IQR(bike$cnt), 1), "\n")

# Question 2 (comparative): does demand differ between working and non-working days?
working_summary <- do.call(rbind, lapply(split(bike$cnt, bike$workingday), function(x) {
  c(n = length(x), mean = mean(x), median = median(x), sd = sd(x))
}))
working_summary <- data.frame(workingday = rownames(working_summary),
                              working_summary, row.names = NULL)
cat("\nDemand by working-day status:\n")
print(working_summary)

# Question 3 (relational): how strongly is normalised temperature associated with demand?
r_temp <- cor(bike$temp, bike$cnt, use = "complete.obs")
cat("\nCorrelation(temp, cnt):", round(r_temp, 3), "\n")

# Time structure: raw daily series plus a centred 30-day moving average.
ma30 <- as.numeric(stats::filter(bike$cnt, rep(1 / 30, 30), sides = 2))
plot(bike$dteday, bike$cnt, type = "l",
     xlab = "Date", ylab = "Daily rentals",
     main = "Daily bike-sharing demand")
lines(bike$dteday, ma30, lwd = 2)
legend("topleft", c("Daily count", "30-day moving average"),
       lty = 1, lwd = c(1, 2), bty = "n")

cat("\nInterpretation prompts:\n")
cat("- Does the working-day comparison change when using medians instead of means?\n")
cat("- Which variables could confound the temperature-demand association?\n")
cat("- Which time-series features would a single overall mean hide?\n")

cat("\nReproducibility record:\n")
print(sessionInfo())
