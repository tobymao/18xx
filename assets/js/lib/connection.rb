# frozen_string_literal: true

require 'lib/storage'
require 'vendor/message-bus'
require 'vendor/message-bus-ajax'

module Lib
  class Connection
    def initialize(root)
      @root = root
      @subs = Hash.new(0)
      start_message_bus
    end

    # rubocop:disable Lint/UnusedMethodArgument
    def subscribe(channel, message_id = -1, multi: false, &block)
      return if @subs[channel].positive? && !multi

      @subs[channel] += 1

      %x{
        window.MessageBus.subscribe(#{channel}, function(data) {
          if (data['_client_id'] != MessageBus.clientId) {
            block.$call(Opal.Hash.$new(data))
          }
        }, message_id)
      }
    end
    # rubocop:enable Lint/UnusedMethodArgument

    def unsubscribe(channel)
      @subs[channel] = 0
      `window.MessageBus.unsubscribe(#{channel})`
    end

    def get(path, &block)
      send(path, 'GET', nil, block)
    end

    def post(path, data = {}, &block)
      send(path, 'POST', data, block)
    end

    def safe_post(path, params, &block)
      post(path, params) do |data|
        if (error = data['error'])
          @root.store(:flash_opts, error)
        elsif block
          block.call(data)
        end
      end
    end

    private

    def send(path, method, data, block) # rubocop:disable Lint/UnusedMethodArgument
      data = data&.merge('_client_id': `MessageBus.clientId`)

      %x{
        var payload = {
          method: #{method},
          headers: {
            'Content-Type': 'application/json',
            'Authorization': #{Lib::Storage['auth_token']},
          }
        }

        if (method == 'POST') {
          payload['body'] = JSON.stringify(#{data.to_n})
        }

        fetch(#{'/api' + path}, payload).then(res => {
          return res.text()
        }).then(data => {
          if (typeof block === 'function') {
            block.$call(Opal.Hash.$new(JSON.parse(data)))
          }
        }).catch(error => {
          if (typeof block === 'function') {
            block(Opal.hash('error', JSON.stringify(error)))
          }
        })
      }
    end

    def start_message_bus
      %x{
        window.MessageBus.start()
        window.MessageBus.callbackInterval = 1000
      }
    end
  end
end
