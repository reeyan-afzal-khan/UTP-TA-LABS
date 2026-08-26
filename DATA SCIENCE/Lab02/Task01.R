#Question 1

weight <- readline("Enter weight (kg): ")
height <- readline("Enter height (m): ")

weight <- as.numeric(weight)
height <- as.numeric(height)

bmi <- weight/(height^2)

is_underweight <- FALSE
is_normal <- FALSE
is_overweight <- FALSE
is_obese <- FALSE

if (bmi <= 18.4) {
  is_underweight <- TRUE
} else if (bmi >= 18.5 & bmi <= 24.9) {
  is_normal <- TRUE
} else if (bmi >= 25.0 & bmi <= 39.9) {
  is_overweight <- TRUE
} else {
  is_obese <- TRUE
}

cat(paste("Underweight: ", is_underweight, "\n"))
cat(paste("Normal: ", is_normal, "\n"))
cat(paste("Overweight: ", is_overweight, "\n"))
cat(paste("Obese: ", is_obese, "\n"))
