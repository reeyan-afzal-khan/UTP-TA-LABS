#Question 3

name <- readline("Name: ")
phonenumber <- readline("Phone Number: ")

print(paste("Hi, ", toupper(name), ". A verification code has been sent to ", substring(phonenumber, 1, 3), "-xxxxx", substring(phonenumber, nchar(phonenumber) - 3)))
