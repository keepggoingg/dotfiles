#!/bin/bash

if [[ $# -ne 1 ]]; then
  echo "no parameters"
  exit 1
fi

eval "$1"
if [[ $? -ne 0 ]]; then
  echo "wrong command"
  exit 1
fi

echo "$1" >> setup.sh
cp setup.sh setup.sh.backup
