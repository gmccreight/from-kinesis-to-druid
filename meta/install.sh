#!/bin/bash

sudo apt-get install default-jre -y
sudo apt-get install python -y

(
  cd to-druid
  ./install.sh
)
