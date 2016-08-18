require 'grpc'
require 'helloworld'
require 'helloworld_services_pb'
require 'benchmark'
require 'faker'

class HelloworldServer < Helloworld::Greeter::Service
  def say_hello(size_request, _unused_call)
    ::Helloworld::HelloReply.new(message: Faker::Commerce.product_name)
  end
end

s = GRPC::RpcServer.new
s.add_http2_port('0.0.0.0:50051', :this_port_is_insecure)
s.handle(HelloworldServer)
s.run_till_terminated
