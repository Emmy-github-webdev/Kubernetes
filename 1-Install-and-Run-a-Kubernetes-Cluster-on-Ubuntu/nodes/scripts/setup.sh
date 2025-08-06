#!/bin/bash

# Set hostname
hostnamectl set-hostname ${hostname}

# Update /etc/hosts to reflect the new hostname
echo "127.0.1.1 ${hostname}" >> /etc/hosts

# Disable the swap
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
