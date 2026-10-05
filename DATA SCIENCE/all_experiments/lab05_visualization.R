# Lab 5 - Visual communication with red-wine quality data
course_root <- if (dir.exists("all_datasets")) "." else ".."
path <- file.path(course_root, "all_datasets", "red_wine_quality_dataset.csv")

d <- read.csv(path, check.names = TRUE)
cat("Quality counts:\n")
print(table(d$quality))

# Figure 1 - Distribution question: how common is each discrete quality score?
barplot(table(d$quality),
        xlab = "Quality score", ylab = "Number of wines",
        main = "Distribution of wine-quality scores")

# Figure 2 - Comparison question: how does alcohol content vary by quality score?
boxplot(alcohol ~ factor(quality), data = d, outline = FALSE,
        xlab = "Quality score", ylab = "Alcohol (%)",
        main = "Alcohol content by quality score")
quality_alcohol <- aggregate(alcohol ~ quality, data = d,
                             FUN = function(x) c(n = length(x), mean = mean(x), median = median(x)))
cat("\nAlcohol summaries by quality score:\n")
print(quality_alcohol)

# Figure 3 - Relationship question: how do two chemical measurements co-vary?
plot(d$volatile.acidity, d$alcohol,
     pch = 16, cex = .55,
     xlab = "Volatile acidity", ylab = "Alcohol (%)",
     main = "Volatile acidity and alcohol")
cat("\nCorrelation(volatile acidity, alcohol):",
    round(cor(d$volatile.acidity, d$alcohol), 3), "\n")

# Redesign example: change the question rather than the styling.
# Here the question becomes: how does volatile acidity differ across quality scores?
boxplot(volatile.acidity ~ factor(quality), data = d, outline = FALSE,
        xlab = "Quality score", ylab = "Volatile acidity",
        main = "Volatile acidity by quality score")

# Extension - hour-by-weekday heatmap with Bike Sharing.
bike_path <- file.path(course_root, "all_datasets", "bike_sharing_dataset_hour.csv")
bike <- read.csv(bike_path, stringsAsFactors = FALSE)
heat <- with(bike, tapply(cnt, list(hr, weekday), mean))
image(x = 0:6, y = 0:23, z = t(heat),
      xlab = "Weekday", ylab = "Hour",
      main = "Mean bike rentals by weekday and hour",
      axes = FALSE)
axis(1, at = 0:6, labels = c("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"))
axis(2, at = seq(0, 23, by = 3))
box()

cat("\nCaption checklist for every submitted figure:\n")
cat("1) What data are shown? 2) What is encoded? 3) What is the visible pattern?\n")
cat("4) What limitation, aggregation, or uncertainty should the reader know?\n")
