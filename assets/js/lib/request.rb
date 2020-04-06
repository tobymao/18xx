# frozen_string_literal: true

require 'json'

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
          headers: { 'Content-Type': 'application/json' }
        }

        if (method == 'POST') {
          payload['body'] = JSON.stringify(#{Native.convert(data)})
        }

        fetch(#{path}, payload).then(res => {
          return res.text()
        }).then(data => {
          if (typeof block === 'function') {
            block(data)
          }
        }).catch(error => {
          console.error('Error:', error)
        })
      }
    end
  end
end
