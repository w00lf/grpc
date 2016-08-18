require 'grpc'
require 'topicrpc'
require 'topicrpc_services_pb'

require 'elasticsearch/persistence/model'



class Log
  include Elasticsearch::Persistence::Model
  attribute :created_at, Date, type: 'date'
  attribute :message_size, Integer, default: 0, mapping: { type: 'integer' }
  attribute :time_spend, Integer, default: 0, mapping: { type: 'integer' }
end
Log.gateway.client.indices.delete index: Log.index_name

# Log.create created_at: Time.now.utc.iso8601, message_size: rand(0..100), time_spend: rand(5..200)


def main
  stub = Topicrpc::Collection::Stub.new('localhost:50051', :this_channel_is_insecure)
  message = stub.get_feature(::Topicrpc::TopicRequest.new(topic_id: 1))
  p message.inspect
end
main
