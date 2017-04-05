#!/usr/bin/env ruby

require_relative 'druid_exporter'

url = ''
if ARGV[0] == 'local'
  url = "http://localhost:8200/v1/post/eventer"
elsif ARGV[0] == 'prod'
  url = "http://druid-tranquility.fernet.io:8200/v1/post/eventer"
else
  STDERR.puts "must specify 'local' or 'prod'"
  exit 1
end

shard_id = "shardId-000000000000"

debug_level = 3 # Show absolutely everything

exporter = DruidExporter.new(shard_id, chunk_size: 3, exporter_url: url, debug_level: debug_level)

exporter.add_row(%Q~{":event_name":"foo",":event_date_time_utc":"#{Time.now - 40}",":event_type":":info",":uuid":"ed7ee1ad-aa4d-4cda-af10-a2c00dac60f2"}~)
exporter.add_row(%Q~{":event_name":"foo",":event_date_time_utc":"#{Time.now - 30}",":event_type":":info",":uuid":"b0c6170e-41ea-4169-942b-9e4757570543",":item_id":2}~)
exporter.add_row(%Q~{":event_name":"foo",":event_date_time_utc":"#{Time.now - 20}",":event_type":":info",":uuid":"78c617cc-41ea-4169-942b-9e4757570999",":item_id":4}~)
exporter.add_row(%Q~{":event_name":"foo",":event_date_time_utc":"#{Time.now - 10}",":event_type":":info",":uuid":"55c617cc-41ea-4169-942b-9e4757570999",":item_id":4}~)

exporter.finish
