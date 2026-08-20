def choose_action(state, explore=True):
    if explore and rng.random() < epsilon:
        return int(rng.integers(len(ACTIONS)))
    r, c = state
    return int(np.argmax(Q[r, c]))
