#!/bin/bash
# Lab 3, Task 3 --- Compute the factorial of a number.
#
# STEP 1: Read a number from the user.
# STEP 2: Reject negative input --- factorial is undefined for it.
# STEP 3: Start the product at 1, which is also the answer for 0! and 1!.
# STEP 4: Multiply by every integer from 2 up to n.
# STEP 5: Print the result, still naming the original n.
#
# Run: bash Task03.sh

set -u

read -r -p "Enter a number: " n

if ! [[ "$n" =~ ^[+-]?[0-9]+$ ]]; then
    echo "Error: '$n' is not an integer." >&2
    exit 1
fi

# Factorial is not defined for negative integers, so say so rather than
# returning a meaningless value.
if [ "$n" -lt 0 ]; then
    echo "Error: factorial is undefined for negative numbers." >&2
    exit 1
fi

# Accumulate into a separate variable. The original loop multiplied into n
# itself, which destroyed the input before it could be printed, and left
# 0! reported as 0 because the loop body never ran.
#
# Seeding at 1 handles 0! = 1 and 1! = 1 with no special case: the loop
# below simply does not execute for n < 2.
product=1
for (( i = 2; i <= n; i++ )); do
    product=$(( product * i ))
done

echo "The factorial of $n is $product"

# Note: bash integers are 64-bit, so this silently overflows past 20!.
# Try 21 and compare against the true value to see it happen.
