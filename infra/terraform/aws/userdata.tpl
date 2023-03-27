#!/bin/bash

# update deps
sudo apt update -y &&

# install python deps
sudo apt install python3-pip python3-dev build-essential libssl-dev libffi-dev python3-setuptools &&

# create virtual env and activate environment
sudo apt install python3-venv &&
cd /home/ubuntu/www &&
python3 -m venv env &&
source env/bin/activate &&
pip install wheel && 
pip install gunicorn && 
pip install -r requirements.txt &&

# echo "Hello Nginx Demo" > /home/ubuntu/www/html/index.html
