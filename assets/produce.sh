#!/bin/bash

i=0

while true
do
  topicNum=$((($i%3)+1))
  for ((j = 0 ; j < 3 ; j++)); do
    DATE=$(date -Ins)
    printf "$DATE\n" | /root/.local/bin/rpk topic produce log$topicNum -p $j
    sleep 0.5
  done
  i=$(($i+1))
done