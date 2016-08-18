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

Log.gateway.client.indices.delete index: Log.index_name if OPTS.remove?

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
    stub = Overhead::Collection::Stub.new('localhost:50051', :this_channel_is_insecure)
    perform_interations(stub: stub, i: i, kind: kind)
    stub = nil
  end
end

def objects_stable_connection_test(n, suffix = '')
  kind = "stable_connection#{suffix}"
  stub = Overhead::Collection::Stub.new('localhost:50051', :this_channel_is_insecure)
  n.times do |i|
    size = (i + 1) ** 2
    p "Starting iteration for size: #{size}"
    100.times do |j|
      message = nil
      measure = Benchmark.measure { message = stub.get_complex_feature(::Overhead::SizeRequest.new(size: size)) }
      Log.create(created_at: Time.now.utc.iso8601, message_size: size, time_spend: ((measure.real * 1000) - message.time_spend).to_i, kind: kind)
    end
  end
end

def perform_interations(stub:, i:, kind:)
  size = (i + 1) ** 2
  p "Starting iteration for size: #{size}"
  100.times do |j|
    measure = Benchmark.measure { stub.get_feature(::Overhead::SizeRequest.new(size: size)) }
    Log.create(created_at: Time.now.utc.iso8601, message_size: size, time_spend: (measure.real * 1000).to_i, kind: kind)
  end
end

def main
  kind = "topics_request_ver1"
  stub = Overhead::Collection::Stub.new('localhost:50051', :this_channel_is_insecure)
  OPTS[:number].times do |i|
    size = (i + 1) ** 2
    p "Starting iteration for size: #{size}"
    100.times do |j|
      message = nil
      measure = Benchmark.measure { message = stub.get_topics(::Overhead::SizeRequest.new(size: size)) }
      Log.create(created_at: Time.now.utc.iso8601, message_size: message.response_bytes, time_spend: ((measure.real * 1000) - message.time_spend).to_i, kind: kind)
    end
  end
end
main

