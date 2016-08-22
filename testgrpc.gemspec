# -*- ruby -*-
# encoding: utf-8

Gem::Specification.new do |s|
  s.name          = 'testgrpc'
  s.version       = '0.11.0'
  s.authors       = ['gRPC Authors']
  s.email         = 'foo@example.local'
  s.homepage      = 'https://github.com/grpc/grpc'
  s.summary       = 'gRPC Ruby overview sample'
  s.description   = 'Simple demo of using gRPC from Ruby'

  s.files         = `git ls-files -- ruby/*`.split("\n")
  s.require_paths = ['lib']
  s.platform      = Gem::Platform::RUBY

  s.add_dependency 'grpc', '~> 0.11'
  s.add_dependency 'virtus'
  s.add_dependency 'elasticsearch-model'
  s.add_dependency 'elasticsearch-persistence'
  s.add_dependency 'elasticsearch-rails'
  s.add_dependency 'slop', '~> 4.0'
  s.add_dependency 'faker'
  s.add_dependency 'byebug'
  s.add_dependency 'sinatra'
  s.add_dependency 'active_model_serializers'

  s.add_development_dependency 'bundler', '~> 1.7'
end
