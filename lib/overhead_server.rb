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
require 'content_generator'
require 'method_profiler'
# require 'grpc_logging'

class OverheadRpcServer < Overhead::Collection::Service
  include ::ContentGenerator

  def get_feature(size_request, _unused_call)
    ::Overhead::SizeResponse.new(message: random_utf_string(size_request.size))
  end

  def get_complex_feature(size_request, _unused_call)
    ::Overhead::ComplexResponse.new(time_spend: 1, messages: [::Overhead::ComplexObject.new(id: 1)])
  end

  def get_topics(size_request, _unused_call)
    result = create_object(size_request.size)
    # $profilers.each {|profiler| puts(profiler.report) }
    result
  end
end

# $profilers = [MethodProfiler.observe(GRPC::RpcDesc)]
s = GRPC::RpcServer.new
s.add_http2_port('0.0.0.0:50051', :this_port_is_insecure)
s.handle(OverheadRpcServer)
s.run_till_terminated
