#Question 3
studentRecord <- list(
  c("Robert", "Hemsworth", "Scarlett", "Evans", "Pratt", "Larson", "Holland", "Paul", "Simu", "Renner"), 
  c(59, 71, 83, 68, 65, 57, 62, 92, 92, 59),
  c(89, 86, 65, 52, 60, 67, 40, 77, 90, 61)
)

names(studentRecord) <- c("Student_Name", "Chemistry", "Physics")

highestChemistry <- max(studentRecord$Chemistry)
highestPhysics <- max(studentRecord$Physics)

highestStudent <- studentRecord$Student_Name[which(studentRecord$Chemistry == highestChemistry & studentRecord$Physics == highestPhysics)] 

count <- sum(studentRecord$Chemistry <= 49 & studentRecord$Physics <= 49)

cat("Number of student that failed Chemistry and Physics: ", count, "\n")
cat("Student with highest score: ", paste(highestStudent, collapse=", "), "\n")