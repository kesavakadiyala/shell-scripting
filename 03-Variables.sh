#!/bin/bash

# syntax: VARNAME=DATA
a=10    # Number
b=xyz   # Characters
c=true  # Boolean
d=0.0.1 # Float

## How to access that
# $VARNAME or ${VARNAME}
echo $a

#Array Initialization
ARRAY=(1 2 abc 20 0.0.1)
#Array Accessing
echo INDEX0 = ${ARRAY[0]}

declare -A MYMAP=( [course]=Shell Scripting [time]=0730 [zone]=IST )
echo "Welcome to ${MYMAP[course]}, Timing is ${MYMAP[time]} ${MYMAP[zone]}"