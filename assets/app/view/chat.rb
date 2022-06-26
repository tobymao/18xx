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
      unless @subscribed
        @connection.subscribe('/chat', 0) do |data|
          add_line(data)
        end
      end

      store(:subscribed, true, skip: true)

      destroy = lambda do
        store(:log, [], skip: true)
        store(:subscribed, false, skip: true)
        @connection.unsubscribe('/chat')
      end

      children = [h(Log, log: @log)]

      enter = lambda do |event|
        event = Native(event)

        if event['key'] == 'Enter'
          message = event['target']['value']
          if message.strip != ''
            add_line(user: @user, created_at: Time.now.to_i, message: message)
            event['target']['value'] = ''
            @connection.post('/chat', message: message)
          end
        end
      end

      prevent_default = lambda do |event|
        event = Native(event)
        event.preventDefault
      end

      form_props = { on: { submit: prevent_default } }

      chatbar_props = {
        attrs: {
          autocomplete: 'off',
          placeholder: 'Send a message (Please keep discussions to 18xx)',
          type: 'text',
        },
        style: {
          cursor: 'text',
          width: '100%',
          margin: '0',
          boxSizing: 'border-box',
          borderRadius: '0',
          background: color_for(:bg2),
          color: color_for(:font2),
        },
        on: { keyup: enter },
      }

      children << h(:form, form_props, [h('input#chatbar', chatbar_props)]) if @user

      props = {
        key: 'global_chat',
        hook: {
          destroy: destroy,
        },
        style: {
          verticalAlign: 'top',
          marginBottom: '1rem',
        },
      }

      h('div#chat.half', props, children)
    end

    private

    QUOTED_BASE_URL = Regexp.quote(`window.location.origin || ''`)
    GAME_LINK_RE = Regexp.new("((?:game #?|#|#{QUOTED_BASE_URL}/game/)(\\d+(?:\\?action=\\d+)?))")

    def parse_message(message)
      message_parts = message.split(GAME_LINK_RE)
      return message if message_parts.count <= 1

      children = []
      # The first element can either unmatched text or a match, depending.
      children << message_parts.shift unless GAME_LINK_RE.match?(message_parts[0])

      until message_parts.empty?
        matched_text = message_parts.shift
        url = "/game/#{message_parts.shift}"
        children << h(:a, { attrs: { href: url, target: '_blank' } }, matched_text)
        # There might not be a final unmatched text segment.
        children << message_parts.shift unless message_parts.empty?
      end

      children
    end

    def add_line(data)
      data[:message] = parse_message(data[:message])
      store(:log, @log << data)
    end
  end
end
