require 'grpc'
require 'sinatra'
require 'content_generator'
require 'benchmark'
require 'active_model_serializers'

include ContentGenerator
set :bind, '0.0.0.0'
set :port, 50051

alias read_attribute_for_serialization send

class ComplexResponseSerializer < ActiveModel::Serializer
  attributes :time_spend, :response_bytes
  has_many :topics
end

class TopicSerializer < ActiveModel::Serializer
  attributes :id, :headline, :alternative_headline, :announce, :content_type, :dispatched_at, :is_visible, :partner_related, :preview_token, :published_at
  has_many :widgets
end

class WidgetSerializer < ActiveModel::Serializer
  attributes :id, :type, :data, :created_at, :updated_at, :position
end

get '/utf8' do
  content_type :json

  random_utf_string(params[:size].to_i)
end

get '/topics' do
  content_type :json
  ComplexResponseSerializer.new(create_object(params[:size].to_i)).as_json.to_json
end
