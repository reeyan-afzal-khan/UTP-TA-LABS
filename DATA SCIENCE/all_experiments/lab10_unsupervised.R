# Lab 10 - Clustering and PCA with Mall Customers and Wine Recognition
course_root <- if (dir.exists("all_datasets")) "." else ".."
mall_path <- file.path(course_root, "all_datasets", "mall_customers_dataset.csv")
wine_path <- file.path(course_root, "all_datasets", "wine_recognition_dataset.csv")

# -----------------------------------------------------------------------------
# Part A: k-means customer segmentation
# -----------------------------------------------------------------------------
mall <- read.csv(mall_path, check.names = TRUE)
X <- mall[, c("Age", "Annual.Income..k..", "Spending.Score..1.100.")]
Xs <- scale(X)

# Compare candidate k values using total within-cluster sum of squares.
set.seed(42)
k_grid <- 2:8
wcss <- numeric(length(k_grid))
for (i in seq_along(k_grid)) {
  fit_k <- kmeans(Xs, centers = k_grid[i], nstart = 50)
  wcss[i] <- fit_k$tot.withinss
}
selection <- data.frame(k = k_grid, total_withinss = wcss)
cat("K-MEANS candidate solutions:\n")
print(selection)
plot(selection$k, selection$total_withinss, type = "o", pch = 16,
     xlab = "Number of clusters (k)", ylab = "Total within-cluster SS",
     main = "K-means cluster-selection diagnostic")

# Use k=5 as a teaching solution; students should justify or challenge this choice.
set.seed(42)
km <- kmeans(Xs, centers = 5, nstart = 100)
mall$cluster <- factor(km$cluster)
cat("\nCluster sizes:\n")
print(table(mall$cluster))
cat("Cluster profiles in original units:\n")
print(aggregate(X, by = list(cluster = mall$cluster), FUN = mean))

plot(mall$Annual.Income..k.., mall$Spending.Score..1.100.,
     col = mall$cluster, pch = 16,
     xlab = "Annual income (k$)", ylab = "Spending score",
     main = "Mall-customer k-means segments")

# Stability check across random seeds using label-invariant co-clustering agreement.
co_cluster_agreement <- function(a, b) {
  same_a <- outer(a, a, "==")
  same_b <- outer(b, b, "==")
  mean(same_a == same_b)
}
seed_grid <- c(7, 19, 42, 101, 2026)
assignments <- list()
withinss <- numeric(length(seed_grid))
for (i in seq_along(seed_grid)) {
  set.seed(seed_grid[i])
  z <- kmeans(Xs, centers = 5, nstart = 20)
  assignments[[i]] <- z$cluster
  withinss[i] <- z$tot.withinss
}
agreements <- sapply(seq_along(assignments), function(i) {
  co_cluster_agreement(assignments[[1]], assignments[[i]])
})
stability <- data.frame(seed = seed_grid, total_withinss = withinss,
                        agreement_with_first = agreements)
cat("\nK-MEANS stability check:\n")
print(stability)

# -----------------------------------------------------------------------------
# Part B: PCA on chemical measurements; labels are withheld during fitting
# -----------------------------------------------------------------------------
wine <- read.csv(wine_path, stringsAsFactors = FALSE)
feature_names <- setdiff(names(wine), c("sample_id", "cultivar"))
pca <- prcomp(wine[, feature_names], center = TRUE, scale. = TRUE)

explained <- (pca$sdev^2) / sum(pca$sdev^2)
cumulative <- cumsum(explained)
variance_table <- data.frame(
  component = seq_along(explained),
  explained = explained,
  cumulative = cumulative
)
cat("\nPCA explained variance (first 8 components):\n")
print(round(head(variance_table, 8), 3))
cat("Components needed for at least 80% cumulative variance:",
    which(cumulative >= .80)[1], "\n")

cat("\nLargest absolute PC1 loadings:\n")
print(sort(abs(pca$rotation[, 1]), decreasing = TRUE)[1:6])
cat("Largest absolute PC2 loadings:\n")
print(sort(abs(pca$rotation[, 2]), decreasing = TRUE)[1:6])

plot(seq_along(explained), explained, type = "o", pch = 16,
     xlab = "Principal component", ylab = "Proportion variance explained",
     main = "PCA explained variance")

scores <- pca$x[, 1:2]
plot(scores[, 1], scores[, 2], pch = 16,
     xlab = "PC1", ylab = "PC2",
     main = "Wine PCA scores (labels withheld during fitting)")

# Labels are introduced only after PCA for post-hoc interpretation.
cat("\nCultivar counts for post-hoc interpretation:\n")
print(table(wine$cultivar))
plot(scores[, 1], scores[, 2], pch = as.integer(factor(wine$cultivar)),
     xlab = "PC1", ylab = "PC2",
     main = "Wine PCA scores with cultivar shown after fitting")
legend("topright", legend = levels(factor(wine$cultivar)),
       pch = seq_along(levels(factor(wine$cultivar))), bty = "n")
