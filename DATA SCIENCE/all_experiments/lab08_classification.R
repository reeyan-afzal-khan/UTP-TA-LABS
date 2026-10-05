# Lab 8 - Probabilistic classification with heart-disease data
course_root <- if (dir.exists("all_datasets")) "." else ".."
path <- file.path(course_root, "all_datasets", "heart_failure_dataset.csv")

d <- read.csv(path, stringsAsFactors = FALSE)
for (v in c("Sex", "ChestPainType", "RestingECG", "ExerciseAngina", "ST_Slope")) {
  d[[v]] <- factor(d[[v]])
}
cat("Outcome prevalence (HeartDisease=1):", round(mean(d$HeartDisease == 1), 3), "\n")
print(table(d$HeartDisease))

# Stratified train/test split preserves class prevalence.
set.seed(42)
train_id <- integer(0)
for (cls in sort(unique(d$HeartDisease))) {
  ids <- which(d$HeartDisease == cls)
  train_id <- c(train_id, sample(ids, floor(.80 * length(ids))))
}
train <- d[train_id, ]
test <- d[-train_id, ]
cat("Train prevalence:", round(mean(train$HeartDisease == 1), 3),
    "; test prevalence:", round(mean(test$HeartDisease == 1), 3), "\n")

fit <- glm(HeartDisease ~ Age + Sex + ChestPainType + RestingBP + Cholesterol +
             FastingBS + MaxHR + ExerciseAngina + Oldpeak + ST_Slope,
           data = train, family = binomial())
prob <- predict(fit, newdata = test, type = "response")

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
    sensitivity = safe(tp, tp + fn),
    specificity = safe(tn, tn + fp),
    precision = safe(tp, tp + fp)
  )
}

thresholds <- c(.30, .50, .70)
threshold_results <- do.call(rbind, lapply(thresholds, function(t) {
  metric_row(test$HeartDisease, prob, t)
}))
cat("\nHoldout threshold comparison:\n")
print(round(threshold_results, 3))

# Reference confusion matrix at 0.50.
pred_50 <- ifelse(prob >= .50, 1, 0)
cm <- table(Predicted = factor(pred_50, levels = c(0, 1)),
            Observed = factor(test$HeartDisease, levels = c(0, 1)))
cat("\nConfusion matrix at threshold 0.50:\n")
print(cm)

# Probabilities preserve more information than hard decisions.
hist(prob[test$HeartDisease == 0], breaks = 20, xlim = c(0, 1),
     col = NA, border = "grey40",
     xlab = "Predicted probability", main = "Heart-disease probabilities")
hist(prob[test$HeartDisease == 1], breaks = 20, add = TRUE,
     col = NA, border = "black")
abline(v = thresholds, lty = c(3, 2, 3))

# Extension A - Breast Cancer: second binary feature geometry.
bc_path <- file.path(course_root, "all_datasets", "breast_cancer_dataset.csv")
bc <- read.csv(bc_path, check.names = TRUE, stringsAsFactors = FALSE)
cat("\nBREAST CANCER diagnosis counts:\n")
print(table(bc$diagnosis))
print(aggregate(cbind(radius_mean, texture_mean) ~ diagnosis, data = bc, FUN = mean))
plot(bc$radius_mean, bc$texture_mean,
     pch = ifelse(bc$diagnosis == "M", 19, 1),
     xlab = "Mean radius", ylab = "Mean texture",
     main = "Breast-cancer feature geometry")
legend("topleft", legend = c("Benign", "Malignant"), pch = c(1, 19), bty = "n")

# Extension B - Optical Digits: high-dimensional multiclass example.
digit_zip <- file.path(course_root, "all_datasets", "optical_recognition_handwritten_digits.zip")
train_member <- "lab06-optical_recognition_handwritten_digits/optdigits.tra"
test_member <- "lab06-optical_recognition_handwritten_digits/optdigits.tes"
digits_train <- read.csv(unz(digit_zip, train_member), header = FALSE)
digits_test <- read.csv(unz(digit_zip, test_member), header = FALSE)
cat("\nOPTICAL DIGITS: train rows =", nrow(digits_train),
    "; test rows =", nrow(digits_test),
    "; predictors =", ncol(digits_train) - 1,
    "; classes =", length(unique(digits_train[[ncol(digits_train)]])), "\n")
print(table(digits_train[[ncol(digits_train)]]))

first_digit <- matrix(as.numeric(digits_train[1, 1:64]), nrow = 8, byrow = TRUE)
image(t(first_digit[8:1, ]), axes = FALSE, col = gray.colors(17),
      main = paste("First digit label:", digits_train[1, 65]))
