# frozen_string_literal: true

require 'view/log'

module View
  class Chat < Snabberb::Component
    needs :user
    needs :connection
    needs :type, default: :global
    needs :log, default: [], store: true

    def render
      @connection.subscribe('/chat', 0) do |data|
        name = data[:user][:name]
        ts = data[:created_at]
        message = data[:message]
        store(:log, @log + ["#{ts} #{name}: #{message}"])
      end

      destroy = lambda do
        @connection.unsubscribe('/chat')
      end

      children = [
        h(Log, log: @log),
      ]

      enter = lambda do |event|
        code = event.JS['keyCode']

        if code && code == 13
          @connection.post('/chat', message: event.JS['target'].JS['value'])
          event.JS['target'].JS['value'] = ''
        end
      end

      children << h(:input, style: { width: '100%' }, on: { keyup: enter }) if @user

      props = {
        key: "#{@type}_chat",
        hook: {
          destroy: destroy,
        },
        style: {
          display: 'inline-block',
        }
      }

      h('div.half', props, children)
    end
  end
end
