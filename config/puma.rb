# frozen_string_literal: true

require 'message_bus'

bind 'tcp://0.0.0.0:9292'

on_worker_boot do
  MessageBus.after_fork
end
