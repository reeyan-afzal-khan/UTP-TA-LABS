# Lab 9 - Stratified cross-validation and leakage-safe preprocessing with fraud data
course_root <- if (dir.exists("all_datasets")) "." else ".."
path <- file.path(course_root, "all_datasets", "credit_card_fraud_dataset.csv")

d <- read.csv(path, stringsAsFactors = FALSE)
d$merchant_category <- factor(d$merchant_category)
cat("Fraud prevalence:", round(mean(d$is_fraud), 4), "\n")
print(table(d$is_fraud))
majority_accuracy <- mean(d$is_fraud == 0)
cat("Always-legitimate baseline accuracy:", round(majority_accuracy, 4), "\n")

# Create stratified fold labels.
set.seed(42)
K <- 5
fold <- integer(nrow(d))
for (cls in sort(unique(d$is_fraud))) {
  ids <- sample(which(d$is_fraud == cls))
  fold[ids] <- rep(seq_len(K), length.out = length(ids))
}
cat("\nClass counts by fold:\n")
print(table(fold, d$is_fraud))

numeric_to_scale <- c("amount", "transaction_hour", "device_trust_score",
                      "velocity_last_24h", "cardholder_age")
thresholds <- c(.10, .25, .50)
results <- data.frame()

metric_row <- function(obs, prob, threshold) {
  pred <- ifelse(prob >= threshold, 1, 0)
  tp <- sum(pred == 1 & obs == 1)
  fp <- sum(pred == 1 & obs == 0)
  tn <- sum(pred == 0 & obs == 0)
  fn <- sum(pred == 0 & obs == 1)
  safe <- function(a, b) ifelse(b == 0, NA_real_, a / b)
  data.frame(
    threshold = threshold,
    TP = tp, FP = fp, TN = tn, FN = fn,
    accuracy = safe(tp + tn, length(obs)),
    precision = safe(tp, tp + fp),
    recall = safe(tp, tp + fn),
    specificity = safe(tn, tn + fp)
  )
}

for (k in seq_len(K)) {
  train <- d[fold != k, ]
  valid <- d[fold == k, ]

  # Fit preprocessing parameters on the training portion only.
  for (v in numeric_to_scale) {
    mu <- mean(train[[v]])
    sig <- sd(train[[v]])
    if (is.na(sig) || sig == 0) stop("Cannot scale variable: ", v)
    train[[v]] <- (train[[v]] - mu) / sig
    valid[[v]] <- (valid[[v]] - mu) / sig
  }

  fit <- glm(is_fraud ~ amount + transaction_hour + merchant_category +
               foreign_transaction + location_mismatch + device_trust_score +
               velocity_last_24h + cardholder_age,
             data = train, family = binomial())
  prob <- predict(fit, newdata = valid, type = "response")

  for (t in thresholds) {
    r <- metric_row(valid$is_fraud, prob, t)
    r$fold <- k
    results <- rbind(results, r)
  }
}

mean_metrics <- aggregate(cbind(accuracy, precision, recall, specificity) ~ threshold,
                          data = results, FUN = mean, na.rm = TRUE)
sd_metrics <- aggregate(cbind(accuracy, precision, recall, specificity) ~ threshold,
                        data = results, FUN = sd, na.rm = TRUE)
cat("\nMean cross-validation metrics by threshold:\n")
print(round(mean_metrics, 3))
cat("\nCross-validation metric SD by threshold:\n")
print(round(sd_metrics, 3))
cat("\nFold-to-fold recall:\n")
print(results[, c("fold", "threshold", "FN", "recall")])

# Illustrative operational choice: missing a fraud costs 5 times a false alarm.
# This cost ratio is an external assumption, not something learned by the model.
results$cost_5_to_1 <- 5 * results$FN + results$FP
cost_summary <- aggregate(cost_5_to_1 ~ threshold, data = results, FUN = mean)
cat("\nMean illustrative cost (5*FN + FP) by threshold:\n")
print(cost_summary)

# Calibration extension with Heart Failure probabilities on a fresh holdout split.
heart_path <- file.path(course_root, "all_datasets", "heart_failure_dataset.csv")
heart <- read.csv(heart_path, stringsAsFactors = FALSE)
for (v in c("Sex", "ChestPainType", "RestingECG", "ExerciseAngina", "ST_Slope")) {
  heart[[v]] <- factor(heart[[v]])
}
set.seed(42)
h_train_id <- integer(0)
for (cls in sort(unique(heart$HeartDisease))) {
  ids <- which(heart$HeartDisease == cls)
  h_train_id <- c(h_train_id, sample(ids, floor(.80 * length(ids))))
}
h_train <- heart[h_train_id, ]
h_test <- heart[-h_train_id, ]
h_fit <- glm(HeartDisease ~ Age + Sex + ChestPainType + RestingBP + Cholesterol +
               FastingBS + MaxHR + ExerciseAngina + Oldpeak + ST_Slope,
             data = h_train, family = binomial())
h_prob <- predict(h_fit, newdata = h_test, type = "response")
h_breaks <- unique(quantile(h_prob, probs = seq(0, 1, length.out = 8)))
h_bin <- cut(h_prob, breaks = h_breaks, include.lowest = TRUE)
calibration <- aggregate(cbind(predicted = h_prob, observed = h_test$HeartDisease),
                         by = list(bin = h_bin), FUN = mean)
calibration$n <- as.vector(table(h_bin))
cat("\nHEART FAILURE calibration bins:\n")
print(calibration)
