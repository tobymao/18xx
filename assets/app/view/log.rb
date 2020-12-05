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

      children = []

      lines = if @log.respond_to?(:lines)
                @log.lines
              else
                @log
              end

      date_previous = 0
      lines.each do |line|
        line_props = { style: { marginBottom: '0.2rem',
                                paddingLeft: '0.5rem',
                                textIndent: '-0.5rem' } }

        time_props = { style: { margin: '0.2rem 0.3rem',
                                fontSize: 'smaller' } }

        username_props = { style: { margin: '0 0.2rem 0 0.4rem',
                                    fontWeight: 'bold' } }

        message_props = { style: { margin: '0 0.1rem' } }

        if line[:created_at]
          time = Time.at(line[:created_at])
          time_str = time.strftime('%R')

          if date_previous < time.strftime('%Y%j').to_i
            date_previous = time.strftime('%Y%j').to_i

            date_line_props = { style: { marginTop: '0.5rem',
                                         marginBottom: '0.5rem',
                                         paddingLeft: '0.5rem',
                                         fontWeight: 'bold',
                                         textIndent: '-0.5rem' } }
            children << h('div.logline', date_line_props,
                          [h('span.date', message_props, time.strftime('%F'))])
          end
        end

        if line.is_a?(String)
          if line.start_with?('--')
            line_props[:style][:fontWeight] = 'bold'
            line_props[:style][:marginTop] = '0.4em'
            line_props[:style][:marginBottom] = '0.4em'
          else
            line_props[:style][:paddingLeft] = '2rem'
          end

          children << h(:div, line_props, line)
        elsif line.is_a?(Hash)
          require 'view/log_line'
          children << if line[:type]
                        h('div.logline', line_props, [h(LogLine, line: line)])
                      else
                        h('div.chatline', line_props, [
                          h('span.time', time_props, time_str),
                          h('span.username', username_props, line[:user][:name]),
                          h('span.message', message_props, line[:message]),
                        ])
                      end
        end
      end

      h('div#chatlog', props, children)
    end
  end
end
