#Question 1
age = c(55,57,56,52,51,59,58,53,59,55,60,60,60,60,52,55,56,51,60,52,54,56,52,57,54,56,58,53,53,50,55,51,57,60,57,55,51,50,57,58)

age_factor <- factor(age)
age_table <- table(age_factor)
print(age_table)

age_groups <- cut(as.numeric(as.character(age_factor)),
                   breaks = seq(50, 60, by = 2),
                   right = FALSE,
                   include.lowest = TRUE)

range_table <- table("Age Range" = age_groups)
print(range_table)


