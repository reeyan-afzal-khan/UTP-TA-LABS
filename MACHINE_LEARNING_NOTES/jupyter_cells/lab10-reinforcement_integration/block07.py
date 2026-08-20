# Evaluate the learned greedy policy.
successes = 0
returns = []
for _ in range(200):
    state = START
    total_reward = 0.0
    for _ in range(100):
        action = choose_action(state, explore=False)
        state, reward, done = step(state, action)
        total_reward += reward
        if done:
            successes += int(state == GOAL)
            break
    returns.append(total_reward)

print("success rate:", successes / 200)
print("mean return:", round(float(np.mean(returns)), 3))
print("learned action at start:", ACTION_NAMES[choose_action(START, explore=False)])
