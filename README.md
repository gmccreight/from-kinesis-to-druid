### Description

This service pulls data from a Kinesis stream and sends data to Druid using
the Tranquility server (which it runs locally).

I have broken the project, and this documention, into two sections describing
each of the portions of work that this service does, `from-kinesis` and
`to-druid`.

The service will ultimately be running on Ubuntu 16.04 on production, so I use
Vagrant to closely mimic the production setup.

## from-kinesis

TODO

## to-druid

### Development

Note that there is a `development_do_everything_from_scratch` script that will
completely reset the Vagrant box and re-install the Ubuntu packages needed to
run the scripts listed below.

#### Prerequisites

This service presumes Druid is running somewhere, and that it can access the
Zookeeper instance associated with that running version of Druid.  For
development purposes, you can run Druid (and Zookeeper) on your local Mac using
the instructions referenced in the "On the Host OS" section.

#### On the Host OS

Follow the instructions here
http://druid.io/docs/0.9.2/tutorials/quickstart.html for running Zookeeper and
Druid on your Mac.

#### In the Service (VM for development instructions)

In development this service runs in Vagrant, which very closely mirrors how it
will run on production.

Tranquility Server, which is the streaming data import mechanism that will run
on this service, requires a connection to Zookeeper.  Since Zookeeper will be
running on the host OS, you will need to set up a reverse port forward to allow
the VM to connect to Zookeeper on the host.

    vagrant ssh -- -R 2181:localhost:2181

That will SSH you onto the development VM with the port-forward set up.

First, you will want to run the Tranquility server (note: the conf file is
copied from the druid-0.9.2 conf-quickstart directory, which is available at
the same quickstart link mentioned above.)

    cd /app/to-druid/tranquility-distribution-0.8.0; bin/tranquility server -configFile ../tranquility-server-conf-from-druid-quickstart.json

Then you can import the data, as in the example.

    cd /app/to-druid/; ./generate-example-metrics | curl -XPOST -H'Content-Type: application/json' --data-binary @- http://localhost:8200/v1/post/eventer

You should see a result like: `{"result":{"received":25,"sent":25}}`
