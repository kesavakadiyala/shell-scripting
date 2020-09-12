#!bin/bash

INPUT=$1
USER_ID=$(id -u)

case $USER_ID in
  0)
    echo -e "\e[33mStarting Installation\e[0m"
    ;;
  *)
    echo -e "\e[31mYou should be a root user for running $0 script.\e[0m"
    exit
    ;;
esac

# Functions

Status_Check(){
  case $? in
    0)
      echo -e "\e[32m>> Success\e[0m"
      ;;
    *)
      echo -e "\e[31m>> Failed\e[0m"
      exit 1;
      ;;
  esac
}

Print(){
  echo -e "\e[33m>> $1\e[0m"
}

Setup_Nojejs(){
  Print "Installing Nodejs..."
  yum install nodejs make gcc-c++ -y >> output.log
  Status_Check
  id roboshop
  case $? in
    1)
      Print "Adding Application user..."
      user add roboshop
      Status_Check
      ;;
    *)
  esac
  Print "Downloading $1 Application..."
  curl -s -L -o /tmp/$1.zip "$2"
  Status_Check
  cd /home/roboshop
  mkdir catalogue
  cd catalogue
  Print "Extracting $1 Application..."
  unzip -o /tmp/catalogue.zip >> output.log
  Status_Check
  Print "Installing Nodejs App Dependencies..."
  npm --unsafe-perm install
  Status_Check
  chown roboshop:roboshop /home/roboshop -R
  mv /home/roboshop/catalogue/systemd.service /etc/systemd/system/catalogue.service
  Print "daemon-reloading..."
  systemctl daemon-reload
  Status_Check
  Print "Starting $1 Application..."
  systemctl enable catalogue >> output.log
  systemctl start catalogue
  Status_Check
  Print "Done with $1 Application Installation..."
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
    unzip - o /tmp/frontend.zip >> /root/shell-scripting/output.log
    Status_Check
    mv static/* .
    rm -rf static README.md
    mv localhost.conf /etc/nginx/nginx.conf
    Print "Starting nginx..."
    systemctl enable nginx >> output.log
    systemctl restart nginx
    Status_Check
    Print "Done with Frontend Installation."
    ;;

  mongodb)
    Print "Setting 4u
    p MongoDB Repo..."
    echo '[mongodb-org-4.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/4.2/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.2.asc' >/etc/yum.repos.d/mongodb.repo
    Status_Check
    Print "Installing Mongodb..."
    yum install -y mongodb-org >> output.log
    Status_Check
    sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf
    Status_Check
    Print "Downloading MongoDB Application..."
    curl -s -L -o /tmp/mongodb.zip "https://dev.azure.com/DevOps-Batches/ce99914a-0f7d-4c46-9ccc-e4d025115ea9/_apis/git/repositories/e9218aed-a297-4945-9ddc-94156bd81427/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true"
    Status_Check
    cd /tmp
    Print "Extracting MongoDB Application..."
    unzip -o mongodb.zip >> output.log
    Status_Check
    Print "Starting MongoDB..."
    systemctl enable mongod >> output.log
    systemctl restart mongod
    Status_Check
    Print "Adding Catalogue schema to mongo..."
    mongo < catalogue.js >> output.log
    Status_Check
    Print "Adding User schema to mongo..."
    mongo < users.js >> output.log
    Status_Check
    Print "Done with MongoDB Installation."
    ;;
  catalogue)
    Setup_Nojejs "catalogue" "https://dev.azure.com/DevOps-Batches/ce99914a-0f7d-4c46-9ccc-e4d025115ea9/_apis/git/repositories/558568c8-174a-4076-af6c-51bf129e93bb/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true"
    ;;
  *)
    echo -e "\e[31mPlease mention proper input for $0 script. \nUsage: sh Project.sh frontend|mongodb|catalogue\e[0m"
esac