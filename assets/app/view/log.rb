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
        },
      }

      if @negative_pad
        props[:style][:padding] = '0.5rem 2vmin'
        props[:style][:margin] = '0 -2vmin'
      else
        props[:style][:boxSizing] = 'border-box'
      end

      timestamp_props = { style: { margin: '0 0.2rem',
                                   fontSize: 'smaller' } }
      username_props = { style: { margin: '0 0.2rem',
                                  fontWeight: 'bold' } }
      message_props = { style: { margin: '0 0.2rem' } }

      lines = @log.each_with_index.map do |line, index|
        line_props = { style: { marginBottom: '0.2rem',
                                paddingLeft: '0.5rem',
                                textIndent: '-0.5rem' } }
        if line.is_a?(String)
          if line.start_with?('--')
            line_props[:style][:fontWeight] = 'bold'
            line_props[:style][:marginTop] = '0.5em' if index.positive?
          end
          h(:div, line_props, line)
        elsif line.is_a?(Hash) # Homepage chat
          time = Time.at(line[:created_at])
          timestamp = time.strftime(time + 86_400 < Time.now ? '%F %T' : '%T')
          h('div.chatline', line_props, [
            h('span.timestamp', timestamp_props, timestamp),
            h('span.username', username_props, line[:user][:name]),
            h('span.message', message_props, line[:message]),
          ])
        elsif line.is_a?(Engine::Action::Message)
          sender = line.entity.name || line.user
          h(:div, { style: { fontWeight: 'bold' } }, "#{sender}: #{line.message}")
        end
      end

      h('div#chatlog', props, lines)
    end
  end
end
