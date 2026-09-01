# Lab 5, Question 1 --- Leap year test.
#
# The Gregorian rule is not "divisible by 4". It is:
#     divisible by 400              -> leap      (2000)
#     else divisible by 100         -> NOT leap  (1900, 2100)
#     else divisible by 4           -> leap      (2024)
#     else                          -> not leap  (2023)
#
# Written as one expression with R's operator precedence (& binds tighter
# than |), that is exactly the condition below.

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

year <- as.numeric(ask("Input year: "))

if (is.na(year) || year != floor(year) || year <= 0) {
  stop("Please enter a positive whole-number year.")
}

is_leap <- (year %% 4 == 0 & year %% 100 != 0) | (year %% 400 == 0)

if (is_leap) {
  print(paste("Output: ", year, "is a leap year."))
} else {
  print(paste("Output: ", year, "is not a leap year."))
}
