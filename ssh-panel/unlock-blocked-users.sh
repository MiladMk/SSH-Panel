#!/bin/bash

users=$(<lock-list.txt)

for i in $users
do
  echo passwd -u $i
done