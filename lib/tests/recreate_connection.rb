def recreate_connection_test(n, suffix = '')
  kind = "recreate_connection#{suffix}"
  n.times do |i|
    size = (i + 1) ** 2
    p "Starting iteration for size: #{size}"
    100.times do |j|
      stub = Overhead::Collection::Stub.new('localhost:50051', :this_channel_is_insecure)
      measure = Benchmark.measure { stub.get_feature(::Overhead::SizeRequest.new(size: size)) }
      begin
        Log.create(created_at: Time.now.utc.iso8601, message_size: size, time_spend: (measure.real * 1000).to_i, kind: kind)
      rescue
        p 'Cnnot connect to elastic'
        retry
      end
      stub = nil
    end
  end
end
