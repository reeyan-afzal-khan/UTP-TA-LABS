# Lab 2, Question 2 --- Case-insensitive comparison of two strings.
#
# Folding BOTH strings to one case before comparing is what makes the test
# case-insensitive: "Hello" and "HELLO" both become "HELLO".
#
# Base R is enough here (nchar, toupper), so no extra package is needed.

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

str1 <- ask("Enter string 1: ")
str2 <- ask("Enter string 2: ")

# A length check is not needed as a separate branch: two strings of
# different lengths can never be equal, so the comparison already covers it.
is_similar <- toupper(str1) == toupper(str2)

print(paste("This program compares 2 strings. Both inputs are similar: ",
            is_similar))
