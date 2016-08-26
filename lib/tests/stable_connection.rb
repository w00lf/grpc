def stable_connection_test(n, suffix = '')
  kind = "stable_connection#{suffix}"
  stub = Overhead::Collection::Stub.new('localhost:50051', :this_channel_is_insecure)
  n.times do |i|
    perform_interations(stub: stub, i: i, kind: kind)
  end
end

def perform_interations(stub:, i:, kind:)
  size = (i + 1) ** 2
  p "Starting iteration for size: #{size}"
  100.times do |j|
    measure = Benchmark.measure { stub.get_feature(::Overhead::SizeRequest.new(size: size)) }
    begin
      Log.create(created_at: Time.now.utc.iso8601, message_size: size, time_spend: (measure.real * 1000).to_i, kind: kind)
    rescue
      p 'Cnnot connect to elastic'
      retry
    end
  end
end
