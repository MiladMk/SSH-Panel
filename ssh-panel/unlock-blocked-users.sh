#!/bin/bash

users=$(<lock-list.txt)

for i in $users
do
  passwd -u $i
  date=`date +"%Y-%m-%d %X"`;
  echo "Unblock User $i - $date ";
  echo "Unblock User $i - $date " >> /root/log-lock-limit.txt;
done
> lock-list.txt
