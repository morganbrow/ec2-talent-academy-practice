#!/bin/bash

yum update
amazon-linux-extras install nginx1
service nginx start
systemctl enable nginx.service

#install Python
pip3 install boto3
