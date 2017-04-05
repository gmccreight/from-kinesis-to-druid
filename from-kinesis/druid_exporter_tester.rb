#!/usr/bin/env ruby

# You can use this test script to play around with the exporter
# Note: if you get something like:
#
#   result of sending filename var/to-import-into-druid-from-shardId-000000001-1491412589-780577.txt: {"result":{"received":2,"sent":0}}
#
# ...that means that tranquility (the server running on port 8200) got the data
# but did not import it.  One reason that can happen is because the timestamp
# (in the timestamp field) is too far behind for Druid to import it... it seems
# like it's something like 10 minutes (empirically).

require_relative 'druid_exporter'

shard_id = "shardId-000000000000"

debug_level = 3 # Show absolutely everything
local_exporter_url = "http://localhost:8200/v1/post/eventer"

exporter = DruidExporter.new(shard_id, chunk_size: 3, exporter_url: local_exporter_url, debug_level: debug_level)

exporter.add_row(%q~{":event_name":"foo",":event_date_time_utc":"2017-04-05 20:34:53 UTC",":event_type":":info",":uuid":"ed7ee1ad-aa4d-4cda-af10-a2c00dac60f2"}~)
exporter.add_row(%q~{":event_name":"foo",":event_date_time_utc":"2017-04-05 20:35:15 UTC",":event_type":":info",":uuid":"b0c6170e-41ea-4169-942b-9e4757570543",":item_id":2}~)
exporter.add_row(%q~{":event_name":"foo",":event_date_time_utc":"2017-04-05 20:35:17 UTC",":event_type":":info",":uuid":"78c617cc-41ea-4169-942b-9e4757570999",":item_id":4}~)
exporter.add_row(%q~{":event_name":"foo",":event_date_time_utc":"2017-04-05 20:35:17 UTC",":event_type":":info",":uuid":"78c617cc-41ea-4169-942b-9e4757570999",":item_id":4}~)

exporter.finish
