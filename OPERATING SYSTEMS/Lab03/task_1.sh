#!/bin/bash
#STEP 1: Start the program. 
#STEP 2: Read the value of n.
#STEP 3: Calculate, r=$((n % 2))
#STEP 4: If the value of r equals 0 then print the number is even
#STEP 5: If the value of r not equal to 0 then print the number is odd.

echo -n "Enter the Number: " 
read n

r=$((n % 2))

if [ $r -eq 0 ]
then
    echo "$n is an Even number"
else
    echo "$n is an Odd number"
fi
