# Lab 2, Question 1 --- Classify BMI into one of four categories.
#
# BMI = weight(kg) / height(m)^2
#
# readline() returns "" whenever the session is NOT interactive, so a script
# written with a bare readline() works in RStudio and then fails with
# "missing value where TRUE/FALSE needed" the moment it is run with Rscript.
# ask() keeps the interactive prompt and falls back to reading one line from
# standard input, so the same file works in both places.

ask <- local({
  con <- NULL
  function(prompt) {
    if (interactive()) return(readline(prompt))
    cat(prompt)
    # Open the stdin connection ONCE and reuse it. Calling
    # readLines("stdin") repeatedly opens a fresh connection each time and
    # loses whatever the previous one had buffered, so only the first
    # prompt would ever receive a value.
    if (is.null(con)) con <<- file("stdin", open = "r")
    line <- readLines(con, n = 1)
    if (length(line) == 0) "" else line
  }
})

weight <- as.numeric(ask("Enter weight (kg): "))
height <- as.numeric(ask("Enter height (m): "))

# as.numeric() turns unparseable text into NA with only a warning, so check
# before using the values in a comparison.
if (is.na(weight) || is.na(height) || weight <= 0 || height <= 0) {
  stop("Weight and height must both be positive numbers.")
}

bmi <- weight / (height^2)

is_underweight <- FALSE
is_normal      <- FALSE
is_overweight  <- FALSE
is_obese       <- FALSE

# The bands are contiguous, so each else-if only needs its upper bound ---
# reaching that branch already proves the lower bound.
if (bmi <= 18.4) {
  is_underweight <- TRUE
} else if (bmi <= 24.9) {
  is_normal <- TRUE
} else if (bmi <= 39.9) {
  is_overweight <- TRUE
} else {
  is_obese <- TRUE
}

cat(sprintf("\nBMI: %.1f\n\n", bmi))
cat(paste("Underweight: ", is_underweight, "\n"))
cat(paste("Normal: ",      is_normal,      "\n"))
cat(paste("Overweight: ",  is_overweight,  "\n"))
cat(paste("Obese: ",       is_obese,       "\n"))
