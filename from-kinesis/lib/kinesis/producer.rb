require 'aws-sdk-core'
require 'multi_json'
module Kinesis
  class Producer
    def initialize(stream_name, partition_key)
      env = ENV['RAILS_ENV'] || 'development'
      config = {}
      config[:endpoint] = 'http://localhost:4567' if env == 'development'
      @stream_name = "#{stream_name}-#{env}"
      @partition_key = partition_key
      @kinesis = Aws::Kinesis::Client.new(config)
    end

    def put_record(data)
      @kinesis.put_record(stream_name: @stream_name,
                          data: MultiJson.dump(data),
                          partition_key: data[@partition_key])
    end

    def stream_description
      r = @kinesis.describe_stream(:stream_name => @stream_name)
      r[:stream_description]
    end

    def wait_for_stream_to_become_active
      sleep_time_seconds = 3
      status = stream_description[:stream_status]
      while status && status != 'ACTIVE' do
        puts "#{@stream_name} has status: #{status}, sleeping for #{sleep_time_seconds} seconds"
        sleep(sleep_time_seconds)
        status = stream_description[:stream_status]
      end
    end

    def create_stream_if_not_exists(shard_count)
      desc = stream_description
      if desc[:stream_status] == 'DELETING'
        raise "Stream #{@stream_name} is being deleted."
      elsif desc[:stream_status] != 'ACTIVE'
        wait_for_stream_to_become_active
      end
      puts "Stream #{@stream_name} already exists with #{desc[:shards].size} shards"
    rescue Aws::Kinesis::Errors::ResourceNotFoundException
      puts "Creating stream #{@stream_name} with #{shard_count} shards"
      @kinesis.create_stream(stream_name: @stream_name,
                             shard_count: shard_count)
      wait_for_stream_to_become_active
    end

    def delete_stream_if_exists
      @kinesis.delete_stream(stream_name: @stream_name)
      puts "Deleted stream #{@stream_name}"
    rescue Aws::Kinesis::Errors::ResourceNotFoundException
      # nothing to do
    end

  end
end
