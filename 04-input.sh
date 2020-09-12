#!/bin/bash

# 1. While executing

read -p 'Enter your Name: ' name

echo "Hello $name, Welcome!!"

# 2. Before executing

## Some Variables can help you in talking the input which are provided as arguments before executing.
# Variables for this are $0-$n , $* , $@ , $#

echo Script Name = $0
echo First Argument = $1
echo Second Argument = $2
echo All Arguments = $*
echo All Arguments = $@
echo Number of Arguments = $#