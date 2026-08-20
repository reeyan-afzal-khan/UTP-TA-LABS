for round_no in range(rounds):
    active_idx = np.array(sorted(active_labeled))
    random_idx = np.array(sorted(random_labeled))

    active = make_model()
    random_model = make_model()
    active.fit(X_pool.iloc[active_idx], y_pool[active_idx])
    random_model.fit(X_pool.iloc[random_idx], y_pool[random_idx])

    active_score = accuracy_score(y_val, active.predict(X_val))
    random_score = accuracy_score(y_val, random_model.predict(X_val))
    label_counts.append(len(active_labeled))
    active_val_scores.append(active_score)
    random_val_scores.append(random_score)
    print(
        f"round {round_no + 1}: labels={len(active_labeled)}, "
        f"active_val={active_score:.3f}, random_val={random_score:.3f}"
    )

    if round_no == rounds - 1:
        break

    # Uncertainty sampling: ask for labels closest to probability 0.5.
    active_unlabeled = np.array([
        i for i in range(len(X_pool)) if i not in active_labeled
    ])
    prob = active.predict_proba(X_pool.iloc[active_unlabeled])[:, 1]
    uncertainty = np.abs(prob - 0.5)
    active_query = active_unlabeled[np.argsort(uncertainty)[:query_batch]]
    active_labeled.update(active_query.tolist())

    # Same label budget, but query randomly as a baseline policy.
    random_unlabeled = np.array([
        i for i in range(len(X_pool)) if i not in random_labeled
    ])
    random_query = rng_random.choice(
        random_unlabeled, size=query_batch, replace=False
    )
    random_labeled.update(random_query.tolist())
