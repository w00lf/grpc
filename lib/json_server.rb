require 'grpc'
require 'sinatra'
require 'content_generator'
require 'benchmark'
require 'overhead_active_model_serializers'

include ContentGenerator
set :bind, '0.0.0.0'
set :port, 50051

get '/utf8' do
  content_type :json
  random_utf_string(params[:size].to_i)
end

get '/topics' do
  content_type :json
  ComplexResponseSerializer.new(create_object(params[:size].to_i)).as_json.to_json
end
