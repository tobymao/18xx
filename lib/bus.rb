# frozen_string_literal: true

require 'message_bus'
require 'redis'

module Bus
  URL = 'redis://redis:6379'.freeze

  USER_TS_PREFIX = 'user_ts'.freeze
  USER_TS = "#{USER_TS_PREFIX}:%d".freeze

  USER_STATS_PREFIX = 'user_stats'.freeze
  USER_STATS = "#{USER_STATS_PREFIX}:%d".freeze

  TTL = {
    USER_TS_PREFIX => 60 * 5,
    USER_STATS_PREFIX => 60 * 60 * 25,
  }.freeze

  def self.configure
    MessageBus.configure(backend: :redis, url: URL)
    MessageBus.backend_instance.max_backlog_size = 1
    MessageBus.backend_instance.max_global_backlog_size = 100_000
    MessageBus.backend_instance.max_backlog_age = 172_800 # 2 days
  end

  def self.redis
    @redis ||= Redis.new(url: URL)
  end

  def self.[](key)
    redis.get(key)
  end

  def self.store_keys(keys)
    redis.pipelined do |pipeline|
      keys.each do |key, value|
        pipeline.set(key, value)
        pipeline.expire(key, ttl_for(key))
      end
    end
  end

  def self.[]=(key, value)
    redis.pipelined do |pipeline|
      pipeline.set(key, value)
      pipeline.expire(key, ttl_for(key))
    end

    value
  end

  def self.ttl_for(key)
    prefix = key.split(':')[0]
    TTL[prefix] || 0
  end
end
