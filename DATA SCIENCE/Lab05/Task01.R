#Question 1

year <- readline("Input year: ")

if (as.numeric(year)%%4==0 & as.numeric(year)%%100!=0 | as.numeric(year)%%400==0) {
  print(paste("Output: ", year, "is a leap year."))
} else {
  print(paste("Output: ", year, "is not a leap year."))
}
