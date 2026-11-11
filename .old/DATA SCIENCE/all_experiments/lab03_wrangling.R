# Lab 3 - Wrangling and feature engineering with hourly bike-sharing data
course_root <- if (dir.exists("all_datasets")) "." else ".."
path <- file.path(course_root, "all_datasets", "bike_sharing_dataset_hour.csv")

bike <- read.csv(path, stringsAsFactors = FALSE)
bike$dteday <- as.Date(bike$dteday)
cat("Source rows:", nrow(bike), "\n")
cat("Date range:", format(min(bike$dteday)), "to", format(max(bike$dteday)),
    "; hour range:", min(bike$hr), "to", max(bike$hr), "\n")

# Preserve source columns; all transformations create new fields.
bike$hour_label <- sprintf("%02d:00", bike$hr)
bike$day_type <- ifelse(bike$workingday == 1, "working day", "non-working day")
bike$peak_period <- cut(
  bike$hr,
  breaks = c(-1, 5, 9, 15, 19, 23),
  labels = c("overnight", "morning peak", "midday", "evening peak", "late evening")
)

# Cyclical encodings keep hour 23 close to hour 0 in feature space.
bike$hour_sin <- sin(2 * pi * bike$hr / 24)
bike$hour_cos <- cos(2 * pi * bike$hr / 24)

# Validation checks before analysis.
cat("Rows with missing engineered peak_period:", sum(is.na(bike$peak_period)), "\n")
cat("Rows where cnt != casual + registered:",
    sum(bike$cnt != bike$casual + bike$registered, na.rm = TRUE), "\n")
unit_circle_error <- max(abs(bike$hour_sin^2 + bike$hour_cos^2 - 1))
cat("Maximum cyclical-encoding identity error:", unit_circle_error, "\n")

# Aggregate 17k+ observations into an interpretable demand profile.
hour_profile <- aggregate(cnt ~ hr + day_type, data = bike,
                          FUN = function(x) c(n = length(x), mean = mean(x), median = median(x)))
hour_profile <- data.frame(
  hr = hour_profile$hr,
  day_type = hour_profile$day_type,
  n = hour_profile$cnt[, "n"],
  mean_cnt = hour_profile$cnt[, "mean"],
  median_cnt = hour_profile$cnt[, "median"]
)
hour_profile <- hour_profile[order(hour_profile$day_type, hour_profile$hr), ]
cat("\nHourly demand profile:\n")
print(head(hour_profile, 16))

period_summary <- aggregate(cbind(cnt, casual, registered) ~ peak_period + day_type,
                            data = bike, FUN = mean)
cat("\nMean demand by peak period and day type:\n")
print(period_summary)
cat("Rows represented by peak-period groups:", sum(table(bike$peak_period, bike$day_type)), "\n")

# Visualise the grouped result, not all raw points.
working <- subset(hour_profile, day_type == "working day")
nonworking <- subset(hour_profile, day_type == "non-working day")
plot(working$hr, working$mean_cnt, type = "o", pch = 16,
     xlab = "Hour", ylab = "Mean rentals",
     ylim = range(hour_profile$mean_cnt),
     main = "Hourly bike demand by day type")
lines(nonworking$hr, nonworking$mean_cnt, type = "o", pch = 1)
legend("topleft", c("Working day", "Non-working day"),
       pch = c(16, 1), lty = 1, bty = "n")

# Sensitivity check: move the morning-peak end from 09:00 to 08:00.
bike$peak_period_alt <- cut(
  bike$hr,
  breaks = c(-1, 5, 8, 15, 19, 23),
  labels = c("overnight", "morning peak", "midday", "evening peak", "late evening")
)
base_morning <- mean(bike$cnt[bike$peak_period == "morning peak"])
alt_morning <- mean(bike$cnt[bike$peak_period_alt == "morning peak"])
cat("\nMorning-peak mean under original boundary:", round(base_morning, 1), "\n")
cat("Morning-peak mean under alternative boundary:", round(alt_morning, 1), "\n")
