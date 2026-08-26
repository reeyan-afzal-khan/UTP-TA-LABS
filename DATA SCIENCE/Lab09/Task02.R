cat("\n=== Activity 2: mtcars - Normalization ===\n")

# Load dataset
data("mtcars")

cat("Original mtcars summary:\n")
print(summary(mtcars))

# We will normalize all numeric columns
# Select numeric columns only
mtcars_num <- mtcars


# -------------------------------------------------------
# METHOD 1: Log Transformation
# Formula: log(x)
# Purpose: Reduces right skew, compresses large values
# -------------------------------------------------------

# Note: log() requires all values > 0
# mtcars has all positive values so this is safe
mtcars_log <- log(mtcars_num)

cat("\n--- Method 1: Log Transformation ---\n")
print(summary(mtcars_log))

# Plot: Compare original vs log-transformed for 'mpg'
par(mfrow = c(1, 2))  # side by side plots

hist(mtcars$mpg,
     main   = "Original MPG",
     xlab   = "MPG",
     col    = "lightblue",
     border = "white",
     breaks = 10)

hist(mtcars_log$mpg,
     main   = "Log-Transformed MPG",
     xlab   = "log(MPG)",
     col    = "steelblue",
     border = "white",
     breaks = 10)

par(mfrow = c(1, 1))  # reset layout


# -------------------------------------------------------
# METHOD 2: Standard Scaling (Z-score Normalization)
# Formula: (x - mean) / sd
# Purpose: Centers data at 0 with std deviation of 1
# -------------------------------------------------------

mtcars_standard <- as.data.frame(scale(mtcars_num))

cat("\n--- Method 2: Standard Scaling (Z-score) ---\n")
print(summary(mtcars_standard))

# Plot: Compare original vs standard scaled for 'mpg'
par(mfrow = c(1, 2))

hist(mtcars$mpg,
     main   = "Original MPG",
     xlab   = "MPG",
     col    = "lightgreen",
     border = "white",
     breaks = 10)

hist(mtcars_standard$mpg,
     main   = "Standard Scaled MPG",
     xlab   = "Z-score",
     col    = "darkgreen",
     border = "white",
     breaks = 10)

par(mfrow = c(1, 1))


# -------------------------------------------------------
# METHOD 3: Min-Max Scaling
# Formula: (x - min) / (max - min)
# Purpose: Rescales all values to range [0, 1]
# -------------------------------------------------------

minmax_scale <- function(x) {
  (x - min(x)) / (max(x) - min(x))
}

mtcars_minmax <- as.data.frame(lapply(mtcars_num, minmax_scale))

cat("\n--- Method 3: Min-Max Scaling ---\n")
print(summary(mtcars_minmax))

# Plot: Compare original vs min-max scaled for 'mpg'
par(mfrow = c(1, 2))

hist(mtcars$mpg,
     main   = "Original MPG",
     xlab   = "MPG",
     col    = "lightyellow",
     border = "white",
     breaks = 10)

hist(mtcars_minmax$mpg,
     main   = "Min-Max Scaled MPG",
     xlab   = "Scaled Value (0-1)",
     col    = "orange",
     border = "white",
     breaks = 10)

par(mfrow = c(1, 1))


# -------------------------------------------------------
# COMPARISON: All 3 methods side by side for 'mpg'
# -------------------------------------------------------

par(mfrow = c(1, 4))

hist(mtcars$mpg,
     main   = "Original",
     xlab   = "MPG",
     col    = "lightgray",
     border = "white",
     breaks = 8)

hist(mtcars_log$mpg,
     main   = "Log Transform",
     xlab   = "log(MPG)",
     col    = "steelblue",
     border = "white",
     breaks = 8)

hist(mtcars_standard$mpg,
     main   = "Standard Scale",
     xlab   = "Z-score",
     col    = "darkgreen",
     border = "white",
     breaks = 8)

hist(mtcars_minmax$mpg,
     main   = "Min-Max Scale",
     xlab   = "[0, 1]",
     col    = "orange",
     border = "white",
     breaks = 8)

par(mfrow = c(1, 1))


# -------------------------------------------------------
# COMPARISON: Boxplots of all 3 methods for 'mpg'
# -------------------------------------------------------

boxplot(mtcars$mpg,
        mtcars_log$mpg,
        mtcars_standard$mpg,
        mtcars_minmax$mpg,
        names  = c("Original", "Log", "Z-score", "Min-Max"),
        main   = "MPG: Comparison of Normalization Methods",
        ylab   = "Value",
        col    = c("lightgray", "steelblue", "darkgreen", "orange"),
        border = "gray30")


cat("\n--- Comparison: Normalization Methods ---\n")
cat("\nOriginal MPG range:         ", min(mtcars$mpg), "to", max(mtcars$mpg), "\n")
cat("Log Transformed MPG range:  ", round(min(mtcars_log$mpg), 3),
    "to", round(max(mtcars_log$mpg), 3), "\n")
cat("Standard Scaled MPG range:  ", round(min(mtcars_standard$mpg), 3),
    "to", round(max(mtcars_standard$mpg), 3), "\n")
cat("Min-Max Scaled MPG range:    0 to 1\n")

cat("\n--- Findings & Discussion ---\n")
cat("1. LOG TRANSFORMATION:\n")
cat("   - Compresses large values, reduces right skew\n")
cat("   - Shape of distribution preserved but scale changes\n")
cat("   - Best for: skewed data with large value ranges\n")
cat("   - Limitation: cannot be used if data contains 0 or negatives\n\n")

cat("2. STANDARD SCALING (Z-score):\n")
cat("   - Centers data at mean=0, std deviation=1\n")
cat("   - Negative values appear (values below mean)\n")
cat("   - Shape of distribution is fully preserved\n")
cat("   - Best for: algorithms sensitive to variance (e.g. PCA, regression)\n\n")

cat("3. MIN-MAX SCALING:\n")
cat("   - All values squeezed into range [0, 1]\n")
cat("   - Shape of distribution is fully preserved\n")
cat("   - Sensitive to outliers (outliers compress other values)\n")
cat("   - Best for: neural networks, distance-based algorithms\n")

cat("\nAll plots and analyses completed successfully!\n")