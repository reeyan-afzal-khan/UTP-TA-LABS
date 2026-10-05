# Lab 6 - Bootstrap and permutation inference with student-performance data
course_root <- if (dir.exists("all_datasets")) "." else ".."
path <- file.path(course_root, "all_datasets", "student_performance_dataset.csv")

d <- read.csv(path, stringsAsFactors = FALSE)
yes <- d$G3[d$higher == "yes"]
no <- d$G3[d$higher == "no"]

cat("Group sizes: higher=yes", length(yes), "; higher=no", length(no), "\n")
cat("Group summaries:\n")
print(data.frame(
  group = c("higher=yes", "higher=no"),
  mean = c(mean(yes), mean(no)),
  median = c(median(yes), median(no)),
  sd = c(sd(yes), sd(no))
))

observed <- mean(yes) - mean(no)
pooled_sd <- sqrt(((length(yes) - 1) * var(yes) + (length(no) - 1) * var(no)) /
                  (length(yes) + length(no) - 2))
std_diff <- observed / pooled_sd
cat("\nObserved mean difference (yes - no):", round(observed, 3), "grade points\n")
cat("Standardised mean difference:", round(std_diff, 3), "\n")

# Bootstrap confidence interval for the mean difference.
set.seed(42)
B <- 5000
boot_diff <- numeric(B)
for (b in seq_len(B)) {
  boot_diff[b] <- mean(sample(yes, replace = TRUE)) - mean(sample(no, replace = TRUE))
}
ci <- quantile(boot_diff, c(.025, .975))
cat("Bootstrap 95% percentile interval:\n")
print(ci)

# Permutation test: shuffle group labels under a no-group-association reference model.
set.seed(42)
perm_diff <- numeric(B)
for (b in seq_len(B)) {
  shuffled <- sample(d$higher)
  perm_diff[b] <- mean(d$G3[shuffled == "yes"]) - mean(d$G3[shuffled == "no"])
}
p_value <- mean(abs(perm_diff) >= abs(observed))
cat("Two-sided permutation p-value:", p_value, "\n")

par(mfrow = c(1, 2))
hist(boot_diff, breaks = 35,
     xlab = "Bootstrap mean difference", main = "Bootstrap distribution")
abline(v = ci, lty = 2)
abline(v = observed, lwd = 2)
hist(perm_diff, breaks = 35,
     xlab = "Permuted mean difference", main = "Null reference distribution")
abline(v = c(-abs(observed), abs(observed)), lty = 2)
par(mfrow = c(1, 1))

# Design audit: plausible confounders available in the same observational dataset.
confounders <- c("G1", "G2", "failures", "studytime", "absences", "Medu", "Fedu")
cat("\nSelected potential confounders and their group means:\n")
for (v in confounders) {
  s <- aggregate(d[[v]], by = list(higher = d$higher), FUN = mean)
  names(s)[2] <- v
  print(s)
}

# Sensitivity check: compare within prior-grade bands (G2 quartiles).
d$G2_band <- cut(d$G2,
                 breaks = unique(quantile(d$G2, probs = seq(0, 1, .25), na.rm = TRUE)),
                 include.lowest = TRUE)
stratified <- aggregate(G3 ~ G2_band + higher, data = d, FUN = mean)
cat("\nMean G3 within prior-grade (G2) bands:\n")
print(stratified)

cat("\nInterpretation warning: the data are observational. Statistical association and\n",
    "uncertainty estimates do not establish that changing higher-education intention\n",
    "would cause final grades to change.\n", sep = "")
