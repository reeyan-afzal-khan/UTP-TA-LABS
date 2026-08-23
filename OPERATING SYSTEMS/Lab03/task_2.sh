#!/bin/bash
#STEP 1: Start the program. 
#STEP 2: Read the value of year.
#STEP 3: Calculate, b=expr $y%4.
#STEP 4: If the value of b equals 0 then print the year is a leap year
#STEP 5: If the value of r not equal to 0 then print the year is not a leap year.

echo -n "Enter the year: "
read y

b=`expr $y % 4`
if [ $b -eq 0 ]
then
    echo "$y is a leap year"
else
    echo "$y is not a leap year"
fi
