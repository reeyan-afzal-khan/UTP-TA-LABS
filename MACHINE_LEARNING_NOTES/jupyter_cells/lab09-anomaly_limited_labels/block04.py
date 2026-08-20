ranked = X_test.copy()
ranked["fraud_label"] = y_test.to_numpy()
ranked["anomaly_score"] = anomaly_score
ranked = ranked.sort_values("anomaly_score", ascending=False)
review_budget = min(100, len(ranked))
top_k_precision = ranked.head(review_budget)["fraud_label"].mean()
print(f"precision among top {review_budget}:", round(top_k_precision, 4))
print(ranked[["fraud_label", "anomaly_score", "amount"]].head(20))
