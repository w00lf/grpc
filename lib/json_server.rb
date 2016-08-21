require 'grpc'
require 'sinatra'
require 'content_generator'
require 'benchmark'
require 'json'

include ContentGenerator
set :bind, '0.0.0.0'
set :port, 50051

get '/utf8' do
  content_type :json

  random_utf_string(params[:size].to_i)
end

get '/topics' do
  content_type :json
  
  result = nil
  size = params[:size].to_i
  time_spend = (Benchmark.measure { result = Array.new(size){ topic_attributes.merge(widgets: Array.new(3) { widget_attributes }) } }.real * 1000).to_i
  p time_spend
  
  JSON({ time_spend: time_spend, topics: result, response_bytes: TOPIC_WEIGTH_BYTES * size })
end
