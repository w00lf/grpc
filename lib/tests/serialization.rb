require 'grpc'
require 'overhead'
require 'overhead_services_pb'
require 'benchmark'
require 'slop'
require 'log'
require 'byebug'
require 'overhead_active_model_serializers'
require 'content_generator'

OPTS = Slop.parse do |o|
  o.integer '-n', '--number', 'Number of iterations', default: 1
  o.integer '-s', '--size', 'Maximum size of objects list', default: 1
end.freeze

include ::ContentGenerator

p 'Beginig serialization test'

def perform_test(n, object, &block)
  Benchmark.measure do
    n.times do |i|
      block.call(object)
    end
  end
end

def symb_keys(hash)
  hash.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
end

OPTS[:size].times do |size|
  p "Begining test for size: #{size}"
  object = create_object(size)

  p 'Grpc:'
  test_proc = Proc.new do |object|
    serialized = Overhead::TopicsResponse.encode(object)
    Overhead::TopicsResponse.decode(serialized)
  end
  p perform_test(OPTS[:number], object, &test_proc)

  p 'Json:'
  test_proc = Proc.new do |object|
    serialized = ComplexResponseSerializer.new(object).as_json.to_json
    response = JSON.load(serialized)
    topics = response['topics'].map do |topic|
      widget_attr = topic.delete('widgets')
      ::Overhead::Topic.new(symb_keys(topic).merge(widgets: widget_attr.map {|n| ::Overhead::Widget.new(symb_keys(n)) }))
    end
    ::Overhead::TopicsResponse.new(time_spend: response['time_spend'], topics: topics, response_bytes: response['response_bytes'])
  end
  p perform_test(OPTS[:number], object, &test_proc)
end

