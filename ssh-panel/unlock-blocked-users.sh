#!/bin/bash

users=$(<lock-list.txt)

for i in $users
do
  passwd -u $i
done
