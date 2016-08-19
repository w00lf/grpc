# class TopicrpcServer < Topicrpc::Collection::Service
#   def get_feature(topic_request, _unused_call)
#     p topic_request
#     topic = Topic.find(topic_request.topic_id)
#     p topic
#     ::Topicrpc::TopicReply.new(id: topic.id, headline: topic.headline, announse: topic.announce)
#   end
# end

require 'grpc'
require 'overhead'
require 'overhead_services_pb'
require 'benchmark'
require 'faker'
require 'byebug'

class OverheadRpcServer < Overhead::Collection::Service
  UTF_VARIANTS = (('а'..'я').to_a + [' ']).freeze
  ASCI_VARIANT = (('a'..'z').to_a + [' ']).freeze
  TOPIC_WEIGTH_BYTES = 7500

  def get_feature(size_request, _unused_call)
    ::Overhead::SizeResponse.new(message: random_utf_string(size_request.size))
  end

  def get_complex_feature(size_request, _unused_call)
    ::Overhead::ComplexResponse.new(time_spend: 1, messages: [::Overhead::ComplexObject.new(id: 1)])
  end

  def get_topics(size_request, _unused_call)
    create_object(size_request.size)
  end

  def create_object(size)
    result = nil
    time_spend = (Benchmark.measure { result = Array.new(size){ create_topic } }.real * 1000).to_i
    ::Overhead::TopicsResponse.new(time_spend: time_spend, topics: result, response_bytes: TOPIC_WEIGTH_BYTES * size)
  end

  def create_topic
    ::Overhead::Topic.new(id: rand(1..10_000),
                          headline: random_utf_string(200),
                          alternative_headline: random_utf_string(200),
                          announce: random_utf_string(400),
                          content_type: random_asci_string(6),
                          dispatched_at: random_unix,
                          is_visible: rand_bool,
                          partner_related: rand_bool,
                          preview_token: random_asci_string(12),
                          published_at: random_unix,
                          widgets: Array.new(3){ create_widget })
  end

  def create_widget
    ::Overhead::Widget.new(id: rand(1..10_000),
                          type: random_asci_string(6),
                          data: random_utf_string(1000),
                          created_at: random_unix,
                          updated_at: random_unix,
                          position: rand(1..100))
  end

  def random_utf_string(size)
    Array.new(size) { UTF_VARIANTS.sample }.join
  end

  def random_asci_string(size)
    Array.new(size) { ASCI_VARIANT.sample }.join
  end

  def random_unix
    Time.new(2016, rand(1..12), rand(1..20)).to_i
  end

  def rand_bool
    rand(1..2) == 1
  end
end

s = GRPC::RpcServer.new
s.add_http2_port('0.0.0.0:50051', :this_port_is_insecure)
s.handle(OverheadRpcServer)
s.run_till_terminated
