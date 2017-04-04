require_relative 'lib/kinesis/consumer'

require 'tmpdir'
require 'fileutils'

class EventerStreamProcessor
  def init(shard_id)
    @output = open("#{shard_id}-#{Time.now.to_i}.log", 'w')
  end

  def process(records)
    last_seq = nil
    records.each do |record|
      begin
        @output.puts record['data']
        @output.flush
        last_seq = record['sequenceNumber']
      rescue => e
        STDERR.puts "#{e}: Failed to process record '#{record}'"
      end
    end
    Kinesis::Consumer.checkpoint(last_seq) if last_seq
  end

  def shutdown(reason)
    @output.close
  end
end
