# Lab 4 - Exploratory data analysis with medical insurance costs
course_root <- if (dir.exists("all_datasets")) "." else ".."
path <- file.path(course_root, "all_datasets", "medical_cost_personal_dataset.csv")

d <- read.csv(path, stringsAsFactors = FALSE)
cat("Rows:", nrow(d), " Columns:", ncol(d), "\n")
print(summary(d))

# Distribution shape and robust summaries.
q <- quantile(d$charges, probs = c(.25, .5, .75))
iqr <- IQR(d$charges)
upper_fence <- q[3] + 1.5 * iqr
cat("Charge median:", round(median(d$charges), 2), "\n")
cat("Charge IQR:", round(iqr, 2), "\n")
cat("Rows above 1.5*IQR upper fence:", sum(d$charges > upper_fence), "\n")

smoker_summary <- aggregate(charges ~ smoker, data = d,
                            FUN = function(x) c(mean = mean(x), median = median(x), sd = sd(x), n = length(x)))
print(smoker_summary)

region_summary <- aggregate(charges ~ region, data = d, FUN = median)
region_summary <- region_summary[order(region_summary$charges, decreasing = TRUE), ]
print(region_summary)

cat("Overall correlation(bmi, charges):", round(cor(d$bmi, d$charges), 3), "\n")
for (s in sort(unique(d$smoker))) {
  z <- subset(d, smoker == s)
  cat("Correlation(bmi, charges) for smoker =", s, ":", round(cor(z$bmi, z$charges), 3), "\n")
}

par(mfrow = c(1, 3))
hist(d$charges, breaks = 30, main = "Charges", xlab = "charges")
boxplot(charges ~ smoker, data = d, main = "Charges by smoker", xlab = "smoker", ylab = "charges")
plot(d$bmi, d$charges, pch = 16, cex = .55, main = "BMI vs charges", xlab = "BMI", ylab = "charges")
par(mfrow = c(1, 1))
