# frozen_string_literal: true

module View
  class Log < Snabberb::Component
    include Lib::Color
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
          height: '200px',
          width: '100%',
          padding: '0.5rem',
          'background-color': color_for(:bg2),
          color: color_for(:font2),
          'word-break': 'break-word',
        },
      }

      if @negative_pad
        props[:style][:padding] = '0.5rem 1.5rem'
        props[:style][:margin] = '0 -1.5rem'
      else
        props[:style]['box-sizing'] = 'border-box'
      end

      lines = @log.map do |line|
        if line.is_a?(String)
          h(:div, line)
        elsif line.is_a?(Engine::Action::Message)
          h(:div, { style: { 'font-weight': 'bold' } }, "#{line.entity.name}: #{line.message}")
        end
      end

      h('div#chatlog', props, lines)
    end
  end
end
