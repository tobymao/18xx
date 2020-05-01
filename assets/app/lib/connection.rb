# frozen_string_literal: true

require 'lib/storage'

module Lib
  class Connection
    def initialize(root)
      @root = root
      start_message_bus
    end

    # rubocop:disable Lint/UnusedMethodArgument
    def subscribe(channel, message_id = -1, &block)
      unsubscribe(channel)

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
      `window.MessageBus.unsubscribe(#{channel})`
    end

    def get(path, &block)
      send(path, 'GET', nil, block)
    end

    def post(path, data = {}, &block)
      send(path, 'POST', data, block)
    end

    def safe_get(path, &block)
      get(path) do |data|
        if (error = data['error'])
          @root.store(:flash_opts, error)
        elsif block
          block.call(data)
        end
      end
    end

    def safe_post(path, params = {}, &block)
      post(path, params) do |data|
        if (error = data['error'])
          @root.store(:flash_opts, error)
        elsif block
          block.call(data)
        end
      end
    end

    def authenticate!
      `MessageBus.headers = {'Authorization': #{auth_token}}`
    end

    def invalidate!
      `MessageBus.headers = {}`
    end

    private

    def auth_token
      Lib::Storage['auth_token']
    end

    def send(path, method, data, block) # rubocop:disable Lint/UnusedMethodArgument
      data = data&.merge('_client_id': `MessageBus.clientId`)

      %x{
        var payload = {
          method: #{method},
          headers: {
            'Content-Type': 'application/json',
            'Authorization': #{auth_token},
          }
        }

        if (method == 'POST') {
          payload['body'] = JSON.stringify(#{data.to_n})
        }

        if (typeof fetch !== 'undefined') {
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
