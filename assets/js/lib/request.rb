# frozen_string_literal: true

require 'json'
require 'lib/storage'

module Lib
  module Request
    def self.get(path, &block)
      send(path, 'GET', nil, block)
    end

    def self.post(path, data = {}, &block)
      send(path, 'POST', data, block)
    end

    def self.send(path, method, data, block) # rubocop:disable Lint/UnusedMethodArgument
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
          console.error('Error:', error)
        })
      }
    end
  end
end
