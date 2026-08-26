#Question 2

library(stringr)

str1 <- readline("Enter string 1: ")
str2 <- readline("Enter string 2: ")
is_similar <- TRUE

if (str_length(str1) != str_length(str2)) {
  is_similar <- FALSE
} else if (toupper(str1) != toupper(str2)) {
  is_similar <- FALSE
}

print(paste("This program compare 2 strings. Both inputs are similar: ", is_similar))
