#!bin/bash

INPUT=$1
USER_ID=$(id -u)
DNS_DOMAIN_NAME=kesavakadiyala.tech

case $USER_ID in
  0)
    echo -e "\e[33mStarting $INPUT Installation\e[0m"
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
  id roboshop >> output.log
  case $? in
    1)
      Print "Adding Application user..."
      useradd roboshop
      Status_Check
      ;;
    *)
  esac
  Print "Downloading $1 Application..."
  curl -s -L -o /tmp/$1.zip "$2"
  Status_Check
  Print "Extracting $1 Application..."
  mkdir -p /home/roboshop/$1
  cd /home/roboshop/$1
  unzip -o /tmp/$1.zip >> output.log
  Status_Check
  Print "Installing Nodejs App Dependencies..."
  npm --unsafe-perm install  >> output.log
  Status_Check
  chown roboshop:roboshop /home/roboshop -R
  Print "Setting up $1 services..."
  mv /home/roboshop/catalogue/systemd.service /etc/systemd/system/$1.service
  sed -i -e "s/MONGO_ENDPOINT/mongodb.${DNS_DOMAIN_NAME}/" /etc/systemd/system/$1.service
  Status_Check
  Print "daemon-reloading..."
  systemctl daemon-reload
  Status_Check
  Print "Starting $1 Application..."
  systemctl enable $1 >> output.log
  systemctl start $1
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
    curl -s -L -o /tmp/frontend.zip "https://codeload.github.com/kesavakadiyala/rs-frontend/zip/master?token=AG4AK7AHYJHQ6O7FLCGMN7K7LTGM2"
    Status_Check
    cd /usr/share/nginx/html
    rm -rf *
    Print "Extracting Frontend Application..."
    unzip -o /tmp/frontend.zip >> /root/shell-scripting/output.log
    Status_Check
    mv rs-frontend-master/static/* .
    mv rs-frontend-master/*.conf .
    rm -rf rs-frontend-master/
    Print "Setting up Application configuration..."
    mv localhost.conf /etc/nginx/nginx.conf
    sed -i -e "s/CATALOGUE_ENDPOINT/catalogue.${DNS_DOMAIN_NAME}/" /etc/nginx/nginx.conf
    Status_Check
    Print "Starting nginx..."
    systemctl enable nginx >> output.log
    systemctl restart nginx
    Status_Check
    Print "Done with Frontend Installation."
    ;;

  mongodb)
    Print "Setting up MongoDB Repo..."
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