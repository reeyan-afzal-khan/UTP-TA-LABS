# Lab 7 - Multiple linear regression with Ames Housing
course_root <- if (dir.exists("all_datasets")) "." else ".."
path <- file.path(course_root, "all_datasets", "ames_housing_dataset.csv")

d <- read.csv(path, check.names = TRUE)
vars <- c("SalePrice", "Gr.Liv.Area", "Overall.Qual", "Year.Built", "Garage.Cars", "Total.Bsmt.SF")
d <- d[complete.cases(d[, vars]), vars]

set.seed(42)
train_id <- sample(seq_len(nrow(d)), size = floor(.80 * nrow(d)))
train <- d[train_id, ]
test <- d[-train_id, ]

fit <- lm(SalePrice ~ Gr.Liv.Area + Overall.Qual + Year.Built + Garage.Cars + Total.Bsmt.SF,
          data = train)
print(summary(fit))

pred <- predict(fit, newdata = test)
err <- test$SalePrice - pred
mae <- mean(abs(err))
rmse <- sqrt(mean(err^2))
r2 <- 1 - sum(err^2) / sum((test$SalePrice - mean(test$SalePrice))^2)
cat("Holdout rows:", nrow(test), "\n")
cat("MAE:", round(mae, 2), " RMSE:", round(rmse, 2), " R2:", round(r2, 3), "\n")

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

# Extension - inspect a categorical location predictor before modelling it.
raw <- read.csv(path, check.names = TRUE)
nb <- aggregate(SalePrice ~ Neighborhood, data = raw,
                FUN = function(x) c(n = length(x), median = median(x)))
nb <- data.frame(Neighborhood = nb$Neighborhood,
                 n = nb$SalePrice[, "n"],
                 median = nb$SalePrice[, "median"])
nb <- nb[nb$n >= 40, ]
nb <- nb[order(nb$median), ]
cat("\nNeighbourhood medians for groups with at least 40 sales:\n")
print(nb)
