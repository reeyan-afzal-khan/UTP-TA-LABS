#!/bin/bash
# Lab 3, Task 4 --- Swap the values of two variables.
#
# STEP 1: Read two values from the user.
# STEP 2: Show them before the swap.
# STEP 3: Exchange them using a temporary variable.
# STEP 4: Show them after the swap.
#
# Run: bash Task04.sh

set -u

read -r -p "Enter two values (separated by a space): " first second

# read assigns "" to second if only one value was typed.
if [ -z "${second:-}" ]; then
    echo "Error: two values are required." >&2
    exit 1
fi

echo "Before swap: first='$first'  second='$second'"

# The temporary holds the value that is about to be overwritten.
# Without it, "first=$second" destroys the original first value and both
# variables end up holding the same thing.
temp="$first"
first="$second"
second="$temp"

echo "After swap:  first='$first'  second='$second'"

# Bash can also swap without a temporary, though the intent is less obvious:
#   read -r first second <<< "$second $first"
