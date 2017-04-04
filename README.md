### Prerequisites

This service presumes Druid is running somewhere, and that it can access the
Zookeeper instance associated with that running version of Druid.

### On the Host OS

Follow the instructions here http://druid.io/docs/0.9.2/tutorials/quickstart.html for running Zookeeper and Druid on your Mac.

### In the Service (VM for development instructions)

In development this service runs in Vagrant, which very closely mirrors how it
will run on production.

Tranquility Server, which is the streaming data import mechanism that will run
on this service, requires a connection to Zookeeper.  Since Zookeeper will be
running on the host OS, you will need to set up a reverse port forward to allow
the VM to connect to Zookeeper on the host.

    vagrant ssh -- -R 2181:localhost:2181

That will SSH you onto the development VM with the port-forward set up.

First, you will want to run the Tranquility server (note: the conf file is copied from the druid-0.9.2 conf-quickstart directory


    cd /app/to-druid/tranquility-distribution-0.8.0; bin/tranquility server -configFile ../tranquility-server-conf-from-druid-quickstart.json

Then you can import the data, as in the example.

    cd /app/to-druid/; ./generate-example-metrics | curl -XPOST -H'Content-Type: application/json' --data-binary @- http://localhost:8200/v1/post/metrics

### In the Service (production)


