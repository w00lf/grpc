require 'elasticsearch/persistence/model'

class Log
  include Elasticsearch::Persistence::Model

  attribute :created_at, Date, type: 'date'
  attribute :kind, String, type: 'string', mapping: { index: 'not_analyzed' }
  attribute :message_size, Integer, default: 0, mapping: { type: 'integer' }
  attribute :time_spend, Integer, default: 0, mapping: { type: 'integer' }
end
Log.gateway.client = Elasticsearch::Client.new url: ENV['ELASTICSEARCH_URL'], log: false
