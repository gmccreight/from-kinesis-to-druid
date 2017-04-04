#! /usr/bin/env ruby

require_relative 'lib/kinesis/producer'

def run(producer)
  producer.create_stream_if_not_exists(2)
  loop do
    r = producer.put_record(get_data)
    puts "Put record to shard '#{r[:shard_id]}' (#{r[:sequence_number]})"
    sleep 0.25
  end
end

def get_data
  {
    "time"=>"#{Time.now.to_f}",
    "sensor"=>"snsr-#{rand(1_000).to_s.rjust(4,'0')}",
    "reading"=>"#{rand(1_000_000)}"
  }
end

producer = Kinesis::Producer.new('kclrbsample', 'sensor')
run(producer)
