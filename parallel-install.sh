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
 ssh $node "cd ~ && [ -d "spark-env-install/" ] && rm -r "spark-env-install/" "
 ssh $node "cd ~ && git clone https://github.com/wanyuzha/spark-env-install.git && cd spark-env-install && ./install-local.sh $NUM_SLAVES" &
done
