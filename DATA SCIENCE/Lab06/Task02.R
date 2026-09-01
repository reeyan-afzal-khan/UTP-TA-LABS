# Lab 6, Task 2 --- Add the qualify column.
#
# A new column is just another vector assigned into the frame. Its length
# must match the existing number of rows (7); R would otherwise recycle a
# shorter vector, silently inventing data.

student.data <- data.frame(
  name = c("Anastasia", "Dima", "Michael", "Matthew", "Laura", "Kevin", "Jonas"),
  score = c(12.5, 9.0, 16.5, 12.0, 9.0, 8.0, 19.0),
  attempts = c(1, 3, 2, 3, 2, 1, 2),
  qualify = c("yes", "no", "yes", "no", "no", "no", "yes")
)

print(student.data)

cat("\nColumn names:", paste(names(student.data), collapse = ", "), "\n")
