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

Create_AppUser(){
  id roboshop >> output.log
  if [ $? -ne 0 ]; then
      Print "Adding Application user..."
      useradd roboshop
      Status_Check
  fi
}

Setup_Nojejs(){
  Print "Installing Nodejs..."
  yum install nodejs make gcc-c++ -y >> output.log
  Status_Check
  Create_AppUser
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
  mv /home/roboshop/$1/systemd.service /etc/systemd/system/$1.service
  sed -i -e "s/MONGO_ENDPOINT/mongodb.${DNS_DOMAIN_NAME}/" /etc/systemd/system/$1.service
  sed -i -e "s/REDIS_ENDPOINT/redis.${DNS_DOMAIN_NAME}/" /etc/systemd/system/$1.service
  sed -i -e "s/CATALOGUE_ENDPOINT/catalogue.${DNS_DOMAIN_NAME}/" /etc/systemd/system/$1.service
  Status_Check
  Print "daemon-reloading..."
  systemctl daemon-reload
  Status_Check
  Print "Starting $1 Application..."
  systemctl enable $1
  systemctl start $1
  Status_Check
  Print "Done with $1 Application Installation..."
}

# Main Program
## Check whether it is a Linux Box
UNAME=$(uname)
if [ "${UNAME}" != "Linux" ]; then
  echo -e "\e[31mUnsupported OS!!\e[0m"
  exit 10
fi

OS=$(cat /etc/os-release  | grep -w ID= |awk -F = '{print $2}'|xargs)
VERSION=$(cat /etc/os-release  | grep -w VERSION_ID | awk -F = '{print $2}' |xargs)

if [ "$OS" == "centos" -a $VERSION -eq 7 ]; then
  echo -e "\e[32mOS Checks - PASSED\e[0m"
else
  echo -e "\e[31mOS Checks - FAILED\e[0m"
  echo -e "\e[31mUnsupported OS!!!\e[0m"
  echo -e "\e[33mSupports only CentOS 7\e[0m"
  exit 10
