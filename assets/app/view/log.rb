# frozen_string_literal: true

module View
  class Log < Snabberb::Component
    needs :log
    needs :follow_scroll, default: true, store: true

    def render
      scroll_to_bottom = lambda do |vnode|
        elm = Native(vnode)['elm']
        elm.scrollTop = elm.scrollHeight
      end

      scroll_handler = lambda do
        # can't seem to access the target of the event here
      end

      props = {
        key: 'log',
        hook: {
          postpatch: ->(_, vnode) { scroll_to_bottom.call(vnode) if @follow_scroll },
        },
        on: {
          scroll: scroll_handler
        },
        style: {
          overflow: 'auto',
          height: '200px',
          padding: '0.5rem',
          'background-color': 'lightgray',
          color: 'black',
          'word-break': 'break-word',
        },
      }

      lines = @log.map do |line|
        if line.is_a?(String)
          h(:div, line)
        elsif line.is_a?(Engine::Action::Message)
          h(:div, { style: { 'font-weight': 'bold' } }, "#{line.entity.name}: #{line.message}")
        end
      end

      h(:div, props, lines)
    end
  end
end
