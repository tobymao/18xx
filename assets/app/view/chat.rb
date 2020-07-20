# frozen_string_literal: true

require 'lib/settings'
require 'view/log'

module View
  class Chat < Snabberb::Component
    include Lib::Settings

    needs :user
    needs :connection
    needs :log, default: [], store: true
    needs :subscribed, default: false, store: true

    def render
      @connection.subscribe('/chat', 0) do |data|
        add_line(data)
      end unless @subscribed

      store(:subscribed, true, skip: true)

      destroy = lambda do
        store(:log, [], skip: true)
        store(:subscribed, false, skip: true)
        @connection.unsubscribe('/chat')
      end

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

      chatbar_props = {
        attrs: {
          placeholder: 'Send a message',
        },
        style: {
          height: '1.4rem',
          width: '100%',
          margin: '0',
          'box-sizing': 'border-box',
          'border-radius': '0',
          background: color_for(:bg2),
          color: color_for(:font2),
          resize: 'vertical',
        },
        on: { keyup: enter },
      }

      children << h('textarea#chatbar', chatbar_props) if @user

      props = {
        key: 'global_chat',
        hook: {
          destroy: destroy,
        },
        style: {
          'vertical-align': 'top',
        },
      }

      h('div#chat.half', props, children)
    end

    def add_line(data)
      name = data[:user][:name]
      ts = Time.at(data[:created_at]).strftime('%Y-%m-%d %H:%M:%S')
      message = data[:message]
      store(:log, @log << "#{ts} #{name}: #{message}")
    end
  end
end
