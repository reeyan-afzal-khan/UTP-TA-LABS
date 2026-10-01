# Lab 5 - Visual communication with red-wine quality data
course_root <- if (dir.exists("all_datasets")) "." else ".."
path <- file.path(course_root, "all_datasets", "red_wine_quality_dataset.csv")

d <- read.csv(path, check.names = TRUE)
cat("Quality counts:\n")
print(table(d$quality))
cat("Correlation(alcohol, quality):", round(cor(d$alcohol, d$quality), 3), "\n")

# 1. Distribution: how common is each quality score?
barplot(table(d$quality),
        xlab = "Quality score", ylab = "Number of wines",
        main = "Distribution of wine-quality scores")

# 2. Comparison: how does alcohol content vary by quality score?
boxplot(alcohol ~ factor(quality), data = d, outline = FALSE,
        xlab = "Quality score", ylab = "Alcohol (%)",
        main = "Alcohol content by quality score")

# 3. Relationship: combine two chemical measurements without claiming causality.
plot(d$volatile.acidity, d$alcohol,
     pch = 16, cex = .55,
     xlab = "Volatile acidity", ylab = "Alcohol (%)",
     main = "Two chemical measurements")

# Print the grouped evidence that supports the second figure.
print(aggregate(alcohol ~ quality, data = d, FUN = mean))

# Extension - hour-by-weekday heatmap with Bike Sharing
bike_path <- file.path(course_root, "all_datasets", "bike_sharing_dataset_hour.csv")
bike <- read.csv(bike_path, stringsAsFactors = FALSE)
heat <- with(bike, tapply(cnt, list(hr, weekday), mean))
image(x = 0:6, y = 0:23, z = t(heat),
      xlab = "Weekday code (0=Sunday)", ylab = "Hour",
      main = "Mean bike rentals by weekday and hour",
      axes = FALSE)
axis(1, at = 0:6, labels = c("Sun","Mon","Tue","Wed","Thu","Fri","Sat"))
axis(2, at = seq(0, 23, by = 3))
box()
