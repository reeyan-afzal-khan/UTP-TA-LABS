#!/bin/bash
# Lab 3, Task 1 --- Decide whether a number is even or odd.
#
# STEP 1: Read a number from the user.
# STEP 2: Reject anything that is not an integer.
# STEP 3: Compute the remainder r = n mod 2.
# STEP 4: r == 0 means even, otherwise odd.
#
# Run: bash Task01.sh

set -u  # abort on an unset variable rather than silently using ""

read -r -p "Enter the number: " n

# Validate before doing arithmetic. Without this, a word like "abc" makes
# $(( )) evaluate it as 0 and the script confidently reports "even".
# The pattern allows an optional sign followed by one or more digits.
if ! [[ "$n" =~ ^[+-]?[0-9]+$ ]]; then
    echo "Error: '$n' is not an integer." >&2
    exit 1
fi

r=$(( n % 2 ))

# Always quote "$n" so a value containing spaces stays a single word.
if [ "$r" -eq 0 ]; then
    echo "$n is an even number"
else
    echo "$n is an odd number"
fi
