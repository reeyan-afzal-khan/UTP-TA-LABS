feature_names = model.named_steps["preprocess"].get_feature_names_out()
print(export_text(
    model.named_steps["tree"],
    feature_names=list(feature_names),
    max_depth=3,
))
