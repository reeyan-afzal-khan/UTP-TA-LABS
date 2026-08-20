# The acquisition policy is now locked. Evaluate each final model on test once.
active_final_idx = np.array(sorted(active_labeled))
random_final_idx = np.array(sorted(random_labeled))
active_final = make_model()
random_final = make_model()
active_final.fit(X_pool.iloc[active_final_idx], y_pool[active_final_idx])
random_final.fit(X_pool.iloc[random_final_idx], y_pool[random_final_idx])
print("final active-learning test accuracy:",
      round(accuracy_score(y_test, active_final.predict(X_test)), 3))
print("final random-query test accuracy:",
      round(accuracy_score(y_test, random_final.predict(X_test)), 3))
