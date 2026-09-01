# Lab 1, Task 2 --- Round two given values.
#
# round(x, n) keeps n digits after the decimal point.

num1 <- 0.956786
num2 <- 7.8345901

print(round(num1, 2))   # expected 0.96
print(round(num2, 3))   # expected 7.835

# A detail worth knowing early: R rounds half to EVEN, not half away from
# zero, so round(0.5) is 0 and round(1.5) is 2. This is the IEEE 754
# convention and it keeps repeated rounding from drifting upward.
cat("\nround(0.5) =", round(0.5), " round(1.5) =", round(1.5), "\n")
cat("Neither is a bug: R rounds a tie to the nearest EVEN number.\n")
