# Lab 7 - Multiple linear regression with Ames Housing
course_root <- if (dir.exists("all_datasets")) "." else ".."
path <- file.path(course_root, "all_datasets", "ames_housing_dataset.csv")

raw <- read.csv(path, check.names = TRUE)
vars <- c("SalePrice", "Gr.Liv.Area", "Overall.Qual", "Year.Built", "Garage.Cars", "Total.Bsmt.SF")
complete_idx <- complete.cases(raw[, vars])
d <- raw[complete_idx, vars]
cat("Original rows:", nrow(raw),
    "; complete modelling rows:", nrow(d),
    "; removed:", sum(!complete_idx), "\n")

set.seed(42)
train_id <- sample(seq_len(nrow(d)), size = floor(.80 * nrow(d)))
train <- d[train_id, ]
test <- d[-train_id, ]
cat("Training rows:", nrow(train), "; test rows:", nrow(test), "\n")

metrics <- function(obs, pred) {
  err <- obs - pred
  c(
    MAE = mean(abs(err)),
    RMSE = sqrt(mean(err^2)),
    R2 = 1 - sum(err^2) / sum((obs - mean(obs))^2)
  )
}

# Baseline: the training-set median is a robust constant prediction.
baseline_pred <- rep(median(train$SalePrice), nrow(test))
baseline_metrics <- metrics(test$SalePrice, baseline_pred)
cat("\nBaseline holdout metrics:\n")
print(round(baseline_metrics, 3))

fit <- lm(SalePrice ~ Gr.Liv.Area + Overall.Qual + Year.Built + Garage.Cars + Total.Bsmt.SF,
          data = train)
cat("\nRegression coefficients:\n")
print(coef(summary(fit)))

pred <- predict(fit, newdata = test)
model_metrics <- metrics(test$SalePrice, pred)
cat("\nRegression holdout metrics:\n")
print(round(model_metrics, 3))
cat("MAE improvement over baseline (%):",
    round(100 * (baseline_metrics["MAE"] - model_metrics["MAE"]) / baseline_metrics["MAE"], 1), "\n")

err <- test$SalePrice - pred
par(mfrow = c(1, 2))
plot(pred, test$SalePrice, pch = 16, cex = .55,
     xlab = "Predicted price", ylab = "Observed price",
     main = "Predicted vs observed")
abline(0, 1, lty = 2)
plot(pred, err, pch = 16, cex = .55,
     xlab = "Predicted price", ylab = "Residual",
     main = "Residual diagnostic")
abline(h = 0, lty = 2)
par(mfrow = c(1, 1))

# Segment error: does average performance hide poorer prediction for expensive homes?
price_breaks <- unique(quantile(test$SalePrice, probs = c(0, .5, .8, .95, 1)))
price_band <- cut(test$SalePrice, breaks = price_breaks, include.lowest = TRUE)
segment_mae <- aggregate(abs(err), by = list(price_band = price_band), FUN = mean)
names(segment_mae)[2] <- "MAE"
cat("\nHoldout MAE by observed sale-price band:\n")
print(segment_mae)

# Extension: add Neighborhood as a categorical predictor using the same split membership.
# Rebuild a modelling table using rows that were already retained above.
d_ext <- raw[complete_idx, c(vars, "Neighborhood")]
train_ext <- d_ext[train_id, ]
test_ext <- d_ext[-train_id, ]
fit_nb <- lm(SalePrice ~ Gr.Liv.Area + Overall.Qual + Year.Built + Garage.Cars +
               Total.Bsmt.SF + Neighborhood,
             data = train_ext)

# A categorical model cannot predict a level that was never present in training.
known_level <- test_ext$Neighborhood %in% unique(train_ext$Neighborhood)
if (any(!known_level)) {
  cat("Test rows with neighbourhood levels unseen in training:", sum(!known_level), "\n")
}
test_ext_known <- test_ext[known_level, ]
test_known <- test[known_level, ]
pred_nb <- predict(fit_nb, newdata = test_ext_known)
nb_metrics <- metrics(test_ext_known$SalePrice, pred_nb)
base_same_rows <- metrics(test_known$SalePrice, predict(fit, newdata = test_known))
cat("\nSame-row holdout metrics without Neighborhood:\n")
print(round(base_same_rows, 3))
cat("Holdout metrics after adding Neighborhood:\n")
print(round(nb_metrics, 3))

nb_profile <- aggregate(SalePrice ~ Neighborhood, data = train_ext,
                        FUN = function(x) c(n = length(x), median = median(x)))
nb_profile <- data.frame(Neighborhood = nb_profile$Neighborhood,
                         n = nb_profile$SalePrice[, "n"],
                         median = nb_profile$SalePrice[, "median"])
nb_profile <- nb_profile[order(nb_profile$median), ]
cat("\nTraining-set neighbourhood profile:\n")
print(nb_profile)
