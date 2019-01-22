Sidekiq.configure_server do |config|
  config.redis = {
    url: "redis://#{$redis.client.options[:host]}:#{$redis.client.options[:port]}/0",
    namespace: 'smas4mail'
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: "redis://#{$redis.client.options[:host]}:#{$redis.client.options[:port]}/0",
    namespace: 'smas4mail'
  }
end
