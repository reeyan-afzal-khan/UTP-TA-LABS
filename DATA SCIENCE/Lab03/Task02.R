#Question 2
studentRecord <- list(
  c("Robert", "Hemsworth", "Scarlett", "Evans", "Pratt", "Larson", "Holland", "Paul", "Simu", "Renner"), 
  c(59, 71, 83, 68, 65, 57, 62, 92, 92, 59)
)

names(studentRecord) <- c("Student_Name", "Exam_Score")

highestScore <- max(studentRecord$Exam_Score)
lowestScore <- min(studentRecord$Exam_Score)
avgScore <- mean(studentRecord$Exam_Score)

highestStudent <- studentRecord$Student_Name[which(studentRecord$Exam_Score == highestScore)] 
lowestStudent <- studentRecord$Student_Name[which(studentRecord$Exam_Score == lowestScore)]

cat("Highest score: ", highestScore, "\n")
cat("Lowest score: ", lowestScore, "\n")
cat("Average score: ", avgScore, "\n")
cat("Student with highest score: ", paste(highestStudent, collapse=", "), "\n")
cat("Student with lowest score: ", lowestStudent, "\n")