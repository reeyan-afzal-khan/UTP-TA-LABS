# Lab 5, Question 3 --- Armstrong number test.
#
# An n-digit number is an Armstrong (narcissistic) number when the sum of
# its digits each raised to the power n equals the number itself:
#
#     153 has 3 digits ->  1^3 + 5^3 + 3^3 = 1 + 125 + 27 = 153   yes
#     154 has 3 digits ->  1^3 + 5^3 + 4^3 = 1 + 125 + 64 = 190   no

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

cat("Check whether an n digits number is Armstrong or not:", "\n")
cat("-----------------------------------------------------------\n")

num <- ask("Input an integer: ")

# Validate the TEXT before splitting it: strsplit on "abc" happily produces
# letters, and as.numeric then yields NA for every one of them.
if (!grepl("^[0-9]+$", num)) {
  stop("Please enter a non-negative whole number.")
}

num_digits  <- strsplit(num, "")[[1]]      # split the input into characters
num_length  <- length(num_digits)          # digit count = the exponent
num_numeric <- as.numeric(num_digits)      # characters back to numbers

total <- 0
for (i in num_numeric) {
  total <- total + i^num_length
}

# Compare NUMBER with NUMBER. Comparing the total against the original
# string would coerce the total to text and make the test depend on how R
# happens to format it.
if (total == as.numeric(num)) {
  cat(num, "is an Armstrong number.\n")
} else {
  cat(num, "is not an Armstrong number. Digit-power sum =", total, "\n")
}
