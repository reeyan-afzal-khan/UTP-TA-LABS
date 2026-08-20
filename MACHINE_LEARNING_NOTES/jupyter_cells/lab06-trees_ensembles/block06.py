# Plot only the top levels so the learned rules remain readable.
feature_names = model.named_steps["preprocess"].get_feature_names_out()
plt.figure(figsize=(12, 6))
plot_tree(
    model.named_steps["tree"],
    feature_names=feature_names,
    class_names=["did not survive", "survived"],
    max_depth=2,
    filled=True,
    fontsize=8,
)
plt.title("Top of the fitted Titanic decision tree")
plt.tight_layout()
plt.show()
