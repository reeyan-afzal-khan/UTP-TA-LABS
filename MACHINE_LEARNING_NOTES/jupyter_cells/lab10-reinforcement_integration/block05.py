training_returns = []

for episode in range(5000):
    state = START
    done = False
    episode_return = 0.0

    for _ in range(100):
        action = choose_action(state, explore=True)
        next_state, reward, done = step(state, action)
        episode_return += reward

        r, c = state
        nr, nc = next_state
        target = reward if done else reward + gamma * np.max(Q[nr, nc])
        Q[r, c, action] += alpha * (target - Q[r, c, action])
        state = next_state

        if done:
            break

    training_returns.append(episode_return)
    epsilon = max(min_epsilon, epsilon * 0.9985)
