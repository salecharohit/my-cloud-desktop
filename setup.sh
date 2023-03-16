#!/bin/bash

until [[ -f /var/lib/cloud/instance/boot-finished ]]; do
  sleep 1
done

sudo apt-add-repository ppa:ansible/ansible -y
sudo apt update -y
sudo apt install wget git jq apt-transport-https ca-certificates curl software-properties-common ansible -y
mv /tmp/ansible ~/ansible
ansible-galaxy install -r ~/ansible/roles.yaml
ansible-playbook -i ~/ansible/inventory -e "password=$1" ~/ansible/playbook.yml