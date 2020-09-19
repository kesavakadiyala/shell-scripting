#!/bin/bash

# In shell scripting we dont bother much on command outputs, But we look for exit status of the commands which is executed to determine whether that is successful or failure.

# Exit status is a number , it ranges from 0-255

# 0 - Successful
# 1-255 - Non Successful / Semi Successful / Semi failure

# exit 0-255

# But system uses the numbers from 126+
# So for user we use 1-125 values for exit status.