#!/bin/bash

cd
mkdir -p foreign_src/
cd foreign_src
sudo apt-get install wget -y
wget -O - http://www.gtlib.gatech.edu/pub/apache/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz | tar -xzf -
cd zookeeper-3.4.6
cp conf/zoo_sample.cfg conf/zoo.cfg
