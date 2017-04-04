require_relative 'lib/kinesis/consumer'

require 'tmpdir'
require 'fileutils'
require 'json'

class EventerStreamProcessor
  def init(shard_id)
    @shard_id = shard_id
    @output = open("#{@shard_id}-#{Time.now.to_i}.log", 'w')
  end

  def process(records)
    last_seq = nil
    records.each_slice(10) do |chunk|
      druid_records = []
      chunk.each do |record|
        begin
          @output.puts record['data']
          @output.flush
          druid_records << record['data']
          last_seq = record['sequenceNumber']
        rescue => e
          STDERR.puts "#{e}: Failed to process record '#{record}'"
        end
      end

      filename = "to-import-into-druid-#{@shard_id}-#{Time.now.to_i}.txt"
      foo = open(filename, 'w')

      begin
        druid_records.each do |druid_record|
          begin
            my_hash = JSON.parse(druid_record)
            if my_hash.key?('event_name')
              foo.puts druid_record
              foo.flush
            end
          rescue
          end
        end
        foo.close
      end

    end
    # Kinesis::Consumer.checkpoint(last_seq) if last_seq
  end

  def shutdown(reason)
    @output.close
  end
end
