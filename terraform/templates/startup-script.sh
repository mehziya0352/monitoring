#!/bin/bash
sudo apt update -y
sudo apt install -y ansible git curl
cd /opt
git clone https://github.com/mehziya0352/monitoring.git
cd monitoring/ansible
ansible-playbook -i localhost, -c local main.yaml
