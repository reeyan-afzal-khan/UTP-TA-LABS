cat("=== Activity 1: ToothGrowth - Correlation Analysis ===\n")

# Load dataset
data("ToothGrowth")

# Preview the data
head(ToothGrowth)
str(ToothGrowth)
summary(ToothGrowth)

# ToothGrowth columns:
# len  - Tooth length (numeric)
# supp - Supplement type: OJ (orange juice) or VC (vitamin C)
# dose - Dose in milligrams/day (0.5, 1.0, 2.0)

# --- Convert supp to numeric for correlation ---
# OJ = 1, VC = 2
tg_numeric <- ToothGrowth
tg_numeric$supp <- as.numeric(factor(ToothGrowth$supp))

cat("\nNumeric version of ToothGrowth:\n")
head(tg_numeric)

# --- Compute Correlation Matrix ---
cor_matrix <- cor(tg_numeric)

cat("\nCorrelation Matrix:\n")
print(round(cor_matrix, 3))

# --- Plot 1: Heatmap of Correlation Matrix ---
# Using base R heatmap
# First create a color palette from blue (negative) to red (positive)
color_palette <- colorRampPalette(c("steelblue", "white", "tomato"))(100)

# Scale the correlation matrix for display
heatmap(cor_matrix,
        main    = "Correlation Heatmap - ToothGrowth Dataset",
        col     = color_palette,
        scale   = "none",
        margins = c(8, 8),
        symm    = TRUE)

# --- Plot 2: Manual Correlation Heatmap with values ---
# Draw a cleaner heatmap using image()
par(mar = c(5, 5, 4, 2))

image(1:3, 1:3, cor_matrix,
      col   = color_palette,
      xaxt  = "n",
      yaxt  = "n",
      main  = "Correlation Heatmap - ToothGrowth (with values)",
      xlab  = "",
      ylab  = "")

# Add axis labels
axis(1, at = 1:3, labels = colnames(cor_matrix), las = 2)
axis(2, at = 1:3, labels = rownames(cor_matrix), las = 1)

# Add correlation values as text on each cell
for (i in 1:3) {
  for (j in 1:3) {
    text(i, j,
         labels = round(cor_matrix[i, j], 2),
         col    = ifelse(abs(cor_matrix[i, j]) > 0.5, "white", "black"),
         cex    = 1.2,
         font   = 2)
  }
}

# Add a title border
box()

# Reset margins
par(mar = c(5.1, 4.1, 4.1, 2.1))

# --- Plot 3: Scatterplot Matrix ---
pairs(tg_numeric,
      main   = "Scatterplot Matrix - ToothGrowth",
      col    = "steelblue",
      pch    = 19,
      cex    = 0.8,
      labels = c("Tooth Length", "Supplement", "Dose"))

# --- Plot 4: Scatterplot - Dose vs Tooth Length ---
plot(tg_numeric$dose, tg_numeric$len,
     main = "Dose vs Tooth Length",
     xlab = "Dose (mg/day)",
     ylab = "Tooth Length",
     col  = ifelse(ToothGrowth$supp == "OJ", "orange", "steelblue"),
     pch  = 19,
     cex  = 1.2)

abline(lm(len ~ dose, data = tg_numeric), col = "red", lwd = 2)

legend("topleft",
       legend = c("OJ (Orange Juice)", "VC (Vitamin C)"),
       col    = c("orange", "steelblue"),
       pch    = 19,
       title  = "Supplement Type")

cat("\n--- Observations: ToothGrowth Correlation ---\n")
cat("  - dose vs len: STRONG POSITIVE correlation\n")
cat("    Higher doses lead to significantly longer teeth\n")
cat("  - supp vs len: WEAK correlation\n")
cat("    Supplement type has a smaller effect on tooth length\n")
cat("  - supp vs dose: NEAR ZERO correlation\n")
cat("    Supplement type and dose are independent variables\n")
