#Question 1
v <- c(33, 24, 54, 94, 16, 89, 60, 6, 77, 61, 13, 44, 26, 24, 73, 73, 90, 39, 90, 54)

pass <- TRUE

countA <- sum(v>=90 & v<=100)
cat("Grade A (90-100):", countA, "\n")
cat("Pass: ", pass, "\n")

countB <- sum(v>=80 & v<=89)
cat("Grade B (80-89):", countB, "\n")
cat("Pass: ", pass, "\n")

countC <- sum(v>=70 & v<=79)
cat("Grade C (70-79):", countC, "\n")
cat("Pass: ", pass, "\n")

countD <- sum(v>=60 & v<=69)
cat("Grade D (60-69):", countD, "\n")
cat("Pass: ", pass, "\n")

countE <- sum(v>=50 & v<=59)
cat("Grade E (50-59):", countE, "\n")
cat("Pass: ", pass, "\n")

countF <- sum(v<=49)
cat("Grade F (<=49):", countF, "\n")
cat("Pass: ", pass <- FALSE)