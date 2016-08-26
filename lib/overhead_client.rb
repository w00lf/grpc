require 'grpc'
require 'overhead'
require 'overhead_services_pb'
require 'benchmark'
require 'slop'
require 'log'
require 'byebug'
require 'method_profiler'
# require 'grpc_logging'

OPTS = Slop.parse do |o|
  o.integer '-n', '--number', 'Max size of object`s array to test', default: 1
  o.integer '-i', '--iterations', 'Number of iterations', default: 100
  o.string '-s', '--suffix', 'Suffix to event logging', default: ''
  o.string '-t', '--type', 'Type of testing', default: 'rest'
  o.bool '-rm', '--remove', 'Recreate indexes', default: false
end.freeze

Log.gateway.client.indices.delete index: Log.index_name if OPTS.remove?

def objects_stable_connection_test(n, iters, suffix = '')
  overhead_host = ENV['OVERHEAD_GRPC'] || 'localhost:50051'
  kind = "topics_request#{suffix}"
  p "Starting test #{kind}"
  stub = Overhead::Collection::Stub.new(overhead_host, :this_channel_is_insecure)
  n.times do |i|
    size = (i + 1)
    p "Starting iteration for size: #{size}"
    iters.times do |j|
      message = nil
      measure = Benchmark.measure { message = stub.get_topics(::Overhead::SizeRequest.new(size: size)) }
      begin
        p "Time spend: #{message.time_spend}"
        p "Real time: #{(measure.real * 1000)}"
        Log.create(created_at: Time.now.utc.iso8601, message_size: message.response_bytes, time_spend: ((measure.real * 1000) - message.time_spend).to_i, kind: kind)
      rescue
        p e
        retry
      end
    end
  end
end

def rest_objects_satble_connection_test(n, iters, suffix = '')
  kind = "rest_topics_request#{suffix}"
  p "Starting test #{kind}"
  n.times do |i|
    size = (i + 1)
    p "Starting iteration for size: #{size}"
    iters.times do |j|
      message = nil
      measure = Benchmark.measure do
	      response = JSON.load(Net::HTTP.get(URI("http://web:50051/topics?size=#{size}&fo#{rand(1..10000)}=#{rand(1..10000)}")))
        topics = response['topics'].map do |topic|
          widget_attr = topic.delete('widgets')
          ::Overhead::Topic.new(symb_keys(topic).merge(widgets: widget_attr.map {|n| ::Overhead::Widget.new(symb_keys(n)) }))
        end
        message = ::Overhead::TopicsResponse.new(time_spend: response['time_spend'], topics: topics, response_bytes: response['response_bytes'])
      end
      begin
        Log.create(created_at: Time.now.utc.iso8601, message_size: message.response_bytes, time_spend: ((measure.real * 1000) - message.time_spend).to_i, kind: kind)
      rescue => e
        p e
        retry
      end
    end
  end
end

def symb_keys(hash)
  hash.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
end

def main
  case OPTS[:type]
  when 'rest'
    rest_objects_satble_connection_test(OPTS[:number], OPTS[:iterations], OPTS[:suffix])
  when 'grpc'
    objects_stable_connection_test(OPTS[:number], OPTS[:iterations], OPTS[:suffix])
  end
end
# $profilers = GRPC.constants.map {|n| klass = (eval("GRPC::#{n}") rescue nil); MethodProfiler.observe(klass) if klass && klass.is_a?(Class) }.compact
main

