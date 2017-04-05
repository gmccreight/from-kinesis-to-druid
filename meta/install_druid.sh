#!/bin/bash

cd
mkdir -p foreign_src/
cd foreign_src
sudo apt-get install wget -y
wget -O - http://static.druid.io/artifacts/releases/druid-0.9.2-bin.tar.gz | tar -xzf -
