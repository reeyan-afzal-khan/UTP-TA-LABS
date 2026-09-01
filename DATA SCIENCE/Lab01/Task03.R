# Lab 1, Task 3 --- Read a circle radius and calculate the area.
#
#   area = pi * r^2
#
# readline() returns "" whenever the session is NOT interactive, so a script
# written with a bare readline() works in RStudio and then fails the moment
# it is run with Rscript. ask() keeps the interactive prompt and falls back
# to reading one line from standard input, so the same file works in both.

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

radius <- as.numeric(ask("Enter radius: "))

# as.numeric() turns unparseable text into NA with only a warning, so check
# before using the value in arithmetic.
if (is.na(radius) || radius <= 0) {
  stop("Radius must be a positive number.")
}

area <- pi * radius ^ 2

print(paste("Circle area:", area))
cat(sprintf("Rounded to 2 decimal places: %.2f\n", area))
