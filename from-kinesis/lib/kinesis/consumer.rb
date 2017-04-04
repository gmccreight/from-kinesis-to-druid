require 'multi_json'
require 'base64'

module Kinesis
  class CheckpointError < RuntimeError; end
  class MalformedAction < RuntimeError; end

  class Consumer
    # Sends and receives messages to and from the KCL via this API:
    # https://github.com/awslabs/amazon-kinesis-client/blob/master/src/main/java/com/amazonaws/services/kinesis/multilang/package-info.java

    def initialize(processor)
      $stdin = nil
      #TODO $stdout = syslog
      @processor = processor
    end

    def run
      running = true
      Signal.trap("TERM") { puts "Kinesis consumer: Terminating..."; running = false }
      Signal.trap("INT") { puts "Kinesis consumer: Terminating..."; running = false }

      while running
        action = self.class.read_action
        break unless action
        process_action(action)
      end
      dispatch_to_processor(:shutdown, 'TERMINATE')
    end

    def process_action(action)
      case action['action']
      when 'initialize'
        dispatch_to_processor(:init, action.fetch('shardId'))
      when 'processRecords'
        records = action.fetch('records').map do |r|
          r['data'] = Base64.decode64(r['data'])
          r
        end
        dispatch_to_processor(:process, records)
      when 'shutdown'
        dispatch_to_processor(:shutdown, action.fetch('reason'))
      else
        raise(MalformedAction, "Received an action which couldn't be understood: '#{action}'")
      end
      self.class.write_action('status', 'responseFor' => action['action'])
    rescue KeyError => ke
      raise(MalformedAction, "Action '#{action}': #{ke.message}")
    end

    def dispatch_to_processor(method, arg)
      @processor.send(method, arg)
    rescue => err
      STDERR.write("#{err.class}: #{err.message}\n\t#{err.backtrace.join("\n\t")}\n")
      # TODO rollbar
    end

    def self.read_line
      loop do
        line = STDIN.readline&.strip!
        return line if !line || !line.empty?
      end
    rescue EOFError
      nil
    end

    def self.read_action
      line = read_line
      line ? MultiJson.load(line) : {}
    end

    def self.write_action(action, details = {})
      response = { 'action' => action }.merge(details)
      STDOUT.write("\n#{MultiJson.dump(response)}\n")
      STDOUT.flush
    end

    def self.checkpoint(sequence_number)
      write_action('checkpoint', 'sequenceNumber' => sequence_number)
      action = read_action
      if action['action'] == 'checkpoint'
        raise(CheckpointError, action['error']) if action['error']
      else
        # We are in an invalid state. Client should shut down
        raise(CheckpointError, 'InvalidStateException')
      end
    end
  end
end
