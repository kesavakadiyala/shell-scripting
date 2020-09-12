#!bin/bash

USER_ID=$(id -u)

case $USER_ID in
  0)
    echo "Starting Installation"
    ;;
  *)
    echo "You should be a root user for running $0 script."
    exit
    ;;
esac

