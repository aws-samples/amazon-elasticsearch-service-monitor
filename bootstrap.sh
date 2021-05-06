#!/bin/bash

# create the virtual environment
python3 -m venv .env
# download requirements
.env/bin/python -m pip install -r requirements.txt

# Load dependency for lambda functions
.env/bin/python -m pip install --target monitoring-py/ -r monitoring-py/requirements.txt 

# create the key pair
region_default="us-west-2"
echo -e
read -p "Please enter your region to bootstrap the env [$region_default]: " region
region="${region:-$region_default}"

aws ec2 create-key-pair --key-name aes_cdk_monitoring --query 'KeyMaterial' --output text > aes_cdk_monitoring.pem --region $region
# update key_pair permissions
chmod 400 aes_cdk_monitoring.pem
# move key_pair to .ssh
mv -f aes_cdk_monitoring.pem $HOME/.ssh/aes_cdk_monitoring.pem
# start the ssh agent
eval `ssh-agent -s`
# add your key to keychain
ssh-add -k ~/.ssh/aes_cdk_monitoring.pem 

# Add e-mail for the notification
email_default="user@example.com"
echo -e
read -p "Please enter an e-mail for alert [$email_default]: " email
email="${email:-$email_default}"
sed -i -e 's/user@example.com/'$email'/g' monitoring_cdk/monitoring_cdk_stack.py

