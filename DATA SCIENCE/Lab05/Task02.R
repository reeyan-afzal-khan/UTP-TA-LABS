#Question 2

num <- as.numeric(readline("Input an integer: "))
v <- 1:num

for (i in v) {
  print(paste("Number is: ", i, "and cube of the ", i, "is :", i^3))
}
