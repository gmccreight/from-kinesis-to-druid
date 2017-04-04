#!/bin/bash

if [[ ! -d "tranquility-distribution-0.8.0" ]]; then
  curl -O http://static.druid.io/tranquility/releases/tranquility-distribution-0.8.0.tgz
  tar -xzf tranquility-distribution-0.8.0.tgz
fi
