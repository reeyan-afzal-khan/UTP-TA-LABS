#!/bin/bash
# Lab 3, Task 2 --- Decide whether a year is a leap year.
#
# STEP 1: Read a year from the user.
# STEP 2: Reject non-integer and non-positive input.
# STEP 3: Apply the full Gregorian rule, not just "divisible by 4".
# STEP 4: Report the result.
#
# The Gregorian rule has three clauses, applied in this order:
#   - divisible by 400            -> leap      (2000 is a leap year)
#   - otherwise divisible by 100  -> NOT leap  (1900 and 2100 are not)
#   - otherwise divisible by 4    -> leap      (2024 is)
#   - otherwise                   -> not leap
#
# Testing only "year % 4 == 0" wrongly calls 1900 and 2100 leap years.
# That is the century bug the 400/100/4 rule exists to prevent.
#
# Run: bash Task02.sh

set -u

read -r -p "Enter the year: " y

if ! [[ "$y" =~ ^[0-9]+$ ]] || [ "$y" -eq 0 ]; then
    echo "Error: '$y' is not a positive year." >&2
    exit 1
fi

# (( )) is bash arithmetic evaluation: it returns success when the
# expression is non-zero, so it reads naturally as a condition.
if (( y % 400 == 0 || (y % 4 == 0 && y % 100 != 0) )); then
    echo "$y is a leap year"
else
    echo "$y is not a leap year"
fi
