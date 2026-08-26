#Question 2
V1 <- c(2,3,1,5,4,6,8,7,9)

Matrix_1 <- matrix(V1, nrow = 3, ncol = 3, byrow = TRUE)
Matrix_2 <- t(Matrix_1)
colnames(Matrix_1) <- colnames(Matrix_2) <- c("C1", "C2", "C3")
rownames(Matrix_1) <- rownames(Matrix_2) <- c("R1", "R2", "R3")

add <- Matrix_1 + Matrix_2
minus <- Matrix_1 - Matrix_2
multiply <- Matrix_1 * Matrix_2
divide <- Matrix_1 / Matrix_2

print(add)
print(minus)
print(multiply)
print(divide)