require 'json'
require 'time'

class DruidExporter

  def initialize(shard_id, chunk_size:, exporter_url:, debug_level:)
    @shard_id = shard_id
    @debug_level = debug_level
    @exporter_url = exporter_url
    @chunk_size = chunk_size
    reset_data
  end

  def add_row(text)
    normalized_text_or_nil = normalize_text_or_nil(text)
    if !normalized_text_or_nil.nil?
      debug(3, "adding normalized line: #{normalized_text_or_nil}")
      @data << normalized_text_or_nil
    end
    maybe_process_chunk()
  end

  def finish
    debug(2, "finish called")
    process_chunk
  end

  private

    def debug(message_level, message)
      if @debug_level >= message_level
        puts message
      end
    end

    # We get some crazy stuff in the stream.
    def normalize_text_or_nil(text)
      result = nil
      begin
        my_hash = JSON.parse(text)
        new_hash = {}
        # remove the ":foo" colon at the beginning of the events
        my_hash.each do |k, v|
          new_hash[k.sub(/^:/, '')] = v
        end
        if new_hash.key?('event_name')
          new_hash['timestamp'] = Time.parse(new_hash['event_date_time_utc']).iso8601
          result = JSON.generate(new_hash)
        end
      rescue
      end
      result
    end

    def maybe_process_chunk
      if @data.size >= @chunk_size
        debug(2, "processing chunk because data size #{@chunk_size} reached")
        process_chunk
      end
    end
  
    def process_chunk
      debug(2, "processing chunk which is #{@data.size} size")
      if @data.size > 0
        filename = write_data_to_file
        send_data_to_tranquility_server(filename)
      else
        debug(2, "the chunk had zero size... did not actually process the chunk")
      end
      reset_data
    end

    def reset_data
      @data = []
    end

    def write_data_to_file
      filename = "var/to-import-into-druid-from-#{@shard_id}-#{Time.now.to_f.to_s.sub(/\./, '-')}.txt"
      File.write(filename, @data.join("\n"))
      filename
    end

    # This could eventually become a direct call as opposed to sending a file
    def send_data_to_tranquility_server(filename)
      debug(1, "sending filename #{filename}")
      if @exporter_url
        result = `cat #{filename} | curl -s -XPOST -H'Content-Type: application/json' --data-binary @- #{@exporter_url}`
      else
        result = "no @exporter_url specified... could not send"
      end
      debug(1, "result of sending filename #{filename}: #{result}")
    end

end
