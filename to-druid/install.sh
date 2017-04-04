#!/bin/bash

if [[ ! -d "druid-0.9.2" ]]; then
  curl -O http://static.druid.io/artifacts/releases/druid-0.9.2-bin.tar.gz
  tar -xzf druid-0.9.2-bin.tar.gz
fi

if [[ ! -d "zookeeper-3.4.6" ]]; then
  curl http://www.gtlib.gatech.edu/pub/apache/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz -o zookeeper-3.4.6.tar.gz
  tar -xzf zookeeper-3.4.6.tar.gz
  cd zookeeper-3.4.6
  cp conf/zoo_sample.cfg conf/zoo.cfg
  cd ..
fi

if [[ ! -d "zookeeper-0.8.0" ]]; then
  curl -O http://static.druid.io/tranquility/releases/tranquility-distribution-0.8.0.tgz
  tar -xzf tranquility-distribution-0.8.0.tgz
fi
