# Lab 6, Task 1 --- Create the base student data frame.
#
# A data frame is a list of equal-length vectors presented as a table: each
# COLUMN is one vector with one type, each ROW is one observation. That is
# why score can be numeric while name is character in the same object --- a
# matrix could not do this, because a matrix holds a single type throughout.

student.data <- data.frame(
  name = c("Anastasia", "Dima", "Michael", "Matthew", "Laura", "Kevin", "Jonas"),
  score = c(12.5, 9.0, 16.5, 12.0, 9.0, 8.0, 19.0),
  attempts = c(1, 3, 2, 3, 2, 1, 2)
)

# Assignment alone prints nothing when the file is run with Rscript, so every
# result a marker needs to see has to be printed explicitly.
print(student.data)

cat("\nRows:", nrow(student.data), " Columns:", ncol(student.data), "\n")
