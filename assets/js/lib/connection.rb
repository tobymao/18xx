# frozen_string_literal: true

require 'json'
require 'lib/storage'
require 'vendor/message-bus'
require 'vendor/message-bus-ajax'

module Lib
  class Connection
    def initialize(root)
      puts "** init connection **"
      @root = root
      start_message_bus
    end

    def subscribe(channel, message_id = -1, &block)
      %x{
        MessageBus.subscribe(#{channel}, function(data) {
          block(data)
        }, message_id)
      }
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
            block(#{JSON.parse(data)})
          }
        }).catch(error => {
          block(Opal.hash('error', error))
        })
      }
    end

    def start_message_bus
      %x{
        MessageBus.start()
        MessageBus.callbackInterval = 1000
      }
    end
  end
end
