# frozen_string_literal: true

require 'json'
require 'lib/request'

module Lib
  class Connection
    def initialize(game_id, handler)
      @game_id = game_id
      @handler = handler
      puts "** coming here ***"
      @source = `new EventSource(#{path})`
      add_event_listeners
    end

    def path
      "/api/game/#{@game_id}/subscribe"
    end

    def close
      %x{
        if (typeof self.source.close !== 'undefined') {
          self.source.close()
        }
      }
    end

    def add_event_listeners
      @source.JS.onmessage = lambda do |event|
        @handler.on_message(JSON.parse(event.JS['data']))
      end
    end

    def send(type, data = nil)
      Request.post("/game/#{@game_id}/#{type}", data) do |resp|
        next unless data

        @handler.on_message(resp)
      end
    end
  end
end
