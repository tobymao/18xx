# frozen_string_literal: true

require 'message_bus'

module Bus
  def self.configure(db)
    MessageBus.configure(
      backend: :postgres,
      backend_options: {
        host: db.opts[:host],
        user: db.opts[:user],
        dbname: db.opts[:database],
        password: db.opts[:password],
        port: db.opts[:port],
      },
      clear_every: 10,
    )

    MessageBus.reliable_pub_sub.max_backlog_size = 2
    MessageBus.reliable_pub_sub.max_global_backlog_size = 100_000
    MessageBus.reliable_pub_sub.max_backlog_age = 172_800 # 2 days
  end
end
