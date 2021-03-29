#!/usr/bin/bash
sudo apt-get update
sudo apt-get install -y python3-pip
pip3 install flask
sudo apt-get install -y awscli
mkdir /home/app
cd /home/app
aws s3 cp s3://app-helloworld/app.py .
python app.py


