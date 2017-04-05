require_relative 'lib/kinesis/consumer'
require_relative 'druid_exporter'

require 'tmpdir'
require 'fileutils'
require 'json'
require 'time'

class EventerStreamProcessor
  def init(shard_id)
    @shard_id = shard_id
    @output = open("var/#{@shard_id}-#{Time.now.to_i}.log", 'w')
  end

  def process(records)

    last_seq = nil

    # TODO: make environmental variables
    production_tranquility_url = "http://druid-tranquility.carrot.onl:8200/v1/post/eventer"
    _local_tranquility_url = "http://localhost:8200/v1/post/eventer"

    druid_exporter = DruidExporter.new(@shard_id, chunk_size: 20, exporter_url: production_tranquility_url, debug_level: 3)

    records.each do |record|
      begin
        @output.puts record['data']
        @output.flush
        druid_exporter.add_row(record['data'])
        last_seq = record['sequenceNumber']
      rescue => e
        STDERR.puts "#{e}: Failed to process record '#{record}'"
      end
    end

    druid_exporter.finish

    # Kinesis::Consumer.checkpoint(last_seq) if last_seq
  end

  def shutdown(reason)
    @output.close
  end
end
