# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: topicrpc.proto

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_message "topicrpc.TopicRequest" do
    optional :topic_id, :int32, 1
  end
  add_message "topicrpc.TopicReply" do
    optional :id, :int32, 2
    optional :headline, :string, 3
    optional :announse, :string, 4
  end
end

module Topicrpc
  TopicRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup("topicrpc.TopicRequest").msgclass
  TopicReply = Google::Protobuf::DescriptorPool.generated_pool.lookup("topicrpc.TopicReply").msgclass
end
