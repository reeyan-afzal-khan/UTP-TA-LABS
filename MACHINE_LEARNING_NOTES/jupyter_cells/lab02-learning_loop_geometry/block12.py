# Cosine similarity answers a different question: direction rather than magnitude.
cosine_distance = pairwise_distances(X_scaled[:5], metric="cosine")
print("\nCosine similarities:\n", 1 - cosine_distance)
