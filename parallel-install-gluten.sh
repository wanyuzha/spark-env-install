#!/bin/bash

# Check if a number is provided as an argument
if [ "$#" -ne 1 ]; then
 echo "Usage: $0 <number-of-slave-nodes>"
 exit 1
fi

# Number of slave nodes
NUM_SLAVES=$1

for i in $(seq 2 $NUM_SLAVES); do
 node=$(printf "rc%02d" $((i - 1)))
 # avoid the input of yes/no
 ssh-keyscan -H $node >> ~/.ssh/known_hosts
 scp install-gluten.sh $node:~/spark-env-install/
 ssh $node "cd ~/spark-env-install && ./install-gluten.sh $NUM_SLAVES" &
done
