# Lab 2, Question 3 --- Uppercase a name and partially mask a phone number.
#
# Keep the first 3 and last 4 characters, hide the middle:
#
#     0123456789   ->   012-xxxxx6789

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

name <- ask("Name: ")
phonenumber <- ask("Phone Number: ")

# Masking only makes sense once there is something left in the middle to
# hide; with 7 characters or fewer the "mask" would overlap the parts kept.
if (nchar(phonenumber) < 8) {
  stop("Phone number must have at least 8 digits to be masked.")
}

first3 <- substr(phonenumber, 1, 3)
last4  <- substr(phonenumber, nchar(phonenumber) - 3, nchar(phonenumber))

print(paste0("Hi, ", toupper(name),
             ". A verification code has been sent to ",
             first3, "-xxxxx", last4))
