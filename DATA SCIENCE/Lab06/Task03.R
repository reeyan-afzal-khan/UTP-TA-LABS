student.data <- data.frame(
  name = c("Anastasia", "Dima", "Michael", "Matthew", "Laura", "Kevin", "Jonas"),
  score = c(12.5, 9.0, 16.5, 12.0, 9.0, 8.0, 19.0),
  attempts = c(1, 3, 2, 3, 2, 1, 2),
  qualify = c("yes", "no", "yes", "no", "no", "no", "yes")
)

student.newdata <- data.frame(
  name = ("Emily"),
  score = (14.5),
  attempts = (1),
  qualify = ("yes")
)

student.finaldata <- rbind(student.data, student.newdata)
