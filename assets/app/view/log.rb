# frozen_string_literal: true

require 'lib/settings'

module View
  class Log < Snabberb::Component
    include Lib::Settings

    needs :log
    needs :negative_pad, default: false
    needs :follow_scroll, default: true, store: true

    def render
      scroll_to_bottom = lambda do |vnode|
        next unless @follow_scroll

        elm = Native(vnode)['elm']
        elm.scrollTop = elm.scrollHeight
      end

      scroll_handler = lambda do |event|
        elm = Native(event).target
        bottom = elm.scrollHeight - elm.scrollTop <= elm.clientHeight + 5
        store(:follow_scroll, bottom, skip: true) if @follow_scroll != bottom
      end

      props = {
        key: 'log',
        hook: {
          postpatch: ->(_, vnode) { scroll_to_bottom.call(vnode) },
          insert: ->(vnode) { scroll_to_bottom.call(vnode) },
          destroy: -> { store(:follow_scroll, true, skip: true) },
        },
        on: { scroll: scroll_handler },
        style: {
          overflow: 'auto',
          padding: '0.5rem',
          backgroundColor: color_for(:bg2),
          color: color_for(:font2),
          wordBreak: 'break-word',
          cursor: 'text',
        },
      }

      if @negative_pad
        props[:style][:padding] = '0.5rem 2vmin'
        props[:style][:margin] = '0 -2vmin'
      else
        props[:style][:boxSizing] = 'border-box'
      end

      h('div#chatlog', props, chat_log(@log))
    end

    def chat_log(log)
      return unless log[0]

      prev_username = log[0][:user][:name]
      line_props = {
        style: {
          marginTop: '0.2rem',
          paddingLeft: '3.8rem',
          textIndent: '-3.7rem',
        },
      }
      timestamp_props = {
        style: {
          margin: '0 0.2rem 0 0',
          fontSize: 'smaller',
        },
        class: { hidden: false },
      }
      username_props = {
        style: {
          margin: '0 0.2rem',
          fontWeight: 'bold',
        },
      }
      message_props = { style: { margin: '0 0.2rem' } }

      log.map.with_index do |line, i|
        if i.positive?
          username = line[:user][:name]
          if username == prev_username
            line_props[:style][:marginTop] = '0'
            timestamp_props[:class][:hidden] = true
            username_props[:style][:display] = 'none'
          else
            line_props[:style][:marginTop] = '0.2rem'
            timestamp_props[:class][:hidden] = false
            username_props[:style][:display] = ''
            prev_username = username
          end
        end

        time = Time.at(line[:created_at])
        timestamp = time.strftime(time + 86_400 < Time.now ? '%F %T' : '%T')

        h('div.chatline', line_props, [
          h('span.timestamp', timestamp_props, timestamp),
          h('span.username', username_props, line[:user][:name]),
          h('span.message', message_props, line[:message]),
        ])
      end
    end
  end
end
