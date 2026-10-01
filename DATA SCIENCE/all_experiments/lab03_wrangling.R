# Lab 3 - Wrangling and feature engineering with hourly bike-sharing data
course_root <- if (dir.exists("all_datasets")) "." else ".."
path <- file.path(course_root, "all_datasets", "bike_sharing_dataset_hour.csv")

bike <- read.csv(path, stringsAsFactors = FALSE)
bike$dteday <- as.Date(bike$dteday)

# Create interpretable features while preserving the original columns.
bike$hour_label <- sprintf("%02d:00", bike$hr)
bike$day_type <- ifelse(bike$workingday == 1, "working day", "non-working day")
bike$peak_period <- cut(
  bike$hr,
  breaks = c(-1, 5, 9, 15, 19, 23),
  labels = c("overnight", "morning peak", "midday", "evening peak", "late evening")
)

# Cyclical encodings keep hour 23 close to hour 0.
bike$hour_sin <- sin(2 * pi * bike$hr / 24)
bike$hour_cos <- cos(2 * pi * bike$hr / 24)

# Aggregate 17k+ hourly observations into an interpretable demand profile.
hour_profile <- aggregate(cnt ~ hr + day_type, data = bike, FUN = mean)
hour_profile <- hour_profile[order(hour_profile$day_type, hour_profile$hr), ]
print(head(hour_profile, 12))

period_summary <- aggregate(cbind(cnt, casual, registered) ~ peak_period + day_type,
                            data = bike, FUN = mean)
print(period_summary)

# Feature check: every row should lie on the unit circle apart from floating-point error.
unit_circle_error <- max(abs(bike$hour_sin^2 + bike$hour_cos^2 - 1))
cat("Maximum cyclical-encoding identity error:", unit_circle_error, "\n")

# Visualise the grouped result, not all 17k raw points.
working <- subset(hour_profile, day_type == "working day")
nonworking <- subset(hour_profile, day_type == "non-working day")
plot(working$hr, working$cnt, type = "o", pch = 16,
     xlab = "Hour", ylab = "Mean rentals",
     ylim = range(hour_profile$cnt),
     main = "Hourly bike demand by day type")
lines(nonworking$hr, nonworking$cnt, type = "o", pch = 1)
legend("topleft", c("Working day", "Non-working day"), pch = c(16, 1), lty = 1, bty = "n")
