# Lab 5, Question 2 --- Print the cube of every integer from 1 to n.

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

num <- as.numeric(ask("Input an integer: "))

# Guard before building the sequence. 1:NA is an error, and 1:0 silently
# counts DOWN (1, 0) rather than producing an empty loop --- a classic R
# trap. Checking num >= 1 avoids both.
if (is.na(num) || num != floor(num) || num < 1) {
  stop("Please enter a whole number of 1 or more.")
}

for (i in 1:num) {
  print(paste("Number is: ", i, "and cube of the ", i, "is :", i^3))
}
