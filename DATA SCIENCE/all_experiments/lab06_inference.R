# Lab 6 - Bootstrap inference with student-performance data
course_root <- if (dir.exists("all_datasets")) "." else ".."
path <- file.path(course_root, "all_datasets", "student_performance_dataset.csv")

d <- read.csv(path, stringsAsFactors = FALSE)
yes <- d$G3[d$higher == "yes"]
no <- d$G3[d$higher == "no"]

observed <- mean(yes) - mean(no)
pooled_sd <- sqrt(((length(yes) - 1) * var(yes) + (length(no) - 1) * var(no)) /
                  (length(yes) + length(no) - 2))
std_diff <- observed / pooled_sd
cat("Observed mean difference (higher=yes - higher=no):", round(observed, 3), "\n")
cat("Standardised mean difference:", round(std_diff, 3), "\n")

# Bootstrap confidence interval for the mean difference.
set.seed(42)
B <- 5000
boot_diff <- numeric(B)
for (b in seq_len(B)) {
  boot_diff[b] <- mean(sample(yes, replace = TRUE)) - mean(sample(no, replace = TRUE))
}
ci <- quantile(boot_diff, c(.025, .975))
cat("Bootstrap 95% interval:\n")
print(ci)

# Permutation test for a sharp no-group-association reference distribution.
set.seed(42)
perm_diff <- numeric(B)
for (b in seq_len(B)) {
  shuffled <- sample(d$higher)
  perm_diff[b] <- mean(d$G3[shuffled == "yes"]) - mean(d$G3[shuffled == "no"])
}
p_value <- mean(abs(perm_diff) >= abs(observed))
cat("Two-sided permutation p-value:", p_value, "\n")

hist(boot_diff, breaks = 35,
     xlab = "Bootstrap mean difference", main = "Bootstrap distribution")
abline(v = ci, lty = 2)
abline(v = observed, lwd = 2)

cat("\nInterpretation warning: this is observational data. Association does not establish that\n",
    "intending higher education causes a change in final grade.\n", sep = "")
