#!/bin/bash
if [[ ! -d "local-dynamo" ]]; then
    mkdir local-dynamo
    cd local-dynamo
    wget https://s3-us-west-2.amazonaws.com/dynamodb-local/dynamodb_local_latest.tar.gz
    tar xzf dynamodb_local_latest.tar.gz
    cd ..
fi

hash kinesalite 2>/dev/null ||  npm install -g kinesalite

java -Djava.library.path=./local-dynamo/DynamoDBLocal_lib -jar ./local-dynamo/DynamoDBLocal.jar -sharedDb &

trap 'kill -- -$$' EXIT SIGINT SIGTERM SIGHUP

kinesalite
