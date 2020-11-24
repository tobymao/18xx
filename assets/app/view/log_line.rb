# frozen_string_literal: true

module View
  class LogLine < Snabberb::Component
    include View::Game::Actionable
    include Lib::Settings

    needs :line
    needs :app_route, default: nil, store: true
    needs :round_history, default: nil, store: true

    def render
      time_props = { style: { margin: '0.2rem 0.3rem',
                              fontSize: 'smaller' } }

      message_props = { style: { margin: '0 0.1rem' } }

      time_str = '⇤'
      if @line[:created_at]
        time = @line[:created_at]
        time_str = time.strftime('%R')
      end

      case @line[:type]
      when :action
        entity_props = { style: { margin: '0 0.2rem',
                                  fontStyle: 'italic' } }
        preamble_props = { style: { margin: '0.1rem',
                                    fontSize: 'smaller' } }
        children = [h('span.time', time_props, [history_link(time_str, "Go to action##{@line[:id]}", @line[:id])])]

        children << h('span.entity', entity_props, @line[:entity]) if @line[:entity]

        @line[:user_text] = "controlled by #{@line[:user]}" if @line[:user]
        preamble = @line.values_at(:player, :user_text).compact.join(', ')
        children << h('span.preamble', preamble_props, "(#{preamble})") unless preamble.empty?

        children << h('span.message', message_props, @line[:message])
        h('span', children)
      when :message
        username_props = { style: { margin: '0 0.2rem 0 0.4rem',
                                    fontWeight: 'bold' } }
        h('span', [
          h('span.time', time_props, [history_link(time_str, "Go to action##{@line[:id]}", @line[:id])]),
          h('span.username', username_props, @line[:username]),
          h('span.separator', time_props, '➤'),
          h('span.message', message_props, @line[:message]),
        ])
      when :undo
        undo_props = { style: { margin: '-0.2rem',
                                fontSize: '0.7rem' } }

        h('div.undo', undo_props, '↺')
      end
    end
  end
end
