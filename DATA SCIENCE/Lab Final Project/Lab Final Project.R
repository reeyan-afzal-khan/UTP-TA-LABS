# Data Science final project --- clean a deliberately messy student dataset.
#
# Run with the working directory set to this folder:
#     setwd("path/to/DATA SCIENCE/Lab Final Project")   # or use RStudio's
#     source("Lab Final Project.R")                     # Session > Set
#                                                       # Working Directory
# From a terminal:
#     Rscript "Lab Final Project.R"
#
# Requires tidyverse and lubridate. They are NOT installed automatically:
# a script that silently installs packages can rewrite a shared lab machine's
# library. Install them yourself once, then run this.

for (pkg in c("tidyverse", "lubridate")) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    stop("Package '", pkg, "' is not installed. Run: install.packages(\"", pkg, "\")")
  }
}
library(tidyverse)
library(lubridate)

INPUT_FILE  <- "Unclean Dataset.csv"
OUTPUT_FILE <- "Cleaned Dataset.csv"

if (!file.exists(INPUT_FILE)) {
  stop("Cannot find '", INPUT_FILE, "' in the working directory:\n  ", getwd(),
       "\nSet the working directory to the folder holding this script.")
}

#LOADING AND SPLITTING THE DATA FOR CLEANING
#load the data set
#ISO-8859-1 encoding is used to safely read all currency symbols without crashing
#read_lines is used instead of read_csv because the data is messy, not in perfect tables
raw_lines <- read_lines(INPUT_FILE, locale = locale(encoding = "ISO-8859-1"))

#extract features (columns), separate by ","
#%>% = pipe operator, think of it like step 1 and then?
header <- raw_lines[1] %>% 
  str_split(",") %>% 
  unlist() %>% 
  str_trim()

#remove header row and empty lines, left with raw data
data_lines <- raw_lines[-1] # -1 = selects everything except the header/first row
data_lines <- data_lines[data_lines != ""]

#separate into 2 lists according to the separator used (| or ,)
pipe_indices <- str_detect(data_lines, "\\|")
pipe_lines <- data_lines[pipe_indices]
comma_lines <- data_lines[!pipe_indices]

#PROCESSING THE DATA SEPARATED BY "|"
df_pipe <- read_delim(
  I(pipe_lines), 
  delim = "|", #split the columns by "|"
  col_names = header, 
  trim_ws = TRUE, #removes whitespace
  locale = locale(encoding = "ISO-8859-1"),
  col_types = cols(.default = "c") #force every column to be read as char
)

#removes everything after the first comma found in Total_Payments
df_pipe <- df_pipe %>%
  mutate(Total_Payments = str_remove(Total_Payments, ",.*")) %>%
  select(all_of(header))

#PROCESSING DATA SEPARATED BY ","
#we use read_csv because a normal row in .csv is separated by ","
df_comma <- read_csv(
  I(comma_lines), 
  col_names = header, 
  trim_ws = TRUE,
  locale = locale(encoding = "ISO-8859-1"),
  col_types = cols(.default = "c") #force every column to be read as char
)

#fix the gender in same column as age
df_comma_fixed <- df_comma %>%
  mutate(
    #extracts age if gender column has numbers
    extracted_age = str_extract(Gender, "\\d+"),
    
    #clean gender column to be just letters
    Gender = if_else(str_detect(Gender, "\\d"), str_extract(Gender, "[A-Za-z]"), Gender),
    
    #fill the missing age rows with extracted age
    Age = coalesce(Age, extracted_age)
  ) %>%
  select(-extracted_age)

#MERGING AND CLEANING ALL AT ONCE
#earlier, we force columns to be read as char to allow bind_rows() to work without crashing
full_df <- bind_rows(df_pipe, df_comma_fixed)

clean_df <- full_df %>%
  mutate(
    Student_ID = suppressWarnings(as.integer(Student_ID)), #convert Student_ID back to int
    First_Name = str_to_title(str_trim(First_Name)), #ensure first and last name are correctly capitalized(Title case)
    Last_Name = str_to_title(str_trim(Last_Name)),
    Age = suppressWarnings(as.integer(Age))
  ) %>%
  
  #standardizing gender from male, Female, etc.. to M or F.
  mutate(
    Gender = str_to_upper(str_trim(Gender)), #converting to uppercase
    Gender = case_when(
      str_detect(Gender, "^M") ~ "M", #if starts with M, replace with M
      str_detect(Gender, "^F") ~ "F", #if starts with F, replace with F
      TRUE ~ Gender #if it doesn't start with M or F, then leave it be to not accidentally remove data
    )
  ) %>%
  
  #fixing spelling errors in course names using pattern matching(Regex)
  mutate(
    Course = str_trim(Course),
    Course = case_when(
      str_detect(Course, "Machine Learnin") ~ "Machine Learning",
      str_detect(Course, "Web Developmen|Web Develpment") ~ "Web Development",
      TRUE ~ Course
    )
  ) %>%
  
  #standardizes all dates into one format
  mutate(
    Enrollment_Date_Clean = parse_date_time(Enrollment_Date, orders = c("ymd", "dmy", "mdy")),
    Enrollment_Date = as.Date(Enrollment_Date_Clean)
  ) %>%
  select(-Enrollment_Date_Clean) %>%
  
  #removes anything that is not a number or a dot and converts it to numeric(Ex: $1,200 to 1200)
  mutate(
    Total_Payments = str_remove_all(Total_Payments, "[^0-9.]"),
    Total_Payments = as.numeric(Total_Payments)
  ) %>%
  
  #drops invalid and duplicate rows
  filter(!is.na(Student_ID), !is.na(First_Name)) %>%
  distinct() %>%
  
  #create a surrogate key since there are duplicate student IDs which would cause problems when linking tables in databases such as Students to Grades
  mutate(
    System_Record_ID = row_number()
  ) %>%
  select(System_Record_ID, Student_ID, everything())

#prints the first 6 rows of the clean dataset, something like a preview to check
print(head(clean_df))

#report what the cleaning actually did, so the result can be checked rather
#than trusted. A cleaning script that only prints the clean rows hides how
#many it silently discarded.
cat("\n--- cleaning summary ---\n")
cat("raw data lines read      :", length(data_lines), "\n")
cat("  pipe-delimited         :", length(pipe_lines), "\n")
cat("  comma-delimited        :", length(comma_lines), "\n")
cat("rows after merge         :", nrow(full_df), "\n")
cat("rows after clean/dedupe  :", nrow(clean_df), "\n")
cat("dropped                  :", nrow(full_df) - nrow(clean_df), "\n\n")

cat("Courses after spelling repair:\n")
print(table(clean_df$Course, useNA = "ifany"))
cat("\nGender after standardisation:\n")
print(table(clean_df$Gender, useNA = "ifany"))
cat("\nDates that failed to parse:", sum(is.na(clean_df$Enrollment_Date)), "\n")

#writes the cleaned file beside the input
write_csv(clean_df, OUTPUT_FILE)
cat("\nWrote", OUTPUT_FILE, "with", nrow(clean_df), "rows.\n")
