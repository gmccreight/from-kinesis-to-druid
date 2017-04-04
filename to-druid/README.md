## To Druid

How do we get the data into Druid?

### Tranquility

Tranquility Server lets you use Tranquility to send data to Druid without developing a JVM app.

We may eventually want to have a JVM app, but for now, as a proof of concept we simply want to
get events from Kinesis by any means necessary and load them into Druid by any means necessary.

The tranquility server takes API requests and loads data into Druid

https://imply.io/docs/latest/ingestion-tranquility

### Web interface

You can see the web interface at

http://127.0.0.1:8090/console.html
