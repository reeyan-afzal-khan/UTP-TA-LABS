# Lab 10 - Clustering and PCA with Mall Customers and Wine Recognition
course_root <- if (dir.exists("all_datasets")) "." else ".."
mall_path <- file.path(course_root, "all_datasets", "mall_customers_dataset.csv")
wine_path <- file.path(course_root, "all_datasets", "wine_recognition_dataset.csv")

# Part A: k-means customer segmentation
mall <- read.csv(mall_path, check.names = TRUE)
X <- mall[, c("Age", "Annual.Income..k..", "Spending.Score..1.100.")]
Xs <- scale(X)
set.seed(42)
km <- kmeans(Xs, centers = 5, nstart = 50)
mall$cluster <- factor(km$cluster)
cat("Cluster sizes:\n")
print(table(mall$cluster))
cat("Cluster profiles in original units:\n")
print(aggregate(X, by = list(cluster = mall$cluster), FUN = mean))

plot(mall$Annual.Income..k.., mall$Spending.Score..1.100.,
     col = mall$cluster, pch = 16,
     xlab = "Annual income (k$)", ylab = "Spending score",
     main = "Mall-customer k-means segments")

# Part B: PCA on chemical measurements. Cultivar is withheld during fitting.
wine <- read.csv(wine_path, stringsAsFactors = FALSE)
feature_names <- setdiff(names(wine), c("sample_id", "cultivar"))
pca <- prcomp(wine[, feature_names], center = TRUE, scale. = TRUE)
cat("\nPCA explained variance:\n")
print(summary(pca))
cat("\nLargest absolute PC1 loadings:\n")
print(sort(abs(pca$rotation[,1]), decreasing = TRUE)[1:6])

scores <- pca$x[, 1:2]
plot(scores[,1], scores[,2], pch = 16,
     xlab = "PC1", ylab = "PC2",
     main = "Wine PCA scores (labels withheld during fitting)")

# Labels are introduced only after PCA to interpret the discovered structure.
cat("\nCultivar counts for post-hoc interpretation:\n")
print(table(wine$cultivar))
