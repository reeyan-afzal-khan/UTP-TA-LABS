# Lab 1, Task 1 --- Create 20 numbers and display their squares.
#
# R is vectorised: `numbers ^ 2` squares all 20 values at once. There is no
# loop here because none is needed, and writing one would be slower and
# longer. That habit matters for the rest of the course.

numbers <- 1:20
squares <- numbers ^ 2

print(numbers)
print(squares)

# cbind() pairs the two vectors as columns so each number sits beside its
# own square, which is much easier to check by eye than two separate rows.
cat("\nSide by side:\n")
print(cbind(numbers, squares))
