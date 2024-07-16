#!/bin/bash

until [[ -f /var/lib/cloud/instance/boot-finished ]]; do
  sleep 1
done

sudo apt update -y
ansible-playbook -i ~/ansible/inventory -e "hostname=$1" ~/ansible/caddy/playbook.yml