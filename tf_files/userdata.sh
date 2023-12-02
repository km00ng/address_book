#!/bin/bash -ex
# Updated to use Amazon Linux 2
yum -y update
yum -y install httpd php mysql php-mysql
amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
yum install -y httpd mariadb-server
/usr/bin/systemctl enable httpd
/usr/bin/systemctl start httpd
cd /var/www/html
wget https://aws-largeobjects.s3.ap-northeast-2.amazonaws.com/AWS-AcademyACF/lab7-app-php7.zip
wget https://aws-largeobjects.s3.ap-northeast-2.amazonaws.com/AWS-AcademyACF/lab7-app-php7.zip
unzip lab7-app-php7.zip -d /var/www/html/
chown apache:root /var/www/html/rds.conf.php