#!/bin/bash

# If you name to data is called a variable
# If you name to commands is called as a function.


## declaring function

function abc() {
  ## Commands
  echo Hello from abc
  a=10
  local b=20
}

xyz() {
  echo Hello from xyz
}


## Main Program
abc  ##Calling Function
xyz  ##Calling Function


# you can declare variables in main program , you can access then in function and vice-versa
# you override variable of main program in function and vice-versa

# You can declare local variables in function using local command
# local a=10, this variable scope is only inside function