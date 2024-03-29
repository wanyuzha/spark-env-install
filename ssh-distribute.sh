#!/bin/bash


# Must be run as root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root." 1>&2
  exit 1
fi


# Check if a number is provided as an argument
if [ "$#" -ne 1 ]; then
 echo "Usage: $0 <number-of-slave-nodes>"
 exit 1
fi


# Define the user's home directory
USER_HOME_DIR="/users/Wanyu"
USER_NAME="Wanyu"


# we use relative path here, point at /users/XXX/.ssh/id_rsa.pub
if [[ -f $USER_HOME_DIR/.ssh/id_rsa.pub ]]; then
   echo "The file $USER_HOME_DIR/.ssh/id_rsa.pub exists."
else
   echo "The file $USER_HOME_DIR/.ssh/id_rsa.pub does not exist."
   exit 1
fi


# Number of slave nodes
NUM_SLAVES=$1

chown $USER_NAME /mydata
cat $USER_HOME_DIR/.ssh/id_rsa.pub >> $USER_HOME_DIR/.ssh/authorized_keys

for i in $(seq 2 $NUM_SLAVES); do
 node=$(printf "rc%02d" $((i - 1)))
 # avoid the input of yes/no
 ssh-keyscan -H $node >> ~/.ssh/known_hosts
 scp $USER_HOME_DIR/.ssh/id_rsa.pub $node:$USER_HOME_DIR/.ssh/id_rsa.pub
 echo "Logging into $node"
 ssh -o StrictHostKeyChecking=no $node "cat $USER_HOME_DIR/.ssh/id_rsa.pub >> $USER_HOME_DIR/.ssh/authorized_keys && rm $USER_HOME_DIR/.ssh/id_rsa.pub && chown $USER_NAME /mydata"
 if [ $? -ne 0 ]; then
    echo "Error: Command failed."
    exit 1  
 fi
done
