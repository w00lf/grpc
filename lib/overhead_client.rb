require 'grpc'
require 'overhead'
require 'overhead_services_pb'
require 'benchmark'
require 'elasticsearch/persistence/model'
require 'slop'

OPTS = Slop.parse do |o|
  o.integer '-n', '--number', 'Number of iterations', default: 1
  o.bool '-rm', '--remove', 'Recreate indexes', default: false
end.freeze

class Log
  include Elasticsearch::Persistence::Model

  attribute :created_at, Date, type: 'date'
  attribute :kind, String, type: 'string', mapping: { index: 'not_analyzed' }
  attribute :message_size, Integer, default: 0, mapping: { type: 'integer' }
  attribute :time_spend, Integer, default: 0, mapping: { type: 'integer' }
end
Log.gateway.client = Elasticsearch::Client.new url: ENV['ELASTICSEARCH_URL'], log: false
Log.gateway.client.indices.delete index: Log.index_name if OPTS.remove?
p ENV['ELASTICSEARCH_URL']

def stable_connection_test(n, suffix = '')
  kind = "stable_connection#{suffix}"
  stub = Overhead::Collection::Stub.new('localhost:50051', :this_channel_is_insecure)
  n.times do |i|
    perform_interations(stub: stub, i: i, kind: kind)
  end
end

def recreate_connection_test(n, suffix = '')
  kind = "recreate_connection#{suffix}"
  n.times do |i|
    size = (i + 1) ** 2
    p "Starting iteration for size: #{size}"
    100.times do |j|
      stub = Overhead::Collection::Stub.new('localhost:50051', :this_channel_is_insecure)
      measure = Benchmark.measure { stub.get_feature(::Overhead::SizeRequest.new(size: size)) }
      begin
        Log.create(created_at: Time.now.utc.iso8601, message_size: size, time_spend: (measure.real * 1000).to_i, kind: kind)
      rescue
        p 'Cnnot connect to elastic'
        retry
      end
      stub = nil
    end
  end
end

def objects_stable_connection_test(n, suffix = '')
  kind = "topics_request#{suffix}"
  stub = Overhead::Collection::Stub.new('grpc:50051', :this_channel_is_insecure)
  n.times do |i|
    size = (i + 1)
    p "Starting iteration for size: #{size}"
    2.times do |j|
      message = nil
      measure = Benchmark.measure { message = stub.get_topics(::Overhead::SizeRequest.new(size: size)) }
      begin
        Log.create(created_at: Time.now.utc.iso8601, message_size: message.response_bytes, time_spend: ((measure.real * 1000) - message.time_spend).to_i, kind: kind)
      rescue
        retry
      end
    end
  end
end

def rest_objects_satble_connection_test(n, suffix = '')
  kind = "rest_topics_request#{suffix}"
  n.times do |i|
    size = (i + 1)
    p "Starting iteration for size: #{size}"
    2.times do |j|
      message = nil
      measure = Benchmark.measure do 
	response = JSON.load(Net::HTTP.get(URI("http://web:50051/topics?size=#{size}&fo#{rand(1..10000)}=#{rand(1..10000)}")))
        topics = response['topics'].map do |topic|
          widget_attr = topic.delete('widgets')
          ::Overhead::Topic.new(symb_keys(topic).merge(widgets: widget_attr.map {|n| ::Overhead::Widget.new(symb_keys(n)) }))
        end
        message = ::Overhead::TopicsResponse.new(time_spend: response['time_spend'], topics: topics, response_bytes: response['response_bytes'])
      end
      p "real: #{(measure.real * 1000)}"
      p "minus: #{message.time_spend}"
      begin
        Log.create(created_at: Time.now.utc.iso8601, message_size: message.response_bytes, time_spend: ((measure.real * 1000) - message.time_spend).to_i, kind: kind)
      rescue => e 
        p e
        p 'Cannot connect to elastic'
        retry
      end
    end
  end
end

def symb_keys(hash)
  hash.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
end

def perform_interations(stub:, i:, kind:)
  size = (i + 1) ** 2
  p "Starting iteration for size: #{size}"
  100.times do |j|
    measure = Benchmark.measure { stub.get_feature(::Overhead::SizeRequest.new(size: size)) }
    begin
      Log.create(created_at: Time.now.utc.iso8601, message_size: size, time_spend: (measure.real * 1000).to_i, kind: kind)
    rescue
      p 'Cnnot connect to elastic'
      retry
    end
  end
end

def main
  # rest_objects_satble_connection_test(OPTS[:number], 'ver5')
  objects_stable_connection_test(OPTS[:number], 'ver2')  
end
main

