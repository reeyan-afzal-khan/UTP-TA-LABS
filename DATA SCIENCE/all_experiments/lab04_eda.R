# Lab 4 - Exploratory data analysis with medical insurance costs
course_root <- if (dir.exists("all_datasets")) "." else ".."
path <- file.path(course_root, "all_datasets", "medical_cost_personal_dataset.csv")

d <- read.csv(path, stringsAsFactors = FALSE)
cat("Rows:", nrow(d), " Columns:", ncol(d), "\n")
print(summary(d))

# 1. Target shape and robust summaries.
q <- quantile(d$charges, probs = c(.25, .5, .75))
iqr <- IQR(d$charges)
upper_fence <- q[3] + 1.5 * iqr
cat("\nCHARGES\n")
cat("Mean:", round(mean(d$charges), 2),
    " Median:", round(median(d$charges), 2),
    " SD:", round(sd(d$charges), 2),
    " IQR:", round(iqr, 2), "\n")
cat("Rows above 1.5*IQR upper fence:", sum(d$charges > upper_fence), "\n")

# Inspect flagged rows rather than deleting them.
flagged <- d[d$charges > upper_fence, ]
cat("Flagged-row smoker counts:\n")
print(table(flagged$smoker))
cat("Flagged-row age/BMI summary:\n")
print(summary(flagged[, c("age", "bmi", "charges")]))

# 2. Subgroup comparison.
smoker_summary <- do.call(rbind, lapply(split(d$charges, d$smoker), function(x) {
  c(n = length(x), mean = mean(x), median = median(x), sd = sd(x), IQR = IQR(x))
}))
cat("\nCHARGES BY SMOKING STATUS\n")
print(smoker_summary)

# 3. Region is inspected without over-interpreting small differences.
region_summary <- do.call(rbind, lapply(split(d$charges, d$region), function(x) {
  c(n = length(x), median = median(x), IQR = IQR(x))
}))
region_summary <- region_summary[order(region_summary[, "median"], decreasing = TRUE), , drop = FALSE]
cat("\nCHARGES BY REGION\n")
print(region_summary)

# 4. Overall versus conditional relationship.
cat("\nBMI-CHARGE RELATIONSHIP\n")
cat("Overall correlation:", round(cor(d$bmi, d$charges), 3), "\n")
for (s in sort(unique(d$smoker))) {
  z <- subset(d, smoker == s)
  fit <- lm(charges ~ bmi, data = z)
  cat("smoker =", s,
      ": correlation =", round(cor(z$bmi, z$charges), 3),
      "; slope =", round(coef(fit)["bmi"], 1), "\n")
}

par(mfrow = c(1, 3))
hist(d$charges, breaks = 30, main = "Charges", xlab = "Charges")
boxplot(charges ~ smoker, data = d, main = "Charges by smoking status",
        xlab = "Smoker", ylab = "Charges")
plot(d$bmi, d$charges, pch = 16, cex = .55,
     main = "BMI vs charges", xlab = "BMI", ylab = "Charges")
par(mfrow = c(1, 1))

# Extension: age bands within smoking groups.
d$age_band <- cut(d$age, breaks = c(17, 29, 39, 49, 59, Inf), right = TRUE)
age_smoke <- aggregate(charges ~ age_band + smoker, data = d, FUN = median)
cat("\nMedian charges by age band and smoking status:\n")
print(age_smoke)
