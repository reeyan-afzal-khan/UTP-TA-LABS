#Question 3
v1 <- c(1:24)
v2 <- c(25:54)

Array1 <- array(c(v1), dim = c(2,4,3))
Array2 <- array(c(v2), dim = c(3,2,5))

cat("Array1", "\n")
print(Array1)
cat("Array2", "\n")
print(Array2)

cat("The second row of the second matrix of the array: ", "\n", Array1[2,,2])
cat("\n", "The element in the 3rd row and 2nd column of the 1st matrix:", "\n", Array2[3,2,1])
