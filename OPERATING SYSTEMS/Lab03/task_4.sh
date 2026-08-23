#!/bin/bash
#STEP 1: Start the program. 
#STEP 2: Read the value of a,b.
#STEP 3: Calculate the swapping of two values by using a temporary variable temp. 
#STEP 4: Print the value of a and b.

echo -n "Enter Two Numbers(with a space): " 
read a b
temp=$a 
a=$b 
b=$temp
echo "after swapping: " $a $b 
