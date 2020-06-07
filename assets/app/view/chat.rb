# frozen_string_literal: true

require 'view/log'

module View
  class Chat < Snabberb::Component
    needs :user
    needs :connection
    needs :log, default: nil, store: true
    needs :subscribed, default: false, store: true

    def render
      @connection.subscribe('/chat', 0) do |data|
        add_line(data)
      end unless @subscribed

      store(:subscribed, true, skip: true)

      destroy = lambda do
        store(:log, nil, skip: true)
        @connection.unsubscribe('/chat')
      end

      @log ||= []

      children = [h(Log, log: @log)]

      enter = lambda do |event|
        event = Native(event)
        code = event['keyCode']

        if code && code == 13
          message = event['target']['value']
          if message.strip != ''
            add_line(user: @user, created_at: Time.now.to_i, message: message)
            event['target']['value'] = ''
            @connection.post('/chat', message: message)
          end
        end
      end

      children << h('input#chatbar', on: { keyup: enter }) if @user

      props = {
        key: 'global_chat',
        hook: {
          destroy: destroy,
        },
        style: {
          display: 'inline-block',
          'vertical-align': 'top',
        },
      }

      h('div.half', props, children)
    end

    def add_line(data)
      name = data[:user][:name]
      ts = Time.at(data[:created_at]).strftime('%m/%d %H:%M:%S')
      message = data[:message]
      store(:log, @log + ["#{ts} #{name}: #{message}"])
    end
  end
end
