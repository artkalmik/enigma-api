require 'connection_pool'

Redis.current = ConnectionPool.new(size: 5, timeout: 5) do
  Redis.new(
    url: ENV.fetch('REDIS_URL') { 'redis://redis:6379/0' },
    driver: :hiredis
  )
end

# Настройка кэширования
Rails.application.configure do
  config.cache_store = :redis_cache_store, {
    url: ENV.fetch('REDIS_URL') { 'redis://redis:6379/0' },
    pool_size: ENV.fetch('RAILS_MAX_THREADS') { 5 },
    pool_timeout: 5,
    connect_timeout: 1,
    read_timeout: 1,
    write_timeout: 1,
    reconnect_attempts: 3,
    error_handler: -> (method:, returning:, exception:) {
      Rails.logger.error(
        "Redis cache error: #{exception.class}: #{exception.message}"
      )
      Sentry.capture_exception(exception) if defined?(Sentry)
    }
  }
end 