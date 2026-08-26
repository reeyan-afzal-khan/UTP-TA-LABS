#!/bin/bash
#STEP 1: Start the program. 
#STEP 2: Read the value of n. 
#STEP 3: Calculate „i=expr $n-1‟.
#STEP 4: If the value of i is greater than 1 then calculate „n=expr $n \* $i‟ and „i=expr $i – 1‟ 
#STEP 5: Print the factorial of the given number.

echo -n "Enter a Number: "
read n
i=`expr $n - 1`
p=1
while [ $i -ge 1 ] 
do
  n=`expr $n \* $i` 
  i=`expr $i - 1` 
done
echo "The Factorial of the given Number is $n"
