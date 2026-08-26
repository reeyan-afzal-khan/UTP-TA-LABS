#Question 3

cat("Check whether an n digits number is Armstrong or not:", "\n")
cat("-----------------------------------------------------------")

num <- as.character(readline("Input an integer: "))

num_digits <- strsplit(num, "")[[1]] #splits input into list
num_length <- length(num_digits) #length of list (exponent)
num_numeric <- as.numeric(num_digits) #convert list back to numeric

sum <- 0
for (i in num_numeric) {
  sum <- sum + i^num_length
}

if (sum == num) {
  cat(num, "is an Armstrong number.")
} else {
  cat(num, "is not an Armstrong number.")
}
