# frozen_string_literal: true

require 'message_bus'
require 'redis'

module Bus
  TTL = 60 * 5
  URL = 'redis://redis:6379'

  USER_TS = 'user_ts:%d'

  def self.configure
    MessageBus.configure(backend: :redis, url: URL)
    MessageBus.reliable_pub_sub.max_backlog_size = 1
    MessageBus.reliable_pub_sub.max_global_backlog_size = 100_000
    MessageBus.reliable_pub_sub.max_backlog_age = 172_800 # 2 days
  end

  def self.redis
    @redis ||= Redis.new(url: URL)
  end

  def self.[](key)
    redis.get(key)
  end

  def self.[]=(key, value)
    redis.pipelined do
      redis.set(key, value)
      redis.expire(key, TTL)
    end

    value
  end
end
