#!/usr/bin/env bash

# Login to super user first
######################
# su -
######################

#Install Git
echo "-- [Git Installation] --"
echo "-- [Git Installation: Start Process] --"

dnf update -y

dnf install git -y

git --version

git config --global user.name "Patbodin CentOS"
git config --global user.email "Patbodin@CentOS"

git config --global --list

echo "-- [Git Installation: End Process] --"

##########################################