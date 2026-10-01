# Run every core course experiment from the DATA SCIENCE project root.
# Interactive graphics will be produced by several labs.
experiments <- sprintf("all_experiments/lab%02d_%s.R",
                       1:10,
                       c("workflow", "data_quality", "wrangling", "eda", "visualization",
                         "inference", "regression", "classification", "validation", "unsupervised"))
for (f in experiments) {
  cat("\n==============================\n")
  cat("Running", f, "\n")
  cat("==============================\n")
  source(f, echo = FALSE)
}
