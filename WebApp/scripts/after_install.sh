#!/bin/bash
EC2_INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
EC2_AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
Deployment_Time=$(date)
sed -i "s/Replace_EC2_ID/$EC2_INSTANCE_ID/g" /var/www/html/index.html
sed -i "s/Replace_AZ/$EC2_AZ/g" /var/www/html/index.html
sed -i "s/Replace_Time/$Deployment_Time/g" /var/www/html/index.html
chmod 664 /var/www/html/index.html
