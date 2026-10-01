# Lab 8 - Logistic classification with heart-disease data
course_root <- if (dir.exists("all_datasets")) "." else ".."
path <- file.path(course_root, "all_datasets", "heart_failure_dataset.csv")

d <- read.csv(path, stringsAsFactors = FALSE)
for (v in c("Sex", "ChestPainType", "RestingECG", "ExerciseAngina", "ST_Slope")) {
  d[[v]] <- factor(d[[v]])
}

# Stratified train/test split preserves the outcome proportion.
set.seed(42)
train_id <- integer(0)
for (cls in sort(unique(d$HeartDisease))) {
  ids <- which(d$HeartDisease == cls)
  train_id <- c(train_id, sample(ids, floor(.80 * length(ids))))
}
train <- d[train_id, ]
test <- d[-train_id, ]

fit <- glm(HeartDisease ~ Age + Sex + ChestPainType + RestingBP + Cholesterol +
             FastingBS + MaxHR + ExerciseAngina + Oldpeak + ST_Slope,
           data = train, family = binomial())
prob <- predict(fit, newdata = test, type = "response")
threshold <- 0.50
pred <- ifelse(prob >= threshold, 1, 0)

cm <- table(Predicted = factor(pred, levels = c(0,1)),
            Observed = factor(test$HeartDisease, levels = c(0,1)))
print(cm)

tn <- cm[1,1]; fn <- cm[1,2]; fp <- cm[2,1]; tp <- cm[2,2]
safe <- function(a, b) ifelse(b == 0, NA, a / b)
accuracy <- safe(tp + tn, sum(cm))
sensitivity <- safe(tp, tp + fn)
specificity <- safe(tn, tn + fp)
precision <- safe(tp, tp + fp)
cat("Accuracy:", round(accuracy, 3),
    " Sensitivity:", round(sensitivity, 3),
    " Specificity:", round(specificity, 3),
    " Precision:", round(precision, 3), "\n")

# Probabilities retain more information than hard class labels.
hist(prob[test$HeartDisease == 0], breaks = 20, xlim = c(0,1),
     col = NA, border = "grey40",
     xlab = "Predicted probability", main = "Heart-disease probabilities")
hist(prob[test$HeartDisease == 1], breaks = 20, add = TRUE,
     col = NA, border = "black")
abline(v = threshold, lty = 2)

# Extension A - Breast Cancer: a second binary classification geometry
bc_path <- file.path(course_root, "all_datasets", "breast_cancer_dataset.csv")
bc <- read.csv(bc_path, check.names = TRUE, stringsAsFactors = FALSE)
cat("\nBREAST CANCER diagnosis counts:\n")
print(table(bc$diagnosis))
print(aggregate(cbind(radius_mean, texture_mean) ~ diagnosis, data = bc, FUN = mean))

# Extension B - Optical Digits: inspect a high-dimensional multiclass example.
# read.csv() can read a text file directly from a ZIP connection via unz().
digit_zip <- file.path(course_root, "all_datasets", "optical_recognition_handwritten_digits.zip")
train_member <- "lab06-optical_recognition_handwritten_digits/optdigits.tra"
digits <- read.csv(unz(digit_zip, train_member), header = FALSE)
cat("\nOPTICAL DIGITS: rows =", nrow(digits),
    "; predictors =", ncol(digits) - 1,
    "; classes =", length(unique(digits[[ncol(digits)]])), "\n")
print(table(digits[[ncol(digits)]]))

# Reconstruct the first row as an 8x8 intensity matrix.
first_digit <- matrix(as.numeric(digits[1, 1:64]), nrow = 8, byrow = TRUE)
image(t(first_digit[8:1, ]), axes = FALSE, col = gray.colors(17),
      main = paste("First digit label:", digits[1, 65]))
