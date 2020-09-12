#!bin/bash

INPUT=$1
USER_ID=$(id -u)

case $USER_ID in
  0)
    echo "\e[33Starting Installation\e[0m"
    ;;
  *)
    echo "\e[31mYou should be a root user for running $0 script.\e[0m"
    exit
    ;;
esac

# Functions

Status_Check(){
  case $? in
    0)
      echo "\e[32m>> Success\e[0m"
      ;;
    *)
      echo "\e[31m>> Failed\e[0m"
      exit 1;
      ;;
  esac
}

Print(){
  echo "\e[33m>> $1\e[0m"
}

# Main Program

case $INPUT in
  frontend)
    Print "Installing Nginx..."
    yum install nginx -y >> /root/shell-scripting/output.log
    Status_Check
    Print "Downloading Frontend Application..."
    curl -s -L -o /tmp/frontend.zip "https://dev.azure.com/DevOps-Batches/ce99914a-0f7d-4c46-9ccc-e4d025115ea9/_apis/git/repositories/db389ddc-b576-4fd9-be14-b373d943d6ee/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true"
    Status_Check
    cd /usr/share/nginx/html
    rm -rf *
    Print "Extracting Frontend Application..."
    unzip /tmp/frontend.zip >> /root/shell-scripting/output.log
    Status_Check
    mv static/* .
    rm -rf static README.md
    mv localhost.conf /etc/nginx/nginx.conf
    Print "Starting nginx..."
    systemctl enable nginx
    systemctl restart nginx
    Status_Check
    ;;
  *)
    echo "\e[31mPlease mention proper input for $0 script. \nUsage: sh Project.sh frontend|mongodb|catalogue\e[0m"
esac