fi

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
    unzip -o /tmp/frontend.zip >> /root/shell-scripting/output.log
    Status_Check
    mv static/* .
    rm -rf static README.md
    Print "Setting up Application configuration..."
    mv template.conf /etc/nginx/nginx.conf
    export CATALOGUE=catalogue.${DNS_DOMAIN_NAME}
    export CART=cart.${DNS_DOMAIN_NAME}
    export USER=user.${DNS_DOMAIN_NAME}
    export SHIPPING=shipping.${DNS_DOMAIN_NAME}
    export PAYMENT=payment.${DNS_DOMAIN_NAME}

    if [ -e /etc/nginx/nginx.conf ]; then
      sed -i -e "s/CATALOGUE/${CATALOGUE}/" -e "s/CART/${CART}/" -e "s/USER/${USER}/" -e "s/SHIPPING/${SHIPPING}/" -e "s/PAYMENT/${PAYMENT}/" /etc/nginx/nginx.conf
    fi
    Status_Check
    Print "Starting nginx..."
    systemctl enable nginx
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
    Print "Updating Configuration..."
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
    Print "Done with $1 Installation."
  ;;

  catalogue)
    Setup_Nojejs "catalogue" "https://dev.azure.com/DevOps-Batches/ce99914a-0f7d-4c46-9ccc-e4d025115ea9/_apis/git/repositories/558568c8-174a-4076-af6c-51bf129e93bb/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true"
  ;;

  user)
    Setup_Nojejs "user" "https://dev.azure.com/DevOps-Batches/ce99914a-0f7d-4c46-9ccc-e4d025115ea9/_apis/git/repositories/e911c2cd-340f-4dc6-a688-5368e654397c/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true"
  ;;

  redis)
    Print "Installing Redis..."
    yum install epel-release yum-utils -y >> output.log
    Status_Check
    yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y >> output.log
    Status_Check
    yum-config-manager --enable remi >> output.log
    Status_Check
    yum install redis -y >> output.log
    Status_Check
    Print "Updating Configuration..."
    if [ -e /etc/redis.conf ]; then
      sed -i -e '/^bind 127.0.0.1/ c bind 0.0.0.0' /etc/redis.conf
    fi
    Print "Starting Redis Server..."
    systemctl enable redis
    systemctl start redis
    Status_Check
  ;;

  cart)
    Setup_Nojejs "cart" "https://dev.azure.com/DevOps-Batches/ce99914a-0f7d-4c46-9ccc-e4d025115ea9/_apis/git/repositories/ac4e5cc0-c297-4230-956c-ba8ebb00ce2d/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true"
  ;;

  mysql)
    yum list installed | grep mysql-community-server
    if [ $? -ne 0 ]; then
      Print "Downloading mysql..."
      curl -L -o /tmp/mysql-5.7.28-1.el7.x86_64.rpm-bundle.tar https://downloads.mysql.com/archives/get/p/23/file/mysql-5.7.28-1.el7.x86_64.rpm-bundle.tar
      Status_Check
      cd /tmp
      Print "Extracting mysql..."
      tar -xf mysql-5.7.28-1.el7.x86_64.rpm-bundle.tar >> output.log
      Status_Check
      Print "Removing Mariadb..."
      yum remove mariadb-libs -y >> output.log
      Status_Check
      Print "Installing mysql..."
      yum install mysql-community-client-5.7.28-1.el7.x86_64.rpm \
                mysql-community-common-5.7.28-1.el7.x86_64.rpm \
                mysql-community-libs-5.7.28-1.el7.x86_64.rpm \
                mysql-community-server-5.7.28-1.el7.x86_64.rpm -y >> output.log
      Status_Check
    fi
    Print "Starting mysql..."
    systemctl enable mysqld
    systemctl start mysqld
    Status_Check
    Print "Default root password is:"
    echo 'show databases;' | mysql -uroot -ppassword
    if [ $? -ne 0 ]; then
      echo -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'Password@1';\nuninstall plugin validate_password;\nALTER USER 'root'@'localhost' IDENTIFIED BY 'password';" >/tmp/reset-password.sql
      ROOT_PASSWORD=$(grep 'A temporary password' /var/log/mysqld.log | awk '{print $NF}')
      Print "Reset MySQL Password"
      mysql -uroot -p"${ROOT_PASSWORD}" < /tmp/reset-password.sql
      Status_Check
    fi
    Print "Downloading Schema..."
    curl -s -L -o /tmp/mysql.zip "https://dev.azure.com/DevOps-Batches/ce99914a-0f7d-4c46-9ccc-e4d025115ea9/_apis/git/repositories/af9ec0c1-9056-4c0e-8ea3-76a83aa36324/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true"
    Status_Check
    Print "Extracting Schema..."
    cd /tmp
    unzip -o mysql.zip
    Status_Check
    Print "Loading Schema..."
    mysql -u root -ppassword <shipping.sql
    Status_Check
    Print "Done with $1 Installation."
  ;;

  shipping)
    Print "Installing maven..."
    yum install maven -y >> output.log
    Status_Check
    Create_AppUser
    mkdir -p /home/roboshop/$1
    cd /home/roboshop/$1
    Print "Downloading Shipping Application..."
    curl -s -L -o /tmp/shipping.zip "https://dev.azure.com/DevOps-Batches/ce99914a-0f7d-4c46-9ccc-e4d025115ea9/_apis/git/repositories/e13afea5-9e0d-4698-b2f9-ed853c78ccc7/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true"
    Status_Check
    Print "Extracting shipping Application..."
    unzip -o /tmp/shipping.zip >> output.log
    Status_Check
    Print "Building Application..."
    mvn clean package >> output.log
    Status_Check
    Print "Moving Jar to Project location..."
    mv target/*dependencies.jar shipping.jar
    Status_Check
    chmod roboshop:roboshop /home/roboshop/ -R
    Print "Setting up Application configuration..."
    cp /home/roboshop/shipping/systemd.service /etc/systemd/system/shipping.service
    sed -i -e "s/CARTENDPOINT/cart.${DNS_DOMAIN_NAME}/" /etc/systemd/system/shipping.service
    sed -i -e "s/DBHOST/mysql.${DNS_DOMAIN_NAME}/" /etc/systemd/system/shipping.service
    Status_Check
    Print "Starting $1 Application..."
    systemctl daemon-reload
    systemctl start shipping
    systemctl enable shipping
    Print "Done with $1 Installation."
  ;;

  rabbitmq)
    Print "Installing Erlang dependency for rabbitmq..."
    yum install https://packages.erlang-solutions.com/erlang/rpm/centos/7/x86_64/esl-erlang_22.2.1-1~centos~7_amd64.rpm -y >> output.log
    Status_Check
    Print "Setting up repository for rabbitmq..."
    curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash
    Status_Check
    Print "Installing $1..."
    yum install rabbitmq-server -y >> output.log
    Status_Check
    Print "Starting $1 server..."
    systemctl enable rabbitmq-server
    systemctl start rabbitmq-server
    Status_Check
    Print "Creating Application user..."
    rabbitmqctl add_user roboshop roboshop123
    Status_Check
    Print "Setting up permissions for application user..."
    rabbitmqctl set_user_tags roboshop administrator
    rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
    Status_Check
    Print "Done with $1 Installation."
  ;;

  payment)
    Print "Installing python3..."
    yum install python36 gcc python3-devel -y >> output.log
    Status_Check
    Create_AppUser
    mkdir -p /home/roboshop/$1
    cd /home/roboshop/$1
    Print "Downloading $1 Application..."
    curl -L -s -o /tmp/payment.zip "https://dev.azure.com/DevOps-Batches/ce99914a-0f7d-4c46-9ccc-e4d025115ea9/_apis/git/repositories/02fde8af-1af6-44f3-8bc7-a47c74e95311/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true"
    Status_Check
    Print "Extracting $1 Application..."
    unzip /tmp/payment.zip >> output.log
    Status_Check
    chmod roboshop:roboshop /home/roboshop/ -R
    Print "Installing dependencies..."
    pip3 install -r requirements.txt >> output.log
    Status_Check
    Print "Setting up Application configuration..."
    mv /home/roboshop/payment/systemd.service /etc/systemd/system/payment.service
    sed -i -e "s/CARTHOST/cart.${DNS_DOMAIN_NAME}/" -e "s/USERHOST/user.${DNS_DOMAIN_NAME}/" -e "s/AMQPHOST/rabbitmq.${DNS_DOMAIN_NAME}/" /etc/systemd/system/payment.service
    Status_Check
    Print "Starting $1 Application..."
    systemctl daemon-reload
    systemctl enable payment
    systemctl start payment
    Status_Check
    Print "Done with $1 Installation."
  ;;

  *)
    echo -e "\e[31mPlease mention proper input for $0 script. \nUsage: sh Project.sh frontend|mongodb|catalogue\e[0m"
  ;;
esac