# frozen_string_literal: true

require 'json'

module Lib
  class Connection
    def initialize(path, handler)
      @path = path
      @handler = handler
      @source = `new EventSource(#{path})`
      add_event_listeners
    end

    def url
      `window.location.protocol + window.location.host + #{@path}`
    end

    def add_event_listeners
      @source.JS.onmessage = ->(event) { on_message(event.JS['data']) }
      @source.JS.onopen = -> { on_open }
      @source.JS.onerror = -> { on_error }
    end

    def send(type, data = nil)
      %x{
        setTimeout(function(){
          fetch(#{"/game/#{type}"}, {
            method: "POST",
            headers: {
              'Content-Type': 'application/json'
            },
            body: JSON.stringify(#{Native.convert(data)})
          }).then(res => {
            return res.text()
          }).then(data => {
            this.$on_message(data)
          }).catch(error => {
            console.error('Error:', error)
          })
        }, 1)
      }
    end

    def on_message(data)
      return if data.empty?

      data = JSON.parse(data)
      type = data['type']
      data = data['data']
      @handler.on_message(type, data)
    end

    def on_open
      send('refresh')
    end

    def on_error
      puts 'event source connection error'
    end
  end
end
