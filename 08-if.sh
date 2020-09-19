#!/bin/bash

## If expression is true then we need to do some thing
# if [ expression ]; then
#    commands
# fi


# if expression is true then some commands if not then some commands
# if [ expression ] ; then
#    commands
# else
#    commands
# fi

# Multi expressions
# if [ expression1 ]; then
#     commands1
# elif [ expression2 ]; then
#     commands2
# else
#     commands
# fi

## Logical And , Means two expressions and both should be true , then the associated commands will execute
# if [ expression1 -a expression2 ] ; then
#       commands
# fi

## Logical OR, Means two expressions and any one can be tru then associated commands will be executed.
# if [ expression1 -o expression2 ] ; then
#       commands
# fi

### Expressions
# 1. String comparisions , == , !=
# [ abc == abc ] , [  ABC != 1234 ]

# 2. Numerical operators
# -eq , -ne , -lt , -le ,-ge, -gt
# [ 1 -eq 2 ]

# 3. File tests
#

a=$1

if [ $a -gt 10 ]; then
  echo a is greater than 10
else
  echo a is less than or equal to 10
fi